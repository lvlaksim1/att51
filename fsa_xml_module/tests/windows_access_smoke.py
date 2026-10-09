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


# Check the same MSXML/XSD mechanism that the original save_XML invokes.
from att51_fsa.writer import Protocol, serialize_protocols, validate_xml

sample = Protocol(
    doc_id="SYNTHETIC-1", creation_date="2026-10-09",
    start_date="2026-10-08", validity_date="2026-10-08",
    application_date="2026-10-07", customer_kind=1,
    object_type=1, object_name="SYNTHETIC TEST", no_equipment=True,
)
xml = serialize_protocols([sample])[0]
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
