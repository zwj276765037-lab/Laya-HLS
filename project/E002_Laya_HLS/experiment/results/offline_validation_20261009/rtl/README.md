# RTL binding

This validation stage does not edit generated DUT RTL. Head15, Scorer, and Type use the frozen generated RTL/IP and bounded AXI endpoint identified in `../source/design.md` and each attempt's input manifest. Ws uses eight frozen functional DCP exports, with simulation-only top-module name isolation recorded by `../tb/ws/prepare_capacity_sim.py`.
