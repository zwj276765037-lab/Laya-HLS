#!/usr/bin/env python3
"""Run the actual eight-bank join from immutable exports and graph tables."""
import json
from pathlib import Path
import sys
from join_funcsim_graph import bind

graph = Path(sys.argv[1]).resolve()
output = Path(sys.argv[2]).resolve()
if output.exists():
    raise SystemExit('fresh output required')
result = bind(graph, graph/'funcsim')
payload = (json.dumps(result, indent=2, sort_keys=True)+'\n').encode()
if len(payload) > 64*1024*1024:
    raise SystemExit('actual join output exceeds 64 MiB')
output.write_bytes(payload)
if len(result['per_bank']) != 8 or any(not bank['parent_constant_boundary_environment'] for bank in result['per_bank']):
    raise SystemExit('actual parent-constant boundary evidence incomplete')
print('WS_ACTUAL_JOIN_PASS banks=8 semantic_properties='+str(result['semantic_property_count'])+
      ' bytes='+str(len(payload)))
