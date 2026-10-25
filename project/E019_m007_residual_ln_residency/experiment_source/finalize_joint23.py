#!/usr/bin/env python3
"""Finalize E019/R002 from actual terminal receipts and unchanged production identities."""
from collections import Counter
from datetime import datetime, timezone
from decimal import Decimal
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
E=ROOT/'project/E019_m007_residual_ln_residency'
RUN=E/'experiment_results/runs/R002'
A=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def save(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def rel(p):return str(p.relative_to(ROOT))
def append_once(p,title,body):
 s=p.read_text()
 assert title not in s,'already finalized '+str(p)
 p.write_text(s+'\n\n'+title+'\n\n'+body+'\n')
ats={'joint16':'AT010_retired_A_return_real_LN16','gamma_reuse':'AT011_actual_cross_owner_gamma_reuse','NaN_recovery':'AT012_public_NaN_newgen_full_recovery','public_FP_DIV_held17':'AT016_legal_FP_DIV_held17_and_inactive','VECTOR_normal':'AT018_vector_normal_equivalence','VECTOR_finalH_held17':'AT019_vector_finalH_held17_equivalence','VECTOR_NaN':'AT022_vector_NaN_equivalence_actual_progress','release_audit':'AT024_release_actual_VECTOR_parameter_census'}
scenarios={}
for name,at in ats.items():
 receipt=RUN/'attempts'/at/'receipt.json';report=RUN/'attempts'/at/'work/report.json';r=read(receipt);m=read(report)
 assert r['status']=='EXIT_ZERO'and m['status']=='PASS'
 assert not r['owned_after_cleanup']and not r['owned_group_after_cleanup_exists']
 scenarios[name]={'attempt':at,'receipt':rel(receipt),'receipt_sha256':sha(receipt),'report':rel(report),'report_sha256':sha(report),'guard_wall_s':r['child_wall_s'],'scope':m['scope'],'metrics':m.get('metrics'),'result_marker':m.get('result_marker'),'equivalence':m.get('equivalence_metrics')}
bundle=read(RUN/'production_bundle_checkpoint_v1.json')
for n,h in bundle['source_sha256'].items():assert sha(ROOT/n)==h,n
lnm=ROOT/bundle['LN_verified_manifest'];assert sha(lnm)==bundle['LN_verified_manifest_sha256']
ln=read(lnm)
for n,h in ln['source_sha256'].items():assert sha(ROOT/'project/E002_Laya_HLS/experiment'/n)==h,n
used={k:Decimal(0)for k in ['reference','static','rtl','ooc']};receipts=[]
for p in sorted((RUN/'attempts').glob('AT*/receipt.json')):
 d=json.loads(p.read_text(),parse_float=Decimal)
 assert d['status']not in ['RUNNING','WAITING_LOCK']
 assert not d.get('owned_after_cleanup',[])and not d.get('owned_group_after_cleanup_exists',False)
 used[d['phase']]+=d.get('child_wall_s',Decimal(0))
 receipts.append({'attempt':p.parent.name,'phase':d['phase'],'status':d['status'],'wall_s':str(d.get('child_wall_s',Decimal(0))),'receipt':rel(p),'receipt_sha256':sha(p)})
limits={'reference':0,'static':600,'rtl':1200,'ooc':0}
assert used['static']<480 and used['rtl']<1080
budget={'schema':'m007-joint23-final-exact-budget-v1','used_s':{k:str(v)for k,v in used.items()},'caps_s':limits,'remaining_closed_s':{k:str(Decimal(limits[k])-v)for k,v in used.items()},'receipts_count':len(receipts),'status_counts':dict(Counter(x['status']for x in receipts)),'receipts':receipts,'method':'Decimal of original JSON numeric receipt lexemes; every failed/infrastructure/observer/cost-stopped attempt retained; remaining balance closed and not transferred'}
save(RUN/'final_budget.json',budget)
audit=read(RUN/'attempts'/ats['release_audit']/'work/report.json')
census=RUN/'attempts'/ats['release_audit']/'work/audit/control_census.json'
param=RUN/'attempts'/ats['release_audit']/'work/vector_external_control.txt'
assert param.read_text().strip()=='1'
gate=read(RUN/'LN128_cost_gate.json');assert gate['status']=='COST_STOP'and not gate['full128_launched']
manifest={'schema':'m007-joint23-production-final-source-v1','production_source_sha256':bundle['source_sha256'],'production_body_sha256':sha(A/'rtl/laya_m007_resident_joint_v2.sv'),'public_header_sha256':bundle['header_sha256'],'public_ports':465,'LN_verified_manifest':rel(lnm),'LN_verified_manifest_sha256':sha(lnm),'LN_dependency_hashes_reverified':len(ln['source_sha256']),'normal_and_held_VECTOR_build':'AT017_vector_three_version_equivalence_build','NaN_VECTOR_build':'AT021_vector_NaN_actual_progress_build','VECTOR_TB_change_between_builds':'only NaN actual independently checked commit progress cadence; DUT and comparator/driver unchanged','guard_final_sha256':sha(A/'tb/m007_joint23_guard.py'),'actual_external_VECTOR_parameter':{'value':1,'evidence':rel(param),'sha256':sha(param)},'TANH_version':'v1; new CE v2 is a separately authorized successor and is not present in this production','no_OOC_PnR_board_claim':True}
save(RUN/'source_manifest_final.json',manifest)
limits_text='Full LN128 COST_STOP: measured same-build estimate315.05614718854196s exceeds120s; not launched. Complete Encoder/30layers, joint synthesized or routed fit/timing and board behavior are not established.'
failures=['AT001 infrastructure process-policy sampling race; robust PID/start_ticks checks added without policy relaxation','AT002 declaration ordering and AT003 missing original archived EXP source dependencies','AT005 oversized combined runtime wall COST_STOP; partitioned bounded scenarios authorized afterward','AT007 actual TB60000cycle timeout FAIL exposed masked A physical readiness; final production uses raw private probes and selected public gating','AT014 test requested illegal DIV phase7; corrected to legal phase6, no production change','AT020 DUT/checker completed but guard SEMANTIC_OBSERVER_FAILURE because13 commits did not reach128-event cadence; fixed only actual NaN commit event cadence, affected AT022 passed','AT023 audit incorrectly required an O3-removed wire-only generate name; AT024 verified actual EXTERNAL_CONTROL=1, unique VECTOR scope and source-bound sole local storage branch']
final={'schema':'m007-joint23-final-delivery-v1','finalized_at':datetime.now(timezone.utc).isoformat(),'mission':'M007/SM011','contract':'D-M007-SM011-JOINT-ARENA-23','experiment':'E019/R002','execution_state':'completed','verdict':'supported','applicability':'Bounded real four-owner residual-LN16/gamma reuse/NaN recovery/held public services and VECTOR local/external control compatibility; full128 cost-stopped','runtime_id':'/root/m007_strict_fp_engineering','thread_id':None,'desired_model':'gpt-6.1-sol','desired_effort':'xhigh','actual_model':'unverified','actual_effort':'unverified','production_body_sha256':manifest['production_body_sha256'],'header_sha256':manifest['public_header_sha256'],'production_source_manifest':rel(RUN/'source_manifest_final.json'),'production_source_manifest_sha256':sha(RUN/'source_manifest_final.json'),'scenarios':scenarios,'scenario_partition':'joint16, gamma reuse, NaN recovery, held public service and each VECTOR mode are separate bounded runtimes; not one all-scenario execution','VECTOR_retirement_semantics':'v2 local/external all outputs equal; v2_retired=v1_retired&&!start_accept with one actual difference edge observed per accepted mode; all other outputs equal each sampled edge','unit_and_production_scope':'VECTOR TB-owned48-bit q proves pure external unit compatibility; production single-arena ownership is proved separately by AT010/011/012 and source/hierarchy evidence','release_audit':{'checks':audit['checks_count'],'hierarchy_scopes':audit['hierarchy_scope_count'],'control_census':rel(census),'control_census_sha256':sha(census),'known_projection_bits_before_parent':32491,'known_projection_B_before_parent':4061.375,'unallocated_bits_before_parent':277,'wrapper_FF_bits':0,'resident_LN_provider_bits':33,'external_VECTOR_shadow_bits':0,'final_parent_or_physical_fit':'NOT_ASSESSED'},'LN128_cost_gate':gate,'retained_failures':failures,'limits':limits_text,'budget':rel(RUN/'final_budget.json'),'budget_sha256':sha(RUN/'final_budget.json'),'heavy_work':'No A007 live or queued guard; window explicitly released to A010 after AT024; every owned cleanup empty; remaining balance closed'}
save(RUN/'final_delivery.json',final)
md=f'''# E019 R002 JOINT-ARENA-23 final delivery

Execution completed; bounded results supported. Production body `{manifest['production_body_sha256']}` and465-port header `{manifest['public_header_sha256']}` remain unchanged since AT009/010; old v1 sources are preserved. Frozen LN v3 core2a97609c uses12128/160 bits in the single12288-bit arena.

- AT010: actual A/G/VECTOR/LN handoffs and cancellation,4096 residual H writes/131072 bitwise values, then synchronous H→canonical LN16→512 Q vectors/16384 values and return to A, no reset. Five cross-owner switches;193 G vectors/15440 original node checks and256 bank operations.
- AT011: actual32chunk gamma load/heldDONE17, cross-owner preservation, a new full4096 finite VECTOR producer and4row/128vector gamma-LN reuse, no reset.
- AT012: public NaN drain with no finite witness, newgeneration A operation, full public H/Q reload and complete4096 residual recovery without reset. Error→fullLN is outside this result.
- AT016: actual public FP and DIV returns each held17 cycles,257 checked values, two real releases and inactive public zero acceptance.
- AT018/019/022: VECTOR v1/localv2/externalv2 normal, finalHwrite17 and NaN comparisons passed. Normal first12/DONE4110, held finalwrite DONE4127; each normal case checks131072 values and rescans131104. Each mode observes one accepted-start retirement difference. V2 local/external outputs are identical; versus v1 only retirement is strengthened by `!start_accept`, other outputs remain bitwise equal. NaN uses a separate observer-only rebuilt TB; production/comparator/driver unchanged.
- AT024:138 source/version/declaration/hierarchy checks over71277 actual scopes. One physical arena/resources/H/scratch and external VECTOR parameter1. Xsim O3 removes the wire-only generate scope; the actual parameter plus exact source branch establish zero external shadow storage. Known projection32491bit/4061.375B leaves277bits before new parent/control; provider33bits and wrapper0FF. This is declaration evidence, not final parent or physical fit.

{limits_text}

All24 receipts are retained, including all failures and costs. Exact guarded totals reference0/static{used['static']}/RTL{used['rtl']}/OOC0s; remaining static{Decimal(600)-used['static']}/RTL{Decimal(1200)-used['rtl']}s is closed and not transferred. All owned cleanup empty. Source/results/status evidence, separate runtime boundaries, all failure explanations and source identities are in `final_delivery.json`, `source_manifest_final.json`, `final_budget.json` and the original AT directories. No A007 heavy tool is running or queued.
'''
(RUN/'final_delivery.md').write_text(md)
layout=E/'experiment_source/vector_control_layout_v1.json';d=read(layout);d['implementation_state']='verified local48/external0 declaration and three-version guarded behavior; retired semantics strengthened on start_accept';d['evidence']=[scenarios[x]['report']for x in ['VECTOR_normal','VECTOR_finalH_held17','VECTOR_NaN','release_audit']];save(layout,d)
append_once(E/'experiment_source/protocol_r002.md','## Actual final closure and version boundaries','AT020 retained SEMANTIC_OBSERVER_FAILURE after a numerically successful short NaN run; thirteen real commits were below the original128-event interval. Only actual checked-commit progress cadence changed in the NaN TB; AT021 rebuilt, AT022 passed with13 real events. AT018/019 retain AT017 snapshot identity; no result is silently migrated. AT023 retained audit FAIL because O3 removed a wire-only generate name. AT024 requires actual VECTOR EXTERNAL_CONTROL=1, unique instance and the source-bound sole localFF branch, with138 checks/71277 scopes. Final budget/source/results: experiment_results/runs/R002/final_delivery.json and final_budget.json. All24 receipts preserved, no owned process remains, remaining budget closed. No new CE source selection in R002.')
append_once(A/'source/results.md','## M007 JOINT-ARENA-23 / E019 R002 final functional closure',md.split('\n\n',1)[1])
append_once(ROOT/'agent/A007/result.md','## E019 R002 JOINT-ARENA-23 completed (2026-10-23)',f'Real four-owner residual128→LN16→A, gamma reuse4rows and NaN→newgen full residual recovery passed as separate bounded runtimes. Public FP/DIV held17, VECTOR v1/localv2/externalv2 normal/finalHheld17/NaN passed with exact accepted-start retirement strengthening; all other outputs equivalent. AT024 audit138checks/71277scopes verifies single arena/resources and actual external VECTOR parameter1. Production52ff2c/header7c9181 unchanged; provider33bit/wrapper0FF, known32491bit before parent. {limits_text} Exact costs static{used["static"]}/RTL{used["rtl"]}s, remaining closed; all24 attempts retained/cleanup empty/no queued guard. Final evidence: project/E019_m007_residual_ln_residency/experiment_results/runs/R002/final_delivery.md and final_delivery.json. Successor CE D27 requires actual controller followup and a new independent batch/budget.')
publication={'source':'# E019 R002 source\n\n'+md.split('\n\n')[1]+'\n\nAuthority: source/m007_residual_encoder30_20261023.md §§10–11 and SM011 D23. Implementation remains E002 unique tree. Sole12288-bit q, A/G/LN/V views12288/11343/12128/48, raw A private service probes and selected public admission; real finite witness from consumed complete VECTOR producer. Source identities and declaration census are in the final manifests.','results':md,'status':'# E019 R002 status\n\nexecution_state: completed\nverdict: supported\napplicability: Bounded four-owner residual-LN16, gamma reuse, NaN recovery, public held17 and VECTOR compatibility.\n\nAll required bounded supplementary checks completed; fullLN128 remains COST_STOP without launch. Every owned cleanup empty; no A007 live/queued heavy tool. Window released to A010. R002 source and all24 receipts frozen; exact remaining budget closed, no transfer. Complete Encoder/30layers and physical fit/timing remain open. D27 CE joint-cost successor is separate and awaits actual followup.','execution_state':'completed','verdict':'supported','applicability':final['applicability'],'evidence':[rel(RUN/'final_delivery.json'),rel(RUN/'final_delivery.md'),rel(RUN/'source_manifest_final.json'),rel(RUN/'final_budget.json'),rel(RUN/'LN128_cost_gate.json'),*[x['report']for x in scenarios.values()]]}
save(RUN/'final_publication.json',publication)
save(ROOT/'agent/A007/stage_report.json',{'execution_state':'completed','current_task':'D-M007-SM011-JOINT-ARENA-23 / E019 R002 bounded functional and source/hierarchy verification completed','stage':'D23_completed_frozen_all_owned_cleanup_empty','blocker':None,'next_step':'A001 centralized review; A010 owns next heavy window. CE-joint D27 requires actual followup/new independent R003 budget; full128 remains original cost gate.','runtime_id':'/root/m007_strict_fp_engineering','thread_id':None})
print(json.dumps({'delivery':rel(RUN/'final_delivery.json'),'attempts':len(receipts),'status_counts':budget['status_counts'],'exact_used_s':budget['used_s'],'remaining_closed_s':budget['remaining_closed_s'],'audit_checks':audit['checks_count']},indent=2))
