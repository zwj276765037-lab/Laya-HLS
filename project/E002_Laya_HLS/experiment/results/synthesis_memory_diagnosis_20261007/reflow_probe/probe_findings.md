# Bounded reflow probe findings

One copy of the original 2,077,332-byte `a.g.ld.5.gdce.bc` (SHA-256
`769090bda7f0f7a37cad27fe7506e98f878f6bd3ecbe5ed5ad12fcb3daf67a9e`)
was replayed on 2026-10-07 15:58–16:01 Asia/Shanghai. The cc1 optimization
options were unchanged; outputs and input were redirected to the diagnosis
directory and `-debug-pass=Executions` was added. GDB was the parent of this
one compiler. Both owned processes were measured at nice 19, CPU 0–3 affinity,
and idle I/O. They were stopped and cleared after the third stack. Peak owned
RSS was 4,214,204 KiB (4.019 GiB); minimum host `MemAvailable` was
444,523,688 KiB (423.9 GiB). The full-top synthesis was not restarted.

| CST time | Owned RSS | Active stage and sampled stack | Interpretation |
| --- | ---: | --- | --- |
| 15:59:19 | 2,859,588 KiB | `Auto automatic array partition analysis`; `AutoArrayPartitionAnalysis::initialize` → `PredicateAnalyzer::initialize` → CUDD initialization | Temporary peak; RSS later fell to about 0.5 GiB. |
| 16:01:01 | 3,523,252 KiB | `LoopFlattenCostModel::runOnModule`; interrupt happened while `-debug-pass` was writing output | Identifies the enclosing pass, not the allocator. |
| 16:01:31 | 4,214,204 KiB | `Generate HLS compatible IR` / `HLSGen::runOnModule` → `HLSBuilder::generateGlobals` → `rewriteGlobalVariableInitializer` → `HLSRewriter::mapBytes` → `HLSIRBuilder::GenerateBitConcat` → `ConstantInt::get` | RSS rose from about 3.6 to 4.0 GiB as the global initializer was rewritten. This is the strongest candidate for the continuing growth. |

The copied input IR contains `@_ZN12_GLOBAL__N_17runtimeE`, an explicit
`FullRuntime` aggregate initializer rather than a single `zeroinitializer`
(`input.ll:2638`). Its DWARF size is 69,761,920 bits = 8,720,240 bytes. The
embedded `FullCache` is 69,141,312 bits = 8,642,664 bytes, including 13
large arrays whose initializer members are individually `zeroinitializer`;
the largest is `weight_q[5,373,952]`. Small scalar fields in the same
aggregate initialize to nonzero values, including `i8 -1` and `i8 6`.
`hls/platform/full_kernel_wrapper.cpp:5` declares this static runtime.
The stack does not expose the global name or the `APInt` width being handled,
so attribution of the sampled rewrite to this exact symbol remains an
inference. No allocation scaling law or memory leak has yet been measured.

The stage ordering agrees with the original full-top run. In that run,
`cmplx.3.013.fe.performance-final.json` was written at 15:25:59 and
`cmplx.3.014.fe.simplify.json` at 15:26:03. Its clang RSS was about 3.37 GiB
at 15:25:57, 8.29 GiB at 15:26:18, and ultimately 360.629 GiB at the guard
stop around 15:32. The probe wrote the same two stage files at 16:01:17 and
16:01:21, then entered HLSGen at 16:01:27. The old stderr file's last
descriptor-partition remarks were emitted before these final stages; they do
not identify the later memory-consuming pass. The 4 GiB probe stopped before
the original 360 GiB regime, so HLSGen is a directly observed 4 GiB hotspot
and a leading explanation for the late growth, not yet a proven cause of the
entire 360 GiB peak.

Raw evidence: `replay_command.json`, `cc1_argv.json`, `gdb_mi.log`,
`memory_timeline.csv`, `stack_captures.json`, `policy_checks.json`,
`guard_trigger.json`, `probe_result.json`, and the read-only `input.ll`
disassembly in this directory. The original comparison is
`results/engineering_p2/csynth_expanded_memory_20261007T072000Z/`
and its build's `.autopilot/db`.
