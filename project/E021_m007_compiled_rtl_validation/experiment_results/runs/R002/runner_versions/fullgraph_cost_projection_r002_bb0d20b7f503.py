#!/usr/bin/env python3
"""Conditional work-weighted cost planning; never opens a simulation launch gate."""
import datetime as dt,hashlib,json
from pathlib import Path
root=Path(__file__).resolve().parents[5]
r=root/'project/E021_m007_compiled_rtl_validation/experiment_results/runs/R002'
a=r/'attempts/AT005_first_original_layer';d=r/'attempts/AT010_kind6_public_abi'
def identify(p):return {'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
def events(at):return [json.loads(z) for z in (at/'work/wall_events.jsonl').read_text().splitlines()]
def event(at,tag):return next(z for z in events(at) if tag in z['line'])
enc_h=next(z['elapsed_s'] for z in reversed(events(a)) if 'phase=PUBLIC_H ' in z['line'])
dec_h=next(z['elapsed_s'] for z in reversed(events(d)) if 'phase=PUBLIC_H ' in z['line'])
enc_core=event(a,'M007_LAYER0_CAPTURE_COMPLETE')['elapsed_s']-enc_h
dec_core=event(d,'M007_LAYER_CAPTURE_COMPLETE global=28')['elapsed_s']-dec_h
preLN=event(d,'global=28 state=86 ')['elapsed_s']-event(d,'global=28 state=85 ')['elapsed_s']
receipt=json.loads((d/'receipt_rtl.json').read_text())['driver_receipt']
type_proxy=next(z['duration_seconds'] for z in receipt['completed_segments'] if z['stage']=='residualA_success')
base=root/'project/E016_m007_single_resource_parent/experiment_results/runs/R007/prepared/fullgraph_kind6_kind7_public_boundary_v2/frozen'
parent=base/'laya_m007_single_parent_v3.sv';qk=base/'laya_attention_qk_av_engine_v1.sv'
assert "layer_index%3==0?2'd0:2'd1" in parent.read_text()
assert 'qk_read_key==127' in qk.read_text() and "partial_commits==4096&&root_accepted==4096&&next_key=={32{8'd128}}" in qk.read_text()
dec1=r/'attempts/AT011_kind6_decision1';dec1receipt=dec1/'receipt_rtl.json';dec1_complete=dec1receipt.exists() and json.loads(dec1receipt.read_text())['verdict']=='PASS'
if dec1_complete:
 dec1_h=next(z['elapsed_s'] for z in reversed(events(dec1)) if 'phase=PUBLIC_H ' in z['line'])
 dec1_core=event(dec1,'M007_LAYER_CAPTURE_COMPLETE global=29')['elapsed_s']-dec1_h
else:dec1_core=dec_core
proxy=enc_h+28*enc_core+27*preLN+dec_core+dec1_core+preLN+type_proxy
lower=.9*proxy;upper=1.25*proxy+120;budget=json.loads((r/'budget_current.json').read_text())
x={
 'created_at':dt.datetime.now(dt.timezone.utc).isoformat(),
 'status':'CONDITIONAL_ENGINEERING_PLANNING_ONLY_NOT_MEASURED_FULLGRAPH_E',
 'current_formal_gate_E':'UNKNOWN',
 'source_evidence':[identify(parent),identify(qk),identify(root/'source/m007_residual_encoder30_20261023.md')],
 'measured_samples':[identify(a/'receipt_rtl.json'),identify(d/'receipt_rtl.json')]+([identify(dec1receipt)] if dec1_complete else []),
 'fixed_original_graph':{'encoder_full_layers':[0,3,6,9,12,15,18,21,24,27],'encoder_full_count':10,'encoder_sliding_count':18,'Decision_count':2,'attention_layers':30,'matrices':120,'LN_commands':60,'vector_commands':61,'GEGLU_layers':28,'kind7_once_BEGIN':1,'tail_commits':1,'original_public_output_groups32':544},
 'sliding_not_shape_discount':{'QK':'32 query groups x128 keys; sliding finite mask added after full products and adjacent sum tree','AV':'4096 root/partial commits;128 keys per group','scope':'source-fixed scheduling; wall/data costs can differ; no measured complete sliding layer'},
 'measured_wall_seconds':{'setup_plus_public_H_once':enc_h,'Encoder0_core_after_H_through_actual_layer_endpoint':enc_core,'preLN_P_RUN85_to_P_RETIRE86':preLN,'Decision0_core_after_H_through_actual_layer_endpoint':dec_core,'Decision1_core_or_proxy':dec1_core,'Decision1_independently_complete':dec1_complete,'vector_type_proxy_from_Decision_residualA':type_proxy},
 'formula':'setupH +28*Encoder0_core +27*preLN +Decision0_core +Decision1_core_or_proxy +finalLN_proxy +type_vector_proxy; tail/gather/terminal unmeasured',
 'proxy_before_unmeasured_tail_seconds':proxy,
 'planning_range_seconds':[lower,upper],
 'planning_range_hours':[lower/3600,upper/3600],
 'planning_upper_rule':'1.25 * stage-weighted proxy +120s unmeasured tail/gather/terminal allowance; heuristic planning margin, not measured/proven conservative upper bound',
 'assumptions_and_gaps':['same single-thread runtime/host policy; numeric data may vary CPU instruction costs','later Encoder preLN represented by one actual preLN; full/sliding common core represented by actual Encoder0 because mask does not prune QK/AV shape','Decision1 independently complete only when explicitly marked above','final gamma/type/gather/tail original kind7 paths not yet measured','continuous internal kind7 handoffs not proven by standalone public components','cannot authorize a run or replace formal measured E<=3600 gate'],
 'budget_comparison':{'single_run_current_limit_seconds':3600,'R002_total_RTL_seconds':7200,'actual_remaining_RTL_seconds':budget['remaining_rtl_seconds'],'actual_spendable_after600_reserve_seconds':budget['remaining_rtl_above600reserve_seconds'],'central_proxy_over3600_factor':proxy/3600,'planning_upper_over3600_factor':upper/3600,'central_proxy_over7200_gap_seconds':proxy-7200,'central_proxy_over_actual_spendable_gap_seconds':proxy-budget['remaining_rtl_above600reserve_seconds'],'AT011_in_flight_cap_seconds':0 if dec1_complete else 500,'formal_gate':'CLOSED'},
 'minimal_complete_run_proposal':{
  'status':'REQUIRES_NEW_CONTROLLER_COST_CONTRACT; NOT_LAUNCHED',
  'same_exact_model_executable_possible':True,'new_math_translation_or_build_required':False,
  'request':'original kind7/local0 once-BEGIN, no STOP, no intermediate fixture injection; same real120 W peer and original checkpoints/tail',
  'original_checker_terminal_requirements':'30 original endpoints;120matrix/60LN/61vector/28GEGLU;544 original output groups and true tail commit; held successDONE consumed; true global/transport/weight idle; normal exit',
  'capture':'reuse global-layer main actual0..29 independent artifacts; cannot replace original TB',
  'suggested_hard_cap_seconds':13000,'suggested_independent_RTL_budget_with600_reserve_seconds':13600,'consecutive_real_phase_cap_seconds':120,
  'unchanged_resource_policy':'CPU0-3/nice19/idle IO;1thread;8GiB/40Mcycle;single heavy lock;MemAvailable>192GiB',
  'real_cycles_order':'about13million from component cycle identities; fullgraph unmeasured',
  'if3600_limit_must_remain':'requires measured about2.83x central or3.57x planning-bound acceleration; current no-op/PC evidence supplies no such gain'
 }
}
(r/'fullgraph_cost_projection_after_Decision0.json').write_text(json.dumps(x,indent=2)+'\n')
body=f'''# 原30层完整图成本规划

正式整图E仍UNKNOWN，未启动kind7完整长跑。原图固定10full/18sliding Encoder、2Decision，共120矩阵、60LN、61vector、28GEGLU。滑窗QK仍遍历32 query group×128 key、AV仍完成4096组累加/128key，finite mask不裁调度，不能按滑窗面积削减成本。

setup/H只算一次{enc_h:.3f}s，Encoder0核心{enc_core:.3f}s，后继27层各新增preLN代理{preLN:.3f}s，Decision0核心{dec_core:.3f}s，Decision1核心或代理{dec1_core:.3f}s（独立完整实测={dec1_complete}），另finalLN代理{preLN:.3f}s、type代理{type_proxy:.3f}s。未测tail前加权代理{proxy:.3f}s（{proxy/3600:.2f}小时）。条件规划范围{lower:.0f}–{upper:.0f}s（{lower/3600:.2f}–{upper/3600:.2f}小时）；上沿取1.25×代理+120s未测尾部余量，是工程计划余量，并非已测或证明的保守E。

缺口仍含未完整实测sliding层、final gamma/type/tail及连续kind7交接，数据也可能改变CPU成本。中央代理需约{proxy/3600:.2f}倍加速才合3600s；规划上沿需{upper/3600:.2f}倍。R002总7200s比中央代理少{proxy-7200:.0f}s；当前留600后可支配{budget['remaining_rtl_above600reserve_seconds']:.3f}s，活动AT011还需实际扣费。组件通过不能打开旧长跑门。

最小完整方案复用同一exe/数学模型不重译，另立单次13000s/独立RTL13600s含600保留的成本合同；保持1线程、CPU0–3/nice19/idle IO、8GiB/40Mcycle、单锁与连续真实成功阶段120s。一次原kind7/local0 BEGIN，真实0..29连续前后依赖、不注入中间fixture，保留全部原checkpoint、tail、544组公开输出、成功DONE消费、真实idle及正常退出。通用捕获记录30层实际H作独立复核，不能替代TB。此为具体建议，未获新成本合同不执行。

机器可核公式和源身份见同目录fullgraph_cost_projection_after_Decision0.json。
'''
(r/'fullgraph_cost_plan_after_Decision0.md').write_text(body)
print(json.dumps({'proxy_seconds':proxy,'planning_range_seconds':[lower,upper],'Decision1_complete':dec1_complete,'formal_gate':'CLOSED'}))
