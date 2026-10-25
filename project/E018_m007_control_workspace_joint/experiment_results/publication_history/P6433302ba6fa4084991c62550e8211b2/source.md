# E018 current source — R002 G-CANCEL-17

R001 CONTROL-ARENA-16 is frozen and accepted within its own source/run boundary. R002 adds producer_cancel_valid/ready/request_id64/generation32/epoch32 plus combinational reject and independent done_cancelled to the production G engine/joint pass-through. Existing rsp identity is compared directly, without copying128bit. Enabled active/not-cancelled/no-held-DONE matching requests accept; wrong/duplicate/inactive requests reject without mutating debt.

Only3 new FF bits are used: done_cancelled, cancel_read_held and cancel_fill_held. Already published stalled bank requests persist; no successor admission after cancel. Actual bank/FP/SFU/precredit/output obligations drain, DONE is held and consumed, then actual matching discard is mandatory before retirement/newgen. Status8/6/0 remains observed status and never implies full-domain success when cancelled. The parent retains its Wi error.

G math/pairs/pool/TANH/numeric/storage and fixed11343-bit layout v1 remain unchanged. Declared joint control4036.375B, ceil4037B/59B margin; no physical fit claim. [R002 protocol](protocol_r002.md), [frozen R001 protocol](protocol.md), [fixed layout](g_control_layout_v1.json). R002 caps0/300/600/0s, no balance transfer, original frozen fixture/no new gold, project lock/CPU0-3/nice19/idle and memory/semantic limits.


---
Published: 2026-10-22T17:04:27.120709+00:00
Publication: P2087e843820f4c8c8269ebd3d97262e5
