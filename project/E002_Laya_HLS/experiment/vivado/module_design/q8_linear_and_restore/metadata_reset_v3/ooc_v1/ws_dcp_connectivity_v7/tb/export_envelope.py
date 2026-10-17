#!/usr/bin/env python3
"""Exact Vivado glbl trailer recognition; never preprocess or execute Verilog.

The only accepted nonstructural text is the byte-identical installed glbl.v
body at EOF. The preceding source is passed unchanged to the v6 strict parser.
"""

from __future__ import annotations

import hashlib
from pathlib import Path

from funcsim_structure import MAX_FILE_BYTES, Unsupported, lex, parse_text


INSTALLED_GLBL = Path(
    "/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/data/verilog/src/glbl.v")
INSTALLED_BYTES = 1762
INSTALLED_SHA256 = "6270251cf35e1fce3119fc79f8fb968912f7983027e43cf030409ba68f048936"
HEADER_SKIP_BYTES = 120
CAPSULE_BYTES = 1642
CAPSULE_SHA256 = "4d98d1c9f6176e36539aad193fd1df028baed0d4bbbdd71791bef453e3bcb334"


def sha256(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def bound_capsule() -> bytes:
    """Bind both the installed full file and the exact post-header capsule."""
    if INSTALLED_GLBL.stat().st_size != INSTALLED_BYTES:
        raise Unsupported("installed glbl full-file byte count drift")
    with INSTALLED_GLBL.open("rb") as stream:
        full = stream.read(INSTALLED_BYTES + 1)
    if len(full) != INSTALLED_BYTES or sha256(full) != INSTALLED_SHA256:
        raise Unsupported("installed glbl full-file identity drift")
    capsule = full[HEADER_SKIP_BYTES:]
    if len(capsule) != CAPSULE_BYTES or sha256(capsule) != CAPSULE_SHA256:
        raise Unsupported("installed glbl capsule identity drift")
    if not capsule.startswith(b"`ifndef GLBL\n`define GLBL\n") or not capsule.endswith(
            b"endmodule\n`endif\n"):
        raise Unsupported("installed glbl exact guard/body boundary drift")
    return capsule


def parse_enveloped_bytes(raw: bytes, source_path: str,
                          *, allow_capsule_free_synthetic: bool = False) -> tuple[dict, dict]:
    """Parse only a complete structural prefix and classify its exact EOF body.

    The synthetic-only absent state is opt-in; production read_export never
    enables it. All size checks precede capsule lookup, slicing or decoding.
    """
    if len(raw) > MAX_FILE_BYTES:
        raise Unsupported("functional export byte cap exceeded before envelope split")
    capsule = bound_capsule()
    present = raw.endswith(capsule)
    if not present and not allow_capsule_free_synthetic:
        raise Unsupported("exact installed glbl capsule required at EOF")
    if present and raw.count(capsule) != 1:
        raise Unsupported("duplicate installed glbl capsule")
    prefix = raw[:-CAPSULE_BYTES] if present else raw
    try:
        structural = prefix.decode("ascii")
    except UnicodeDecodeError as error:
        raise Unsupported("non-ASCII structural prefix") from error
    at = structural.find("GLBL")
    while at >= 0:
        line_start = structural.rfind("\n", 0, at) + 1
        if structural[line_start:at].lstrip().startswith("`"):
            raise Unsupported("prefix directive references GLBL")
        at = structural.find("GLBL", at + 4)
    tokens = lex(structural)
    # The strict parser remains authoritative for every prefix directive,
    # module, declaration, instance, expression and source literal span.
    modules = parse_text(structural)
    for token in tokens:
        name = token.value[1:] if token.value.startswith("\\") else token.value
        if any(part in ("glbl", "GLBL") for part in name.split(".")):
            raise Unsupported("explicit glbl/GLBL reference in structural prefix")
    if "glbl" in modules:
        raise Unsupported("glbl cannot be selected as a structural root")
    if present:
        if not tokens or tokens[-1].value != "endmodule":
            raise Unsupported("glbl capsule is not after a complete module")
        gap = structural[tokens[-1].end:]
        if not gap or not gap.isspace() or "\n" not in gap:
            raise Unsupported("glbl capsule is not at a complete line/module boundary")
    raw_identity = {"path": source_path, "bytes": len(raw), "sha256": sha256(raw)}
    if not present:
        return modules, {"state": "ABSENT_SYNTHETIC_STRUCTURAL_SOURCE",
                         "raw_source": raw_identity,
                         "reason": "capsule-free mode is explicit for synthetic parser tests only"}
    return modules, {
        "state": "EXCLUDED_EXACT_INSTALLED_GLBL_CAPSULE",
        "raw_source": raw_identity,
        "start_byte": len(prefix), "end_byte": len(raw),
        "capsule_bytes": CAPSULE_BYTES, "capsule_sha256": CAPSULE_SHA256,
        "immutable_source_reference": {
            "path": str(INSTALLED_GLBL), "bytes": INSTALLED_BYTES,
            "sha256": INSTALLED_SHA256, "header_skip_bytes": HEADER_SKIP_BYTES,
            "slice_start_byte": HEADER_SKIP_BYTES,
            "slice_end_byte": INSTALLED_BYTES},
        "module_name": "glbl", "guard_name": "GLBL",
        "scope": "exact trailing installed Vivado simulation support body; excluded from bank structural graph",
        "reason": "behavioral global startup/JTAG support is not a selected bank primitive, port or parameter source",
        "global_startup_limit": {
            "ROC_WIDTH_ps": 100000, "TOC_WIDTH_ps": 0,
            "GRES_START_ps": 10000, "GRES_WIDTH_ps": 10000,
            "static_join_scope": "connectivity and explicit parameter correspondence only",
            "later_mapping_condition": "settled operation after global startup; reset/restore semantics require separate justification"
        }
    }
