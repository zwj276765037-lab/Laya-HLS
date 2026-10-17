"""D-M004-ROPE-REFERENCE-01: evaluate only the frozen independent RoPE oracle.

No DUT imports, full model, LN/matrix evaluation, trig generation, or old-gold writes.
Run once per fresh --output directory; every input and derived product is identified.
"""
import argparse
import ast
from collections import Counter
from datetime import datetime, timezone
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import platform
import resource
import struct
import sys
import time
import traceback

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
E = "project/E002_Laya_HLS/experiment/"
F = E + "results/cpu_embedding_q8_validation_20261010/attempts/task2_real_fixture_20/work/fixtures/"
D2 = E + "results/attention_rtl_repair_20261008/d2_cpu_full_official/"
P2 = E + "results/engineering_p2/20261007T025037Z-1839717/fixture/"
MODEL = E + "build/model-current-production-v2-20261011/"
PARENT = "source/feasibility_20261014/v4/inputs/fe9678e44030ef4c_full_reference.py"
PARENT_SHA = "fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784"
SUPPORT = "source/fixed_graph_support_20261014/"
parser = argparse.ArgumentParser()
parser.add_argument("--output", default=str(Path(__file__).resolve().parent / "run01"))
OUT = Path(parser.parse_args().output).resolve()
if not OUT.is_relative_to(ROOT / SUPPORT):
    raise ValueError("output must remain in research support directory")
OUT.mkdir(parents=True, exist_ok=False)
(OUT / "inputs").mkdir()
(OUT / "products").mkdir()
START = time.monotonic()
checks = []
inputs = []
products = []
source_identities = {}
oracle_calls = Counter()
manifest = dict(schema=1, decision="D-M004-ROPE-REFERENCE-01", created_utc=datetime.now(timezone.utc).isoformat(), status="RUNNING", scope="Derived independent RoPE reference for request3/gen1 B1/S128 token rows0/1 only; not RTL/Check ABI/full128 validation", checks=checks, inputs=inputs, products=products)

def sha(data):
    return hashlib.sha256(data).hexdigest()

def read(path):
    return (ROOT / path).read_bytes()

def source(path):
    data = read(path)
    source_identities[path] = dict(path=path, bytes=len(data), sha256=sha(data))
    return data

def check(name, condition, **detail):
    record = dict(name=name, passed=bool(condition), **detail)
    checks.append(record)
    if not condition:
        raise AssertionError(name)

def freeze(path, name, offset=0, size=None, shape=None, dtype="bytes", role="input"):
    data = source(path)
    size = len(data)-offset if size is None else size
    window = data[offset:offset+size]
    check("window_bounds:"+name, offset >= 0 and len(window) == size)
    dest = OUT / "inputs" / name
    with dest.open("xb") as f:
        f.write(window)
    rec = dict(name=name, role=role, parent=dict(source_identities[path]), offset_bytes=offset, bytes=size, sha256=sha(window), shape=shape, dtype=dtype, endian="little" if dtype.startswith("<") else "not_applicable", frozen_path=str(dest.relative_to(ROOT)))
    inputs.append(rec)
    return window

def save(name, data, shape, dtype, derivation):
    path=OUT / "products" / name
    with path.open("xb") as f:
        f.write(data)
    rec=dict(path=str(path.relative_to(ROOT)),bytes=len(data),sha256=sha(data),shape=shape,dtype=dtype,endian="little",order="C",derivation=derivation)
    products.append(rec)
    return rec

