# Attention v5 cold-start static RTL v2 source results

Status on 2026-10-09: the independent v2 testbench source packet and read-only binding check are prepared for Astra source review after the first v1 runtime stopped at a composite special-hold assertion. No v2 xvhdl, xvlog, xelab or xsim command has run. The v1 static compile passed, but no numerical RTL, timing or board conclusion exists.

## Target and estimated finite budget

The frozen V5 configuration requests xcu55c-fsvh2892-2L-e at 150 MHz with Vitis HLS 2025.2. The [accepted synthesis review](../../../../reviewer_attention_v5_software_synthesis_structure_review.json) reports 216 generated Verilog files, 35 `.dat` and six FP simulation VHDL wrappers. HLS estimated 79 BRAM18, 22 DSP, 56,309 FF and 200,525 LUT; its 5.390 ns synthesis estimate did not meet the 4.867 ns effective target after uncertainty. These are prior V5 HLS facts, not static harness compile, mapped resources or achieved frequency.

For B1/S64 one head/query, the independent schedule review identifies 8256 QKV read calls ×27 clocks = 222,912, main QK 44,736, softmax 2,294, and AV 45,056; subtotal **314,998 cycles** before request/owner/control and finite stalls. The harness adds a 0–3 cycle channel exposure delay per accepted transfer, with one extra 16-cycle QKV R and ATT_OUT B hold. As a deliberately serialized allowance for the 8256 selected QKV reads, up to `2 × 8256 × 5 = 82,560` adapter edges cover AR and R capture/exposure/retire. A separate 100,000-cycle allowance covers the finite descriptor/request/aux, ATT_OUT and observed bus transfers. These conservative, partly overlapping allowances total 497,558 cycles including the scheduled subtotal. The remaining **1,502,442 cycles** in the proposed 2,000,000-cycle RUN watchdog must cover the following finite control work and any scheduling/arbitration overhead; it is not an undifferentiated latency claim:

| RUN control path from unchanged source | Finite iteration count for this fixture |
| --- | ---: |
| Descriptor shape/identity/receipt checks | 16 reserved words, 24 digest words, four build-tag words, 48 metadata words |
| Coverage-mask walk | 48 plane/head masks × 64 rows = 3072 row visits, at most 48 cover calls |
| Production `full_cover_qkv` | 48 calls × two 64-row passes = at most 6144 check/mark visits; each also finds two owners in a 32-record array |
| Production `full_publish_qkv_pair` | 48 `all_rows(S=64)` calls × 64 bit tests = 3072 tests, then 64 covered-row marks on each of two owners |
| `count_covered` in the final report | 96 mask words with at most 3072 bit shifts |
| Numeric/report observation | 64 score writes, 64 probability writes, 64 ATT_OUT reads, 64 AV writes, 30 status-word resets, two owner snapshots |
| Post-report cleanup | 32 owner-record visits, with bounded invalidation of incomplete owners |

The table gives loop bounds, not per-loop HLS latencies. The watchdog is a **prior stop bound**, not a proof of true top latency. At every fixed 100,000 cycles the testbench prints a phase hint, command/state, all seven ports' DUT/endpoint AR/R/AW/B counts and actual in-process RSS. A timeout is a preserved first failure requiring schedule analysis, not automatic budget growth. BEGIN, pending BEGIN and replay RUN each have a proposed 200,000-cycle bound; pointer setup and command checks fit under the proposed 2,700,000-cycle total watchdog. The previously published generic XML maxima are not B1/S64 fixture bounds.

BEGIN also has finite work: production request parsing checks the 128-byte header, copies four 16-byte identity tags, checks five directory entries, visits 64 token/mask entries and 16 marker entries for B1/S64, then checks the AUX model header. Its two QKV owner claims search at most 32 records each and clear two 64-word coverage arrays per owner. `full_claim_qkv_pair` clears the declared QKV plane bitmap `[2][3][16][2][32]` (6144 words) and rope bitmap `[2][2][16][2][32]` (4096 words). The second BEGIN returns at the pending guard before parsing; replay RUN returns at the no-pending guard before numeric work. These loop counts explain why the three 200,000-cycle non-RUN limits remain proposed stop bounds rather than measured latencies.

