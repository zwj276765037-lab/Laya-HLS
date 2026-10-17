#pragma once
#include <stdint.h>
// Full-capacity single-head tile service. RESET/BIND/CONFIG/K/V/MASK and
// BIND_READ retain the 55-word binding contract of attention_service.h.
// 18 LOAD_Q_TILE accepts row_local*64+d in strictly increasing order.
// Accepted nonfinite Q values retire the load normally. Command19 checks
// each original row's Q before that row's arithmetic and returns its local
// d for a Q failure, preserving earlier-row arithmetic first-error priority.
// 19/20/21 execute whole-tile QK/SM/AV; index and payload are zero.
// CONFIG selects only diagnostic query and cannot change the bound tile.
// SCORE/PROB/Y remain valid for the complete successful tile; EXP/MAX/SUM
// diagnostics require a matching row tag in one of the eight scratch slots.
// Real RTL holds done/result/status valid until continue and freezes every
// sequential block under CE; synchronous reset takes precedence over CE.
void laya_attention_tile_service(uint32_t command, uint32_t index,
                                uint32_t payload, uint32_t epoch,
                                uint32_t &result, uint32_t &status);
