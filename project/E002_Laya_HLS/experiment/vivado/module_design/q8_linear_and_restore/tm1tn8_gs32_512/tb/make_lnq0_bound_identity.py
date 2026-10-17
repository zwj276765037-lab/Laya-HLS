#!/usr/bin/env python3
"""Build one reproducible LNQ0 strict-W diagnostic binding from checked BOs.

This is a finite simulation binding, not Q8S2 registration or live BO proof.
The RTL adapter must compare the resulting full identity and actual AXI ranges.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
from pathlib import Path


BO = (
    ("embedding", 0, 0x600000000),
    ("w_q0", 2, 0x500000000),
    ("w_q1", 3, 0x510000000),
    ("w_scale", 4, 0x520000000),
    ("aux", 5, 0x400000000),
)
STATE0_BASE = 0x300000000
STATE0_BYTES = 16920576
OUTPUT_BASE = 0x100000000
OUTPUT_BYTES = 0x3000000


def require(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError(message)


def sha(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(8 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def record(path: Path) -> dict:
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": sha(path)}


def words(path: Path, width: int) -> bytes:
    raw = bytearray()
    for i, line in enumerate(path.read_text().splitlines()):
        require(len(line) == 2 * width, f"bad hex line {path}:{i}")
        raw += bytes.fromhex(line)[::-1]
    return bytes(raw)


def write_words(path: Path, raw: bytes, width: int) -> None:
    require(len(raw) % width == 0, "word alignment")
    path.write_text("".join(raw[i:i + width][::-1].hex() + "\n"
                            for i in range(0, len(raw), width)))


def put32(raw: bytearray, off: int, value: int) -> None:
    struct.pack_into("<I", raw, off, value)


def put64(raw: bytearray, off: int, value: int) -> None:
    struct.pack_into("<Q", raw, off, value)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--production", required=True, type=Path)
    ap.add_argument("--at041", required=True, type=Path)
    ap.add_argument("--generation", type=int, default=1)
    ap.add_argument("--output", required=True, type=Path)
    args = ap.parse_args()
    prod, at041, out = (p.resolve() for p in
                       (args.production, args.at041, args.output))
    require(not out.exists() and 0 < args.generation < (1 << 64),
            "fresh output and nonzero binding generation required")
    manifest_path = prod / "manifest.json"
    manifest = json.loads(manifest_path.read_text())
    prior_path = at041 / "result/report.json"
    prior = json.loads(prior_path.read_text())
    require(prior["status"] == "PASS_HOST_ONLY" and
            prior["inputs"][0]["sha256"] == sha(manifest_path),
            "AT041 canonical preflight drift")
    require(prior["production_tags"] == manifest["tags"], "tag drift")
    require(manifest["schema"] == "laya-model-p2-v1", "manifest dialect")
    prior_bo = {entry["role"]: entry["canonical"]["sha256"]
                for entry in prior["package_bos"]}
    require(sha(Path(manifest["source_model"]["path"])) ==
            manifest["source_model"]["sha256"], "actual GGUF drift")

    # This template has the checked Q8S2 field layout. Every canonical data
    # field below is rebuilt from the current manifest and real address table.
    template_path = at041 / "result/fixtures/model_identity_q8s2_diagnostic.hex"
    template = words(template_path, 416)
    require(len(template) == 416 and
            hashlib.sha256(template).hexdigest() ==
            prior["diagnostic_W_identity_sha256"], "diagnostic layout drift")
    binding = bytearray(template)
    prefix = b"".join(bytes.fromhex(manifest["tags"][k]) for k in
                      ("model", "numeric", "layout", "build"))
    require(len(prefix) == 64, "canonical tag width")
    binding[:64] = prefix
    put32(binding, 64, 0)  # strict profile
    put64(binding, 72, args.generation)
    ranges = [(OUTPUT_BASE, OUTPUT_BYTES), (STATE0_BASE, STATE0_BYTES)]
    bo_records = []
    for index, (role, role_id, base) in enumerate(BO):
        source = prod / manifest["bo"][role]["file"]
        source_record = record(source)
        require(source_record["bytes"] == manifest["bo"][role]["size"] and
                source_record["sha256"] == manifest["bo"][role]["sha256"] and
                source_record["sha256"] == prior_bo[role],
                f"canonical BO drift: {role}")
        size = source_record["bytes"]
        require(base % 64 == 0 and size > 0 and base + size < (1 << 64),
                f"BO range: {role}")
        ranges.append((base, size))
        seed = ("LNQ0-W-BO-v1:" + sha(manifest_path) + ":" + role + ":" +
                str(base) + ":" + str(size) + ":" +
                str(args.generation) + ":" + source_record["sha256"]).encode()
        cookie = int.from_bytes(hashlib.sha256(seed).digest()[:8], "little")
        require(cookie != 0, f"zero cookie: {role}")
        off = 256 + 32 * index
        put32(binding, off, role_id)
        put32(binding, off + 4, 1)
        put64(binding, off + 8, base)
        put64(binding, off + 16, size)
        put64(binding, off + 24, cookie)
        bo_records.append({"role": role, "role_id": role_id, "flags": 1,
                           "base": base, "bytes": size, "cookie": cookie,
                           "source": source_record})
    require(len({x["cookie"] for x in bo_records}) == len(bo_records),
            "duplicate BO cookie")
    for i, (base, size) in enumerate(ranges):
        for other_base, other_size in ranges[i + 1:]:
            require(base + size <= other_base or other_base + other_size <= base,
                    "overlapping physical BO regions")
    assert struct.unpack_from("<I", binding, 224)[0] == 5
    assert struct.unpack_from("<I", binding, 228)[0] == 32
    assert struct.unpack_from("<I", binding, 232)[0] == 18

    validation = {
        "schema": "lnq0-finite-w-binding-v1", "manifest_sha256": sha(manifest_path),
        "GGUF_sha256": manifest["source_model"]["sha256"],
        "tags": manifest["tags"], "generation": args.generation,
        "bo": [{k: r[k] for k in ("role", "role_id", "flags", "base", "bytes",
                                     "cookie")} | {"sha256": r["source"]["sha256"]}
               for r in bo_records],
    }
    validation_raw = json.dumps(validation, sort_keys=True,
                                separators=(",", ":")).encode()
    validation_sha = hashlib.sha256(validation_raw).digest()
    binding[80:96] = validation_sha[:16]
    binding[96:128] = validation_sha
    binding[128:160] = bytes.fromhex(sha(manifest_path))
    binding[160:192] = bytes.fromhex(manifest["tag_preimages"]["build"]["sha256"])
    binding[192:224] = bytes.fromhex(manifest["source_model"]["sha256"])
    require(binding[48:64] == binding[160:176] and
            struct.unpack_from("<I", binding, 64)[0] == 0 and
            struct.unpack_from("<Q", binding, 72)[0] == args.generation,
            "strict-W encoding invalid")
    out.mkdir(parents=True)
    write_words(out / "model_identity.hex", binding, 416)
    header = (prod / "aux.bin").open("rb").read(128)
    require(len(header) == 128 and
            hashlib.sha256(header).hexdigest() ==
            prior["AUX"]["canonical_header_sha256"], "AUX header drift")
    write_words(out / "expected_aux_header.hex", header, 128)
    write_words(out / "aux_header.hex", header, 16)
    sv = [
        "`timescale 1ns/1ps",
        "// Generated from the checked canonical package for one LNQ0 simulation.",
        "// This finite address binding is not production Q8S2 registration.",
        "package laya_lnq0_bound_identity_generated_v1;",
        f"  localparam logic [3327:0] W_IDENTITY=3328'h{int.from_bytes(binding, 'little'):0832x};",
        f"  localparam logic [1023:0] AUX_HEADER=1024'h{int.from_bytes(header, 'little'):0256x};",
        f"  localparam logic [63:0] BINDING_GENERATION=64'd{args.generation};",
    ]
    for role, _, base in BO:
        size = manifest["bo"][role]["size"]
        sv.append(f"  localparam logic [63:0] {role.upper()}_BASE=64'h{base:016x};")
        sv.append(f"  localparam logic [63:0] {role.upper()}_BYTES=64'd{size};")
    sv += ["endpackage", ""]
    (out / "laya_lnq0_bound_identity_generated_v1.sv").write_text("\n".join(sv))
    (out / "validation_record.json").write_bytes(validation_raw + b"\n")
    report = {"schema": "lnq0-bound-identity-host-v1",
              "status": "PASS_HOST_ONLY", "model_identity_sha256":
                  hashlib.sha256(binding).hexdigest(),
              "scope": "one finite simulation address table; hardware adaptation NOT_RUN",
              "production_manifest": record(manifest_path),
              "AT041_report": record(prior_path),
              "AT041_template": record(template_path),
              "BO": bo_records,
              "validation_sha256": validation_sha.hex(),
              "outputs": [record(p) for p in sorted(out.iterdir())],
              "not_verified": ["live DUT BO binding", "Q8S2 registration",
                               "LNQ0 RTL", "production 13BO"]}
    (out / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print("LNQ0_BOUND_IDENTITY_HOST_PASS bo=5 regions=7", flush=True)


if __name__ == "__main__":
    main()
