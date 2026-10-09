"""Att51_export Windows graphical shell; does not run Word or original ATT51.

Until original VBA is completely reproduced this app exposes only diagnostics.
No persistent configuration, cache, logs or user exports outside {app}.
"""
from __future__ import annotations

import json
from pathlib import Path
import queue
import sys
import threading
import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext, ttk
import webbrowser
from dataclasses import asdict

if not getattr(sys, "frozen", False):
    sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "fsa_xml_module"))

from att51_fsa.sources import AppSources, FsaSourceError
from att51_fsa.resources import ResourceCatalog
from att51_fsa.resource_xml import inspect_protocol_resources_file, inspection_dict
from att51_fsa.pipeline_2025 import Original2025Options, analyze_2025_file, diagnostic_dict
from att51_fsa.writer import validate_xml
from updater import Release, UpdateError, apply_update, fetch_latest, newer, LATEST_WEB
from source_discovery import discover_installations, discover_protocols
from protocol_batch import inspect_all_2025
from internal_xml import inspect_internal_xml
from version import VERSION

APP_NAME = "Att51_export"


def included_file(relative: str) -> Path:
    root = Path(getattr(sys, "_MEIPASS", Path(__file__).parent))
    return root / relative


def human_error(exc: Exception) -> str:
    # Avoid writing potentially sensitive file paths and records to disk.
    return f"{type(exc).__name__}: {exc}"


