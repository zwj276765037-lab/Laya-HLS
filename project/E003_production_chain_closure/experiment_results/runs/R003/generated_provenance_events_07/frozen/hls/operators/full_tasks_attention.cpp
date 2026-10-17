#include "full_task_common.h"
#include "laya_full_cache_storage.h"
#include "../../vivado/module_design/attention_and_fp_engine/source/attention_service.h"

namespace laya::full {
#ifndef __SYNTHESIS__
namespace { AttentionServiceStats attention_stats{}; }
void full_attention_service_stats_reset() { attention_stats = {}; }
AttentionServiceStats full_attention_service_stats_read() { return attention_stats; }
#endif
namespace {
Check read_qkv(const FullRuntime& rt, const FullMemory& memory, uint8_t plane, uint8_t batch,
               uint8_t head, uint16_t row, uint8_t d, float& value) {
  Address a;
  Check c = qkv_address(plane, batch, head, row, d,
                        rt.inputs.identity.B, rt.inputs.identity.S, a);
  if (!c) return c;
  uint8_t raw[4];
  c = full_read(memory, a.bo, a.offset, raw, 4);
  if (!c) return c;
  value = numeric_bits_f32(uint32_t(raw[0]) | uint32_t(raw[1]) << 8 |
                           uint32_t(raw[2]) << 16 | uint32_t(raw[3]) << 24);
  return ok();
}
Check write_qkv(FullRuntime& rt, FullMemory& memory, uint8_t plane, uint8_t batch,
                uint8_t head, uint16_t row, uint8_t d, float value) {
  Address a;
  Check c = qkv_address(plane, batch, head, row, d,
                        rt.inputs.identity.B, rt.inputs.identity.S, a);
  if (!c) return c;
  const uint32_t bits = numeric_f32_bits(value);
  const uint8_t raw[4] = {uint8_t(bits), uint8_t(bits >> 8),
                          uint8_t(bits >> 16), uint8_t(bits >> 24)};
  c = full_note_generated_store(rt, a, 4);
  return c ? full_write(memory, a.bo, a.offset, raw, 4) : c;
}
void qkv_specs(const FullRuntime& rt, const BufferRef (&refs)[2],
               uint8_t stage, uint8_t layer, Content content,
               FullOwnerSpec (&out)[2]) {
  for (unsigned shard = 0; shard < 2; ++shard)
    out[shard] = task::spec(refs[shard], 0, stage, layer,
                            RowSpace::TOKEN, rt.inputs.identity.S,
                            64, content);
}
Check qkv_ready(FullRuntime& rt, const FullOwnerSpec (&pair)[2]) {
  for (unsigned shard = 0; shard < 2; ++shard)
    for (unsigned batch = 0; batch < rt.inputs.identity.B; ++batch) {
      Check c = full_require_owner(rt, pair[shard], uint8_t(batch), 0,
                                   rt.inputs.identity.S);
      if (!c) return c;
    }
  return ok();
}
FullOwnerSpec kv_spec(const FullRuntime& rt, BufferRef ref,
                      const TaskContext& ctx) {
  return task::spec(ref, 0, ctx.stage, ctx.layer,
                    RowSpace::TOKEN, rt.inputs.identity.S, 64);
}
FullOwnerSpec score_spec(BufferRef ref, const TaskContext& ctx,
                          uint16_t width, Content content) {
  return {ref, 0, ctx.stage, ctx.layer, ctx.batch, RowSpace::TOKEN,
          ctx.row0, ctx.rows, width, content};
}
void attention_identity_words(const NumericIdentity& id, uint32_t words[21]) {
  words[0]=uint32_t(id.request_id);words[1]=uint32_t(id.request_id>>32);
  words[2]=uint32_t(id.generation);words[3]=uint32_t(id.generation>>32);
  words[4]=uint32_t(id.B)|(uint32_t(id.S)<<16);
  const uint8_t* tags[4]={id.model_tag,id.numeric_tag,id.layout_tag,id.build_tag};
  for(unsigned tag=0;tag<4;++tag)
    for(unsigned word=0;word<4;++word) {
      const uint8_t* p=tags[tag]+word*4;
      words[5+tag*4+word]=uint32_t(p[0])|uint32_t(p[1])<<8|
                          uint32_t(p[2])<<16|uint32_t(p[3])<<24;
    }
}
void attention_context_words(const TaskContext& ctx, uint32_t* words) {
  words[0]=ctx.task_id;
  words[1]=uint32_t(ctx.op)|uint32_t(ctx.stage)<<8|
           uint32_t(ctx.layer)<<16|uint32_t(ctx.batch)<<24;
  words[2]=uint32_t(ctx.row0)|uint32_t(ctx.rows)<<16;
  words[3]=uint32_t(ctx.row_space);
}
void attention_ref_words(BufferRef ref, uint32_t* words) {
  words[0]=uint32_t(ref.id)|uint32_t(ref.bank)<<8;words[1]=ref.epoch;words[2]=0;
}
Check attention_call(Op op, uint32_t command, uint32_t index,
                     uint32_t payload, uint32_t epoch, uint32_t& result) {
#pragma HLS inline off
#pragma HLS allocation function instances=laya_attention_service limit=1
  uint32_t status=0;
#ifndef __SYNTHESIS__
  if(command<18)++attention_stats.command_calls[command];
#endif
  laya_attention_service(command,index,payload,epoch,result,status);
#ifndef __SYNTHESIS__
  if(status==0&&command<18)++attention_stats.successful_commands[command];
  else if(status==1)++attention_stats.numerical_errors;
  else if(status)++attention_stats.protocol_errors;
#endif
  if(status==1)return task::numerical(op,result);
  if(status)return {Status::E_PROTOCOL,detail(7,uint8_t(op),4)};
  return ok();
}
Check attention_verify(Op op, uint32_t epoch, unsigned first,
                       const uint32_t* words, unsigned count) {
  for(unsigned i=0;i<count;++i) {
    uint32_t result=0;
    Check c=attention_call(op,17,first+i,0,epoch,result);
    if(!c)return c;
    if(result!=words[i])return {Status::E_PROTOCOL,detail(7,uint8_t(op),4)};
  }
  return ok();
}
// The scalar service is connected to the production B1 controller. Generic
// standalone task tests and the original B2 path retain their existing leaves.
bool attention_service_destination(const FullRuntime& rt,
                                    const TaskContext& ctx, BufferRef& dst) {
  if(rt.inputs.identity.B!=1)return false;
  for(unsigned i=0;i<32;++i) {
    const FullOwnerRecord& owner=rt.owners.record[i];
    if(owner.valid&&owner.ref.id==Buffer::ATT_OUT&&owner.ref.bank==0&&
       owner.region==0&&owner.state==CacheState::FILL&&
       owner.stage==ctx.stage&&owner.layer==ctx.layer&&
       numeric_identity_equal(owner.identity,rt.inputs.identity)) {
      dst=owner.ref;return true;
    }
  }
  return false;
}
Check attention_begin(FullRuntime& rt,const QKTask& t,BufferRef dst) {
  uint32_t words[55]={};attention_identity_words(rt.inputs.identity,words);
  attention_context_words(t.ctx,words+21);
  TaskContext sm=t.ctx;sm.task_id++;sm.op=Op::SOFTMAX_ATT;
  TaskContext av=sm;av.task_id++;av.op=Op::AV;
  attention_context_words(sm,words+25);attention_context_words(av,words+29);
  BufferRef partial{Buffer::AV_PARTIAL,0,1};
  for(unsigned i=0;i<32;++i) {
    const FullOwnerRecord& owner=rt.owners.record[i];
    if(owner.ref.id==Buffer::AV_PARTIAL&&owner.ref.bank==0&&owner.region==0) {
      partial.epoch=owner.max_claimed_epoch<kMaxEpoch?owner.max_claimed_epoch+1:0;
      break;
    }
  }
  BufferRef prob=t.score;prob.epoch++;
  const BufferRef refs[7]={t.kv,t.score,prob,partial,dst,t.qkv_ref[0],t.qkv_ref[1]};
  for(unsigned i=0;i<7;++i)attention_ref_words(refs[i],words+33+i*3);
  words[54]=uint32_t(t.head)|uint32_t(t.mask_mode)<<8;
  uint32_t result=0;Check c=attention_call(t.ctx.op,0,0,0,t.ctx.task_id,result);
  for(unsigned i=0;i<55&&c;++i)c=attention_call(t.ctx.op,1,i,words[i],t.ctx.task_id,result);
  if(c)c=attention_verify(t.ctx.op,t.ctx.task_id,0,words,55);
  if(c)c=attention_call(t.ctx.op,2,t.S,uint32_t(t.ctx.row0)|uint32_t(t.head)<<16|
                        uint32_t(t.mask_mode)<<24,t.ctx.task_id,result);
  for(unsigned key=0;key<t.S&&c;++key)
    for(unsigned d=0;d<64&&c;++d) {
      c=attention_call(t.ctx.op,4,key*64+d,numeric_f32_bits(full_cache_kv(rt)[0][0][key][d]),t.ctx.task_id,result);
      if(c)c=attention_call(t.ctx.op,5,key*64+d,numeric_f32_bits(full_cache_kv(rt)[1][0][key][d]),t.ctx.task_id,result);
    }
  for(unsigned key=0;key<t.S&&c;++key)
    c=attention_call(t.ctx.op,6,key,rt.inputs.attention_mask[0][key],t.ctx.task_id,result);
  return c;
}
Check attention_continue(const FullRuntime& rt,const TaskContext& ctx,
                          uint32_t epoch,unsigned context_word) {
  uint32_t identity[21],context[4],ref[3];
  attention_identity_words(rt.inputs.identity,identity);attention_context_words(ctx,context);
  Check c=attention_verify(ctx.op,epoch,0,identity,21);
  if(c)c=attention_verify(ctx.op,epoch,context_word,context,4);
  attention_ref_words(rt.loaded_kv_ref,ref);
  if(c)c=attention_verify(ctx.op,epoch,33,ref,3);
  for(unsigned shard=0;shard<2&&c;++shard) {
    attention_ref_words(rt.final_qkv_ref[shard],ref);
    c=attention_verify(ctx.op,epoch,48+shard*3,ref,3);
  }
  uint32_t head=uint32_t(rt.score_head)|uint32_t(ctx.stage==2&&ctx.layer%3!=0)<<8;
  if(c)c=attention_verify(ctx.op,epoch,54,&head,1);
  return c;
}
Check attention_select(const FullRuntime& rt,const TaskContext& ctx,
                        uint32_t epoch,unsigned row) {
  uint32_t result=0;
  const uint32_t mode=ctx.stage==2&&ctx.layer%3!=0;
  return attention_call(ctx.op,2,rt.inputs.identity.S,uint32_t(row)|
                        uint32_t(rt.loaded_kv_head)<<16|mode<<24,epoch,result);
}
} // namespace

Check full_run_task(FullRuntime& rt, FullMemory& memory, const RopeTask& t, TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const uint8_t mode = t.ctx.layer % 3 == 0 ? 0 : 1;
  if (t.ctx.op != Op::ROPE || t.ctx.stage != 2 ||
      t.ctx.row_space != RowSpace::TOKEN || t.head >= 16 ||
      t.mode != mode || t.table_set != mode ||
      rt.loaded_rope_mode != mode ||
      rt.loaded_rope_ref.id != Buffer::ROPE_TABLE ||
      rt.loaded_rope_ref.bank != mode)
    return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                        OutputUnit::F32, 0, done);
  BufferRef old_ref[2], next_ref[2];
  for (unsigned shard = 0; shard < 2; ++shard) {
    old_ref[shard] = t.src_qkv_ref[shard];
    next_ref[shard] = t.dst_qkv_ref[shard];
    if (old_ref[shard].id != Buffer::QKV ||
        next_ref[shard].id != Buffer::QKV ||
        old_ref[shard].bank != shard || next_ref[shard].bank != shard ||
        old_ref[shard].epoch >= kMaxEpoch ||
        next_ref[shard].epoch != old_ref[shard].epoch + 1)
      return task::finish(rt, t.ctx, task::buffer(Buffer::QKV),
                          OutputUnit::F32, 0, done);
  }
  FullOwnerSpec next[2];
  qkv_specs(rt, next_ref, 2, t.ctx.layer, Content::QKV_FINAL, next);
  for (unsigned shard = 0; shard < 2; ++shard) {
    FullOwnerRecord owner;
    c = full_owner_snapshot(rt, next_ref[shard], 0, owner);
    if (!c || owner.state != CacheState::EXCLUSIVE_RW ||
        owner.lease_old_ref != old_ref[shard] ||
        owner.stage != 2 || owner.layer != t.ctx.layer ||
        owner.content != Content::QKV_FINAL ||
        !numeric_identity_equal(owner.identity, rt.inputs.identity)) {
      c = task::buffer(Buffer::QKV);
      return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
    }
  }
  for (unsigned plane = 0; plane < 2; ++plane)
    for (unsigned r = 0; r < t.ctx.rows; ++r) {
      const unsigned row = t.ctx.row0 + r;
      if (rt.owners.qkv_rope_rows[t.head % 2][plane][t.head]
                                  [t.ctx.batch][row / 32] &
          (uint32_t(1) << (row % 32)))
        return task::finish(rt, t.ctx, task::buffer(Buffer::QKV),
                            OutputUnit::F32, 0, done);
    }
  const FullOwnerSpec table{rt.loaded_rope_ref, 0, 2, t.ctx.layer, 0,
                             RowSpace::BATCH, 0, 1, 64, Content::F32};
  c = full_acquire_owner(rt, table, 0, 0, 1);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  for (unsigned r = 0; r < t.ctx.rows && c; ++r) {
    const uint16_t row = uint16_t(t.ctx.row0 + r);
    for (unsigned plane = 0; plane < 2 && c; ++plane) {
      float raw[64], rotated[64];
      for (unsigned d = 0; d < 64; ++d) {
        c = read_qkv(rt, memory, uint8_t(plane), t.ctx.batch, t.head,
                     row, uint8_t(d), raw[d]);
        if (!c) break;
      }
      if (c) c = rope_head(raw, full_cache_rope_table(rt)[0][row],
                            full_cache_rope_table(rt)[1][row], rotated);
      for (unsigned d = 0; d < 64 && c; ++d)
        c = write_qkv(rt, memory, uint8_t(plane), t.ctx.batch, t.head,
                      row, uint8_t(d), rotated[d]);
    }
  }
  Check release = full_release_read_owner(rt, table);
  if (c) c = release;
  if (c) c = full_cover_qkv_rope(rt, next, t.head, t.ctx.batch,
                                 t.ctx.row0, t.ctx.rows);
  if (!c) {
    full_invalidate_owner(rt, next_ref[0], 0);
    full_invalidate_owner(rt, next_ref[1], 0);
  }
  return task::finish(rt, t.ctx, c, OutputUnit::F32,
                      uint32_t(t.ctx.rows) * 128u, done);
}

