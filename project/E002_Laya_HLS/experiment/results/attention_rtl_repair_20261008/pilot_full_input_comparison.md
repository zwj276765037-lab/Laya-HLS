# Pilot versus full-top input audit (D0, 2026-10-08)

This comparison reads the frozen pilot `input_manifest.json` and full-top
`input_hashes.sha256`, then compares `syn.file` and settings in the captured
HLS configuration files. It does not infer RTL equivalence from matching
source hashes.

| Captured evidence | SHA-256 |
|---|---|
| `results/synthesis_memory_fix_20261007/followon_r1/pilot_vitis_r2/input_manifest.json` | `497f851728ded9e2c446f85e59d394067eb97eb79c90aa1d99755beecd5cf465` |
| `results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/input_hashes.sha256` | `49e10fbdac97b6db23c730435bce145522695a1009c5cacaed16dd4cb3ee770e` |
| `results/synthesis_memory_fix_20261007/followon_r1/pilot_preview/full_pointer_control_pilot.cfg` | `2fa6056018309b0c70aa0b08bb066d183e668ebf7bcd993a54479402fc635a3a` |
| `results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/ir_capture/full_top.cfg` | `c9322ef72df234035f56203197de6dace6e8a10636157610a7c0465e886212b2` |

The pilot manifest has 62 files and the full-top list has 64. After stripping
their common `Laya-repair-20261007/` prefix, **all 53 shared paths have
identical hashes**. In particular:

| Shared file | Identical SHA-256 |
|---|---|
| `hls/control/full_forward_controller.cpp` | `7e73939eba00bd062a5a6d75d77a82b2d0ec7fae0d2f5a16ebb359c821536b37` |
| `hls/common/laya_full_owner.cpp` | `8ce4d28470798d122cf958acb5433f4f5786e565be1afe996c9fe64a5d1d6973` |
| `hls/memory/full_loader.cpp` | `e5536516ae56055e2e25f32f07e1f6f6bf27c7b012aa7b0d5d0906e23681cf1d` |
| `hls/operators/full_tasks_attention.cpp` | `c59328610b12bff2a6546f4f7064e63227a545c785b6e687770e95f80cb2ab60` |
| `include/laya_full_runtime.h` | `9f518fd26db66bf0a2e865e6ba8a1150d6c2d70486856663f1e3368fa3c16621` |
| `include/laya_full_cache_storage.h` | `8960eb1cd1f919173a279913a74870e29f83bd007f107e144281c55bad511329` |
| `include/laya_tasks.h` | `20a8a3a0a94e997c05d0f81657498f16f8d08e406a202eb8b08dde5b2ccd55bf` |
| `config/full_sources.cmake` | `99ace612b8423e7eedebdb8869081d044ba4fa527a0b83244c93e8cd826eac5b` |

Both configurations select U55C `xcu55c-fsvh2892-2L-e`, 150 MHz, Vivado
flow, `pipeline_loops=0`, and the same two array-partition settings. Their
25-entry `syn.file` lists share 24 entries. The pilot alone compiles
`tests/full_pointer_control_pilot.cpp`; the full top alone compiles
`hls/control/full_forward_controller.cpp`. The pilot source explicitly
`#include`s that controller `.cpp` at `tests/full_pointer_control_pilot.cpp:6`
and calls `Controller::fresh` and `Controller::invalidate_incomplete` in its
controller mode. Thus the source is compiled in the pilot translation unit,
but **`Controller::linear`, its optional `qkv_pair` argument, and the real
QKV-to-RoPE chain are not reachable from the pilot top**. Pilot top is
`full_pointer_control_pilot`; full
top is `laya_typed_q8_forward`. Testbenches are respectively
`tests/full_pointer_control_pilot_tb.cpp` and
`hls/platform/full_kernel_csim_tb.cpp`. Both use C++17,
`-fno-fast-math`, and `-ffp-contract=off`; the pilot adds `-O2` only to its
testbench flags. Include-path sets differ around control/operators and the
generated descriptor directory.

The pilot generated descriptor hash is
`e82731e5599c499832e667323eedaec2e286601552190b5d6f77c7b2badf9747`;
the full-top descriptor hash is
`9b0bd819abce34e642b107d6d2006243235781f66653fe9952c1c702960385b8`.
A line-by-line diff shows only `kFullBuildTag[16]` differs; model, numeric,
layout, tensor descriptors, and all other lines are identical. The full-top
list additionally hashes its model manifest and five binary objects; the
pilot manifest instead includes pilot test files, run guards, and its earlier
gate/plan evidence.

The pilot source directly sets owner records to `READY` and assigns
`runtime.final_qkv_ref`, `runtime.loaded_kv_ref`, and
`runtime.loaded_kv_head` at `tests/full_pointer_control_pilot.cpp:28,45,50,104-113`.
It can demonstrate the local QK leaf but cannot exercise the full-top
controller's `LIN_QKV → publish → RoPE → LOAD_KV` path. The shared source
hashes rule out a source-version difference in the shared files as the sole
explanation; the different top/call graph remains material.
