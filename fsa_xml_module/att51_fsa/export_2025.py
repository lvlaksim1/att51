"""Conservative verified-field FGIS XML preparation.

Reads original ATT51 sidecar and the already loaded resource catalogue. Missing
FGIS numerical identifiers / organizational facts are explicit blocking errors.
Never substitutes local GUID, SNILS or a fabricated numeric ID into FGIS XSD.
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from xml.etree import ElementTree as ET

from .original_header import build_header, original_protocol_date, fgis_date
from .pipeline_2025 import FieldTrace, Original2025Options, analyze_2025
from .resource_xml import inspect_protocol_resources
from .resources import ResourceCatalog
from .sources import FsaSourceError, read_ini
from .writer import ApprovedPerson, Protocol


@dataclass(frozen=True)
class CustomerSettings:
    application_date: str
    customer_kind: int
    inn: str = ""
    ogrn: str = ""
    full_name: str = ""
    fio: str = ""
    data_status: str = "20"

    def validate(self) -> tuple[str, ...]:
        issues = []
        if self.customer_kind not in (1, 2, 4):
            issues.append("Нужно выбрать подтверждённый тип заказчика: 1, 2 или 4")
        if self.customer_kind in (1, 2) and not self.inn.strip():
            issues.append("Для ЮЛ/ИП не указан ИНН заказчика")
        if self.customer_kind == 4 and not self.fio.strip():
            issues.append("Для физического лица не указано ФИО")
        if not self.application_date.strip():
            issues.append("Отсутствует дата заявки (v5_org_options.query_date)")
        else:
            try:
                fgis_date(self.application_date, source="v5_org_options.query_date")
            except FsaSourceError:
                issues.append("Неверная дата заявки: " + repr(self.application_date)
                              + ". Укажите дату в формате ДД.ММ.ГГГГ.")
        return tuple(issues)


@dataclass(frozen=True)
class PreparedProtocol:
    protocol: Protocol | None
    blockers: tuple[str, ...]
    warnings: tuple[str, ...] = ()
    # Captured before FGIS IDs replace source values; precisely the same
    # accepted traces, and in the same order, as protocol.research_objects.
    source_traces: tuple[FieldTrace, ...] = ()


def _doc(xml: ET.Element) -> ET.Element:
    node = xml if xml.tag == "Document" else xml.find(".//Document")
    if node is None:
        raise FsaSourceError("Внутренний XML без Document")
    return node


def prepare_protocol(
    xml: ET.Element, resources: ResourceCatalog, customer: CustomerSettings,
    *, options: Original2025Options | None = None,
    working_ini: Path | None = None,
) -> PreparedProtocol:
    """Build one protocol only when all mapped essential facts are verified.

    Original 2025 is the selected measurement regime. Consolidated protocols
    and different original UI switches need their own explicit adapter.
    """
    doc = _doc(xml)
    factor = doc.find("./factor")
    if factor is None:
        return PreparedProtocol(None, ("Нет Document/factor",))
    number, facid = doc.get("num_doc", "").strip(), factor.get("facid", "")
    blockers = list(customer.validate())
    if facid not in ("3", "4", "5", "6", "11", "12", "13", "14", "10099"):
        blockers.append("Фактор не имеет проверенного алгоритма 2025: " + facid)
    if doc.get("fgis_state") == "1":
        blockers.append("Оригинальная программа исключает протокол по fgis_state=1")
    if not number:
        blockers.append("Нет Document/@num_doc")
    try:
        src_date = original_protocol_date(doc.get("fill_date",""), doc.get("sign_date",""))
        object_name_override = (
            read_ini(Path(working_ini), "FullNameObject", facid)
            if working_ini is not None else ""
        )
        h = build_header(
            number=number, protocol_date=src_date,
            measurement_dates=(factor.get("izm_date",""),),
            application_date=customer.application_date,
            factor_id=facid, data_status=customer.data_status,
            object_name_override=object_name_override,
        )
    except (FsaSourceError, ValueError) as exc:
        blockers.append(str(exc))
        h = None
    try:
        resource_info = inspect_protocol_resources(doc, resources)
    except (FsaSourceError, ValueError) as exc:
        blockers.append("Не удалось сопоставить исходные ресурсы: "+str(exc))
        resource_info = None
    equipment_ids: list[str] = []
    approved: list[ApprovedPerson] = []
    nd_ids: list[str] = []
    warnings: list[str] = []
    if resource_info is not None:
        blockers.extend("НД: "+code for code in resource_info.errors)
        warnings.extend(resource_info.warnings)
        equipment_nodes = factor.findall("./si_guids/si_guid")
        for index, item in enumerate(resource_info.equipment):
            if not item.fgis_id.isdecimal() or int(item.fgis_id) <= 0:
                node = equipment_nodes[index] if index < len(equipment_nodes) else None
                ref = (f"GUID={node.get('guid', '')}; номер={node.get('num', '')}"
                       if node is not None else item.local_guid)
                context = ("найден в справочнике: " + item.display_name
                           if item.found else "не найден в выбранном справочнике")
                blockers.append("Прибор (" + ref + "): " + context +
                                "; отсутствует числовой ID ФГИС")
            else:
                equipment_ids.append(item.fgis_id)
        if not resource_info.equipment and doc.get("fgis_state") != "2":
            blockers.append("Не подтверждено отсутствие оборудования; NoEquipmentInfo не подставляется")
        role_map = {"izm":1, "boss":2, "exp":3}
        people_nodes = (
            factor.findall("./persons/pers") +
            factor.findall("./exp_persons/pers") +
            (factor.findall("./boss/pers") if doc.get("type") == "protocol2019"
             else [node for node in (factor.find("./boss"),) if node is not None])
        )
        for index, (role, item) in enumerate(resource_info.people):
            if not item.fgis_id.isdecimal() or int(item.fgis_id) <= 0:
                node = people_nodes[index] if index < len(people_nodes) else None
                ref = (node.get("guid", "") if node is not None else item.local_guid)
                context = (item.display_name if item.found
                           else "нет соответствия в выбранной базе ресурсов")
                blockers.append("Сотрудник (роль " + role + "; GUID=" + ref + "; " +
                                context + "): отсутствует числовой ID ФГИС")
                continue
            profile = next((p for p in resources.people if p.guid == item.local_guid), None)
            # Original uses pers.fgis_state, NOT generic ATT_PERSON.dolg.
            position = profile.fgis_position.strip() if profile else ""
            if not position:
                blockers.append("У сотрудника отсутствует подтверждённая должность ФГИС (fgis_state)")
                continue
            approved.append(ApprovedPerson(item.fgis_id, position, (role_map.get(role,1),)))
        if not approved:
            blockers.append("Нет ни одного сопоставленного подписанта/измерителя ФГИС")
        for nd in resource_info.normative:
            if "fatal_nd_absent" in nd.warnings:
                blockers.append("НД из протокола не найден в выбранной базе ресурсов: "
                                + repr(nd.source_name) + " (исходный id="
                                + repr(nd.source_id) + ")")
            if nd.method_doc_id.isdecimal() and int(nd.method_doc_id)>0:
                nd_ids.append(nd.method_doc_id)
            elif not nd.method_doc_id and not nd.warnings:
                blockers.append("Нормативный документ без подтверждённого идентификатора/правила иной НД")
    analysis = None
    if facid in ("3", "4", "5", "6", "11", "12", "13", "14", "10099"):
        try:
            analysis=analyze_2025(doc,resources,options or Original2025Options(),
                                  working_fgis_ini=working_ini)
            blockers.extend("Показатели/методики: "+s for s in analysis.errors
                            if s not in analysis.resource_errors)
            missing_traces = []
            for trace in analysis.measurement_traces:
                if trace.prepared is None and trace.result_status != "excluded_by_original_rule":
                    missing_traces.append(trace)
                warnings.extend(trace.warnings)
            if missing_traces:
                places = ", ".join(trace.source_xpath.rsplit("/", 1)[-1]
                                   for trace in missing_traces)
                blockers.append(f"Не подготовлено показателей: {len(missing_traces)} "
                                f"из {len(analysis.measurement_traces)} "
                                f"(позиции исходного XML: {places})")
        except (FsaSourceError, ValueError) as exc:
            blockers.append("Ошибка преобразования показателей: "+str(exc))
    if not analysis or not analysis.measurement_traces or not any(t.prepared for t in analysis.measurement_traces):
        blockers.append("Нет подтверждённых ResearchObjectInfo")
    unique_blockers=tuple(dict.fromkeys(blockers))
    if unique_blockers or h is None:
        return PreparedProtocol(None, unique_blockers,
                                tuple(dict.fromkeys(warnings)))
    return PreparedProtocol(Protocol(
        doc_id=h.doc_id, creation_date=h.creation_date,
        start_date=h.start_date, validity_date=h.validity_date,
        application_date=h.application_date, customer_kind=customer.customer_kind,
        object_type=h.object_type_id, object_name=h.object_name,
        data_status=h.data_status_id, protocol_status=h.protocol_status_id,
        inn=customer.inn, ogrn=customer.ogrn,
        customer_full_name=customer.full_name, customer_fio=customer.fio,
        equipment_ids=tuple(dict.fromkeys(equipment_ids)),
        approved_users=tuple(approved), method_doc_ids=tuple(dict.fromkeys(nd_ids)),
        research_objects=tuple(t.prepared for t in analysis.measurement_traces
                               if t.prepared is not None),
        no_equipment=False, territory_feature=True, is_lab=False,
        is_another_doc=False,
    ), (), tuple(dict.fromkeys(warnings)),
       tuple(t for t in analysis.measurement_traces if t.prepared is not None))
