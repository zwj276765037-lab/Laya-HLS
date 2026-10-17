# Offline validation results

Target and actual host: local offline Vivado/XSim 2025.2; no U55C or XRT. The execution guard uses CPUs 0–3, nice 19, idle I/O, 0.2 s aggregate owned-RSS samples and MemAvailable strictly above 192 GiB. Resource budgets and acceptance criteria follow the linked phase contract in `design.md`.

Functional results and evidence are tracked in `../stage_results.md` and `../stage_results.json`. Synthesis, place-and-route, timing closure, and board validation are NOT_RUN in this offline stage.
