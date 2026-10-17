# AXI queue-existence diagnostic identity

This isolated source tree is derived directly from the frozen `v2` tree. Its only simulator-behavior edit is the four nested associative-array `exists(i)` guards in `rtl/axivip/axi_slave_seq_lib.sv`. The build script selects snapshot `axi_queue_exists`; all other RTL, testbench, guard and DPI bytes are copied from v2. The current module design and results are the parent `source/design.md` and `source/results.md`, under their `queue_exists_v1` sections. The source packet records exact copy and diff identities.

Static build and runtime have not been released or run for this identity. The first planned runtime is idle only.
