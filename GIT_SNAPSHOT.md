# GitHub snapshot

This repository records the Laya-HLS source tree, RTL/HLS and testbench sources,
build/verification scripts, specifications, project decisions and experiment
reports/manifests. The project remains paused at the user's request; publishing
this snapshot does not resume experiments or change any PASS/FAIL/NOT_RUN status.

The original local tree is about 99 GiB including generated data. Git excludes
build/simulation caches, downloaded tool binaries, model weights, raw binary
tensor dumps and large generated reports. These files remain unchanged in the
original workspace. See `.gitignore` for the exact rules and `GIT_LOCAL_ARTIFACTS.tsv` for additional oversized diagnostics and extensionless executables. This is a source and
evidence snapshot, not a complete binary experiment archive; referenced inputs,
absolute local symlinks and tool paths may require the original environment.
Existing manifests retain their original hashes and paths.

The pinned `reference/vendor/ggmlc` dependency is included as source, including
its four existing local instrumentation changes. Its upstream history is not
included in this parent repository. No new inference, synthesis, RTL simulation,
or physical-design verification was run for this publication.
