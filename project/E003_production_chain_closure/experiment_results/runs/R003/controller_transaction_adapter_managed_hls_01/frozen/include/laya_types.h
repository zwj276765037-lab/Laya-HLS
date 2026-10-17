#pragma once
#include "laya_config.h"
#include <array>
#include <cstddef>
#include <cstdint>

namespace laya {
enum class Status : uint16_t { OK=0, E_ABI=1, E_MODEL=2, E_SHAPE=3, E_INDEX=4, E_BUFFER=5, E_NUMERICAL=6, E_PROTOCOL=7, E_INTERNAL=8 };
struct Check { Status code; uint32_t detail=0; uint64_t bad_element=UINT64_MAX; constexpr explicit operator bool() const { return code==Status::OK; } };
constexpr Check ok() { return {Status::OK,0,UINT64_MAX}; }
constexpr uint32_t detail(uint8_t domain,uint8_t object,uint16_t reason) { return (uint32_t(domain)<<24)|(uint32_t(object)<<16)|reason; }
enum class Bo : uint8_t { EMBEDDING, IO, W_Q0, W_Q1, W_SCALE, AUX, STATE0, STATE1, QKV0, QKV1, FF0, FF1, ATT_OUT };
enum class Buffer : uint8_t { NONE=0,HIDDEN=1,NORM=2,TMP=3,MARKER=4,QKV=5,WI=6,GATE=7,ATT_OUT=8,DEC_FF=9,HEAD_WORK=10,TYPE_ROWS=11,LN_ROW=0x20,QUANT_INPUT=0x21,A8=0x22,WEIGHT=0x23,PS=0x24,KV=0x25,SCORE_PROB=0x26,Q_TILE=0x27,AV_PARTIAL=0x28,ROPE_HEAD=0x29,LN_GAMMA=0x2a,ROPE_TABLE=0x2b };
enum class Region : uint8_t { SCORER_ACT=0,ACT_INPUT=1,ACT_HIDDEN=2,CAND_MASKED=3,ACT_LOGITS=4,STATS=5,CAND_PROB=6,CAND_RAW=7 };
enum class RowSpace : uint8_t { TOKEN=0, MARKER=1, BATCH=2 };
enum class CacheState : uint8_t { FREE=0,FILL=1,READY=2,READ=3,EXCLUSIVE_RW=4,DRAIN=5,INVALID=6 };
enum class Content : uint8_t { UNDEFINED=0,F32=1,QKV_RAW=2,QKV_FINAL=3,Q8_TILE=4,Q8_WEIGHT=5,SCORE=6,PROB=7 };
enum class OutputUnit : uint8_t { NONE=0,F32=1,Q8_GROUP=2,BYTES=3 };
struct BufferRef { Buffer id=Buffer::NONE; uint8_t bank=0; uint32_t epoch=0; };
constexpr bool operator==(BufferRef a,BufferRef b) { return a.id==b.id && a.bank==b.bank && a.epoch==b.epoch; }
constexpr bool operator!=(BufferRef a,BufferRef b) { return !(a==b); }
constexpr BufferRef none() { return {}; }
struct WeightKey { uint8_t family=0,layer=255; };
struct F32Beat { std::array<uint32_t,8> data{}; uint32_t task_id=0,epoch=0; uint16_t row=0,col=0; uint8_t valid_count=0; bool row_last=false,task_last=false; };
struct WiPairBeat { std::array<uint32_t,8> data{}; uint32_t task_id=0,epoch=0; uint16_t row=0,col=0; uint8_t pair_count=0; bool row_last=false,task_last=false; };
struct Q8Group { std::array<int8_t,32> q{}; uint16_t scale_bits=0; uint32_t task_id=0,epoch=0; uint8_t row_local=0,group=0; bool row_last=false,tile_last=false; };
struct DotIssue {uint32_t task_id=0,a_epoch=0,w_epoch=0,ps_epoch=0;uint8_t group=0;uint16_t n0=0;uint8_t valid_rows=0,valid_cols=0;};
using PackedF32=std::array<uint8_t,45>;
using PackedQ8=std::array<uint8_t,44>;
PackedF32 pack(const F32Beat&);
PackedF32 pack(const WiPairBeat&);
PackedQ8 pack(const Q8Group&);
Check unpack(const PackedF32&,F32Beat&);
Check unpack(const PackedF32&,WiPairBeat&);
Check unpack(const PackedQ8&,Q8Group&);
Check check_beat(const F32Beat&,uint16_t row_width,uint16_t final_row,uint8_t lanes=8);
Check check_beat(const WiPairBeat&,uint16_t final_row);
Check check_group(const Q8Group&,uint8_t rows,uint8_t groups);
Check check_dot_issue(const DotIssue&,uint8_t rows,uint16_t K,uint16_t N);
}
