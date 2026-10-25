# E012 current R003 F32-MATRIX-07

One real32F32 stream passes descriptor/bias binding, one frozen quant_group32, real A config/write/ack/publication, actual quant/DIV release, one cold-W full matrix command and32F32 final retirement. The pure quant/A engine is separate from the current row-major F32 parent; it has external real DIV and A ports, bounded256B coordinate metadata and explicit producer close/cancel location. Current standalone shell has exactly one DIV8 and one existing matrix/core/A/W/sharedFP/PS. Original model64/tensor32 remain internal keys; full128bit tags must be validated before future parent mapping.

Current main compiled build AT018 uses sharedDIV8bbd14630885f50817e1055da0bec2449f055021b462fbc02bb531389ea05a79. Its only SV differences from AT006 are exact owned DIV idle gating and TB coefficient-load timing observation; all matrix/A/quant DUT bytes match. Explicit frozen compiled source reuse keeps source versions distinct. Later stronger TB observations are only uncompiled preparation and do not extend old claims. Actual source/oracle/command/guard/fixture/snapshot evidence remains per AT.

Original independent full_reference is frozen at SHAfe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784. Existing R002 full-local reference fixtures are reused; only bytes-to-input.hex conversion and original global quant error classification are new, no full-model gold.

# E012 / R002 FULLN-04 frozen delivery

R002 ends at its declared cost boundary. One prequantized M128 command autonomously traverses full N through one numeric core, unique shared FP/PS, two A/W slots and a coverage-bound original-bias store. All protocol/code/raw source/fixture/snapshot/command/guard/policy/receipt evidence stays in its original attempts. Authority and exact resource/cycle boundaries are SM010 FULLN-04 and R002/protocol.md; authoritative independent original reference SHAfe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784. AT002 has all full-local original W/bias and128xN final/pre-bias gold for8 representative tensors; this is fixture scope, not eight executed full matrices.

Current cleanup core SHAc13b2f8bf601631c33b206b42f57f6060889c2a26d507aa8cdd52a9da966c349 is frozen in AT029. Only one abort-clear assignment plus its comment differs from prior full-N core SHA9123f76026cac7e0757fccfc55dda225d1796fadb06272ac026211433370fac3. All other R002 DUT SHA match. R001 numeric/cache/PS leaves are reused only by exact unchanged SHA. The sharedFP wrapper separately changed two bypass enables fromphase3 tophase3||phase6 before R002; exact diff is verified, phase1 remains false in both, and actual R002 wrapper is directly exercised. No E012 phase6 claim.

This publication is the delivery-time boundary. Subsequent R003 authorized source changes must not be used to rerun or repair these frozen expectations. R003 will add actual F32/quant/A integration with its own budget, not supplement unchanged R002 full FC tests.


---
Published: 2026-10-21T07:46:39.839971+00:00
Publication: Pc569ec4d11e247f1914cac816c79ff25
