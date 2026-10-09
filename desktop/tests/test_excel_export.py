"""Exact XML->Excel selection, source labels, no ID fallback and worker COM."""
from __future__ import annotations

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

from excel_export import HEADERS, create_excel_export
from excel_shared_source import MISSING, prepared_protocol_rows, build_shared_excel_rows
from com_workers import run_with_com
from att51_fsa.export_2025 import CustomerSettings, PreparedProtocol
from att51_fsa.measurements import ResearchObjectDraft
from att51_fsa.pipeline_2025 import FieldTrace
from att51_fsa.resources import ResourceCatalog
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


def assembled():
    drafts = [
        ResearchObjectDraft("66","1","2.4","533",
                            "Document/izm_data/zone/param[1]"),
        ResearchObjectDraft("66","1","0.5","533",
                            "Document/izm_data/zone/param[2]"),
    ]
    selected = [SimpleNamespace(
        fact_value=value, unique_indicator="", unique_method="",
        indicator_id="66", measurement_id="533")
        for value in ("2.4", "0.5")]
    traces = [
        FieldTrace(draft.source_xpath,draft.indicator_id,"complete",
                   "first_pass_nd_id","4519842",item,(),(),
                   source_draft=draft,
                   original_method_name=("Методика 1","Методика 2")[i],
                   original_oa_method="Инструментальный {1138}")
        for i,(draft,item) in enumerate(zip(drafts,selected))]
    protocol = SimpleNamespace(
        doc_id="ABC-001", start_date="2026-09-21",
        validity_date="2026-09-21", creation_date="2026-10-02",
        object_name="Аэрозоли преимущественно фиброгенного действия",
        research_objects=tuple(selected))
    return PreparedProtocol(protocol,(),(),tuple(traces))


