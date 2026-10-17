# Distinct valid Scorer rows3: strict CPU build dependency capture

2026-10-09. GPT-6 Astra / xhigh. Source preparation only; no compiler, preprocessor, DUT runtime or EDA invocation is released here. Preserve the existing variant/source packet and every frozen file. The implementation belongs in this separate supplement and a fresh run tree.

## Fixed identity and behavior

The actual distinct rows3 fixture is accepted by `reviewer_q8_scorer_distinct_valid_rows3_actual_fixture_independent_check.json`, SHA256 `5a4f874bea6a593e6b014f456a48c3d965114d3c995a03a623afd2ecca59823a`, under the project results directory. Its actual packet is `runs/fixture_v1_control/fixture_execution_packet.json`, SHA256 `f6379df78387f2805572da6b6cdaeddb4314ff4ff96a4bc3eff418bdd51b2699`. Bind both and the unchanged source packet `25d6a9940474c1f309343a2814148b81dc6732538229e6781c4c8be320b1c91d`.

The frozen CPU testbench `tb/test_q8_scorer_distinct_rows3.cpp` uses the real `metadata_reset_v3/source/q8_joint_tm4tn8.cpp`, LOAD followed by trace-on/off RUNs, one retained W state, B2/S128/batch1/rows0–2, K=N1024, one TM4 tile with three active lanes and one tail. Preserve numerical implementation, constants, descriptors, pages, gold, output comparison and PASS/FAIL behavior. The fixture provenance is the historical 4f12 checkpoint; current descriptors and BOs remain fe067. Do not change or re-materialize the fixture.

The existing `tb/build_cpu_leaf.sh` already uses strict `-std=c++17 -O2 -ffp-contract=off -fno-fast-math`, but its `-MMD` excludes system headers and its final `ldd` is not the required direct observation record. Do not edit that frozen script. Prepare a separate driver with the same two-TU compilation and object link order; only the observational closure collection changes.

## Source and installed host closure

Read and bind the exact two C++ TUs, quoted local headers and ordered include directories. Preserve include order: installed Vitis/include, project/include, current model build directory, metadata_reset_v3/source. Bind generated layout and numerical ABI headers actually referenced by these TUs. Provide a recursive local include inventory with unresolved/macro/conditional cases explicit; do not pretend a lexical inventory is the actual preprocessor result.

Read-only reuse of the D2 host-chain supplement is allowed for the same installed toolchain: `results/attention_rtl_repair_20261008/d2_type_producer_binary_v1/source/supplements/cpu_host_chain_v1/host_chain_manifest.json`, SHA256 `ef749b097ec51424c717ec9f1cd7408aee233ab97d02a99fd2740f6326b69bf8`. Verify applicability and exact canonical paths/symlinks. Bind GCC driver, cc1plus, assembler, linker, collect2, readelf, libc loader, compiler specs/metadata and relevant startup/runtime libraries. The installed Vitis ap_int header closure must be included in this source inventory or explicitly discovered in actual depfiles. No compiler/preprocessor probe may run at this preparation stage.

## Future exact build sequence

Prepare a named fresh control root and fresh build-output root. The candidate exact driver records argv, CWD and inherited environment policy and exits at first error. Use only the two source files; compile sequentially with `/usr/bin/g++` and the unchanged strict flags and include order. For each TU add `-MD -MF <unique-tu>.d -MT <unique-tu>.o -c <source> -o <unique-tu>.o`. Do not use `-MMD`, a shared multi-TU depfile, or a separate additional compiler/preprocessor pass. Link once in original order `q8_joint_tm4tn8.o`, `test_q8_scorer_distinct_rows3.o`, then `-lm`, retaining the numerical flags and adding only observational `-Wl,-t`. Preserve both raw stdout/stderr and exact exit codes, without buffering unlimited output.

Keep a controlled environment: unset PYTHONHOME/PYTHONPATH, CPATH/CPLUS_INCLUDE_PATH/C_INCLUDE_PATH/OBJC_INCLUDE_PATH, GCC_EXEC_PREFIX/COMPILER_PATH/LIBRARY_PATH and LD_PRELOAD/LD_LIBRARY_PATH; set a documented `/usr/bin:/bin` PATH and LC_ALL=C. No global environment or installed-tool edit is authorized.

After successful compilation, parse both actual GCC make depfiles including continuations and escaped spaces; resolve against actual CWD, hash every dependency and report source/local/vendor/system classification without dropping system entries. Bind both depfile bytes and object bytes. Inspect the final ELF using the bound readelf for ELF identity, interpreter and NEEDED entries; collect the linker trace paths and exact resolved startup/static/shared input identities. A later execution gate may explicitly allow the bound glibc loader with `--list <final-ELF>` to record dynamic resolution without entering the DUT. Do not run `ldd`, the DUT binary, or the CPU runtime script in the build stage. Actual runtime maps and numerical acceptance belong to the separate runtime gate.

Source presealed records and newly observed transitive system headers have distinct status. Actual depfiles and linker records establish the observed invocation closure, not an exhaustive prior OS attestation. Hash original source before and after. The build may produce only fresh control/output artifacts.

## Gate, policy and limits

Prepare source/results status, driver, dependency/ELF auditor, exact candidate argv, fresh paths, explicit compiler/link stages and a sealed source packet. Read-only hash, AST and shell-syntax checks are allowed. The independent reviewer must inspect actual source before one finite build gate; root assigns the single heavy Laya slot. Proposed ceilings are up to 8 GiB owned RSS and 600 seconds aggregate for two compiles, one link and closure observations, to be finalized in that gate. CPU0–3, nice19, idle I/O, owned process RSS sampled every0.2s and MemAvailable strictly above192GiB remain required. Any failure stops and preserves all outputs; no retries or quota reset.

A successful build establishes only this executable identity and its observed compilation/link closure. It does not accept CPU numerical output, RTL, HLS, C1 integration, full-model hardware,150MHz,50ms or board behavior. Runtime remains held until actual build/snapshot evidence is independently reviewed.
