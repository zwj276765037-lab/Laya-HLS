#!/usr/bin/env python3
"""Record bounded evidence, preserving all attempt files and prior identities."""
import datetime as dt
import hashlib
import json
from pathlib import Path

RUN = Path(__file__).resolve().parent
PROJECT = RUN.parents[4]
IMPL = PROJECT/'project/E002_Laya_HLS/experiment'
PREFIX = 'project/E003_production_chain_closure/experiment_results/runs/R003/'
NAMES = ['bootstrap_source_guard_rtl_08', 'layernorm_guarded_source_05',
    'bootstrap_source_conflict_adapter_host_01', 'generated_store_monitor_13',
    'bootstrap_snapshot_rtl_05', 'layernorm_producer_portal_08', 'layernorm_quant_source_04']

def rec(p):
    p = Path(p).resolve(); data = p.read_bytes()
    return {'path': str(p), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def main():
    out = RUN/'guarded_layernorm_f16_catalog_delta_20261012.json'
    if out.exists(): raise RuntimeError('catalog delta already exists')
    config = IMPL/'config'
    paths = [config/'full_module_registry.json', config/'production_hls_partitions.json']
    before = [rec(p) for p in paths]
    registry, partitions = [json.loads(p.read_text()) for p in paths]
    boundary = partitions['bootstrap_source_guard_boundary']
    boundary.update(state='finite_actual_generated_LN_STATE0_protection_pass_all_13BO_executor_pending',
        producer_completion_consumer='same real depth2 consumer of F9-verified LPC1; tail2/tail1 held in layernorm_guarded_source_05',
        action_completion_consumer='same physical LAC1 depth2 FIFO with full safe-error validation; report remains controlled fixture',
        validation='F15 scoped controller closure on guard_07; identical guard in guard_08/LN_05. F16 repaired hub mapping and actual decoder/adapter finite host verification await controller acceptance',
        supported_ingress='one fixed STATE0 base; controlled checkpoint and generated LN writer share one monitor; source AR VALID and READY gated identically',
        remaining='real executor/action top, complete rows16/tensor action, all 13BO/base lifecycle and mutation paths, active cancellation recovery, full graph/request')
    partitions['bootstrap_snapshot_boundary']['validation'] = 'bootstrap_snapshot_rtl_05 default-guard-disabled F14 compatibility; actual readonly snapshot and finite STATE0 guarded LN_05; full production protection remains pending'
    executor = next(p for p in partitions['partitions'] if p['name']=='task_lifecycle_executor')
    executor['state'] = 'host_bootstrap_FSM_and_finite_actual_guarded_LN_validated_executor_top_pending'
    executor['implementation']['source_guard_validation'] = boundary['supported_ingress']+'; '+boundary['remaining']
    executor['evidence'].update(source_guard=PREFIX+'bootstrap_source_guard_rtl_08',
        snapshot_arbitration=PREFIX+'bootstrap_snapshot_rtl_05', guarded_generated_LN=PREFIX+'layernorm_guarded_source_05',
        source_conflict_decoder_adapter=PREFIX+'bootstrap_source_conflict_adapter_host_01',
        scope='finite readonly/protected source and actual one-row LN with controlled predecessor/LAC1; executor bootstrap checkpoint high-water interface and true action top pending')
    engine = next(p for p in partitions['partitions'] if p['name']=='layernorm_producer_engine')
    engine['evidence'] = {'guarded_source': PREFIX+'layernorm_guarded_source_05',
        'default_portal_compatibility': PREFIX+'layernorm_producer_portal_08',
        'default_quant_F9_compatibility': PREFIX+'layernorm_quant_source_04',
        'scope': 'one real generated row and 1024 F32 gold; default shell pilot/six F9 negatives; prior rows16 Q/fullA remains its old frozen identity'}
    registry['bootstrap_source_guard'].update(validation=boundary['validation'],
        actual_generated_LN=PREFIX+'layernorm_guarded_source_05',
        production_limit=boundary['remaining'],snapshot_arbitration='bootstrap_snapshot_rtl_05 F14 scoped compatibility')
    m = 'vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/'
    registry['rtl_shell_sources']['layernorm_guarded_source'] = [m+n+'.sv' for n in (
        'laya_model_identity_13bo_generated_v1','laya_compute_portal_layout_v1',
        'laya_generated_provenance_layout_v1','laya_private_fifo2_v1','laya_generated_provenance_v1',
        'laya_generated_provenance_hub_v1','laya_generated_provenance_portal_v1',
        'laya_generated_store_monitor_v1','laya_generated_provenance_axi_portal_v1',
        'laya_bootstrap_source_guard_v1','laya_layernorm_producer_portal_shell_v1')]
    for p,d in zip(paths,[registry,partitions]): p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
    differences = []; total_pairs = 0; refs = []
    def walk(value):
        if isinstance(value,dict):
            if all(k in value for k in ('path','bytes','sha256')):
                actual=rec(value['path']); refs.append({'declared':value,'actual':actual,'match':value==actual})
            for v in value.values():walk(v)
        elif isinstance(value,list):
            for v in value:walk(v)
    for name in NAMES:
        manifest=json.loads((RUN/name/'input_manifest.json').read_text())
        pairs=list(manifest['files'])+manifest.get('contracts',[])
        for key in ('contract','bootstrap_contract'):
            if key in manifest:pairs.append(manifest[key])
        total_pairs+=len(pairs)
        for pair in pairs:
            current=rec(pair['original']['path'])
            if current!=pair['original']:differences.append({'attempt':name,'original':pair['original'],'current':current})
            if rec(pair['frozen']['path'])!=pair['frozen'] or pair['original']['sha256']!=pair['frozen']['sha256']:raise RuntimeError('frozen/pair mismatch')
        walk(manifest);walk(json.loads((RUN/name/'receipt.json').read_text()))
    allowed={str(p.resolve()) for p in paths}
    if any(d['current']['path'] not in allowed for d in differences):raise RuntimeError('non-catalog live drift')
    data={'schema':'laya-guarded-layernorm-f16-catalog-delta-v1','at_utc':dt.datetime.now(dt.timezone.utc).isoformat(),
        'catalogs':[{'before':b,'after':rec(p)} for b,p in zip(before,paths)],
        'attempts':NAMES,'total_pairs':total_pairs,'current_matching_pairs':total_pairs-len(differences),
        'frozen_and_declared_pairs_match':True,'live_differences':differences,
        'reference_count':len(refs),'matching_references':sum(r['match'] for r in refs),
        'reference_differences':[r for r in refs if not r['match']]}
    if any(r['actual']['path'] not in allowed for r in data['reference_differences']):raise RuntimeError('non-catalog reference drift')
    out.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
    print({k:data[k] for k in ['total_pairs','current_matching_pairs','reference_count','matching_references']})

if __name__=='__main__':main()
