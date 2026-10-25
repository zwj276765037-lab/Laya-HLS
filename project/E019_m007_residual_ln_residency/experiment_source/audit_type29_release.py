#!/usr/bin/env python3
import argparse,hashlib,json,re,subprocess,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];E=ROOT/'project/E019_m007_residual_ln_residency';RUN=E/'experiment_results/runs/R004';A=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine';VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path,required=True);p.add_argument('--tanh-version',choices=['v2','v3'],required=True);a=p.parse_args();o=a.output;o.mkdir(parents=True,exist_ok=False)
h=o/'hierarchy_scopes.txt';v=o/'actual_parameters.txt';t=o/'hierarchy.tcl';t.write_text('set h [open {'+str(h)+'} w]\nforeach s [get_scopes -r /*] {puts $h $s}\nclose $h\nset p [open {'+str(v)+'} w]\nputs $p [get_value -radix unsigned /m007_type29_joint_tb/dut/TANH_FORCE_CORE_CE]\nputs $p [get_value -radix unsigned /m007_type29_joint_tb/dut/g_tanh/FORCE_CORE_CE]\nputs $p [get_value -radix unsigned /m007_type29_joint_tb/dut/joint/vector_engine/EXTERNAL_CONTROL]\nclose $p\nquit\n')
subprocess.run([str(VIV/'xsim'),'type29_joint_sim','-tclbatch',str(t)],cwd=a.build,check=True)
checks=[]
def check(n,c):
 assert c,n
 checks.append(n)
prep=read(RUN/'source_preparation_v1.json')
for n,d in prep['old_v2_and_dependencies_preserved_sha256'].items():check('preserved old65 '+n,sha(ROOT/n)==d)
for x in read(E/'experiment_results/runs/R003/final_budget.json')['receipts']:check('preserved R003 receipt '+x['attempt'],sha(ROOT/x['receipt'])==x['receipt_sha256'])
body=A/'rtl/laya_m007_resident_joint_v3.sv';s=body.read_text();hdr=A/'rtl/laya_m007_resident_joint_v3_header.svh';ports=read(E/'experiment_source/resident_joint_v3_public_ports_v1.json')
check('public475 ports',len(ports['ports'])==475 and s.startswith(hdr.read_text()))
check('no wrapper FF',not re.search(r'\balways(?:_ff)?\s*[@(]',s))
check('one selected TANH8 declaration',s.count(' laya_m007_tanh8_'+a.tanh_version+' #(.FORCE_CORE_CE(TANH_FORCE_CORE_CE)) g_tanh(')==1)
check('one typebank declaration',s.count(' laya_m007_type32_v1 type_bank(')==1)
check('identity qualified legal H_LOAD source event','h_load_success_valid&&resident_owner_valid&&external_identity&&h_bank_idle&&!raw_h_wr_valid' in s)
check('BEGIN/publicH/VECTOR invalidate one witness','!resident_owner_valid||h_wr_commit||(vector_start_valid&&vector_start_ready)'in s)
bank=(A/'rtl/laya_m007_type32_v1.sv').read_text();vec=(A/'rtl/laya_m007_resident_vector32_v3.sv').read_text()
check('type exactly response13 control and128B payload','output logic rsp_valid' in bank and 'output logic[11:0]rsp_vector_addr' in bank and 'output logic[31:0][31:0]rsp_data' in bank)
check('type exactly96x32F32 words','for(genvar lane=0;lane<32;lane++)'in bank and 'logic[31:0]words[0:95]'in bank)
check('type held idle and setup qualification','assign bank_idle=!rsp_valid;'in bank and 'rst_n&&!model_committed&&!inference_active&&bank_idle&&wr_index<96'in bank and 'rst_n&&model_committed&&rd_qtype<3&&(!rsp_valid||rsp_ready)'in bank)
check('type control sequential assignments only',set(re.findall(r'\b(\w+)(?:\[[^\n]*?\])?\s*<=',bank))=={'rsp_valid','rsp_vector_addr','words','rsp_data'})
check('VECTOR external48 no op FF','input logic[47:0]external_control_q'in vec and 'TYPE_LEASE,TYPE_RUN,TYPE_RELEASE'in vec and 'q_view[43+:5]'in vec and 'q_view[31+:12]'in vec)
check('VECTOR full-address atomic join','q_rsp_addr==type_rsp_addr'in vec and 'assign type_rsp_ready='in vec and 'assign q_rsp_ready='in vec)
check('VECTOR type response in debt barrier','issued_vectors==retired_vectors&&!h_rsp_valid&&!q_rsp_valid&&!type_rsp_valid'in vec)
bm=read(a.build/'report.json');check('actual selected joint build',bm['status']=='BUILD_COMPLETE'and bm['kind']=='joint')
for n,d in bm['compiled_source_sha256'].items():check('actual compiled current source '+n,sha(ROOT/n)==d)
check('actual runtime parameters',v.read_text().splitlines()==['0','0','1'])
lines=h.read_text().splitlines()
for suffix in ['/dut/joint/workspace','/dut/resources/fp','/dut/resources/div','/dut/resources/qkv','/dut/hidden','/dut/scratch','/dut/type_bank','/dut/ln_provider','/dut/g_pool','/dut/g_tanh','/dut/g_tanh/credit']:
 check('actual unique resource '+suffix,sum(x.endswith(suffix)for x in lines)==1)
