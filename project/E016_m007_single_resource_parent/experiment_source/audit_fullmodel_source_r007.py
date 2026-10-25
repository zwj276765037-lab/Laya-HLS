#!/usr/bin/env python3
"""Bounded source-only audit, never implementation or behavioral acceptance."""
from pathlib import Path
import hashlib,json,re,time,resource
ROOT=Path(__file__).resolve().parents[3];M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007';start=time.monotonic()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
checks=[]
def check(c,s):
 assert c,s;checks.append(s)
p=M/'forward_controller/rtl/laya_m007_single_parent_v3.sv';t=p.read_text();header=t[:t.index('\n);')]
check(sha(M/'forward_controller/rtl/laya_m007_single_parent_v2.sv')=='b6bf3d811dfa2a2036c049714e1fd5dc46fe81f4b7c0c5b12ef165912d7050df','frozen parent_v2 exact preserved')
for name in ['cmd_tensor','cmd_base','cmd_span','desc_valid','coef_cfg_valid','coef_wr_valid']:
 check(not re.search(r'\b'+name+r'\b',header),'v3 removed Host/legacy port '+name)
assigns=re.findall(r'\bassign\s+(\w+)\s*=',t)
check(len(assigns)==len(set(assigns)),'parent continuous assignment targets unique')
check('logic[8:0]active_epoch_offset;'in t and 'wire[31:0]operation_epoch=epoch+{23\'b0,active_epoch_offset};'in t,'operation epoch held in explicit9bit state')
check("BUILD_ID=128'hcedb4c130303f16da9fa1c605b2cf985"in t,'ABI tag exact')
check('7209eb09c3f265363cfb274f7790a73336e1570f5081bc9bbb2538c1ba5a50d5'in t,'full package build field distinct from manifest file SHA')
check('if(crc_next!=span[0][0])'in t,'last actual record included in CRC comparison')
check(t.count('laya_m007_resident_joint_v3 resident(')==1 and t.count('laya_m007_matrix_facade_v2 #(')==1 and t.count('laya_m007_quant_a_fill_v1 front(')==1,'one resident/matrix/quant top instance source')
fac=(M/'q8_linear_and_restore/rtl/laya_m007_matrix_facade_v2.sv').read_text();can=fac[fac.index('generate if(CANONICAL_MODEL)'):fac.index('end else begin:legacy')]
check('words[0:287]'in can and 'logic response_valid;'in can,'canonical73728B bias bank + one response-valid declaration')
for n in ['coeff_busy','coeff_valid','coeff_bad','coeff_coverage','coeff_count','coeff_model','coeff_request','coeff_tensor','coeff_generation','coeff_epoch','coeff_n']:
 check(not re.search(r'\b'+n+r'\b',can),'canonical source excludes legacy physical field '+n)
check('logic[63:0][31:0] response_data;'in can,'canonical256B response holding separately declared')
check('&&w_transport_idle&&'in fac and '&&!load_pending&&!wl_rsp_valid' in fac,'facade transport predicate includes W/load-held debt')
rdr=(M/'hbm_loader_and_cache/rtl/laya_m007_w_reader_v2.sv').read_text()
check('if(rlast)begin complete[rid]<=1;'in rdr,'W burst completion waits actual RLAST')
check('busy==0&&complete==0&&!out_valid&&!arvalid&&inflight==0'in rdr,'W transport predicate includes queues and held output')
ports=json.loads((ROOT/'project/E019_m007_residual_ln_residency/experiment_source/resident_joint_v3_public_ports_v1.json').read_text())['ports']
instance=t[t.index('laya_m007_resident_joint_v3 resident('):]
bound=re.findall(r'\.(\w+)\(',instance[:instance.index('\n);')]);check(set(bound)==set(x[2]for x in ports)and len(bound)==len(ports)==475,'all475 public D29 ports bound exactly once')
check('model_committed<=1;'in t and t.index('if(kind==0&&done_status==0)model_committed<=1;')>t.index('if(done_valid&&done_ready)'),'model commit only successful held SETUP_DONE consumption')
check('pack_seq==16384'in t and "state==D1SUB?16'd4096"in t and "decision_mode?16'd4096:16'd2624"in t,'Decision actual16384 barrier/K4096 selectors present')
report={'status':'SOURCE_STRUCTURAL_CHECK_ONLY','checks':checks,'check_count':len(checks),'source_sha256':{str(q.relative_to(ROOT)):sha(q)for q in [p,M/'q8_linear_and_restore/rtl/laya_m007_matrix_facade_v2.sv',M/'hbm_loader_and_cache/rtl/laya_m007_w_reader_v2.sv',M/'hbm_loader_and_cache/rtl/laya_m007_w_supply_v2.sv',M/'forward_controller/tb/m007_fullmodel_parent_tb.sv']},'new_control_projection_bits':221,'candidate_legacy_control_removed_bits':398,'actual_elaborated_census':'NOT_RUN','compilation':'NOT_RUN','normal_full_graph':'NOT_RUN','elapsed_seconds':time.monotonic()-start,'max_rss_kib':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss}
(R/'source_structural_check.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'checks':len(checks),'elapsed_seconds':report['elapsed_seconds'],'max_rss_kib':report['max_rss_kib']}))
