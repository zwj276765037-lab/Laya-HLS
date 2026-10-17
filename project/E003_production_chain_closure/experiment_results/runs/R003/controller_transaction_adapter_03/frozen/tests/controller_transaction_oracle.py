#!/usr/bin/env python3
"""Independent byte-layout checks for the sequencer/adapter transaction schema."""
import argparse
from pathlib import Path


def u(data, offset, size):
    return int.from_bytes(data[offset:offset + size], 'little')


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--fixture', type=Path, required=True)
    args = parser.parse_args()
    names = ('compute', 'provenance', 'producer')
    request_magic = int.from_bytes(b'LTX1', 'little')
    completion_magic = int.from_bytes(b'LTC1', 'little')
    for kind, name in enumerate(names, 1):
        request = (args.fixture / f'{name}_request.bin').read_bytes()
        completion = (args.fixture / f'{name}_completion.bin').read_bytes()
        require(len(request) == 1536, f'{name} request size')
        require(len(completion) == 1024, f'{name} completion size')
        require(u(request, 0, 4) == request_magic and
                u(request, 4, 2) == 1 and u(request, 6, 2) == 24,
                f'{name} request header')
        require(u(completion, 0, 4) == completion_magic and
                u(completion, 4, 2) == 1 and u(completion, 6, 2) == 16,
                f'{name} completion header')
        require(u(request, 8, 2) == kind and
                u(completion, 8, 2) == kind, f'{name} kind')
        require(request[12:16] == bytes(4) and
                request[36:64] == bytes(28), f'{name} common reserved')
        require(completion[52:56] == bytes(4),
                f'{name} completion reserved')
        require(request[84:148] == completion[92:156],
                f'{name} identity tags')
    compute = (args.fixture / 'compute_request.bin').read_bytes()
    provenance = (args.fixture / 'provenance_request.bin').read_bytes()
    producer = (args.fixture / 'producer_request.bin').read_bytes()
    require(compute[976:] == bytes(1536 - 976), 'compute tail reserved')
    require(provenance[1008:] == bytes(1536 - 1008),
            'provenance tail reserved')
    require(producer[664:] == bytes(1536 - 664), 'producer tail reserved')
    require(u(producer, 612, 4) == 4096, 'producer row bytes')
    require(u(provenance, 579, 1) == 1 and
            provenance[752:880] == bytes(128) and
            provenance[944:1008] == bytes(64),
            'unused second provenance descriptor')
    print('FULL_CURRENT_CONTROLLER_TRANSACTION_ORACLE_PASS '
          'kinds=3 request_bytes=1536 completion_bytes=1024')


if __name__ == '__main__':
    main()
