"""Regression: Excel renders shared original text without ever parsing source files."""
from __future__ import annotations

from datetime import date
from pathlib import Path
from types import SimpleNamespace
import sys
from tempfile import TemporaryDirectory
import types
import unittest
from unittest.mock import patch
from xml.etree import ElementTree as ET

DESKTOP = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(DESKTOP))
sys.path.insert(0, str(DESKTOP.parent / "fsa_xml_module"))

from excel_export import HEADERS, excel_date_text, excel_text_rows, create_excel_export
from excel_shared_source import prepared_protocol_rows, prepared_batch_rows
from export_batch import ProtocolBatch, prepare_batch
from com_workers import run_with_com
from att51_fsa.export_2025 import CustomerSettings, PreparedProtocol
from att51_fsa.measurements import ResearchObjectDraft
from att51_fsa.pipeline_2025 import FieldTrace
from att51_fsa.resources import ResourceCatalog
from att51_fsa.source_snapshot import snapshot_for_protocol, EMPTY
from att51_fsa.sources import FsaSourceError


def original():
    return ET.fromstring('''<Document num_doc="ABC-001" fill_date="2026-10-02">
      <factor facid="3" izm_date="2026-09-21">
        <si_guids><si_guid guid="G1" num="17"/></si_guids>
        <persons><pers guid="P1" /></persons>
      </factor>
      <nd_data><nd id="71" action="1" name="Методика 1"/>
        <nd id="72" action="1" name="Методика 2"/>
      </nd_data>
      <izm_data><zone>
        <param name="Пыль: разовая концентрация" unit="мг/м³" fact="2.4"
               nd_izm1="71"/>
        <param name="Пыль: среднесменная" unit="мг/м³" fact="0.5"
               nd_izm1="72"/>
      </zone></izm_data>
    </Document>''')


def catalog():
    return ResourceCatalog.from_rows(
        devices=[{"id": "3", "mguid": "G1", "factory_num": "17",
                  "name": "Аспиратор"}],
        people=[{"mguid": "P1", "snils": "", "fio": "Петров П. П."}],
        normative=[], links=[])


def assembled(doc=None, client=None):
    doc = doc if doc is not None else original()
    client = client or CustomerSettings(
        "11.09.2026", 2, inn="123456789012",
        full_name="ИП Исходный заказчик",
        address_variant=2, address="Адрес 2", contacts="8 800 123 45 67")
    drafts = [
        ResearchObjectDraft("66", "1", "2.4", "533",
                            "Document/izm_data/zone/param[1]"),
        ResearchObjectDraft("66", "1", "0.5", "533",
                            "Document/izm_data/zone/param[2]"),
    ]
    selected = [SimpleNamespace(
        fact_value=value, unique_indicator="", unique_method="",
        indicator_id="66", measurement_id="533")
        for value in ("2.4", "0.5")]
    traces = tuple(
        FieldTrace(draft.source_xpath, draft.indicator_id, "complete",
                   "first_pass_nd_id", "4519842", item, (), (),
                   source_draft=draft,
                   original_method_name=("Методика 1", "Методика 2")[i],
                   original_oa_method="Инструментальный {1138}")
        for i, (draft, item) in enumerate(zip(drafts, selected)))
    protocol = SimpleNamespace(
        doc_id="ABC-001", start_date="2026-09-21",
        validity_date="2026-09-21", creation_date="2026-10-02",
        application_date="2026-09-11",
        object_name="Аэрозоли преимущественно фиброгенного действия",
        research_objects=tuple(selected))
    audit = SimpleNamespace(
        equipment=(SimpleNamespace(local_guid="G1"),),
        people=(("izm", SimpleNamespace(local_guid="P1")),))
    source = snapshot_for_protocol(doc, protocol, traces, audit, catalog(), client)
    return PreparedProtocol(protocol, (), (), traces, source)


