#include "laya_executor_cold_init.h"

#include <cstdint>
#include <cstring>
#include <fstream>
#include <iostream>
#include <map>
#include <new>
#include <stdexcept>
#include <string>
#include <type_traits>

// Independent defaults transcribed from the PASS executor_stream_host_03
// frozen laya_{types,tasks,numeric_tasks,task_reservation,full_runtime}.h.
// The runner verifies and archives those original declarations. No DUT
// constructor, encode function, object image or padding provides the gold.
namespace {
using namespace laya;
using namespace laya::full;

void require(bool okay, const char* name) {
  if (!okay) throw std::runtime_error(name);
}
struct Defaults {
  std::map<std::string, uint64_t> fields;
  uint64_t leaves = 0, nonzero = 0, allocator_domains = 0;
  void mark(const char* name) { fields.emplace(name, 0); }
  template<class T, class E> void one(const T& actual, const E& expected, const char* name) {
    mark(name); ++fields[name]; ++leaves;
    if (expected != E{}) ++nonzero;
    require(actual == expected, name);
  }
  template<class T> uint64_t zero_leaves(const T& value, const char* name) {
    if constexpr (std::is_array<T>::value) {
      uint64_t count = 0;
      for (const auto& element : value) count += zero_leaves(element, name);
      return count;
    } else {
      ++leaves;
      if constexpr (std::is_same<T, float>::value) {
        uint32_t bits = 1; static_assert(sizeof(bits) == sizeof(value));
        std::memcpy(&bits, &value, sizeof(bits));
        require(bits == 0, name); // ordinary +0.0, not an aggregate image
      } else require(value == T{}, name);
      return 1;
    }
  }
  template<class T, std::size_t N> uint64_t zero_leaves(const std::array<T, N>& value, const char* name) {
    uint64_t count = 0;
    for (const auto& element : value) count += zero_leaves(element, name);
    return count;
  }
  template<class T> void zeros(const T& value, const char* name) {
    mark(name); fields[name] += zero_leaves(value, name);
  }
};
#define ONE(Type, field, expected) d.one(x.field, expected, #Type "." #field)
#define ZERO(Type, field) d.zeros(x.field, #Type "." #field)
#define SUB(Type, field, function) d.mark(#Type "." #field); function(d, x.field)

void identity(Defaults& d, const NumericIdentity& x) {
  ONE(NumericIdentity, request_id, uint64_t(0)); ONE(NumericIdentity, generation, uint64_t(0));
  ONE(NumericIdentity, B, uint16_t(0)); ONE(NumericIdentity, S, uint16_t(0));
  ZERO(NumericIdentity, model_tag); ZERO(NumericIdentity, numeric_tag);
  ZERO(NumericIdentity, layout_tag); ZERO(NumericIdentity, build_tag);
}
void ref(Defaults& d, const BufferRef& x) {
  ONE(BufferRef, id, Buffer::NONE); ONE(BufferRef, bank, uint8_t(0)); ONE(BufferRef, epoch, uint32_t(0));
}
void key(Defaults& d, const WeightKey& x) {
  ONE(WeightKey, family, uint8_t(0)); ONE(WeightKey, layer, uint8_t(255));
}
void check(Defaults& d, const Check& x) {
  ONE(Check, code, Status::OK); ONE(Check, detail, uint32_t(0)); ONE(Check, bad_element, UINT64_MAX);
}
void context(Defaults& d, const TaskContext& x) {
  ONE(TaskContext, task_id, uint32_t(0)); ONE(TaskContext, op, Op::IO_VALIDATE);
  ONE(TaskContext, stage, uint8_t(0)); ONE(TaskContext, layer, uint8_t(255));
  ONE(TaskContext, batch, uint8_t(0)); ONE(TaskContext, row_space, RowSpace::TOKEN);
  ONE(TaskContext, row0, uint16_t(0)); ONE(TaskContext, rows, uint8_t(0));
}
void spec(Defaults& d, const FullOwnerSpec& x) {
  SUB(FullOwnerSpec, ref, ref); ONE(FullOwnerSpec, region, uint8_t(0));
  ONE(FullOwnerSpec, stage, uint8_t(0)); ONE(FullOwnerSpec, layer, uint8_t(255));
  ONE(FullOwnerSpec, batch, uint8_t(255)); ONE(FullOwnerSpec, row_space, RowSpace::TOKEN);
  ONE(FullOwnerSpec, row0, uint16_t(0)); ONE(FullOwnerSpec, rows, uint16_t(0));
  ONE(FullOwnerSpec, width, uint16_t(0)); ONE(FullOwnerSpec, content, Content::UNDEFINED);
}
void owner(Defaults& d, const FullOwnerRecord& x) {
  SUB(FullOwnerRecord, identity, identity); SUB(FullOwnerRecord, ref, ref);
  SUB(FullOwnerRecord, lease_old_ref, ref); ONE(FullOwnerRecord, max_claimed_epoch, uint32_t(0));
  ONE(FullOwnerRecord, region, uint8_t(0)); ONE(FullOwnerRecord, stage, uint8_t(0));
  ONE(FullOwnerRecord, layer, uint8_t(255)); ONE(FullOwnerRecord, batch, uint8_t(0));
  ONE(FullOwnerRecord, row_space, RowSpace::TOKEN); ONE(FullOwnerRecord, row0, uint16_t(0));
  ONE(FullOwnerRecord, rows, uint16_t(0)); ONE(FullOwnerRecord, width, uint16_t(0));
  ONE(FullOwnerRecord, content, Content::UNDEFINED); ONE(FullOwnerRecord, state, CacheState::INVALID);
  ONE(FullOwnerRecord, readers, uint8_t(0)); ZERO(FullOwnerRecord, covered_rows);
  ZERO(FullOwnerRecord, old_consumed_rows); ONE(FullOwnerRecord, valid, false);
}
void source_window(Defaults& d, const SourceWindowProvenance& x) {
  SUB(SourceWindowProvenance, close_context, context);
  SUB(SourceWindowProvenance, inherited_v_context, context);
  ONE(SourceWindowProvenance, component_mask, uint16_t(0));
  ONE(SourceWindowProvenance, close_valid, false); ONE(SourceWindowProvenance, inherited_v_valid, false);
}
void source(Defaults& d, const SourceProvenanceRecord& x) {
  SUB(SourceProvenanceRecord, identity, identity); SUB(SourceProvenanceRecord, owner, spec);
  d.mark("SourceProvenanceRecord.window"); unsigned windows = 0;
  for (const auto& w : x.window) { source_window(d, w); ++windows; }
  require(windows == 128, "source window capacity/range-for");
  d.mark("SourceProvenanceRecord.pair_ref"); for (const auto& r : x.pair_ref) ref(d, r);
  SUB(SourceProvenanceRecord, inherited_v_ref, ref); ONE(SourceProvenanceRecord, required_mask, uint16_t(0));
  ONE(SourceProvenanceRecord, valid, false); ONE(SourceProvenanceRecord, published, false);
  ONE(SourceProvenanceRecord, invalid, false); ONE(SourceProvenanceRecord, old_lease, false);
  ONE(SourceProvenanceRecord, inherits_v, false);
}
void f32(Defaults& d, const F32TileMeta& x) {
  SUB(F32TileMeta, identity, identity); SUB(F32TileMeta, ref, ref);
  ONE(F32TileMeta, region, uint8_t(0)); ONE(F32TileMeta, row_space, RowSpace::TOKEN);
  ONE(F32TileMeta, batch, uint8_t(0)); ONE(F32TileMeta, row0, uint16_t(0));
  ONE(F32TileMeta, rows, uint8_t(0)); ONE(F32TileMeta, K, uint16_t(0));
  ONE(F32TileMeta, state, CacheState::INVALID); ONE(F32TileMeta, content, Content::UNDEFINED);
  ONE(F32TileMeta, readers, uint8_t(0)); ZERO(F32TileMeta, covered_groups); ONE(F32TileMeta, valid, false);
}
void a8(Defaults& d, const A8TileMeta& x) {
  SUB(A8TileMeta, identity, identity); SUB(A8TileMeta, ref, ref); SUB(A8TileMeta, source, f32);
  SUB(A8TileMeta, source_context, context); SUB(A8TileMeta, quant_context, context);
  ONE(A8TileMeta, producer_task_id, uint32_t(0)); ONE(A8TileMeta, stage, uint8_t(0));
  ONE(A8TileMeta, layer, uint8_t(255)); ONE(A8TileMeta, row_space, RowSpace::TOKEN);
  ONE(A8TileMeta, batch, uint8_t(0)); ONE(A8TileMeta, row0, uint16_t(0));
  ONE(A8TileMeta, rows, uint8_t(0)); ONE(A8TileMeta, K, uint16_t(0)); ZERO(A8TileMeta, covered_groups);
  ONE(A8TileMeta, state, CacheState::INVALID); ONE(A8TileMeta, content, Content::UNDEFINED);
  ONE(A8TileMeta, readers, uint8_t(0)); ONE(A8TileMeta, valid, false);
}
void vector_task(Defaults& d, const VectorTask& x) {
  SUB(VectorTask, ctx, context); SUB(VectorTask, src0, ref); SUB(VectorTask, src1, ref);
  SUB(VectorTask, dst, ref); ONE(VectorTask, length, uint16_t(0));
  ONE(VectorTask, src0_region, uint8_t(0)); ONE(VectorTask, src1_region, uint8_t(0));
  ONE(VectorTask, dst_region, uint8_t(0)); ONE(VectorTask, bias_id, uint16_t(65535));
}
void quant(Defaults& d, const QuantTask& x) {
  SUB(QuantTask, ctx, context); SUB(QuantTask, src, ref); SUB(QuantTask, a_dst, ref);
  ONE(QuantTask, K, uint16_t(0)); ONE(QuantTask, src_region, uint8_t(0));
  ONE(QuantTask, input_lanes, uint8_t(8));
}
void linear(Defaults& d, const LinearTask& x) {
  SUB(LinearTask, ctx, context); SUB(LinearTask, a, ref); SUB(LinearTask, w, ref);
  SUB(LinearTask, ps, ref); SUB(LinearTask, dst, ref); SUB(LinearTask, weight, key);
  ONE(LinearTask, K, uint16_t(0)); ONE(LinearTask, N, uint16_t(0));
  ONE(LinearTask, dst_region, uint8_t(0)); ONE(LinearTask, bias_kind, uint8_t(0));
}
void load(Defaults& d, const LoadTask& x) {
  SUB(LoadTask, ctx, context); ONE(LoadTask, kind, uint8_t(0)); SUB(LoadTask, dst, ref);
  SUB(LoadTask, weight, key); ONE(LoadTask, head, uint8_t(255));
  ONE(LoadTask, planes, uint8_t(0)); ONE(LoadTask, byte_count, uint32_t(0));
}
void view(Defaults& d, const ViewTicket& x) {
  ONE(ViewTicket, generation, uint64_t(0)); ONE(ViewTicket, row_block, uint8_t(0));
  ONE(ViewTicket, rows, uint8_t(0));
}
void g_window(Defaults& d, const GDownWindow& x) {
  SUB(GDownWindow, producer, vector_task); SUB(GDownWindow, quant, quant); SUB(GDownWindow, linear, linear);
  ONE(GDownWindow, producer_generation, uint64_t(0)); ONE(GDownWindow, quant_generation, uint64_t(0));
  d.mark("GDownWindow.view"); for (const auto& v : x.view) view(d, v);
  ONE(GDownWindow, views, uint8_t(0)); ONE(GDownWindow, state, WindowState::CANCELED);
}
void allocator(Defaults& d, const TaskReservation& x) {
  // Private cursor fields are observed through their complete legal physical
  // domains and first-ticket behavior on small allocator copies, not bytes.
  d.one(x.task_high_water(0), uint32_t(0), "TaskReservation.task_floor");
  d.one(x.task_high_water(17), uint32_t(17), "TaskReservation.committed_task_floor");
  d.one(x.can_tasks(0, kMaxEpoch), true, "TaskReservation.task_capacity");
  d.one(x.can_tasks(kMaxEpoch, 1), false, "TaskReservation.task_overflow");
  auto tasks = x;
  d.one(tasks.context(0, Op::IO_VALIDATE, 0, 255, 0, RowSpace::BATCH, 0, 1).task_id,
        uint32_t(1), "TaskReservation.first_task");
  for (unsigned id = 1; id <= 43; ++id) {
    if (id > 11 && id < 32) continue;
    const unsigned banks = id == 1 || id == 5 || id >= 32 ? 2 : 1;
    const unsigned regions = id == 10 ? 8 : 1;
    for (unsigned bank = 0; bank < banks; ++bank) for (unsigned region = 0; region < regions; ++region) {
      const auto buffer = static_cast<Buffer>(id); ++d.allocator_domains;
      d.one(x.ref_high_water(buffer, uint8_t(bank), uint8_t(region), 0), uint32_t(0), "TaskReservation.ref_floor");
      d.one(x.ref_high_water(buffer, uint8_t(bank), uint8_t(region), 19), uint32_t(19), "TaskReservation.committed_ref_floor");
      d.one(x.can_refs(buffer, uint8_t(bank), uint8_t(region), 0, 1), true, "TaskReservation.ref_capacity");
      auto copy = x;
      const auto first = copy.ref(buffer, uint8_t(bank), uint8_t(region), 0);
      d.one(first.id, buffer, "TaskReservation.first_ref_id");
      d.one(first.bank, uint8_t(bank), "TaskReservation.first_ref_bank");
      d.one(first.epoch, uint32_t(1), "TaskReservation.first_ref_epoch");
    }
  }
  require(d.allocator_domains == 44, "all allocator physical domains");
}
void runtime_defaults(Defaults& d, const FullRuntime& x) {
#ifndef __SYNTHESIS__
  d.mark("FullRuntime.memory");
#define MEMORY(name) d.one(x.memory.name, nullptr, "FullMemory." #name); d.one(x.memory.name##_bytes, uint64_t(0), "FullMemory." #name "_bytes")
  MEMORY(embedding); MEMORY(io); MEMORY(w_q0); MEMORY(w_q1); MEMORY(w_scale); MEMORY(aux);
  MEMORY(state0); MEMORY(state1); MEMORY(qkv0); MEMORY(qkv1); MEMORY(ff0); MEMORY(ff1); MEMORY(att_out);
#undef MEMORY
#endif
  d.mark("FullRuntime.inputs"); identity(d, x.inputs.identity); d.mark("FullInputs.identity");
  d.zeros(x.inputs.token_ids, "FullInputs.token_ids"); d.zeros(x.inputs.marker_positions, "FullInputs.marker_positions");
  d.zeros(x.inputs.attention_mask, "FullInputs.attention_mask"); d.zeros(x.inputs.marker_mask, "FullInputs.marker_mask");
  d.zeros(x.inputs.qtype, "FullInputs.qtype");
  d.mark("FullRuntime.owners"); d.mark("FullOwners.record"); unsigned count = 0;
  for (const auto& o : x.owners.record) { owner(d, o); ++count; }
  require(count == 32, "owner capacity/range-for"); count = 0; d.mark("FullOwners.source");
  for (const auto& p : x.owners.source) { source(d, p); ++count; }
  require(count == 34, "source capacity/range-for");
  d.zeros(x.owners.qkv_plane_head_rows, "FullOwners.qkv_plane_head_rows");
  d.zeros(x.owners.qkv_rope_rows, "FullOwners.qkv_rope_rows"); d.zeros(x.owners.att_head_rows, "FullOwners.att_head_rows");
  d.zeros(x.owners.scorer_old_consumed, "FullOwners.scorer_old_consumed");
  d.zeros(x.owners.scorer_new_written, "FullOwners.scorer_new_written"); d.zeros(x.owners.type_valid, "FullOwners.type_valid");
  d.mark("FullRuntime.cache");
#ifndef __SYNTHESIS__
#define CACHE(name) d.zeros(x.cache.name, "FullCache." #name)
  CACHE(weight_q); CACHE(weight_scale); CACHE(weight_bias); CACHE(activation_q); CACHE(activation_scale);
  CACHE(input_tile); CACHE(ps_tile); CACHE(gamma); CACHE(rope_table); CACHE(kv); CACHE(score);
  CACHE(av_partial); CACHE(fp_act_weight);
#undef CACHE
#endif
  d.mark("FullCache.activation_source_ledger"); f32(d, x.cache.activation_source_ledger);
  d.mark("FullCache.activation_meta"); a8(d, x.cache.activation_meta);
  d.mark("FullRuntime.current_weight"); const auto& w = x.current_weight;
  d.zeros(w.name, "FullWeightDescriptor.name"); key(d, w.key); d.mark("FullWeightDescriptor.key");
#define WEIGHT(field) d.one(w.field, 0u, "FullWeightDescriptor." #field)
  WEIGHT(K); WEIGHT(N); WEIGHT(dtype); WEIGHT(bias_kind); WEIGHT(scale_base); WEIGHT(scale_span);
  WEIGHT(aux_base); WEIGHT(aux_span); WEIGHT(bias_base); WEIGHT(bias_span);
#undef WEIGHT
  d.zeros(w.q_base, "FullWeightDescriptor.q_base"); d.zeros(w.q_span, "FullWeightDescriptor.q_span");
  d.zeros(w.source_sha256, "FullWeightDescriptor.source_sha256"); d.zeros(w.bias_sha256, "FullWeightDescriptor.bias_sha256");
  SUB(FullRuntime, current_weight_ref, ref); d.mark("FullRuntime.loaded_gamma_ref");
  for (const auto& r : x.loaded_gamma_ref) ref(d, r);
  d.mark("FullRuntime.final_qkv_ref"); for (const auto& r : x.final_qkv_ref) ref(d, r);
  SUB(FullRuntime, loaded_kv_ref, ref); SUB(FullRuntime, loaded_rope_ref, ref);
  SUB(FullRuntime, score_ref, ref); SUB(FullRuntime, score_kv_ref, ref);
  d.mark("FullRuntime.score_qkv_ref"); for (const auto& r : x.score_qkv_ref) ref(d, r);
  ONE(FullRuntime, score_head, uint8_t(255)); ONE(FullRuntime, score_stage, uint8_t(0));
  ONE(FullRuntime, score_layer, uint8_t(255)); ONE(FullRuntime, score_batch, uint8_t(255));
  ONE(FullRuntime, score_rows, uint8_t(0)); ONE(FullRuntime, score_row0, uint16_t(0)); ONE(FullRuntime, score_valid, false);
  SUB(FullRuntime, expected_quant_source, spec); d.mark("FullRuntime.expected_task_source");
  for (const auto& s : x.expected_task_source) spec(d, s);
  ONE(FullRuntime, expected_task_source_count, uint8_t(0)); ONE(FullRuntime, loaded_rope_mode, uint8_t(255));
  ONE(FullRuntime, loaded_kv_head, uint8_t(255)); SUB(FullRuntime, dispatch_reservations, allocator);
  d.mark("FullRuntime.portal_reservations"); d.one(x.portal_reservations.high_water(), uint64_t(0), "PortalReservation.high_water");
  auto portal = x.portal_reservations; d.one(portal.next(), uint64_t(1), "PortalReservation.first_ticket");
  ONE(FullRuntime, dispatch_command_generation, uint64_t(0)); ONE(FullRuntime, provenance_event_high_water, uint64_t(0));
  ONE(FullRuntime, producer_request_high_water, uint64_t(0)); ONE(FullRuntime, defer_task_retirement, false);
  d.mark("FullRuntime.generated_store"); const auto& g = x.generated_store;
  d.mark("GeneratedStoreTracker.geometry");
  for (const auto& v : g.geometry) {
    d.one(v.role, Bo::IO, "Geometry.role"); d.one(v.first_offset, uint64_t(0), "Geometry.first_offset");
    d.one(v.segment_bytes, uint32_t(0), "Geometry.segment_bytes"); d.one(v.row_count, uint16_t(0), "Geometry.row_count");
    d.one(v.repeat_count, uint16_t(0), "Geometry.repeat_count"); d.one(v.row_step, uint64_t(0), "Geometry.row_step");
    d.one(v.repeat_step, uint64_t(0), "Geometry.repeat_step");
  }
  d.zeros(g.issued_bytes, "GeneratedStoreTracker.issued_bytes"); spec(d, g.source_lease); d.mark("GeneratedStoreTracker.source_lease");
  d.one(g.descriptor_count, uint8_t(0), "GeneratedStoreTracker.descriptor_count");
  d.one(g.active, false, "GeneratedStoreTracker.active"); d.one(g.source_lease_active, false, "GeneratedStoreTracker.source_lease_active");
  check(d, g.first_error); d.mark("GeneratedStoreTracker.first_error");
  d.mark("FullRuntime.lifecycle_action"); const auto& a = x.lifecycle_action;
  identity(d, a.identity); spec(d, a.source); spec(d, a.output); check(d, a.first_error);
  d.mark("LifecycleActionTracker.identity"); d.mark("LifecycleActionTracker.source");
  d.mark("LifecycleActionTracker.output"); d.mark("LifecycleActionTracker.first_error");
#define ACTION(field) d.one(a.field, 0u, "LifecycleActionTracker." #field)
  ACTION(ordinal); ACTION(source_version); ACTION(target_slot_version); ACTION(begin_event_seq);
  ACTION(request_flags); ACTION(previous_task_id); ACTION(previous_tasks_retired); ACTION(kind); ACTION(pc); ACTION(op); ACTION(stage);
  d.one(a.layer, uint8_t(255), "LifecycleActionTracker.layer");
  ACTION(source_slot); ACTION(target_slot); ACTION(target_buffer); ACTION(target_bank); ACTION(target_region); ACTION(gamma);
  ACTION(active); ACTION(owner_local_claimed); ACTION(claim_sent); ACTION(claim_remote_terminal); ACTION(publish_sent);
  ACTION(publish_remote_terminal); ACTION(begin_response_bound); ACTION(begin_scope_active); ACTION(source_release_pending);
  ACTION(cleanup_pending); ACTION(cleanup_remote_terminal); ACTION(cleanup_local_complete);
#undef ACTION
  d.mark("FullRuntime.g_down_plan"); identity(d, x.g_down_plan.identity); d.mark("GDownPlan.identity");
  d.mark("GDownPlan.window"); count = 0; for (const auto& v : x.g_down_plan.window) { g_window(d, v); ++count; }
  require(count == 128, "GDown capacity/range-for"); load(d, x.g_down_plan.load); d.mark("GDownPlan.load");
  d.one(x.g_down_plan.load_generation, uint64_t(0), "GDownPlan.load_generation");
  d.one(x.g_down_plan.count, uint16_t(0), "GDownPlan.count"); d.one(x.g_down_plan.valid, false, "GDownPlan.valid");
  d.mark("FullRuntime.dispatch_binding"); const auto& b = x.dispatch_binding;
  context(d, b.producer_context); quant(d, b.quant); linear(d, b.linear);
  d.mark("DispatchBinding.producer_context"); d.mark("DispatchBinding.quant"); d.mark("DispatchBinding.linear");
  d.one(b.quant_generation, uint64_t(0), "DispatchBinding.quant_generation"); d.mark("DispatchBinding.view");
  for (const auto& v : b.view) view(d, v);
  d.one(b.views, uint8_t(0), "DispatchBinding.views"); d.one(b.valid, false, "DispatchBinding.valid");
  ONE(FullRuntime, last_task_id, uint32_t(0)); ONE(FullRuntime, tasks_retired, uint32_t(0));
  d.mark("FullRuntime.checkpoint_baseline"); const auto& c = x.checkpoint_baseline;
  identity(d, c.identity); spec(d, c.source); d.mark("CheckpointBaseline.identity"); d.mark("CheckpointBaseline.source");
  d.zeros(c.model_identity, "CheckpointBaseline.model_identity");
#define BASE(field) d.one(c.field, 0u, "CheckpointBaseline." #field)
  BASE(snapshot_sequence); BASE(handoff_epoch); BASE(base_epoch); BASE(base_address); BASE(base_capacity);
  BASE(lpv_floor); BASE(task_base); BASE(local_retired_at_import); BASE(target_epoch_floor); BASE(valid);
#undef BASE
  ZERO(FullRuntime, op_calls); ONE(FullRuntime, owner_claims, uint32_t(0)); ONE(FullRuntime, owner_leases, uint32_t(0));
  ONE(FullRuntime, encoder_layers_completed, uint8_t(0)); ONE(FullRuntime, decision_layers_completed, uint8_t(0));
  ONE(FullRuntime, session_generation, uint64_t(0)); ONE(FullRuntime, last_accepted_request_id, uint64_t(0));
  ONE(FullRuntime, diagnostic_request_id, uint64_t(0)); ONE(FullRuntime, diagnostic_generation, uint64_t(0));
  ONE(FullRuntime, diagnostic_B, uint16_t(0)); ONE(FullRuntime, diagnostic_S, uint16_t(0));
  ONE(FullRuntime, diagnostic_identity_valid, false); ONE(FullRuntime, diagnostic_shape_valid, false);
  SUB(FullRuntime, last_execution_error, check); SUB(FullRuntime, last_cleanup_error, check); SUB(FullRuntime, last_commit_error, check);
  ONE(FullRuntime, request_valid, false); ONE(FullRuntime, model_header_valid, false); ONE(FullRuntime, expected_quant_source_valid, false);
  d.mark("FullRuntime.cpu_import"); const auto& i = x.cpu_import;
#define IMPORT(field) d.one(i.field, 0u, "CpuImportDiagnostic." #field)
  IMPORT(descriptor_valid); IMPORT(admitted); IMPORT(imports_started); IMPORT(imports_committed);
  IMPORT(raw_verified); IMPORT(scan_complete); IMPORT(cleanup_attempted); IMPORT(cleanup_completed);
  IMPORT(request_crc_valid); IMPORT(descriptor_crc_valid); IMPORT(expected_raw_crc); IMPORT(actual_raw_crc);
  IMPORT(raw_bytes_scanned); IMPORT(raw_elements_scanned); IMPORT(import_rows_covered);
  d.one(i.descriptor_error_offset, UINT32_MAX, "CpuImportDiagnostic.descriptor_error_offset");
  d.one(i.import_bad_element, UINT64_MAX, "CpuImportDiagnostic.import_bad_element");
  IMPORT(reached_phase); IMPORT(first_error_stage); IMPORT(first_error_operator); IMPORT(first_error_task_id);
  IMPORT(expected_request_crc); IMPORT(actual_request_crc); IMPORT(expected_descriptor_crc); IMPORT(actual_descriptor_crc);
#undef IMPORT
#ifndef __SYNTHESIS__
  ONE(FullRuntime, checkpoint, nullptr); ONE(FullRuntime, checkpoint_user, nullptr);
#endif
}

struct RuntimeStorage {
  void* storage = ::operator new(sizeof(FullRuntime), std::align_val_t(alignof(FullRuntime)));
  FullRuntime* value = nullptr;
  RuntimeStorage(bool cold, unsigned char fill) {
    // Fill raw allocated storage before any object exists. No completed or
    // inactive typed member is read through bytes or compared as an image.
    auto* bytes = static_cast<unsigned char*>(storage);
    for (std::size_t i = 0; i < sizeof(FullRuntime); ++i) bytes[i] = fill;
    value = cold ? ::new (storage) FullRuntime(ColdInitTag{}) : ::new (storage) FullRuntime();
  }
  ~RuntimeStorage() { if (value) value->~FullRuntime(); ::operator delete(storage, std::align_val_t(alignof(FullRuntime))); }
  RuntimeStorage(const RuntimeStorage&) = delete;
  RuntimeStorage& operator=(const RuntimeStorage&) = delete;
};
void copy_compatibility(const FullRuntime& rt) {
  auto owner_table = rt.owners.record;
  owner_table[31].max_claimed_epoch = 19;
  require(rt.owners.record[31].max_claimed_epoch == 0, "independent owner cell copy");
  auto source_copy = rt.owners.source[33];
  source_copy.window[127].close_context.task_id = 73;
  SourceProvenanceRecord destination; destination = source_copy;
  require(destination.window[127].close_context.task_id == 73 &&
          rt.owners.source[33].window[127].close_context.task_id == 0, "nested source table value-copy assignment");
  auto plan_copy = rt.g_down_plan;
  plan_copy.window[127].producer.bias_id = 9; plan_copy.window[127].view[5].generation = 81;
  GDownPlan plan_destination; plan_destination = plan_copy;
  require(plan_destination.window[127].producer.bias_id == 9 && plan_destination.window[127].view[5].generation == 81 &&
          rt.g_down_plan.window[127].producer.bias_id == 65535 && rt.g_down_plan.window[127].view[5].generation == 0,
          "nested GDown table value-copy assignment");
}
#undef ONE
#undef ZERO
#undef SUB
} // namespace