Check full_run_task(FullRuntime& rt, FullMemory& memory, const QKTask& t, TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const uint8_t mode = t.ctx.stage == 2 && t.ctx.layer % 3 != 0 ? 1 : 0;
  if (t.ctx.op != Op::QK ||
      (t.ctx.stage != 2 && t.ctx.stage != 4) ||
      t.ctx.row_space != RowSpace::TOKEN || t.head >= 16 ||
      t.S != rt.inputs.identity.S || t.mask_mode != mode ||
      t.scale_bits != 0x3e000000u ||
      t.kv != rt.loaded_kv_ref || rt.loaded_kv_head != t.head ||
      t.score.id != Buffer::SCORE_PROB || t.score.bank != 0)
    return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                        OutputUnit::F32, 0, done);
  BufferRef refs[2] = {t.qkv_ref[0], t.qkv_ref[1]};
  if (refs[0].id != Buffer::QKV || refs[0].bank != 0 ||
      refs[1].id != Buffer::QKV || refs[1].bank != 1 ||
      refs[0] != rt.final_qkv_ref[0] ||
      refs[1] != rt.final_qkv_ref[1])
    return task::finish(rt, t.ctx, task::buffer(Buffer::QKV),
                        OutputUnit::F32, 0, done);
  FullOwnerSpec qkv[2];
  qkv_specs(rt, refs, t.ctx.stage, t.ctx.layer, Content::QKV_FINAL, qkv);
  c = qkv_ready(rt, qkv);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const FullOwnerSpec kv = kv_spec(rt, t.kv, t.ctx);
  c = full_require_owner(rt, kv, t.ctx.batch, 0,
                         rt.inputs.identity.S);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  const FullOwnerSpec score = score_spec(t.score, t.ctx, t.S,
                                          Content::SCORE);
  c = full_claim_owner(rt, score);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  bool q_read = false, kv_read = false;
  c = full_acquire_owner(rt, qkv[t.head % 2], t.ctx.batch,
                         t.ctx.row0, t.ctx.rows);
  if (c) {
    q_read = true;
    c = full_acquire_owner(rt, kv, t.ctx.batch, 0,
                           rt.inputs.identity.S);
    if (c) kv_read = true;
  }
  uint8_t qk_mask[1024];
  if (c)
    for (unsigned key = 0; key < t.S; ++key)
      qk_mask[key] = rt.inputs.attention_mask[t.ctx.batch][key];
  BufferRef service_dst;
  const bool service=attention_service_destination(rt,t.ctx,service_dst);
  if(c&&service)c=attention_begin(rt,t,service_dst);
  for (unsigned r = 0; r < t.ctx.rows && c; ++r) {
    float q[64];
    for (unsigned d = 0; d < 64; ++d) {
      c = read_qkv(rt, memory, 0, t.ctx.batch, t.head,
                   uint16_t(t.ctx.row0 + r), uint8_t(d), q[d]);
      if (!c) break;
    }
    if(c&&service) {
      uint32_t value=0;
      c=attention_select(rt,t.ctx,t.ctx.task_id,t.ctx.row0+r);
      for(unsigned d=0;d<64&&c;++d)
        c=attention_call(t.ctx.op,3,d,numeric_f32_bits(q[d]),t.ctx.task_id,value);
      if(c)c=attention_call(t.ctx.op,7,0,0,t.ctx.task_id,value);
      for(unsigned key=0;key<t.S&&c;++key) {
        c=attention_call(t.ctx.op,10,key,0,t.ctx.task_id,value);
        if(c)full_cache_score(rt)[t.ctx.batch][r][key]=numeric_bits_f32(value);
      }
    } else if (c) {
#ifndef __SYNTHESIS__
      ++(rt.inputs.identity.B==2?attention_stats.legacy_qk_b2:attention_stats.legacy_qk_b1);
#endif
      c = qk_row(q, full_cache_kv(rt)[0][t.ctx.batch],
                      qk_mask, t.S,
                      uint16_t(t.ctx.row0 + r), mode != 0,
                      full_cache_score(rt)[t.ctx.batch][r]);
    }
  }
  if (kv_read) full_release_read_owner(rt, kv);
  if (q_read) full_release_read_owner(rt, qkv[t.head % 2]);
  if (c) c = full_cover_owner(rt, score, t.ctx.batch,
                              t.ctx.row0, t.ctx.rows);
  if (c) c = full_publish_owner(rt, score);
  if (!c) full_invalidate_owner(rt, t.score, 0);
  else {
    rt.score_ref = t.score;
    rt.score_kv_ref = t.kv;
    rt.score_qkv_ref[0] = refs[0];
    rt.score_qkv_ref[1] = refs[1];
    rt.score_head = t.head;
    rt.score_stage = t.ctx.stage;
    rt.score_layer = t.ctx.layer;
    rt.score_batch = t.ctx.batch;
    rt.score_row0 = t.ctx.row0;
    rt.score_rows = t.ctx.rows;
    rt.score_valid = true;
  }
  return task::finish(rt, t.ctx, c, OutputUnit::F32,
                      uint32_t(t.ctx.rows) * t.S, done);
}

