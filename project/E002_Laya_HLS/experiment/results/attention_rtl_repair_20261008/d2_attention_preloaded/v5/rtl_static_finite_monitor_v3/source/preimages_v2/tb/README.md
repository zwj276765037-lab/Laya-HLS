# Testbench source preparation

The owning monitor now records checked R-accept scalars. The control observes the tagged one-entry adapter at a settled negedge and checks its ordinal against the endpoint monitor. `source/design.md` is the frozen contract; `source/implementation_mapping.md` maps the implementation.

Only `base_h15_r63` is eligible for later separately released build/runtime commands. This source tree has not run a compiler, simulator, DUT, materializer or oracle. Copied v1 `generate_top.py`, `make_source_packet.py` and `materialize_cold_pages.py` are held historical helpers and are not future commands.
