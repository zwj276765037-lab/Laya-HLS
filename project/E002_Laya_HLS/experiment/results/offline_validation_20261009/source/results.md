# Offline validation results

Target and actual host: local offline Vivado/XSim 2025.2; no U55C or XRT. The execution guard uses CPUs 0–3, nice 19, idle I/O, 0.2 s aggregate owned-RSS samples and MemAvailable strictly above 192 GiB. Resource budgets and acceptance criteria follow the linked phase contract in [design.md](design.md).

Functional results and evidence are tracked in [stage_results.md](../stage_results.md) and [stage_results.json](../stage_results.json). The [Type resumption final acceptance](../type_resumption_final_acceptance.md) accepts both complete cold requests and completes this stage's fixed functional scope. The other three passes reuse the [prior acceptance](../final_acceptance.md), preserved with its historical Type cost block. The entire offline project remains incomplete. Synthesis, place-and-route, timing closure, and board validation are NOT_RUN in this offline stage.
