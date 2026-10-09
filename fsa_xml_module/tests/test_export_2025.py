"""Strict production preparation never invents original FGIS data."""
import unittest
from xml.etree import ElementTree as ET

from att51_fsa.export_2025 import CustomerSettings, prepare_protocol
from att51_fsa.resources import ResourceCatalog
from att51_fsa.writer import Protocol, ApprovedPerson, serialize_protocols, validate_xml
from pathlib import Path


class ExportPreparationTests(unittest.TestCase):
    def catalog(self):
        return ResourceCatalog.from_rows([], [], [], [], present_tables=ResourceCatalog.REQUIRED)

    def test_missing_org_and_fgis_blocks_xml(self):
        doc=ET.fromstring("""<Document num_doc="T-01" sign_date="24.03.2026">
          <factor facid="13" izm_date="11.03.2026">
          <persons><pers guid="unknown"/></persons>
          <si_guids><si_guid guid="unknown" num="123"/></si_guids>
          </factor><izm_data><zone><param bm="bm_2_2_m" fact="5"/></zone></izm_data>
          </Document>""")
        result=prepare_protocol(doc,self.catalog(),
                  CustomerSettings("10.03.2026",1,inn="1234567890"))
        self.assertIsNone(result.protocol)
        self.assertTrue(any("ID ФГИС" in x for x in result.blockers))
        self.assertTrue(any("подписанта" in x for x in result.blockers))

    def test_no_date_never_substitutes_current_date(self):
        doc=ET.fromstring('<Document num_doc="T"><factor facid="14"/></Document>')
        result=prepare_protocol(doc,self.catalog(),
                   CustomerSettings("",1,inn="1234567890"))
        self.assertIsNone(result.protocol)
        self.assertTrue(any("дата заявки" in x for x in result.blockers))

    def test_positive_verified_serializer_matches_original_xsd(self):
        sample = Protocol(
            doc_id="T-001", creation_date="2026-03-24",
            start_date="2026-03-11", validity_date="2026-03-11",
            application_date="2026-03-10", customer_kind=1,
            object_type=10, object_name="Тяжесть трудового процесса",
            data_status="20", protocol_status="6",
            inn="1234567890", no_equipment=False,
            equipment_ids=("100123",),
            approved_users=(ApprovedPerson("421", "Инженер", (1,)),),
        )
        blob = serialize_protocols([sample], verified_mapping=True)[0]
        root = ET.fromstring(blob)
        self.assertEqual(root.findtext("protocol/DataStatusId"), "20")
        self.assertEqual(root.findtext("protocol/ProtocolStatusId"), "6")
        self.assertEqual(root.findtext("protocol/Equipment/EquipmentDetails/EquipmentId"), "100123")
        schema=Path(__file__).resolve().parents[2]/"extracted"/"app"/"fileProtocolLoad_v4.xsd"
        valid, reason=validate_xml(blob, schema)
        self.assertTrue(valid, reason)

    def test_reject_incorrect_date_in_customer_form(self):
        msg = CustomerSettings("09.10.20226", 1, inn="1234567890").validate()
        self.assertTrue(any("Неверная дата заявки" in x for x in msg))
        self.assertEqual(CustomerSettings("09.10.2026", 1,
                                           inn="1234567890").validate(), ())

    def test_customer_kind_and_identity(self):
        self.assertTrue(CustomerSettings("",1).validate())
        self.assertEqual(CustomerSettings("01.03.2026",1,inn="111").validate(), ())
        self.assertTrue(CustomerSettings("01.03.2026",4).validate())


if __name__=="__main__":
    unittest.main()
