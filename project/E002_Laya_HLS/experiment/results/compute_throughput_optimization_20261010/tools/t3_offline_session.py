#!/usr/bin/env python3
"""Portable T3 model-session gate; the endpoint is memory, not XRT/HBM."""
from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
import hashlib
import json
from pathlib import Path
import time
from types import MappingProxyType
from typing import Mapping

from t3_static_model import BO_ROLES, PackageError, digest_bytes, package_file, validate


PROFILE = 'VALIDATED_STATIC_MODEL_V1'
U64_MAX = (1 << 64) - 1


class State(str, Enum):
    EMPTY = 'EMPTY'
    PACKAGE_CHECKED = 'PACKAGE_CHECKED'
    UPLOADED = 'UPLOADED'
    READBACK_VERIFIED = 'READBACK_VERIFIED'
    ACTIVE = 'ACTIVE'
    INVALID = 'INVALID'


@dataclass(frozen=True)
class Candidate:
    """Explicit package tags plus the currently selected kernel source hash."""
    tags: Mapping[str, str]
    kernel_sha256: str

    def __post_init__(self) -> None:
        if set(self.tags) != {'model', 'numeric', 'layout', 'build'} or any(
            len(value) != 32 or not _hex(value) for value in self.tags.values()
        ) or len(self.kernel_sha256) != 64 or not _hex(self.kernel_sha256):
            raise PackageError('incomplete candidate identity')
        object.__setattr__(self, 'tags', MappingProxyType(dict(self.tags)))


def _hex(value: str) -> bool:
    try:
        bytes.fromhex(value)
        return True
    except ValueError:
        return False


def _stamp(path: Path) -> tuple[int, int, int, int]:
    info = path.stat()
    return (info.st_dev, info.st_ino, info.st_size, info.st_mtime_ns)


class MemoryEndpoint:
    """Byte-exact BO endpoint with allocation and upload-event identity."""

    def __init__(self) -> None:
        self.bos: dict[str, bytearray] = {}
        self.allocations: dict[str, str] = {}
        self.events: list[dict] = []
        self.next_allocation = 1
        self.next_event = 1
        self.sealed = False
        self.on_mutation = None

    def _require_writable(self) -> None:
        if self.sealed:
            if self.on_mutation is not None:
                self.on_mutation()
            raise PackageError('ACTIVE model BO is read-only')

    def allocate(self, role: str, size: int) -> str:
        self._require_writable()
        allocation = f'memory-allocation-{self.next_allocation}'
        self.next_allocation += 1
        self.bos[role] = bytearray(size)
        self.allocations[role] = allocation
        return allocation

    def upload_and_sync(self, role: str, data: bytes) -> dict:
        self._require_writable()
        if role not in self.bos or len(self.bos[role]) != len(data):
            raise PackageError(f'{role} missing or wrong-sized allocation')
        self.bos[role][:] = data
        event = {'id': self.next_event, 'role': role, 'offset': 0,
                 'bytes': len(data), 'completed': True}
        self.next_event += 1
        self.events.append(event)
        return event.copy()

    def readback(self, role: str, offset: int, size: int) -> bytes:
        bo = self.bos[role]
        if offset < 0 or size < 0 or offset + size > len(bo):
            raise PackageError(f'{role} readback range')
        return bytes(bo[offset:offset + size])

    def reset(self, *, internal: bool = False) -> None:
        if self.sealed and not internal:
            if self.on_mutation is not None:
                self.on_mutation()
            return
        self.sealed = False
        self.on_mutation = None
        self.bos.clear()
        self.allocations.clear()
        self.events.clear()

    def seal(self, on_mutation) -> None:
        self.sealed = True
        self.on_mutation = on_mutation

    def host_write(self, role: str, offset: int, data: bytes) -> None:
        self._require_writable()
        if offset < 0 or offset + len(data) > len(self.bos[role]):
            raise PackageError(f'{role} write range')
        self.bos[role][offset:offset + len(data)] = data