core_paths=[x for x in lines if '/dut/g_tanh/'in x and re.fullmatch(r'tanh_lane\[[0-7]\]\.core',x.rsplit('/',1)[-1].strip().lstrip('\\'))]
check('actual eight numerical cores',len(core_paths)==8 and {int(re.search(r'\[([0-7])\]',x).group(1))for x in core_paths}==set(range(8)))
check('actual VECTOR no local FF scope',not any('/dut/joint/vector_engine/local_control'in x for x in lines))
records=[]
for rp in sorted((RUN/'attempts').glob('AT*/receipt.json')):
 r=read(rp)
 if r['status']in ['RUNNING','WAITING_LOCK']:continue
 check('cleanup '+rp.parent.name,not r.get('owned_after_cleanup',[])and not r.get('owned_group_after_cleanup_exists',False))
 with tarfile.open(rp.parent/'sources.tar.gz')as tar:
  for n,d in r['source_sha256'].items():check('archive '+rp.parent.name+' '+n,hashlib.sha256(tar.extractfile(n).read()).hexdigest()==d)
 records.append({'attempt':rp.parent.name,'status':r['status'],'receipt_sha256':sha(rp)})
for at in ['AT002_declared_type_VECTOR_unit_build','AT009_TANHv2_production_joint_v3_build','AT011_settled_LN_admission_TANHv2_joint_build']:
 p=RUN/'attempts'/at/'work';m=read(p/'report.json')
 for n,d in m['snapshot'].items():check('snapshot '+at+' '+n,sha(p/n)==d)
if a.tanh_version=='v3':
 p=a.build;m=bm
 for n,d in m['snapshot'].items():check('snapshot currentv3 '+n,sha(p/n)==d)
control={'new_control_bits':13,'VECTOR_external_control_bits':48,'VECTOR_new_control_bits':0,'wrapper_new_FF_bits':0,'type_RAM_bytes':12288,'type_response_payload_bytes':128,'prior_known_control_projection_bits_before_parent':32491,'new_known_projection_before_parent_bits':32504,'parent_and_final_physical_fit':'NOT_ASSESSED'}
report={'status':'PASS','scope':'D29 source/version/archive/snapshot/single-resource actual hierarchy and declared control audit; parent/physical not assessed','checks_count':len(checks),'checks':checks,'actual_hierarchy_scopes':len(lines),'actual_core_paths':core_paths,'core_instances':8,'TANH8_instances':1,'type_bank_instances':1,'TANH_version':a.tanh_version,'body_sha256':sha(body),'header_sha256':sha(hdr),'public_ports':475,'control_census':control,'hierarchy_sha256':sha(h),'actual_parameters_sha256':sha(v),'terminal_receipts':records,'limits':['Parent guarantees4096 finite H_LOAD commits; wrapper cannot detect arbitrary matching early pseudo-events','No preceding28layers/setup/full final gamma-type/Decision/30layers/physical timing conclusion']}
(o/'report.json').write_text(json.dumps(report,indent=2)+'\n');print('HARDWARE_AGENT_SIM_PASS TYPE29_RELEASE_AUDIT checks='+str(len(checks)))
