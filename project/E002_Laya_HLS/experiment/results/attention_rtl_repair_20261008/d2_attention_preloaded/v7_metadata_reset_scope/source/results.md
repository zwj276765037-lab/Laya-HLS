# Attention V7 reset-pragma scope: status and evidence

The [V7 authority](../../../reviewer_attention_v7_metadata_reset_pragma_scope_source_preparation_release.json) allows source preparation only. The [source packet](source_packet.json), [literal diff](v6_to_v7_scope_only.diff), [preimage archive](../evidence/preimage_manifest.json), and [dormant execution plan](execution_plan.json) bind this variant. The full design and original specification references are in [design.md](design.md).

| Stage | V7 status | Evidence and limit |
| --- | --- | --- |
| Source and static scope checks | Prepared when packet passes | Exact single using-directive move, path-only config adaptation, copied TB/ABI, frozen input identities. No compiler invoked. |
| Strict CPU build and numerical test | Not run for V7 | [Accepted V6 actual strict CPU evidence](../../../reviewer_attention_v6_metadata_reset_actual_strict_cpu_acceptance.json): 3 legal, 17 negative, 3 warm scenarios; inheritance requires independent V7 diff review. |
| Native-libm CSim | Not run for V7 | [Accepted V6 actual CSim evidence](../../../reviewer_attention_v6_metadata_reset_actual_csim_acceptance.json); inheritance requires independent V7 diff review. |
| HLS synthesis | Not run for V7 | [V6 actual first syntax failure](../../v6_metadata_reset/runs/hls_synthesis_v1/actual_result_evidence.json): unqualified `metadata_initialized` at reset pragma line 448, 70.724 s, 1,293,380 KiB owned RSS, no guard trigger, no schedule or RTL. A future V7 single attempt is still held. |
| Generated RTL and runtime reset | Not run | No reset-cone, actual pin, CSR rebind, or numerical warm-reset evidence yet. |
| OOC, layout, timing, board | Not run | No V7 resource, Fmax or board result. |

The inherited V6 source plan uses `xcu55c-fsvh2892-2L-e` and requests 150 MHz (6.667 ns). This is a configuration target, not measured closure. No V7 resource, II, latency, throughput, memory bandwidth or power figures exist. The V6 finite metadata initialization source count, including 15,360 owner coverage words and 4,162 input mirror entries, is unchanged by the directive move; it is not a measured cycle count. No U55C board access is claimed or planned in this offline source stage.

Future HLS work, if separately released, is a single guarded attempt in fresh `runs/hls_synthesis_v1`, with 16 GiB owned RSS and 1,800 s wall limit, one Laya heavy tool globally, CPU 0–3, nice 19, idle I/O, 0.2 s guard sampling, and MemAvailable strictly above 192 GiB. Those values are authorization constraints for a future stage, not evidence of execution. The original V6 failed run and all accepted numerical variants remain frozen.
