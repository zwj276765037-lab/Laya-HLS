#!/usr/bin/env python3
"""Archive bounded raw build/runtime evidence after success or first failure."""
from __future__ import annotations
import argparse,hashlib,json,shutil
from pathlib import Path

def sha(path):
    h=hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda:stream.read(1<<20),b''): h.update(block)
    return h.hexdigest()

def main():
    p=argparse.ArgumentParser()
    p.add_argument('mode',choices=('base_h15_r63','changed_h0_r0'))
    p.add_argument('stage',choices=('materialize','static','runtime'))
    p.add_argument('attempt_dir',type=Path)
    p.add_argument('archive_dir',type=Path)
    p.add_argument('--build',type=Path)
    args=p.parse_args()
    assert not args.archive_dir.exists(),args.archive_dir
    if args.stage=='runtime': assert args.build is not None
    args.archive_dir.mkdir(parents=True)
    names={'materialize':['guard/driver.log','guard/guard_result.json',
                          'independent_page_check.json','prepared/materialization.json'],
           'static':['guard/driver.log','guard/guard_result.json','binding_pre.json',
                     'binding_post.json','xvhdl.log','xvlog_dut.log','xvlog_tb.log','xelab.log'],
           'runtime':['guard/driver.log','guard/guard_result.json','binding_pre.json',
                      'binding_post.json','xsim.log','runtime_seal.json','numeric_check.json',
                      *[f'observed_{i}.hex' for i in range(4)],
                      *[f'att_out_{i}.hex' for i in range(4)]]}[args.stage]
    rows=[]; missing=[]
    for name in names:
        source=args.attempt_dir/name
        if not source.is_file():
            missing.append(name); continue
        target=args.archive_dir/name
        target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(source,target)
        rows.append({'source':str(source.resolve()),'relative_path':name,
                     'bytes':target.stat().st_size,'sha256':sha(target)})
    if args.stage=='runtime':
        snapshot=args.build/'xsim.dir'/f'att_finite_{args.mode}_static'
        for name in ('xsim_script.tcl','xsimSettings.ini','xsimkernel.log','xsimcrash.log'):
            source=snapshot/name
            relative='snapshot_runtime_artifacts/'+name
            if not source.is_file():
                missing.append(relative); continue
            target=args.archive_dir/relative
            target.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(source,target)
            rows.append({'source':str(source.resolve()),'relative_path':relative,
                         'bytes':target.stat().st_size,'sha256':sha(target)})
    manifest={'schema':'attention_v5_finite_attempt_archive_v1','mode':args.mode,
              'stage':args.stage,'files':rows,'missing':missing,
              'scope':'Copies named raw evidence present after an attempt; missing entries are recorded, not inferred as success.'}
    (args.archive_dir/'manifest.json').write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n')
    print(f'ATT_FINITE_ATTEMPT_ARCHIVED mode={args.mode} stage={args.stage} files={len(rows)} missing={len(missing)}')

if __name__=='__main__': main()
