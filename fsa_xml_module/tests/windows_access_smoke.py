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
