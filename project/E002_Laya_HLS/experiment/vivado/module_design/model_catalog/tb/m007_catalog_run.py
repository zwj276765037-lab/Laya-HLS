#!/usr/bin/env python3
"""E020 frozen-input reference, reader build/census and public RTL runner."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tarfile

MODULE=Path(__file__).resolve().parents[1]
EXPERIMENT=MODULE.parents[2]
LOCAL=MODULE.relative_to(EXPERIMENT)
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
READER=LOCAL/'rtl/laya_m007_catalog_reader_v1.sv'
TB=LOCAL/'tb/m007_catalog_tb.sv'

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def save(path,value):path.write_text(json.dumps(value,indent=2)+'\n')
def inventory(path):return {str(p.relative_to(path)):sha(p) for p in sorted((path/'xsim.dir').rglob('*')) if p.is_file()}
def execute(argv,cwd):
 print('COMMAND',list(map(str,argv)),flush=True)
 process=subprocess.Popen(list(map(str,argv)),cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,bufsize=1)
 lines=[]
 for line in process.stdout:print(line,end='',flush=True);lines.append(line)
 code=process.wait();log=''.join(lines)
 if code or re.search(r'(?im)^\s*(?:Fatal|ERROR):',log):raise RuntimeError(f'tool failure exit={code}')
 return log

def census(path):
 text=re.sub(r'//[^\n]*','',path.read_text())
 compact=re.sub(r'\s+','',text)
 assert len(re.findall(r'\balways_ff\b',text))==1
 assert re.findall(r'\balways\b',text)==[]
 body=text[text.index('always_ff'):]
 assert set(re.findall(r'\b([a-zA-Z_]\w*)\s*<=',body))=={'state'}
 assert len(re.findall(r'logic\s*\[1:0\]\s*state\s*;',text))==1
 assert 'localparamlogic[1:0]IDLE=0,AR=1,RSP=2,DRAIN=3;' in compact
 assert 'AR:if(arvalid&&arready)state<=RSP;' in compact
 assert 'RSP:if(rsp_valid&&rsp_ready)state<=rlast?IDLE:DRAIN;' in compact
 assert 'DRAIN:if(rvalid&&rready&&rlast)state<=IDLE;' in compact
 assert 'assignarvalid=rst_n&&state==AR;' in compact
 assert 'assignrsp_valid=rst_n&&state==RSP&&rvalid;' in compact
 assert 'assignrsp_data=rdata;' in compact
 assert 'assignrready=rst_n&&((state==RSP&&rsp_ready)||state==DRAIN);' in compact
 assert 'assignfault=rsp_valid&&(rid!=3\'d7||rresp!=2\'b00||!rlast);' in compact
 return {'status':'PASS_SOURCE_SEQUENTIAL_CENSUS','control_FF_bits':2,'control_names':{'state':2},'payload_FF_bits':0,'address_FF_bits':0,'identity_FF_bits':0,'descriptor_slots_in_reader':0,'sequential_block_count':1,'source_sha256':sha(path),'synthesis':'NOT_RUN','physical_resources_or_timing':'NOT_RUN'}

def main():
 p=argparse.ArgumentParser();p.add_argument('stage',choices=('reference','build','rtl'));p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path);p.add_argument('--fixture',type=Path);a=p.parse_args()
 output=a.output;output.mkdir(parents=True,exist_ok=False);frozen=output/'frozen';frozen.mkdir()
 with tarfile.open(output.parent/'sources.tar.gz','r:gz') as archive:archive.extractall(frozen,filter='data')
 assert sha(Path(__file__))==sha(frozen/LOCAL/'tb/m007_catalog_run.py'),'runner snapshot differs'
 if a.stage=='reference':
  log=execute([sys.executable,frozen/'tests/test_m007_model_catalog.py','--output',output/'host'],output)
  host=json.loads((output/'host/report.json').read_text());assert host['status']=='PASS'
  save(output/'report.json',dict(host,driver_sha256=sha(Path(__file__)),host_report_sha256=sha(output/'host/report.json'),fixture_sha256=sha(output/'host/catalog.hex')))
 elif a.stage=='build':
  save(output/'reader_control_census.json',census(frozen/READER))
  execute([VIV/'xvlog','--sv',frozen/READER,frozen/TB],output)
  execute([VIV/'xelab','work.m007_catalog_tb','--relax','-mt','4','--O3','-s','catalog28_sim'],output)
  save(output/'report.json',{'status':'BUILD_COMPLETE','sources_sha256':{str(x):sha(frozen/x) for x in (READER,TB)},'driver_sha256':sha(Path(__file__)),'census_sha256':sha(output/'reader_control_census.json'),'snapshot':inventory(output)})
 else:
  assert a.build is not None and a.fixture is not None
  build=json.loads((a.build/'report.json').read_text());assert build['driver_sha256']==sha(Path(__file__))
  for name,digest in build['sources_sha256'].items():assert sha(frozen/name)==digest and sha(EXPERIMENT/name)==digest
  for name,digest in build['snapshot'].items():assert sha(a.build/name)==digest
  fixture=a.fixture/'catalog.hex';host=json.loads((a.fixture/'report.json').read_text());assert host['status']=='PASS'
  assert fixture.read_text().count('\n')==128
  identity={'catalog_hex_sha256':sha(fixture),'catalog_bin_sha256':sha(a.fixture/'catalog.bin'),'host_report_sha256':sha(a.fixture/'report.json'),'type_reference_comparison_sha256':sha(a.fixture/'type_reference_comparison.json'),'source_sha256':build['sources_sha256'],'build_report_sha256':sha(a.build/'report.json')}
  save(output/'input_identity.json',identity);save(output/'snapshot_prerun_sha256.json',inventory(a.build))
  log=execute([VIV/'xsim','catalog28_sim','-runall','-testplusarg','CATALOG='+str(fixture),'-testplusarg','PROGRESS_FILE='+str(output/'semantic_progress.jsonl')],a.build)
  (output/'xsim.log').write_text(log)
  assert 'HARDWARE_AGENT_SIM_PASS CATALOG_READER' in log
  match=re.search(r'CATALOG_READER_PASS requests=(\d+) ar=(\d+) r=(\d+) responses=(\d+) faults=(\d+) drains=(\d+) commits=(\d+) ar_held=(\d+) r_held=(\d+) drain_bubbles=(\d+) reset_edges=(\d+) cycles=(\d+)',log);assert match
  measurements=dict(zip(('requests','actual_AR','actual_R','parent_responses','faults','actual_drain_beats','two_peer_slot_commits','AR_held_cycles','R_held_cycles','debt_bubble_cycles','reset_edges','cycles'),map(int,match.groups())))
  assert [measurements[k] for k in ('requests','actual_AR','actual_R','parent_responses','faults','actual_drain_beats','two_peer_slot_commits')]==[132,131,132,129,3,3,121]
  progress=[json.loads(line) for line in (output/'semantic_progress.jsonl').read_text().splitlines()];assert progress[-1]['checked']==132
  post=inventory(a.build);assert all(post[name]==digest for name,digest in build['snapshot'].items());save(output/'snapshot_postrun_sha256.json',post)
  save(output/'report.json',{'status':'PASS_PUBLIC_CATALOG_READER','measurements':measurements,'independent_input_identity':identity,'last_checked_consumption':progress[-1],'reader_control_FF_bits':2,'TB_peer_descriptor_slots':2,'production_W_mux_transport_idle':'NOT_RUN','device_setup_or_model_committed':'NOT_RUN','arbitrary_late_prereset_RID7':'OUTSIDE_COMMON_PEER_RESET_CONTRACT','actual_DMA':'NOT_RUN','OOC_PnR_board_timing':'NOT_RUN'})
if __name__=='__main__':main()
