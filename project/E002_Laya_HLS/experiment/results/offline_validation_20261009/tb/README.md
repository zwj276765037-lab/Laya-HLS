# Offline validation testbenches

This mutable workspace contains the Head15/query63 four-command testbench and record-boundary probe. The accepted-R monitor record is sampled passively 1 ps after the rising edge. The independent literal probe checks reset, known records, and injected X before the full Head15 numeric run.

`ws/` reads the frozen eight-bank funcsim exports and parent DCP graph. Its structural/parameter join preserves original DCP `MISSING` values and binds only the exact Vivado 2025.2 RAMB36E2 inversion defaults authorized in the phase contract. The capacity testbench is a separate exhaustive-address simulation; its result is recorded independently from the join.

Scorer's distinct-row and Type's cold RTL testbenches live at their linked source locations in `../source/design.md`. Actual results, original failures, resource limits, and remaining gaps are in `../stage_results.md`.
