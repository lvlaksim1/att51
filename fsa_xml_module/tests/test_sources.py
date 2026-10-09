import os
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import patch
from xml.etree import ElementTree as ET

from att51_fsa.sources import (
    AppSources, FsaSourceError, candidate_factor, files_directory,
    read_ini, read_sidecar, resolve_relative_file, sidecar_for_document,
)
from att51_fsa.writer import Protocol, serialize_protocols, validate_xml

# Reference the original, unchanged XSD in the repository.
ORIGINAL_XSD = Path(__file__).resolve().parents[2] / "extracted/app/fileProtocolLoad_v4.xsd"


class PathsTest(unittest.TestCase):
    def test_original_paths(self):
        self.assertEqual(
            sidecar_for_document(r"C:\ARMv51_files\{GUID}\Протокол.docx"),
            r"C:\ARMv51_files\{GUID}\xml\Протокол.xml",
        )
        self.assertEqual(sidecar_for_document(r"C:\A\B.DOC"),
                         r"C:\A\xml\B.xml")
        self.assertEqual(str(files_directory(Path("/data/ARMv51.MDB"))),
                         "/data/ARMv51_files")

    def test_original_factor_conditions(self):
        for factor in (1, 11, 15, 17, 26, 35, 37, 41, 10009, 10099):
            self.assertTrue(candidate_factor(factor), factor)
        for factor in (-1, 0, 16, 101, 105, 10001):
            self.assertFalse(candidate_factor(factor), factor)

    def test_outside_paths_refused(self):
        with TemporaryDirectory() as directory:
            root = Path(directory)
            with self.assertRaises(FsaSourceError):
                resolve_relative_file(root, r"..\secret.docx")
            with self.assertRaises(FsaSourceError):
                resolve_relative_file(root, r"C:\other.docx")

    def test_russian_ini(self):
        with TemporaryDirectory() as directory:
            path = Path(directory) / "options.ini"
            path.write_bytes("[DB]\nsout_path=C:\\Базы\\RM.MDB\n".encode("cp1251"))
            self.assertEqual(read_ini(path, "DB", "sout_path"),
                             r"C:\Базы\RM.MDB")


class SidecarTest(unittest.TestCase):
    def test_original_xml_nodes(self):
        with TemporaryDirectory() as directory:
            path = Path(directory) / "test.xml"
            path.write_text(
                '<Document num_doc="P-22" fill_date="01.02.2026" '
                'sign_date="03.02.2026" fgis_state="0">'
                '<factor facid="4" izm_date="02.02.2026">'
                '<si_guids><si_guid guid="abc" num="121"/></si_guids></factor>'
                '<persons><person/></persons><nd_data><nd/></nd_data>'
                '</Document>', encoding="utf-8"
            )
            result = read_sidecar(path)
            self.assertEqual(result.protocol_number, "P-22")
            self.assertEqual(result.measurement_dates, "02.02.2026")
            self.assertEqual(result.equipment, (("abc", "121"),))
            self.assertEqual(result.personnel_count, 1)
            self.assertEqual(result.normative_documents_count, 1)

    def test_xml_dtd_refused(self):
        with TemporaryDirectory() as directory:
            path = Path(directory) / "bad.xml"
            path.write_text('<!DOCTYPE foo [<!ENTITY x "y">]><Document/>')
            with self.assertRaises(FsaSourceError):
                read_sidecar(path)


class ExportWriterTest(unittest.TestCase):
    def sample(self) -> Protocol:
        # Artificial test data, not a real protocol or a complete export mapping.
        return Protocol(
            doc_id="TEST-001", creation_date="2026-10-01",
            start_date="2026-09-30", validity_date="2026-09-30",
            application_date="2026-09-29", customer_kind=1, object_type=1,
            object_name="TEST only", inn="1234567890", no_equipment=True,
        )

    def test_valid_minimal_output_against_original_schema(self):
        payload = serialize_protocols([self.sample()])[0]
        root = ET.fromstring(payload)
        self.assertEqual(root.findall("./protocol")[0].findtext("DocId"), "TEST-001")
        if ORIGINAL_XSD.is_file():
            ok, error = validate_xml(payload, ORIGINAL_XSD)
            self.assertTrue(ok, error)

    def test_split_into_100_record_files(self):
        contents = serialize_protocols([self.sample()] * 101)
        self.assertEqual([len(ET.fromstring(part).findall("protocol"))
                          for part in contents], [100, 1])

    def test_disallow_bad_status_from_original_vba(self):
        import dataclasses
        sample = dataclasses.replace(self.sample(), data_status="20 - Черновик")
        with self.assertRaisesRegex(ValueError, "DataStatusId"):
            serialize_protocols([sample])


class InspectionTest(unittest.TestCase):
    def test_mdb_xml_and_resource_mapping(self):
        with TemporaryDirectory() as directory:
            base = Path(directory)
            mdb = base / "ARMv51.MDB"
            mdb.touch()
            resources = base / "res_orgs.mdb"
            resources.touch()
            folder = files_directory(mdb)
            sidecar = folder / "ABC" / "xml" / "shum.xml"
            sidecar.parent.mkdir(parents=True)
            sidecar.write_text(
                '<Document num_doc="T1" fgis_state="0">'
                '<factor facid="4" izm_date="01.01.2026">'
                '<si_guids><si_guid guid="GUID1" num="123"/></si_guids>'
                '</factor></Document>', encoding="utf-8"
            )

            class FakeAccess:
                def __init__(self, database):
                    self.database = Path(database)
                def __enter__(self):
                    return self
                def __exit__(self, *args):
                    pass
                def select(self, query):
                    if "FROM FGIS_RA" in query:
                        return [{"rec_type": 0, "rec_guid": "GUID1", "IntValue": 199}]
                    if "FROM struct_rm" in query:
                        return [{"id": 7}]
                    if "FROM sout_factors" in query:
                        return [{"factor_id": 4, "factor_name": "Шум",
                                 "izm_date": None, "file": r"ABC\shum.docx"}]
                    raise AssertionError(query)
            with patch("att51_fsa.sources.AccessReader", FakeAccess):
                report = AppSources(mdb, resources).inspect()
            self.assertEqual(report["candidates"][0]["protocol_number"], "T1")
            self.assertEqual(report["candidates"][0]["status"],
                             "ready_for_further_mapping")


if __name__ == "__main__":
    unittest.main()
