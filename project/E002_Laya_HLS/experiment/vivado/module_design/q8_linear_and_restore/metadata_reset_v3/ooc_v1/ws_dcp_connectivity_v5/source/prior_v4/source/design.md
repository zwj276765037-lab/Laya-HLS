# Ws v4: semantic property batches, unchanged proof domain

2026-10-09. GPT-6 Astra / xhigh. Source preparation only. This fresh sibling must not alter the running `ws_dcp_connectivity_v1` v3 source, its output tree, or any frozen evidence. It authorizes no Vivado, synthesis, DCP open, numerical mapping evaluator, quota extension, or automatic retry. The root controller must first receive and independently review the terminal actual v3 packet before considering a separately sealed v4 execution gate.

## Fixed input and reason

Use only the accepted c480c9334ed20d775c5a768e077b15fa9ad1932cb6535ae639d9b9524c11f1ce DCP and unchanged OOC constraints. The running source packet is 57fb8dbcf5071c2aa031d0fed31c34554de131aeb4407b502bf65f5d095b0d55, released under a43f1daa22f2ae85d5874b59814af855d3185f6f23521849549b03eb8652ec29 with 12 GiB / 900 s. Its terminal result is not yet available at this design's creation. Observed slow per-cell calls and inapplicable-property warnings motivate a source optimization; they do not establish memory leakage or DUT failure.

The prior compact design and its semantic proof requirements remain authoritative. Preserve every selected cell, primitive, pin, logical boundary, net component, segment alias, driver owner, constant and coverage issue. Keep all eight exact banks, both 15-bit addresses, both CE signals, WE, 16-bit input/output, reset and clock. Do not remove cells or suppress unknown primitives to finish faster.

## Property contract

`semantic_property_contract.json` binds the installed UNISIM definitions already used by v3 and enumerates each top-level parameter. Required parameters include every functional BRAM/URAM width, mode, cascade, ECC, polarity, reset, address-enable, output-register, sleep and initialization setting; LUT INIT; FF initial state and input polarities; carry mode; and distributed-memory INIT/clock polarity. Exact INIT and INITP words are retained. LOC and simulation-only MSGON/XON/SIM_COLLISION_CHECK are separately classified, not mistaken for logical settings. Parameter declaration defaults are provenance only and never substitute for missing actual properties.

For each encountered primitive REF_NAME, use its exact required-name contract. A DCP name alias or configuration property not directly named by the UNISIM parameter must have an explicit source-reviewed mapping. A required property that is absent, empty, unsupported, truncated, or raises a tool error is an explicit held semantic gap. Do not silently equate an empty string with zero or a default. Unknown references preserve their inventory/pins and make proof incomplete. Do not infer a primitive's actual property values from another same-type instance.

No hundreds-of-properties `list_property`/`get_property` sweep per cell. Group stable, sorted cell objects by exact REF_NAME. Query each required property once for that group, using documented `get_property PROPERTY $objects`; check output list length against object count, preserve null elements, and serialize exact per-cell values in the same normalized property table. Bind NAME ordering for each group before pairing values with IDs. Use normal error return/catch, not `-quiet` error suppression. A per-cell fallback is allowed only for the failed required group/property, records its reason and does not expand to all available properties. Cache available-property metadata once per reference as diagnostic information; availability on one object never proves availability/value on every object.

The installed `common/get_property` manual explicitly supports multiple objects and a list containing null entries. `common/list_property` and `common/report_property` explicitly accept only one object; bulk `report_property` is therefore not a valid optimization. The contract binds all three manuals. No Vivado experiment is needed during source preparation.

## Graph queries and output

Keep documented pin-object `get_nets -segments`; retain the existing canonical-component and driver-owner caches. Batch NAME, DIRECTION and REF_PIN_NAME metadata over stable pin collections where supported, validating lengths and required values. Avoid repeated `list_property` calls inside each pin or driver loop. Never treat hierarchy output aliases as active primitive drivers. Verified GND/VCC remain explicit constants; selected incident pins and unique drivers suffice without expanding all constant loads.

Preserve the eleven normalized graph tables, UTF-8 hex encoding, cell/bank IDs and structural-auditor referential/owner/direction checks unless a separately reviewed schema change is necessary. Add a small phase ledger with timestamps, input/output counts, property query group sizes, failures and completed flush markers so a timeout's last completed stage is clear. Optional repeated global utilization, global DSP lists and exhaustive clock-property sweeps may be omitted from this v4 critical extraction path; bind already accepted reports and unchanged constraints instead. This omission concerns diagnostics only, never the eight-bank graph or logical clock/reset connections.

The source packet must bind this design, the property contract, installed semantics/manuals, exact source/argv, unchanged DCP/constraint identities, v3 terminal evidence and independent review when available, fresh distinct output/control roots, and candidate finite budget. Defaults remain read-only. Tcl syntax completeness, Python AST/manifest checks and synthetic table-parser checks are source checks only; no actual DCP extraction or proof is implied.

## Acceptance boundary

A complete graph and structural audit are prerequisites, not Ws capacity proof. A later separately reviewed evaluator must establish all 8 x 20,992 x 16 logical mappings (2,686,976 bits), unique enabled writes, correct read selection of the same physical storage, data/parity correspondence, CE/WE/clock/reset effects, cascade behavior and address range 16,384 through 20,991. Count each physical RAM once; do not add its two ports as capacity. High-address sample points alone are insufficient. Any external read-selection cone or unsupported state retains a held gap.

No successful C1 numerical/physical integration, 150 MHz timing, board result, or production fe067 change follows from this source preparation. GPT-6 Sol / max may implement this isolated candidate after root scheduling; a new independent source review and finite execution gate are required before running it.
