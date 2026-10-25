# E018 R002 G-CANCEL-17 protocol

Authority: M007/SM012 D-M007-SM012-G-CANCEL-17, 2026-10-23. R001 remains frozen. A007 owns G engine producer-cancel, necessary joint pass-through and tests/runner. G math/pairs/pool/TANH/layout and numeric leaves remain unchanged.

Producer cancellation directly matches existing rsp_request_id/generation/epoch. Only enabled active uncancelled/no-held-DONE requests may handshake. Wrong/duplicate/inactive requests reject without affecting debt. Accept same-edge real fill/read/FP/SFU/ACK, preserve all committed valid/stable payloads, stop successors, drain every accepted bank/math/output debt without clear/reset. Independent held done_cancelled qualifies partial cancellation; status retains real8/6/0 among observed work, never declares full coverage or global earliest numerical result. Consume DONE, then actual explicit matching pair discard, then no-reset newgen. No early workspace retirement.

Implementation candidate:3 new FF bits (done_cancelled, outstanding published read/write holds); no identity copy, no payload buffer. Exact accounting and immutable source boundary will be audited. Existing joint baseline4036B; expected4036.375B before final audit.

Tests use real native storage/FP pool/TANH8 and original frozen AT058 fixture, no new gold. Cover inactive/wrong identities, incomplete half/block, real bank/FP/SFU and held output17 cancellation, same-edge accepted fill/returns, held bank valids, cancellation DONE held17/discard/newgen12288 result recovery, owner barrier, and normal current short/held/medium/full if cost gate permits. No forced state/debt; public response/status interposers preserve actual obligations.

Independent caps seconds reference0/static300/RTL600/OOC0; static and unknown pilot <=120s, static24GiB/RTL8GiB, CPU0-3/nice19/idle I/O, MemAvailable>192GiB, project heavy lock through descendants, checked semantic stall120s and40Mcycle limit. Full normal requires same-build medium measured bound child_wall*335872/pilot_count*1.35+10<=300s and available RTL >= bound+120s. No old balance transfer, no OOC/board/P&R/GPU/full-model/reference generation. Failed attempts retain archive/log/receipt and cost.
