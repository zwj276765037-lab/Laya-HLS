# R0 adapter status and resource boundary

2026-10-09, GPT-6 Astra / xhigh design. Status: isolated helper/probe/reference source draft prepared by GPT-6 Sol / max; no R0 execution or implementation acceptance.

The upstream actual-IP probe completed 119 cases with 33 R0 failures. This is evidence motivating the adapter, not adapter verification. The normal Scorer one-row pilot remains accepted only for its frozen normal data.

Target context is xcu55c-fsvh2892-2L-e and requested 150 MHz. Helpers add integer max/classification, tiny constant div/rem, leading-bit/exponent adjustments and aligned bypass selectors. Their LUT/FF/DSP use, combinational path, pipeline latency and sustainable II are unknown. In particular a 30-bit division by constant127 must not be called free or assigned an unmeasured latency. The product remedy adds no required general48-bit multiplier; small-product lanes are handled by a proved q=0 bypass.

No existing 32-lane C1 DSP/resource budget is silently increased. Before integration, quantify these helpers and their sharing/II and include bypass token/credit latency. Existing FP IP/resource coefficients stay provisional until same-source OOC. Independent source review and a finite CPU/RTL plan are the next gate. No synthesis, routed timing, shell, board or50ms result exists for this adapter.

The selected design explicitly replaces both current d_full float-zero controls (reciprocal at line 625 and rounded selection at line 641) with the same raw-bit zero predicate. Nonzero subnormal d must take the nonzero path at both sites. This is a source contract, not an implemented or tested repair.

Source mapping: `rtl/r0_fp_bits_pkg.sv` provides the synthesizable combinational helpers; `tb/original_r0_reference.py` is the independent R0 oracle; `tb/vector_manifest.json`/`tb/generate_vectors.py` are the finite vector source; `tb/r0_adapter_probe_top.sv` instantiates the actual seven wrappers. `tb/make_source_packet.py`/`tb/verify_source_binding.py` bind source, library and future compiled snapshot identities; `tb/verify_generated_vectors.py`/`tb/audit_raw.py` check table and raw coverage. `tb/run_vectors.sh`, `tb/build_static.sh`, and `tb/run_adapter.sh` are dormant entrypoints. The source packet and static-source check will identify exact hashes after this draft is complete.

Planned local runner caps are 120 s for finite vector materialization, 900 s per static tool process, 600 s for XSim, and a 500000-cycle probe watchdog. These are protective script bounds, not an execution release or aggregate guard budget. The exhaustive 0..0x03fe0000 amax and all-subnormal-d CPU sweeps remain separately unplanned and unrun. Source inspection and syntax checks do not establish reference correctness, seven-wrapper adapted-domain conformance, C1 throughput, resource use, routed timing or board behavior.
