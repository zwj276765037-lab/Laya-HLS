# Bounded runtime-initializer zero control

One isolated replay of the Vitis 2025.2 reflow `clang -cc1` used a copy of the
original bitcode with only the initializer of
`@_ZN12_GLOBAL__N_17runtimeE` changed to `zeroinitializer`. The compiler
entered `Generate HLS compatible IR` but exited with code 1 during that pass,
after reporting unsupported pointer selection in
`full_recycle_request(FullRuntime&)`. It did **not** complete HLSGen or write
`a.g.lto.bc`, so this is an incomplete causal control, not a successful
synthesis or a production repair.

## Input integrity and scope

The source bitcode SHA-256 is
`769090bda7f0f7a37cad27fe7506e98f878f6bd3ecbe5ed5ad12fcb3daf67a9e`;
the altered copied bitcode SHA-256 is
`f8aa019ed3ca540654048c578870a36d1404c1ef82f83497928b7783acd8ab6f`.
The altered hash was checked before launch; the source hash was independently
rechecked on disk after the replay. Disassembled text has 142,556
lines in each version; line 2638, the runtime global initializer, is the
only changed line. Re-disassembly of the altered bitcode differs from the
altered text only at line 1 (`ModuleID` path). Thus all function bodies,
types, other globals, and metadata remain textually unchanged. See
`transform_manifest.json`, `exact_initializer.diff`, `original.ll`,
`runtime_zero.ll`, and `runtime_zero_roundtrip.ll`. The original aggregate
contains nonzero scalar values, so the all-zero initializer changes runtime
semantics and cannot be used as a functional fix.

Only this copied reflow cc1 was run, with input, output, database, XML, and
diagnostics directed to `build/diagnosis-reflow-runtime-zero-20261007`.
`probe_plan.json` records the exact command and SHA-256. The log reader in
`run_zero_probe.py` was corrected to use an independent read-only file
descriptor and to scan remaining log data after natural cc1 exit; its syntax
check passed before launch.

## Front-end comparison

The replay regenerated all 15 `cmplx.3.000`–`014` files after launch.
For each stage, the top function `laya_typed_q8_forward` has the same direct
`instructions` and inclusive `total_instructions` as the original run:

| Stage | Direct, both runs | Inclusive, both runs |
| --- | ---: | ---: |
| 000 link | 23 | 2,590,344 |
| 001 unroll raw | 21 | 2,072,815 |
| 002 unroll simplified | 21 | 1,798,641 |
| 003 inline raw | 112 | 1,549,617 |
| 004 inline simplified | 99 | 1,302,671 |
| 005 array partition raw | 99 | 1,138,182 |
| 006 array partition simplified | 99 | 1,130,209 |
| 007 aggregate | 99 | 1,130,209 |
| 008 array reshape | 99 | 1,130,201 |
| 009 infer access pattern | 99 | 1,136,993 |
| 010 performance prep | 99 | 1,094,396 |
| 011 performance parallel | 99 | 1,079,924 |
| 012 performance array partition raw | 251 | 1,361,775 |
| 013 performance final | 251 | 1,078,825 |
| 014 simplify | 248 | 1,078,899 |

At every stage, the multiset of all function rows is also equal after
normalizing by function name, source location, direct/inclusive instructions,
basic blocks, memory accesses, def-use/control depth, loads, and stores.
Raw JSON bytes differ because function IDs and their numeric `calls` IDs are
ordered differently. `cmplx_comparison.json` gives all stage paths, row
counts, metrics, normalization fields, and regeneration checks.

## HLSGen behavior and memory

The actual HLSGen entry marker is `driver.log:993686` at 16:39:15.361 CST.
The first compiler error is `driver.log:994092`, followed by the source
locations `hls/common/laya_full_owner.cpp:129:9` and `:716:20`. No
`Made Modification` or `Freeing Pass` marker for HLSGen appears. The
diagnostic is `Pointer (phi) points to an unknown underlying object and
therefore cannot be synthesized`; the subsequent messages report unsupported
pointer selection and a select between `FullOwnerRecord*` and `i64`.

Disassembly of the actual vendor compiler in the diagnosis parent directory
shows `HLSBuilder::buildModule` calling `generateGlobals` at `0x23c0b1e`
before `generateFunctions` at `0x23c0b36`.
`HLSBuilder_generateFunctions.disassembly.txt` shows its call to
`FunctionBuilder::buildFunction`; `FunctionBuilder_visitSelectInst.disassembly.txt`
shows calls to the matching unsupported-select diagnostics and
`flushDiagAndExit`. This ordering places the observed error after the
global-generation call returned and during function conversion. It does not
establish that the original captured bit concatenation belonged to this
specific global.

At HLSGen entry, the altered clang RSS was 3,536,092 KiB; the original
debugger replay measured clang RSS 3,535,428 KiB at its HLSGen entry. During
the altered run's roughly three seconds in HLSGen, sampled clang RSS stayed
between 3,536,092 and 3,536,920 KiB. Its overall peak was 3,738,992 KiB
earlier in front-end analysis. The original debugger replay instead continued
through global-initializer rewriting and reached 8,682,868 KiB clang RSS
(8,851,968 KiB owned-tree RSS) before its 8 GiB guard stopped it. Those
different stopping points prevent a completed-pass memory comparison, but
the equal front-end metrics, nearly equal HLSGen entry RSS, and later-stage
error support the runtime initializer as a contributor to the original
global-rewrite hotspot. The original run never reached this pointer
diagnostic, so this replay cannot determine whether that error is latent in
the production input or caused by the altered initializer.

The altered replay sampled at 0.2-second intervals with an 8 GiB owned-tree
RSS ceiling, 192 GiB `MemAvailable` floor, and 15-minute maximum. `clang`
passed observed nice 19, CPU 0–3 affinity, and idle I/O checks. Minimum host
`MemAvailable` was 436,453,228 KiB. No guard threshold fired; the child
exited naturally after 202.6 seconds, and the compiler and runner PIDs were
gone. See `memory_timeline.csv`, `policy_checks.json`, `launch.json`, and
`probe_result.json`. No later scheduling, RTL generation, or production-source
change was performed.
