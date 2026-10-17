#include "laya_full_runtime.h"
#include "laya_full_cache_storage.h"
#include "attention_preloaded_abi.h"

// Include the exact production controller in this TU. The build must omit
// the separately compiled controller source from full_sources.cmake.
#include "control/full_forward_controller.cpp"

namespace laya::full {
namespace {

// Diagnostic control facade: exact production method bodies, runtime only.
struct PreloadOwnerControl {
  FullRuntime& rt;

  bool physical(const FullOwnerRecord& r, Buffer id,
                uint8_t bank, uint8_t region) const {
    if (r.ref.id == Buffer::NONE || r.region != region) return false;
    if (id == Buffer::ROPE_TABLE && r.ref.id == id) return true;
    if (r.ref.bank != bank) return false;
    if (r.ref.id == id) return true;
    return (id == Buffer::WI && r.ref.id == Buffer::DEC_FF) ||
           (id == Buffer::DEC_FF && r.ref.id == Buffer::WI);
  }
  BufferRef fresh(Buffer id, uint8_t bank = 0, uint8_t region = 0) const {
    for (unsigned i = 0; i < 32; ++i) {
      const FullOwnerRecord& record = rt.owners.record[i];
      if (physical(record, id, bank, region))
        return {id, bank, record.max_claimed_epoch < kMaxEpoch ?
                          record.max_claimed_epoch + 1 : 0};
    }
    return {id, bank, 1};
  }
  TaskContext context(Op op, uint8_t stage, uint8_t layer,
                      uint8_t batch, RowSpace space,
                      uint16_t row0, uint8_t rows) const {
    return {rt.last_task_id + 1, op, stage, layer, batch,
            space, row0, rows};
  }
  Check invalidate_incomplete() {
    for (unsigned i = 0; i < 32; ++i) {
      FullOwnerRecord& owner = rt.owners.record[i];
      if (owner.ref.id == Buffer::NONE) continue;
      if (owner.state == CacheState::READ || owner.readers)
        return {Status::E_INTERNAL, detail(7, 0, 14)};
      if (owner.state == CacheState::FILL ||
          owner.state == CacheState::EXCLUSIVE_RW) {
        Check c = full_invalidate_owner(rt, owner.ref, owner.region);
        if (!c) return c;
      }
    }
    return ok();
  }
};

struct ImportPending {
  bool valid = false;
  uint64_t ticket = 0;
  uint32_t metadata[48] = {};
  FullOwnerSpec pair[2] = {};
};

static FullRuntime runtime;
static ImportPending pending;
static uint64_t ticket_counter = 0;
// This is the only persistent object placed on the hardware reset network.
// The first accepted command reconstructs metadata before observing any state.
static bool metadata_initialized = false;

void reset_identity(NumericIdentity& id) {
  id.request_id = 0;
  id.generation = 0;
  id.B = 0;
  id.S = 0;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = 0;
    id.numeric_tag[i] = 0;
    id.layout_tag[i] = 0;
    id.build_tag[i] = 0;
  }
}

void reset_ref(BufferRef& ref) {
  ref.id = Buffer::NONE;
  ref.bank = 0;
  ref.epoch = 0;
}

void reset_spec(FullOwnerSpec& spec) {
  reset_ref(spec.ref);
  spec.region = 0;
  spec.stage = 0;
  spec.layer = 255;
  spec.batch = 255;
  spec.row_space = RowSpace::TOKEN;
  spec.row0 = 0;
  spec.rows = 0;
  spec.width = 0;
  spec.content = Content::UNDEFINED;
}

void reset_record(FullOwnerRecord& record) {
  reset_identity(record.identity);
  reset_ref(record.ref);
  reset_ref(record.lease_old_ref);
  record.max_claimed_epoch = 0;
  record.region = 0;
  record.stage = 0;
  record.layer = 255;
  record.batch = 0;
  record.row_space = RowSpace::TOKEN;
  record.row0 = 0;
  record.rows = 0;
  record.width = 0;
  record.content = Content::UNDEFINED;
  record.state = CacheState::INVALID;
  record.readers = 0;
  for (unsigned i = 0; i < 64; ++i) {
    record.covered_rows[i] = 0;
    record.old_consumed_rows[i] = 0;
  }
  record.valid = false;
}

void reset_f32_meta(F32TileMeta& meta) {
  reset_identity(meta.identity);
  reset_ref(meta.ref);
  meta.region = 0;
  meta.row_space = RowSpace::TOKEN;
  meta.batch = 0;
  meta.row0 = 0;
  meta.rows = 0;
  meta.K = 0;
  meta.state = CacheState::INVALID;
  meta.content = Content::UNDEFINED;
  meta.readers = 0;
  for (unsigned row = 0; row < 16; ++row)
    for (unsigned word = 0; word < 4; ++word)
      meta.covered_groups[row][word] = 0;
  meta.valid = false;
}

void reset_a8_meta(A8TileMeta& meta) {
  reset_identity(meta.identity);
  reset_ref(meta.ref);
  reset_f32_meta(meta.source);
  meta.producer_task_id = 0;
  meta.stage = 0;
  meta.layer = 255;
  meta.row_space = RowSpace::TOKEN;
  meta.batch = 0;
  meta.row0 = 0;
  meta.rows = 0;
  meta.K = 0;
  for (unsigned row = 0; row < 16; ++row)
    for (unsigned word = 0; word < 4; ++word)
      meta.covered_groups[row][word] = 0;
  meta.state = CacheState::INVALID;
  meta.content = Content::UNDEFINED;
  meta.readers = 0;
  meta.valid = false;
}

void reset_weight(FullWeightDescriptor& weight) {
  for (unsigned i = 0; i < 48; ++i) weight.name[i] = 0;
  weight.key.family = 0;
  weight.key.layer = 255;
  weight.K = 0;
  weight.N = 0;
  weight.dtype = 0;
  weight.bias_kind = 0;
  for (unsigned i = 0; i < 2; ++i) {
    weight.q_base[i] = 0;
    weight.q_span[i] = 0;
  }
  weight.scale_base = 0;
  weight.scale_span = 0;
  weight.aux_base = 0;
  weight.aux_span = 0;
  weight.bias_base = 0;
  weight.bias_span = 0;
  for (unsigned i = 0; i < 32; ++i) {
    weight.source_sha256[i] = 0;
    weight.bias_sha256[i] = 0;
  }
}

void reset_metadata(FullRuntime& rt, ImportPending& import,
                    uint64_t& next_ticket) {
  reset_identity(rt.inputs.identity);
  for (unsigned batch = 0; batch < 2; ++batch) {
    for (unsigned token = 0; token < 1024; ++token) {
      rt.inputs.token_ids[batch][token] = 0;
      rt.inputs.attention_mask[batch][token] = 0;
    }
    for (unsigned marker = 0; marker < 16; ++marker) {
      rt.inputs.marker_positions[batch][marker] = 0;
      rt.inputs.marker_mask[batch][marker] = 0;
    }
    rt.inputs.qtype[batch] = 0;
  }

  for (unsigned i = 0; i < 32; ++i) reset_record(rt.owners.record[i]);
  for (unsigned bank = 0; bank < 2; ++bank) {
    for (unsigned plane = 0; plane < 3; ++plane)
      for (unsigned head = 0; head < 16; ++head)
        for (unsigned batch = 0; batch < 2; ++batch)
          for (unsigned word = 0; word < 32; ++word)
            rt.owners.qkv_plane_head_rows[bank][plane][head][batch][word] = 0;
    for (unsigned plane = 0; plane < 2; ++plane)
      for (unsigned head = 0; head < 16; ++head)
        for (unsigned batch = 0; batch < 2; ++batch)
          for (unsigned word = 0; word < 32; ++word)
            rt.owners.qkv_rope_rows[bank][plane][head][batch][word] = 0;
    rt.owners.scorer_old_consumed[bank] = 0;
    rt.owners.scorer_new_written[bank] = 0;
  }
  for (unsigned head = 0; head < 16; ++head)
    for (unsigned batch = 0; batch < 2; ++batch)
      for (unsigned word = 0; word < 32; ++word)
        rt.owners.att_head_rows[head][batch][word] = 0;
  for (unsigned i = 0; i < 3; ++i) rt.owners.type_valid[i] = false;

  // FullCache's numerical arrays have no stores on this path.
  reset_f32_meta(rt.cache.activation_source_ledger);
  reset_a8_meta(rt.cache.activation_meta);
  reset_weight(rt.current_weight);
  reset_ref(rt.current_weight_ref);
  for (unsigned i = 0; i < 2; ++i) {
    reset_ref(rt.loaded_gamma_ref[i]);
    reset_ref(rt.final_qkv_ref[i]);
    reset_ref(rt.score_qkv_ref[i]);
  }
  reset_ref(rt.loaded_kv_ref);
  reset_ref(rt.loaded_rope_ref);
  reset_ref(rt.score_ref);
  reset_ref(rt.score_kv_ref);
  rt.score_head = 255;
  rt.score_stage = 0;
  rt.score_layer = 255;
  rt.score_batch = 255;
  rt.score_rows = 0;
  rt.score_row0 = 0;
  rt.score_valid = false;
  reset_spec(rt.expected_quant_source);
  for (unsigned i = 0; i < 4; ++i) reset_spec(rt.expected_task_source[i]);
  rt.expected_task_source_count = 0;
  rt.loaded_rope_mode = 255;
  rt.loaded_kv_head = 255;
  rt.last_task_id = 0;
  rt.tasks_retired = 0;
  for (unsigned i = 0; i < 256; ++i) rt.op_calls[i] = 0;
  rt.owner_claims = 0;
  rt.owner_leases = 0;
  rt.encoder_layers_completed = 0;
  rt.decision_layers_completed = 0;
  rt.session_generation = 0;
  rt.last_accepted_request_id = 0;
  rt.diagnostic_request_id = 0;
  rt.diagnostic_generation = 0;
  rt.diagnostic_B = 0;
  rt.diagnostic_S = 0;
  rt.diagnostic_identity_valid = false;
  rt.diagnostic_shape_valid = false;
  rt.last_execution_error.code = Status::OK;
  rt.last_execution_error.detail = 0;
  rt.last_execution_error.bad_element = UINT64_MAX;
  rt.last_cleanup_error.code = Status::OK;
  rt.last_cleanup_error.detail = 0;
  rt.last_cleanup_error.bad_element = UINT64_MAX;
  rt.last_commit_error.code = Status::OK;
  rt.last_commit_error.detail = 0;
  rt.last_commit_error.bad_element = UINT64_MAX;
  rt.request_valid = false;
  rt.model_header_valid = false;
  rt.expected_quant_source_valid = false;

  import.valid = false;
  import.ticket = 0;
  for (unsigned i = 0; i < 48; ++i) import.metadata[i] = 0;
  for (unsigned i = 0; i < 2; ++i) reset_spec(import.pair[i]);
  next_ticket = 0;
}

uint64_t wide(const uint32_t* p, unsigned first) {
  return uint64_t(p[first]) | uint64_t(p[first + 1]) << 32;
}

Check protocol(uint32_t command, d2_preload::Reason reason) {
  return {Status::E_PROTOCOL,
          detail(0xd2, uint8_t(command), uint16_t(reason))};
}

bool nonzero_digest(const uint32_t* p, unsigned first) {
  uint32_t any = 0;
  for (unsigned i = 0; i < 8; ++i) any |= p[first + i];
  return any != 0;
}

Check descriptor_shape(const uint32_t* p, uint32_t command) {
  using namespace d2_preload;
  if (p[0] != kMagic || p[1] != kVersion || p[2] != command ||
      p[3] != (1u << 16 | 64u) || p[10] != 0 || p[11] != 1 ||
      p[14] != kSourceBytes || p[15] != kPrefixBytes ||
      p[46] != kWords || p[47] == 0)
    return protocol(command, BAD_DESCRIPTOR);
  if (p[44] >= 16 || p[45] >= 64)
    return protocol(command, BAD_SHAPE);
  for (unsigned i = 48; i < 64; ++i)
    if (p[i]) return protocol(command, BAD_DESCRIPTOR);
  if (!nonzero_digest(p, 16) || !nonzero_digest(p, 24) ||
      !nonzero_digest(p, 32))
    return protocol(command, BAD_DESCRIPTOR);
  if (command == kBegin) {
    if (p[8] || p[9] || p[12] || p[13])
      return protocol(command, BAD_DESCRIPTOR);
    for (unsigned i = kDescriptorMasks; i < kWords; ++i)
      if (p[i]) return protocol(command, BAD_DESCRIPTOR);
  }
  return ok();
}

Check descriptor_identity(const uint32_t* p, const FullRuntime& rt,
                          uint32_t command) {
  const NumericIdentity& id = rt.inputs.identity;
  if (wide(p, 4) != id.request_id || wide(p, 6) != id.generation ||
      id.B != 1 || id.S != 64)
    return protocol(command, d2_preload::BAD_IDENTITY);
  for (unsigned i = 0; i < 4; ++i) {
    const unsigned b = 4 * i;
    const uint32_t word = uint32_t(id.build_tag[b]) |
                          uint32_t(id.build_tag[b + 1]) << 8 |
                          uint32_t(id.build_tag[b + 2]) << 16 |
                          uint32_t(id.build_tag[b + 3]) << 24;
    if (p[40 + i] != word)
      return protocol(command, d2_preload::BAD_IDENTITY);
  }
  return ok();
}

unsigned count_covered(const FullRuntime& rt) {
  unsigned count = 0;
  for (unsigned plane = 0; plane < 3; ++plane)
    for (unsigned head = 0; head < 16; ++head)
      for (unsigned word = 0; word < 2; ++word) {
        uint32_t bits =
            rt.owners.qkv_plane_head_rows[head & 1][plane][head][0][word];
        while (bits) { count += bits & 1u; bits >>= 1; }
      }
  return count;
}

void report(uint32_t* observed, Check c, uint32_t phase,
            bool has_pair) {
  observed[0] = uint32_t(c.code);
  observed[1] = c.detail;
  observed[2] = phase;
  observed[3] = runtime.last_task_id;
  observed[9] = runtime.tasks_retired;
  observed[10] = uint32_t(runtime.score_valid);
  observed[11] = runtime.owner_claims;
  observed[d2_preload::kObsTicketLo] = uint32_t(pending.ticket);
  observed[d2_preload::kObsTicketHi] = uint32_t(pending.ticket >> 32);
  observed[d2_preload::kObsRequestLo] =
      uint32_t(runtime.inputs.identity.request_id);
  observed[d2_preload::kObsGenerationLo] =
      uint32_t(runtime.inputs.identity.generation);
  observed[d2_preload::kObsCoverageBits] = count_covered(runtime);
  observed[d2_preload::kObsFinal0Epoch] = runtime.final_qkv_ref[0].epoch;
  observed[d2_preload::kObsFinal1Epoch] = runtime.final_qkv_ref[1].epoch;
  if (has_pair) {
    observed[4] = pending.pair[0].ref.epoch;
    observed[5] = pending.pair[1].ref.epoch;
    observed[12] = uint32_t(pending.pair[0].ref.id);
    observed[13] = pending.pair[0].ref.bank;
    observed[14] = uint32_t(pending.pair[1].ref.id);
    observed[15] = pending.pair[1].ref.bank;
    for (unsigned shard = 0; shard < 2; ++shard) {
      FullOwnerRecord record;
      const Check snapshot = full_owner_snapshot(runtime, pending.pair[shard].ref,
                                                 0, record);
      observed[d2_preload::kObsOwner0State + shard] =
          snapshot ? uint32_t(record.state) : 0xffffffffu;
    }
  }
}

// Expand error cleanup in the top rather than passing a Controller reference
// across an out-of-line helper boundary. Evaluate each argument exactly once.
#define D2_FAIL_AT_SITE(obs_expr, error_expr, phase_expr, close_expr) \
  do { \
    uint32_t* const d2_observed = (obs_expr); \
    const Check d2_first_error = (error_expr); \
    const uint32_t d2_phase = (phase_expr); \
    const bool d2_close_pending = (close_expr); \
    if (d2_close_pending) { \
      const Check d2_cleanup = controller.invalidate_incomplete(); \
      d2_observed[d2_preload::kObsCleanupStatus] = uint32_t(d2_cleanup.code); \
      d2_observed[d2_preload::kObsCleanupDetail] = d2_cleanup.detail; \
      report(d2_observed, d2_first_error, d2_phase, \
             pending.valid); \
      pending.valid = false; \
    } else { \
      report(d2_observed, d2_first_error, d2_phase, \
             pending.valid); \
    } \
  } while (false)

template <class Task>
Check run_task(FullRuntime& rt, FullMemory& memory, const Task& task,
               uint32_t expected, OutputUnit unit, uint32_t& actual) {
  TaskDone done;
  Check c = full_run_task(rt, memory, task, done);
  actual = done.output_elements;
  if (!c) return c;
  Check completion = check_done(done, task.ctx.task_id, expected, unit);
  if (completion && done.status != c.code)
    completion = {Status::E_INTERNAL, detail(7, uint8_t(task.ctx.op), 14)};
  return completion;
}

}  // namespace
}  // namespace laya::full

