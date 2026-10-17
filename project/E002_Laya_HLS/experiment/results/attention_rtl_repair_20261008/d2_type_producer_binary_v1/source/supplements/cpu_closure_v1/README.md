# Type producer CPU source-closure supplement

This supplement extends the independently accepted [source packet](../../source_packet.json) without changing it. The packet binds 25 proposed C++ source files and the generated model descriptor header; this supplement binds every transitive project-local `#include` reached from those 25 sources plus the CPU test translation unit. It also seals one exact future `/usr/bin/g++` command derived from the previously accepted vector CPU build flags and shared source list. Standard-library headers and the installed compiler are toolchain dependencies; a later actual build must record their versions and emitted dependency file.

`make_closure.py` may create or verify `closure_manifest.json` using only file reads, hashes, include parsing and JSON writing. `build_cpu_future.py` defaults to a read-only manifest check. Its `--execute` path requires a **new** signed CPU-build release binding this supplement, a finite budget, and a root heavy-slot token. The current Astra gate `d185ab57…` releases one qtype1 oracle materialization only; it does not release compilation or execution. Neither CPU driver nor the qtype1 materializer was run for this supplement.

The new manifest reports local header/include edges, the included production Controller `.cpp`, exact source order and command hash. It does not make a new numerical or RTL claim.
