# Head15 monitor v4 testbench source

The v3 run stopped at its first top record reset predicate before any command. This fresh v4 source prints every owner, wrapper and top record/count boundary on all seven ports before the wrapper and top reset predicates can terminate the settled negative-edge check. The original 119-bit record owner, named top wiring, first-R checks, hold/debt/association path and numerical control remain. `att_r_boundary_diagnostic.svh` contains only bounded diagnostic reads and prints.

The two literal tops were regenerated from `generate_top.py` and match the v3 tops byte for byte. `build_static.sh` and `run_mode.sh` point at this v4 root but are **dormant**. No compiler, elaborator, simulator, DUT, materializer, or numerical oracle has run for v4. A separate small no-DUT probe and its dormant commands are in `diagnostic/README.md`.
