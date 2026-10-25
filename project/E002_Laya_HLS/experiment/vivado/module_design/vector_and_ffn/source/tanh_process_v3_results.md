# TANH v3 results

E015/R003 D31, A008, Vivado Simulator2025.2 xvlog SV/xelab --relax -mt4 --O3; source/input/compiled snapshot identities frozen per attempt. Desired gpt-6.1-sol/xhigh, actual configuration UNKNOWN. Old v1/v2 and parent dependencies unchanged.

Source audit PASS:2447→1 core sequential processes,2447 distinct NBA targets,42 unchanged leaves per core, zero new RTL FF/clock gate, reset and CE priorities unchanged. This is source-equivalence evidence, not synthesis resource/timing measurement. Old D26 string audit and all R002 evidence preserved.

Same-runtime actual v2/v3 PASS:6726 scalar output checks and282812 node checks per version;841core152 latency checks/public consume153/II1. Credit peak256/flight152,held298cycles,reject6,17inflight reset/newgen64 and8, boundary384/nonfinite6,actual lease/release-debt and token-stage/CE checks all retain original assertions. All2671cycles and841response trace lines equal in eq/v2-only/v3-only snapshots, SHA55827849a0a58a64f1a2f9e15a047e4d777c0da802c366c277e5d30a47157072.

| Single-snapshot category | v2 seconds | v3 seconds | v2/v3 |
|---|---:|---:|---:|
| Simulator launch→exit | 9.188027718 | 8.694883177 | 1.056716638 |
| Startup before TB INIT | 5.082593658 | 5.083785558 | 0.999765549 |
| Fixture initialization | 0.977341337 | 0.976717956 | 1.000638241 |
| Active+protocol stage | 2.899840288 | 2.516007214 | 1.152556428 |
| Explicit idle-noise448cycles | 0.141459022 | 0.019675719 | 7.189522387 |
| Shutdown after TB DONE | 0.086793413 | 0.098696730 | 0.879395022 |

Total reduction0.493144541s/5.36725%, one sample each, no variation/CI measurement. RUN category includes protocol/reset/quiescent gaps outside explicit idle_noise; CE-active2044/CE-idle612/reset15cycles are separately counted over2671total. Local simulator cost only; no joint speedup/FPGA timing claim and LN128 gate unchanged. No additional flag sweep, new gold or parent/joint run started.

Six attempts EXIT_ZERO: static14.349013049/11.839297087/8.407813775s and RTL14.152761844/9.684000002/9.183186707s. Cumulative static34.596123910974711/300s, RTL33.019948552944698/600s, reference/OOC0;120s reserve retained, old balances not transferred. All6source archives19files each verified;24original snapshot files per build unchanged, runtime additions separately recorded.4714owned policy samples/0corrections, all owned cleanupempty/PGIDabsent, no active/queued A008 tool; window released to A007/active controller. A010 release notice tool hit threadlimit; A001 informed.

Final evidence: project/E015_m007_tanh_geglu8/experiment_results/runs/R003/{independent_delivery_v1.json,production_manifest_v1.json,standalone_cost_comparison_v1.json,budget_closure_v1.json}. Source/receipt/trace/progress/snapshot/stdout/stderr remain in six AT directories. A001 scope review pending. Parent withv3/joint/LN128/OOC/P&R/timing/board NOT_RUN.