class DesktopApp:
    def __init__(self, root: tk.Tk):
        self.root = root
        self.results: queue.Queue[tuple[str, object]] = queue.Queue()
        self.busy = False
        self.latest: Release | None = None
        self.fields = {name: tk.StringVar(value="") for name in
                       ("mdb", "resources", "xml", "ini", "rm")}
        self.acoustic = tk.BooleanVar(value=False)
        self.acoustic_only = tk.BooleanVar(value=False)
        self.per_operation = tk.BooleanVar(value=False)
        self.uncertainty = tk.BooleanVar(value=False)
        self.micro_results = tk.BooleanVar(value=False)
        self.micro_dose = tk.BooleanVar(value=False)
        self.status = tk.StringVar(value="Готово. Рабочая выгрузка XML ещё не реализована.")
        self.update_status = tk.StringVar(value="Обновления: проверка не выполнена")
        root.title(f"{APP_NAME} — v{VERSION} (диагностика)")
        root.geometry("1050x790")
        root.minsize(850, 620)
        icon = included_file("assets/app.ico")
        if icon.exists():
            try:
                root.iconbitmap(str(icon))
            except tk.TclError:
                pass
        self._build_ui()
        root.after(100, self._pump)
        root.after(350, self._auto_discover)
        root.after(1200, lambda: self._check_updates(manual=False))

    def _build_ui(self):
        style = ttk.Style(self.root)
        if "vista" in style.theme_names():
            style.theme_use("vista")
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(3, weight=1)

        heading = ttk.Frame(self.root, padding=(15, 12, 15, 8))
        heading.grid(row=0, column=0, sticky="ew")
        ttk.Label(heading, text=f"Att51_export  ·  v{VERSION}",
                  font=("Segoe UI", 17, "bold")).pack(anchor="w")
        ttk.Label(
            heading,
            text="Независимое чтение данных «Аттестация-5.1» для ФГИС ФСА · испытательная версия",
            foreground="#456280",
        ).pack(anchor="w", pady=(3, 0))

        pane = ttk.LabelFrame(
            self.root, text="Основные источники (доступ только для чтения)", padding=12)
        pane.grid(row=1, column=0, padx=14, pady=(0, 8), sticky="ew")
        pane.columnconfigure(1, weight=1)
        labels = [
            ("mdb", "База рабочих мест (.mdb)", [("Access MDB", "*.mdb")]),
            ("resources", "Справочник res_orgs.mdb", [("Access MDB", "*.mdb")]),
        ]
        for row, (name, label, extensions) in enumerate(labels):
            ttk.Label(pane, text=label, width=32).grid(
                row=row, column=0, sticky="w", pady=3)
            ttk.Entry(pane, textvariable=self.fields[name]).grid(
                row=row, column=1, sticky="ew", padx=8, pady=3)
            ttk.Button(
                pane, text="Обзор…", width=11,
                command=lambda n=name, ext=extensions: self._browse(n, ext),
            ).grid(row=row, column=2, pady=3)
        ttk.Label(pane, text="fgis_ra.ini (необязательно)", width=32).grid(
            row=2, column=0, sticky="w", pady=3)
        ttk.Entry(pane, textvariable=self.fields["ini"]).grid(
            row=2, column=1, sticky="ew", padx=8, pady=3)
        ttk.Button(
            pane, text="Обзор…", width=11,
            command=lambda: self._browse("ini", [("INI", "*.ini")]),
        ).grid(row=2, column=2, pady=3)
        ttk.Label(
            pane, text="Файл используется только для пользовательских подмен "
                       "идентификаторов ФГИС. Если его нет, оставьте поле пустым.",
            foreground="#456280",
        ).grid(row=3, column=0, columnspan=3, sticky="w", pady=(2, 0))
        findbar = ttk.Frame(pane)
        findbar.grid(row=4, column=0, columnspan=3, sticky="ew", pady=(8, 2))
        ttk.Button(findbar, text="Найти по настройкам",
                   command=lambda: self._discover_paths(interactive=True)
                   ).pack(side="left", padx=(0, 8))
        ttk.Button(findbar, text="Указать папку Аттестации…",
                   command=self._browse_installation).pack(side="left")

        detail = ttk.LabelFrame(
            self.root,
            text="Параметры диагностики (выбор одного XML необязателен)",
            padding=(12, 8))
        detail.grid(row=2, column=0, padx=14, pady=(0, 8), sticky="ew")
        detail.columnconfigure(1, weight=1)
        ttk.Label(detail, text="XML для отдельной проверки:").grid(
            row=0, column=0, sticky="w", pady=3)
        ttk.Entry(detail, textvariable=self.fields["xml"]).grid(
            row=0, column=1, sticky="ew", padx=8, pady=3)
        ttk.Button(
            detail, text="Обзор…", width=11,
            command=lambda: self._browse("xml", [("XML", "*.xml")]),
        ).grid(row=0, column=2, pady=3)
        ttk.Button(detail, text="Выбрать из базы…",
                   command=self._find_protocols).grid(
                       row=0, column=3, padx=(8, 0))
        opts = ttk.Frame(detail)
        opts.grid(row=1, column=0, columnspan=4, sticky="ew", pady=(8, 2))
        ttk.Label(opts, text="Фильтр по ID РМ (необязательно):").pack(side="left")
        ttk.Entry(opts, textvariable=self.fields["rm"], width=10).pack(
            side="left", padx=(6, 16))
        for name, var in (
            ("Акустические измерения", self.acoustic),
            ("Только акустические", self.acoustic_only),
            ("По операциям", self.per_operation),
            ("Неопределённость", self.uncertainty),
        ):
            ttk.Checkbutton(opts, text=name, variable=var).pack(side="left", padx=4)
        micro = ttk.Frame(detail)
        micro.grid(row=2, column=0, columnspan=4, sticky="w", pady=(3, 0))
        ttk.Checkbutton(micro, text="Итоговые значения микроклимата",
                        variable=self.micro_results).pack(side="left")
        ttk.Checkbutton(micro, text="Экспозиционная доза",
                        variable=self.micro_dose).pack(side="left", padx=(20, 0))

        report = ttk.LabelFrame(self.root, text="Проверка и результаты", padding=(10, 8))
        report.grid(row=3, column=0, padx=14, sticky="nsew")
        report.rowconfigure(1, weight=1)
        report.columnconfigure(0, weight=1)
        tools = ttk.Frame(report)
        tools.grid(row=0, column=0, sticky="ew")
        self.buttons = []
        for index, (label, command) in enumerate((
            ("Проверить протоколы базы", self._inspect_mdb),
            ("Сопоставить все XML (6 факторов)", self._inspect_all_2025),
            ("Проверить справочники", self._inspect_resources),
            ("Сопоставить один XML", self._inspect_2025),
            ("Проверить структуру XML", self._validate_xml),
        )):
            b = ttk.Button(tools, text=label, command=command)
            b.grid(row=index // 3, column=index % 3, sticky="ew",
                   padx=(0, 7), pady=(0, 4))
            self.buttons.append(b)
        ttk.Button(tools, text="Копировать отчёт", command=self._copy).grid(
            row=1, column=2, sticky="ew", padx=(0, 7), pady=(0, 4))
        self.report = scrolledtext.ScrolledText(
            report, wrap="none", font=("Consolas", 10), undo=False)
        self.report.grid(row=1, column=0, sticky="nsew", pady=(8, 0))
        self.report.insert("1.0",
            "Сведения об организации, измерениях и сотрудниках выводятся только здесь.\n"
            "Программа не записывает отчёты, журналы и настройки на диск.\n"
            "Формирование итогового XML для ФГИС ФСА пока недоступно.\n")
        self.report.config(state="disabled")

        bottom = ttk.Frame(self.root, padding=(15, 10, 15, 14))
        bottom.grid(row=4, column=0, sticky="ew")
        ttk.Label(bottom, textvariable=self.status, foreground="#6d4a10").pack(anchor="w")
        bar = ttk.Frame(bottom)
        bar.pack(fill="x", pady=(8, 0))
        ttk.Label(bar, textvariable=self.update_status).pack(side="left")
        self.install_btn = ttk.Button(bar, text="Установить обновление",
                                      command=self._install_update)
        self.install_btn.pack(side="right", padx=(6, 0))
        self.install_btn.state(["disabled"])
        ttk.Button(bar, text="Открыть релизы", command=lambda: webbrowser.open(LATEST_WEB)
                   ).pack(side="right", padx=(6, 0))
        self.check_btn = ttk.Button(bar, text="Проверить обновления",
                                    command=lambda: self._check_updates(manual=True))
        self.check_btn.pack(side="right")

    def _browse(self, name: str, extensions: list[tuple[str, str]]):
        path = filedialog.askopenfilename(
            parent=self.root, title="Выберите исходный файл",
            filetypes=extensions + [("Все файлы", "*.*")])
        if path:
            if name == "mdb" and self.fields[name].get().strip() != path:
                self.fields["xml"].set("")
            self.fields[name].set(path)

    def _choose_candidate(self, title: str, choices, describe=str):
        """Explicit selection for multiple plausible sources; no arbitrary first."""
        if not choices:
            return None
        dialog = tk.Toplevel(self.root)
        dialog.title(title)
        dialog.transient(self.root)
        dialog.geometry("780x310")
        dialog.minsize(550, 230)
        frame = ttk.Frame(dialog, padding=12)
        frame.pack(fill="both", expand=True)
        ttk.Label(frame, text=title).pack(anchor="w")
        listing = tk.Listbox(frame, exportselection=False, height=9)
        listing.pack(fill="both", expand=True, pady=8)
        for candidate in choices:
            listing.insert("end", str(describe(candidate)))
        selected = [None]
        def accept():
            selection = listing.curselection()
            if selection:
                selected[0] = choices[selection[0]]
            dialog.destroy()
        listing.bind("<Double-Button-1>", lambda event: accept())
        row = ttk.Frame(frame)
        row.pack(fill="x")
        ttk.Button(row, text="Отмена", command=dialog.destroy).pack(side="right")
        ttk.Button(row, text="Выбрать", command=accept).pack(side="right", padx=8)
        dialog.grab_set()
        self.root.wait_window(dialog)
        return selected[0]

    def _auto_discover(self):
        self._discover_paths(interactive=False)

    def _browse_installation(self):
        folder = filedialog.askdirectory(parent=self.root,
                                          title="Папка оригинальной Аттестации-5.1")
        if folder:
            self._discover_paths(explicit_root=Path(folder), interactive=True)

    def _discover_paths(self, *, explicit_root=None, interactive=False):
        try:
            installs = discover_installations(
                (explicit_root,) if explicit_root is not None else None)
            if not installs:
                self.status.set(
                    "Исходная программа не найдена по штатному пути. "
                    "Укажите её папку или выберите файлы вручную.")
                return
            if len(installs) > 1:
                if not interactive:
                    self.status.set(
                        "Найдено несколько установок Аттестации. "
                        "Нажмите «Найти по настройкам» и выберите одну.")
                    return
                installation = self._choose_candidate(
                    "Выберите оригинальную установку", installs,
                    lambda x: x.folder)
                if installation is None:
                    return
            else:
                installation = installs[0]
            ambiguous = []
            for name, choices in (
                ("mdb", installation.databases),
                ("resources", installation.resources),
                ("ini", installation.settings),
            ):
                # Manual choices are never silently overwritten.
                if self.fields[name].get().strip():
                    continue
                if len(choices) == 1:
                    self.fields[name].set(str(choices[0]))
                elif len(choices) > 1:
                    if interactive:
                        selected = self._choose_candidate(
                            "Выберите исходный файл", choices)
                        if selected is not None:
                            self.fields[name].set(str(selected))
                    else:
                        ambiguous.append(name)
            problem = "; ".join(installation.warnings)
            if ambiguous:
                problem += "; неоднозначный источник: " + ", ".join(ambiguous)
            self.status.set(
                "Проверены настройки оригинальной программы. " +
                (problem or "Доступные исходные пути заполнены.") +
                " Все XML читаются по данным базы, без ручного выбора.")
        except Exception as error:
            self.status.set("Не удалось прочитать настройки источников: " +
                            human_error(error))

    def _find_protocols(self):
        try:
            database = self._required("mdb")["mdb"]
            rm = self.fields["rm"].get().strip()
            rm_id = int(rm) if rm else None
            if rm_id is not None and rm_id <= 0:
                raise ValueError("Номер рабочего места должен быть положительным.")
        except Exception as error:
            messagebox.showerror(APP_NAME, human_error(error))
            return
        self._work(lambda: discover_protocols(database, rm_id),
                   title="Чтение записей протоколов", kind="protocols")

    def _required(self, *names: str) -> dict[str, Path]:
        found = {}
        for name in names:
            raw = self.fields[name].get().strip()
            if not raw:
                raise ValueError(f"Не выбран файл: {name}.")
            p = Path(raw)
            if not p.is_file():
                raise FileNotFoundError(f"Не найден исходный файл: {raw}")
            found[name] = p
        return found

    def _work(self, task, *, title="Чтение данных", kind="report"):
        if self.busy:
            return
        self.busy = True
        for b in self.buttons:
            b.state(["disabled"])
        self.status.set(f"{title}…")

        def worker():
            try:
                self.results.put((kind, task()))
            except Exception as error:
                self.results.put(("error", human_error(error)))
        threading.Thread(target=worker, daemon=True).start()

    def _inspect_mdb(self):
        try:
            sources = self._required("mdb", "resources")
            rm = self.fields["rm"].get().strip()
            ids = [int(rm)] if rm else None
            if ids and ids[0] <= 0:
                raise ValueError("Номер рабочего места должен быть положительным.")
        except Exception as error:
            messagebox.showerror(APP_NAME, human_error(error))
            return
        self._work(lambda: AppSources(
            sources["mdb"], sources["resources"]).inspect(ids),
            title="Проверка рабочих мест")

    def _inspect_resources(self):
        try:
            source = self._required("resources")
            xml_raw = self.fields["xml"].get().strip()
            xml = self._required("xml")["xml"] if xml_raw else None
        except Exception as error:
            messagebox.showerror(APP_NAME, human_error(error))
            return
        def task():
            catalog = ResourceCatalog.from_mdb(source["resources"])
            result = {"not_exportable": True, "catalog": asdict(catalog.diagnostics)}
            info = catalog.diagnostics
            if (info.device_count == 0 and info.person_count == 0 and
                    "FGIS_RA" in info.tables_absent):
                result["source_warning"] = (
                    "Справочник не содержит приборов и сотрудников, а таблица "
                    "FGIS_RA отсутствует. Возможно, выбран исходный шаблон "
                    "res_orgs.mdb вместо рабочей базы организации. Проверьте "
                    "настройку [DB_res] в options.ini оригинальной программы. "
                    "Рабочие данные не изменялись."
                )
            if xml:
                result["protocol"] = inspection_dict(
                    inspect_protocol_resources_file(xml, catalog))
            return result
        self._work(task, title="Проверка справочников")

    def _diagnostic_options(self) -> Original2025Options:
        if self.acoustic_only.get() and not self.acoustic.get():
            raise ValueError("Флаг «Только акустические» требует «Акустические измерения».")
        if self.per_operation.get() and not self.acoustic.get():
            raise ValueError("Флаг «По операциям» требует «Акустические измерения».")
        return Original2025Options(
            acoustic_measurements=self.acoustic.get(),
            both_measurements_and_equivalent=self.acoustic_only.get(),
            acoustic_level_per_operation=self.per_operation.get(),
            include_uncertainty=self.uncertainty.get(),
            micro_use_result_values=self.micro_results.get(),
            micro_include_exposure_dose=self.micro_dose.get())

    def _optional_fgis_ini(self) -> Path | None:
        raw = self.fields["ini"].get().strip()
        return self._required("ini")["ini"] if raw else None

    def _inspect_all_2025(self):
        try:
            sources = self._required("mdb", "resources")
            ini_path = self._optional_fgis_ini()
            options = self._diagnostic_options()
            value = self.fields["rm"].get().strip()
            rm_id = int(value) if value else None
            if rm_id is not None and rm_id <= 0:
                raise ValueError("Номер рабочего места должен быть положительным.")
        except Exception as error:
            messagebox.showerror(APP_NAME, human_error(error))
            return
        self._work(lambda: inspect_all_2025(
            sources["mdb"], sources["resources"], options,
            rm_id=rm_id, working_fgis_ini=ini_path),
            title="Пакетное сопоставление внутренних XML")

    def _inspect_2025(self):
        try:
            files = self._required("xml", "resources")
            ini_path = self._optional_fgis_ini()
            options = self._diagnostic_options()
        except Exception as error:
            messagebox.showerror(APP_NAME, human_error(error))
            return
        self._work(lambda: diagnostic_dict(analyze_2025_file(
            files["xml"], files["resources"], options,
            working_fgis_ini=ini_path)), title="Сопоставление одного протокола")

    def _validate_xml(self):
        """Only internal ATT51 XML is selected here; FGIS XSD does not apply."""
        try:
            path = self._required("xml")["xml"]
        except Exception as error:
            messagebox.showerror(APP_NAME, human_error(error))
            return
        self._work(
            lambda: inspect_internal_xml(path),
            title="Проверка структуры внутреннего XML",
        )

    def _copy(self):
        content = self.report.get("1.0", "end-1c")
        self.root.clipboard_clear()
        self.root.clipboard_append(content)
        self.status.set("Отчёт скопирован в буфер обмена (файл не создавался).")

    def _show_report(self, value: object):
        content = json.dumps(value, ensure_ascii=False, indent=2, default=str)
        self.report.config(state="normal")
        self.report.delete("1.0", "end")
        self.report.insert("1.0", content)
        self.report.config(state="disabled")
        self.status.set("Диагностика завершена. Рабочий XML не формировался.")

    def _check_updates(self, *, manual: bool):
        if self.check_btn.instate(["disabled"]):
            return
        self.check_btn.state(["disabled"])
        self.update_status.set("Проверка выпуска на GitHub…")
        def worker():
            try:
                self.results.put(("update", fetch_latest()))
            except Exception as exc:
                self.results.put(("update_error", str(exc)))
        threading.Thread(target=worker, daemon=True).start()

    def _install_update(self):
        release = self.latest
        if release is None or not newer(release, VERSION):
            messagebox.showinfo(APP_NAME, "Новая версия не обнаружена.")
            return
        if not release.verified:
            messagebox.showwarning(APP_NAME,
                "GitHub не предоставил контрольную сумму. Откройте страницу релиза.")
            return
        if not getattr(sys, "frozen", False) or sys.platform != "win32":
            messagebox.showwarning(APP_NAME,
                "Установка обновлений доступна только в установленной Windows-версии.")
            return
        if not messagebox.askyesno(
            APP_NAME,
            f"Скачать и установить {release.tag}?\n"
            "Windows запросит права администратора. Открытые данные не изменяются.",
        ):
            return
        import ctypes
        args = f'--apply-update {release.tag} {release.sha256} {release.size}'
        try:
            code = ctypes.windll.shell32.ShellExecuteW(
                None, "runas", str(Path(sys.executable).resolve()), args,
                str(Path(sys.executable).resolve().parent), 1)
            if code <= 32:
                raise OSError("Операция отменена или Windows отказала в запуске.")
        except Exception as error:
            messagebox.showerror(APP_NAME, human_error(error))
            return
        self.root.destroy()

    def _pump(self):
        try:
            while True:
                kind, value = self.results.get_nowait()
                if kind in ("report", "error", "protocols"):
                    self.busy = False
                    for b in self.buttons:
                        b.state(["!disabled"])
                    if kind == "report":
                        self._show_report(value)
                    elif kind == "protocols":
                        protocols = value
                        if not protocols:
                            self.status.set(
                                "Для выбранной MDB/РМ не найдены связанные XML. "
                                "Проверьте путь, сохранение протокола или выберите вручную.")
                        else:
                            chosen = protocols[0] if len(protocols) == 1 else (
                                self._choose_candidate(
                                    "Выберите протокол", protocols,
                                    lambda p: p.label))
                            if chosen is not None:
                                self.fields["xml"].set(str(chosen.xml))
                                self.status.set(
                                    "Внутренний XML определён по sout_factors.file; "
                                    "файл не изменялся.")
                    else:
                        self.status.set(str(value))
                        messagebox.showerror(APP_NAME, str(value))
                elif kind == "update":
                    info = value
                    self.latest = info
                    self.check_btn.state(["!disabled"])
                    if newer(info, VERSION):
                        self.update_status.set(
                            f"Доступна {info.tag}" +
                            ("" if info.verified else " (только ручная установка)")
                        )
                        if info.verified:
                            self.install_btn.state(["!disabled"])
                    else:
                        self.update_status.set(f"Установлена актуальная версия {VERSION}.")
                elif kind == "update_error":
                    self.check_btn.state(["!disabled"])
                    self.update_status.set("Проверка обновлений недоступна: " + str(value))
        except queue.Empty:
            pass
        self.root.after(100, self._pump)


