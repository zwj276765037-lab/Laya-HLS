# Minimal initializer contrast

Four serial Vitis 2025.2 HLS runs used one new source file, `init_probe.cpp`
(SHA-256 `9248a65b42f4fc8ebf9e6bd1600a65327879b1fb974c552a406ee8899ed415cb`).
The only source-level variables were `N` and `INITIAL_FLAG`: `N` was 4,096
or 16,384 and the flag was zero or one. The top read and wrote `state.data`
at a dynamic masked index, updated `state.flag`, and returned both prior
values. All runs used U55C, 150 MHz, the same three low-automation settings,
nice 19, CPUs 0–3, idle I/O, an 8 GiB owned-tree RSS guard, and a 192 GiB
`MemAvailable` floor. Policy checks passed for every observed child. No guard
triggered, and all four runs exited zero with synthesis reports and RTL.

| N | Initial flag | Elapsed | Peak owned tree RSS | Sampled peak of any clang | URAM in HLS report |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 4,096 | 0 | 29.79 s | 2,336,568 KiB | 103,452 KiB | 1 |
| 4,096 | 1 | 27.77 s | 2,330,452 KiB | 86,672 KiB | 1 |
| 16,384 | 0 | 28.52 s | 2,344,004 KiB | 83,296 KiB | 4 |
| 16,384 | 1 | 29.15 s | 2,343,776 KiB | 132,100 KiB | 4 |

The tree peaks occur during subsequent Vitis/Vivado packaging, not during
the short reflow. The reflow compiler's own time report gives about 0.109 s
for each case. Process sampling actually occurred about every 0.18–0.20 s
because gathering the process table took time. Thus the sampled clang peaks
above can miss the entire reflow invocation or its true RSS peak. They cannot
be used as a precise scaling comparison or as evidence that flag initialization
has no memory effect.

The real pre-reflow input `a.g.ld.5.gdce.bc` retained the aggregate in all
four cases: `@_ZL5state = internal global %struct.State`, with the type
`{ i8, [N x i8] }`. At flag zero its initializer was a single
`zeroinitializer`; at flag one it was `{ i8 1, [N x i8] zeroinitializer }`.
The reflow output `a.g.lto.bc` split both into `@state.flag` and
`@state.data`. The latter remained `[N x i8] zeroinitializer` with a
dynamic `getelementptr`, load, and store. HLS reports show that the pragma
was accepted and that the actual array mapped to URAM (1 or 4 blocks).
The toy therefore preserved real memory use but did not preserve the
production runtime's large combined aggregate through the output. This
limited experiment did not reproduce the full-top memory growth; it does
not disprove the candidate large-aggregate initializer rewrite mechanism.

Each case directory contains `plan.json`, `result.json`,
`memory_timeline.csv`, `policy_checks.json`, the build, original bitcode,
`source_ir.ll`, `reflow_input.ll`, `reflow_output.ll`, `ir_manifest.json`,
and the HLS report. `a_g_0.ll` is retained under its actual checkpoint name;
it is bit-for-bit identical to `a.g.lto.bc` in these runs and should not be
treated as an independent frontend checkpoint. No production source or model
was changed.
