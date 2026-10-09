"""Original VBA ResearchObjectInfo 2025 mapping and original XSD checks.

Synthetic only: no working customer records or real protocol identifiers.
"""
import dataclasses
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest
from xml.etree import ElementTree as ET

from att51_fsa.measurements import ResearchObjectDraft
from att51_fsa.methods import MethodResolution
from att51_fsa.research_objects import (
    ResearchOverrides, append_research_objects, load_working_overrides,
    original_directory_name, original_oa_method_id, prepare_research_object,
)
from att51_fsa.sources import FsaSourceError
from att51_fsa.writer import Protocol, serialize_protocols, validate_xml


XSD = Path(__file__).resolve().parents[2] / "extracted/app/fileProtocolLoad_v4.xsd"


def measurement(directory="1"):
    return ResearchObjectDraft("9", directory, "83,2", "650",
                               "Document/izm_data/Level[1]", nd_izm1="2")


def method(doc_id="123", oa="Lab procedure {350}"):
    return MethodResolution(
        doc_name_id=doc_id, doc_name="Measured sound",
        oa_method=oa, nd_guid="ND1", source_rule="first_pass_nd_id",
        requires_review=False,
    )


def sample_protocol(prepared):
    return Protocol(
        doc_id="SYNTH-001", creation_date="2026-10-09", start_date="2026-10-08",
        validity_date="2026-10-08", application_date="2026-10-07",
        customer_kind=1, object_type=1, object_name="Synthetic workplace",
        data_status="20", protocol_status="6", no_equipment=True,
        method_doc_ids=(123,), research_objects=(prepared,),
    )


class ResearchObjectTests(unittest.TestCase):
    def test_original_directory_code_names(self):
        self.assertEqual(original_directory_name("1"), "DM-53535")
        self.assertEqual(original_directory_name("2"), "DM-55254")
        self.assertEqual(original_directory_name("3"), "Unknown")

    def test_original_oa_method_bracket_rule(self):
        self.assertEqual(original_oa_method_id("Lab method {350}"), "350")
        self.assertEqual(original_oa_method_id("First {0} Second {50}"), "")
        self.assertEqual(original_oa_method_id("{12ab}"), "12ab")
        self.assertEqual(original_oa_method_id("No brackets"), "")

    def test_exact_sequence_and_original_xsd_validity(self):
        r = prepare_research_object(measurement(), method(), ResearchOverrides())
        self.assertEqual(r.status, "prepared_for_synthetic_protocol_only")
        self.assertEqual((r.value.indicator_id, r.value.directory,
                          r.value.oa_method_id), ("9", "DM-53535", "350"))
        data = serialize_protocols(
            [sample_protocol(r.value)], synthetic_test_mode=True)[0]
        elem = ET.fromstring(data)
        info = elem.find("./protocol/ObjectInfo/ResearchObject/ResearchObjectInfo")
        self.assertEqual([x.tag for x in info], [
            "IndicatorId", "UniqueIndicator", "Directory", "FactValue",
            "MeasurementId", "DocNameId", "DocNameMethodikId",
        ])
        self.assertEqual(info.findtext("Directory"), "DM-53535")
        self.assertEqual(info.findtext("FactValue"), "83,2")
        self.assertEqual(info.findtext("DocNameId"), "123")
        self.assertEqual(info.findtext("DocNameMethodikId"), "350")
        if XSD.is_file():
            ok, error = validate_xml(data, XSD)
            self.assertTrue(ok, error)

    def test_individual_overrides_original_ini_sections(self):
        with TemporaryDirectory() as folder:
            ini = Path(folder) / "fgis_ra.ini"
            ini.write_text(
                "[Measurements]\nid1_9=777\n"
                "[vars_fiz1~9]\n123=2~431\n",
                encoding="utf-8",
            )
            ov = load_working_overrides(measurement(), method(), ini)
            self.assertEqual(ov.measurement_override, "777")
            self.assertEqual(ov.method_indicator_override, "2~431")
            r = prepare_research_object(
                measurement(), method(), ov)
            self.assertEqual((r.value.indicator_id, r.value.directory,
                              r.value.measurement_id), ("431", "DM-55254", "777"))

    def test_unique_indicator_and_comment_tags(self):
        ov = ResearchOverrides(
            force_unique_indicator=True,
            unique_indicator_name="Синтетический параметр",
            measurement_comment="measurement comment",
        )
        r = prepare_research_object(measurement(), method("123", "text method"), ov)
        self.assertEqual(r.value.indicator_id, "")
        self.assertEqual(r.value.directory, "")
        root = ET.Element("ObjectInfo")
        append_research_objects(root, (r.value,))
        info = root.find("./ResearchObject/ResearchObjectInfo")
        self.assertEqual(info.findtext("UniqueIndicator"), "Синтетический параметр")
        self.assertEqual(info.findtext("UniqueMethodik"), "text method")
        self.assertEqual(info.findtext("UniqueMeasurement"), "measurement comment")

    def test_unmapped_oa_is_blocked_not_guessed(self):
        r = prepare_research_object(
            measurement(), method("123", ""), ResearchOverrides())
        self.assertEqual(r.status, "requires_correction")
        self.assertIn("accreditation_method_missing", r.errors)

    def test_missing_document_id_uses_other_method_name(self):
        r = prepare_research_object(
            measurement(), method("", "Some OA method"), ResearchOverrides())
        self.assertEqual(r.value.doc_name_id, "")
        self.assertEqual(r.value.unique_method, "Measured sound")

    def test_unknown_directory_does_not_emit_unknown(self):
        r = prepare_research_object(
            measurement("55"), method(), ResearchOverrides())
        self.assertEqual(r.status, "requires_correction")
        self.assertIn("unknown_original_directory", r.errors)

    def test_original_minus_one_exclusion(self):
        a = prepare_research_object(
            measurement(), method("-1"), ResearchOverrides())
        b = prepare_research_object(
            measurement(), method(),
            ResearchOverrides(user_indicator_mapping="-1"))
        self.assertEqual((a.status, b.status),
                         ("excluded_by_original_rule", "excluded_by_original_rule"))
        self.assertIsNone(b.value)

    def test_invalid_mapping_is_not_silently_used(self):
        r = prepare_research_object(
            measurement(), method(),
            ResearchOverrides(user_indicator_mapping="something wrong"))
        self.assertEqual(r.status, "requires_correction")
        self.assertIn("invalid_user_indicator_mapping", r.errors)

    def test_missing_unique_name_needs_review(self):
        r = prepare_research_object(
            measurement(), method(),
            ResearchOverrides(force_unique_indicator=True))
        self.assertEqual(r.status, "requires_correction")
        self.assertIn("unique_indicator_name_unavailable", r.errors)

    def test_chemical_override_requires_original_chemical_id(self):
        chemical_measure = dataclasses.replace(measurement(), indicator_id_2="66")
        with TemporaryDirectory() as folder:
            ini = Path(folder) / "fgis_ra.ini"
            ini.write_text("[varsABC]\n123=2~66\n", encoding="utf-8")
            with self.assertRaises(FsaSourceError):
                load_working_overrides(chemical_measure, method(), ini)
            ov = load_working_overrides(
                chemical_measure, method(), ini, chemical_id="ABC"
            )
            self.assertEqual(ov.method_indicator_override, "2~66")

    def test_real_working_export_remains_blocked(self):
        r = prepare_research_object(measurement(), method(), ResearchOverrides())
        with self.assertRaisesRegex(NotImplementedError, "Incomplete mapping"):
            serialize_protocols([sample_protocol(r.value)])


if __name__ == "__main__":
    unittest.main()
