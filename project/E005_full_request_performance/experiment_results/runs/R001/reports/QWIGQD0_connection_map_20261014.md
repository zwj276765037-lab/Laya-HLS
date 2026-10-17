# QWIGQD0 four-row connection map

Contract: `mission/quant_wi_g_quant_down_stage_20261013.md`. Implementation is solely in E002/experiment; AT034 is the accepted diagnostic attempt, pending controller review. All stages run after one initial reset in one process.

| Stage | Real producer and consumer | Storage / identity | Observed obligation |
| --- | --- | --- | --- |
| External source | Original enc0 LN_FFN F32 first four rows, 16,384B | Read-only DDR `0x100050000`–`0x100053fff`; B1/S128, batch0/row0; NORM source class2, epoch1 | Original binary SHA `658b5a8d...`; AXI 256×512-bit R and exact byte source preservation. Source AR burst count/first-last edges were not printed. |
| Wi input Q | **One** `quant_task_to_dual_a_v1` in `geglu_gate_quant_bridge_v1`; external command accepted cycle23, actual response consumed before G command | Q Context task `ac000002`, Wi linear task `ac000003`; slot0/epoch1, K1024/rows4 | 4096 INT8, 128 FP16 scales and 256 half commits exactly match original q/scale; A publish cycle1101. No TB A commits. |
| Wi resident | Same matrix engine, dualW and dualA | Wi output class6/epoch1, DDR base `0x100001000`; W slot0/epoch1 | 20,992 F32, 671,744 PS lane-groups; 1312 AW/W/B and last B; completion consumed once. |
| Wi→G | Real DDR Wi reader → original G arithmetic and writer | Wi reader source class6/epoch1; GATE output class7/epoch1 at `0x100020000` | 1312 Wi R, four row barriers and 20,992 F32 scalar identities; GATE 10,496 F32 and 656 AW/W/B. |
| GATE Q | Same quantizer, selected only after external Q response consumption and GATE publication | G Q Context task `ac000005`; same dualA slot0/epoch2, K2624/rows4 | GATE 656 physical R; 328 groups, 656 half commits and A publish cycle162862; feeder/dualA counters reset per task. |
| Down resident | Same matrix engine, dualW and dualA | W slot0/epoch2; Down output class3/epoch1 at `0x100040000` | 335,872 PS lane-groups, 4096 F32; 256 AW/W/B, last B, lease/debt closure and one response consume. |

The external task route in the bridge holds the selected response owner from command acceptance through actual response consumption or rejection. While it is selected, G command-ready is isolated. `EXT_QUANT=0` remains the legacy default. The test observes one external Q and one GATE Q sequentially; it does not prove all simultaneous request or recovery profiles.

The final DDR model checks 393,216 bytes. Output written coverage is 83,968B Wi + 41,984B GATE + 16,384B Down = 142,336B; the 16,384B source remains read-only, and 234,496B other bytes stay at sentinel `0xA5` with no write flag. The independent q/scale binaries and all downstream gold serve only as comparators, never as intermediate data injection.
