#!/usr/bin/env python3
"""Check evidence identity, capacity-safe schedule and independent replay."""
import csv, hashlib, json, math, sys
from pathlib import Path
first, second=map(Path,sys.argv[1:3])
for p in first.iterdir():
    if p.is_file():
        assert p.read_bytes()==(second/p.name).read_bytes(), f'nondeterministic output: {p.name}'
manifest=json.loads((first/'input_manifest.json').read_text())
for x in manifest:
    blob=(first/x['snapshot']).read_bytes()
    assert len(blob)==x['bytes'] and hashlib.sha256(blob).hexdigest()==x['sha256']
budget=json.loads((first/'budget.json').read_text())
ops=json.loads((first/'operations.json').read_text())
assert sum(x['MAC'] for x in ops if x['kind']=='MATRIX')==budget['workload']['Q8_INT8_MAC']
assert all(x['rows']<=4 for x in ops if x['kind']=='MATRIX')
assert all(x['rows']<=16 and x['width']<=4096 for x in ops if x['kind']=='QUANT')
current_matrix=None; quant_remaining=0; qK=0; qend=0; consumed=0
for x in ops:
    if x['kind']=='W_LOAD':
        assert quant_remaining==0
        current_matrix=x['weight']['name']
    elif x['kind']=='QUANT':
        assert quant_remaining==0
        quant_remaining=x['rows'];qK=x['width'];qend=x['ordinal'];consumed=0
    elif x['kind']=='MATRIX':
        assert current_matrix==x['weight']['name'] and qK==x['K']
        quant_remaining-=x['rows'];consumed+=x['rows'];assert quant_remaining>=0
assert quant_remaining==0
timeline=list(csv.DictReader((first/'serial_timeline_150MHz_10GBps_reuse128_aux8.csv').open()))
assert len(timeline)==len(ops)
end=0.0
for x in timeline:
    assert math.isclose(float(x['start_seconds']),end,abs_tol=1e-10)
    assert float(x['finish_seconds'])>=end
    end=float(x['finish_seconds'])
rep=json.loads((first/'ffn_replay.json').read_text())
assert sum(v for k,v in rep.items() if isinstance(v,int) and k!='sum_cycles')==375074==rep['sum_cycles']
for x in csv.DictReader((first/'scenarios.csv').open()):
    assert float(x['serial_II_seconds_conditional'])==float(x['serial_warm_device_seconds_conditional'])
    assert float(x['multi_context_resource_demand_II_lower_seconds_NOT_attainable_claim'])<=float(x['serial_II_seconds_conditional'])
print(json.dumps({'status':'PASS_ANALYSIS_REPRODUCTION_NOT_HARDWARE','inputs_verified':len(manifest),
 'scheduled_operations':len(ops),'matrix_views':sum(x['kind']=='MATRIX' for x in ops),
 'quant_windows':sum(x['kind']=='QUANT' for x in ops),'checks':['byte-identical snapshot replay',
 'manifest snapshot SHA256','MAC total','fullA16/PS4 capacity-safe serial order','single matrix binding',
 'AT049 exact 375074-cycle interval closure','single-slot II=latency']},indent=2))