class SharedExportTests(unittest.TestCase):
    def setUp(self):
        self.client = CustomerSettings(
            "11.09.2026",2,inn="123456789012",
            full_name="ИП Исходный заказчик")

    def test_excel_template_has_26_original_fields(self):
        self.assertEqual(len(HEADERS),26)
        self.assertEqual(HEADERS[10:15],(
            "Наименование показателя", "Измеренное значение",
            "Единица измерения", "Наименование методики",
            "Наименование метода"))

    def test_exact_common_selected_count_and_order(self):
        doc = original()
        prepared = assembled()
        rows = prepared_protocol_rows(doc,prepared,catalog(),self.client)
        self.assertEqual(len(rows),len(prepared.protocol.research_objects))
        self.assertEqual([row[11] for row in rows],["2.4","0.5"])
        self.assertEqual([row[10] for row in rows],
                         ["Пыль: разовая концентрация","Пыль: среднесменная"])
        self.assertEqual(rows[0][12:15],["мг/м³","Методика 1","Инструментальный"])
        self.assertEqual(rows[1][12:15],["мг/м³","Методика 2","Инструментальный"])
        self.assertEqual(rows[0][0],"ABC-001")
        self.assertEqual(rows[0][4],"ИП Исходный заказчик")
        self.assertEqual(rows[0][7],"123456789012")
        self.assertEqual(rows[0][9],"Аэрозоли преимущественно фиброгенного действия")
        self.assertEqual(rows[0][16],"11.09.2026")
        self.assertIn("Аспиратор",rows[0][22])
        self.assertEqual(rows[0][23],"Петров П. П.")
        self.assertEqual(rows[1][:10],[""]*10)
        self.assertEqual(rows[1][15:],[""]*11)
        self.assertNotIn("4519842",repr(rows))
        self.assertNotIn("1138",repr(rows))
        self.assertNotIn("533",repr(rows))

    def test_missing_source_text_not_reconstructed_from_fgis_id(self):
        doc=original()
        for node in doc.findall("./izm_data/zone/param"):
            node.attrib.pop("name")
            node.attrib.pop("unit")
        result=prepared_protocol_rows(doc,assembled(),catalog(),self.client)
        self.assertEqual(result[0][10],MISSING)
        self.assertEqual(result[0][12],MISSING)
        self.assertEqual(result[0][11],"2.4")

    def test_prepared_mismatch_fails_instead_of_dropping_indicator(self):
        old=assembled()
        wrong=PreparedProtocol(old.protocol,(),(),old.source_traces[:1])
        with self.assertRaisesRegex(FsaSourceError,"количества"):
            prepared_protocol_rows(original(),wrong,catalog(),self.client)

    def test_shared_batch_calls_xml_preparation_and_keeps_selected(self):
        with TemporaryDirectory() as tmp:
            folder=Path(tmp)
            xml=folder/"raw.xml"
            xml.write_text(ET.tostring(original(),encoding="unicode"),encoding="utf-8")
            items=[{"xml":xml,"factor_id":"3"}]
            with patch("excel_shared_source.read_inventory",
                       return_value=([],items,folder)), \
                 patch("excel_shared_source.ResourceCatalog.from_mdb",
                       return_value=catalog()), \
                 patch("excel_shared_source.prepare_protocol",
                       return_value=assembled()) as prepare:
                rows,n,indicators=build_shared_excel_rows(
                    folder/"ARMv51.MDB",folder/"res_orgs.mdb",None,self.client)
            self.assertTrue(prepare.called)
            self.assertEqual((n,indicators),(1,2))
            self.assertEqual(len(rows),2)

    def test_blocked_source_prevents_partial_xls(self):
        with TemporaryDirectory() as tmp:
            base=Path(tmp)
            xml=base/"raw.xml"
            xml.write_text(ET.tostring(original(),encoding="unicode"),encoding="utf-8")
            with patch("excel_shared_source.read_inventory",return_value=(
                [],[{"xml":xml,"factor_id":"3"}],base)), \
                 patch("excel_shared_source.ResourceCatalog.from_mdb",
                       return_value=catalog()), \
                 patch("excel_shared_source.prepare_protocol",
                       return_value=PreparedProtocol(None,("missing_method",))):
                with self.assertRaisesRegex(FsaSourceError,"missing_method"):
                    build_shared_excel_rows(base/"a.mdb",base/"b.mdb",None,self.client)

    def test_real_xls_filename_and_writer_receives_same_rows(self):
        with TemporaryDirectory() as tmp:
            base=Path(tmp)
            rows=prepared_protocol_rows(original(),assembled(),catalog(),self.client)
            saved=[]
            def writer(path, values):
                saved.append((path,values))
                path.write_bytes(b"TEST XLS")
            with patch("excel_export.build_shared_excel_rows",return_value=(
                rows,1,len(rows))):
                output=create_excel_export(base/"a.mdb",base/"b.mdb",None,
                                           self.client,directory=base,writer=writer)
            self.assertEqual(output.protocol_count,1)
            self.assertEqual(output.indicator_count,2)
            self.assertEqual(output.file.suffix,".xls")
            self.assertEqual(saved[0][1],rows)

    def test_two_buttons_share_one_options_form(self):
        code=(DESKTOP/"app.py").read_text(encoding="utf-8")
        actions=code.split("for label, command in (",1)[1].split("):",1)[0]
        self.assertEqual(actions.count('("Выгрузить'),2)
        self.assertIn('self._create_fgis_xml(target="excel")',code)
        self.assertIn('if target == "excel":',code)
        self.assertIn('kind="excel_result"',code)
        self.assertIn("run_with_com(task)",code)


class ComTests(unittest.TestCase):
    def test_com_lifecycle_preserved(self):
        actions=[]
        fake=types.SimpleNamespace(
            CoInitialize=lambda:actions.append("init"),
            CoUninitialize=lambda:actions.append("done"))
        with patch.object(sys,"platform","win32"),patch.dict(sys.modules,
                                                             {"pythoncom":fake}):
            self.assertEqual(run_with_com(lambda:actions.append("work") or 42),42)
        self.assertEqual(actions,["init","work","done"])


if __name__=="__main__":
    unittest.main()
