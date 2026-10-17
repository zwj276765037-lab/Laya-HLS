#!/usr/bin/env python3
from pathlib import Path
import hashlib,importlib.util,json,shutil,sys
out,source,ref=map(Path,sys.argv[1:]);out.mkdir()
spec=importlib.util.spec_from_file_location("immutable_reference",ref);mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
for name in ["wi.mem","steps.mem"]:shutil.copy2(source/name,out/name)
words=[int(s,16) for s in (out/"steps.mem").read_text().split()];assert len(words)==26240
values=words[9::10];groups=[]
for g in range(82):
 r=mod.original_r0_group(values[g*32:(g+1)*32],row=0,group=g);assert r["status"]==0 and r["commit"];groups.append(r)
for name,key,width in [("q.mem","q",64),("scale.mem","saved_half",4),("d.mem","d_bits",8),("recip.mem","reciprocal_bits",8)]:
 numbers=[sum((n&255)<<(i*8) for i,n in enumerate(r[key])) if key=="q" else r[key] for r in groups]
 (out/name).write_text("".join(f"{n:0{width}x}\n" for n in numbers))
(out/"independent_quant_gold.json").write_text(json.dumps({"source":"immutable GEGLU original10step gold laststep, then untouched exact-rational original_r0_group","groups":groups},indent=2)+"\n")
print("GEGLU_GATE_QUANT_FIXTURE_PASS groups=82 input_words=5248 gate_gold_words=2624 independent_rational=1")
