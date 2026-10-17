# R0 finite-domain numerical adapter design

Designer/reviewer: GPT-6 Astra / xhigh, 2026-10-09. Status: mathematical design and isolated source preparation; no adapter implementation, CPU, RTL or synthesis acceptance. Existing metadata_reset_v3, its accepted Scorer results, the failed 119-case raw FP probe, and all frozen gold stay unchanged. This design changes no R0 tolerance or public numerical rule.

## Authoritative inputs and exact scope

- [Current Q8 source](../../source/q8_joint_tm4tn8.cpp), quantization lines 603–661: finite input scan, amax, d_full=F32(amax/127), reciprocal, half RNE, group numerical rejection, F32 product then roundf ties away from zero, range rejection, and only then group commit. Checked current SHA cad329dbb9a57e49ec8fb3b99ef53f41b6662538dac0df3090b4677260b2e17d.
- [Original Q8 design source](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md), §2 “从dot到最终输出经过什么” and §4 “与量化、RoPE和GELU共同核算” (checked 2026-10-09). It supplies the broader module context; the explicit current R0 source and reviewed C1 contract determine exact operation/order.
- [C1 detailed design review](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_q8_c1_detailed_arithmetic_pipeline_design_review.json): 32 restore channels, exact group order, first error rank and credit/retirement obligations. This adapter does not redesign these.
- [Actual seven-wrapper review](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_q8_actual_fp_boundary_119_characterization_acceptance.json): 119 complete cases, 33 R0 mismatches; general primitive conformance failed.
- [Restore reachable-domain proof](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_q8_restore_reachable_f32_domain_precision_analysis.json), claims 1–6: normal-or-zero scale product/term/PS; zero PS is +0; a nonzero final cancellation is at least 2^-72.

The selected remedy is a small bit-domain adapter around the same actual FP operations. Normal operations still require their original RNE behavior and are tested using the unchanged wrappers. The proof below is algorithmic; it does not claim that a few normal probes exhaustively verify the vendor IP.

## 1. Input classification and maximum

Classify exponent==255 by raw bits before any max operation. Retain the original first nonfinite input position and ordering. For each finite x, magnitude bits are x_bits & 0x7fffffff. Unsigned integer maximum on these nonnegative finite encodings gives exactly max(abs(x)), including subnormals; both signed zeros map to +0. No floating comparator is used for this maximum. This is consistent with the C1 integer max design and repairs the observed subnormal-versus-zero comparator failure.

## 2. Exact tiny division by 127, with one RNE rounding

Let a be the nonnegative finite amax encoding. For a <= 0x03fe0000, form an unsigned integer U measuring amax in units of 2^-149:

- exponent field e=0: U=fraction.
- 1<=e<=7: U=(0x800000 | fraction) << (e-1).

The maximum U in this branch is 127*2^23=1,065,353,216, strictly below 2^30. Compute exact integer q=floor(U/127), r=U-127*q, then n=q+(r>=64). Because 127 is odd, an exact half-integer tie is impossible. The raw positive binary32 d_full bits are n, including n=0 or n=0x00800000 at the upper boundary. This is direct RNE on the subnormal grid; it does not first round a normal quotient and then round it again on rescaling.

For a>0x03fe0000, retain the original FP divide by literal 127.0f. Both input and rounded result are normal: at the boundary amax=127*2^-126, d=minnormal; the next input is larger. Division by 127 cannot overflow finite amax. This branch never asks the IP to handle a subnormal operand/result.

The source implementation may use synthesizable unsigned 30-bit constant division/remainder for the tiny branch. Its eventual pipeline/area is unmeasured and must be assessed before C1 integration. Do not substitute approximate reciprocal multiplication or reassociated division.

## 3. Reciprocal using exact exponent scaling