class SharedExportTests(unittest.TestCase):
    def setUp(self):
        self.client = CustomerSettings(
            "11.09.2026", 2, inn="123456789012",
            full_name="ИП Исходный заказчик",
            address_variant=2, address="Адрес 2", contacts="8 800 123 45 67")

    def test_excel_template_has_26_original_fields(self):
        self.assertEqual(len(HEADERS), 26)
        self.assertEqual(HEADERS[10:15], (
            "Наименование показателя", "Измеренное значение",
            "Единица измерения", "Наименование методики",
            "Наименование метода"))

    def test_exact_common_selected_count_and_order(self):
        prepared = assembled(client=self.client)
        rows = prepared_protocol_rows(prepared)
        self.assertEqual(len(rows), len(prepared.protocol.research_objects))
        self.assertEqual([row[11] for row in rows], ["2.4", "0.5"])
        self.assertEqual([row[10] for row in rows],
                         ["Пыль: разовая концентрация", "Пыль: среднесменная"])
        self.assertEqual(rows[0][12:15], ["мг/м³", "Методика 1", "Инструментальный"])
        self.assertEqual(rows[1][12:15], ["мг/м³", "Методика 2", "Инструментальный"])
        self.assertEqual(rows[0][0], "ABC-001")
        self.assertEqual(rows[0][4], "ИП Исходный заказчик")
        self.assertEqual(rows[0][6], "Адрес 2")
        self.assertEqual(rows[0][7], "123456789012")
        self.assertEqual(rows[0][9], "Аэрозоли преимущественно фиброгенного действия")
        self.assertEqual(rows[0][15], "8 800 123 45 67")
        self.assertEqual(rows[0][16], "2026-09-11")
        self.assertIn("Аспиратор", rows[0][22])
        self.assertEqual(rows[0][23], "Петров П. П.")
        self.assertEqual(rows[1][:10], [""] * 10)
        self.assertEqual(rows[1][15:], [""] * 11)
        self.assertNotIn("4519842", repr(rows))
        self.assertNotIn("1138", repr(rows))
        self.assertNotIn("533", repr(rows))

    def test_missing_original_unit_never_inferred_from_measurement_id(self):
        doc = original()
        for node in doc.findall("./izm_data/zone/param"):
            node.attrib.pop("unit")
        proposal = assembled(doc, self.client)
        self.assertEqual(prepared_protocol_rows(proposal)[0][12], EMPTY)

    def test_missing_text_not_guessed_from_unrelated_numeric_id(self):
        doc = original()
        for node in doc.findall("./izm_data/zone/param"):
            node.attrib.pop("name")
        proposal = assembled(doc, self.client)
        self.assertEqual(prepared_protocol_rows(proposal)[0][10], EMPTY)

    def test_prepared_mismatch_fails_instead_of_dropping_indicator(self):
        old = assembled()
        wrong = PreparedProtocol(old.protocol, (), (), old.source_traces, 
                                 type(old.source)(old.source.shared,
                                                  old.source.measurements[:1],
                                                  old.source.additional))
        with self.assertRaisesRegex(FsaSourceError, "различается"):
            prepared_protocol_rows(wrong)

    def test_shared_batch_calls_common_xml_preparation(self):
        with TemporaryDirectory() as tmp:
            folder = Path(tmp)
            xml = folder / "raw.xml"
            xml.write_text(ET.tostring(original(), encoding="unicode"), encoding="utf-8")
            items = [{"xml": xml, "factor_id": "3", "rm_id": "1"}]
            with patch("export_batch.read_inventory", return_value=([], items, folder)), \
                 patch("export_batch.ResourceCatalog.from_mdb",
                       return_value=catalog()), \
                 patch("export_batch.prepare_protocol",
                       return_value=assembled()) as prepare:
                result = prepare_batch(
                    folder / "ARMv51.MDB", folder / "res_orgs.mdb", None, self.client)
            self.assertTrue(prepare.called)
            self.assertEqual((result.total, result.measurement_count), (1, 2))
            # Resource mapping not complete in synthetic catalogue: fail closed.
            self.assertFalse(result.ready)
            self.assertEqual(len(result.protocols), 1)

    def test_failed_batch_does_not_create_partial_xls(self):
        bad = ProtocolBatch(2, (assembled(),), ("protocol 2 failed",), ())
        with self.assertRaisesRegex(FsaSourceError, "protocol 2 failed"):
            prepared_batch_rows(bad)

    def test_real_xls_filename_and_writer_receives_same_rows(self):
        with TemporaryDirectory() as tmp:
            root = Path(tmp)
            proposal = assembled()
            batch = ProtocolBatch(1, (proposal,), (), ())
            expected = prepared_protocol_rows(proposal)
            written = []
            def writer(path, values):
                written.append((path, values))
                path.write_bytes(b"TEST XLS")
            output = create_excel_export(batch, directory=root, writer=writer)
            self.assertEqual(output.protocol_count, 1)
            self.assertEqual(output.indicator_count, 2)
            self.assertEqual(output.file.suffix, ".xls")
            self.assertEqual(written[0][1], expected)

    def test_two_buttons_share_one_options_form(self):
        app = (DESKTOP / "app.py").read_text(encoding="utf-8")
        actions = app.split("for label, command in (", 1)[1].split("):", 1)[0]
        self.assertEqual(actions.count('("Выгрузить'), 2)
        self.assertIn('self._create_fgis_xml(target="excel")', app)
        self.assertIn('if target == "excel":', app)
        self.assertIn('kind="excel_result"', app)
        self.assertIn("address_choice", app)
        self.assertIn("run_with_com(task)", app)

    def test_excel_output_modules_do_not_read_any_source_files(self):
        for path in ("excel_shared_source.py", "excel_export.py"):
            source = (DESKTOP / path).read_text(encoding="utf-8")
            self.assertNotIn("parse_xml", source)
            self.assertNotIn("read_inventory", source)
            self.assertNotIn("AccessReader", source)
            self.assertNotIn("ResourceCatalog", source)

    def test_excel_dates_are_text_not_serials(self):
        self.assertEqual(excel_date_text("2026-10-10"), "10.10.2026")
        self.assertEqual(excel_date_text("10.10.2026"), "10.10.2026")
        self.assertEqual(excel_date_text(date(2026, 10, 10)), "10.10.2026")
        self.assertEqual(excel_date_text("31.02.2026"), EMPTY)
        self.assertEqual(excel_date_text(EMPTY), EMPTY)
        self.assertEqual(excel_date_text(""), "")
        source = (DESKTOP / "excel_export.py").read_text(encoding="utf-8")
        self.assertIn('sheet.Cells.NumberFormat = "@"', source)
        self.assertNotIn('NumberFormat = "dd.mm.yyyy"', source)
        self.assertIn('Range("A:Z").WrapText = False', source)
        self.assertIn('Range("A:Z").EntireColumn.AutoFit()', source)

    def test_all_populated_cells_are_text_and_dates_human_readable(self):
        rows = prepared_protocol_rows(assembled())
        result = excel_text_rows(rows)
        self.assertEqual(result[0][1:4],
                         ["21.09.2026", "21.09.2026", "02.10.2026"])
        self.assertEqual(result[0][16], "11.09.2026")
        self.assertEqual(result[0][7], "123456789012")
        self.assertEqual(result[1][1:4], ["", "", ""])
        self.assertTrue(all(isinstance(cell, str) for row in result for cell in row))
        with self.assertRaises(FsaSourceError):
            excel_text_rows([["too short"]])


class ComTests(unittest.TestCase):
    def test_com_lifecycle_preserved(self):
        events = []
        fake = types.SimpleNamespace(
            CoInitialize=lambda: events.append("init"),
            CoUninitialize=lambda: events.append("done"))
        with patch.object(sys, "platform", "win32"), patch.dict(sys.modules,
                                                                {"pythoncom": fake}):
            self.assertEqual(run_with_com(lambda: events.append("work") or 42), 42)
        self.assertEqual(events, ["init", "work", "done"])


if __name__ == "__main__":
    unittest.main()
