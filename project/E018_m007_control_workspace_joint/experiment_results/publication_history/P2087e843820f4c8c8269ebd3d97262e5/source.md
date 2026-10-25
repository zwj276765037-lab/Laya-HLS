# E018 CONTROL-ARENA-16 source

M007/SM012 fixed one12288-bit FF workspace; layer uses all bits, G math uses low11343 bits. Version1 layout follows AT133 census order across41 fields. Default/local and external modes share one next algorithm; original old-q RHS and last-write priority are preserved. Numeric payload/alignment, pre_credit, pairs/pool and engine private state remain separate. Owner/rearm adds2 FF; no request identity is copied.

Production composition wires safety to actual consumer retirement and target private-idle. Same-owner requests hold state; different-owner handshakes clear and disable both for one REARM cycle. Incoming prepare/cmd excludes current retirement to prevent a simultaneous admission/switch. Inputs and baseline SHAs: [protocol](protocol.md), [input identities](input_identity.json), [layout](g_control_layout_v1.json).

Vivado2025.2 functional RTL only; CPU0-3/nice19/idle I/O, project heavy lock, MemAvailable>192GiB, static24GiB/RTL8GiB. Independent caps0/600/1800/0 seconds, no transfer. No new gold; original AT058 fixture is reused.


---
Published: 2026-10-22T15:38:08.111713+00:00
Publication: P09e24f7733774a42ac86218682cd62af


---
Published: 2026-10-22T15:57:41.195995+00:00
Publication: Pde82246891ff46eca79cefd8ff970f99
