#pragma once
#include <stdint.h>
// Stateful scalar RTL blackbox call. All accepted calls finish before the
// next one. The outer FullRuntime owns the actual tensor leases/BO writes.
// Generated top uses ap_ctrl_chain and the HLS global ap_ce clock enable;
// completed outputs remain held until ap_continue acknowledges the command.
// RESET=0, BIND_WORD=1 (index0..54), CONFIG=2 (index=S,payload=query|head<<16|
// sliding<<24), Q=3, K=4, V=5, MASK=6, QK=7, SOFTMAX=8, AV=9,
// SCORE=10, PROB=11, OUTPUT=12, MAX=13, EXP=14, SUM=15, RELEASE=16.
// BIND_READ=17 (complete record readback, retained in actual RTL storage).
// 55 binding words: NumericIdentity21, QK/SM/AV TaskContext4 each, and
// KV/score/prob/partial/destination/QKV0/QKV1 BufferRef3 words each plus
// head|mask_mode<<8. Context: task_id,op|stage<<8|layer<<16|batch<<24,
// row0|rows<<16,row_space. Ref: id|bank<<8,epoch,reserved0.
// SCORE/PROB caches retain 16 complete rows. CONFIG selects a row; every bound
// row must complete QK before SOFTMAX, and SOFTMAX before any AV acceptance.
// MAX/EXP/SUM are one-row scratch and OUTPUT is one-row return storage: reads
// require the selected query to match the most recently completed SM/AV row.
void laya_attention_service(uint32_t command, uint32_t index,
                            uint32_t payload, uint32_t epoch,
                            uint32_t &result, uint32_t &status);
