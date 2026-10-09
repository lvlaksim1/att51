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
        root.geometry("980x735")
        root.minsize(810, 570)
        icon = included_file("assets/app.ico")
        if icon.exists():
            try:
                root.iconbitmap(str(icon))
            except tk.TclError:
                pass
        self._build_ui()
        root.after(100, self._pump)
        root.after(1200, lambda: self._check_updates(manual=False))

    def _build_ui(self):
        style = ttk.Style(self.root)
        if "vista" in style.theme_names():
            style.theme_use("vista")
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(2, weight=1)

        heading = ttk.Frame(self.root, padding=(15, 12, 15, 8))
        heading.grid(row=0, column=0, sticky="ew")
        ttk.Label(heading, text=f"Att51_export  ·  v{VERSION}",
                  font=("Segoe UI", 17, "bold")).pack(anchor="w")
        ttk.Label(
            heading,
            text="Независимое чтение данных «Аттестация-5.1» для ФГИС ФСА · испытательная версия",
            foreground="#456280",
        ).pack(anchor="w", pady=(3, 0))

        pane = ttk.LabelFrame(self.root, text="Исходные файлы (доступ только для чтения)", padding=12)
        pane.grid(row=1, column=0, padx=14, pady=(0, 8), sticky="ew")
        pane.columnconfigure(1, weight=1)
        labels = [
            ("mdb", "База рабочих мест (.mdb)", [("Access MDB", "*.mdb")]),
            ("resources", "Справочник res_orgs.mdb", [("Access MDB", "*.mdb")]),
            ("xml", "Внутренний XML протокола", [("XML", "*.xml")]),
            ("ini", "Параметры fgis_ra.ini", [("INI", "*.ini")]),
        ]
        for row, (name, label, extensions) in enumerate(labels):
            ttk.Label(pane, text=label, width=29).grid(row=row, column=0, sticky="w", pady=3)
            ttk.Entry(pane, textvariable=self.fields[name]).grid(
                row=row, column=1, sticky="ew", padx=8, pady=3)
            ttk.Button(
                pane, text="Обзор…", width=11,
                command=lambda n=name, ext=extensions: self._browse(n, ext),
            ).grid(row=row, column=2, pady=3)
        opts = ttk.Frame(pane)
        opts.grid(row=4, column=0, columnspan=3, sticky="ew", pady=(8, 2))
        ttk.Label(opts, text="Номер рабочего места:").pack(side="left")
        ttk.Entry(opts, textvariable=self.fields["rm"], width=12).pack(side="left", padx=(6, 16))
        for text, var in (
            ("Акустические измерения", self.acoustic),
            ("Только акустические", self.acoustic_only),
            ("По операциям", self.per_operation),
            ("Неопределённость", self.uncertainty),
        ):
            ttk.Checkbutton(opts, text=text, variable=var).pack(side="left", padx=4)
        micro = ttk.Frame(pane)
        micro.grid(row=5, column=0, columnspan=3, sticky="w", pady=(3, 0))
        ttk.Checkbutton(micro, text="Итоговые значения микроклимата",
                        variable=self.micro_results).pack(side="left")
        ttk.Checkbutton(micro, text="Экспозиционная доза",
                        variable=self.micro_dose).pack(side="left", padx=(20, 0))

        report = ttk.LabelFrame(self.root, text="Проверка и результаты", padding=(10, 8))
        report.grid(row=2, column=0, padx=14, sticky="nsew")
        report.rowconfigure(1, weight=1)
        report.columnconfigure(0, weight=1)
        tools = ttk.Frame(report)
        tools.grid(row=0, column=0, sticky="ew")
        self.buttons = []
        for label, command in (
            ("Проверить базу РМ", self._inspect_mdb),
            ("Проверить справочники", self._inspect_resources),
            ("Сопоставить протокол", self._inspect_2025),
            ("Проверить XML по XSD", self._validate_xml),
        ):
            b = ttk.Button(tools, text=label, command=command)
            b.pack(side="left", padx=(0, 7))
            self.buttons.append(b)
        ttk.Button(tools, text="Копировать отчёт", command=self._copy).pack(side="right")
        self.report = scrolledtext.ScrolledText(
            report, wrap="none", font=("Consolas", 10), undo=False)
        self.report.grid(row=1, column=0, sticky="nsew", pady=(8, 0))
        self.report.insert("1.0",
            "Сведения об организации, измерениях и сотрудниках выводятся только здесь.\n"
            "Программа не записывает отчёты, журналы и настройки на диск.\n"
            "Формирование итогового XML для ФГИС ФСА пока недоступно.\n")
        self.report.config(state="disabled")

        bottom = ttk.Frame(self.root, padding=(15, 10, 15, 14))
        bottom.grid(row=3, column=0, sticky="ew")
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
            self.fields[name].set(path)

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

    def _work(self, task, *, title="Чтение данных"):
        if self.busy:
            return
        self.busy = True
        for b in self.buttons:
            b.state(["disabled"])
        self.status.set(f"{title}…")

        def worker():
            try:
                self.results.put(("report", task()))
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
            if xml:
                result["protocol"] = inspection_dict(
                    inspect_protocol_resources_file(xml, catalog))
            return result
        self._work(task, title="Проверка справочников")

    def _inspect_2025(self):
        try:
            files = self._required("xml", "resources")
            ini = self.fields["ini"].get().strip()
            ini_path = self._required("ini")["ini"] if ini else None
            if self.acoustic_only.get() and not self.acoustic.get():
                raise ValueError("Флаг «Только акустические» требует «Акустические измерения».")
            if self.per_operation.get() and not self.acoustic.get():
                raise ValueError("Флаг «По операциям» требует «Акустические измерения».")
            options = Original2025Options(
                acoustic_measurements=self.acoustic.get(),
                both_measurements_and_equivalent=self.acoustic_only.get(),
                acoustic_level_per_operation=self.per_operation.get(),
                include_uncertainty=self.uncertainty.get(),
                micro_use_result_values=self.micro_results.get(),
                micro_include_exposure_dose=self.micro_dose.get())
        except Exception as error:
            messagebox.showerror(APP_NAME, human_error(error))
            return
        self._work(lambda: diagnostic_dict(analyze_2025_file(
            files["xml"], files["resources"], options,
            working_fgis_ini=ini_path)), title="Сопоставление измерений")

    def _validate_xml(self):
        try:
            path = self._required("xml")["xml"]
            schema = included_file("assets/fileProtocolLoad_v4.xsd")
            if not schema.is_file():
                raise FileNotFoundError("Не найдена штатная XSD в составе приложения.")
        except Exception as error:
            messagebox.showerror(APP_NAME, human_error(error))
            return
        def task():
            ok, details = validate_xml(path.read_bytes(), schema)
            return {
                "xml": str(path), "conforms_to_xsd": ok, "details": details,
                "not_exportable": True,
                "warning": "Соответствие XSD не доказывает правильность данных для ФСА.",
            }
        self._work(task, title="Проверка исходной XML-схемы")

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
                if kind in ("report", "error"):
                    self.busy = False
                    for b in self.buttons:
                        b.state(["!disabled"])
                    if kind == "report":
                        self._show_report(value)
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
        return 0
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
