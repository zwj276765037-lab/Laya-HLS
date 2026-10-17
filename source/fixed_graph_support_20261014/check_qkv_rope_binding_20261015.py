"""Saved bytes, source hashes and integer layout only. No FP/oracle execution."""
import hashlib
import json
import os
from pathlib import Path
import resource
import struct
import time

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).with_name("qkv_rope_binding_20261015.json")
E = "project/E002_Laya_HLS/experiment/"
M = E + "vivado/module_design/"
Q = M + "q8_linear_and_restore/tm1tn8_gs32_512/"
P2 = E + "results/engineering_p2/20261007T030653Z-1859617/"
BUILD = E + "build/full-hls-20261007T030653Z-1859617/"
PROBE = BUILD + "rope_probe/solution1/"
COSIM = BUILD + "rope_cosim/solution1/"
F = E + "results/cpu_embedding_q8_validation_20261010/attempts/task2_real_fixture_20/work/fixtures/"
D2 = E + "results/attention_rtl_repair_20261008/d2_cpu_full_official/"
AF = D2 + "attention_fixture/"
NF = D2 + "numeric_fixture/"
MODEL = E + "build/model-current-production-v2-20261011/"
A204 = "project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT204_SM004_rev13_scratch_real_chain_01/"
start = time.monotonic()
files = {}
checks = {}

def read(path, offset=0, size=None):
    with (ROOT / path).open("rb") as f:
        f.seek(offset)
        data = f.read() if size is None else f.read(size)
    if size is not None:
        assert len(data) == size, path
    return data

