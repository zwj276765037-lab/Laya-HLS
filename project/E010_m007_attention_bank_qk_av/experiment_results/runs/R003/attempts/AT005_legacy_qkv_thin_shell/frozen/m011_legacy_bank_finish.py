#!/usr/bin/env python3
"""AT005 actual before/after artifact observation; does not backdate prior runs."""
import hashlib,json,shutil,subprocess,sys
from pathlib import Path
import m011_r003_block_run as r
at=r.RUN/'attempts/AT005_legacy_qkv_thin_shell';w=at/'work';src=Path(__file__).resolve();f=at/'frozen'/src.name
assert not(at/'supplemental_legacy_protocol.json').exists();shutil.copy2(src,f)
r.dump(at/'supplemental_legacy_protocol.json',{'source':str(src.relative_to(r.ROOT)),'frozen_sha256':r.sha(f),'reason':'actual current post-build/pre-RTL observation added before first AT005 dynamic run; prior AT002/003/004 not retroactively changed','artifact_helper_source':str(Path(r.__file__).relative_to(r.ROOT)),'artifact_helper_sha256':r.sha(Path(r.__file__))})
r.artifacts(at,w,'after_build_observed_before_first_rtl');before=r.artifacts(at,w,'before_rtl')
cmd=[sys.executable,str(src.parent/'m011_layer_run.py'),'rtl','bank_legacy','AT005_legacy_qkv_thin_shell'];r.dump(at/'supplemental_legacy_command.json',{'argv':cmd,'project_lock':'nested immutable runner holds lock through guard and descendants'})
rc=subprocess.call(cmd);after=r.artifacts(at,w,'after_rtl');r.dump(at/'supplemental_legacy_receipt.json',{'exit_code':rc,'compiled_products_unchanged':before==after,'actual_rtl_receipt_sha256':r.sha(at/'receipt_rtl.json')})
raise SystemExit(0 if rc==0 and before==after else 1)
