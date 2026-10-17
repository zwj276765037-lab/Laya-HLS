#!/usr/bin/env python3
import json, sys, hashlib, traceback
from pathlib import Path
manifest=Path(sys.argv[2])
bindings=json.loads(manifest.read_text())
for r in bindings:
 p=Path(r['path']);h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 if p.stat().st_size != r['bytes'] or h.hexdigest()!=r['sha256']:raise ValueError('frozen input drift: '+str(p))
if sys.argv[1]=='check':
 print('WS_V7_JOIN_BINDINGS_OK count='+str(len(bindings)));raise SystemExit(0)
if sys.argv[1]!='run' or len(sys.argv)!=6:raise ValueError('exact invocation required')
source,graph,out=map(Path,sys.argv[3:6])
if out.exists():raise ValueError('output must be absent')
out.mkdir(parents=True)
(out/'attempt.json').write_text(json.dumps({'maximum_invocations':1,'scope':'actual structure and explicit parameter join only','input_manifest':str(manifest)},indent=2)+'\n')
try:
 sys.path.insert(0,str(source))
 from join_funcsim_graph import bind
 result=bind(graph,graph/'funcsim')
 encoded=(json.dumps(result,indent=2,sort_keys=True)+'\n').encode()
 if len(encoded)>64*1024*1024:raise ValueError('joined output exceeds64MiB cap')
 (out/'actual_join.json').write_bytes(encoded)
 print('WS_V7_STRUCTURAL_PARAMETER_JOIN_COMPLETE bytes='+str(len(encoded)))
except Exception as error:
 failure={'status':'FIRST_FAILURE_NO_RETRY','exception_type':type(error).__name__,'message':str(error),'traceback':traceback.format_exc()}
 (out/'terminal_failure.json').write_text(json.dumps(failure,indent=2,sort_keys=True)+'\n')
 traceback.print_exc();raise SystemExit(1)
