#!/usr/bin/env python3
from pathlib import Path
from decimal import Decimal
import argparse,hashlib,json,re,subprocess
ROOT=Path(__file__).resolve().parents[7];A=Path(__file__).resolve().parents[1];EXP=A.parents[2];RUN=ROOT/'project/E019_m007_residual_ln_residency/experiment_results/runs/R003';VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path,required=True);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False)
h=o/'hierarchy_scopes.txt';v=o/'actual_parameters.txt';t=o/'hierarchy.tcl';t.write_text('set h [open {'+str(h)+'} w]\nforeach s [get_scopes -r /*] {puts $h $s}\nclose $h\nset p [open {'+str(v)+'} w]\nputs $p [get_value -radix unsigned /m007_joint27_tb/dut/TANH_FORCE_CORE_CE]\nputs $p [get_value -radix unsigned /m007_joint27_tb/dut/g_tanh/FORCE_CORE_CE]\nputs $p [get_value -radix unsigned /m007_joint27_tb/dut/joint/vector_engine/EXTERNAL_CONTROL]\nclose $p\nquit\n')
subprocess.run([str(VIV/'xsim'),'joint27_sim','-tclbatch',str(t)],cwd=a.build,check=True)
checks=[]
def check(name,condition):
 assert condition,name
 checks.append(name)
prior=read(RUN/'input_identity.json')
for n,d in prior['prior_frozen_R002_files_sha256'].items():check('frozen R002 final '+n,sha(ROOT/n)==d)
for n,d in prior['prior_receipt_sha256'].items():check('frozen R002 receipt '+n,sha(ROOT/n)==d)
dep=read(RUN/'dependency_manifest_prebuild_v1.json');body=A/'rtl/laya_m007_resident_joint_v2.sv';s=body.read_text()
check('actual body unchanged since dispatch freeze',sha(body)==dep['body_sha256'])
inv=s.replace(' parameter bit TANH_FORCE_CORE_CE=0;\n','',1).replace(' laya_m007_tanh8_v2 #(.FORCE_CORE_CE(TANH_FORCE_CORE_CE)) g_tanh(', ' laya_m007_tanh8_v1 g_tanh(')
check('exact inverse to original body',hashlib.sha256(inv.encode()).hexdigest()==dep['prior_body_sha256'])
check('no wrapper FF','always_ff'not in s and 'always @'not in s and 'always@'not in s)
check('single TANH8 v2 declaration',s.count(' laya_m007_tanh8_v2 #(.FORCE_CORE_CE(TANH_FORCE_CORE_CE)) g_tanh(')==1 and 'laya_m007_tanh8_v1'not in s)
for n,d in dep['unchanged_production_source_sha256'].items():check('unchanged production '+n,sha(ROOT/n)==d)
ce=ROOT/dep['CE26_manifest'];check('frozen CE manifest',sha(ce)==dep['CE26_manifest_sha256'])
for n,d in dep['CE_dependencies_experiment_relative'].items():check('frozen CE dependency '+n,sha(EXP/n)==d)
ln=ROOT/'project/E014_m007_layernorm32/experiment_results/runs/R002/source_manifest_v3_verified.json'
for n,d in read(ln)['source_sha256'].items():check('frozen LN dependency '+n,sha(EXP/n)==d)
bm=read(a.build/'report.json');check('actual auto0 build',bm['force_core_ce']==0 and bm['status']=='BUILD_COMPLETE')
for n,d in bm['compiled_source_sha256'].items():check('actual current compiled source '+n,sha(ROOT/n)==d)
check('actual runtime parameters',v.read_text().splitlines()==['0','0','1'])
lines=h.read_text().splitlines()
for suffix in ['/dut/joint/workspace','/dut/resources/fp','/dut/resources/div','/dut/resources/qkv','/dut/hidden','/dut/scratch','/dut/ln_provider','/dut/g_pool','/dut/g_tanh','/dut/g_tanh/credit']:
 check('actual unique physical '+suffix,sum(x.endswith(suffix)for x in lines)==1)
core_paths=[x for x in lines if '/dut/g_tanh/'in x and re.fullmatch(r'tanh_lane\[[0-7]\]\.core',x.rsplit('/',1)[-1].strip().lstrip('\\'))]
check('actual eight numerical cores',len(core_paths)==8 and {int(re.search(r'\[([0-7])\]',x).group(1))for x in core_paths}==set(range(8)))
check('actual external VECTOR no local storage',not any('/dut/joint/vector_engine/local_control'in x for x in lines))
comp=read(RUN/'force1_auto0_comparison.json');check('same-source exact-cycle comparison',comp['status']=='PASS'and comp['same_frozen_compiled_source']and comp['exact_cycle_control_trace_equal']and comp['numeric_assertions_equal'])
gate=read(RUN/'LN128_cost_gate.json')
if gate['status']=='COST_STOP':check('full128 not launched after closed gate',not gate['full128_launched'])
else:
 check('full128 admitted by actual auto0 measurement',gate['status']=='ADMITTED'and gate['estimate_s']<=120)
 fr=read(RUN/'attempts/AT005_auto0_residual128_LN128/receipt.json');fm=read(RUN/'attempts/AT005_auto0_residual128_LN128/work/report.json')
 check('actual full128 current-build PASS',fr['status']=='EXIT_ZERO'and fm['status']=='PASS'and fm['scope']=='JOINT_RESIDUAL_LN_128_PASS'and fm['build_manifest_sha256']==sha(a.build/'report.json'))
 check('actual all4096 LN Q commits',fm['metrics']['ln_vectors']==4096 and fm['metrics']['residual_vectors']==4096)
for q in sorted((RUN/'attempts').glob('AT*/receipt.json')):
 d=read(q)
 if d['status']not in ['RUNNING','WAITING_LOCK']:check('terminal cleanup '+q.parent.name,not d.get('owned_after_cleanup',[])and not d.get('owned_group_after_cleanup_exists',False))
report={'status':'PASS','scope':'D27 exact production replacement, frozen dependencies, single resources/eight-core hierarchy and actual CE configuration/cost outcomes; no physical timing/complete Encoder','checks_count':len(checks),'checks':checks,'hierarchy_scope_count':len(lines),'hierarchy_sha256':sha(h),'actual_parameter_sha256':sha(v),'body_sha256':sha(body),'public_header_sha256':dep['public_header_sha256'],'public_ports':465,'TANH8_instances':1,'core_instances':8,'actual_core_paths':core_paths,'credit_instances':1,'new_FF_bits':0,'wrapper_FF_bits':0,'known_projection_bits_before_parent':32491,'new_parent_control_bits':'separately owned/audited by A010; unchanged in D27','audit_driver_sha256':sha(Path(__file__))}
(o/'report.json').write_text(json.dumps(report,indent=2)+'\n');print('HARDWARE_AGENT_SIM_PASS JOINT27_RELEASE_AUDIT checks='+str(len(checks)))