Both original zero-control sites must use raw-bit zero classification: current Q8 line 625 selects reciprocal, and line 641 selects rounded quantization. Define `d_is_zero = ((d_bits & 0x7fffffff) == 0)` and carry this same predicate to both decisions. All nonzero subnormal encodings must select the nonzero path at both sites. Do not retain either `d_full == 0.0f` floating comparison: the actual comparator characterization includes subnormal-versus-zero mismatches. The successful d domain is nonnegative and produces +0, so `d_bits == 0` is equivalent there; assert this domain explicitly in the isolated checker. Apply the same raw-bit zero classification to x and any helper route control.

If d_is_zero, return reciprocal +0 exactly as R0. If d is normal, use the original 1.0f/d operation: over all finite amax, the smallest such reciprocal is still normal, and minnormal d has reciprocal 2^126, finite.

For a nonzero subnormal d=M*2^-149, construct D=d*2^24 by integer bit encoding. If k=floor(log2 M), encode exponent k+2 and fraction (M<<(23-k)) & 0x7fffff. D is normal, ranging from 2^-125 to less than 2^-102. Compute R=F32(1.0f/D) with the actual unchanged divider; R is normal and finite. Recover reciprocal by adding 24 to its exponent using a wide integer sum; retain its fraction. An exponent sum >=255 produces positive infinity, with no integer wrap.

This recovery is exact RNE: the real reciprocal and normalized reciprocal differ by an exact power of two, with identical 24-bit precision; the normalized operation remains in the normal range. Scaling an already rounded normal result upward preserves significand rounding, including the same overflow rounding threshold. No underflow or second significand rounding occurs on recovery.

A useful derived boundary is M<=0x00200000 -> reciprocal infinity, M>=0x00200001 -> finite reciprocal. The overflow midpoint is 2^128-2^103; 2^149/M below that requires M>2^21/(1-2^-25), so the first integer M is 2^21+1. This boundary is a diagnostic/proof, not permission to bypass the original group error handling.

Apply the original d/reciprocal finite tests and original f32-to-half RNE conversion. A half infinity/NaN encoding rejects the group exactly as before. A half scale rounded to zero does not imply q is zero. Never merge all tiny groups into a zero group.

## 4. Quantization products without subnormal FP operands/results

Enter this stage only after all original group validity checks pass. Then reciprocal is positive finite and the saved half is finite. Since d<65520 whenever half-RNE is finite, reciprocal is >=2^-16. The same carried bit-domain d_is_zero predicate from section 3 bypasses the entire product/round service to integer q=0, after the finite input scan. Original R0 would form finite signed-zero products for finite x times +0; the observable q/status are unchanged. For nonzero subnormal d, the line-641 rounded selection must never take this zero branch, even if the old FP comparator would report equality to zero.

For nonzero x and nonzero d, obtain exact floor binary exponents E_x and E_r from bits (for subnormal x, E_x=k-149). If E_x+E_r<=-4, the exact magnitude x*r is strictly below 1/4. Its binary32 rounding is at most 1/4, so the original roundf result is exactly zero, finite and in range. Emit q=0 through an aligned bypass token. This is an exact refinement of the observable quantization, not an assertion that an FTZ product equals the original subnormal intermediate. The original product/rounded validity tests are provably satisfied on this bypass domain. A new diagnostic must not falsely label an omitted raw product as a bit-exact computed R0 product.

For all remaining lanes the exact product magnitude is at least 1/8, hence its binary32 result cannot underflow. If x is normal, use original x and reciprocal. If x is subnormal, construct X=x*2^24 by bit encoding (preserving sign) and R=reciprocal*2^-24 by subtracting 24 from its normal exponent. R remains normal: its exponent is at least -40. Both operands are now normal and their exact real product is unchanged. Therefore the unchanged multiplier's RNE result equals R0 F32(x*reciprocal), with no scaling of the product and no double rounding.

Retain original roundf ties away from zero and the [-127,+127] rejection. This design does not introduce saturation/clamping. Zero x yields q=0. Any FP unknown, unexpected nonfinite, or broken helper precondition fails the isolated checker; it is not converted into a plausible q.