def main() -> int:
    if len(sys.argv) == 2 and sys.argv[1] == "--self-test":
        # Executed from CI after full installation and update. No UI, writes
        # or network required; failure is signaled only by an exit code.
        if not included_file("assets/app.ico").is_file():
            return 10
        if not included_file("assets/fileProtocolLoad_v4.xsd").is_file():
            return 11
        if len(VERSION.split(".")) != 3:
            return 12
        # Exercise COM imports inside the frozen executable; the previous
        # self-test never loaded the missing win32timezone dependency.
        if sys.platform == "win32":
            try:
                import win32timezone  # noqa: F401
                import pythoncom  # noqa: F401
                import win32com.client
                connection = win32com.client.Dispatch("ADODB.Connection")
                if connection is None:
                    return 13
            except Exception:
                return 13
        return 0
    if len(sys.argv) == 3 and sys.argv[1] == "--self-test-mdb":
        # ADO integration test runs on the original reference MDB with only
        # read-only SELECT; no mutable Access, schema, or Word calls.
        try:
            from att51_fsa.sources import AccessReader
            with AccessReader(Path(sys.argv[2])) as source:
                source.select("SELECT TOP 1 id FROM struct_rm")
            return 0
        except Exception:
            return 14
    if len(sys.argv) == 5 and sys.argv[1] == "--apply-update":
        try:
            apply_update(sys.argv[2], sys.argv[3], sys.argv[4])
            return 0
        except Exception as error:
            root = tk.Tk()
            root.withdraw()
            messagebox.showerror(APP_NAME, human_error(error))
            root.destroy()
            return 2
    if len(sys.argv) > 1:
        return 2
    root = tk.Tk()
    DesktopApp(root)
    root.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
