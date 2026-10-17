# Bounded reflow bit-concatenation measurement

One replay of the copied original reflow input ended at its 8 GiB owned-tree
RSS guard on 2026-10-07 16:27:22 Asia/Shanghai. The copied input retained
SHA-256 `769090bda7f0f7a37cad27fe7506e98f878f6bd3ecbe5ed5ad12fcb3daf67a9e`.
The original cc1 options were retained with paths redirected to this isolated
DB and the diagnostic `-debug-pass=Executions` option. GDB and clang both
passed measured nice 19, CPU 0–3, and idle I/O checks. Their PIDs 2157261
and 2157273 no longer existed after the guard stopped them. No complete RTL
or synthesis resource report was sought.

At 16:27:12, GDB hit the actual `HLSGen::runOnModule` entry at an owned RSS
of 3,702,384 KiB (clang 3,535,428 KiB). At 16:27:15, the first qualifying
`HLSIRBuilder::GenerateBitConcat` entry had these live values:

| Value | Measured result |
| --- | ---: |
| Target `IntegerType` width | 2,653,009 bits |
| `ArrayRef<Value*>` element count | 6,480,158 |
| `ArrayRef` begin address | `0x5112f640` |
| Builder `this` | `0x7fffb6d7f688` |

The SysV calling registers at function entry were read directly. The saved
disassembly shows `rsi` as the `ArrayRef` begin, `rdx` as its element count
(`lea (r14,rbx,8)` computes the end), and `rcx` as the target integer type.
The width is `(*(uint32_t*)(rcx+8) >> 8)`, matching the target type access in
`ConstantInt::get`. A temporary breakpoint at `0x14b0edc`, immediately before
the `ConstantInt::get` call, recorded the same width, bit offset `r12=0`,
and the raw 16 type bytes
`10ecb83e000000000b517b2800000000`. Its backtrace was
`GenerateBitConcat` → `rewriteConstant` → `twoStepsBitCast` →
`HLSRewriter::mapBytes` → `HLSBuilder::rewriteGlobalVariableInitializer`
→ `generateGlobals` → `HLSGen::runOnModule`.

The debugger then continued in the same HLSGen pass. No new large-concat
entry was captured before memory increased quickly: owned RSS rose from
3,706,344 KiB at the call breakpoint (16:27:16) to 4,748,116 KiB at
16:27:18, 6,081,952 KiB at 16:27:19, and 8,745,804 KiB at 16:27:21.
The final stopped sample recorded owned RSS 8,851,968 KiB and clang RSS
8,682,868 KiB. The one-second guard interval allowed an approximately
0.44 GiB overshoot of the 8 GiB threshold; minimum host `MemAvailable`
remained 430,769,500 KiB (410.8 GiB). The subsequent growth while still
inside HLSGen strongly localizes the original sustained memory problem to
global-initializer conversion/bit concatenation. It does not identify the
specific global variable or establish how much memory each element allocates.
The first width, 2,653,009 bits, is smaller than the pre-reflow FullRuntime
type width of 69,761,920 bits; no equality to that symbol is claimed.

The raw `width_captures.json`, `gdb_mi.log`, `hlsgen_entry.json`,
`memory_timeline.csv`, `policy_checks.json`, `guard_trigger.json`,
`probe_result.json`, `cc1_argv.json`, and the two saved disassembly excerpts
provide the underlying evidence. `compiler_manifest.json` records the exact
vendor clang binary SHA-256 and fixed-address ELF type.
