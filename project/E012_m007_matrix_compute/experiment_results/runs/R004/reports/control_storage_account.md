# R004 actual pure-path control declaration account

Current source is mapped from immutable R003 AT018 in extraction_source_map.json. No lifecycle-sharing deduction is assumed. Full facade and pure quant/A control declarations are unchanged; engine FP/PS ports/owner aliases are wires to existing registered identities, not new state.

| block | persistent bits in profile-off source | module-rounded bytes | conservative bits incl same-cycle scratch | conservative bytes |
|---|---:|---:|---:|---:|
| matrix facade |1923|241|1972|247|
| pure matrix controller |3138|393|3300|413|
| pure quant/A incl128x16 coords |2357|295|2357|295|
| independently rounded sum ||929||955|

The prior superblock controller had7298persistent bits, including4096bits issue_time/ps_time and64bits measured-max registers. PROFILE_ENABLE=0 does not instantiate g_profile and its two64x32 arrays; max_issue_commit/max_ps_feedback are constant invalid outputs and profile_valid=0. Actual source control reduction is4160bits=520B. The agreed nominal512B reduction can conservatively retain8B unused reservation, yielding963B matrix-side allocation rather than955B. Neither total is a joint4KiB fit result. With the still-unmodified old layer3754B, actual-source matrix955B alone would total4709B before parent/LN/G additions; A007's separately authorized compression/sharing changes must actually land before the combined account can close.

PROFILE_ENABLE=1 compatibility instantiates all original512B arrays plus the8B max registers. AT002(profile0) and AT004(profile1) have identical actual QKV3 outputs/protocol/cycles (8370TB/8357joint), and passive TB measures31issue→actualPSwriteack/13actualPSread→writeack in each. Enabled profile metrics equal passive measurements; disabled numeric zeros are explicitly invalid. The passive TB arrays are outside DUT and cannot affect production ready/data/error/retirement. Other debug counters remain fully counted.

Per-field prior declaration tables are retained in R003/reports/single_resource_boundary.md; only the actual generate removal and max-register constants change this count. Existing F32 row-major standalone shell adds169B if instantiated; it is not part of the production pure facade/front interface and cannot be silently deducted from a parent that retains it. Parent descriptor/Check/mux state remains to be counted when implemented.

Arithmetic payload remains explicit and unchanged:131072B op0/op1,1088B W holdings,512B context bias operands,128B output holding and16384B sole coefficient payload. Inherited fixed-pipeline metadata also remains in the physical declaration account:32dot trees2304Btag+24Bvalid;256half-product leaves12384Braw tag/valid declarations (includes unused tag[2]);256converters3104Btag/valid;format129Brounded valid/exception mask. None is removed from physical totals, treated as numerical payload, or assumed automatically merged. SharedFP return-tag6144B and existing independent service budgets are counted once under owner A007, not as another controller4KiB. No synthesis/route/totalFF result is claimed.