Check full_run_task(FullRuntime& rt, FullMemory& memory, const SoftmaxTask& t, TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  if (t.ctx.op == Op::SOFTMAX_ATT) {
    if ((t.ctx.stage != 2 && t.ctx.stage != 4) ||
        t.ctx.row_space != RowSpace::TOKEN || t.mode != 0 ||
        t.length != rt.inputs.identity.S ||
        t.src.id != Buffer::SCORE_PROB ||
        t.dst.id != Buffer::SCORE_PROB ||
        t.src.bank != 0 || t.dst.bank != 0 ||
        t.dst.epoch != t.src.epoch + 1 ||
        t.src_region || t.dst_region ||
        !rt.score_valid || rt.score_ref != t.src ||
        rt.score_head != rt.loaded_kv_head ||
        rt.score_kv_ref != rt.loaded_kv_ref ||
        rt.score_qkv_ref[0] != rt.final_qkv_ref[0] ||
        rt.score_qkv_ref[1] != rt.final_qkv_ref[1] ||
        rt.score_stage != t.ctx.stage ||
        rt.score_layer != t.ctx.layer ||
        rt.score_batch != t.ctx.batch ||
        rt.score_row0 != t.ctx.row0 ||
        rt.score_rows != t.ctx.rows)
      return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                          OutputUnit::F32, 0, done);
    const FullOwnerSpec next = score_spec(t.dst, t.ctx, t.length,
                                           Content::PROB);
    FullOwnerRecord owner;
    c = full_owner_snapshot(rt, t.dst, 0, owner);
    if (!c || owner.state != CacheState::EXCLUSIVE_RW ||
        owner.lease_old_ref != t.src ||
        owner.stage != t.ctx.stage || owner.layer != t.ctx.layer ||
        owner.content != Content::PROB || owner.batch != t.ctx.batch ||
        owner.row0 != t.ctx.row0 || owner.rows != t.ctx.rows ||
        !numeric_identity_equal(owner.identity, rt.inputs.identity)) {
      c = task::buffer(Buffer::SCORE_PROB);
      return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
    }
    for (unsigned r = 0; r < t.ctx.rows && c; ++r) {
      float p[1024];
      BufferRef service_dst;
      if(attention_service_destination(rt,t.ctx,service_dst)) {
        const uint32_t epoch=t.ctx.task_id-1;uint32_t value=0,ref[3];
        c=attention_continue(rt,t.ctx,epoch,25);
        attention_ref_words(t.src,ref);if(c)c=attention_verify(t.ctx.op,epoch,36,ref,3);
        attention_ref_words(t.dst,ref);if(c)c=attention_verify(t.ctx.op,epoch,39,ref,3);
        if(c)c=attention_select(rt,t.ctx,epoch,t.ctx.row0+r);
        if(c)c=attention_call(t.ctx.op,8,0,0,epoch,value);
        for(unsigned key=0;key<t.length&&c;++key) {
          c=attention_call(t.ctx.op,11,key,0,epoch,value);
          if(c)p[key]=numeric_bits_f32(value);
        }
      } else {
#ifndef __SYNTHESIS__
        ++(rt.inputs.identity.B==2?attention_stats.legacy_softmax_b2:attention_stats.legacy_softmax_b1);
#endif
        c = softmax_row(full_cache_score(rt)[t.ctx.batch][r], t.length, p);
      }
      if (c) c = full_consume_inplace_rows(rt, next, t.ctx.batch,
                                           uint16_t(t.ctx.row0 + r), 1);
      if (c)
        for (unsigned k = 0; k < t.length; ++k)
          full_cache_score(rt)[t.ctx.batch][r][k] = p[k];
      if (c) c = full_cover_owner(rt, next, t.ctx.batch,
                                  uint16_t(t.ctx.row0 + r), 1);
    }
    if (c) c = full_commit_inplace_owner(rt, next);
    if (!c) {
      full_invalidate_owner(rt, t.dst, 0);
      rt.score_valid = false;
    } else rt.score_ref = t.dst;
  } else if (t.ctx.op == Op::SOFTMAX_CAND) {
    if (t.ctx.stage != 6 || t.ctx.row_space != RowSpace::BATCH ||
        t.mode != 1 || t.length != 16 ||
        t.src.id != Buffer::HEAD_WORK ||
        t.src_region != uint8_t(Region::CAND_MASKED) ||
        t.dst.id != Buffer::HEAD_WORK ||
        t.dst_region != uint8_t(Region::CAND_PROB))
      return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                          OutputUnit::F32, 0, done);
    FullOwnerSpec src;
    c = task::source(rt, t.src, t.src_region, t.ctx, 16, src);
    const FullOwnerSpec dst = task::spec(t.dst, t.dst_region, 6, 255,
                                        RowSpace::BATCH, 1, 16);
    if (c) c = full_check_uncovered_owner(rt, dst, t.ctx.batch, 0, 1);
    if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
    c = full_acquire_owner(rt, src, t.ctx.batch, 0, 1);
    if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
    float x[1024] = {}, y[1024] = {};
    for (unsigned col = 0; col < 16 && c; ++col)
      c = task::read(rt, memory, t.src, t.src_region, t.ctx.batch, 0,
                     uint16_t(col), x[col]);
    Check release = full_release_read_owner(rt, src);
    if (c) c = release;
    if (c) c = softmax_row(x, 16, y);
    for (unsigned col = 0; col < 16 && c; ++col)
      c = task::write(rt, memory, t.dst, t.dst_region, t.ctx.batch, 0,
                      uint16_t(col), y[col]);
    if (c) c = full_cover_owner(rt, dst, t.ctx.batch, 0, 1);
    if (!c) full_invalidate_owner(rt, t.dst, t.dst_region);
  } else {
    c = task::shape(t.ctx.op);
  }
  return task::finish(rt, t.ctx, c, OutputUnit::F32,
                      uint32_t(t.ctx.rows) * t.length, done);
}

