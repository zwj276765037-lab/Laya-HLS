# Attention v5 cold-start static RTL source results

Status on 2026-10-09: source construction and one corrected host page materialization only. No Attention xvhdl, xvlog, xelab or xsim command has run. No numerical RTL, timing or board conclusion exists.

## Target and estimated finite budget

The frozen V5 configuration requests xcu55c-fsvh2892-2L-e at 150 MHz with Vitis HLS 2025.2. The [accepted synthesis review](../../../../reviewer_attention_v5_software_synthesis_structure_review.json) reports 216 generated Verilog files, 35 `.dat` and six FP simulation VHDL wrappers. HLS estimated 79 BRAM18, 22 DSP, 56,309 FF and 200,525 LUT; its 5.390 ns synthesis estimate did not meet the 4.867 ns effective target after uncertainty. These are prior V5 HLS facts, not static harness compile, mapped resources or achieved frequency.

For B1/S64 one head/query, the independent schedule review identifies 8256 QKV read calls ×27 clocks = 222,912, main QK 44,736, softmax 2,294, and AV 45,056; subtotal **314,998 cycles** before request/owner/control and finite stalls. The harness adds a 0–3 cycle channel exposure delay per accepted transfer, with one extra 16-cycle QKV R and ATT_OUT B hold. As a deliberately serialized allowance for the 8256 selected QKV read calls, up to `2 × 8256 × 5 = 82,560` adapter edges cover AR and R channel capture/exposure/retire. The original descriptor/request/aux and observed/ATT_OUT traffic has additional finite transfers; a 100,000-cycle allowance covers their adapter exposure and response bookkeeping. The resulting 497,558-cycle accounting subtotal leaves 1,502,442 cycles in the proposed 2,000,000-cycle RUN watchdog for production owner/coverage, parser, report, generated top control and unknown arbitration overhead. This is a **prior stop bound**, not a proof of true top latency. A timeout is a preserved first failure requiring schedule analysis, not automatic budget growth. BEGIN, pending BEGIN and replay RUN each have a proposed 200,000-cycle bound; pointer setup and command checks fit under the proposed 2,700,000-cycle total watchdog. The previously published generic XML maxima are not B1/S64 fixture bounds.

## Preparation evidence

The first guarded materializer attempt stopped before output because its forward plane stride omitted the batch dimension. Its guard and first failure remain in `runs/materialize_base_h0_r0_v1/guard` (exit 1, no guard trigger). After correcting that formula, a fresh guarded attempt in `runs/materialize_base_h0_r0_v2` exited 0 in 6.761 s, peak owned RSS 57,516 KiB, 34 samples and no guard trigger; minimum MemAvailable was 451,346,556 KiB. Its independent inverse checker inspected all **25,165,824 host QKV bytes**, and both 12 MiB and 10,240,064 B prefix SHA256 values matched the frozen manifest. The materialized XSim backing contains exactly 267 mapped 4 KiB pages, including only 786,432 B of the QKV logical shards. Python source syntax, shell syntax, all 352 generated top pins and the 267-page map passed static checks. No Attention EDA compile/simulation has run.

The [materialization evidence](../runs/materialize_base_h0_r0_v2/prepared/materialization.json) records all ten generated `.memh` files and full image hashes. The final source packet binds these, the source gate, all generated V5 and FP wrapper files, installed simulation libraries, exact command plans and source scripts. All future pre/post binding reports and the four XSim runtime artifacts are planned fresh paths; they are not current execution results.

| Stage | State |
| --- | --- |
| Host page materialization | Passed after a recorded source-formula correction |
| Static source/page/pin audit | Passed; no RTL compiler invoked |
| Attention static compile | Not released, not run |
| Attention numerical RTL runtime | Not released, not run |
| RTL resource/timing, place/route, board | Not run |
