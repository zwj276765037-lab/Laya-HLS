# Passive R-accept implementation mapping

The frozen design contract is `design.md` in this directory. Its source and first-failure references remain authoritative. This sibling copies the finite v1 testbench and leaves the original tree untouched.

| Contract item | Source mapping |
| --- | --- |
| Checked endpoint R handshake | `tb/att_axi_monitor.sv`, `ram_mon` instance in `tb/att_axi_port.sv`. The monitor records valid, the next `r_count` ordinal, effective 64-bit `first_byte`, pre-advance beat, ARLEN, ARSIZE, ARID, RID and RLAST only after its existing R checks. Reset assigns every scalar zero. |
| Tagged adapter association | `tb/att_finite_control.svh` selects fixed scalar references from qkv1 for head15, with the analogous qkv0 expression retained. At a settled negedge it requires `r_delay.full && r_delay.held_special`, known monitor fields, and equality of monitor ordinal, endpoint `ram_r_count`, and adapter `accepted_count`. It then records command-relative ordinal, beat, address and last once. |
| Original injection and acceptance | The existing `r_hold_reg` and `b_hold_reg` assignments, `att_static_axi_stall.sv`, `hold_failure_bits`, end-command hold rows, protocol and numerical checks remain intact. The monitor record drives no DUT or AXI signal. |
| Later build and runtime | `tb/build_static.sh`, `tb/run_mode.sh` and `tb/verify_binding.py` point at this sibling and restrict entry to base_h15_r63. The source packet proposes fresh build/runtime directories while reusing the already accepted v1 prepared pages by identity. No command in the source packet has been executed. |

The three copied v1 helper scripts `generate_top.py`, `make_source_packet.py` and `materialize_cold_pages.py` are held historical source only. They are not listed as future commands and must not generate or change pages for this repair.
