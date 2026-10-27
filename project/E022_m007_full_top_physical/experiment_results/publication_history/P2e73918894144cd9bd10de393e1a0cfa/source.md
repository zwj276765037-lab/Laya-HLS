# E022 D38 complete production top physical validation

Full91-source/EXP ROM byte closure follows D37 successful source order and D36 fixed parent manifest; no production RTL/TB/gold/shape change. Actual platform generic binding is [configuration v2](../experiment_results/runs/R001/input/physical_configuration_v2.json): all11 parent parameters match the D37 instance,including VERIFY0,profile1,base0,each4GiB aperture and nonzero platform identity. These are the tested peer layout parameters, not a real HBM shell. Original source-manifest identity is preserved separately.

Vivado2025.2,xcu55c-fsvh2892-2L-e,OOC bare kernel,core3.333333333ns. No invented IO delay/uncertainty/reset exceptions; internal setup/hold and unclocked endpoints will be reported separately from external boundary gaps. Physical scripts live only in E002/experiment/.../forward_controller/physical_d38. [Protocol](protocol.md) gives independent budgets,CPU/log/checkpoint300s stall guard and source-bound staged checkpoints.


---
Published: 2026-10-25T06:46:09.571422+00:00
Publication: P69123906bb1a4193ac318ed2b0d7c8e5
