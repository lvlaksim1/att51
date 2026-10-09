"""Independent FGIS FSA XML research module for ATT51. Original application is not invoked."""
from .sources import AccessReader, AppSources, Candidate, FsaSourceError, read_sidecar, sidecar_for_document
from .writer import Protocol, serialize_protocols, validate_xml

__all__ = ["AccessReader", "AppSources", "Candidate", "FsaSourceError", "read_sidecar", "sidecar_for_document", "Protocol", "serialize_protocols", "validate_xml"]

from .selection import ProtocolSelection, select_individual, select_consolidated
from .measurements import NoiseOptions, ResearchObjectDraft, map_noise_equivalent

from .resources import ResourceCatalog, ResourceResolution, NdResolution, nd_hash, resource_mdb_path
from .resource_xml import ProtocolResourceAudit, inspect_protocol_resources, inspection_dict

from .measurements import (MicroclimateOptions, LightingOptions,
                           map_microclimate_2025, map_aeroions_2025,
                           map_ultrasound_2025, map_infrasound_equivalent,
                           map_lighting_2025)
from .pipeline_2025 import (Original2025Options, Protocol2025Diagnostic,
                            analyze_2025, analyze_2025_file)
from .research_objects import (ResearchOverrides, PreparedResearchObject,
                               ResearchPreparation, prepare_research_object,
                               load_working_overrides)
__all__.extend([
    "MicroclimateOptions", "LightingOptions", "map_microclimate_2025",
    "map_aeroions_2025", "map_ultrasound_2025", "map_infrasound_equivalent",
    "map_lighting_2025", "Original2025Options", "Protocol2025Diagnostic",
    "analyze_2025", "analyze_2025_file", "ResearchOverrides",
    "PreparedResearchObject", "ResearchPreparation", "prepare_research_object",
    "load_working_overrides",
])