def ident(path, offset=0, size=None):
    data = read(path, offset, size)
    item = dict(path=path, bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
    if size is not None:
        item["offset"] = offset
    files[path + (f"@{offset}:{size}" if size is not None else "")] = item
    return item

def check(name, value):
    checks[name] = bool(value)
    assert value, name

def words(data):
    return struct.unpack("<" + str(len(data) // 4) + "I", data)

def bitdiff(a, b):
    assert len(a) == len(b)
    indices = [i for i, (x, y) in enumerate(zip(words(a), words(b))) if x != y]
    return dict(words=len(a)//4, different_words=len(indices), first_different=indices[0] if indices else None)

source_paths = [
    E + "hls/operators/rope_full_compute.cpp", E + "hls/operators/full_rope_cosim_wrapper.cpp",
    E + "hls/operators/full_tasks_attention.cpp", E + "hls/control/full_forward_controller.cpp",
    E + "hls/common/laya_memory_map.cpp", E + "include/laya_types.h",
    E + "config/full_hls_rope.tcl", E + "config/full_hls_rope_cosim.tcl",
    E + "tests/full_reference.py", E + "tests/full_fixture_test.py", E + "tests/full_attention_fixture.py",
    Q + "tb/make_real_fixtures.py", MODEL + "laya_model_layout_generated.h",
    M + "hbm_loader_and_cache/rtl/t4_w_reader_port_v1.sv",
    M + "hbm_loader_and_cache/rtl/t4_aux_bias_reader_v1.sv",
    Q + "rtl/tm1tn8_axi512_writer.sv", Q + "rtl/laya_qkv_scratch_row_v1.sv",
    Q + "rtl/laya_lnq_wi_gqdown_row_v1.sv",
    P2 + "source_hashes.sha256", P2 + "csim_rope.log", P2 + "cosim_rope.log",
    P2 + "rope_head_csynth.rpt", P2 + "rope_head_csynth.xml",
    M + "rope_and_mask/tb/full_numeric_tb.cpp", M + "rope_and_mask/tb/full_rope_cosim_tb.cpp",
    F + "manifest.json", AF + "full_attention_fixture_report.json", NF + "full_fixture_report.json",
    A204 + "source_manifest.json", A204 + "guard_rtl/guard_result.json", A204 + "guard_rtl/driver.log",
]
for p in source_paths:
    ident(p)
for p in sorted((ROOT / (PROBE + "syn/verilog")).iterdir()):
    if p.suffix in (".v", ".tcl"):
        ident(str(p.relative_to(ROOT)))
ident(COSIM + "syn/verilog/full_rope_cosim_top.v")
check("probe_report_matches_preserved_P2_report", read(PROBE + "syn/report/rope_head_csynth.rpt") == read(P2 + "rope_head_csynth.rpt"))
decls = {}
for line in read(P2 + "source_hashes.sha256").decode().splitlines():
    digest, path = line.split(maxsplit=1)
    decls[path.split("Laya-baseline/")[-1]] = digest
for p in ("hls/operators/rope_full_compute.cpp", "hls/operators/full_rope_cosim_wrapper.cpp", "config/full_hls_rope.tcl", "config/full_hls_rope_cosim.tcl"):
    check("P2_source_" + Path(p).name, ident(E + p)["sha256"] == decls[p])
check("P2_three_case_cosim_marker", b"FULL_ROPE_COSIM_PASS cases=3" in read(P2 + "cosim_rope.log"))

current_frozen = []
for name in ("laya_qkv_scratch_row_v1.sv", "laya_lnq_wi_gqdown_row_v1.sv", "tm1tn8_axi512_writer.sv"):
    current = ident(Q + "rtl/" + name)
    frozen = ident(A204 + "frozen/" + name)
    current_frozen.append(dict(name=name, current=current, AT204=frozen, equal=current["sha256"] == frozen["sha256"]))

tables = {}
for name, offset, expected_sha in (
    ("cos_full", 617728, "fe68cb1cd364cdd31324ec5bf01250eb3a93e4b1a8915b908fa2d575a74ad0fc"),
    ("sin_full", 880128, "e2c58174cc0988a14699e0ef3f314048f82d8073c22893a860a7c4ad5914eb8e"),
):
    table = ident(MODEL + "aux.bin", offset, 262400)
    check(name + "_whole_saved_table_sha", table["sha256"] == expected_sha)
    old = AF + ("full_cosine.f32.bin" if name == "cos_full" else "full_sine.f32.bin")
    ident(old)
    check(name + "_old128_matches_current_aux", read(old) == read(MODEL + "aux.bin", offset, 128 * 256))
    entries = []
    for s in (0, 1, 127):
        data = read(MODEL + "aux.bin", offset+s*256, 256)
        w = words(data)
        check(f"{name}_s{s}_finite_bits", all(x & 0x7f800000 != 0x7f800000 for x in w))
        entries.append(dict(row=s, identity=ident(MODEL+"aux.bin", offset+s*256, 256), words_hex=[f"{x:08x}" for x in w], halves_equal=data[:128] == data[128:]))
    tables[name] = dict(table=table, rows=entries)
check("row1_not_position0_table", read(MODEL+"aux.bin",617728+256,256) != read(MODEL+"aux.bin",617728,256) and read(MODEL+"aux.bin",880128+256,256) != read(MODEL+"aux.bin",880128,256))
check("row0_cos_one_sin_positive_zero", set(words(read(MODEL+"aux.bin",617728,256))) == {0x3f800000} and set(words(read(MODEL+"aux.bin",880128,256))) == {0})

pre = read(F + "qkv_rows4_output_f32.bin")
norm = read(F + "qkv_rows4_source_f32.bin")
scatter = read(F + "qkv_rows4_scatter_u32x4.bin")
old_raw = read(AF + "raw_qkv.f32.bin")
old_final = read(AF + "full_final_qkv.f32.bin")
for path in (F+"qkv_rows4_output_f32.bin", F+"qkv_rows4_source_f32.bin", F+"qkv_rows4_scatter_u32x4.bin", AF+"raw_qkv.f32.bin", AF+"full_final_qkv.f32.bin"):
    ident(path)
check("saved_shapes", len(pre)==4*12288 and len(norm)==4*4096 and len(old_raw)==len(old_final)==2*128*12288)
check("current_row0_QK_all_normal_nonzero_bits", all(0 < ((x >> 23) & 255) < 255 for x in words(pre[:8192])))
check("old_FINAL_preserves_V_all_B2S128", all(old_raw[(s*3072+2048)*4:(s*3072+3072)*4] == old_final[(s*3072+2048)*4:(s*3072+3072)*4] for s in range(256)))

def offset(plane, head, s, d=0):
    return (((plane*2*8+head//2)*1024+s)*64+d)*4

row_records = []
for s in (0,1):
    q = pre[s*12288:(s+1)*12288]
    native = old_raw[s*12288:(s+1)*12288]
    sc = list(struct.iter_unpack("<4I",scatter[s*49152:(s+1)*49152]))
    expect = []
    for n, value in enumerate(words(q)):
        p, feature = divmod(n,1024)
        h,d = divmod(feature,64)
        expect.append((h&1,offset(p,h,s,d),value,s))
    check(f"row{s}_saved_scatter_exact",sc==expect)
    parent = D2 + "oracle/B1_from_b0_S128/embedding_norm.f32.bin"
    check(f"row{s}_norm_parent_exact",read(parent,s*4096,4096)==norm[s*4096:(s+1)*4096])
    ident(parent,s*4096,4096)
    matching_pairs=[]
    for p in (0,1):
        for h in range(16):
            for i in range(32):
                lo=(p*1024+h*64+i)*4
                hi=lo+128
                if q[lo:lo+4] == native[lo:lo+4] and q[hi:hi+4] == native[hi:hi+4]:
                    matching_pairs.append(dict(plane=p,head=h,pair=i,old_final_byte_offsets=[s*12288+lo,s*12288+hi]))
    row_records.append(dict(row=s,pre=ident(F+"qkv_rows4_output_f32.bin",s*12288,12288), norm=ident(F+"qkv_rows4_source_f32.bin",s*4096,4096),scatter=ident(F+"qkv_rows4_scatter_u32x4.bin",s*49152,49152), native_raw=ident(AF+"raw_qkv.f32.bin",s*12288,12288),native_input_final=ident(AF+"full_final_qkv.f32.bin",s*12288,12288),current_vs_native_by_plane={str(p):bitdiff(q[p*4096:(p+1)*4096],native[p*4096:(p+1)*4096]) for p in range(3)}, matching_qk_heads=[(p,h) for p in (0,1) for h in range(16) if q[(p*1024+h*64)*4:(p*1024+(h+1)*64)*4] == native[(p*1024+h*64)*4:(p*1024+(h+1)*64)*4]],matching_QK_pair_count=len(matching_pairs),matching_QK_pairs=matching_pairs))

leaf_refs=[]
for s,h in ((0,0),(127,15)):
    for p,field in ((0,"q"),(1,"k")):
        stem=NF+f"rope_{field}_b0_s{s}_h{h}_full"
        inp=read(stem+".input.bin")
        expected=read(stem+".expected.bin")
        a=(s*3072+p*1024+h*64)*4
        check(f"old_leaf_{field}_{s}_raw_layout",inp[:256]==old_raw[a:a+256])
        check(f"old_leaf_{field}_{s}_table_layout",inp[256:512]==read(MODEL+"aux.bin",617728+s*256,256) and inp[512:768]==read(MODEL+"aux.bin",880128+s*256,256))
        check(f"old_leaf_{field}_{s}_matches_old_final",expected==old_final[a:a+256])
        leaf_refs.append(dict(row=s,head=h,plane=p,input=ident(stem+".input.bin"),expected=ident(stem+".expected.bin"),actual=ident(stem+".actual.bin"), current_row0_head_input_equal=(inp[:256] == pre[(p*1024+h*64)*4:(p*1024+(h+1)*64)*4]) if s==0 else None))

seen=set()
per_row=[]
for s in range(128):
    beats=[]
    for p in (0,1):
        for h in range(16):
            for beat in range(4):
                key=(h&1,offset(p,h,s,beat*16))
                assert key not in seen
                seen.add(key)
                assert key[1]%64==0 and key[1]%4096+64<=4096 and key[1]+64<=12*1024*1024
                beats.append(key)
            assert {i for k in range(32) for i in (k,k+32)} == set(range(64))
    per_row.append(dict(row=s,read_write_beats=len(beats),shard0=sum(k[0]==0 for k in beats),shard1=sum(k[0]==1 for k in beats),first=min(a for _,a in beats),end=max(a for _,a in beats)+64))
check("S128_QK_16384_unique_in_bounds_beats",len(seen)==16384)
check("no_QK_aliases_V",not any((h&1,offset(2,h,s,d)) in seen for s in range(128) for h in range(16) for d in (0,16,32,48)))
inventories={d:[p.name for p in sorted((ROOT/d).iterdir()) if p.is_file()] for d in (F,AF,NF,D2+"oracle/B1_from_b0_S128/")}
result=dict(scope="Static saved bytes/integer layout/source identity only; no EDA/model/FP oracle/new gold", checks=checks,files=list(files.values()),current_AT204_comparison=current_frozen,tables=tables,rows=row_records,old_leaf_refs=leaf_refs,reference_boundary="Old full FINAL is independently calculated from captured native B2 QKV, not from current request3/gen1 exact QKV. No current-input full RoPE step/final file found in enumerated evidence directories. QKV steps_u32x6 are matrix steps, not RoPE.",inventories=inventories,structural_counts=dict(per_row_heads=32,pairs=1024,mul=4096,add_sub=2048,qk_read_bytes=8192,qk_write_bytes=8192,qk_read_beats=128,qk_singlebeat_AW_W_B=128,writer_tiles32B=256,head_flushes=32,table_bytes=512,aux128_R=32,QK_512_R=128,S128_QK_beats=len(seen),local_head_bank_bytes=256,cos_sin_bank_bytes=512,generated_saved_bytes=256,selected_reader_original_fifo_bytes=4096,selected_aux_reader_original_fifo_bytes=1024,existing_writer_payload_bytes=160),layout_rows=per_row,historical_AT204_guard=json.loads(read(A204+"guard_rtl/guard_result.json")),sampling=dict(process_wall_seconds=time.monotonic()-start,maxrss_kib=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,affinity=sorted(os.sched_getaffinity(0)),nice=os.getpriority(os.PRIO_PROCESS,0),interactive_reads="UNKNOWN"))
OUT.write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n")
print(json.dumps(dict(checks=len(checks),all_true=all(checks.values()),identities=len(files),rows=[{k:v for k,v in r.items() if k != "matching_QK_pairs"} for r in row_records],current_AT204=current_frozen,sampling=result["sampling"]),ensure_ascii=False))