def compare(label, got, expected):
    check(label+":bytes",len(got)==len(expected),bytes=len(got))
    diffs=[i for i,(a,b) in enumerate(zip(struct.iter_unpack("<I",got),struct.iter_unpack("<I",expected))) if a!=b]
    check(label,not diffs,compared_f32=len(got)//4,bit_mismatches=len(diffs),first_mismatch=diffs[0] if diffs else None,got_sha256=sha(got),expected_sha256=sha(expected))

def finish_sampling():
    return dict(wall_seconds_inside_script=time.monotonic()-START,maxrss_kib=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,affinity=sorted(os.sched_getaffinity(0)),nice=os.getpriority(os.PRIO_PROCESS,0),rlimit_as_bytes=list(resource.getrlimit(resource.RLIMIT_AS)),interactive_reads="UNKNOWN")

try:
    script=Path(__file__).resolve().read_bytes()
    manifest["caller"]=dict(path=str(Path(__file__).resolve().relative_to(ROOT)),bytes=len(script),sha256=sha(script))
    (OUT/"prepare_reference.frozen.py").write_bytes(script)
    check("affinity_0_3_nice19",sorted(os.sched_getaffinity(0))==[0,1,2,3] and os.getpriority(os.PRIO_PROCESS,0)==19)
    for key in ("OPENBLAS_NUM_THREADS","OMP_NUM_THREADS","MKL_NUM_THREADS","NUMEXPR_NUM_THREADS","BLIS_NUM_THREADS","VECLIB_MAXIMUM_THREADS"):
        check("single_thread_env:"+key,os.environ.get(key)=="1")
    parent = freeze(PARENT,"full_reference.py",role="unmodified_complete_oracle_parent")
    check("oracle_complete_SHA",sha(parent)==PARENT_SHA,expected=PARENT_SHA)
    check("current_oracle_byte_identical",source(E+"tests/full_reference.py")==parent)
    v4=json.loads(freeze("source/feasibility_20261014/v4/input_manifest.json","v4_input_manifest.json",role="prior_frozen_oracle_provenance"))
    check("v4_manifest_contains_oracle_SHA",PARENT_SHA in json.dumps(v4))
    declarations = ast.parse(parent)
    imports=[n for n in declarations.body if isinstance(n,(ast.Import,ast.ImportFrom))]
    import_modules=[n.module if isinstance(n,ast.ImportFrom) else n.names[0].name for n in imports]
    check("oracle_imports_stdlib_and_numpy_only",set(import_modules)<={"__future__","ctypes","math","struct","pathlib","numpy"},imports=import_modules)
    wanted={"rope_head","rope_qkv_many","mul","sub","add","_array","_finite"}
    manifest["oracle_functions"]={n.name:dict(first_line=n.lineno,last_line=n.end_lineno,source_sha256=sha(ast.get_source_segment(parent.decode(),n).encode())) for n in declarations.body if isinstance(n,ast.FunctionDef) and n.name in wanted}
    check("oracle_function_set_complete",set(manifest["oracle_functions"])==wanted)
    # Import only the byte-identical frozen independent parent, never production code.
    import numpy as np
    spec=importlib.util.spec_from_file_location("frozen_rope_reference",OUT/"inputs/full_reference.py")
    oracle=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(oracle)
    oracle_filename=str(OUT/"inputs/full_reference.py")
    def audit(frame,event,arg):
        if event=="call" and frame.f_code.co_filename==oracle_filename:
            name=frame.f_code.co_name
            oracle_calls[name]+=1
            if name not in wanted:
                raise RuntimeError("unauthorized oracle function: "+name)
    sys.setprofile(audit)
    manifest["environment"]=dict(python=sys.version,python_executable=sys.executable,python_executable_sha256=sha(Path(sys.executable).read_bytes()),numpy=np.__version__,numpy_file=np.__file__,machine=platform.machine(),platform=platform.platform(),byteorder=sys.byteorder,threads={k:os.environ[k] for k in ("OPENBLAS_NUM_THREADS","OMP_NUM_THREADS","MKL_NUM_THREADS","NUMEXPR_NUM_THREADS","BLIS_NUM_THREADS","VECLIB_MAXIMUM_THREADS")})
    check("host_little_endian",sys.byteorder=="little")

    fixture_manifest=json.loads(freeze(F+"manifest.json","pre_qkv_manifest.json",role="exact_pre_QKV_parent"))
    check("request3_gen1_B1S128",fixture_manifest["session"]==dict(B=1,S=128,generation=1,request_id=3))
    check("pre_QKV_oracle_parent_SHA",fixture_manifest["oracle_source"]["sha256"]==PARENT_SHA)
    manifest["request_identity"]=dict(fixture_manifest["session"],token_rows=[0,1],encoder_layer=0,rope_family="full",evaluation_window_shape=[1,2,3072],window_not_model_S_reduction=True)
    p2_report=json.loads(freeze(P2+"full_fixture_report.json","P2_full_fixture_report.json",role="historical_leaf_calibration_and_model_provenance"))
    d2_report=json.loads(freeze(D2+"numeric_fixture/full_fixture_report.json","D2_full_fixture_report.json",role="historical_leaf_expected_provenance"))
    old_report=json.loads(freeze(D2+"attention_fixture/full_attention_fixture_report.json","native_attention_fixture_report.json",role="native_input_independent_full_FINAL_provenance"))
    header=freeze(MODEL+"laya_model_layout_generated.h","model_layout.h",role="current_model_table_offsets_and_source_SHA").decode()
    model_sha="6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18"
    check("P2_declares_frozen_model_SHA",any(v.get("sha256")==model_sha and v.get("role")=="model" for v in p2_report["checked_reference_files"].values()))
    source_sha_line=next(line for line in header.splitlines() if "kFullSourceSha256" in line)
    import re
    check("current_model_header_source_SHA",bytes(int(x,16) for x in re.findall(r"0x([0-9a-f]{2})",source_sha_line)).hex()==model_sha)
    manifest["model_provenance"]=dict(declared_GGUF_sha256=model_sha,whole_GGUF_not_rehashed=True,table_hashes_and_windows_rehashed=True)
    table_data={}
    for name,offset,gguf_offset,expected_sha in (
        ("cos_full",617728,449923200,"fe68cb1cd364cdd31324ec5bf01250eb3a93e4b1a8915b908fa2d575a74ad0fc"),
        ("sin_full",880128,450185600,"e2c58174cc0988a14699e0ef3f314048f82d8073c22893a860a7c4ad5914eb8e"),
    ):
        aux=source(MODEL+"aux.bin")
        table=aux[offset:offset+262400]
        check(name+":whole_table_SHA",sha(table)==expected_sha)
        decl=next(v for k,v in p2_report["checked_reference_files"].items() if k.endswith("::"+name))
        check(name+":P2_source_identity",decl["sha256"]==expected_sha and decl["absolute_file_offset"]==gguf_offset and decl["bytes"]==262400)
        current_line=next(line for line in header.splitlines() if '"'+name+'"' in line)
        check(name+":header_offsets",f"{gguf_offset}, 262400, {offset}, 262400" in current_line)
        data=freeze(MODEL+"aux.bin",name+"_s0_s1.f32.bin",offset,512,[2,64],"<f4",role="original_table_token_windows")
        table_data[name]=np.frombuffer(data,dtype="<f4").reshape(2,64)
    cos,sin=table_data["cos_full"],table_data["sin_full"]
    manifest["calibration_gate"]="four legacy leaf cases must match before current inputs are evaluated"
    for s,h in ((0,0),(127,15)):
        for field in ("q","k"):
            stem=f"rope_{field}_b0_s{s}_h{h}_full"
            inp=freeze(D2+"numeric_fixture/"+stem+".input.bin",stem+".input.bin",shape=[3,64],dtype="<f4",role="old_independent_leaf_input")
            expected=freeze(D2+"numeric_fixture/"+stem+".expected.bin",stem+".expected.bin",shape=[64],dtype="<f4",role="unchanged_old_expected")
            decl=next(v for v in d2_report["cases"] if v["name"]==stem)
            check(stem+":D2_declared_hash",sha(inp)==decl["input_sha256"] and sha(expected)==decl["expected_sha256"])
            check(stem+":original_P2_bytes_identical",source(P2+stem+".input.bin")==inp and source(P2+stem+".expected.bin")==expected)
            x,c,t=np.frombuffer(inp,dtype="<f4").reshape(3,64)
            got=oracle.rope_head(x,c,t).astype("<f4",copy=False).tobytes()
            compare("legacy_leaf:"+stem,got,expected)
    manifest["calibration_gate_passed"]=True

    # Also calibrate the complete old native-input rows, not as current gold.
    legacy_raw=freeze(D2+"attention_fixture/raw_qkv.f32.bin","native_rows01_pre.f32.bin",0,24576,[1,2,3072],"<f4",role="legacy_calibration_input_not_real_producer")
    legacy_final=freeze(D2+"attention_fixture/full_final_qkv.f32.bin","native_rows01_expected.f32.bin",0,24576,[1,2,3072],"<f4",role="unchanged_legacy_independent_FINAL")
    native=np.frombuffer(legacy_raw,dtype="<f4").reshape(1,2,3072)
    native_out=oracle.rope_qkv_many(native,cos,sin).astype("<f4",copy=False)
    compare("legacy_full_rows01",native_out.tobytes(),legacy_final)
    for key, path in (("raw_qkv",D2+"attention_fixture/raw_qkv.f32.bin"),("full",D2+"attention_fixture/full_final_qkv.f32.bin")):
        decl=old_report[key] if key=="raw_qkv" else old_report["full"]["final_qkv"]
        check("old_report_parent:"+key,source_identities[path]["sha256"]==decl["sha256"])

    case=next(c for c in fixture_manifest["cases"] if c["name"]=="qkv_rows4")
    pre_data=freeze(F+"qkv_rows4_output_f32.bin","current_rows01_pre.f32.bin",0,24576,[1,2,3072],"<f4",role="current_independent_pre_QKV")
    norm_data=freeze(F+"qkv_rows4_source_f32.bin","current_rows01_norm.f32.bin",0,8192,[1,2,1024],"<f4",role="original_norm_bytes_no_evaluation")
    scatter=freeze(F+"qkv_rows4_scatter_u32x4.bin","current_rows01_pre_scatter.u32x4.bin",0,98304,[2,3072,4],"<u4",role="existing_pre_QKV_layout_identity")
    for name,filename in (("output_f32","qkv_rows4_output_f32.bin"),("source_f32","qkv_rows4_source_f32.bin"),("scatter_u32x4","qkv_rows4_scatter_u32x4.bin")):
        check("current_fixture_declared:"+name,source_identities[F+filename]["sha256"]==case["products"][name]["sha256"])
    prior=json.loads(freeze(SUPPORT+"qkv_rope_binding_20261015.json","prior_static_binding.json",role="previous_39pair_identity_binding"))
    current=np.frombuffer(pre_data,dtype="<f4").reshape(1,2,3072)
    final=oracle.rope_qkv_many(current,cos,sin).astype("<f4",copy=False)
    check("all_FINAL_finite",np.isfinite(final).all(),computed_QK_f32=4096,copied_V_f32=2048)
    head_checked=current.copy()
    for s in range(2):
        for p in range(2):
            for h in range(16):
                begin=p*1024+h*64
                head_checked[0,s,begin:begin+64]=oracle.rope_head(current[0,s,begin:begin+64],cos[s],sin[s])
    compare("two_existing_functions_internal_crosscheck",head_checked.tobytes(),final.tobytes())
    compare("row0_identity",final[0,0].tobytes(),pre_data[:12288])
    check("row1_is_nondegenerate",final[0,1,:2048].tobytes()!=current[0,1,:2048].tobytes())
    for s in range(2):
        compare(f"V_unchanged_row{s}",final[0,s,2048:].tobytes(),current[0,s,2048:].tobytes())
    matches=prior["rows"][1]["matching_QK_pairs"]
    check("row1_39pairs_prior_count",len(matches)==39)
    for m in matches:
        for off in m["old_final_byte_offsets"]:
            check(f"row1_prior_input_word:{off}",pre_data[off:off+4]==legacy_raw[off:off+4])
            compare(f"row1_prior_pair:{off}",final.tobytes()[off:off+4],legacy_final[off:off+4])

    # Diagnostic only: the same frozen helpers, with explicit non-FMA order.
    steps=np.empty((2,2,16,32,6),dtype="<f4")
    for s in range(2):
        for p in range(2):
            for h in range(16):
                x=current[0,s,p*1024+h*64:p*1024+(h+1)*64]
                for i in range(32):
                    a=oracle.mul(x[i],cos[s,i])
                    b=oracle.mul(x[i+32],sin[s,i])
                    lower=oracle.sub(a,b)
                    c=oracle.mul(x[i+32],cos[s,i+32])
                    d=oracle.mul(x[i],sin[s,i+32])
                    upper=oracle.add(c,d)
                    steps[s,p,h,i]=[a,b,lower,c,d,upper]
    check("all_diagnostic_steps_finite",np.isfinite(steps).all())
    for s in range(2):
        for p in range(2):
            expected=final[0,s,p*1024:(p+1)*1024].reshape(16,64)
            compare(f"diagnostic_lower_row{s}_plane{p}",steps[s,p,:,:,2].tobytes(),expected[:,:32].tobytes())
            compare(f"diagnostic_upper_row{s}_plane{p}",steps[s,p,:,:,5].tobytes(),expected[:,32:].tobytes())
    check("oracle_call_allowlist",set(oracle_calls)<=wanted,called=dict(oracle_calls))
    sys.setprofile(None)
    manifest["oracle_calls"]=dict(oracle_calls)
    manifest["not_called"]=["full_forward","attention_many","q8_linear","layernorm","trigonometric_generation","DUT_or_production_arithmetic"]
    for s in range(2):
        save(f"row{s}_full_FINAL.f32.bin",final[0,s].tobytes(),[3,16,64],"<f4",f"frozen rope_qkv_many(current pre row{s}, AUX cos/sin position{s}); Q/K computed and V copied")
        save(f"row{s}_steps_ab_lower_cd_upper.f32.bin",steps[s].tobytes(),[2,16,32,6],"<f4","same frozen mul/sub/add helpers in order a,b,lower,c,d,upper; diagnostic, not a second oracle")
        save(f"row{s}_norm_unchanged.f32.bin",norm_data[s*4096:(s+1)*4096],[1024],"<f4","verbatim original norm window; no arithmetic")
    manifest["layouts"]=dict(final="[plane(Q,K,V),head0..15,d0..63], 4B F32 little endian",steps="[plane(Q,K),head0..15,pair0..31,field(a,b,lower,c,d,upper)], each pair uses d=i and i+32",norm="[d0..1023] verbatim",scratch="shard=head&1; off=((((plane*2+b)*8+head//2)*1024+s)*64+d)*4; b=0, model S=128 unchanged")
    # Re-read all parents after evaluation to detect concurrent changes.
    for path,ident in source_identities.items():
        check("source_unchanged:"+path,sha(read(path))==ident["sha256"])
    manifest["sources"]=list(source_identities.values())
    manifest["sampling"]=finish_sampling()
    manifest["status"]="PASS_DERIVED_ROPE_REFERENCE_ROWS01_PENDING_CONTROLLER_REVIEW"
    (OUT/"manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n")
    print(json.dumps(dict(status=manifest["status"],checks=len(checks),products=products,oracle_calls=manifest["oracle_calls"],sampling=manifest["sampling"]),ensure_ascii=False))
except Exception as exc:
    sys.setprofile(None)
    manifest.update(status="FAIL_REFERENCE_PREPARATION",error=repr(exc),traceback=traceback.format_exc(),sources=list(source_identities.values()),oracle_calls=dict(oracle_calls),sampling=finish_sampling())
    (OUT/"failure.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n")
    raise