class StaticModelSession:
    def __init__(self, package: Path, candidate: Candidate, *, device: str,
                 context: str, endpoint: MemoryEndpoint) -> None:
        if not device or not context:
            raise PackageError('device and context identities are required')
        self.package = package.resolve()
        self.candidate = candidate
        self.device = device
        self.context = context
        self.endpoint = endpoint
        self.state = State.EMPTY
        self.generation = 0
        self.cache_epoch = 0
        self.record: dict | None = None
        self.record_sha256: str | None = None
        self.session_record: dict | None = None
        self.snapshot: dict[str, bytes] = {}
        self.source_stamps: dict[str, tuple[int, int, int, int]] = {}
        self.allocations: dict[str, str] = {}
        self.events: dict[str, dict] = {}
        self.upload_event_count = 0
        self.readback_hashes: dict[str, str] = {}
        self.cost_seconds: dict[str, float] = {}
        self.scale_scan_count = 0

    def _fail(self, reason: str) -> None:
        self.invalidate(reason)
        raise PackageError(reason)

    def invalidate(self, reason: str) -> None:
        if self.generation == U64_MAX:
            raise PackageError('session generation exhausted')
        self.generation += 1
        self.state = State.INVALID
        self.session_record = None
        self.allocations.clear()
        self.events.clear()
        self.upload_event_count = 0
        self.readback_hashes.clear()
        self.snapshot.clear()
        self.source_stamps.clear()
        self.endpoint.reset(internal=True)
        self.invalid_reason = reason

    def _source_unchanged(self) -> bool:
        return self._source_unchanged_with(self.source_stamps)

    def prepare(self, record_path: Path) -> dict:
        if self.state not in (State.EMPTY, State.INVALID):
            self._fail('prepare requires an empty or invalid session')
        try:
            started = time.perf_counter()
            result = validate(self.package)
            self.scale_scan_count += 1
            if result['profile'] != PROFILE or result['tags'] != dict(self.candidate.tags):
                self._fail('candidate tags differ from validated package')
            manifest = self.package / 'manifest.json'
            stamps = {'manifest.json': _stamp(manifest)}
            for item in result['tag_preimages'].values():
                path = package_file(self.package, item['file'])
                stamps[path.relative_to(self.package).as_posix()] = _stamp(path)
            source = Path(json.loads(manifest.read_bytes())['source_model']['path'])
            stamps[str(source)] = _stamp(source)
            snapshot: dict[str, bytes] = {}
            for role in BO_ROLES:
                item = result['bos'][role]
                path = package_file(self.package, item['file'])
                relative = path.relative_to(self.package).as_posix()
                before = _stamp(path)
                data = path.read_bytes()
                after = _stamp(path)
                if before != after or len(data) != item['bytes'] or (
                    digest_bytes(data) != item['sha256']
                ):
                    self._fail(f'{role} changed while preparing immutable snapshot')
                stamps[relative] = after
                snapshot[role] = data
            if _stamp(manifest) != stamps['manifest.json'] or (
                digest_bytes(manifest.read_bytes()) != result['manifest_sha256']
            ):
                self._fail('manifest changed while preparing snapshot')
            if not all(digest_bytes(package_file(self.package, item['file']).read_bytes()) ==
                       item['sha256'] for item in result['tag_preimages'].values()):
                self._fail('tag preimage changed while preparing snapshot')
            if not self._source_unchanged_with(stamps):
                self._fail('package source changed while preparing snapshot')
            self.record = result
            raw = (json.dumps(result, indent=2, sort_keys=True) + '\n').encode()
            record_path.parent.mkdir(parents=True, exist_ok=True)
            record_path.write_bytes(raw)
            self.record_sha256 = digest_bytes(raw)
            self.snapshot = snapshot
            self.source_stamps = stamps
            if self.state == State.EMPTY:
                self.generation = 1
            self.state = State.PACKAGE_CHECKED
            self.cost_seconds['cold_prepare_total'] = time.perf_counter() - started
            return {'record': str(record_path.resolve()),
                    'record_sha256': self.record_sha256,
                    'generation': self.generation,
                    'scale_scan_count': self.scale_scan_count}
        except Exception:
            if self.state != State.INVALID:
                self.invalidate('package preparation failed')
            raise

    def _source_unchanged_with(self, stamps: Mapping[str, tuple[int, int, int, int]]) -> bool:
        try:
            return all(_stamp(self.package / name) == stamp
                       for name, stamp in stamps.items())
        except OSError:
            return False

    def upload(self) -> None:
        if self.state != State.PACKAGE_CHECKED:
            self._fail('upload requires PACKAGE_CHECKED')
        if not self._source_unchanged():
            self._fail('model package changed before upload')
        started = time.perf_counter()
        try:
            assert self.record is not None
            for role in BO_ROLES:
                if digest_bytes(self.snapshot[role]) != self.record['bos'][role]['sha256']:
                    self._fail(f'{role} immutable snapshot changed before upload')
                self.allocations[role] = self.endpoint.allocate(role, len(self.snapshot[role]))
                self.events[role] = self.endpoint.upload_and_sync(role, self.snapshot[role])
                if not self.events[role]['completed'] or (
                    self.events[role]['bytes'] != self.record['bos'][role]['bytes']
                ):
                    self._fail(f'{role} upload completion/range')
            self.upload_event_count = len(self.endpoint.events)
            self.state = State.UPLOADED
            self.cost_seconds['upload_and_sync'] = time.perf_counter() - started
        except Exception:
            if self.state != State.INVALID:
                self.invalidate('upload failed')
            raise

    def verify_readback(self) -> None:
        if self.state != State.UPLOADED:
            self._fail('readback requires all uploads')
        if not self._source_unchanged():
            self._fail('model package changed before readback')
        started = time.perf_counter()
        try:
            for role in BO_ROLES:
                size = len(self.snapshot[role])
                if self.endpoint.allocations.get(role) != self.allocations[role]:
                    self._fail(f'{role} allocation changed')
                read = self.endpoint.readback(role, 0, size)
                if len(read) != size:
                    self._fail(f'{role} incomplete readback')
                actual = digest_bytes(read)
                if actual != digest_bytes(self.snapshot[role]) or (
                    actual != self.record['bos'][role]['sha256']
                ):
                    self._fail(f'{role} readback SHA256 mismatch')
                self.readback_hashes[role] = actual
            if not self._endpoint_binding_unchanged():
                self._fail('model allocation or upload event changed during readback')
            # The verified bytes must stay immutable until activation. A public
            # endpoint mutation now revokes this generation even in this gap.
            self.endpoint.seal(self.model_changed)
            self.state = State.READBACK_VERIFIED
            self.cost_seconds['readback_verify'] = time.perf_counter() - started
        except Exception:
            if self.state != State.INVALID:
                self.invalidate('readback failed')
            raise

    def activate(self) -> dict:
        if self.state != State.READBACK_VERIFIED:
            self._fail('activation requires complete readback verification')
        if not self._source_unchanged():
            self._fail('model package changed before activation')
        if not self.endpoint.sealed or not self._endpoint_binding_unchanged():
            self._fail('verified model endpoint changed before activation')
        assert self.record is not None and self.record_sha256 is not None
        self.session_record = {
            'schema': 'laya-validated-static-session-v1', 'status': 'ACTIVE',
            'profile': PROFILE, 'session_generation': self.generation,
            'cache_epoch': self.cache_epoch, 'device': self.device,
            'context': self.context, 'kernel_sha256': self.candidate.kernel_sha256,
            'tags': dict(self.candidate.tags),
            'manifest_sha256': self.record['manifest_sha256'],
            'validation_record_sha256': self.record_sha256,
            'bos': {role: {'allocation': self.allocations[role], 'offset': 0,
                           'bytes': len(self.snapshot[role]),
                           'upload_event': self.events[role],
                           'readback_sha256': self.readback_hashes[role]}
                    for role in BO_ROLES}}
        self.state = State.ACTIVE
        return self.session_record.copy()

    def _endpoint_binding_unchanged(self) -> bool:
        return self.endpoint.allocations == self.allocations and (
            len(self.endpoint.events) == self.upload_event_count and
            self.endpoint.events[-len(BO_ROLES):] ==
            [self.events[role] for role in BO_ROLES]
        )

    def authorize_load(self, *, profile: str, generation: int,
                       candidate: Candidate, record_sha256: str,
                       allocations: Mapping[str, str], weight_key: tuple[int, int],
                       K: int, N: int, cache_epoch: int) -> bool:
        if self.state != State.ACTIVE or not self._source_unchanged():
            if self.state == State.ACTIVE:
                self.invalidate('model package changed during ACTIVE session')
            return False
        if profile != PROFILE or generation != self.generation or (
            candidate != self.candidate or record_sha256 != self.record_sha256 or
            dict(allocations) != self.allocations or cache_epoch != self.cache_epoch
        ):
            return False
        if not self.endpoint.sealed or not self._endpoint_binding_unchanged():
            self.invalidate('allocation or upload identity changed during ACTIVE session')
            return False
        assert self.record is not None
        return any(tuple(item['WeightKey']) == weight_key and item['K'] == K and
                   item['N'] == N for item in self.record['matrices'])

    def warm_reuse(self) -> dict:
        if self.state != State.ACTIVE or not self._source_unchanged():
            self._fail('warm reuse requires unchanged ACTIVE session')
        assert self.session_record is not None
        return {'session_generation': self.generation,
                'scale_scan_count': self.scale_scan_count,
                'validation_record_sha256': self.record_sha256}

    def reset(self) -> None:
        self.invalidate('device reset/context invalidation')

    def model_changed(self) -> None:
        self.invalidate('model, tag, BO, or address changed')
