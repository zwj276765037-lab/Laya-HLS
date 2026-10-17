# QWIGQD0: real LN_FFN source quantization into Wi→G→Down

**AT034 is a bounded four-row normal RTL PASS, pending controller review.** The original enc0 LN_FFN F32 first four rows were initialized as a read-only DDR input, read by the existing quantizer over actual AXI, converted to the original Wi q/scale and published to the existing dualA epoch1. In the same runtime, one resident engine and its existing caches then completed Wi→real DDR/reader→G→the same quantizer/dualA epoch2→Down. The original independent Wi/G/quant/Down gold, last B, leases, true response consumption, and final whole-DDR byte check all passed. The LN_FFN producer and FFN residual remain external to this window.

## Frozen attempts and failure

AT033 static and short pilot passed. Its full stopped at cycle162864 immediately after the GATE Q A publication marker at162862 with `Fatal: GQD0 bridge completion/physical debt`. This was a TB assertion error: `quant_f32_two_row_feeder_v1` clears AR/R/row/input counts on each accepted task, and `quant_dual_a_v1` clears half/scale counts on each fill. AT033 erroneously expected the source-Q and GATE-Q counts summed across tasks. The raw failure and receipt remain FAIL. AT034 changes only the frozen TB counter expectation/diagnostic and runner provenance relative to AT033; the bridge RTL, all other frozen files, data, generated IP and response profile are identical. At the formerly failing point AT034 printed `starts=4 rows=4 input_beats=656 half=656 scale=328 complete_rows=4 source_R=656 gate_W=656 gate_R=912 source_R_TB=256 g_half=656 debt=1`, then consumed the bridge response and continued to Down.

AT034 has 106 manifest references to 104 distinct frozen paths; every frozen SHA/byte identity was rechecked. The original 16,384B F32 source equals the first four rows of the complete enc0 LN_FFN capture and equals the generated DDR byte image. The original Wi q and scale binary bytes are 4096B/256B with SHA256 `839f4cb8cdb85f5fc1ad8449b9e55ba649915cac7a02aa9d7575d8afd8c49f34` and `4cca5faa8d74766136eb72e6950b422150be37899e808d15623dc548deee9d6f`; the loaded comparison memories decode exactly to them. This is the reference identity, not an injection into dualA.

## Actual result and timing

| Same AT034 cold runtime boundary | Cycle / measured work |
| --- | ---: |
| Source Q accepted → A published | 23 → 1101; 1078 cycles |
| Source AXI input / Wi A | 256 R beats = 16,384B; 256 half commits, 128 scales, 4096 INT8 |
| Wi cfg → first done → actual consume | 55236 → 102146 → 102153 |
| Wi physical output / handoff | 20,992 F32; 1312 AW/W/B; Wi complete marker 102154 |
| G accepted / Wi reader | 102158; 1312 Wi R and four row-done barriers |
| GATE output / second Q | 10,496 F32; 656 AW/W/B, 656 R, 328 groups; second A publish 162862 |
| Down cfg → first done → actual consume | 189939 → 206125 → 206132 |
| Down output / full TB | 335,872 PS lane-groups, 4096 F32, 256 AW/W/B; 206133 cycles |

The new cold TB is 819 cycles longer than AT032's 205314, and the G-accepted→final-consume interval remains 103974 cycles (`206132−102158`). The old input was prequantized, so the 819-cycle difference is an end-to-end boundary change in this response profile, not a standalone quantizer latency estimate or a deployment-speed claim. The GATE Q `source_R=656` and half/scale counters are per-task; the raw final marker's `total_quant_groups=328` label also denotes only the second GATE task, not 128+328. First/last source AR/R edge timestamps and source AR burst count were not printed; the actual 256 R beats, bounded read addresses and completion/publication were checked.

AT034 final DDR loop executed before the chain PASS marker: all 393216B were checked, including source read-only 16384B, Wi 83968B, GATE 41984B, Down 16384B, and 234496B unwritten sentinel bytes. Output written flags, original word gold and source bytes were verified; no middle q/scale or Wi/GATE output was preloaded. Both Wi and Down final B, seven-cycle held done response, once-only consume and local lease/ledger debt closure remain checked. The first external Q result was consumed before G admission; the second Q result was consumed before Down admission.

## Tool and applicability

AT034 static/pilot/full guard child0 with no trigger: 82.810202s / 28.706722s / 1778.416778s; full peak owned RSS 1510892KiB and minimum MemAvailable 411043416KiB. The three guards were serial. All 31/9/9 observed policy samples report CPU0–3, nice19 and idle I/O. The full was admitted against a conservative 2683.631229s estimate below the existing 3600s cap. AT033 full FAIL cost 1276.007880s and is not rewritten as PASS.

This establishes only the original B1/S128, batch0/row0 four-row normal window and this AXI backpressure profile. It does not include the LN_FFN producer, FFN residual, the complete 28+2-layer/122-matrix request, production 13BO owner/recovery, all error profiles, joint resources, physical timing or U55C board deployment. M003/M004 remain open. No new HLS/OOC/P&R/board tool was run.

Evidence: [AT034 receipt](../attempts/AT034_QWIGQD0_chain_02/receipt.json), [raw full log](../attempts/AT034_QWIGQD0_chain_02/raw_full.log), [manifest](../attempts/AT034_QWIGQD0_chain_02/input_manifest.json), [independent verification](../attempts/AT034_QWIGQD0_chain_02/verification.json), [source identity](../attempts/AT034_QWIGQD0_chain_02/source_identity_check.json), [AT033 failure](../attempts/AT033_QWIGQD0_chain_01/receipt.json), and [connection map](QWIGQD0_connection_map_20261014.md).
