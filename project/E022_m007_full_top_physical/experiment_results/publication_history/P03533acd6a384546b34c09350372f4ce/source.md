# E022 D38 source-identical full-top physical flow

91 production sources/ROM match D37 order and D36 fixed SHA; all11 parent generic values use [configurationv2](../experiment_results/runs/R001/input/physical_configuration_v2.json),including VERIFY0 and valid tested peer apertures/platform identity. No RTL/gold/shape/interface change. Target xcu55c-fsvh2892-2L-e,300MHz bare-kernel OOC; external IO delays/real platform uncertainty/shell remain unspecified.

After real full-top memory stops,the same RTL is now compiled along natural module boundaries,starting actual matrix_engine PROFILE0. Original dot_array/format,full ports and source defaults are preserved. Real DCPs must ultimately be inserted into the original parent,with zero blackboxes and all internal/cross-partition timing; no component summation is a full-top result. [Protocol](protocol.md),[future configurationv4](../experiment_results/runs/R001/input/bottom_up_configuration_v4.json). A010 owns all actual EDA; A014 only reviews.


---
Published: 2026-10-25T07:14:34.869039+00:00
Publication: P2e73918894144cd9bd10de393e1a0cfa
