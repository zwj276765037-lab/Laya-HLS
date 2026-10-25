# R002 single-head strict softmax/Attention delivery (frozen)

Complete RTL functional/numeric/cycle scope: original real S128/head0 full and independent local sliding, one production start after768 public QKV32 writes, no score/probability injection. A single logical resource shell owns QKV, FP256, PS/G/context, LNexp, EXP8 and DIV8; engines contain no duplicate payload/FP arrays.

| Actual run | Total cycles | QK | Softmax | AV |
| --- | ---: | ---: | ---: | ---: |
| AT018 full |11038|4187|2333|4508|
| AT019 sliding |11038|4187|2333|4508|
| AT024 full generation2 after common reset |11038|4187|2333|4508|

Every head checks16384score/128max/16384prob/8192context, all actual QK products/tree/scale, softmax shift/EXP/seven adjacent sums/direct divide, and AV products/key partials. Final8192 context words return through native bank reads. Firstscore90, firstrow298, sumtail56, row launch gap16, firstcontext4251, AV feedback11; actual phase handoffs total10 cycles. Three real bank binds and FP leases; no normal phase reset or prepare. DONEhold3 and consumed-DONE/held-read3 preserve the real response and delay release. Preparation is counted as768 writes; exact preparation cycle is not inferred as zero or called end-to-end latency.

AT020 validates legal NaN input/finite shift overflow/illegal EXP domain/true exp-underflow total0, stages7/8/9/17; all score checks complete, bad row does not write probability,127 good rows16256prob/2032Gack remain exact, status1 denies public results. Finite PS/FP/SFU/LN/DIV/G holds yield all16384prob/2048ack correctly;2754cycle observed includes external stalls. AT025 proves early physical phase8 row0 loses to late logical phase7 row127/node127, with126good rows16128prob/2016ack. This is head-local ordering.

AT023 aborts actual phase3 SFU16inflight plus FP debt, drains every accepted service/storage/div debt, returns status2 in194softmax cycles, denies results, holds DONE3 and releases truly idle; no-reset generation2 rejects old identities and partial reload cannot start. AT024 resets with actual QK mul/add debt, reloads all768 QKV writes and completes the entire generation2 head. AT026 resets with actual SFU32inflight, reloads real score/max for generation2 and passes all16384prob/intermediates/bank reads plus held response release.

Current frozen production closure is final_source_manifest.json and each attempt's full manifest. AT008168-cycleEXP and AT011167-cycleEXP remain distinct. AT015 uses pre-phase6-extension sharedFP; AT018 onward include phase3-or6 internal bypass SHA80f91e30e26b7f23d84b6b1972335cce5c634b4a0e2fe20b7030e2b91d472230. Phase6/LN acceptance belongs to E014. AT00163-cycle tree FAIL, AT007 HLS ready/start FAIL, AT012/013 declaration static FAIL, AT014 TB gold-loading FAIL, AT017 real initial bind FAIL, AT021 request-counter checker FAIL and AT022 separator static FAIL are preserved and charged. AT003 remains static-only.

Declaration-level conservative row/tag/control3865B includes retained max512B and new service tags/control, below8192B; existing sharedFP tags6144B count once separately. Payload is LNexp32768B, LN native read registers1024B, EXP return FIFO8192B and DIV return data/error1056B, separately declared. idle_Q alias and LN parent remain unwired here. Logical instances and cycle simulation do not establish joint physical capacity or route timing.

Actual charged seconds: reference3.379594575, static359.021194723, RTL700.786864808, HLS/OOC0. Failed and unused-static attempts included; no cap increase; unused balance sealed without R003 transfer.

NOT_RUN: Decision true input, pre-RoPE pipeline, 16head, whole-layer logical first error, TANH, LN parent, full parent graph, joint OOC, P&R, board. R001 is separately frozen. R003 HEAD16-06 is independently authorized and budgeted, directly follows this completed stage.
