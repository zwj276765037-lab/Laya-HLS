#!/usr/bin/env python3
"""Small independent-format/amax xsim pilot, invoked only through E013 guard."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

ROOT=Path(__file__).resolve().parents[4]
VIV=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
LOCAL=Path('vivado/module_design/activation_quantizer')
SOURCES=[LOCAL/'rtl/laya_m007_quant_format_v1.sv',LOCAL/'rtl/laya_m007_quant_amax32_v1.sv',LOCAL/'tb/m007_quant_local_tb.sv']
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def execute(argv,cwd):
    print('COMMAND '+repr([str(x)for x in argv]),flush=True)
    result=subprocess.run([str(x)for x in argv],cwd=cwd,capture_output=True,text=True)
    print(result.stdout,flush=True);print(result.stderr,flush=True)
    if result.returncode or re.search(r'(?im)^(?:ERROR|FATAL|Fatal):',result.stdout+result.stderr):raise RuntimeError('tool failure')
    return result.stdout+result.stderr
def main():
    p=argparse.ArgumentParser();p.add_argument('--stage',choices=('build','rtl'),required=True)
    p.add_argument('--output',type=Path,required=True);p.add_argument('--fixture',type=Path,required=True)
    p.add_argument('--build',type=Path);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
    fixture=json.loads((a.fixture/'report.json').read_text())
    assert fixture['status']=='PASS_INDEPENDENT_QUANT_REFERENCE'
    for name in('format.hex','edge_input.hex','edge_gold.hex'):
        assert sha(a.fixture/name)==fixture['files'][name]['sha256']
    if a.stage=='build':
        frozen=a.output/'frozen';frozen.mkdir()
        with tarfile.open(a.output.parent/'sources.tar.gz','r:gz')as archive:archive.extractall(frozen,filter='data')
        execute([VIV/'xvlog','--sv',*[frozen/name for name in SOURCES]],a.output)
        execute([VIV/'xelab','work.m007_quant_local_tb','--relax','-mt','4','--O3','-s','m007_quant_local_sim'],a.output)
        (a.output/'source_identity.json').write_text(json.dumps({str(path):sha(ROOT/path)for path in SOURCES},indent=2)+'\n')
        print('M007_QUANT_LOCAL_BUILD_PASS',flush=True)
    else:
        assert a.build
        identity=json.loads((a.build/'source_identity.json').read_text())
        assert all(sha(ROOT/name)==value for name,value in identity.items()),'stale static build'
        argv=[VIV/'xsim','m007_quant_local_sim','-runall']
        for value in('FORMAT='+str(a.fixture/'format.hex'),'EDGES='+str(a.fixture/'edge_input.hex'),
            'GOLD='+str(a.fixture/'edge_gold.hex'),'FORMAT_COUNT='+str(fixture['format_count']),'EDGE_COUNT='+str(fixture['edge_count'])):
            argv+=['-testplusarg',value]
        log=execute(argv,a.build)
        assert 'HARDWARE_AGENT_SIM_PASS M007_QUANT_LOCAL'in log,'missing terminal self-check'
        (a.output/'report.json').write_text(json.dumps({'status':'PASS_LOCAL_FORMAT_AMAX','format_count':fixture['format_count'],
            'amax_checked':fixture['edge_count']+36,'latency_enabled_edges':5,'reset_inflight':True,
            'group_engine':'NOT_RUN','shared_div_integration':'NOT_RUN','timing_300MHz':'NOT_RUN'},indent=2)+'\n')
if __name__=='__main__':main()
