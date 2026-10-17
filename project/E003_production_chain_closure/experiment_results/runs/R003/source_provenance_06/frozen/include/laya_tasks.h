#pragma once
#include "laya_types.h"
#include <array>

namespace laya {
enum class Op : uint8_t { EMB_TOKEN=0x01,EMB_TYPE=0x02,LN_EMB=0x10,LN_ATTN=0x11,LN_FFN=0x12,LN_FINAL=0x13,LN_MARKER=0x14,QUANT=0x20,LIN_QKV=0x30,LIN_WO=0x31,LIN_WI=0x32,LIN_DOWN=0x33,LIN_DEC_FC1=0x34,LIN_DEC_FC2=0x35,LIN_SCORER_FC1=0x36,LIN_ACT_FC2=0x37,ROPE=0x40,QK=0x50,SOFTMAX_ATT=0x51,AV=0x52,FP_SCORER_FC2=0x53,FP_ACT_FC1=0x54,SOFTMAX_CAND=0x55,GEGLU=0x60,RELU=0x61,ADD_RESIDUAL=0x62,ADD_TYPE=0x63,BIAS_GELU_SCORER=0x64,BIAS_GELU_ACT=0x65,APPLY_CAND_MASK=0x66,GATHER_MARKER=0x70,CAND_STATS=0x71,CONCAT_ACT=0x72,LOAD_W=0x80,LOAD_KV=0x81,LOAD_LN_PARAMS=0x82,LOAD_ROPE=0x83,IO_VALIDATE=0x84,RESULT_COMMIT=0x85 };
struct TaskContext { uint32_t task_id=0;Op op=Op::IO_VALIDATE;uint8_t stage=0,layer=255,batch=0;RowSpace row_space=RowSpace::TOKEN;uint16_t row0=0;uint8_t rows=0; };
struct EmbeddingTask {TaskContext ctx;uint8_t table=0;BufferRef dst;uint8_t type_id=255;};
struct LayerNormTask {TaskContext ctx;BufferRef src,dst;uint8_t gamma=0;uint16_t D=1024;uint32_t eps_bits=0x3727c5ac;};
struct QuantTask {TaskContext ctx;BufferRef src,a_dst;uint16_t K=0;uint8_t src_region=0,input_lanes=8;};
struct LinearTask {TaskContext ctx;BufferRef a,w,ps,dst;WeightKey weight;uint16_t K=0,N=0;uint8_t dst_region=0,bias_kind=0;};
struct RopeTask {TaskContext ctx;std::array<BufferRef,2> src_qkv_ref{},dst_qkv_ref{};uint8_t head=0,mode=0,table_set=0;};
struct QKTask {TaskContext ctx;std::array<BufferRef,2> qkv_ref{};BufferRef kv,score;uint8_t head=0,mask_mode=0;uint16_t S=0;uint32_t scale_bits=0x3e000000;};
struct SoftmaxTask {TaskContext ctx;BufferRef src,dst;uint16_t length=0;uint8_t mode=0,src_region=0,dst_region=0;};
struct AVTask {TaskContext ctx;BufferRef prob,kv,partial,dst;uint8_t head=0;uint16_t S=0;};
struct FPLinearTask {TaskContext ctx;BufferRef src,dst;WeightKey weight;uint16_t K=0,N=0;uint8_t src_region=0,dst_region=0;};
struct VectorTask {TaskContext ctx;BufferRef src0,src1,dst;uint16_t length=0;uint8_t src0_region=0,src1_region=0,dst_region=0;uint16_t bias_id=65535;};
struct GatherTask {TaskContext ctx;BufferRef hidden,markers;uint8_t columns=16;};
struct StatsTask {TaskContext ctx;BufferRef probs,stats;uint8_t valid_options=0,prob_region=6,stats_region=5;};
struct ConcatActTask {TaskContext ctx;BufferRef hidden,stats,dst;uint8_t stats_region=5,dst_region=1;};
struct LoadTask {TaskContext ctx;uint8_t kind=0;BufferRef dst;WeightKey weight;uint8_t head=255,planes=0;uint32_t byte_count=0;};
struct TaskDone {uint32_t task_id=0;Status status=Status::OK;uint32_t error_detail=0;uint64_t bad_element=UINT64_MAX;uint32_t output_elements=0,output_beats=0;OutputUnit output_unit=OutputUnit::NONE;bool drained=false;};
Check check_context(const TaskContext&,uint16_t B,uint16_t S);
Check check_ref(BufferRef,uint8_t region=0);
Check check_weight(WeightKey,uint8_t stage,uint8_t layer,uint16_t K,uint16_t N,bool fp=false);
Check check_done(const TaskDone&,uint32_t expected_task_id,uint32_t expected_elements,OutputUnit expected_unit);
}
