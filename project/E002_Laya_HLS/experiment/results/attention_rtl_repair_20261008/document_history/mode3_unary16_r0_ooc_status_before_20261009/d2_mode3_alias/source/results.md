# D2-I Mode3 alias overlay: execution record

The [bounded static release](../../../reviewer_d2_i_mode3_alias_compatibility_bounded_frontend_release.json) binds the prior CPU 16-F32 gold, 14-page preparation and 57,344-byte independent check; those passed in V1 and are **not rerun** here. The first V1 static attempt passed xvhdl/two xvlog stages and failed xelab `XSIM 43-4412`; [original evidence](../../rtl_static_mode3_v1/runs/mode3_ordered_attempt_evidence_v1.json) remains unchanged.

| Stage | Overlay status |
| --- | --- |
| Exact 19-alias source overlay and source packet | Prepared; preflight pending |
| Static attempt 1 (16 GiB / 300 s) | Not run |
| Static attempts 2–3 | Conditional on separately diagnosed mechanical frontend failures, unused |
| XSim runtime and numerical check | Held pending independent static acceptance |
| HLS/OOC/physical timing/board | Not authorized by this gate |

Guard policy: one Laya heavy tool, CPU 0–3, nice 19, idle I/O, owned RSS sampled every 0.2 s, MemAvailable strictly above 201,326,592 KiB. The complete source and partial/final snapshot are sealed after every attempt, including failure. No unchanged retry. The source design keeps original first-done debt, terminal hold and numeric criteria.
