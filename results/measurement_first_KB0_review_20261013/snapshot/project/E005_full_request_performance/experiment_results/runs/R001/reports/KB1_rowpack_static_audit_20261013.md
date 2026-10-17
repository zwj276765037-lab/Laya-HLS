# KB1 four-row output pack: bounded static audit

2026-10-13 · A006 review · root/A002 implementation ownership.

**No newly introduced safety issue found in the declared normal four-row cold Down path.** This is a source audit; compiler, simulation, numerical gold, 256 actual AW/W/B and performance are NOT_RUN. Physical resources are UNKNOWN. Baseline and measurement TB/runner were not modified.

Candidate: `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_axi512_writer_rowpack_kb1.sv` · 14944 bytes · SHA256 `5fad1da7479aeb4227da5744a857503b82b3690b1d10aec5231f96f7dd5bc691`. Baseline: `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/resident_regression_02/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_axi512_writer_v1.sv` · SHA256 `676eabc146f835ca3cfdaebb5fe6fbde85f3230b4046f18b8cf5a3403ed20a76`. The candidate deliberately retains the original module name and must replace the frozen writer, not be compiled beside it.

| Preserved source region | Candidate lines | Bytes | SHA256 |
| --- | --- | ---: | --- |
| shape_config_packet_address | 77–160 | 5355 | `03ce63d5838b401facb3f24312ee035cfc544594c8418f2b12502e330fed5d66` |
| configuration_identity_latch | 209–221 | 1101 | `2774d04957314f4bfb36a663fdf00519cf9a63c31acc99b6bff2ecc9e9c0c161` |
| AXI_signal_equations | 185–189 | 383 | `4c482ec2037015cf59584c7fa623b2be482827878685d2dc896221a88c809fa8` |
| retirement | 258–260 | 216 | `a6a66823b41f342abd323449cfa556f8a47e10e471e2a398195f8b45dccc13e9` |

All four regions are byte-identical to the frozen baseline. Configuration/packet/address checks, full identity latch, AXI output equations and retirement authority remain single instances. Four caches expand only pack valid/address/strobe/data, adding 3×(1+64+64+512)=1923 logical bits. This is a field-storage count, not a mapped LUT/BRAM result.

- Lines 164–179 select a sealed row and permit replacement of the held row only when that row is selected. Lines 226–235 capture the old selected cache into tx, clear its local valid/strobe/data, then merge. A same-row merge sees the cleared valid bit; another row's merge leaves the selected row and all other caches intact.
- Lines 123–128 retain packet owner/tile/row/mask/final checks. Lines 176–182 and 236–244 clear held_pending by beat_mask and admit the next packet only after the old packet finishes or is absent. Same-edge NBA replacement does not alter the old held row used for that merge.
- Lines 161–162, 175 and 185–189 keep the old AXI transaction immutable until physical B. READY0 or a partially sent AW/W transaction cannot be replaced. Fault does not withdraw a presented VALID or mutate its address/data/strobe.
- Lines 246–249 clear all unsent caches/held state in the original bad-held, B-error or bad-packet branch while keeping existing tx debt. Lines 164–169 seal every valid row during flush; lines 183–184 and 254–260 require all caches, held packet and tx empty after last B before completion/retirement.
- Fixed row priority has no newly found normal-path deadlock: a held row that cannot merge blocks new packet admission, so the finite other sealed caches drain before it can transfer and proceed.

Two inherited error windows remain unmeasured. At lines 175, 181–182 and 226–249, a new bad packet handshake can coincide with transferring a sealed unsent cache into an empty tx slot. The transfer then creates tx debt before the bad-packet branch clears the caches; AW/W may first appear after that fault edge. At line 251, stray B with no tx sets fault without clearing held/cache state, so general recovery can remain blocked by unsent debt. Both behaviors are present in the original baseline, rather than new row-cache logic.

Root explicitly retained the inherited fault policy for this local normal arithmetic experiment: stop the sample on any experimental error, add no generic fault-recovery work here, and require affected error regressions before production integration. This audit does not close those obligations.

The candidate hypothesis is 512 partial 64-byte beats → 256 full 64-byte beats for the same 16384 useful bytes and 512 final TN8 packets. The actual benefit and numerical correctness remain to be measured using the same fixture/gold, AXI response strategy, seven-cycle done hold and resource profile after KB0 completes. No source files were edited and no tools or agents were launched by this reviewer.