Check full_run_task(FullRuntime& rt, FullMemory& memory, const AVTask& t, TaskDone& done) {
  Check c = task::context(rt, t.ctx);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  if (t.ctx.op != Op::AV || (t.ctx.stage != 2 && t.ctx.stage != 4) ||
      t.ctx.row_space != RowSpace::TOKEN || t.S != rt.inputs.identity.S ||
      t.head >= 16 || t.prob.id != Buffer::SCORE_PROB ||
      t.kv != rt.loaded_kv_ref || rt.loaded_kv_head != t.head ||
      t.partial.id != Buffer::AV_PARTIAL || t.partial.bank != 0 ||
      t.dst.id != Buffer::ATT_OUT ||
      !rt.score_valid || rt.score_ref != t.prob ||
      rt.score_kv_ref != t.kv || rt.score_head != t.head ||
      rt.score_qkv_ref[0] != rt.final_qkv_ref[0] ||
      rt.score_qkv_ref[1] != rt.final_qkv_ref[1] ||
      rt.score_stage != t.ctx.stage || rt.score_layer != t.ctx.layer ||
      rt.score_batch != t.ctx.batch || rt.score_row0 != t.ctx.row0 ||
      rt.score_rows != t.ctx.rows)
    return task::finish(rt, t.ctx, task::shape(t.ctx.op),
                        OutputUnit::F32, 0, done);
  const FullOwnerSpec prob = score_spec(t.prob, t.ctx, t.S, Content::PROB);
  const FullOwnerSpec kv = kv_spec(rt, t.kv, t.ctx);
  const FullOwnerSpec dst = task::spec(t.dst, 0, t.ctx.stage,
                                      t.ctx.layer, RowSpace::TOKEN,
                                      t.S, 1024);
  c = full_require_owner(rt, prob, t.ctx.batch, t.ctx.row0, t.ctx.rows);
  if (c) c = full_require_owner(rt, kv, t.ctx.batch, 0, t.S);
  if (c) c = full_check_fill_owner(rt, dst);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  for (unsigned r = 0; r < t.ctx.rows; ++r) {
    const uint16_t row = uint16_t(t.ctx.row0 + r);
    if (rt.owners.att_head_rows[t.head][t.ctx.batch][row / 32] &
        (uint32_t(1) << (row % 32)))
      return task::finish(rt, t.ctx, task::buffer(Buffer::ATT_OUT),
                          OutputUnit::F32, 0, done);
  }
  const FullOwnerSpec partial = {t.partial, 0, t.ctx.stage, t.ctx.layer,
                                 t.ctx.batch, RowSpace::TOKEN,
                                 t.ctx.row0, t.ctx.rows, 64, Content::F32};
  c = full_claim_owner(rt, partial);
  if (!c) return task::finish(rt, t.ctx, c, OutputUnit::F32, 0, done);
  bool p_read = false, kv_read = false;
  c = full_acquire_owner(rt, prob, t.ctx.batch, t.ctx.row0, t.ctx.rows);
  if (c) {
    p_read = true;
    c = full_acquire_owner(rt, kv, t.ctx.batch, 0, t.S);
    if (c) kv_read = true;
  }
  BufferRef service_dst;
  const bool service=attention_service_destination(rt,t.ctx,service_dst);
  const uint32_t service_epoch=t.ctx.task_id-2;
  if(c&&service) {
    c=attention_continue(rt,t.ctx,service_epoch,29);uint32_t ref[3];
    attention_ref_words(t.prob,ref);if(c)c=attention_verify(t.ctx.op,service_epoch,39,ref,3);
    attention_ref_words(t.partial,ref);if(c)c=attention_verify(t.ctx.op,service_epoch,42,ref,3);
    attention_ref_words(t.dst,ref);if(c)c=attention_verify(t.ctx.op,service_epoch,45,ref,3);
  }
  for (unsigned r = 0; r < t.ctx.rows && c; ++r)
    if(service) {
      uint32_t value=0;c=attention_select(rt,t.ctx,service_epoch,t.ctx.row0+r);
      if(c)c=attention_call(t.ctx.op,9,0,0,service_epoch,value);
      for(unsigned d=0;d<64&&c;++d) {
        c=attention_call(t.ctx.op,12,d,0,service_epoch,value);
        if(c)full_cache_av_partial(rt)[r][d]=numeric_bits_f32(value);
      }
    } else {
#ifndef __SYNTHESIS__
      ++(rt.inputs.identity.B==2?attention_stats.legacy_av_b2:attention_stats.legacy_av_b1);
#endif
      c = av_row(full_cache_score(rt)[t.ctx.batch][r],
                full_cache_kv(rt)[1][t.ctx.batch], t.S,
                full_cache_av_partial(rt)[r]);
    }
  if(service) {
    uint32_t value=0;Check release=attention_call(t.ctx.op,16,0,0,service_epoch,value);
    if(c)c=release;
  }
  if (kv_read) full_release_read_owner(rt, kv);
  if (p_read) full_release_read_owner(rt, prob);
  if (c) c = full_cover_owner(rt, partial, t.ctx.batch,
                              t.ctx.row0, t.ctx.rows);
  if (c) c = full_publish_owner(rt, partial);
  bool partial_read = false;
  if (c) {
    c = full_acquire_owner(rt, partial, t.ctx.batch,
                           t.ctx.row0, t.ctx.rows);
    partial_read = bool(c);
  }
  for (unsigned r = 0; r < t.ctx.rows && c; ++r)
    for (unsigned d = 0; d < 64; ++d) {
      c = task::write(rt, memory, t.dst, 0, t.ctx.batch,
                      uint16_t(t.ctx.row0 + r),
                      uint16_t(t.head * 64 + d),
                      full_cache_av_partial(rt)[r][d]);
      if (!c) break;
    }
  if (partial_read) {
    Check release = full_release_read_owner(rt, partial);
    if (c) c = release;
  }
  if (c) c = full_cover_att_head(rt, dst, t.head, t.ctx.batch,
                                 t.ctx.row0, t.ctx.rows);
  if (c) c = full_release_owner(rt, partial);
  if (c) c = full_release_owner(rt, prob);
  if (!c) {
    full_invalidate_owner(rt, t.partial, 0);
    full_invalidate_owner(rt, t.dst, 0);
    full_invalidate_owner(rt, t.prob, 0);
  }
  rt.score_valid = false;
  return task::finish(rt, t.ctx, c, OutputUnit::F32,
                      uint32_t(t.ctx.rows) * 64u, done);
}

} // namespace laya::full
