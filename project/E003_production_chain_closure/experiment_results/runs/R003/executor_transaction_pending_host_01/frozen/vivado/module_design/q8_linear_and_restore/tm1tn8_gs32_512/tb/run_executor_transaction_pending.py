#!/usr/bin/env python3
"""Freeze and guard the full LTP1 codec host test; no HLS/RTL invocation."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import struct
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[5]
PROJECT=ROOT.parents[2]
MODULE=Path('vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512')
MODEL=Path('build/model-current-production-v2-20261011')
SOURCE=Path('hls/control/executor_transaction_pending.cpp')
TEST=Path('tests/executor_transaction_pending_test.cpp')
HEADER=Path('include/laya_executor_transaction_pending.h')
SOURCES=[Path('hls/common/'+name+'.cpp') for name in
         ['laya_numeric','laya_tasks','laya_task_retirement','laya_memory_map',
          'laya_full_memory','laya_full_owner','laya_full_io']]
SOURCES += [Path('hls/platform/'+name+'.cpp') for name in
            ['compute_portal_client','controller_transaction_codec','compute_portal_codec',
             'generated_provenance_codec','producer_engine_codec']]
SOURCES += [Path('hls/control/graph_action_protocol.cpp'),
            Path('hls/control/admission_owner_protocol.cpp'),SOURCE]
DEFINES=['-DLAYA_PARTITIONED_PRODUCTION_CALLER','-DLAYA_CONTROLLER_TRANSACTION_SEQUENCER']
VITIS_INCLUDE=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include')
PREFIX='FULL_CURRENT_EXECUTOR_TRANSACTION_PENDING_'
CASES=['end_cleanup','end_ordinary','invalidate_cleanup','invalidate_ordinary',
       'release','claim','begin','publish','compute','producer']
SCOPE=('Pure LTP1 codec: original complete 512B LAX and 1536B LTX, persistent '
       'four-word K/route and a reference to the one retained full A. Full actual '
       'action/transaction codecs and canonical bytes, complete NumericIdentity '
       'and416B model against provided old A. No owner table, collector/adapter '
       'pop/occupancy, physical binding immutability proof, hub permission, '
       'publication, allocator, helper commit, retirement, executor generation '
       'or RTL acceptance. Identical retry bytes may belong to the next real slot.')


def rec(path):
    path=Path(path).resolve();digest=hashlib.sha256();size=0
    with path.open('rb') as stream:
        for block in iter(lambda:stream.read(1024*1024),b''):
            digest.update(block);size+=len(block)
    return {'path':str(path),'bytes':size,'sha256':digest.hexdigest()}


def write_json(path,value):
    Path(path).write_text(json.dumps(value,indent=2,sort_keys=True)+'\n')


def verify(records):
    for item in records:
        if rec(item['path'])!=item:raise RuntimeError('identity changed: '+item['path'])


def launcher_state():
    available=next(int(line.split()[1]) for line in Path('/proc/meminfo').read_text().splitlines()
                   if line.startswith('MemAvailable:'))
    io=subprocess.run(['/usr/bin/ionice','-p',str(os.getpid())],check=True,
                      capture_output=True,text=True).stdout.strip()
    state={'cpu_affinity':sorted(os.sched_getaffinity(0)),
           'nice':os.getpriority(os.PRIO_PROCESS,0),'ionice':io,'mem_available_kib':available}
    state['pass']=state['cpu_affinity']==[0,1,2,3] and state['nice']==19 and \
        io.startswith('idle') and available>192*1024*1024
    return state


def guarded(attempt,name,command,cwd,guard,marker=None,artifact=None):
    output=attempt/('guard_'+name)
    if output.exists():raise RuntimeError('guard output already exists')
    args=[sys.executable,str(guard),'--out',str(output),'--cwd',str(cwd),'--rss-gib','24',
          '--timeout-seconds','1800','--semantic-stall-seconds','120']
    if artifact is not None:args+=['--artifact-progress-root',str(artifact)]
    args+=['--',*map(str,command)]
    done=subprocess.run(args,cwd=cwd)
    result_path=output/'guard_result.json'
    result=json.loads(result_path.read_text()) if result_path.is_file() else \
        {'child_exit_code':None,'trigger':'guard_result_missing'}
    log=output/'driver.log';body=log.read_text(errors='replace') if log.is_file() else ''
    passed=done.returncode==0 and result.get('child_exit_code')==0 and result.get('trigger') is None and \
        (marker is None or body.count(marker)==1)
    return {'status':'PASS' if passed else 'COST_STOP' if result.get('trigger') else 'FAIL',
            'started':True,'command':args,'runner_exit_code':done.returncode,'guard':result,
            'driver_log':rec(log) if log.is_file() else None,
            'guard_files':[rec(p) for p in sorted(output.rglob('*')) if p.is_file()],
            'markers':[line for line in body.splitlines() if marker and marker in line]}


def dependency_worker(spec_path):
    spec=json.loads(spec_path.read_text());root=Path(spec['root'])
    raw=Path(spec['raw']);raw.mkdir(exist_ok=False);project=set();external=set();units=[]
    for index,unit in enumerate(spec['units']):
        command=[spec['compiler'],*spec['flags'],*unit['defines'],'-M',str(root/unit['source'])]
        done=subprocess.run(command,cwd=root,capture_output=True,text=True)
        stdout=raw/f'{index:02d}.stdout';stderr=raw/f'{index:02d}.stderr'
        stdout.write_text(done.stdout);stderr.write_text(done.stderr)
        item={'mode':unit['mode'],'source':unit['source'],'command':command,
              'exit_code':done.returncode,'stdout':rec(stdout),'stderr':rec(stderr)}
        write_json(raw/f'{index:02d}.json',item)
        if done.returncode:raise RuntimeError('dependency extraction failed: '+unit['source'])
        names=shlex.split(done.stdout.replace('\\\n',' ').split(':',1)[1])
        files=sorted({Path(name).resolve() for name in names});item['files']=[rec(p) for p in files]
        units.append(item)
        for path in files:(project if path.is_relative_to(root) else external).add(path)
        print(PREFIX+f'DEPENDENCY_PROGRESS units={index+1}',flush=True)
    for item in units:verify(item['files'])
    write_json(spec['output'],{'files':[rec(p) for p in sorted(project)],
                              'external_files':[rec(p) for p in sorted(external)],'units':units})
    print(PREFIX+'DEPENDENCY_PASS',flush=True)


def build_worker(spec_path):
    spec=json.loads(spec_path.read_text());objects=Path(spec['objects']);objects.mkdir(exist_ok=False)
    built=[]
    for index,unit in enumerate(spec['units']):
        obj=objects/f'{index:02d}_{Path(unit).stem}.o'
        subprocess.run([spec['compiler'],*spec['flags'],'-c',unit,'-o',str(obj)],cwd=spec['cwd'],check=True)
        built.append(str(obj));print(PREFIX+f'BUILD_PROGRESS units={index+1}',flush=True)
    # Link the real dependency closure. No stubs or gc-sections workaround.
    subprocess.run([spec['compiler'],*built,'-o',spec['binary']],cwd=spec['cwd'],check=True)
    print(PREFIX+'BUILD_PASS',flush=True)


def fixture_worker(model_header,output):
    output.mkdir(exist_ok=False);text=model_header.read_text()
    def array(name,count):
        match=re.search(r'\b'+name+r'\['+str(count)+r'\]\s*=\s*\{([^}]+)\}',text)
        if not match:raise RuntimeError('model header literal missing: '+name)
        values=[int(x,0) for x in re.findall(r'0x[0-9a-fA-F]+|\d+',match[1])]
        if len(values)!=count:raise RuntimeError('model header literal size: '+name)
        return values
    def put(p,at,value,size):p[at:at+size]=value.to_bytes(size,'little')
    def ref(p,at,epoch,buffer,bank=0):struct.pack_into('<IBBBB',p,at,epoch,buffer,bank,0,0)
    def context(p,at,task,op):struct.pack_into('<IBBBBBHB',p,at,task,op,2,1,0,0,16,16)
    tags=b''.join(bytes(array('kFull'+name+'Tag',16)) for name in ['Model','Numeric','Layout','Build'])
    identity=struct.pack('<QQHH',1101,51,1,64)+tags
    model=bytearray(416);model[:64]=tags
    struct.pack_into('<IHHII',model,64,0x4d33314c,1,416,0,1)
    model[80:112]=bytes(array('kFullSourceSha256',32));struct.pack_into('<III',model,112,5,16,128)
    for index,(role,size) in enumerate(zip([0,2,3,4,5],array('kFullModelBoSizes',5))):
        struct.pack_into('<IIQ',model,128+16*index,role,1,size)
    owner=bytearray(1024);struct.pack_into('<IHHIIQQ',owner,0,0x3144414c,1,16,3,1<<6,29,101)
    owner[64:148]=identity;owner[160:576]=model
    struct.pack_into('<QQQ',owner,576+6*24,7,0x1200000000,16920576)
    action=bytearray(512);struct.pack_into('<IHH5B',action,0,0x3158414c,1,8,2,0,0x11,2,1)
    put(action,24,1,8);action[64:148]=identity;put(action,168,1,8);ref(action,176,1,1)
    action[184:188]=bytes([2,0,255,0]);struct.pack_into('<HHHB',action,188,0,64,1024,1)
    action[224:228]=bytes([1,2,0,0]);put(action,232,1,8);action[257]=255
    (output/'owner.bin').write_bytes(owner);(output/'action.bin').write_bytes(action)
    def common(kind,protocol,seq,origin,flags):
        p=bytearray(1536);struct.pack_into('<IHHHH',p,0,0x3158544c,1,24,kind,protocol)
        put(p,16,seq,8);put(p,24,origin,8);put(p,32,flags,4);p[64:148]=identity;p[160:576]=model
        return p
    def provenance(protocol,flags):
        task_event=protocol in [2,3]
        p=common(2,protocol,52 if protocol==3 else 51 if protocol==2 else 54+protocol,
                 51 if task_event else 0,flags)
        if task_event:
            context(p,148,20,0x11);p[580]=1;put(p,600,16384,4)
            if protocol==3:p[578]=1;put(p,584,16384,4);put(p,608,65536,8)
        p[579]=1;ref(p,624,2,2)
        p[642:646]=bytes([2,1,255,0]);struct.pack_into('<HHHBBB',p,646,0,64,1024,1,0,6)
        struct.pack_into('<7Q',p,656,16920576,0,4096,4194304,262144,0,0)
        if task_event:
            struct.pack_into('<QIHHQQQBBB',p,880,65536,4096,16,1,4096,0,65536,0,255,0)
        return p
    requests={name:provenance(protocol,flags) for name,protocol,flags in
              [('end_cleanup',3,1),('end_ordinary',3,0),('invalidate_cleanup',6,1),
               ('invalidate_ordinary',6,0),('release',5,1),('claim',1,1),('begin',2,1),('publish',4,1)]}
    p=common(1,3,101,0,1);context(p,148,19,0x30)
    context(p,576,17,0x11);context(p,588,18,0x20);context(p,600,19,0x30)
    for at,epoch,buffer in [(612,2,2),(620,3,0x22),(628,4,0x23),(636,5,0x24),(644,6,5),(652,6,5)]:
        ref(p,at,epoch,buffer)
    p[663]=8;struct.pack_into('<IIHHHBBBBB',p,668,3,4,1024,1024,0x101,4,4,0,0,0)
    struct.pack_into('<3Q',p,688,12*1024*1024,16*4096,16*4096)
    struct.pack_into('<QQ',p,736,4096,4194304);requests['compute']=p
    p=common(3,1,103,51,1);context(p,148,20,0x11);ref(p,576,1,1);ref(p,584,2,2)
    p[594:598]=bytes([6,6,0,1]);put(p,600,1024,2);put(p,604,16384,4)
    struct.pack_into('<II6Q',p,608,0x3727c5ac,4096,65536,8388608+65536,4096,4096,16920576,16920576)
    requests['producer']=p
    def ltp(tx,hold=True,route=1):
        p=bytearray(2112);struct.pack_into('<IHHBB',p,0,0x3150544c,1,33,route,int(hold))
        struct.pack_into('<4Q',p,16,29,101,1 if hold else 0,19 if hold else 0)
        p[64:576]=action;p[576:2112]=tx;return p
    for name in CASES:
        (output/(name+'_ltx.bin')).write_bytes(requests[name])
        (output/(name+'_ltp.bin')).write_bytes(ltp(requests[name]))
    (output/'no_hold_ltp.bin').write_bytes(ltp(requests['end_cleanup'],False,0))
    print(PREFIX+'FIXTURE_PASS literal_records=11 owner_bytes=1024 action_bytes=512 record_bytes=2112',flush=True)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--attempt',type=Path)
    parser.add_argument('--dependency-worker',type=Path,help=argparse.SUPPRESS)
    parser.add_argument('--build-worker',type=Path,help=argparse.SUPPRESS)
    parser.add_argument('--fixture-worker',type=Path,help=argparse.SUPPRESS)
    parser.add_argument('--model-header',type=Path,help=argparse.SUPPRESS)
    args=parser.parse_args()
    if args.dependency_worker:dependency_worker(args.dependency_worker);return 0
    if args.build_worker:build_worker(args.build_worker);return 0
    if args.fixture_worker:
        if not args.model_header:parser.error('--model-header required for fixture worker')
        fixture_worker(args.model_header,args.fixture_worker);return 0
    if not args.attempt:parser.error('--attempt is required')
    attempt=args.attempt.resolve();attempt.mkdir(parents=True,exist_ok=False)
    receipt={'schema':'laya-transaction-pending-host-receipt-v1','status':'PREPARING','scope':SCOPE,
             'operations':{},'HLS':'NOT_RUN','RTL':'NOT_RUN','collector_adapter_pop':'NOT_RUN',
             'physical_A_immutability':'NOT_RUN','hub_permission':'NOT_RUN','retirement':'NOT_RUN'}
    manifest={'schema':'laya-transaction-pending-input-v1','scope':SCOPE,'files':[],
              'sources':[str(p) for p in SOURCES],'source_count':len(SOURCES),'defines':DEFINES,
              'full_request_decoder_enabled':True,'record_bytes':2112,'record_beats':33,
              'profile':{'cpu_ids':[0,1,2,3],'nice':19,'io_class':'idle',
                         'mem_available_gib_strictly_greater_than':192,'rss_gib':24,
                         'wall_seconds_per_stage':1800,'semantic_stall_seconds':120,
                         'one_heavy_tool_at_a_time':True}}
    def save():
        write_json(attempt/'input_manifest.json',manifest);receipt['input_manifest']=rec(attempt/'input_manifest.json')
        write_json(attempt/'receipt.json',receipt)
    save()
    try:
        launcher=launcher_state();write_json(attempt/'launcher.json',launcher)
        manifest['launcher']=rec(attempt/'launcher.json');save()
        if not launcher['pass']:receipt['status']='FAIL_LAUNCHER';save();return 1
        frozen=attempt/'frozen';runner=Path(__file__).resolve().relative_to(ROOT)
        def copy(source,relative,expected=None):
            original=rec(source)
            if expected is not None and original!=expected:raise RuntimeError('dependency changed before copy')
            target=frozen/relative
            if target.exists():
                if any(rec(target)[k]!=original[k] for k in ['bytes','sha256']):raise RuntimeError('frozen mismatch')
                return
            target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target);copied=rec(target)
            if rec(source)!=original or any(copied[k]!=original[k] for k in ['bytes','sha256']):
                raise RuntimeError('copy identity changed')
            manifest['files'].append({'relative':str(relative),'original':original,'frozen':copied})
        fixed=SOURCES+[HEADER,TEST,runner,MODULE/'tb/production_guard.py',Path('tools/hls_guard_helpers.py'),
                       MODEL/'laya_model_layout_generated.h',MODEL/'manifest.json']
        for path in fixed:copy(ROOT/path,path)
        for name in ['executor_old_ltx_cleanup_contract_20261013.md','executor_managed_lpv_owner_contract_20261013.md',
                     'production_hls_partition_contract_20261012.md']:
            copy(PROJECT/'results'/name,Path('external/contracts')/name)
        compiler=Path(shutil.which('g++') or '/missing-g++').resolve()
        manifest['tools']=[rec(compiler),rec(sys.executable)]
        manifest['SDK_seeds']=[rec(VITIS_INCLUDE/'ap_int.h'),rec(VITIS_INCLUDE/'hls_stream.h')]
        guard=frozen/MODULE/'tb/production_guard.py'
        live_flags=['-std=c++17',*DEFINES,'-I'+str(ROOT/'include'),'-I'+str(ROOT/'hls'),
                    '-I'+str(ROOT/'hls/platform'),'-I'+str(ROOT/MODEL),'-isystem',str(VITIS_INCLUDE)]
        dep_spec=attempt/'dependency_spec.json';dep_output=attempt/'dependencies.json'
        units=[{'source':str(p),'mode':'full_codec_host','defines':[]} for p in SOURCES+[TEST]]
        units += [{'source':str(SOURCE),'mode':'FIRST_metadata_encode_only',
                   'defines':['-DLAYA_TRANSACTION_SEQUENCER_CODEC']}]
        write_json(dep_spec,{'root':str(ROOT),'compiler':str(compiler),'flags':live_flags,
                             'units':units,'raw':str(attempt/'dependency_raw'),'output':str(dep_output)})
        manifest['dependency_spec']=rec(dep_spec);save()
        result=guarded(attempt,'dependencies',[sys.executable,str(frozen/runner),'--dependency-worker',str(dep_spec)],
                       ROOT,guard,PREFIX+'DEPENDENCY_PASS')
        receipt['operations']['dependencies']=result;save()
        if result['status']!='PASS':receipt['status']=result['status'];save();return 1
        dependencies=json.loads(dep_output.read_text())
        for item in dependencies['files']:copy(item['path'],Path(item['path']).relative_to(ROOT),item)
        for item in dependencies['external_files']:
            copy(item['path'],Path('external/header_inputs')/Path(item['path']).relative_to('/'),item)
        manifest['dependencies']=rec(dep_output);manifest['external_headers']=dependencies['external_files']
        manifest['frozen_closure_complete']=True
        def stable():
            verify(manifest['tools']);verify(manifest['SDK_seeds']);verify(manifest['external_headers'])
            for item in manifest['files']:verify([item['frozen']])
        stable()
        result=guarded(attempt,'compiler_version',[str(compiler),'--version'],frozen,guard)
        receipt['operations']['compiler_version']=result;manifest['compiler_version_log']=result['driver_log'];save()
        if result['status']!='PASS':receipt['status']=result['status'];save();return 1
        fixture=attempt/'fixture';binary=attempt/'executor_transaction_pending_test';build_spec=attempt/'host_build_spec.json'
        flags=['-std=c++17','-O1','-Wall','-Wextra','-Werror','-Wno-unknown-pragmas',
               '-Wno-unused-parameter','-Wno-aggressive-loop-optimizations',*DEFINES,
               '-I'+str(frozen/'include'),'-I'+str(frozen/'hls'),'-I'+str(frozen/'hls/platform'),
               '-I'+str(frozen/MODEL),'-isystem',str(VITIS_INCLUDE)]
        if any('LAYA_TRANSACTION_SEQUENCER_CODEC' in flag for flag in flags):raise RuntimeError('full codec disabled')
        write_json(build_spec,{'compiler':str(compiler),'cwd':str(frozen),'flags':flags,
                              'units':[str(frozen/p) for p in SOURCES+[TEST]],
                              'objects':str(attempt/'host_objects'),'binary':str(binary)})
        manifest['host_build_spec']=rec(build_spec)
        commands={'oracle':[sys.executable,str(frozen/runner),'--fixture-worker',str(fixture),
                            '--model-header',str(frozen/MODEL/'laya_model_layout_generated.h')],
                  'host_build':[sys.executable,str(frozen/runner),'--build-worker',str(build_spec)],
                  'host':[str(binary),str(fixture)]}
        manifest['planned_commands']=commands;save();stable()
        result=guarded(attempt,'oracle',commands['oracle'],frozen,guard,PREFIX+'FIXTURE_PASS')
        receipt['operations']['oracle']=result;save()
        if result['status']!='PASS':receipt['status']=result['status'];save();return 1
        expected={p.name:rec(p) for p in sorted(fixture.iterdir()) if p.is_file()}
        names={'owner.bin','action.bin','no_hold_ltp.bin'}|{name+suffix for name in CASES for suffix in ['_ltx.bin','_ltp.bin']}
        if set(expected)!=names:raise RuntimeError('fixture file set mismatch')
        for item in expected.values():copy(item['path'],Path('external/fixture_inputs')/Path(item['path']).name,item)
        manifest['fixture_inputs']=list(expected.values());save();stable();verify(manifest['fixture_inputs'])
        result=guarded(attempt,'host_build',commands['host_build'],attempt,guard,PREFIX+'BUILD_PASS',attempt/'host_objects')
        receipt['operations']['host_build']=result;save();stable()
        if result['status']!='PASS':receipt['status']=result['status'];save();return 1
        receipt['executable']=rec(binary);verify(manifest['fixture_inputs'])
        result=guarded(attempt,'host',commands['host'],frozen,guard,PREFIX+'HOST_PASS')
        receipt['operations']['host']=result;save();stable();verify(manifest['fixture_inputs']);verify([receipt['executable']])
        if result['status']!='PASS':receipt['status']=result['status'];save();return 1
        captures=[]
        for name in CASES+['no_hold']:
            path=fixture/('actual_'+name+'.bin');oracle=fixture/(name+'_ltp.bin')
            data=path.read_bytes();gold=oracle.read_bytes()
            if len(data)!=2112 or len(gold)!=2112 or data!=gold:raise RuntimeError('full independent LTP literal mismatch '+name)
            captures.append({'actual':rec(path),'expected':rec(oracle),'bytes_compared':2112,'pass':True})
        receipt['literal_byte_oracle']=captures;receipt['status']='PASS_SCOPED_HOST';save()
        print(PREFIX+'PASS_SCOPED_HOST',flush=True);return 0
    except Exception as error:
        receipt['status']='FAIL_RUNNER';receipt['error']=str(error);save();raise


if __name__=='__main__':raise SystemExit(main())
