# Head15 monitor-v3 testbench source preparation

The owning monitor drives one packed 119-bit accepted-R output after its checked RAM-side handshake. Each port forwards that output, and both top variants connect all seven ports to the same-index record array. Bounded reset and first-R lines identify the first boundary that disagrees. The selected held-R check retains the original adapter, count, address, last-beat and ID requirements. `source/design.md` is the frozen contract; `source/implementation_mapping.md` maps the implementation.

Only `base_h15_r63` is eligible for later separately released build/runtime commands. This source tree has not run a compiler, simulator, DUT, materializer or oracle. `generate_top.py` was used only to regenerate the two literal top source files. The inherited `make_source_packet.py` and `materialize_cold_pages.py` remain historical helpers and are not future commands.
