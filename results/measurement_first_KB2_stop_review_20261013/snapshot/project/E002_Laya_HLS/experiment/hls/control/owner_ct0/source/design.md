# CT0: 32-entry owner table diagnostic

Status: schema/reference preparation only. HLS and RTL are NOT_RUN. This diagnostic is not connected to the production owner, publisher, or retirement path. Heavy-tool work begins only after KB2 has a result or evidence-backed no-go.

Authority: `include/laya_full_runtime.h` (`FullOwnerRecord`, `FullOwners`) and `hls/common/laya_full_owner.cpp` (`find_index`, `legal_spec`, `in_scope`, `full_require_owner`, `full_acquire_owner`, `full_release_read_owner`), checked 2026-10-13. The operation contract is `mission/measurement_next_stage_20261013.md`.

## Packed storage schema

The fixed table has 32 records. These are semantic bit widths; C++ ABI padding is excluded. Array word 0 occupies the low bits of each bitmap; row bit `i` is word `i/32`, bit `i%32`.

| Bits inclusive | Field | Width |
| --- | --- | ---: |
| 0..671 | `identity`: request_id64, generation64, B16, S16, four 128-bit tags | 672 |
| 672..719 | `ref`: id8, bank8, epoch32 | 48 |
| 720..767 | `lease_old_ref`: id8, bank8, epoch32 | 48 |
| 768..799 | `max_claimed_epoch` | 32 |
| 800..839 | region, stage, layer, batch, row_space; each 8 | 40 |
| 840..887 | row0, rows, width; each 16 | 48 |
| 888..911 | content, state, readers; each 8 | 24 |
| 912..2959 | `covered_rows[64]`; each 32 | 2048 |
| 2960..5007 | `old_consumed_rows[64]`; each 32 | 2048 |
| 5008 | valid | 1 |

Each record is 5009 bits; 32 records total 160288 semantic bits. The three `type_valid` bits and operation input latches are separate. This is a logical storage account, not a BRAM/LUT result.

Cold INIT writes the actual default record values to every entry: `ref` and `lease_old_ref` are `NONE/0/0`, `layer=255`, `row_space=TOKEN`, `content=UNDEFINED`, `state=INVALID`, all other scalar values and both bitmaps are zero, `valid=0`. The diagnostic must not treat a later request reset as a fresh INIT. A setup fixture may load complete records only before operations begin; every loaded field is read back.

## Operation boundary

One operation is in flight. REQUIRE and ACQUIRE first apply the source helper's physical alias search across all 32 entries, legal spec, request/model validity, numeric identity, full spec, READY/READ state, scope, covered row bits, and TYPE_ROWS `type_valid`. REQUIRE does not write. ACQUIRE also checks `readers != 255`, then forms a private full-record candidate and commits the readers/state change once. Rejection writes no record.

RELEASE_READ uses the source helper's narrower rule: physical alias search, `same_spec`, READ state, nonzero readers, and valid. It does not add a request-valid or full-NumericIdentity requirement. It decrements readers once and returns state to READY only at zero. Response backpressure holds the result without repeating the commit. INIT, fixture load, operation, and readback share one writer and cannot overlap.

The independent software oracle uses an actual `FullRuntime` with the original three functions and compares full record readback, Check status/detail/bad element, unchanged records on rejection, same-address and different-address order, and response hold. Tests must exercise entries 0 and 31, all 32 occupied, aliasing, mismatched epoch/spec/identity, coverage boundaries, readers 0/255, TYPE_ROWS bits, and default values. Generated RTL must demonstrate physical table access and one commit or rejection, not only HLS generation.
