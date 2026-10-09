"""Read the original MDB files on x86 Windows, without Office or Word.

Requires Windows (32-bit Python), Jet/ACE OLE DB provider and pywin32.
No mutable ADO commands are issued. This is not an original exporter test.
"""
from pathlib import Path
from att51_fsa.sources import AccessReader

root = Path(__file__).resolve().parents[2]
samples = [
    ("workplaces", root / "extracted/app/model/ARMv51.MDB",
     "SELECT TOP 1 id FROM struct_rm"),
    ("resources", root / "extracted/app/res_orgs.mdb",
     "SELECT TOP 1 id FROM ATT_DEVICE"),
]
for label, path, sql in samples:
    with AccessReader(path) as connection:
        records = connection.select(sql)
        print(f"{label}: ADO/Jet provider={connection.provider}, rows={len(records)}")
print("ORIGINAL_MDB_READ_ONLY_SMOKE_PASS")

# Force the fallback on a real original MDB, not just simulated COM errors.
from tempfile import TemporaryDirectory
from unittest.mock import patch
with TemporaryDirectory() as temp:
    root_snapshot = Path(temp) / "Att51_export" / "data"
    with patch.object(AccessReader, "_is_network_path", return_value=True):
        with AccessReader(samples[0][1], snapshot_root=root_snapshot) as copy:
            assert copy.used_snapshot, "Forced network snapshot was not used"
            rows = copy.select(samples[0][2])
            print("ORIGINAL_MDB_LOCAL_SNAPSHOT_READ_PASS", len(rows))
    assert not list(root_snapshot.rglob("*.mdb")), "MDB copy remained after closing"
    print("ORIGINAL_MDB_LOCAL_SNAPSHOT_REMOVED")



# Check the same MSXML/XSD mechanism that the original save_XML invokes.
from att51_fsa.writer import Protocol, serialize_protocols, validate_xml

sample = Protocol(
    doc_id="SYNTHETIC-1", creation_date="2026-10-09",
    start_date="2026-10-08", validity_date="2026-10-08",
    application_date="2026-10-07", customer_kind=1,
    object_type=1, object_name="SYNTHETIC TEST", no_equipment=True,
    data_status="20", protocol_status="6",
)
xml = serialize_protocols([sample], synthetic_test_mode=True)[0]
schema_path = root / "extracted/app/fileProtocolLoad_v4.xsd"
ok, reason = validate_xml(xml, schema_path)
assert ok, f"Original MSXML rejects minimal supported structure: {reason}"
print("ORIGINAL_MSXML6_XSD_PASS")

# The original VBA includes text labels in two integer fields in certain
# branches. This probe tests the actual XSD type with MSXML6, not Word.
mismatch = xml.replace(b"<DataStatusId>20</DataStatusId>",
                       b"<DataStatusId>20 - status</DataStatusId>")
ok, reason = validate_xml(mismatch, schema_path)
assert not ok, "Original XML schema unexpectedly accepts a noninteger status"
print("ORIGINAL_MSXML6_NONINTEGER_STATUS_REJECTED")

# Read original Access column definitions without records or schema changes.
# ADODB OpenSchema(4) = adSchemaColumns; schema inspection never writes to MDB.
resource = root / "extracted/app/res_orgs.mdb"
with AccessReader(resource) as connection:
    schema = connection._connection.OpenSchema(4)
    names = {}
    try:
        while not schema.EOF:
            table = str(schema.Fields("TABLE_NAME").Value)
            column = str(schema.Fields("COLUMN_NAME").Value)
            if table in {
                "FGIS_RA", "ATT_DEVICE", "ATT_DOP_INFO", "ATT_PERSON",
                "DIC_ND", "DIC_ND_INFO", "DIC_ND_SYN", "DIC_ND_OA_METHODS",
            }:
                names.setdefault(table, []).append(column)
            schema.MoveNext()
    finally:
        schema.Close()
    for table in sorted(names):
        print(f"RESOURCE_SCHEMA {table}: {','.join(names[table])}")
    for mandatory in ("ATT_DEVICE", "ATT_PERSON", "DIC_ND"):
        assert mandatory in names, f"Missing original resource table: {mandatory}"
    for table in ("FGIS_RA", "DIC_ND_INFO", "DIC_ND_SYN"):
        if table not in names:
            print(f"RESOURCE_SCHEMA_OPTIONAL_ABSENT {table}")
print("RESOURCE_SCHEMA_READONLY_PASS")

# The resource loader must work against the ORIGINAL installation template.
# This template does not yet contain the FGIS_RA/DIC_ND_INFO/DIC_ND_SYN
# tables; the original GUI creates them on first open. Our loader MUST NOT.
from att51_fsa.resources import ResourceCatalog
with AccessReader(root / "extracted/app/res_orgs.mdb") as resource_reader:
    tables_before = resource_reader.table_names()
    catalog = ResourceCatalog.from_reader(resource_reader)
    tables_after = resource_reader.table_names()
    assert tables_after == tables_before, "Resource loader changed MDB schema"
    assert catalog.diagnostics.device_count >= 0
    assert catalog.diagnostics.normative_count >= 0
    print("ORIGINAL_RESOURCE_CATALOG_READONLY_PASS",
          catalog.diagnostics.device_count,
          catalog.diagnostics.person_count,
          catalog.diagnostics.normative_count)
    if "FGIS_RA" not in tables_after:
        print("ORIGINAL_TEMPLATE_FGIS_LINKS_ABSENT_CONFIRMED")
