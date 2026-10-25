# E018 R001 CONTROL-ARENA-16 protocol

Authority: M007 / SM012 D-M007-SM012-CONTROL-ARENA-16, 2026-10-22. A007 owns the layer coverage extraction, G math/engine optional q/next extraction, workspace component and affected verification. Other owners and numeric leaves are read-only. Baseline source identities and original files are in input_identity.json and input_baseline/.

One physical packed FF workspace has 12288 bits. Layer uses all bits; G uses low11343 bits in AT133 census entry order, with explicitly versioned per-field layout. Local and external modes share one next-state algorithm. Numeric payload25600B, numeric alignment736B, pre_credit, pairs/pool and engine private state stay independent. Preserve old RHS values and last-assignment priority.

Initial owner A. Different-target handshake requires actual current retirement and target private idle. Same-owner handshake holds state. Handoff disables both for exactly one REARM cycle and clears the workspace. Actual integrated consumer state drives safety. No request identity copy, gated clocks or scratch borrowing.

Verification order: layout/component holds/concurrent updates/early rejection/rearm; actual layer PREP QKV duplicate/boundary writes and held cancel then A to G; actual G short/held/full-ring/bad returns, same-build medium pilot and original335872 full normal outputs/cycle contract if cost allows; actual G done retirement then G to A new prepare/reload. No Attention arithmetic is launched by the local layer tests. PREP/cancel is not full16head normal handoff. Original frozen fixture only; no gold generation.

Independent caps seconds: reference0, static600, RTL1800, OOC0. Each unknown pilot <=120s; static <=120s; RTL <=600s only after actual same-build/fixture pilot. Keep120s RTL reserve. All heavy descendants hold .research-agent/m007_heavy.lock, CPUs0-3/nice19/idle I/O, MemAvailable>192GiB, static24GiB/RTL8GiB, <=40Mcycles and <=120s true checked semantic stall. No parent long chain, OOC/P&R/board/GPU. Failed attempts retain source archive/log/receipt and count against caps.

Execution records include actual source, selected inputs, tools, command, host/UTC, exit status, sampled process policy/RSS and descendant cleanup. Infrastructure failure is not a method failure. Source census is not physical fit/timing.
