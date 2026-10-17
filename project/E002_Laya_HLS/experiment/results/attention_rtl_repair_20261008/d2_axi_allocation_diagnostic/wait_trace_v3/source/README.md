# AXI wait-trace diagnostic identity

This isolated source tree is derived directly from the frozen `v2` tree. Only `tb/axi_allocation_diag_top.sv` and `tb/phase_axi_monitor.sv` add bounded first-pair wait and edge-window observations. The build script selects snapshot `axi_wait_trace`; all VIP, memory, guard and DPI bytes are copied from v2. The current module design and results are the parent `source/design.md` and `source/results.md`, under their `wait_trace_v3` sections. The source packet records exact copy and diff identities.

Static build and runtime have not been released or run for this identity. The planned runtime is one fresh traffic invocation after a separate snapshot gate.
