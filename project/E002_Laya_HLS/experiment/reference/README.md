# Native Typed Q8 reference capture

This directory contains actual fixed-GGML runtime inference data, not random tensors or a reconstructed model. The GGUF is the pinned Typed Decisions Q8_0 model (455179648 bytes, SHA256 `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`). Native preprocessing uses the tokenizer embedded in this file. The two Chinese questions are refund and department, in that order.

`runs/typed_q8_ref_20261005/original_native` records the upstream B2/S94 input. `abi_replay` records a separate native B2/S128 execution, padding with PAD 50283, rebasing live markers, and filling unused markers with each row's CLS. Its `request_v1.bin` is a verified 1856-byte offline fixture. The three unfrozen numeric/layout/build tags are zero: this file is explicitly production-ineligible.

Each manifest lists exact native graph tensor shape, byte strides, dtype, endianness and SHA256. Semantic aliases identify measured checkpoints. A view binary contains its native storage span, including stride holes; it must be read using `ggml_ne` and `ggml_nb_bytes`, rather than reshaped as packed elements. Weights are loaded directly from the hash-bound GGUF and are not duplicated in the dumps.

The source is `vendor/ggmlc`, fixed commit `dcc300def5c5bc8fa778223589244abb0555a5de`, with `instrumentation.patch`. Graph outputs are pinned before allocation, and native backend buffers are read after compute. The audit additionally saves actual internal quantized MUL_MAT scratch buffers and reports the executed branch. Neither these data nor the native fused attention profile should be mislabeled hardware Q8-F. Fused attention score/probability matrices are unavailable and are not reconstructed as backend checkpoints.

Reproduce from this directory using the bundled local CMake (no global installation):

```sh
cmake-3.31.8-linux-x86_64/bin/cmake -S vendor/ggmlc -B build/cpu -DCMAKE_BUILD_TYPE=Release -DGGMLC_ENABLE_CUDA=OFF -DGGML_NATIVE=ON
cmake-3.31.8-linux-x86_64/bin/cmake --build build/cpu --target laya -j 8
python3 capture.py
LAYA_REFERENCE_ABI128=1 python3 capture.py
python3 make_fixture.py
LAYA_REFERENCE_FORCE_PIN=1 python3 audit_backend.py
LAYA_REFERENCE_FORCE_PIN=1 python3 enrich_manifest.py
python3 verify_normal.py
python3 inventory_gguf.py
```

All final full captures and audits bind the same final binary and instrumentation patch hash. Pinned capture outputs and normal allocation outputs are compared byte-for-byte. Native CLAMP constructs an in-place view: 32 pre-CLAMP snapshots preserve sources before overwrite, and affected end-of-graph records are labeled. The true act probability vector uses preclamp_31.bin. This checkpoint mechanism requires the fixed one-thread capture configuration. `backend_path_audit.log/json` supplies actual CPU execution evidence. Hardware implementation and FPGA validation are outside this capture.
