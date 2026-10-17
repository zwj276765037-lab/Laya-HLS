# Results: type producer to binary ADD_TYPE

The signed [source-only design](design.md) remains unchanged. The isolated [top](type_producer_binary_slice.cpp), [test source](../tb/test_type_producer_binary_slice.cpp), [future qtype1 oracle source](../tb/materialize_qtype1.py), [static address plan](../tb/static_mapping.json), [finite runner proposal](../tb/runner_proposal.md), [implementation mapping](implementation_notes.md), [Encoder layer-0 read-only appendix](encoder_layer0_binding_appendix.md), and candidate [HLS config](config_type_producer_binary.cfg) are prepared. The [source packet](source_packet.json) records static hashes and checks. No generated qtype1 fixture, CPU compile/run, CSim, HLS, RTL, OOC, placement/routing, timing or board test has been executed under this gate.

| Item | Status and evidence |
| --- | --- |
| Target platform | Candidate config inherits xcu55c-fsvh2892-2L-e and 150 MHz target from the existing vector slice; no board or platform execution is authorized or measured. |
| Scope | B1/S64, F32 width1024, qtype2 first: one original EMB_TYPE task and four original 16-row ADD_TYPE tasks. Cold qtype1 is source-prepared only. |
| Model/input identity | Signed release binds fe067 package, full 54,803,648-byte EMBEDDING BO, original Q8 `type_emb.weight` SHA-256 `807c9f71…`, 262,144-byte native HIDDEN ingress, valid 832-byte request and independent qtype2 gold. The qtype1 source binds original GGUF bytes and uses `tests/full_reference.py`; it has not generated output. |
| Logical payload budget | External ingress reads and writes 262,144 B; EMB_TYPE reads 1,088 Q8 B and writes 4,096 F32 B; four ADD_TYPE tasks logically read 262,144 B HIDDEN plus 262,144 B of repeated selected type-row values and write 262,144 B output. These are source-level payload counts, **not** measured AXI traffic, cycles or bandwidth. Request/model-header reads and bus granularity add traffic. |
| Sparse physical plan | Seven disjoint nonzero 64-bit port bases, 206 mapped 4 KiB pages, all three TYPE_ROWS pages visible for selected-row and unused-row sentinels. No page image has been materialized. |
| Resources and timing | LUT/FF/DSP/BRAM/URAM, Fmax, WNS/TNS, II, HLS schedule, memory transaction counts and accepted-to-done latency: **not measured**. A finite RTL ceiling cannot reuse unary Mode3's number and requires the new actual schedule plus ingress/producer/binary work. |
| Functional validation | Static source/hash/address checks only. CPU/CSim/RTL numerical results: **not run**. Existing [accepted unary Mode3](../../reviewer_d2_i_mode3_unary16_final_functional_acceptance.json) remains a separate 16-candidate window. |
| Encoder | Read-only architecture/data-binding appendix prepared; no Encoder producer connection, integrated source, simulation or timing result. |

The static source packet does not authorize execution. A later Astra xhigh review must check the actual path, oracle independence, report assertions, and a new finite memory/time budget before CPU or EDA runs.
