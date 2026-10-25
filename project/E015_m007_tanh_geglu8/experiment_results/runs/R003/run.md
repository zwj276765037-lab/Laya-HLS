# E015/R003 D31 final bounded delivery

Execution completed; supported for exact source and original-fixture same-runtime equivalence plus observed single-snapshot local cost. A001 scope review pending. A008 runtime /root/m007_host_tail_engineering; desired gpt-6.1-sol/xhigh, actual configuration UNKNOWN. New v3 only, old v1/v2/D26 R002/D28 E020/parent/shared dependencies untouched.

| Attempt | Phase | Result | Child wall seconds |
|---|---|---|---:|
| AT001_eq_build | static | per-target audit and real v2/v3 snapshot PASS | 14.34901304898085 |
| AT002_eq_rtl | RTL | same-runtime all original output/node/protocol checks PASS | 14.15276184398681 |
| AT003_v2_build | static | one actual v2 TANH8 snapshot PASS | 11.839297086989973 |
| AT004_v2_cost | RTL | complete frozen workload/checkers PASS | 9.684000001987442 |
| AT005_v3_build | static | one actual v3 TANH8 snapshot PASS | 8.407813775003888 |
| AT006_v3_cost | RTL | identical complete workload/checkers PASS | 9.183186706970446 |

Source audit:2447same-clock unique NBA targets/processes→1process, identical per-target conditions/RHS/data order/declarations/functions/module nodes/42leafs,valid_pipe reset outsideCE/data no newreset/wrapper protocol unchanged except versions. New core59f29c46f1896c328bd8f8396b0830e9148f5f12b9d653bda807f331684ad47b,wrappera09ad675c49858e80f544e0b84bfdff4a027c323df35485e0841c4812e7196c1. Zero new RTL FF/clock gate from exact source preservation, not synthesized resource count. Old D26 audit unchanged.

Actual v2/v3 same-runtime6726outputs and282812nodes on each version PASS;841core152/public153/II1,held298/reject6/credit256/flight152,17inflight reset/newgen64/8,boundary384/nonfinite6,lease/release-debt/token-stage/CE retained. Eq and both singles have same2671cycles, identical841-line traceSHA55827849a0a58a64f1a2f9e15a047e4d777c0da802c366c277e5d30a47157072. Original vectors/nodes/schedule hashes verified; no newgold.

Single-snapshot xsim totalv2 9.188027718046214→v3 8.694883176998701s,ratio1.056716637936214x/reduction0.493144541s. Active+protocol2.8998402879806235→2.5160072140279226s,explicit448-cycleidle0.14145902200834826→0.019675718969665468s;startup~5.083/fixtureinit~0.977s unchanged. Each is one sample; no variation/CI/general/joint/FPGA speedup claim. RUN stage includes protocol/reset/quiescent gaps; complete CEactive2044/CEidle612/reset15cycles separately retained. LN128 gate unchanged.

All6archives exactly19files verified, allcurrent source hashes match frozen archives;3×24originalsnapshotfiles unchanged, runtime additions listed.4714owned policy samples/0I/Ocorrections, all cleanupempty/PGIDabsent, no active/queued tool. Static34.596123910974711/300s,RTL33.019948552944698/600s,ref/OOC0;120s reserve retained;unused balances not transferred. Actual release delivered to A007 and root; final A010 release notification tool returnedthreadlimit, root informed.

Evidence independent_delivery_v1.json, production_manifest_v1.json, standalone_cost_comparison_v1.json, budget_closure_v1.json, exact receipts/source archives/commands/progress/stdout/stderr and trace/snapshot inventories under attempts. No new parent withv3 or unauthorized joint/LN128/OOC/P&R/board run.