Important half-integer test: with amax=0x037e0000, d=0x00400000 and reciprocal=0x7f000000. x=+/-0x00200000 represents +/-2^-128 and must quantize +/-0.5 to +/-1. Adjacent magnitudes 0x001fffff and 0x00200001 test both sides. They take the normal-product route, not the small-product zero bypass.

## 5. Final bias addition on the reachable restore domain

Keep half scale decode, fixed integer dot tree, separate scale product, term and ordered PS accumulation unchanged. Their successful-domain inputs/results are normal or signed zero by the referenced proof; no general subnormal multiplier replacement is selected.

After original finite-bias validation, if PS_bits==0x00000000, emit the raw bias bits except that either signed zero bias emits +0. For nonzero PS, if abs(bias_bits)<0x00800000 (zero or subnormal), emit PS_bits: bias is below half an ULP of |PS|>=2^-48. Otherwise perform the original FP addition. Both operands of that addition are normal; its result is zero or normal, since nonzero near-cancellation is at least 2^-72. Thus the actual adder never needs to accept a subnormal operand or produce a nonzero subnormal on the active FP route.

A PS value of -0 is outside the proved successful restore domain; tests must expose such a violation rather than using this proof to excuse it. General arbitrary-F32 add/multiply conformance remains failed. This adapter does not repair all seven wrappers for unrestricted IEEE use.

## 6. State, ordering and implementation interfaces

Initially implement only isolated synthesizable raw-bit helper functions and a probe against the bound actual wrappers. Helpers cover classification/bit-domain zero at both d_full control sites/unsigned max, tiny div127, subnormal-up24, positive-normal exponent down24/up24-overflow, quant zero-domain predicate, and final-bias route/select. Use explicit unsigned widths: 30-bit U, at least 24-bit quotient, 7-bit remainder, and at least 9-bit exponent sums. Never implement normalization by feeding a subnormal into the failed FP multiply.

Helpers are combinational and have no independent clock/reset/ownership. The test harness uses the existing 10 ns probe clock and fixed operand holds. Future C1 insertion must carry bypass results as ordinary tagged tokens and align them with their corresponding service result; no early result retirement, changed first-error order, additional group commit, lost output/trace credit or cache-state change. Rows, groups, input lanes, bad_element, done task/unit, counters and ABI remain the original definitions. A failed group commits neither A8 nor saved half, and linear work does not start after quant rejection. Production integration and its exact pipeline schedule remain held.

## 7. Required isolated source delivery and coverage

Provide source/design.md/results.md mapping updates, rtl/r0_fp_bits_pkg.sv (or equivalent synthesizable helpers), explicit actual-wrapper probe TB, an independent original-R0 reference source, vector manifest/generator sources, exact source/library/snapshot binding and finite runners. The reference must not call the repair helpers or derive expected values from DUT output. Keep all prior 119 raw vectors/results frozen; new adapted-domain tests are a separately named suite, not a relabel of primitive conformance.

Required groups/values include: both signed zeros; amax encodings 1,63,64,0x00800000; 0x02fdffff and 0x02fe0000..0x02fe0005; 0x037e0000 with signed normal/subnormal lane mixtures and the half-integer trio; 0x03fdffff/0x03fe0000/0x03fe0001; first/last valid half-scale rounding and overflow boundaries; normal RNE and roundf ties; all lane positions for nonfinite-input first error; a late bad lane versus an earlier potential tiny-div failure; no group commit after rejection. Include normal-path regression inputs from accepted Scorer rows.

