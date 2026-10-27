# GitHub snapshot — 2026-10-27

This repository records the Laya-HLS source tree, RTL/HLS and testbench sources,
build/verification scripts, specifications, project decisions and experiment
reports/manifests. This update includes the current M007 hardware/Host sources,
D38 core synthesis/optimization scripts and evidence, and the new board-first
CPU/FPGA operator partition with multi-channel HBM planning. D37 repaired,
original 30-layer, once-BEGIN normal-path RTL validation remains historical
evidence for its original source closure. D38's optimized core exceeds the device
LUT capacity; full-top placement/routing and board validation have not passed.
The new partition is a design, not an implemented or validated replacement.

Git excludes build/simulation caches, downloaded tool binaries, model weights,
raw binary tensor dumps and large generated reports. The 2026-10-25 update also
leaves new generated `.mem`/`.hex` test vectors of at least 256 KiB under
experiment run directories in the local archive. Source code, reference
generators, source/input manifests and compact receipts remain versioned.
The 2026-10-27 update also excludes new D38 generated diagnostic files of at least
5 MiB and runtime lock files. Compact resource/timing reports, source manifests,
scripts, completion receipts and reviews remain included. DCPs stay local under
the existing binary-artifact rule. No local file is deleted. See `.gitignore` for exact rules and
`GIT_LOCAL_ARTIFACTS.tsv` for the additional local-only files.

This is a source and evidence snapshot, not a complete binary experiment archive.
Referenced inputs, absolute local symlinks and tool paths may require the original
environment. Existing manifests retain their original hashes and paths. A clone
alone does not provide the full model/reference data or executable experiment.

The pinned `reference/vendor/ggmlc` dependency is included as source, including
its four existing local instrumentation changes. Its upstream history is not
included in this parent repository. The project-local Verilator runtime source
and patches are included; the installed tool and compiled model are excluded.
Reproduction requires matching model/reference bytes, tools/IP, source manifests
and environment paths; this is not a turnkey binary release.

The old physical stage has closed, and the new architecture is being specified.
Publishing this snapshot does not resume experiments or change any
PASS/FAIL/NOT_RUN status. No new inference, synthesis, RTL simulation or
physical-design verification ran for publication.
