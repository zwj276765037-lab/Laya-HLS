#!/usr/bin/env python3
"""Small byte-range/state tests; real 122-matrix run is a separate guarded case."""
from __future__ import annotations

import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from t3_offline_session import Candidate, MemoryEndpoint, PROFILE, State, StaticModelSession
from t3_static_model import BO_ROLES, PackageError, digest_bytes


TAGS = {name: f'{n:02x}' * 16 for n, name in
        enumerate(('model', 'numeric', 'layout', 'build'), 1)}
CANDIDATE = Candidate(TAGS, 'ab' * 32)


class TruncatedUpload(MemoryEndpoint):
    def upload_and_sync(self, role: str, data: bytes) -> dict:
        event = super().upload_and_sync(role, data)
        if role == 'w_scale':
            self.bos[role][-1] ^= 1
        return event


class SyncWithoutReadback(MemoryEndpoint):
    def readback(self, role: str, offset: int, size: int) -> bytes:
        raise PackageError('readback was not performed')


class SessionTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.package = Path(self.temp.name)
        source = self.package / 'source.gguf'
        source.write_bytes(b'GGUF fixture identity')
        (self.package / 'manifest.json').write_text(json.dumps({
            'source_model': {'path': str(source)}}))
        self.preimages = {}
        for name in ('numeric', 'layout', 'build'):
            file = f'{name}.txt'
            content = name.encode()
            (self.package / file).write_bytes(content)
            self.preimages[name] = {'file': file, 'sha256': digest_bytes(content)}
        self.bos = {}
        for index, role in enumerate(BO_ROLES):
            content = bytes([index + 1]) * (index + 3)
            file = f'{role}.bin'
            (self.package / file).write_bytes(content)
            self.bos[role] = {'file': file, 'bytes': len(content),
                              'sha256': digest_bytes(content)}
        self.validated = {'schema': 'laya-validated-static-model-v1',
                          'profile': PROFILE, 'status': 'PASS', 'tags': TAGS,
                          'manifest_sha256': digest_bytes(
                              (self.package / 'manifest.json').read_bytes()),
                          'tag_preimages': self.preimages, 'bos': self.bos,
                          'matrices': [{'WeightKey': [4, 0], 'K': 32, 'N': 7}]}
        self.validate_patch = patch('t3_offline_session.validate',
                                    return_value=self.validated)
        self.validate_patch.start()
        self.addCleanup(self.validate_patch.stop)

    def new_session(self, endpoint: MemoryEndpoint | None = None) -> StaticModelSession:
        return StaticModelSession(self.package, CANDIDATE, device='device0',
                                  context='context0', endpoint=endpoint or MemoryEndpoint())

    def prepare(self, session: StaticModelSession) -> None:
        session.prepare(self.package / 'record.json')

    def active(self) -> StaticModelSession:
        session = self.new_session()
        self.prepare(session)
        session.upload()
        session.verify_readback()
        session.activate()
        return session

    def request(self, session: StaticModelSession, **changes) -> bool:
        args = {'profile': PROFILE, 'generation': session.generation,
                'candidate': CANDIDATE, 'record_sha256': session.record_sha256,
                'allocations': session.allocations.copy(), 'weight_key': (4, 0),
                'K': 32, 'N': 7, 'cache_epoch': session.cache_epoch}
        args.update(changes)
        return session.authorize_load(**args)

    def test_complete_path_and_warm_reuse(self) -> None:
        session = self.active()
        self.assertEqual(session.state, State.ACTIVE)
        self.assertTrue(self.request(session))
        before = session.scale_scan_count
        warm = session.warm_reuse()
        self.assertEqual(warm['scale_scan_count'], before)
        self.assertEqual(warm['session_generation'], session.generation)
        self.assertEqual(len(session.session_record['bos']), 5)

    def test_no_unverified_or_mismatched_request(self) -> None:
        session = self.new_session()
        self.prepare(session)
        self.assertFalse(self.request(session))
        session.upload()
        self.assertFalse(self.request(session))
        session.verify_readback()
        self.assertFalse(self.request(session))
        session.activate()
        for change in ({'generation': 0}, {'profile': 'STRICT'},
                       {'record_sha256': '00' * 32},
                       {'allocations': {'w_scale': 'forged'}},
                       {'weight_key': (5, 0)}, {'K': 64}, {'N': 8},
                       {'cache_epoch': 1}):
            with self.subTest(change=change):
                self.assertFalse(self.request(session, **change))

    def test_snapshot_changed_before_upload(self) -> None:
        session = self.new_session()
        self.prepare(session)
        (self.package / 'w_scale.bin').write_bytes(b'changed')
        with self.assertRaises(PackageError):
            session.upload()
        self.assertEqual(session.state, State.INVALID)

    def test_snapshot_bytes_changed_before_upload(self) -> None:
        session = self.new_session()
        self.prepare(session)
        session.snapshot['w_scale'] = b'forged'
        with self.assertRaises(PackageError):
            session.upload()
        self.assertEqual(session.state, State.INVALID)

    def test_tag_changed_after_activation(self) -> None:
        session = self.active()
        (self.package / 'numeric.txt').write_bytes(b'changed')
        self.assertFalse(self.request(session))
        self.assertEqual(session.state, State.INVALID)

    def test_active_bo_write_and_reallocation_revoke_session(self) -> None:
        for action in ('write', 'reallocate', 'reupload', 'reset'):
            with self.subTest(action=action):
                session = self.active()
                old_generation = session.generation
                if action == 'reset':
                    session.endpoint.reset()
                else:
                    with self.assertRaises(PackageError):
                        if action == 'write':
                            session.endpoint.host_write('w_scale', 0, b'\x00')
                        elif action == 'reallocate':
                            session.endpoint.allocate('w_scale', len(session.snapshot['w_scale']))
                        else:
                            session.endpoint.upload_and_sync('w_scale', session.snapshot['w_scale'])
                self.assertEqual(session.state, State.INVALID)
                self.assertGreater(session.generation, old_generation)

    def test_verified_readback_is_sealed_before_activation(self) -> None:
        for action in ('reupload', 'write', 'reallocate', 'reset'):
            with self.subTest(action=action):
                session = self.new_session()
                self.prepare(session)
                session.upload()
                session.verify_readback()
                old_generation = session.generation
                if action == 'reset':
                    session.endpoint.reset()
                else:
                    with self.assertRaises(PackageError):
                        if action == 'reupload':
                            damaged = bytes([session.snapshot['w_scale'][0] ^ 1]) + (
                                session.snapshot['w_scale'][1:])
                            session.endpoint.upload_and_sync('w_scale', damaged)
                        elif action == 'write':
                            session.endpoint.host_write('w_scale', 0, b'\x00')
                        else:
                            session.endpoint.allocate('w_scale', len(session.snapshot['w_scale']))
                self.assertEqual(session.state, State.INVALID)
                self.assertGreater(session.generation, old_generation)
                with self.assertRaises(PackageError):
                    session.activate()
                self.assertFalse(self.request(session, generation=old_generation))

    def test_readback_rejects_unrecorded_reupload_event(self) -> None:
        session = self.new_session()
        self.prepare(session)
        session.upload()
        session.endpoint.upload_and_sync('w_scale', session.snapshot['w_scale'])
        with self.assertRaisesRegex(PackageError, 'upload event changed'):
            session.verify_readback()
        self.assertEqual(session.state, State.INVALID)

    def test_corrupt_tail_and_sync_only_fail_readback(self) -> None:
        for endpoint in (TruncatedUpload(), SyncWithoutReadback()):
            with self.subTest(endpoint=type(endpoint).__name__):
                session = self.new_session(endpoint)
                self.prepare(session)
                session.upload()
                with self.assertRaises(PackageError):
                    session.verify_readback()
                self.assertEqual(session.state, State.INVALID)

    def test_reset_invalidates_handles_and_full_revalidation_recovers(self) -> None:
        session = self.active()
        old_generation = session.generation
        old_allocations = session.allocations.copy()
        session.reset()
        self.assertFalse(self.request(session, generation=old_generation,
                                      allocations=old_allocations))
        self.prepare(session)
        session.upload()
        session.verify_readback()
        session.activate()
        self.assertGreater(session.generation, old_generation)
        self.assertNotEqual(session.allocations, old_allocations)
        self.assertEqual(session.scale_scan_count, 2)
        self.assertTrue(self.request(session))


if __name__ == '__main__':
    unittest.main()