Check d_full and reciprocal raw bits, both d_is_zero branch decisions, saved half, all 32 q bytes and status/error index separately. Explicitly prove nonzero subnormal d selects reciprocal normalization and the nonzero rounded path; include d=0, d=1, the reciprocal overflow pair 0x00200000/0x00200001, d=0x00400000 and d=minnormal. Never infer branch correctness only from a final q that happens to be zero. For lanes taking the mathematically proved q=0 bypass, compare original-R0 q/status and record bypass explicitly; do not invent a computed product field. For FP-route lanes compare raw product too. Restore cases include PS+0 with +/-minsub, largest signed subnormal, normal bias, +/-0; nonzero PS +/-2^-48 with signed tiny bias; cancellation producing +/-2^-72; and original dot/half extremes. All raw mismatch records must be preserved before final failure.

Source preparation only is released now. CPU execution, actual adapter RTL, HLS/OOC and C1 integration need subsequent source and finite-budget acceptance. Planned exhaustive CPU checks of the tiny 0..0x03fe0000 amax domain and all subnormal d encodings must receive an explicit bounded execution plan; they are not claimed as run. No board/150 MHz/II/resource result follows from this proof.

## 8. Source draft map and later binding gate

- `rtl/r0_fp_bits_pkg.sv`: combinational classification, unsigned magnitude maximum and first nonfinite lane, exact tiny division, subnormal up24, normal exponent shift, quant route/operand selection, and reachable-domain bias route/direct bits. The helpers have no clock or transaction ownership; production C1 changes are not present.
- `tb/original_r0_reference.py`: independent exact-rational binary32/half RNE, original group error/commit and ordered restore PS from signed8 dot and finite half scales. It does not import the helper package or use DUT outputs.
- `tb/vector_manifest.json` and `tb/generate_vectors.py`: fixed finite inputs plus the accepted Scorer input group by exact hash; generated include/table are absent until a later CPU gate. The restore extremes use dot +524288 or -520192, half min-subnormal or max-finite, and one or 128 ordered groups. `tb/verify_generated_vectors.py` binds the resulting table/include without executing the oracle.
- `tb/r0_adapter_probe_top.sv`: the exact seven unchanged generated outer wrappers, both d-zero control observations, raw d/reciprocal/half/product/q/status/error/commit checks, and +0/normal/tiny-bias restore routes. The bench holds operands for 32 clocks, samples active FP services on three clocks, logs each comparison before fatal, and has a 500000-cycle watchdog. `tb/audit_raw.py` requires full expected field coverage, stable values, the completion count and the XSim pass marker.
- `tb/make_source_packet.py` and `tb/verify_source_binding.py`: the 28 wrapper/VHDL/Tcl/XCI input identities, accepted FP and Scorer lineage, installed `floating_point_v7_1_21` library identities, tool launchers, maintained source and exact new compiled snapshot identity. Only four named XSim runtime-mutable snapshot files may change after a recorded pre-runtime snapshot.
- `tb/run_vectors.sh`, `tb/build_static.sh`, `tb/run_adapter.sh`: dormant finite source runners with fresh output directories and local timeouts. Each CPU/static/runtime/offline stage still requires a separate Astra-reviewed finite execution budget and owned-process guard before use. The old 119-case raw suite remains independent and failed at 33 cases; passing this adapted-domain suite later would not relabel general primitive conformance.

The v2 source correction uses raw `amax=0x4afde040` for the exactly representable `65504×127` last-finite half-scale case. The neighboring overflow-midpoint probes use `0x4afdf01f`, `0x4afdf020`, and `0x4afdf021` around `65520×127`. These are input encodings in the manifest; their expected d, half, status and q values will be produced only when the separately gated independent reference runs. The earlier v1 manifest and all 16 maintained v1 files are preserved byte-for-byte under `source/preimages/v1/`.

`tb/audit_raw.py` now takes its fixed expected bits from the independently generated case table. It checks both the probe's logged actual and its logged expected bits against that table; only service-stability samples use a dynamic comparison. The normal-wrapper smoke values are also table-bound. The probe's `group_committed` field reports a local test-bench decision after its own 32-lane loop. It does not demonstrate atomic A8/half commit in production RTL, or C1 integration, ownership, retirement or credit behavior. Those remain separate implementation and verification work.
