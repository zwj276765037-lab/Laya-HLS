# D2 Type Producer CPU: bounded actual dependency capture

2026-10-09. GPT-6 Astra / xhigh. Source preparation only. No preprocessing, CPU build, CPU DUT execution, HLS or RTL execution is released here. The actual qtype1 fixture must first pass its independent materialization review. Preserve the original source packet, cpu_closure_v1 supplement, host-chain supplement and original 38-argument command unchanged.

## Existing accepted inputs and scope

The functional source packet is SHA256 `1201554b4b8c18d376a4045cdb4b64d8a35c37c8b0a3d5b3e6b61ab14c0137f1`. The local-header closure is `2b344450e4cd8a091fceea8ad3ff4bbc847a47d6297fd322df753e93b8e1eacb`, independently accepted under `ff55c1f0dc35bf73838ca4bb9da43c14c6603dc67e738a9e04756fc84d3fc62b`. The host-chain supplement is `ef749b097ec51424c717ec9f1cd7408aee233ab97d02a99fd2740f6326b69bf8`. It identifies GCC 13.3 compiler/front end, binutils 2.42, glibc/libm 2.39, and separate libstdc++/libgcc runtime 14.2 files. It is a prospective identity record, not the final executable's observed dependency closure.

The frozen original argv hash is `2925782ae2112a47c8c65e53d594e3e67c1996da137ec560e7854a11573a9dd0`. It names exactly 26 ordered translation units, four ordered -I roots, `-std=c++17 -O2 -fno-fast-math -ffp-contract=off`, and `-lm`. The original Controller is included through the slice translation unit once; do not compile it again as an additional translation unit. No C++ source, reference, fixture, numeric flag or include-order change is part of this supplement.

## New candidate command sequence

Prepare a separate default-read-only driver and immutable command manifest in this supplement. Use a new named fresh output/control root, distinct from the original dormant cpu_build_v1. A future separately gated build consists of 26 sequential compilation commands and one link command under one aggregate resource/time guard. Never launch one compiler per source concurrently.

For translation unit i, retain the exact four language/numeric flags and ordered -I roots, then add `-MD -MF <fresh-build>/deps/tu_i.d -MT <fresh-build>/obj/tu_i.o -c <exact-source> -o <fresh-build>/obj/tu_i.o`. Each dependency file and object has a unique deterministic index-based name. `-MD` captures system headers actually used by that compilation; `-MMD` would omit them. Do not pass a single shared -MF to a multi-source g++ command: it would overwrite earlier translation units' dependency records. No separate preprocessing pass is needed for this candidate.

Link with the same g++ driver, the same language/numeric options, exactly those 26 objects in the original translation-unit order, then `-lm -o <fresh-build>/type_producer_binary_cpu`. Add only the observational linker trace option `-Wl,-t` and direct stdout/stderr into a fresh link log. The command manifest must show the complete per-command argv and its hash, the original argv and its hash, and the narrowly explained change from single driver invocation to per-TU compilation plus link. Future execution must bind this new manifest explicitly; the old CPU gate schema must not be treated as authorization for the new argv.

## Evidence and checks

Before a future build, rehash all accepted functional/local-closure inputs and the selected host-chain binaries, libraries, direct header candidates and package/environment identities. Relevant include/compiler/linker environment variables must match the declared execution environment. Bind actual resolved tool paths, not a shared version label inferred across packages.

After each successful compile, parse and preserve the actual -MD dependency file. Canonicalize the emitted paths with correct Make escaping/continuation handling; reject unsupported or ambiguous syntax rather than dropping dependencies. Bind the source and every emitted local/system header by path, bytes and SHA256, and bind the output object and exact compiler command/log. Confirm that the expected local include closure is represented; record conditional differences explicitly. De-duplicate file hashing across translation units while retaining each TU-to-header edge and the raw dependency files. Rehash the discovered dependency set and accepted inputs at the end of the build. Newly discovered system headers are actual post-compile observations; do not claim they were all presealed before the build or expand this work into an unbounded OS attestation.

After successful link, hash the final ELF and inspect its ELF interpreter and DT_NEEDED entries with the bound readelf tool. Preserve the linker trace and hash the actual opened objects, linker scripts, startup files, static archives and resolved shared objects that it identifies. Unknown or unresolvable trace records are explicit review items, not silently ignored. The current prospective host-chain list cannot substitute for final ELF inspection.

The future build gate may explicitly permit the already bound glibc loader's `--list <ELF>` operation, under the same declared clean runtime-library environment, to resolve DT_NEEDED without entering the DUT program. Record those resolved libraries and recurse through their ELF dependencies. Do not execute the binary as part of the build or silently use an unbound ldd wrapper. Actual runtime mappings, outputs and numerical behavior remain for the later CPU-run gate.

Seal all source/tool/dependency/object/ELF/log identities and pre/post checks in an actual build packet. A changed source, failed compiler/linker, missing depfile, incomplete header parser, unresolved library or guard trigger stops the stage and preserves the first failure. No automatic retry or changed flags follow. A successful compile is not CPU numerical acceptance.

## Release boundary

Source preparation and syntax/manifest inspection are allowed now. Starting the compiler, including -M/-E preprocessing, is held. Prepare exact future paths and a finite candidate guard command for review after actual fixture acceptance. The root controller assigns the unique heavy Laya slot. CPU 0–3, nice 19, idle I/O, 0.2-second owned-RSS sampling, MemAvailable strictly above 192 GiB and owned-process-only cleanup remain mandatory. R0 finite runtime has scheduling priority. This supplement changes no existing execution gate or frozen artifact.
