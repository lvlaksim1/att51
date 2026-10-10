"""Att51_export Windows graphical shell; does not run Word or original ATT51.

XML and raw Excel exports are independent; diagnostic readers remain internal.
No persistent configuration, cache, logs or user exports outside {app}.
"""
from __future__ import annotations

import os
from pathlib import Path
import queue
import sys
import threading
import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext, ttk

if not getattr(sys, "frozen", False):
    sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "fsa_xml_module"))

from updater import Release, UpdateError, apply_update, fetch_latest, newer
from install_guard import InstallationMutex
from source_discovery import discover_installations
from source_settings import SourceSettings, SOURCE_KEYS
from whole_base_reports import create_index, create_details
from fgis_export import create_fgis_export
from excel_export import create_excel_export
from export_batch import prepare_batch
from com_workers import run_with_com
from organization_sources import unique_organization
from att51_fsa.export_2025 import CustomerSettings
from att51_fsa.labour_2025 import LabourOptions
from att51_fsa.aerosol_2025 import ChemicalOptions
from att51_fsa.sources import FsaSourceError
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
                       ("mdb", "resources", "ini")}
        self.source_settings = SourceSettings()
        self._save_after_id = None
        self._settings_load_warning = ""
        try:
            previous_paths = self.source_settings.load()
        except ValueError as exc:
            previous_paths = {}
            self._settings_load_warning = str(exc)
        for key, path in previous_paths.items():
            if key in self.fields:
                self.fields[key].set(path)
        self.status = tk.StringVar(value="Готово. Выберите XML или Excel для самостоятельной выгрузки.")
        self.update_status = tk.StringVar(value="Обновления: проверка не выполнена")
        root.title(f"{APP_NAME} — v{VERSION}")
        root.geometry("1050x700")
        root.minsize(780, 510)
        icon = included_file("assets/app.ico")
        if icon.exists():
            try:
                root.iconbitmap(str(icon))
            except tk.TclError:
                pass
        self._build_ui()
        for key in self.fields:
            self.fields[key].trace_add("write", self._paths_changed)
        root.protocol("WM_DELETE_WINDOW", self._close)
        if self._settings_load_warning:
            self.status.set(self._settings_load_warning)
        root.after(100, self._pump)
        root.after(350, self._auto_ini)
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

        pane = ttk.LabelFrame(
            self.root, text="Источники данных (только чтение)", padding=12)
        pane.grid(row=1, column=0, padx=14, pady=(0, 8), sticky="ew")
        pane.columnconfigure(1, weight=1)
        labels = (
            ("mdb", "База организации / рабочих мест (.mdb)", [("Access MDB", "*.mdb")]),
            ("resources", "База ресурсов res_orgs.mdb", [("Access MDB", "*.mdb")]),
            ("ini", "fgis_ra.ini (необязательно)", [("INI", "*.ini")]),
        )
        for row, (key, label, extensions) in enumerate(labels):
            ttk.Label(pane, text=label, width=38).grid(
                row=row, column=0, sticky="w", pady=3)
            ttk.Entry(pane, textvariable=self.fields[key]).grid(
                row=row, column=1, sticky="ew", padx=8, pady=3)
            ttk.Button(pane, text="Обзор…", width=11,
                       command=lambda k=key, ext=extensions: self._browse(k, ext)
                       ).grid(row=row, column=2, pady=3)
        ttk.Button(pane, text="Авто", width=9,
                   command=lambda: self._auto_ini(interactive=True)
                   ).grid(row=2, column=3, padx=(8, 0))
        ttk.Label(pane, text="Excel не требует ID ФГИС; настройки ФГИС используются для XML. "
                             "Выбранные пути сохраняются.",
                  foreground="#456280").grid(
                      row=3, column=0, columnspan=4, sticky="w", pady=(5, 0))

        report = ttk.LabelFrame(
            self.root, text="Выгрузка сведений", padding=(10, 8))
        report.grid(row=2, column=0, padx=14, sticky="nsew")
        report.columnconfigure(0, weight=1)
        report.rowconfigure(1, weight=1)
        actions = ttk.Frame(report)
        actions.grid(row=0, column=0, sticky="ew")
        self.buttons = []
        for label, command in (
            ("Выгрузить XML", self._create_fgis_xml),
            ("Выгрузить Excel", self._create_excel),
        ):
            b = ttk.Button(actions, text=label, command=command)
            b.pack(side="left", padx=(0, 10), pady=(0, 6))
            self.buttons.append(b)
        self.report = scrolledtext.ScrolledText(
            report, wrap="word", font=("Segoe UI", 10), undo=False)
        self.report.grid(row=1, column=0, sticky="nsew", pady=(8, 0))
        self.report.insert("1.0",
            "XML: подготовка данных с проверкой соответствий ФГИС и исходной XSD.\n"
            "Excel: те же показатели, что и в XML, но с исходными названиями без ID ФГИС.\n"
            "Каждый показатель занимает отдельную строку, а общие сведения — только первую.\n"
            "Результаты: %ProgramData%\\Att51_export\\reports\\.\n"
            "Кнопки работают независимо, предварительные отчёты не нужны.")
        self.report.config(state="disabled")

        bottom = ttk.Frame(self.root, padding=(15, 10, 15, 14))
        bottom.grid(row=3, column=0, sticky="ew")
        ttk.Label(bottom, textvariable=self.status, foreground="#6d4a10").pack(anchor="w")
        bar = ttk.Frame(bottom)
        bar.pack(fill="x", pady=(8, 0))
        ttk.Label(bar, textvariable=self.update_status).pack(side="left")
        self.install_btn = ttk.Button(bar, text="Обновить",
                                      command=self._install_update)
        self.install_btn.pack(side="right", padx=(6, 0))
        self.install_btn.state(["disabled"])
        self.check_btn = ttk.Button(bar, text="Проверить обновления",
                                    command=lambda: self._check_updates(manual=True))
        self.check_btn.pack(side="right")

    def _paths_changed(self, *_args):
        if self._save_after_id is not None:
            self.root.after_cancel(self._save_after_id)
        self._save_after_id = self.root.after(600, self._save_sources)

    def _save_sources(self) -> bool:
        if self._save_after_id is not None:
            self.root.after_cancel(self._save_after_id)
            self._save_after_id = None
        try:
            self.source_settings.save({
                key: self.fields[key].get().strip() for key in self.fields
            })
        except (OSError, ValueError) as exc:
            self.status.set("Не удалось сохранить пути внутри папки приложения: "
                            + human_error(exc))
            return False
        return True

    def _close(self):
        if not self._save_sources() and not messagebox.askyesno(
            APP_NAME, "Пути не удалось сохранить. Закрыть без сохранения?"
        ):
            return
        self.root.destroy()

    def _browse(self, name: str, extensions: list[tuple[str, str]]):
        path = filedialog.askopenfilename(
            parent=self.root, title="Выберите исходный файл",
            filetypes=extensions + [("Все файлы", "*.*")])
        if path:
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

    def _auto_ini(self, *, interactive=False):
        # Only search original fgis_ra.ini. Never replace user MDB paths.
        if self.fields["ini"].get().strip() and not interactive:
            return
        try:
            choices = tuple(dict.fromkeys(
                p for install in discover_installations() for p in install.settings
                if p.is_file()
            ))
            if not choices:
                self.status.set("fgis_ra.ini не обнаружен. Файл необязателен.")
                if interactive:
                    messagebox.showinfo(APP_NAME, "fgis_ra.ini не найден. "
                                        "Поля базы и отчёты работают без него.")
                return
            if len(choices) > 1:
                if not interactive:
                    self.status.set("Найдено несколько fgis_ra.ini. "
                                    "Нажмите «Авто» для выбора.")
                    return
                selected = self._choose_candidate("Выберите fgis_ra.ini", choices)
                if selected is None:
                    return
            else:
                selected = choices[0]
            self.fields["ini"].set(str(selected))
            self.status.set("Найден необязательный fgis_ra.ini: " + str(selected))
        except (OSError, ValueError) as exc:
            self.status.set("Не удалось определить fgis_ra.ini: " + human_error(exc))

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
                self.results.put((kind, run_with_com(task)))
            except Exception as error:
                self.results.put(("error", human_error(error)))
        threading.Thread(target=worker, daemon=True).start()

    def _report_inputs(self):
        source = self._required("mdb", "resources")
        ini = self.fields["ini"].get().strip()
        if ini:
            source.update(self._required("ini"))
        return source, source.get("ini")

    def _create_index(self):
        try:
            files, ini = self._report_inputs()
        except (ValueError, OSError) as error:
            messagebox.showerror(APP_NAME, human_error(error))
            return
        self._work(lambda: create_index(files["mdb"], files["resources"], ini),
                   title="Формирование перечня всех рабочих мест",
                   kind="report_file")

    def _create_details(self):
        try:
            files, ini = self._report_inputs()
        except (ValueError, OSError) as error:
            messagebox.showerror(APP_NAME, human_error(error))
            return
        self._work(lambda: create_details(files["mdb"], files["resources"], ini),
                   title="Формирование подробного отчёта по всем протоколам",
                   kind="report_file")

    def _create_excel(self):
        # Same input selection, customer information and factor options as XML.
        # The format changes only AFTER the common XML measurement selector.
        self._create_fgis_xml(target="excel")

    def _open_excel_result(self, result):
        self.status.set(
            "Excel создан: " + str(result.protocol_count) +
            " протоколов, " + str(result.indicator_count) + " показателей")
        self.report.config(state="normal")
        self.report.delete("1.0", "end")
        self.report.insert(
            "1.0", "Excel XLS создан:\n" + str(result.file) +
            "\nПротоколов: " + str(result.protocol_count) +
            "\nСтрок с показателями: " + str(result.indicator_count) +
            "\nТолько исходные сведения, без ID ФГИС.")
        self.report.config(state="disabled")
        try:
            if sys.platform == "win32":
                os.startfile(str(result.file))
        except OSError as error:
            messagebox.showwarning(APP_NAME, "Excel создан, но не удалось открыть:\n"
                                   + str(error))

    def _create_fgis_xml(self, *, target="xml"):
        try:
            files, ini = self._report_inputs()
        except (ValueError, OSError) as error:
            messagebox.showerror(APP_NAME,human_error(error))
            return
        # The original uses STRUCT_ORG and 000_org_data/{mguid}/adv_data.xml.
        # Auto-fill only when this MDB contains exactly one organization.
        try:
            source_org = unique_organization(files["mdb"])
            autodiscovery_error = ""
        except (ValueError, OSError, FsaSourceError) as exc:
            source_org = None
            autodiscovery_error = str(exc)
        originals = {
            "date": source_org.query_date if source_org else "",
            "inn": source_org.inn if source_org else "",
            "ogrn": source_org.ogrn if source_org else "",
            "fio": source_org.fio if source_org else "",
            "full_name": source_org.name if source_org else "",
        }
        popup=tk.Toplevel(self.root)
        popup.title("Данные заказчика и параметры выгрузки ФГИС")
        popup.transient(self.root)
        popup.grab_set()
        popup.resizable(False,False)
        controls=ttk.Frame(popup,padding=14)
        controls.pack(fill="both",expand=True)
        prompts=(
            ("Дата заявки, ДД.ММ.ГГГГ","date",""),
            ("Тип заказчика (1=ЮЛ, 2=ИП, 4=физлицо)","kind","1"),
            ("Наименование организации","full_name",""),
            ("ИНН заказчика","inn",""),
            ("ОГРН (если есть)","ogrn",""),
            ("ФИО заказчика-физлица (если есть)","fio",""),
        )
        values={}
        for row,(title,key,initial) in enumerate(prompts):
            ttk.Label(controls,text=title).grid(row=row,column=0,sticky="w",pady=4)
            var=tk.StringVar(value=originals.get(key, initial))
            ttk.Entry(controls,textvariable=var,width=35).grid(row=row,column=1,padx=8,pady=4)
            values[key]=var
        ttk.Label(controls,text="Состояние данных").grid(row=6,column=0,sticky="w",pady=4)
        status=tk.StringVar(value="20")
        ttk.Combobox(controls,textvariable=status,values=("20","13"),state="readonly",
                     width=33).grid(row=6,column=1,padx=8,pady=4)
        direct=tk.BooleanVar(value=False)
        totals=tk.BooleanVar(value=False)
        ttk.Checkbutton(controls,text="Тяжесть: прямые измерения (не итоговые)",
                        variable=direct).grid(row=7,column=0,columnspan=2,sticky="w",pady=3)
        ttk.Checkbutton(controls,text="Добавить итоговые суммы тяжести",
                        variable=totals).grid(row=8,column=0,columnspan=2,sticky="w",pady=3)
        chem_uncertainty=tk.BooleanVar(value=False)
        chem_detailed=tk.BooleanVar(value=False)
        chem_shift=tk.BooleanVar(value=False)
        chem_max=tk.BooleanVar(value=False)
        chem_omit_points=tk.BooleanVar(value=False)
        chem_rows=(
            ("АПФД: включить погрешность U0,95", chem_uncertainty),
            ("АПФД: использовать детальные результаты измерений", chem_detailed),
            ("АПФД: добавить среднесменные концентрации", chem_shift),
            ("АПФД: добавить максимальные концентрации", chem_max),
            ("АПФД: не добавлять отдельные измерения", chem_omit_points),
        )
        for index,(title,variable) in enumerate(chem_rows,9):
            ttk.Checkbutton(controls,text=title,variable=variable).grid(
                row=index,column=0,columnspan=2,sticky="w",pady=2)
        address_choice = tk.IntVar(value=1)
        ttk.Label(controls, text="Адрес проведения измерений (из STRUCT_ORG)").grid(
            row=14, column=0, columnspan=2, sticky="w", pady=(8, 2))
        address_candidates = (
            source_org.address1 if source_org else "",
            source_org.address2 if source_org else "",
        )
        for variant, original_address in enumerate(address_candidates, 1):
            ttk.Radiobutton(
                controls,
                text=f"Вариант {variant}: {original_address or 'НЕТ ДАННЫХ'}",
                variable=address_choice, value=variant,
            ).grid(row=14+variant, column=0, columnspan=2, sticky="w", pady=2)
        source_msg = ("Реквизиты найдены в исходных STRUCT_ORG и adv_data.xml. Проверьте их."
                      if source_org else
                      "Автозаполнение недоступно: нужна одна организация и исходные сведения.")
        if autodiscovery_error:
            source_msg += " Ошибка чтения: " + autodiscovery_error
        ttk.Label(controls,text=source_msg,foreground="#456280",wraplength=570
                  ).grid(row=17,column=0,columnspan=2,pady=3,sticky="w")
        ttk.Label(controls,text="При ошибках обязательных полей XML не создаётся.",
                  foreground="#72531d").grid(row=18,column=0,columnspan=2,pady=5,sticky="w")
        footer=ttk.Frame(controls)
        footer.grid(row=19,column=0,columnspan=2,sticky="e")
        ttk.Button(footer,text="Отмена",command=popup.destroy).pack(side="right",padx=4)
        def begin():
            try:
                kind=int(values["kind"].get())
                customer=CustomerSettings(
                    application_date=values["date"].get().strip(),
                    customer_kind=kind,inn=values["inn"].get().strip(),
                    ogrn=values["ogrn"].get().strip(),fio=values["fio"].get().strip(),
                    full_name=values["full_name"].get().strip(),
                    data_status=status.get(),
                    address_variant=address_choice.get(),
                    address=address_candidates[address_choice.get()-1],
                    contacts=source_org.contacts if source_org else "")
            except ValueError as exc:
                messagebox.showerror(APP_NAME,"Тип заказчика должен быть числом: "+str(exc))
                return
            validation = customer.validate()
            if validation:
                messagebox.showerror(APP_NAME, "Исправьте исходные данные:\n"
                                     + "\n".join(validation), parent=popup)
                return
            labour=LabourOptions(heavy_direct=direct.get(),include_heavy_totals=totals.get())
            chemical=ChemicalOptions(
                include_uncertainty=chem_uncertainty.get(),
                use_detailed_results=chem_detailed.get(),
                include_shift_average=chem_shift.get(),
                include_maximum=chem_max.get(),
                omit_point_measurements=chem_omit_points.get(),
            )
            popup.destroy()
            if target == "excel":
                self._work(lambda: create_excel_export(
                    prepare_batch(files["mdb"], files["resources"], ini, customer,
                                  labour=labour, chemical=chemical)),
                    title="Подготовка исходных сведений Excel",
                    kind="excel_result")
            else:
                self._work(lambda: create_fgis_export(
                    files["mdb"], files["resources"], ini, customer,
                    included_file("assets/fileProtocolLoad_v4.xsd"),
                    labour=labour, chemical=chemical),
                    title="Проверка и формирование итогового XML",
                    kind="fgis_result")
        ttk.Button(footer,text="Проверить и сформировать",command=begin).pack(side="right")
        popup.focus_set()

    def _open_fgis_result(self, result):
        self.status.set("XML сформирован: "+str(len(result.files))+" файлов"
                        if result.ready else "XML не создан: обнаружены блокирующие ошибки")
        self.report.config(state="normal")
        self.report.delete("1.0","end")
        self.report.insert("1.0",result.report.read_text(encoding="utf-8-sig")[:20000])
        self.report.config(state="disabled")
        try:
            if sys.platform=="win32":
                os.startfile(str(result.report))
        except OSError:
            pass

    def _open_report(self, filename: Path):
        self.report.config(state="normal")
        self.report.delete("1.0", "end")
        self.report.insert("1.0", "Отчёт готов:\n" + str(filename) +
                           "\n\nСоздан текстовый файл UTF-8. "
                           "Файл содержит исходные значения, в том числе "
                           "не имеющие сопоставленного ID ФГИС.\n"
                           "Отчёт не является итоговым XML ФГИС.")
        self.report.config(state="disabled")
        self.status.set("Текстовый отчёт создан: " + str(filename))
        try:
            if sys.platform == "win32":
                os.startfile(str(filename))
        except OSError as exc:
            messagebox.showwarning(
                APP_NAME, "Отчёт сохранён, но не удалось открыть текстовый файл:\n"
                + str(filename) + "\n" + human_error(exc))

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
        if not self._save_sources():
            messagebox.showerror(APP_NAME, "Не удалось сохранить пути перед обновлением.")
            return
        from updater import start_update_overlay
        # Show progress IMMEDIATELY; wait until the persistent helper appears
        # before shutting down the original Att51_export.exe.
        starting = tk.Toplevel(self.root)
        starting.title("Обновление Att51_export")
        starting.geometry("490x156")
        starting.resizable(False, False)
        starting.transient(self.root)
        ttk.Label(starting, text="Подготовка обновления…",
                  padding=(15, 14)).pack(anchor="w")
        progress = ttk.Progressbar(starting, mode="indeterminate", length=445)
        progress.pack(padx=15, pady=(10, 0), fill="x")
        progress.start(12)
        starting.update_idletasks()
        try:
            process, ready = start_update_overlay(
                release, Path(sys.executable).resolve().parent,
                included_file("assets/update_overlay.ps1"), os.getpid())
        except Exception as exc:
            starting.destroy()
            messagebox.showerror(APP_NAME, human_error(exc))
            return
        def wait_visible():
            if ready.is_file():
                progress.stop()
                self.root.destroy()
            elif process.poll() is not None:
                progress.stop()
                starting.destroy()
                messagebox.showerror(
                    APP_NAME, "Окно обновления не запустилось. "
                    "Проверьте доступность Windows PowerShell.")
            else:
                self.root.after(100, wait_visible)
        wait_visible()

    def _pump(self):
        try:
            while True:
                kind, value = self.results.get_nowait()
                if kind in ("report_file", "fgis_result", "excel_result", "error"):
                    self.busy = False
                    for b in self.buttons:
                        b.state(["!disabled"])
                    if kind == "report_file":
                        self._open_report(Path(value))
                    elif kind == "fgis_result":
                        self._open_fgis_result(value)
                    elif kind == "excel_result":
                        self._open_excel_result(value)
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
    if len(sys.argv) == 4 and sys.argv[1] == "--self-test-reports":
        try:
            index = create_index(Path(sys.argv[2]), Path(sys.argv[3]))
            details = create_details(Path(sys.argv[2]), Path(sys.argv[3]))
            if not index.is_file() or not details.is_file():
                return 16
            if "Протоколов" not in index.read_text(encoding="utf-8-sig"):
                return 16
            if "ПРОТОКОЛ" not in details.read_text(encoding="utf-8-sig"):
                return 16
            return 0
        except Exception:
            return 16
    if len(sys.argv) == 2 and sys.argv[1] == "--self-test-settings":
        try:
            store = SourceSettings()
            store.save({"mdb": "Z:/Att51-test/example.MDB"})
            return 0 if store.load().get("mdb") == "Z:/Att51-test/example.MDB" else 15
        except (OSError, ValueError):
            return 15
    if len(sys.argv) == 2 and sys.argv[1] == "--self-test":
        # Executed from CI after full installation and update. No UI, writes
        # or network required; failure is signaled only by an exit code.
        if not included_file("assets/app.ico").is_file():
            return 10
        if not included_file("assets/fileProtocolLoad_v4.xsd").is_file():
            return 11
        if not included_file("assets/update_overlay.ps1").is_file():
            return 19
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
    if len(sys.argv) == 3 and sys.argv[1] == "--self-test-mdb-thread":
        # Regression: the same background COM worker as the XML GUI button.
        # A successful CLI read on the main thread does not cover this case.
        from concurrent.futures import ThreadPoolExecutor
        from att51_fsa.sources import AccessReader
        def read_from_worker():
            with AccessReader(Path(sys.argv[2])) as source:
                return source.select("SELECT TOP 1 id FROM struct_rm")
        try:
            with ThreadPoolExecutor(max_workers=1) as executor:
                executor.submit(run_with_com, read_from_worker).result(timeout=30)
            return 0
        except Exception:
            return 18
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
    if len(sys.argv) in (5, 6) and sys.argv[1] == "--apply-update":
        # The main application has already closed. Display download progress
        # in a small noninteractive updater window, then switch to the
        # progress-only Inno Setup window. Never ask additional questions.
        root = tk.Tk()
        root.title("Обновление Att51_export")
        root.geometry("440x120")
        root.resizable(False, False)
        title = ttk.Label(root, text="Подготовка обновления…", padding=(16, 14))
        title.pack(fill="x")
        bar = ttk.Progressbar(root, maximum=100, mode="indeterminate",
                              length=400)
        bar.pack(padx=16, fill="x")
        try:
            root.update()
            def show_progress(received, total):
                bar.configure(mode="determinate", value=100 * received / total)
                title.configure(text=f"Загрузка проверенного обновления: "
                                     f"{round(100 * received / total)} %")
                root.update()
            apply_update(sys.argv[2], sys.argv[3], sys.argv[4],
                         sys.argv[5] if len(sys.argv) == 6 else "0",
                         progress=show_progress)
            return 0
        except Exception as error:
            messagebox.showerror(APP_NAME, human_error(error), parent=root)
            return 2
        finally:
            root.destroy()
    if len(sys.argv) == 3 and sys.argv[1] == "--self-test-hold-legacy-process":
        # Emulate releases <=0.1.10, which never created an AppMutex.
        import time
        time.sleep(min(max(int(sys.argv[2]), 1), 60))
        return 0
    if len(sys.argv) == 3 and sys.argv[1] == "--self-test-hold-mutex":
        # Dedicated Windows release test: test that both installers refuse
        # to overwrite the currently running EXE. Never open user data.
        import time
        with InstallationMutex():
            time.sleep(min(max(int(sys.argv[2]), 1), 60))
        return 0
    updated = len(sys.argv) == 2 and sys.argv[1] == "--update-started"
    if len(sys.argv) > 1 and not updated:
        return 2
    with InstallationMutex():
        root = tk.Tk()
        DesktopApp(root)
        if updated:
            def signal_ready():
                marker = Path(sys.executable).resolve().parent / "updates" / "newapp.ready"
                marker.parent.mkdir(parents=True, exist_ok=True)
                marker.write_text("READY", encoding="ascii")
            root.after(300, signal_ready)
        root.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