## Preparation evidence

The first guarded materializer attempt stopped before output because its forward plane stride omitted the batch dimension. Its guard and first failure remain in the frozen v1 `runs/materialize_base_h0_r0_v1/guard` (exit 1, no guard trigger). **The original v1 script text/hash was not frozen before that attempt**, so no later copy is represented as its pre-run source; this limits reconstruction of that failure. After correcting the formula, a fresh guarded attempt in v1 `runs/materialize_base_h0_r0_v2` exited 0 in 6.761 s, peak owned RSS 57,516 KiB, 34 samples and no guard trigger; minimum MemAvailable was 451,346,556 KiB. Its independent inverse checker inspected all **25,165,824 host QKV bytes**, and both 12 MiB and 10,240,064 B prefix SHA256 values matched the frozen manifest. The materialized XSim backing contains exactly 267 mapped 4 KiB pages, including only 786,432 B of the QKV logical shards. A separate [independent page serialization check](../../rtl_static_cold_v1/runs/materialize_base_h0_r0_v2/independent_page_check.json) verified all ten `.memh` files byte-for-byte; [Astra's independent review](../../../../reviewer_attention_v5_cold_static_v1_prepared_bytes_review.json) also accepted the 267 page bytes and full-host/prefix hashes. The frozen v1 source packet binds both records; the v2 packet reuses them. V2 Python AST, shell syntax, all 352 generated top pins, the 267-page map, documentation links and the read-only binding check over 557 files plus 11 prepared records passed. No v2 EDA compile/simulation has run.

The [materialization evidence](../../rtl_static_cold_v1/runs/materialize_base_h0_r0_v2/prepared/materialization.json) records all ten generated `.memh` files and full image hashes. The v2 source packet binds these unchanged prepared bytes, the new diagnostic testbench, the generated V5 and FP wrapper files, installed simulation libraries, exact command plans and source scripts. All v2 pre/post binding reports and the four XSim runtime artifacts must use fresh paths; none is a current v2 execution result.

## V1 first-run evidence and v2 diagnostic scope

The [v1 static audit](../../rtl_static_cold_v1/runs/static_build_v1/static_audit.json) passed. The [first v1 runtime](../../rtl_static_cold_v1/runs/rtl_base_h0_r0_v1/failure_evidence_manifest.json) passed both BEGIN commands and reached RUN `ap_done` at command cycle 500,645, then stopped at `ATT_COLD_SPECIAL_HOLD_MISSING r=1 b=1`. The composite assertion omitted the selected index/address values, so the exact failed predicate remains unobserved. No RUN memory scan, numerical check or replay occurred. The [post-run analysis](../../rtl_static_cold_v1/runs/rtl_base_h0_r0_v1/postrun_analysis.md) traces a likely v1 testbench expectation mismatch: 64 F32 outputs produce 256 byte-level user writes, mapped to 256 one-beat 32-bit AW/W/B transactions and 1,024 bus bytes. The final aligned bus AW remains at `att_out_base+252`. The ATT_OUT read expectation stays 64 AR/R and 256 bus bytes.

V2 changes only the testbench's ATT_OUT write transaction expectations, selects the 256th final B, dumps all four commands' full observed and ATT_OUT memories before result checks, and prints seven-port dual-side cumulative/per-command counts, adapter debts, start/done scope, four-state R/B predicate results and bounded first/final AW/W/B physical event samples. It checks the source-derived AW length/size/address and W strobe shape across all physical ATT_OUT writes. It retains the final `+252` address, at least 16-cycle holds, first-`ap_done` and CSR debt checks, exact status/oracle values and numerical tolerance. The v1 source packet, compiled snapshot and failed runtime are unchanged. This source-preparation state does not authorize v2 compilation or simulation.

| Stage | State |
| --- | --- |
| Host page materialization | Passed after a recorded source-formula correction |
| V2 source/page/pin audit | Passed read-only checks; Astra source review pending; no v2 RTL compiler invoked |
| V2 Attention static compile | Not released, not run |
| V2 Attention numerical RTL runtime | Not released, not run |
| RTL resource/timing, place/route, board | Not run |
