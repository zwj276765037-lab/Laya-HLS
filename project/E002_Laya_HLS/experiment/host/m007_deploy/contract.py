"""Versioned little-endian Host codec driven only by schema.json.

This schema is a Host/RTL handoff, not an XRT register map. Metadata and the
69632-byte data payload are separate; payload size excludes control metadata.
"""
from __future__ import annotations

from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import struct

SCHEMA_PATH = Path(__file__).with_name("schema.json")
SCHEMA_RAW = SCHEMA_PATH.read_bytes()
SCHEMA = json.loads(SCHEMA_RAW)
CONSTANTS = SCHEMA["constants"]
FORMATS = {"u8": "B", "u16": "H", "u32": "I", "u64": "Q", "i32": "i"}
OFFSETS: dict[str, int] = {}
_offset = 0
for _name, _kind, _count in SCHEMA["fields"]:
    OFFSETS[_name] = _offset
    _offset += _count if _kind == "bytes" else struct.calcsize(FORMATS[_kind]) * _count
if _offset != SCHEMA["metadata_bytes"] or _offset > 4096:
    raise RuntimeError("schema size disagreement")
SCHEMA_SHA256 = hashlib.sha256(SCHEMA_RAW).hexdigest()
IDENTITY_NAMES = ("model", "graph", "numeric", "layout", "build")


class ContractError(ValueError):
    pass


class DeviceResultError(ContractError):
    """A real completion reported a failed Check or incomplete data retirement."""


def _uint(value: int, width: int, name: str) -> None:
    if type(value) is not int or not 0 <= value < (1 << width):
        raise ContractError(f"{name}: unsigned {width}-bit domain")


@dataclass(frozen=True)
class Identity:
    model: str
    graph: str
    numeric: str
    layout: str
    build: str

    def validate(self) -> None:
        for name in IDENTITY_NAMES:
            value = getattr(self, name)
            if (not isinstance(value, str) or len(value) != 64 or
                    any(c not in "0123456789abcdef" for c in value) or
                    value == "0" * 64):
                raise ContractError(name + ": nonzero lowercase SHA256 required")


@dataclass(frozen=True)
class BufferRegion:
    address: int
    span: int

    def end(self) -> int:
        _uint(self.address, 64, "address")
        _uint(self.span, 64, "span")
        if not self.span or self.address > (1 << 64) - 1 - self.span:
            raise ContractError("empty span or address+span overflow")
        return self.address + self.span

    def contains(self, other: "BufferRegion") -> bool:
        return self.address <= other.address and other.end() <= self.end()


@dataclass(frozen=True)
class Request:
    request_id: int
    generation: int
    identity: Identity
    qtype: int
    attention_mask: tuple[int, ...]
    markers: tuple[int, ...]
    marker_mask: tuple[int, ...]
    candidate_count: int
    h0_address: int
    tail_address: int
    h0_span: int = CONSTANTS["H0_BYTES"]
    tail_span: int = CONSTANTS["TAIL_BYTES"]

    def __post_init__(self):
        # Own immutable copies: caller list mutation must never change an in-flight
        # request, and decoded tuple fields must compare with constructor inputs.
        for name in ("attention_mask", "markers", "marker_mask"):
            object.__setattr__(self, name, tuple(getattr(self, name)))

    def validate(self, h0_region: BufferRegion | None = None,
                 tail_region: BufferRegion | None = None) -> None:
        _uint(self.request_id, 64, "request_id")
        _uint(self.generation, 32, "generation")
        self.identity.validate()
        if type(self.qtype) is not int or self.qtype not in SCHEMA["rules"]["qtype"]:
            raise ContractError("qtype: expected 0, 1 or 2")
        for name, values, size in (("attention_mask", self.attention_mask, 128),
                                   ("marker_mask", self.marker_mask, 16)):
            if (len(values) != size or any(type(v) is not int or v not in (0, 1)
                                          for v in values) or not any(values)):
                raise ContractError(name + ": exact binary nonempty mask")
        if (type(self.candidate_count) is not int or
                not 1 <= self.candidate_count <= 16 or
                self.candidate_count != sum(self.marker_mask)):
            raise ContractError("candidate_count: exact marker_mask sum in 1..16")
        minimum, maximum = SCHEMA["rules"]["candidate_counts_by_qtype"][str(self.qtype)]
        if not minimum <= self.candidate_count <= maximum:
            raise ContractError("qtype/candidate_count violates original business option count")
        if len(self.markers) != 16:
            raise ContractError("markers: expected 16 slots")
        for position, active in zip(self.markers, self.marker_mask):
            if type(position) is not int or not -(1 << 31) <= position < (1 << 31):
                raise ContractError("marker: signed 32-bit domain")
            if active:
                if not 0 <= position < 128 or self.attention_mask[position] != 1:
                    raise ContractError("active marker outside unmasked S128")
            elif position != 0:
                raise ContractError("inactive marker must map to CLS row zero")
        if self.h0_span != CONSTANTS["H0_BYTES"] or self.tail_span != CONSTANTS["TAIL_BYTES"]:
            raise ContractError("H0/tail span must match exact fixed frame size")
        a = BufferRegion(self.h0_address, self.h0_span)
        b = BufferRegion(self.tail_address, self.tail_span)
        ae, be = a.end(), b.end()
        if (not a.address or not b.address or a.address % 64 or b.address % 64):
            raise ContractError("nonzero 64-byte aligned address required")
        if a.address < be and b.address < ae:
            raise ContractError("H0/tail overlap")
        if h0_region is not None and not h0_region.contains(a):
            raise ContractError("H0 outside BO region")
        if tail_region is not None and not tail_region.contains(b):
            raise ContractError("tail outside BO region")


