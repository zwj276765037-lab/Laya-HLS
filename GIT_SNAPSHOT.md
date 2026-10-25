# GitHub snapshot — 2026-10-25

This repository records the Laya-HLS source tree, RTL/HLS and testbench sources,
build/verification scripts, specifications, project decisions and experiment
reports/manifests. The current publication includes the M007 hardware/Host
implementation and the D37 repaired, original 30-layer, once-BEGIN normal-path
RTL validation records. The README separates measured RTL cycles, conditional
frequency conversion, CPU-only measurements, design budgets and unmeasured
physical/board performance.

Git excludes build/simulation caches, downloaded tool binaries, model weights,
raw binary tensor dumps and large generated reports. The 2026-10-25 update also
leaves new generated `.mem`/`.hex` test vectors of at least 256 KiB under
experiment run directories in the local archive. Source code, reference
generators, source/input manifests and compact receipts remain versioned.
No local file is deleted. See `.gitignore` for exact rules and
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

The project remains paused at the user's request. Publishing this snapshot does
not resume experiments or change any PASS/FAIL/NOT_RUN status. No new inference,
synthesis, RTL simulation or physical-design verification ran for publication.
