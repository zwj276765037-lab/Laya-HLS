# Head15 monitor-v3 source mapping

The accepted [design](design.md) defines the field map and the cold finite acceptance contract. The exact v2 preimages are in `preimages_v2/`, indexed by `v2_preimage_archive.json`. The accepted generated DUT, endpoint, prepared pages and numerical gold remain external and frozen.

| Contract | Active source mapping |
| --- | --- |
| Single checked record owner | `tb/att_axi_monitor.sv` assigns the whole 119-bit `accepted_r_record` only in its reset branch and after a checked R handshake, before `r_count` and AR queue advance. Its first RAM R line checks the new ordinal against the updated count. |
| Explicit port path | `tb/att_axi_port.sv` names both monitor outputs and forwards the RAM record through one `ram_accepted_r_record` output. Settled-negedge reset and first-R witnesses compare the monitor and forwarded values. |
| Seven top connections | `tb/generate_top.py` generated both literal top variants. Their seven port instances bind the forwarded record to `ram_accepted_r_record[0:6]`. The instances are inline in the inherited top layout; there is no `att_finite_ports.svh` in v2. |
| Selected association | `tb/att_finite_control.svh` extracts fields from the connected array with explicit bit constants. Its original selected full+held-special predicate, endpoint/adapter count equality, command-relative ordinal, address, last-beat/ID checks and hold/numerical paths remain. The top emits bounded reset and first-R witnesses at settled negedges. |
| Future entry | `tb/build_static.sh`, `tb/run_mode.sh` and `tb/verify_binding.py` point to this fresh sibling. No build or runtime command is released by this source packet. |

Only `base_h15_r63` is a future gated execution candidate. `changed_h0_r0` remains a maintained source variant and is not an execution selection.
