"""Schema-only evidence for unsupported internal ATT51 measurement factors.

No values, personal names, GUIDs, source XML text, or measurement outcomes are
included: this report helps reconstruct the transformation, not export data.
"""
from __future__ import annotations

from collections import Counter, defaultdict
from xml.etree import ElementTree as ET

from att51_fsa.sources import FsaSourceError


MEASUREMENT_ROOTS = {"factor", "izm_data", "izm_res_data"}
MAX_NODES = 20000
MAX_SHAPES = 120
MAX_DEPTH = 5


def inspect_factor_structure(root: ET.Element) -> dict:
    document = root if root.tag == "Document" else root.find(".//Document")
    if document is None:
        raise FsaSourceError("Внутренний XML не содержит Document.")
    factor = document.find("factor")
    if factor is None:
        raise FsaSourceError("Внутренний XML не содержит Document/factor.")
    facid = factor.get("facid", "")
    groups = {}
    for rootname in sorted(MEASUREMENT_ROOTS):
        blocks = document.findall(rootname)
        counts: Counter[str] = Counter()
        attributes: dict[str, set[str]] = defaultdict(set)
        visited = 0
        for block in blocks:
            queue = [(block, rootname, 1)]
            while queue:
                node, key, depth = queue.pop()
                visited += 1
                if visited > MAX_NODES:
                    raise FsaSourceError(
                        "Слишком много элементов измерений; исследование структуры "
                        "ограничено 20000 узлами."
                    )
                counts[key] += 1
                attributes[key].update(node.attrib)
                if depth < MAX_DEPTH:
                    for child in reversed(list(node)):
                        queue.append((child, key + "/" + child.tag, depth + 1))
        shapes = [{
            "element": key,
            "count": count,
            "attribute_names": sorted(attributes[key])[:40],
        } for key, count in sorted(counts.items())[:MAX_SHAPES]]
        groups[rootname] = {
            "root_count": len(blocks),
            "element_count": visited,
            "distinct_element_paths": len(counts),
            "truncated_paths": len(counts) > MAX_SHAPES,
            "structure": shapes,
        }
    return {
        "factor_id": facid,
        "measurement_structure": groups,
        "privacy": "Содержатся только имена полей и их количества; значения XML не включены.",
        "status": "structure_only_not_a_mapping",
        "fgis_export_supported": False,
    }
