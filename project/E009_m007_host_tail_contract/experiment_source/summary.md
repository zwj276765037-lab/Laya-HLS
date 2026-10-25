# E009: M007 Host/CPU handoff source

mission: M007 / SM009 / R002 current; R001 retained history; owner: A008.

Current continuation: D-M007-SM009-NATIVE-CPU-03 / R002 execution completed.
AT022/023 persistent native Session passed156 checks, both frozen complete H0/tail
bit comparisons and full/lazy cache equivalence. Final library SHA256
921b329faa0858ca3aa4e1ea52e709965b7a0042e364e39e8da717acc8593d72.
Native BPE/recipe/decode, initial LN, ordered Q8 scorer, marker LN/stats and ACT
execute without Python numerical reference. AVX512/VNNI, CPU0 caller/1–3 workers,
local fenv/affinity restoration, no FMA/FTZ/DAZ. Full50368-token post-LN cache
206307328B; initialization includes full model/source/libm verification and regex.
AT025200 full-mode warm inputs meet0.75ms,6 tail samples exceed2.25ms; both
first inputs exceed0.75ms. Function PASS, overall performance FAIL remains open.
[Final evidence](../experiment_results/runs/R002/release_evidence_v4.json) and
[CPU handoff](../experiment_results/runs/R002/native_cpu03_handoff.md).
Independent R002 budgets: reference/unit600s, compile900s, local CPU profile180s.
R001 v3 was accepted by A001 and is preserved. Before the first R002 source edit,
39 source/dependency files were archived as R002/predecessor_v3_sources.tar.gz,
SHA256 e69654ae4e8c137a6754b054c36741672a1c153232ffce3c825c260da1ec6eda.

Historical D-M007-SM009-FRONTEND-02 completed result:
`frontend.py`/`native_frontend.cpp` reuse the actual native BPE/questions/recipe
and original decode member arithmetic. Complete uncut sequences <=128 are kept;
longer sequences fail. Legal >48-token options are intentionally retained.
AT020 clean native/oracle build, AT021133 functional checks and AT022 actual CLI
passed. AT023 compiled9 existing native CPU leaf objects; link/math/speed NOT_RUN.
Current identities/costs are in release_evidence_v3.json; the accepted first-slice
source/results below retain their AT014-017/release_v2 version boundary.

Original engine.cpp SHA:4f169af9397d80d6a7d785f1dc0c40bbe4c20f554f5742dd0d9a2cb83c11e741.
Original private decode member text SHA:aa404af639460e149962c893882b63de140b61099842b10bb7bc2c090f8a60da.
The production standalone adapter preserves its exact arithmetic body; a separate
oracle class independently compiles the original member body and loads metadata
with the original GGUF library. These validate adaptation, not a second math gold.

The first code slice delivers executable strict H0 and compact-tail adapters,
not an XRT deployment. [Protocol](protocol.md) defines inputs/resources/evidence.

- One schema: E002 `host/m007_deploy/schema.json`; final SHA256
  `c3d8d192e26cc249a07818f73f2926181965fd460faa5ea140b28d689517d24c`.
  512-byte little-endian metadata; H0=524288 B; tail=69632 B. Host codec and
  generated C++ constants/SV package bind the same schema, including magic/version. Register mapping unbound.
- Frozen original source: `tests/full_reference.py` SHA256
  `fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784`.
  No math/helper changes in the independent whole graph. CPU contract adapter
  invokes its original operations in the original order.
- Model SHA256 `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`,
  455179648 B, actually present and fully verified in AT003. Embedded graph
  SHA256 `f33f7848434b73048f957dcd232e1bd4ff99e95b8cf41c98191b69fddad815f9`.
- Expected values come from existing read-only independent whole-graph checkpoints
  at E002 `results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle`.
  Only frozen five request inputs, gamma/weights and final Decision hidden are
  read; the new experiment does not regenerate a full graph or derive gold from DUT.
- Platform: host `user`, Python3.12.3/NumPy1.26.4/glibc2.39; g++13.3 C++17.
  All actual calculations/compile use the common lock, CPU0-3/nice19/idle,
  <=120s each and <=16GiB RSS, reference/unit600s and compile600s cumulative.

Acceptance: independent frame/negative tests, frozen H0 and every tail checkpoint
bit equality, final18 equality, generated Host compilation, runnable explicit CPU
CLI and explicit device NOT_RUN. No board, RTL, timing or business quality claim.

Business qtype mapping is the original Choice0/Score1/Noul2. Noul renders exactly
false/true candidates; final schema enforces count2, Choice/Score1..16, exact
marker_mask sum, preserving duplicate markers and slot holes.