#if !defined(__SYNTHESIS__) && defined(D2_PRELOADED_RESET_TEST_HOOK)
// CPU stimulus only. Hardware reset must clear metadata_initialized via pin.
extern "C" void attention_preloaded_test_only_clear_metadata_initialized() {
  laya::full::metadata_initialized = false;
}
#endif

extern "C" void attention_preloaded_slice(uint32_t command,
                                            const uint32_t* descriptor,
                                            uint8_t* io, const uint8_t* aux,
                                            uint8_t* qkv0, uint8_t* qkv1,
                                            uint8_t* att_out,
                                            uint32_t* observed) {
  using namespace laya::full;
#ifdef __SYNTHESIS__
#pragma HLS INTERFACE m_axi port=descriptor offset=slave bundle=descriptor depth=160 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=io offset=slave bundle=io depth=32768 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=aux depth=128 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv0 offset=slave bundle=qkv0 depth=10240064 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=qkv1 offset=slave bundle=qkv1 depth=10240064 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=att_out offset=slave bundle=att_out depth=262144 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=observed offset=slave bundle=observed depth=256 num_write_outstanding=1
#pragma HLS INTERFACE s_axilite port=command bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control
#pragma HLS reset variable=metadata_initialized
#endif
  using namespace laya;
  using namespace laya::d2_preload;
  FullRuntime& rt = runtime;
  if (!metadata_initialized) {
    reset_metadata(rt, pending, ticket_counter);
    metadata_initialized = true;
  }
  FullMemory memory{
      nullptr, 0,          // embedding
      io, 32768,           // io
      nullptr, 0,          // w_q0
      nullptr, 0,          // w_q1
      nullptr, 0,          // w_scale
      aux, 1671872,        // aux
      nullptr, 0,          // state0
      nullptr, 0,          // state1
      qkv0, kHostBytes,     // qkv0
      qkv1, kHostBytes,     // qkv1
      nullptr, 0,          // ff0
      nullptr, 0,          // ff1
      att_out, 8u << 20    // att_out
  };
#ifndef __SYNTHESIS__
  rt.memory = memory;
#endif
  for (unsigned i = 0; i < 16; ++i) observed[i] = 0;
  for (unsigned i = 224; i < 238; ++i) observed[i] = 0;
  PreloadOwnerControl controller{rt};

  if (command == kBegin) {
    if (pending.valid) {
      D2_FAIL_AT_SITE(observed, protocol(command, BEGIN_PENDING), 1, false);
      return;
    }
    Check c = full_parse_request(rt, memory);
    if (!c) { D2_FAIL_AT_SITE(observed, c, 1, true); return; }
    if (rt.inputs.identity.B != 1 || rt.inputs.identity.S != 64) {
      D2_FAIL_AT_SITE(observed, (Check{Status::E_SHAPE, detail(7, 0, 20)}), 1, true);
      return;
    }
    c = descriptor_shape(descriptor, command);
    if (c) c = descriptor_identity(descriptor, rt, command);
    if (!c) { D2_FAIL_AT_SITE(observed, c, 1, true); return; }
    if (ticket_counter == UINT64_MAX) {
      D2_FAIL_AT_SITE(observed, protocol(command, TICKET_EXHAUSTED), 1, true);
      return;
    }
    FullOwnerSpec pair[2] = {
        {controller.fresh(Buffer::QKV, 0), 0, 4, 0, 255,
         RowSpace::TOKEN, 0, 64, 64, Content::QKV_FINAL},
        {controller.fresh(Buffer::QKV, 1), 0, 4, 0, 255,
         RowSpace::TOKEN, 0, 64, 64, Content::QKV_FINAL}};
    c = full_claim_qkv_pair(rt, pair);
    if (!c) { D2_FAIL_AT_SITE(observed, c, 2, true); return; }
    FullOwnerRecord first, second;
    Check c0 = full_owner_snapshot(rt, pair[0].ref, 0, first);
    Check c1 = full_owner_snapshot(rt, pair[1].ref, 0, second);
    if (!c0 || !c1 || first.state != CacheState::FILL ||
        second.state != CacheState::FILL || first.valid || second.valid ||
        rt.final_qkv_ref[0].id != Buffer::NONE ||
        rt.final_qkv_ref[1].id != Buffer::NONE || count_covered(rt) != 0) {
      D2_FAIL_AT_SITE(observed, protocol(command, OWNER_INVARIANT), 2, true);
      return;
    }
    for (unsigned i = 0; i < 64; ++i)
      if (first.covered_rows[i] || second.covered_rows[i]) {
        D2_FAIL_AT_SITE(observed, protocol(command, OWNER_INVARIANT), 2, true);
        return;
      }
    pending.valid = true;
    pending.ticket = ++ticket_counter;
    for (unsigned i = 0; i < 48; ++i)
      pending.metadata[i] = descriptor[i];
    pending.pair[0] = pair[0];
    pending.pair[1] = pair[1];
    report(observed, ok(), 1, true);
    return;
  }

  if (command != kRun) {
    D2_FAIL_AT_SITE(observed, protocol(command, BAD_DESCRIPTOR), 0, pending.valid);
    return;
  }
  if (!pending.valid) {
    D2_FAIL_AT_SITE(observed, protocol(command, NO_PENDING), 3, false);
    return;
  }
  Check c = descriptor_shape(descriptor, command);
  if (!c) { D2_FAIL_AT_SITE(observed, c, 3, true); return; }
  if (wide(descriptor, 8) != pending.ticket) {
    D2_FAIL_AT_SITE(observed, protocol(command, BAD_TICKET), 3, true);
    return;
  }
  if (descriptor[12] != pending.pair[0].ref.epoch ||
      descriptor[13] != pending.pair[1].ref.epoch) {
    D2_FAIL_AT_SITE(observed, protocol(command, BAD_EPOCH), 3, true);
    return;
  }
  for (unsigned i = 0; i < 48; ++i) {
    if (i == 2 || i == 8 || i == 9 || i == 12 || i == 13) continue;
    if (descriptor[i] != pending.metadata[i]) {
      D2_FAIL_AT_SITE(observed, protocol(command, BAD_METADATA), 3, true);
      return;
    }
  }
  c = descriptor_identity(descriptor, rt, command);
  if (!c) { D2_FAIL_AT_SITE(observed, c, 3, true); return; }

  for (unsigned plane = 0; plane < 3; ++plane)
    for (unsigned head = 0; head < 16; ++head) {
      const unsigned entry = plane * 16 + head;
      const uint64_t mask = wide(descriptor, kDescriptorMasks + 2 * entry);
      for (unsigned row = 0; row < 64 && c;) {
        if (!(mask & (uint64_t(1) << row))) { ++row; continue; }
        const unsigned first = row;
        do { ++row; } while (row < 64 && (mask & (uint64_t(1) << row)));
        c = full_cover_qkv(rt, pending.pair, uint8_t(plane),
                           uint8_t(head), 0, uint16_t(first),
                           uint16_t(row - first));
        if (!c) break;
      }
      if (!c) break;
    }
  if (!c) { D2_FAIL_AT_SITE(observed, c, 4, true); return; }
  c = full_publish_qkv_pair(rt, pending.pair);
  if (!c) { D2_FAIL_AT_SITE(observed, c, 5, true); return; }

  const uint8_t head = uint8_t(descriptor[44]);
  const uint16_t query = uint16_t(descriptor[45]);
  const FullOwnerSpec output{controller.fresh(Buffer::ATT_OUT), 0, 4, 0,
                             255, RowSpace::TOKEN, 0, 64, 1024,
                             Content::F32};
  c = full_claim_owner(rt, output);
  if (!c) { D2_FAIL_AT_SITE(observed, c, 6, true); return; }

  LoadTask kv{};
  kv.ctx = controller.context(Op::LOAD_KV, 4, 0, 0, RowSpace::BATCH, 0, 1);
  kv.kind = 1;
  kv.dst = controller.fresh(Buffer::KV);
  kv.head = head;
  kv.planes = 3;
  kv.byte_count = 2u * 64u * 64u * 4u;
  c = run_task(rt, memory, kv, kv.byte_count,
               OutputUnit::BYTES, observed[6]);
  if (!c) { D2_FAIL_AT_SITE(observed, c, 7, true); return; }

  QKTask qk{};
  qk.ctx = controller.context(Op::QK, 4, 0, 0,
                              RowSpace::TOKEN, query, 1);
  qk.qkv_ref = {pending.pair[0].ref, pending.pair[1].ref};
  qk.kv = kv.dst;
  qk.score = controller.fresh(Buffer::SCORE_PROB);
  qk.head = head; qk.mask_mode = 0; qk.S = 64;
  c = run_task(rt, memory, qk, 64, OutputUnit::F32,
               observed[kObsQkElements]);
  if (!c) { D2_FAIL_AT_SITE(observed, c, 8, true); return; }
  for (unsigned key = 0; key < 64; ++key)
    observed[16 + key] = numeric_f32_bits(full_cache_score(rt)[0][0][key]);

  const FullOwnerSpec score{qk.score, 0, 4, 0, 0,
                            RowSpace::TOKEN, query, 1, 64, Content::SCORE};
  FullOwnerSpec probability = score;
  probability.ref = controller.fresh(Buffer::SCORE_PROB);
  probability.content = Content::PROB;
  c = full_begin_inplace_owner(rt, score, probability);
  if (!c) { D2_FAIL_AT_SITE(observed, c, 9, true); return; }
  SoftmaxTask softmax{};
  softmax.ctx = controller.context(Op::SOFTMAX_ATT, 4, 0, 0,
                                   RowSpace::TOKEN, query, 1);
  softmax.src = score.ref;
  softmax.dst = probability.ref;
  softmax.length = 64;
  c = run_task(rt, memory, softmax, 64, OutputUnit::F32,
               observed[kObsSoftmaxElements]);
  if (!c) { D2_FAIL_AT_SITE(observed, c, 10, true); return; }
  for (unsigned key = 0; key < 64; ++key)
    observed[80 + key] = numeric_f32_bits(full_cache_score(rt)[0][0][key]);

  AVTask av{};
  av.ctx = controller.context(Op::AV, 4, 0, 0,
                              RowSpace::TOKEN, query, 1);
  av.prob = probability.ref;
  av.kv = kv.dst;
  av.partial = controller.fresh(Buffer::AV_PARTIAL);
  av.dst = output.ref;
  av.head = head; av.S = 64;
  c = run_task(rt, memory, av, 64, OutputUnit::F32,
               observed[kObsAvElements]);
  if (!c) { D2_FAIL_AT_SITE(observed, c, 11, true); return; }
  for (unsigned d = 0; d < 64; ++d) {
    Address address;
    c = full_f32_address(rt, memory, output.ref, 0, 0,
                         query, uint16_t(head * 64u + d), address);
    if (!c) { D2_FAIL_AT_SITE(observed, c, 12, true); return; }
    uint8_t raw[4];
    c = full_read(memory, address.bo, address.offset, raw, 4);
    if (!c) { D2_FAIL_AT_SITE(observed, c, 12, true); return; }
    observed[144 + d] = uint32_t(raw[0]) |
                        uint32_t(raw[1]) << 8 |
                        uint32_t(raw[2]) << 16 |
                        uint32_t(raw[3]) << 24;
  }
  Check partial_publish = full_publish_att(rt, output);
  observed[7] = uint32_t(partial_publish.code);
  observed[8] = partial_publish.detail;
  report(observed, ok(), 13, true);
  const Check cleanup = controller.invalidate_incomplete();
  observed[kObsCleanupStatus] = uint32_t(cleanup.code);
  observed[kObsCleanupDetail] = cleanup.detail;
  pending.valid = false;
}

#undef D2_FAIL_AT_SITE