int main(int argc, char** argv) {
  try {
    require(argc == 2, "one output JSON path required");
    static_assert(kColdInitMaxSteps == 15810, "frozen complete initialization extent");
    static_assert(uint8_t(Op::IO_VALIDATE) == 0x84 && uint8_t(CacheState::INVALID) == 6 &&
                  uint8_t(WindowState::CANCELED) == 4 && uint8_t(Bo::IO) == 1,
                  "original frozen nonzero enum defaults");
    RuntimeStorage ordinary(false, 0x5a), cold(true, 0xa5);
    ColdInitCursor cursor;
    require(cursor.phase == ColdInitPhase::OWNERS && cursor.index == 0 && cursor.steps == 0 && !cursor.done,
            "typed cursor defaults");
    const unsigned extents[] = {32, 34, 4352, 6144, 4096, 1024, 128};
    const ColdInitPhase phases[] = {ColdInitPhase::OWNERS, ColdInitPhase::SOURCES, ColdInitPhase::SOURCE_WINDOWS,
      ColdInitPhase::QKV_ROWS, ColdInitPhase::ROPE_ROWS, ColdInitPhase::ATT_ROWS, ColdInitPhase::G_DOWN_WINDOWS};
    unsigned total = 0;
    for (unsigned phase = 0; phase < 7; ++phase) for (unsigned cell = 0; cell < extents[phase]; ++cell) {
      require(!cursor.done && cursor.phase == phases[phase] && cursor.index == cell && cursor.steps == total,
              "exact pre-step phase/index/no-early-done");
      // Never inspect or copy any cold table until all typed cells are live.
      cold_init_step(*cold.value, cursor); ++total;
      require(cursor.steps == total && cursor.done == (total == 15810), "exact step count and final done");
      if (total % 1024 == 0 || cell + 1 == extents[phase])
        std::cout << "FULL_CURRENT_EXECUTOR_COLD_INIT_PROGRESS steps=" << total << " phase=" << phase << '\n';
    }
    require(cursor.phase == ColdInitPhase::DONE && cursor.index == 0 && cursor.steps == 15810 && cursor.done,
            "all cells complete before FIRST eligibility");
    Defaults expected, actual; runtime_defaults(expected, *ordinary.value); runtime_defaults(actual, *cold.value);
    require(expected.fields == actual.fields && expected.leaves == actual.leaves && expected.nonzero == actual.nonzero,
            "complete ordinary/cold semantic field and leaf-set equality");
    for (unsigned step = 0; step < 17; ++step) cold_init_step(*cold.value, cursor);
    require(cursor.phase == ColdInitPhase::DONE && cursor.index == 0 && cursor.steps == 15810 && cursor.done,
            "completed initialization cursor is idempotent");
    Defaults after; runtime_defaults(after, *cold.value);
    require(after.fields == actual.fields && after.leaves == actual.leaves && after.nonzero == actual.nonzero,
            "post-done complete semantic state is unchanged");
    copy_compatibility(*cold.value);
#ifdef __SYNTHESIS__
    const char* profile = "synthesis_metadata";
#else
    const char* profile = "host";
#endif
    std::ofstream report(argv[1]); require(bool(report), "open semantic evidence");
    report << "{\n  \"profile\":\"" << profile << "\",\n  \"steps\":15810,\n  \"extra_noop_calls\":17,\n"
           << "  \"ordinary_and_cold_gold_match\":true,\n  \"padding_compared\":false,\n  \"inactive_tables_read\":false,\n"
           << "  \"scalar_leaf_checks_per_complete_state\":" << actual.leaves
           << ",\n  \"nonzero_expected_value_checks\":" << actual.nonzero
           << ",\n  \"allocator_physical_domains\":" << actual.allocator_domains
           << ",\n  \"field_set\":{\n";
    bool comma = false;
    for (const auto& entry : actual.fields) {
      if (comma) report << ",\n";
      report << "    \"" << entry.first << "\":" << entry.second; comma = true;
    }
    report << "\n  }\n}\n"; report.close();
    std::cout << "FULL_CURRENT_EXECUTOR_COLD_INIT_HOST_PASS profile=" << profile << " steps=15810 extra_noop_calls=17"
              << " fields=" << actual.fields.size() << " leaves=" << actual.leaves << " nonzero=" << actual.nonzero
              << " allocator_domains=" << actual.allocator_domains
              << " frozen_literal_defaults=1 all_arrays=1 float_scalar_bits=1 no_padding=1 inactive_read=0"
              << " table_copy_compatibility=1 FIRST_actor_top_HLS_RTL_NOT_RUN=1\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "FULL_CURRENT_EXECUTOR_COLD_INIT_HOST_FAIL " << error.what() << '\n';
    return 1;
  }
}
