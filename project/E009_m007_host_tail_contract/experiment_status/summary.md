# E009 / SM009 current status

- execution_state: completed
- verdict: PASS_SCOPED_NATIVE_CPU_SESSION / FAIL_SAMPLED_LIMITS; CPU overall
  performance remains open. A001 reviewed156 functional checks in this version.
- applicability: D-M007-SM009-NATIVE-CPU-03 / R002 / AT022–027 / release_evidence_v4.
  Binary921b329f...8593d72; shared512B schema c3d8d192... unchanged. R001 v2/v3
  and all intermediate R002 source/results/cost boundaries remain preserved.
- Stage: persistent native full/lazy Session implemented and actually run.
  AT023156 functional checks PASS; both frozen complete H0/tail exact; AT02738
  production source identities and39-file recoverable closure match, no FMA or
  saturating VNNI. No owned tool process remains running.
- Final performance: AT025200 full warm input median0.498548ms/P95 0.588732/max0.666537,
  0 violations; tail1.912646ms/P95 2.080202/max2.726395,6 violations. First full inputs
  1.141907/0.913050ms exceed0.75ms.32 new-word full-cache hits meet both limits.
  AT02632 true lazy misses meet both limits; first lazy26/32-miss inputs exceed,
  and first lazy tail2.263643ms exceeds2.25ms. No sample discarded or repeated to seek PASS.
- Initialization: full model/source/libm/recipe/weights/pool/regex/table1472.907ms,
  of which all50368 post-LN rows135.673ms; table206307328B. Reload replaces cache
  and invalidates old prepared objects. No request H0/hidden/logit/answer memoization.
- Resource use: R00227 attempts, reference/unit29.906244418991264s/600s,
  compile173.74383348802803s/900s, local profile15.288382256956538s/180s.
  Peak owned-tree RSS434528256B; CPU0–3/nice19/idle/shared heavy lock,<=120s each.
  Desired model/effort remain distinct from unverified actual fields in A008 report.
- Blocker: none for handoff. Device/XRT/Attention/board/whole-model/GPU benchmark
  remain NOT_RUN; CPU cap gap is a scoped outcome, not a global infrastructure block.
- Next CPU boundary: fuse native JSON/request/H0 entry to remove token/mask JSON
  roundtrip, and investigate scorer/scheduling tail outliers with new causal data.
  Controller will assign the independent quantizer successor; not started here.
- Evidence: experiment_results/runs/R002/release_evidence_v4.json,
  native_cpu03_handoff.md, AT023/025/026/027 raw reports/receipts and source archives.
