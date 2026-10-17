# D2 repeated clock-wait diagnostic v2 results

Source prepared for Astra scope-correction review. The v1 static build exited 1 at `VRFC 10-1319`: XSim rejected `$root.clock_wait_diag_top.clk` from the package. No runtime started. The v1 failure evidence remains at `../../runs/static_build_v1/failure_evidence.json`.

The v2 source moves the identical helper class and virtual-interface typedef into module scope and removes the package from the build. The v2 source packet binds the copies, exact diff, wait expressions and planned commands. No v2 static build, runtime or memory-mechanism result exists yet. The static build remains limited to 16 GiB owned RSS/300 s/4 CPUs; runtime remains gated, four fresh 20,000-clock modes at 4 GiB/30 s each.