def canonical_request(*, markers, marker_mask, **values) -> Request:
    """Explicit frontend normalization: inactive slots map to CLS; no truncation."""
    positions, mask = tuple(markers), tuple(marker_mask)
    if len(positions) != 16 or len(mask) != 16:
        raise ContractError("frontend requires exactly 16 candidate slots")
    request = Request(markers=tuple(p if m else 0 for p, m in zip(positions, mask)),
                      marker_mask=mask, **values)
    request.validate()
    return request


def _encode(request: Request, kind: int, status: int, completed: int) -> bytes:
    request.validate()
    _uint(status, 32, "status")
    _uint(completed, 32, "completed_elements")
    values = dict(vars(request))
    values.pop("identity")
    values.update({name: bytes.fromhex(getattr(request.identity, name))
                   for name in IDENTITY_NAMES})
    values.update(magic=bytes.fromhex(SCHEMA["magic_hex"]), version=SCHEMA["version"],
                  metadata_bytes=SCHEMA["metadata_bytes"], kind=kind, status=status,
                  completed_elements=completed, reserved0=bytes(4), reserved1=bytes(64))
    output = bytearray(SCHEMA["metadata_bytes"])
    for name, field_type, count in SCHEMA["fields"]:
        value = values[name]
        if field_type == "bytes":
            if len(value) != count:
                raise ContractError(name + ": wrong byte count")
            output[OFFSETS[name]:OFFSETS[name] + count] = value
        else:
            struct.pack_into("<" + FORMATS[field_type] * count, output, OFFSETS[name],
                             *(value if count > 1 else (value,)))
    return bytes(output)


def encode_request(request: Request) -> bytes:
    return _encode(request, CONSTANTS["REQUEST"], 0, 0)


def decode_metadata(data: bytes, expected_identity: Identity) -> tuple[Request, int, int, int]:
    if len(data) != SCHEMA["metadata_bytes"]:
        raise ContractError("metadata frame length")
    values = {}
    for name, kind, count in SCHEMA["fields"]:
        offset = OFFSETS[name]
        values[name] = (data[offset:offset + count] if kind == "bytes" else
                        struct.unpack_from("<" + FORMATS[kind] * count, data, offset))
        if kind != "bytes" and count == 1:
            values[name] = values[name][0]
    if (values.pop("magic") != bytes.fromhex(SCHEMA["magic_hex"]) or
            values.pop("version") != SCHEMA["version"] or
            values.pop("metadata_bytes") != len(data)):
        raise ContractError("metadata magic/version/size")
    if any(values.pop("reserved0")) or any(values.pop("reserved1")):
        raise ContractError("reserved metadata bytes must be zero")
    identity = Identity(**{name: values.pop(name).hex() for name in IDENTITY_NAMES})
    expected_identity.validate()
    if identity != expected_identity:
        raise ContractError("model/graph/numeric/layout/build identity mismatch")
    kind, status, completed = (values.pop(name) for name in
                               ("kind", "status", "completed_elements"))
    if kind not in (CONSTANTS["REQUEST"], CONSTANTS["TAIL_READY"]):
        raise ContractError("unknown metadata kind")
    request = Request(identity=identity, **values)
    request.validate()
    if kind == CONSTANTS["REQUEST"] and (status or completed):
        raise ContractError("request has nonzero status/completion")
    return request, kind, status, completed


def decode_request(data: bytes, expected_identity: Identity) -> Request:
    request, kind, _, _ = decode_metadata(data, expected_identity)
    if kind != CONSTANTS["REQUEST"]:
        raise ContractError("expected request frame")
    return request


def validate_tail_ready(metadata: bytes, payload: bytes, expected: Request) -> bytes:
    request, kind, status, completed = decode_metadata(metadata, expected.identity)
    if request != expected or kind != CONSTANTS["TAIL_READY"]:
        raise ContractError("stale/wrong request or generation; TAIL_READY required")
    if status or completed != CONSTANTS["TAIL_ELEMENTS"]:
        raise DeviceResultError(f"failed/incomplete device result: status={status}, elements={completed}")
    if len(payload) != CONSTANTS["TAIL_BYTES"]:
        raise ContractError("tail payload length")
    return payload
