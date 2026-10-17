# P2 F0 final independent read-only review — 2026-10-07

**Review verdict:** The frozen model, production CPU build, 27 CTests,
three complete forward comparisons, fault recovery, direct fixtures, and
real 13-port top CSim are internally consistent and pass their stated
functional checks. This is a CPU and CSim verdict. Full-top synthesis did
not complete, so generated full-top RTL, RTL co-simulation, routed timing,
platform integration, and board execution remain unverified.

The machine-readable [independent audit](full_final_independent_readonly_audit_20261007.json)
rehashed the actual files rather than relying only on report status strings.
Its status is `INDEPENDENT_FINAL_CPU_CSIM_AUDIT_PASS`.

## Frozen identity and compiled closure

- The final package [manifest](../engineering_p2/full_cpu_final_20261007/model_package/full_model_package_report.json)
  has build tag `4f12ecfe940ecf2a8998a8626fc1ed1c`, manifest SHA-256
  `0d3ef9fbcc0de7ddf49c26921b523f4ca22a16d856c58e1c523b52b61e7dbec3`,
  and generated-header SHA-256
  `369aba58c48ef410901220f6b9f3dad7c02686ea2417633803ce87c011678deb`.
  I independently matched the source GGUF, all five exported BO sizes and
  hashes, the three tag preimages, and all **99** build-tagged source hashes.
  Package verification reports 153 tensors checked and 152 restored.
- The [compiler closure](../engineering_p2/full_cpu_final_20261007/source_closure/full_source_closure_report.json)
  SHA-256 is `623f38d3aa2c895a6f362f3f60f456795458050fbded2f4b30119b9569dec3e4`.
  Its 24 production C++ files exactly match the CMake source list and
  compile database. I rehashed each source, object, dependency file, all
  **36** project/generated-header dependencies, and the archive
  (`5d530d5e2a371c1cf74c9234889544f1d2bdc9486533d54f2fda940980c5586c`).
  Each compiler `.d` file contains its declared dependencies, and each
  object is newer than those inputs. The package, build, DUT, fixture, and
  comparison reports bind to these exact manifest/closure/library hashes.
- The final compile database, `.d` files, object and executable timestamps
  confirm the tested `full_memory_tb.cpp` SHA-256
  `b4c214d2c2480758237b7d1bd61e5a61a0d1b540fca73216382f62da5fd9561c`
  and matrix/scorer TB SHA-256
  `e0716b243171f644ba9ba1afac41a8323819ac2edbc98922c0f81937fefd0a88`.
  Both targets link the same production archive. The memory TB contains
  the short-IO secondary commit-error assertion; the scorer TB contains
  the incomplete full-B lease commit rejection. The [final CTest log](../engineering_p2/full_cpu_final_20261007/ctest.log)
  records **27/27 passed**, including both targets.

## Complete request and recovery evidence

I compared the actual DUT and independent-oracle binary files for all
**141** checkpoints (47 in each of three successful requests). Their byte
sizes, shapes, SHA-256 values, and contents agree: **18,094,384 F32
elements bitwise**. This includes the `final18` result-frame checkpoint.
The [comparison report](../engineering_p2/full_cpu_final_20261007/compare/full_forward_dut_compare_report.json)
and [run metadata](../engineering_p2/full_cpu_final_20261007/dut/full_forward_dut_run_report.json)
refer to the same model, source closure, and one persistent Runtime session.

The four requests used IDs 1, 2, 3, and 4 without a Runtime replacement.
Every request's pre-state equals the preceding post-state, including the
accepted failure. I checked the raw `runtime.tsv` fields, operation arrays,
and design call counts against the per-request metadata:

| Request | Actual tasks retired | Encoder / Decision layers | A8 epoch after | Result |
| --- | ---: | ---: | ---: | --- |
| B2/S128, ID 1 | 37,158 | 28 / 2 | 1,924 | 47 checkpoint bitwise pass |
| Inf-gamma accepted failure, ID 2 | 17 | 0 / 0 | 1,924 | numerical error frame |
| B1/S128 from b0, ID 3 | 18,895 | 28 / 2 | 2,886 | 47 checkpoint bitwise pass |
| B1/S128 from b1, ID 4 | 18,895 | 28 / 2 | 3,848 | 47 checkpoint bitwise pass |

The failure executed 16 `EMB_TOKEN` tasks and one failing
`LOAD_LN_PARAMS` task. Its 384-byte result frame reports status 6,
flags 9, error task 17, 578 accepted input elements, zero committed output
elements, `UINT64_MAX` first-bad index, and an all-zero output payload.
The AUX byte mutation was restored before ID 3 and the on-disk package
hash stayed unchanged. The two subsequent full requests completed and
matched their independent oracle checkpoints.

Direct fixture reports on the same closure are
[front](../engineering_p2/full_cpu_final_20261007/front_dut/full_front_dut_report.json)
(527,360 F32),
[attention](../engineering_p2/full_cpu_final_20261007/attention_dut/full_attention_dut_report.json)
(1,622,016 F32 per mode),
[matrix/scorer](../engineering_p2/full_cpu_final_20261007/matrix_dut/full_matrix_dut_report.json)
(10 cases, 329,730 F32), and
[focused shapes](../engineering_p2/full_cpu_final_20261007/shape_dut/full_shape_dut_report.json)
(S64, S256, S512, S1024; typed tasks and addresses only).
The focused shapes are not full-network runs.

## Current HLS evidence and limit

The [final top CSim log](../engineering_p2/csim_full_final_20261007/csim.log)
has exit 0 and `FULL_KERNEL_CSIM_PASS checkpoints=47 values=9047192
tasks=37158`. I rehashed all **111** listed CSim inputs and confirmed
its 24 HLS production sources exactly match the CPU archive's 24 sources.
The log shows compilation of the real thirteen-argument wrapper and its
top testbench. This CSim covers one complete B2/S128 request; recovery and
the two B1 requests are covered by the persistent CPU run above.

The [base-zero pilot](../engineering_p2/axi_base_zero_pilot_20261007/after/source/results.md)
separately confirms the approved memory fix in generated `full_read`
helper RTL: a base of zero and a base of `0x100` each produced one internal
read request with the expected address and returned byte. The
[pre-fix pilot](../engineering_p2/axi_base_zero_pilot_20261007/source/results.md)
preserves the original base-zero rejection. This pilot does not cover the
outer `m_axi` adapter or full top AXI4 protocol.

The final-source [full-top synthesis attempt](../engineering_p2/csynth_array_f0_final_20261007/termination_reason.txt)
was stopped by its 180 GiB available-memory guard after Vitis's transform
stage (`csynth.exit=1`), before a complete synthesis report or generated
top RTL. The CPU gate's own [phase status](../engineering_p2/full_cpu_final_20261007/full_final_gate_report.json)
was written before the separately completed CSim; the two pieces of
evidence are kept distinct.

The first independent audit draft expected a different string for the
accepted-failure success label. The actual comparison label is
`ACCEPTED_FAILURE_RECOVERED`; I verified it against the run metadata,
corrected the audit predicate, and retained the
[initial audit result](full_final_independent_readonly_audit_initial_20261007.json).
