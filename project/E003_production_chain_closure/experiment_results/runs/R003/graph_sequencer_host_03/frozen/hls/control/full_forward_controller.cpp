#include "laya_full_runtime.h"
#include "laya_compute_portal_commit.h"
#include "laya_compute_portal_controller.h"
#include "laya_controller_transaction_dispatch.h"
#include "laya_generated_provenance_events.h"
#include "laya_producer_engine_client.h"
#include "laya_producer_engine_hls.h"

namespace laya::full {
namespace {

bool same_context(const TaskContext& a, const TaskContext& b) {
  return a.task_id == b.task_id && a.op == b.op && a.stage == b.stage &&
         a.layer == b.layer && a.batch == b.batch &&
         a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows;
}

Check check_activation_binding(const FullRuntime& rt,
                               const LinearTask& task) {
  if (!rt.dispatch_binding.valid) return ok();
  const DispatchBinding& binding = rt.dispatch_binding;
  const A8TileMeta& a = rt.cache.activation_meta;
  if (!a.valid || a.state != CacheState::READY || a.ref != task.a ||
      !same_context(binding.producer_context, a.source_context) ||
      !same_context(binding.quant.ctx, a.quant_context) ||
      !same_context(binding.linear.ctx, task.ctx) ||
      binding.quant.src != a.source.ref ||
      binding.quant.src_region != a.source.region ||
      binding.quant.a_dst != task.a || binding.linear.a != task.a)
    return {Status::E_PROTOCOL, detail(7, uint8_t(task.ctx.op), 14)};
  return ok();
}

template<class T>
Check record_source_completion(FullRuntime&, const T&, const TaskDone&,
                               uint32_t, OutputUnit) {
  return ok();
}

Check record_source_completion(FullRuntime& rt, const LayerNormTask& task,
                               const TaskDone& done, uint32_t elements,
                               OutputUnit unit) {
  const uint8_t region = task.ctx.op == Op::LN_MARKER ?
                         uint8_t(Region::SCORER_ACT) : 0;
  return full_source_accept_completion(rt, task.dst, region, task.ctx, 0, 1,
                                       done, elements, unit);
}

Check record_source_completion(FullRuntime& rt, const VectorTask& task,
                               const TaskDone& done, uint32_t elements,
                               OutputUnit unit) {
  return full_source_accept_completion(rt, task.dst, task.dst_region,
                                       task.ctx, 0, 1, done, elements, unit);
}

Check record_source_completion(FullRuntime& rt, const LinearTask& task,
                               const TaskDone& done, uint32_t elements,
                               OutputUnit unit) {
  if (task.ctx.op == Op::LIN_QKV) {
    const Content content = task.ctx.stage == 4 ? Content::QKV_FINAL :
                                                  Content::QKV_RAW;
    FullOwnerSpec pair[2] = {
        {task.dst, 0, task.ctx.stage, task.ctx.layer, 255,
         RowSpace::TOKEN, 0, rt.inputs.identity.S, 64, content},
        {task.dst, 0, task.ctx.stage, task.ctx.layer, 255,
         RowSpace::TOKEN, 0, rt.inputs.identity.S, 64, content}};
    pair[1].ref.bank = 1;
    return full_source_accept_qkv_completion(rt, pair, task.ctx, done);
  }
  return full_source_accept_completion(rt, task.dst, task.dst_region,
                                       task.ctx, 0, 1, done, elements, unit);
}

[[maybe_unused]] Check record_source_completion(FullRuntime& rt,
                               const RopeTask& task,
                               const TaskDone& done, uint32_t,
                               OutputUnit) {
  FullOwnerSpec pair[2] = {
      {task.dst_qkv_ref[0], 0, 2, task.ctx.layer, 255,
       RowSpace::TOKEN, 0, rt.inputs.identity.S, 64, Content::QKV_FINAL},
      {task.dst_qkv_ref[1], 0, 2, task.ctx.layer, 255,
       RowSpace::TOKEN, 0, rt.inputs.identity.S, 64, Content::QKV_FINAL}};
  return full_source_accept_rope_completion(rt, pair, task.ctx, task.head,
                                            done);
}

[[maybe_unused]] Check record_source_completion(FullRuntime& rt,
                               const AVTask& task,
                               const TaskDone& done, uint32_t elements,
                               OutputUnit unit) {
  return full_source_accept_completion(rt, task.dst, 0, task.ctx, task.head,
                                       UINT16_MAX, done, elements, unit);
}

Check record_source_completion(FullRuntime& rt, const QuantTask& task,
                               const TaskDone&, uint32_t, OutputUnit) {
  const DispatchBinding& binding = rt.dispatch_binding;
  A8TileMeta& a = rt.cache.activation_meta;
  if (!binding.valid || !same_context(binding.quant.ctx, task.ctx) ||
      binding.producer_context.task_id >= task.ctx.task_id ||
      !a.valid || a.state != CacheState::READY || a.ref != task.a_dst ||
      !numeric_identity_equal(a.identity, rt.inputs.identity))
    return {Status::E_PROTOCOL, detail(7, uint8_t(Op::QUANT), 14)};
  a.source_context = binding.producer_context;
  a.quant_context = task.ctx;
  return ok();
}

#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
struct PortalEndpoint {
  hls::stream<ap_uint<512>>* command = nullptr;
  hls::stream<ap_uint<512>>* response = nullptr;
  hls::stream<ap_uint<512>>* provenance_command = nullptr;
  hls::stream<ap_uint<512>>* provenance_response = nullptr;
  hls::stream<ap_uint<512>>* producer_request = nullptr;
  hls::stream<ap_uint<512>>* producer_completion = nullptr;
  portal::ModelBinding model;
  bool valid = false;
};

#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
enum class GraphActionKind : uint8_t {
  EMBED = 0,
  LOAD_GAMMA = 1,
  NORM = 2,
  RELEASE = 3,
  LINEAR = 4,
  ATTENTION = 5,
  RESIDUAL = 6,
  GEGLU_DOWN = 7,
  TYPE_ADD = 8,
  TRANSFORM = 9,
  GATHER = 10,
  LOOKUP_BIAS = 11,
  FP_LINEAR = 12,
  CANDIDATE_MASKED = 13,
  CANDIDATE_PROBABILITY = 14,
  CANDIDATE_STATISTICS = 15,
  ACT_CONCAT = 16,
};

enum GraphSlot : uint8_t {
  SLOT_HIDDEN = 0,
  SLOT_NORMALIZED,
  SLOT_QKV_PRIMARY,
  SLOT_ATTENDED,
  SLOT_PROJECTED,
  SLOT_WIDE,
  SLOT_DOWN,
  SLOT_FC1,
  SLOT_RELU,
  SLOT_FC2,
  SLOT_MARKERS,
  SLOT_MARKER_NORM,
  SLOT_SCORER_BAKED,
  SLOT_SCORER_HIDDEN,
  SLOT_RAW,
  SLOT_CANDIDATE,
  SLOT_PROBABILITY,
  SLOT_STATS,
  SLOT_ACT_INPUT,
  SLOT_ACT_DOT,
  SLOT_ACT_HIDDEN,
  SLOT_ACT_OUTPUT,
  SLOT_COUNT,
};

struct GraphAction {
  GraphActionKind kind = GraphActionKind::EMBED;
  Op op = Op::IO_VALIDATE;
  WeightKey weight{};
  uint8_t src = SLOT_HIDDEN;
  uint8_t dst = SLOT_HIDDEN;
  uint8_t stage = 0;
  uint8_t layer = 255;
  Buffer dst_buffer = Buffer::NONE;
  uint8_t dst_bank = 0;
  uint8_t dst_region = 0;
  uint8_t gamma = 0;
  uint16_t length = 0;
  uint16_t K = 0;
  uint16_t N = 0;
  bool qkv = false;
  bool inplace = false;
  uint8_t bias = 0;
};

struct GraphState {
  FullOwnerSpec slot[SLOT_COUNT]{};
  FullOwnerSpec qkv[2]{};
  uint16_t bias_id[2] = {65535, 65535};
};

#ifdef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
#define LAYA_PARTITIONED_IO_PARAMETERS                                      \
  hls::stream<ap_uint<512>>& transaction_request_stream,                    \
  hls::stream<ap_uint<512>>& transaction_completion_stream,                 \
  const portal::ModelBinding& portal_model, bool portal_available,          \
  bool provenance_available, bool producer_available
#define LAYA_PARTITIONED_IO_APPEND_PARAMETERS , LAYA_PARTITIONED_IO_PARAMETERS
#define LAYA_PARTITIONED_IO_ARGUMENTS                                      \
  transaction_request_stream, transaction_completion_stream, portal_model, \
  portal_available, provenance_available, producer_available
#define LAYA_PARTITIONED_IO_APPEND_ARGUMENTS , LAYA_PARTITIONED_IO_ARGUMENTS
#define LAYA_TRANSACTION_REQUEST_STREAM transaction_request_stream
#define LAYA_TRANSACTION_COMPLETION_STREAM transaction_completion_stream
#define LAYA_PARTITIONED_STREAMS_UNUSED                                    \
  (void)transaction_request_stream; (void)transaction_completion_stream
#else
#define LAYA_PARTITIONED_IO_PARAMETERS                                      \
  hls::stream<ap_uint<512>>& command_stream,                               \
  hls::stream<ap_uint<512>>& response_stream,                              \
  hls::stream<ap_uint<512>>& provenance_command_stream,                    \
  hls::stream<ap_uint<512>>& provenance_response_stream,                   \
  hls::stream<ap_uint<512>>& producer_request_stream,                      \
  hls::stream<ap_uint<512>>& producer_completion_stream,                   \
  const portal::ModelBinding& portal_model, bool portal_available,         \
  bool provenance_available, bool producer_available
#define LAYA_PARTITIONED_IO_APPEND_PARAMETERS , LAYA_PARTITIONED_IO_PARAMETERS
#define LAYA_PARTITIONED_IO_ARGUMENTS                                      \
  command_stream, response_stream, provenance_command_stream,              \
  provenance_response_stream, producer_request_stream,                     \
  producer_completion_stream, portal_model, portal_available,              \
  provenance_available, producer_available
#define LAYA_PARTITIONED_IO_APPEND_ARGUMENTS , LAYA_PARTITIONED_IO_ARGUMENTS
#define LAYA_PORTAL_COMMAND_STREAM command_stream
#define LAYA_PORTAL_RESPONSE_STREAM response_stream
#define LAYA_PROVENANCE_COMMAND_STREAM provenance_command_stream
#define LAYA_PROVENANCE_RESPONSE_STREAM provenance_response_stream
#define LAYA_PRODUCER_REQUEST_STREAM producer_request_stream
#define LAYA_PRODUCER_COMPLETION_STREAM producer_completion_stream
#define LAYA_PARTITIONED_STREAMS_UNUSED                                    \
  (void)command_stream; (void)response_stream;                             \
  (void)provenance_command_stream; (void)provenance_response_stream;       \
  (void)producer_request_stream; (void)producer_completion_stream
#endif
#define LAYA_PORTAL_MODEL portal_model
#define LAYA_DEFAULT_OUTPUT_UNIT(value)
#else
#define LAYA_PARTITIONED_IO_PARAMETERS
#define LAYA_PARTITIONED_IO_APPEND_PARAMETERS
#define LAYA_PARTITIONED_IO_ARGUMENTS
#define LAYA_PARTITIONED_IO_APPEND_ARGUMENTS
#define LAYA_PORTAL_COMMAND_STREAM (*portal_endpoint->command)
#define LAYA_PORTAL_RESPONSE_STREAM (*portal_endpoint->response)
#define LAYA_PROVENANCE_COMMAND_STREAM (*portal_endpoint->provenance_command)
#define LAYA_PROVENANCE_RESPONSE_STREAM (*portal_endpoint->provenance_response)
#define LAYA_PRODUCER_REQUEST_STREAM (*portal_endpoint->producer_request)
#define LAYA_PRODUCER_COMPLETION_STREAM (*portal_endpoint->producer_completion)
#define LAYA_PORTAL_MODEL (portal_endpoint->model)
#define LAYA_DEFAULT_OUTPUT_UNIT(value) = value
#endif
#endif

#ifndef LAYA_PARTITIONED_IO_PARAMETERS
#define LAYA_PARTITIONED_IO_PARAMETERS
#define LAYA_PARTITIONED_IO_APPEND_PARAMETERS
#define LAYA_PARTITIONED_IO_ARGUMENTS
#define LAYA_PARTITIONED_IO_APPEND_ARGUMENTS
#define LAYA_DEFAULT_OUTPUT_UNIT(value) = value
#endif

struct Controller {
  FullRuntime& rt;
  FullMemory& memory;
  uint8_t error_stage = 0, error_op = 0;
  uint32_t error_task_id = 0;
  uint8_t current_stage = 0, current_op = 0;
#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
  PortalEndpoint* portal_endpoint = nullptr;
#endif

  void phase(uint8_t stage, Op op) {
    current_stage = stage;
    current_op = uint8_t(op);
  }

  bool physical(const FullOwnerRecord& r, Buffer id,
                uint8_t bank, uint8_t region) const {
    if (r.ref.id == Buffer::NONE || r.region != region) return false;
    if (id == Buffer::ROPE_TABLE && r.ref.id == id) return true;
    if (r.ref.bank != bank) return false;
    if (r.ref.id == id) return true;
    return (id == Buffer::WI && r.ref.id == Buffer::DEC_FF) ||
           (id == Buffer::DEC_FF && r.ref.id == Buffer::WI);
  }
  uint32_t committed_epoch(Buffer id, uint8_t bank = 0, uint8_t region = 0) const {
    for (unsigned i = 0; i < 32; ++i) {
      const FullOwnerRecord& record = rt.owners.record[i];
      if (physical(record, id, bank, region))
        return record.max_claimed_epoch;
    }
    return 0;
  }
  BufferRef fresh(Buffer id, uint8_t bank = 0, uint8_t region = 0) {
    return rt.dispatch_reservations.ref(id, bank, region, committed_epoch(id, bank, region));
  }
  TaskContext context(Op op, uint8_t stage, uint8_t layer,
                      uint8_t batch, RowSpace space,
                      uint16_t row0, uint8_t rows) {
    return rt.dispatch_reservations.context(rt.last_task_id, op, stage, layer, batch, space, row0, rows);
  }
  template<class T>
  Check finish_issue(const T& task, Check c, const TaskDone& done,
                     uint32_t elements, OutputUnit unit) {
    Check completion = check_done(done, task.ctx.task_id, elements, unit);
    if (completion && done.status != c.code)
      completion = {Status::E_INTERNAL,
                    detail(7, uint8_t(task.ctx.op), 14)};
    if (completion && c) {
      Check provenance = record_source_completion(rt, task, done,
                                                  elements, unit);
      if (!provenance) completion = provenance;
    }
    if (!completion || !c) {
      error_stage = task.ctx.stage;
      error_op = uint8_t(task.ctx.op);
      error_task_id = task.ctx.task_id;
    }
    return completion ? c : completion;
  }
#if defined(LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM) && \
    defined(LAYA_PARTITIONED_PRODUCTION_CALLER)
  template<class T>
  Check partitioned_direct_issue(const T& task, uint32_t, OutputUnit
                                 LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#pragma HLS inline off
    LAYA_PARTITIONED_STREAMS_UNUSED;
    (void)portal_model; (void)portal_available;
    (void)provenance_available; (void)producer_available;
    // A family without a generated engine must fail before reserving a
    // provenance sequence or constructing a frame that can never be sent.
    return fail_issue(task, {Status::E_PROTOCOL,
                             detail(7, uint8_t(task.ctx.op), 5)});
  }
  Check partitioned_direct_issue(const LayerNormTask& task,
                                 uint32_t elements, OutputUnit unit
                                 LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#pragma HLS inline off
    if (!provenance_available)
      return fail_issue(task, {Status::E_PROTOCOL,
                               detail(7, uint8_t(task.ctx.op), 5)});
    provenance::Request begin;
    bool protected_task = false;
    Check built = provenance::build_generated_begin(
        rt, memory, portal_model, task, elements, unit,
        begin, protected_task);
    if (!built) return fail_issue(task, built);
    if (!protected_task)
      return fail_issue(task, {Status::E_PROTOCOL,
                               detail(7, uint8_t(task.ctx.op), 5)});
    return provenance_issue(task, elements, unit, begin
                            LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
  }
#endif
  template<class T>
  Check direct_issue(const T& task, uint32_t elements,
                     OutputUnit unit LAYA_DEFAULT_OUTPUT_UNIT(OutputUnit::F32)
                     LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
    phase(task.ctx.stage, task.ctx.op);
#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
    return partitioned_direct_issue(task, elements, unit
                                    LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
#else
    if (provenance_ready()) {
      provenance::Request begin;
      bool protected_task = false;
      Check built = provenance::build_generated_begin(
          rt, memory, portal_endpoint->model, task, elements, unit,
          begin, protected_task);
      if (!built) return fail_issue(task, built);
      if (protected_task)
        return provenance_issue(task, elements, unit, begin);
    }
#endif
#endif
#ifndef LAYA_PARTITIONED_PRODUCTION_CALLER
    TaskDone done;
    Check c = full_run_task(rt, memory, task, done);
    return finish_issue(task, c, done, elements, unit);
#else
    return fail_issue(task, {Status::E_PROTOCOL,
                             detail(7, uint8_t(task.ctx.op), 5)});
#endif
  }
  template<class T>
  Check issue(const T& task, uint32_t elements,
              OutputUnit unit LAYA_DEFAULT_OUTPUT_UNIT(OutputUnit::F32)
              LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
    return direct_issue(task, elements, unit
                        LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
  }
#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
  bool portal_ready(LAYA_PARTITIONED_IO_PARAMETERS) const {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
    LAYA_PARTITIONED_STREAMS_UNUSED;
    (void)portal_model; (void)provenance_available;
    (void)producer_available;
    return portal_available;
#else
    return portal_endpoint && portal_endpoint->valid &&
           portal_endpoint->command && portal_endpoint->response;
#endif
  }
  bool provenance_ready(LAYA_PARTITIONED_IO_PARAMETERS) const {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
    LAYA_PARTITIONED_STREAMS_UNUSED;
    (void)portal_model; (void)portal_available; (void)producer_available;
    return provenance_available;
#else
    return portal_endpoint && portal_endpoint->valid &&
           portal_endpoint->provenance_command &&
           portal_endpoint->provenance_response;
#endif
  }
  bool producer_ready(LAYA_PARTITIONED_IO_PARAMETERS) const {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
    LAYA_PARTITIONED_STREAMS_UNUSED;
    (void)portal_model; (void)portal_available;
    (void)provenance_available;
    return producer_available;
#else
    return portal_endpoint && portal_endpoint->valid &&
           portal_endpoint->producer_request &&
           portal_endpoint->producer_completion;
#endif
  }
  static bool provenance_response_bound(
      Check result, const provenance::Response& response) {
    return result.code == response.status &&
           result.detail == response.error_detail &&
           result.bad_element == response.bad_element;
  }
  static bool producer_response_bound(
      Check result, const producer::Request& request,
      const producer::Completion& completion) {
    const bool same_binding =
        completion.family == request.family &&
        completion.request_seq == request.request_seq &&
        completion.provenance_origin_seq == request.provenance_origin_seq &&
        numeric_identity_equal(completion.identity, request.identity) &&
        same_context(completion.context, request.context) &&
        completion.source == request.source &&
        completion.destination == request.destination &&
        completion.source_region == request.source_region &&
        completion.destination_region == request.destination_region &&
        completion.source_role == request.source_role &&
        completion.destination_role == request.destination_role &&
        completion.D == request.D && completion.gamma == request.gamma &&
        completion.eps_bits == request.eps_bits &&
        completion.row_bytes == request.row_bytes &&
        completion.source_first_offset == request.source_first_offset &&
        completion.destination_first_offset ==
            request.destination_first_offset &&
        completion.source_row_step == request.source_row_step &&
        completion.destination_row_step == request.destination_row_step;
    return same_binding &&
           completion.finished && result.code == completion.status &&
           result.detail == completion.error_detail &&
           result.bad_element == completion.bad_element;
  }
  template<class T>
  Check fail_issue(const T& task, Check result) {
    error_stage = task.ctx.stage;
    error_op = uint8_t(task.ctx.op);
    error_task_id = task.ctx.task_id;
    return result;
  }
  Check provenance_issue(const LayerNormTask& task, uint32_t elements,
                         OutputUnit unit,
                         const provenance::Request& begin
                         LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    if (!producer_ready(LAYA_PARTITIONED_IO_ARGUMENTS) ||
        unit != OutputUnit::F32 ||
        elements != uint32_t(task.ctx.rows) * 1024u ||
        rt.defer_task_retirement || rt.generated_store.active)
      return fail_issue(task, {Status::E_PROTOCOL,
                               detail(7, uint8_t(task.ctx.op), 5)});

    FullOwnerSpec source, destination;
    Check result = producer::prepare_layernorm(rt, memory, task,
                                                source, destination);
    if (!result) return fail_issue(task, result);

    producer::Request engine_request;
    result = producer::build_layernorm_request(
        rt, memory, LAYA_PORTAL_MODEL, task, begin, engine_request);
    if (!result) {
      const Check released = full_release_read_owner(rt, source);
      return fail_issue(task, result ? released : result);
    }
    result = provenance::arm_generated_store_tracker(rt, begin);
    if (!result) {
      const Check released = full_release_read_owner(rt, source);
      return fail_issue(task, result ? released : result);
    }
    rt.generated_store.source_lease = source;
    rt.generated_store.source_lease_active = true;

    provenance::Response begin_response;
#ifdef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
    result = transaction::exchange_provenance(
        LAYA_TRANSACTION_REQUEST_STREAM, LAYA_TRANSACTION_COMPLETION_STREAM,
        begin, begin_response);
#else
    result = provenance::exchange(
        LAYA_PROVENANCE_COMMAND_STREAM, LAYA_PROVENANCE_RESPONSE_STREAM,
        begin, begin_response);
#endif
    const bool begin_bound = provenance_response_bound(result, begin_response);
    if (!begin_bound) return fail_issue(task, result);
    if (!result) {
      Check released = full_release_read_owner(rt, source);
      rt.generated_store.source_lease_active = false;
      rt.generated_store.source_lease = FullOwnerSpec{};
      provenance::clear_generated_store_tracker(rt);
      if (!released) result = released;
      return fail_issue(task, result);
    }

    producer::Completion completion;
#ifdef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
    uint32_t producer_completion_flags = 0;
    result = transaction::exchange_producer(
        LAYA_TRANSACTION_REQUEST_STREAM, LAYA_TRANSACTION_COMPLETION_STREAM,
        engine_request, completion, &producer_completion_flags);
    const bool producer_local_reject =
        producer_completion_flags & transaction::LOCAL_REJECT;
#else
    result = producer::exchange(
        LAYA_PRODUCER_REQUEST_STREAM, LAYA_PRODUCER_COMPLETION_STREAM,
        engine_request, completion);
#endif
#ifndef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
    if (!producer_response_bound(result, engine_request, completion))
      return fail_issue(task, result);
#else
    if (!producer_local_reject &&
        !producer_response_bound(result, engine_request, completion))
      return fail_issue(task, result);
#endif

    TaskDone logical_done;
#ifdef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
    Check logical_result;
    if (producer_local_reject) {
      if (result || completion.finished || completion.issued_store_bytes ||
          completion.consumed_source_bytes || completion.output_elements ||
          completion.unit != OutputUnit::NONE)
        return fail_issue(task, {Status::E_PROTOCOL,
                                 detail(7, uint8_t(task.ctx.op), 14)});
      logical_result = producer::accept_layernorm_local_reject(
          rt, task, source, destination, begin, result, logical_done);
    } else {
      logical_result = producer::accept_layernorm_completion(
          rt, task, source, destination, begin, completion, logical_done);
    }
    if (logical_result.code != result.code ||
        logical_result.detail != result.detail ||
        logical_result.bad_element != result.bad_element)
      return fail_issue(task, logical_result);
#else
    Check logical_result = producer::accept_layernorm_completion(
        rt, task, source, destination, begin, completion, logical_done);
    if (logical_result.code != result.code ||
        logical_result.detail != result.detail ||
        logical_result.bad_element != result.bad_element)
      return fail_issue(task, logical_result);
#endif

    provenance::Request end;
    result = provenance::build_generated_end(rt, begin, logical_done, end);
    if (!result) return fail_issue(task, result);
    provenance::Response end_response;
#ifdef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
    // A bound non-terminal END is an explicit fence-in-progress response.  The
    // sequencer retains the same END identity and tracker and permits no next
    // task; one transaction is outstanding at a time until the peer reports a
    // real drained, closed scope.  A malformed or stale response still exits
    // immediately with the tracker intact.
    do {
      result = transaction::exchange_provenance(
          LAYA_TRANSACTION_REQUEST_STREAM, LAYA_TRANSACTION_COMPLETION_STREAM,
          end, end_response);
      if (!provenance_response_bound(result, end_response))
        return fail_issue(task, result);
    } while (!end_response.drained || end_response.scope_active);
#else
    result = provenance::exchange(
        LAYA_PROVENANCE_COMMAND_STREAM, LAYA_PROVENANCE_RESPONSE_STREAM,
        end, end_response);
    if (!provenance_response_bound(result, end_response))
      return fail_issue(task, result);
    if (!end_response.drained || end_response.scope_active)
      return fail_issue(task, result);
#endif

    provenance::clear_generated_store_tracker(rt);
    TaskDone final_done;
    final_done.task_id = task.ctx.task_id;
    final_done.status = end_response.status;
    final_done.error_detail = end_response.error_detail;
    final_done.bad_element = end_response.bad_element;
    final_done.output_elements = end_response.output_elements;
    final_done.output_unit = end_response.unit;
    final_done.drained = end_response.drained;
    const Check retired = full_retire_prepared_task(rt, task.ctx, final_done);
    if (retired.code != final_done.status ||
        retired.detail != final_done.error_detail ||
        retired.bad_element != final_done.bad_element)
      return fail_issue(task, {Status::E_PROTOCOL,
                               detail(7, uint8_t(task.ctx.op), 14)});
    return finish_issue(task, result, final_done, elements, unit);
  }
  template<class T>
  Check provenance_issue(const T& task, uint32_t elements, OutputUnit unit,
                         const provenance::Request& begin
                         LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
    (void)elements; (void)unit; (void)begin;
    LAYA_PARTITIONED_STREAMS_UNUSED;
    (void)portal_model; (void)portal_available;
    (void)provenance_available; (void)producer_available;
    return fail_issue(task, {Status::E_PROTOCOL,
                             detail(7, uint8_t(task.ctx.op), 5)});
#else
    if (rt.defer_task_retirement || rt.generated_store.active)
      return fail_issue(task, {Status::E_PROTOCOL,
                               detail(7, uint8_t(task.ctx.op), 9)});
    Check result = provenance::arm_generated_store_tracker(rt, begin);
    if (!result) return fail_issue(task, result);

    provenance::Response begin_response;
    result = provenance::exchange(
        *portal_endpoint->provenance_command,
        *portal_endpoint->provenance_response, begin, begin_response);
    const bool begin_bound = provenance_response_bound(result, begin_response);
    if (!begin_bound) return fail_issue(task, result);
    if (!result) {
      provenance::clear_generated_store_tracker(rt);
      return fail_issue(task, result);
    }

    rt.defer_task_retirement = true;
    TaskDone logical_done;
    const Check logical_result = full_run_task(rt, memory, task, logical_done);
    rt.defer_task_retirement = false;
    (void)logical_result;

    provenance::Request end;
    result = provenance::build_generated_end(rt, begin, logical_done, end);
    if (!result) return fail_issue(task, result);
    provenance::Response end_response;
    result = provenance::exchange(
        *portal_endpoint->provenance_command,
        *portal_endpoint->provenance_response, end, end_response);
    if (!provenance_response_bound(result, end_response))
      return fail_issue(task, result);
    // A bound END is terminal only after the physical scope is both drained
    // and closed.  Preserve the BEGIN/store tracker for either undrained
    // error form so cancellation/fence handling retains the issued-byte and
    // binding state needed to finish the old producer safely.
    if (!end_response.drained || end_response.scope_active)
      return fail_issue(task, result);

    provenance::clear_generated_store_tracker(rt);
    TaskDone final_done;
    final_done.task_id = task.ctx.task_id;
    final_done.status = end_response.status;
    final_done.error_detail = end_response.error_detail;
    final_done.bad_element = end_response.bad_element;
    final_done.output_elements = end_response.output_elements;
    final_done.output_unit = end_response.unit;
    final_done.drained = end_response.drained;
    const Check retired = full_retire_prepared_task(rt, task.ctx, final_done);
    if (retired.code != final_done.status ||
        retired.detail != final_done.error_detail ||
        retired.bad_element != final_done.bad_element)
      return fail_issue(task, {Status::E_PROTOCOL,
                               detail(7, uint8_t(task.ctx.op), 14)});
    return finish_issue(task, result, final_done, elements, unit);
#endif
  }
  portal::TaskBinding portal_binding() const {
    return {rt.dispatch_binding.producer_context,
            rt.dispatch_binding.quant, rt.dispatch_binding.linear};
  }
  Check issue(const LoadTask& task, uint32_t elements,
              OutputUnit unit LAYA_DEFAULT_OUTPUT_UNIT(OutputUnit::BYTES)
              LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    if (!portal_ready(LAYA_PARTITIONED_IO_ARGUMENTS) || task.kind != 0)
      return direct_issue(task, elements, unit
                          LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    phase(task.ctx.stage, task.ctx.op);
    FullWeightDescriptor descriptor;
    Check c = full_lookup_weight(task.weight, descriptor);
    TaskDone done;
    if (c) c =
#ifdef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
        transaction::dispatch_load(
        LAYA_TRANSACTION_REQUEST_STREAM, LAYA_TRANSACTION_COMPLETION_STREAM,
#else
        portal::dispatch_load(
        LAYA_PORTAL_COMMAND_STREAM, LAYA_PORTAL_RESPONSE_STREAM,
#endif
        rt.inputs.identity, memory, LAYA_PORTAL_MODEL,
        descriptor, task, rt.dispatch_command_generation, done);
    if (c || done.drained)
      c = portal::commit_load(rt, descriptor, task, done);
    return finish_issue(task, c, done, elements, unit);
  }
  Check issue(const VectorTask& task, uint32_t elements,
              OutputUnit unit LAYA_DEFAULT_OUTPUT_UNIT(OutputUnit::F32)
              LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    if (!portal_ready(LAYA_PARTITIONED_IO_ARGUMENTS) ||
        task.ctx.op != Op::GEGLU ||
        !rt.dispatch_binding.valid)
      return direct_issue(task, elements, unit
                          LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    phase(task.ctx.stage, task.ctx.op);
    TaskDone done;
    const portal::TaskBinding binding = portal_binding();
    Check c =
#ifdef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
        transaction::dispatch_geglu(
        LAYA_TRANSACTION_REQUEST_STREAM, LAYA_TRANSACTION_COMPLETION_STREAM,
#else
        portal::dispatch_geglu(
        LAYA_PORTAL_COMMAND_STREAM, LAYA_PORTAL_RESPONSE_STREAM,
#endif
        rt.inputs.identity, memory, LAYA_PORTAL_MODEL, task, binding,
        rt.dispatch_command_generation, done);
    const FullOwnerSpec source{task.src0, task.src0_region, task.ctx.stage,
        task.ctx.layer, 255, task.ctx.row_space, 0,
        rt.inputs.identity.S, 5248, Content::F32};
    const FullOwnerSpec output{task.dst, task.dst_region, task.ctx.stage,
        task.ctx.layer, 255, task.ctx.row_space, 0,
        rt.inputs.identity.S, task.length, Content::F32};
    if (c || done.drained)
      c = portal::commit_geglu(rt, source, output, task, done);
    return finish_issue(task, c, done, elements, unit);
  }
  Check issue(const QuantTask& task, uint32_t elements,
              OutputUnit unit LAYA_DEFAULT_OUTPUT_UNIT(OutputUnit::Q8_GROUP)
              LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    if (!portal_ready(LAYA_PARTITIONED_IO_ARGUMENTS) ||
        !rt.dispatch_binding.valid)
      return direct_issue(task, elements, unit
                          LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    phase(task.ctx.stage, task.ctx.op);
    TaskDone done;
    const portal::TaskBinding binding = portal_binding();
    Check c =
#ifdef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
        transaction::dispatch_quant(
        LAYA_TRANSACTION_REQUEST_STREAM, LAYA_TRANSACTION_COMPLETION_STREAM,
#else
        portal::dispatch_quant(
        LAYA_PORTAL_COMMAND_STREAM, LAYA_PORTAL_RESPONSE_STREAM,
#endif
        rt.inputs.identity, memory, LAYA_PORTAL_MODEL, binding,
        rt.dispatch_command_generation, done);
    const FullOwnerSpec source = rt.expected_quant_source_valid ?
        rt.expected_quant_source :
        FullOwnerSpec{task.src, task.src_region, task.ctx.stage,
                      task.ctx.layer, 255, task.ctx.row_space, 0,
                      task.ctx.row_space == RowSpace::TOKEN ?
                          rt.inputs.identity.S :
                      task.ctx.row_space == RowSpace::MARKER ?
                          uint16_t(16) : uint16_t(1),
                      task.K, Content::F32};
    if (c || done.drained)
      c = portal::commit_quant(rt, source, task, done);
    return finish_issue(task, c, done, elements, unit);
  }
  Check issue(const LinearTask& task, uint32_t elements,
              OutputUnit unit LAYA_DEFAULT_OUTPUT_UNIT(OutputUnit::F32)
              LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    if (!portal_ready(LAYA_PARTITIONED_IO_ARGUMENTS) ||
        !rt.dispatch_binding.valid)
      return direct_issue(task, elements, unit
                          LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    phase(task.ctx.stage, task.ctx.op);
    Check c = check_activation_binding(rt, task);
    if (!c) return c;
    TaskDone done;
    const portal::TaskBinding binding = portal_binding();
    c =
#ifdef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
        transaction::dispatch_matrix(
        LAYA_TRANSACTION_REQUEST_STREAM, LAYA_TRANSACTION_COMPLETION_STREAM,
#else
        portal::dispatch_matrix(
        LAYA_PORTAL_COMMAND_STREAM, LAYA_PORTAL_RESPONSE_STREAM,
#endif
        rt.inputs.identity, memory, LAYA_PORTAL_MODEL, binding,
        rt.dispatch_binding.view, rt.dispatch_binding.views, done);
    const FullOwnerSpec output{task.dst, task.dst_region, task.ctx.stage,
        task.ctx.layer, 255, task.ctx.row_space, 0,
        task.ctx.row_space == RowSpace::TOKEN ? rt.inputs.identity.S :
        task.ctx.row_space == RowSpace::MARKER ? uint16_t(16) : uint16_t(1),
        task.N, Content::F32};
    if (c || done.drained)
      c = portal::commit_matrix(rt, output, nullptr, task, done);
    return finish_issue(task, c, done, elements, unit);
  }
#endif
  static bool provenance_owner(const FullOwnerSpec& owner) {
    switch (owner.ref.id) {
      case Buffer::HIDDEN: case Buffer::NORM: case Buffer::TMP:
      case Buffer::MARKER: case Buffer::QKV: case Buffer::WI:
      case Buffer::GATE: case Buffer::ATT_OUT: case Buffer::DEC_FF:
      case Buffer::HEAD_WORK: case Buffer::TYPE_ROWS:
        return true;
      default: return false;
    }
  }
  static FullOwnerSpec owner_from_record(const FullOwnerRecord& record) {
    return {record.ref, record.region, record.stage, record.layer,
            record.batch, record.row_space, record.row0, record.rows,
            record.width, record.content};
  }
  Check owner_event(provenance::Action action,
                    const FullOwnerSpec* owner,
                    const FullOwnerSpec* old_owner,
                    uint8_t count
                    LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
    if (!provenance_ready(LAYA_PARTITIONED_IO_ARGUMENTS)) return ok();
    if (!owner || !count || count > 2) return {Status::E_PROTOCOL,
                                                detail(7, 0, 9)};
    for (unsigned i = 0; i < count; ++i)
      if (!provenance_owner(owner[i])) return ok();
    provenance::Request request;
    Check result = provenance::build_owner_event(
        rt, memory, LAYA_PORTAL_MODEL, action, owner, old_owner,
        count, request);
    if (!result) return result;
    provenance::Response response;
#ifdef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
    result = transaction::exchange_provenance(
        LAYA_TRANSACTION_REQUEST_STREAM, LAYA_TRANSACTION_COMPLETION_STREAM,
        request, response);
#else
    result = provenance::exchange(
        LAYA_PROVENANCE_COMMAND_STREAM, LAYA_PROVENANCE_RESPONSE_STREAM,
        request, response);
#endif
    return provenance_response_bound(result, response) ? result :
           Check{Status::E_PROTOCOL, detail(7, 0, 14)};
#else
    (void)action; (void)owner; (void)old_owner; (void)count;
    return ok();
#endif
  }
  Check claim_owner(const FullOwnerSpec& owner
                    LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    Check result = full_claim_owner(rt, owner);
    if (!result) return result;
    Check physical = owner_event(provenance::Action::CLAIM,
                                 &owner, nullptr, 1
                                 LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!physical) {
      (void)full_invalidate_owner(rt, owner.ref, owner.region);
      return physical;
    }
    return result;
  }
  Check claim_qkv_pair(const FullOwnerSpec (&pair)[2]
                       LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
    Check result = full_claim_qkv_pair(rt, pair);
    if (!result) return result;
    Check physical = owner_event(provenance::Action::CLAIM,
                                 pair, nullptr, 2
                                 LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!physical) {
      (void)full_invalidate_owner(rt, pair[0].ref, pair[0].region);
      (void)full_invalidate_owner(rt, pair[1].ref, pair[1].region);
      return physical;
    }
    return result;
  }
  Check publish_owner(const FullOwnerSpec& owner
                      LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    Check result = owner_event(provenance::Action::PUBLISH,
                               &owner, nullptr, 1
                               LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    return result ? full_publish_owner(rt, owner) : result;
  }
  Check publish_att(const FullOwnerSpec& owner
                    LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
    Check result = owner_event(provenance::Action::PUBLISH,
                               &owner, nullptr, 1
                               LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    return result ? full_publish_att(rt, owner) : result;
  }
  Check publish_qkv_pair(const FullOwnerSpec (&pair)[2]
                         LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
    Check result = owner_event(provenance::Action::PUBLISH,
                               pair, nullptr, 2
                               LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    return result ? full_publish_qkv_pair(rt, pair) : result;
  }
  Check release_owner(const FullOwnerSpec& owner
                      LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    Check result = owner_event(provenance::Action::RELEASE,
                               &owner, nullptr, 1
                               LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    return result ? full_release_owner(rt, owner) : result;
  }
  Check release_qkv_pair(const FullOwnerSpec (&pair)[2]
                         LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
    Check result = owner_event(provenance::Action::RELEASE,
                               pair, nullptr, 2
                               LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!result) return result;
    result = full_release_owner(rt, pair[0]);
    return result ? full_release_owner(rt, pair[1]) : result;
  }
  Check invalidate_owner(const FullOwnerSpec& owner
                         LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    Check physical = owner_event(provenance::Action::INVALIDATE,
                                 &owner, nullptr, 1
                                 LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    Check local = full_invalidate_owner(rt, owner.ref, owner.region);
    return physical ? local : physical;
  }
  Check begin_inplace_owner(const FullOwnerSpec& old_owner,
                            const FullOwnerSpec& next_owner
                            LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
    Check result = full_begin_inplace_owner(rt, old_owner, next_owner);
    if (!result) return result;
    Check physical = owner_event(provenance::Action::CLAIM,
                                 &next_owner, &old_owner, 1
                                 LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!physical) {
      (void)full_invalidate_owner(rt, next_owner.ref, next_owner.region);
      return physical;
    }
    return result;
  }
  Check commit_inplace_owner(const FullOwnerSpec& old_owner,
                             const FullOwnerSpec& next_owner
                             LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
    Check result = owner_event(provenance::Action::PUBLISH,
                               &next_owner, &old_owner, 1
                               LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    return result ? full_commit_inplace_owner(rt, next_owner) : result;
  }
  Check begin_qkv_rope_pair(const FullOwnerSpec (&old_pair)[2],
                            const FullOwnerSpec (&next_pair)[2]
                            LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
    Check result = full_begin_qkv_rope_pair(rt, old_pair, next_pair);
    if (!result) return result;
    Check physical = owner_event(provenance::Action::CLAIM,
                                 next_pair, old_pair, 2
                                 LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!physical) {
      (void)full_invalidate_owner(rt, next_pair[0].ref,
                                  next_pair[0].region);
      (void)full_invalidate_owner(rt, next_pair[1].ref,
                                  next_pair[1].region);
      return physical;
    }
    return result;
  }
  Check commit_qkv_rope_pair(const FullOwnerSpec (&old_pair)[2],
                             const FullOwnerSpec (&next_pair)[2]
                             LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
    Check result = owner_event(provenance::Action::PUBLISH,
                               next_pair, old_pair, 2
                               LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    return result ? full_commit_qkv_rope_pair(rt, next_pair) : result;
  }
  FullOwnerSpec matrix(BufferRef ref, uint8_t region, uint8_t stage,
                       uint8_t layer, RowSpace space, uint16_t width,
                       Content content = Content::F32) const {
    return {ref, region, stage, layer, 255, space, 0,
            space == RowSpace::TOKEN ? rt.inputs.identity.S :
            space == RowSpace::MARKER ? uint16_t(16) : uint16_t(1),
            width, content};
  }
  Check bind(const FullOwnerSpec& source) {
    return full_bind_task_source(rt, source);
  }
  void checkpoint(const char* name, const FullOwnerSpec& object) {
#ifndef __SYNTHESIS__
    if (rt.checkpoint)
      rt.checkpoint(name, rt, object.ref, object.region,
                    object.row_space, object.width, rt.checkpoint_user);
#else
    (void)name; (void)object;
#endif
  }
  void checkpoint_name(const char* prefix, uint8_t layer,
                       const FullOwnerSpec& object) {
#ifndef __SYNTHESIS__
    char name[24] = {};
    unsigned i = 0;
    while (prefix[i]) { name[i] = prefix[i]; ++i; }
    name[i++] = char('0' + layer / 10);
    name[i++] = char('0' + layer % 10);
    name[i++] = '_'; name[i++] = 'o'; name[i++] = 'u';
    name[i++] = 't'; name[i] = 0;
    checkpoint(name, object);
#else
    (void)prefix; (void)layer; (void)object;
#endif
  }
  Check load_gamma(uint8_t kind LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(kind == 1 ? 1 : 3, Op::LOAD_LN_PARAMS);
    LoadTask t;
    t.ctx = context(Op::LOAD_LN_PARAMS, kind == 1 ? 1 : 3,
                    255, 0, RowSpace::BATCH, 0, 1);
    t.kind = 2;
    t.dst = fresh(Buffer::LN_GAMMA, kind - 1);
    t.weight = {0, 255};
    t.head = 255;
    t.byte_count = 4096;
    return issue(t, t.byte_count, OutputUnit::BYTES
                 LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
  }
  Check load_weight(WeightKey key, uint8_t stage, uint8_t layer,
                    FullWeightDescriptor& descriptor
                    LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(stage, Op::LOAD_W);
    Check c = full_lookup_weight(key, descriptor);
    if (!c) return c;
    LoadTask t;
    t.ctx = context(Op::LOAD_W, stage, layer, 0,
                    RowSpace::BATCH, 0, 1);
    t.kind = 0;
    t.dst = fresh(Buffer::WEIGHT);
    t.weight = key;
    t.head = 255;
    t.byte_count = ((uint32_t(descriptor.N) + 7u) & ~7u) *
                   (descriptor.K / 32u) * 34u;
    rt.dispatch_command_generation = rt.portal_reservations.next();
    if (!rt.dispatch_command_generation) return {Status::E_PROTOCOL, detail(7, uint8_t(Op::LOAD_W), 9)};
    return issue(t, t.byte_count, OutputUnit::BYTES
                 LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
  }
  Check embed_tokens(FullOwnerSpec& output
                     LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(1, Op::EMB_TOKEN);
    output = matrix(fresh(Buffer::HIDDEN, 0), 0, 1, 255,
                    RowSpace::TOKEN, 1024);
    Check c = claim_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) return c;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
      for (unsigned row = 0; row < rt.inputs.identity.S; row += 16) {
        EmbeddingTask t;
        t.ctx = context(Op::EMB_TOKEN, 1, 255, uint8_t(b),
                        RowSpace::TOKEN, uint16_t(row), 16);
        t.table = 0; t.type_id = 255; t.dst = output.ref;
        c = issue(t, 16u * 1024u, OutputUnit::F32
                  LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
        if (!c) break;
      }
    if (c) c = publish_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) checkpoint("embedding_raw", output);
    return c;
  }
  Check norm(Op op, const FullOwnerSpec& source, uint8_t stage,
             uint8_t layer, BufferRef dst_ref, uint8_t dst_region,
             uint8_t gamma, FullOwnerSpec& output
             LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(stage, op);
    output = matrix(dst_ref, dst_region, stage, layer,
                    source.row_space, 1024);
    Check c = claim_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) return c;
    const unsigned rows = output.rows;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
      for (unsigned row = 0; row < rows; row += 16) {
        LayerNormTask t;
        t.ctx = context(op, stage, layer, uint8_t(b),
                        output.row_space, uint16_t(row),
                        uint8_t(rows - row < 16 ? rows - row : 16));
        t.src = source.ref; t.dst = output.ref; t.gamma = gamma;
        c = bind(source);
        if (c) c = issue(t, uint32_t(t.ctx.rows) * 1024u, OutputUnit::F32
                         LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
        if (!c) break;
      }
    if (c) c = publish_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    return c;
  }
  Check vector_impl(Op op, const FullOwnerSpec& src0,
                    bool src1_present, const FullOwnerSpec& src1,
                    uint8_t stage, uint8_t layer, BufferRef dst_ref,
                    uint8_t dst_region, uint16_t length,
                    FullOwnerSpec& output
                    LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(stage, op);
    output = matrix(dst_ref, dst_region, stage, layer,
                    op == Op::APPLY_CAND_MASK ? RowSpace::BATCH :
                    src0.row_space, length);
    Check c = claim_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) return c;
    const unsigned rows = output.rows;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
      for (unsigned row = 0; row < rows; row += 16) {
        VectorTask t;
        t.ctx = context(op, stage, layer, uint8_t(b),
                        output.row_space, uint16_t(row),
                        uint8_t(rows - row < 16 ? rows - row : 16));
        t.src0 = src0.ref; t.src0_region = src0.region;
        t.src1 = src1_present ? src1.ref : none();
        t.src1_region = src1_present ? src1.region : 0;
        t.dst = output.ref; t.dst_region = dst_region;
        t.length = length;
        c = bind(src0);
        if (c && src1_present) c = bind(src1);
        if (c) c = issue(t, uint32_t(t.ctx.rows) * length, OutputUnit::F32
                         LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
        if (!c) break;
      }
    if (c) c = publish_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    return c;
  }
  Check vector(Op op, const FullOwnerSpec& src0,
               const FullOwnerSpec& src1, uint8_t stage, uint8_t layer,
               BufferRef dst_ref, uint8_t dst_region,
               uint16_t length, FullOwnerSpec& output
               LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
    return vector_impl(op, src0, true, src1, stage, layer,
                       dst_ref, dst_region, length, output
                       LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
  }
  Check vector(Op op, const FullOwnerSpec& src0,
               uint8_t stage, uint8_t layer, BufferRef dst_ref,
               uint8_t dst_region, uint16_t length,
               FullOwnerSpec& output
               LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
    FullOwnerSpec unused_src1{};
    return vector_impl(op, src0, false, unused_src1, stage, layer,
                       dst_ref, dst_region, length, output
                       LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
  }
  Check linear_impl(Op op, WeightKey key, const FullOwnerSpec& source,
                    uint8_t stage, uint8_t layer, BufferRef dst_ref,
                    uint8_t dst_region, FullOwnerSpec& output,
                    bool pair_present, FullOwnerSpec (&pair_output)[2]
                    LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(stage, op);
    FullWeightDescriptor descriptor;
    Check c = load_weight(key, stage, layer, descriptor
                          LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) return c;
    phase(stage, op);
    const bool qkv = op == Op::LIN_QKV;
    output = matrix(dst_ref, dst_region, stage, layer,
                    source.row_space, qkv ? 64 : descriptor.N,
                    qkv ? (stage == 4 ? Content::QKV_FINAL :
                           Content::QKV_RAW) : Content::F32);
    FullOwnerSpec pair[2];
    const bool scorer_lease = op == Op::LIN_SCORER_FC1;
    if (qkv) {
      if (!pair_present) return {Status::E_INTERNAL, detail(7, 0, 4)};
      pair[0] = output;
      pair[1] = output;
      pair[1].ref = fresh(Buffer::QKV, 1);
      c = claim_qkv_pair(pair LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    } else if (!scorer_lease)
      c = claim_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) return c;
    const unsigned rows = source.rows;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
      for (unsigned row = 0; row < rows; row += 16) {
        rt.dispatch_binding.valid = false;
        const uint8_t count = uint8_t(rows - row < 16 ? rows - row : 16);
        QuantTask quant;
        quant.ctx = context(Op::QUANT, stage, layer, uint8_t(b),
                            source.row_space, uint16_t(row), count);
        quant.src = source.ref;
        quant.src_region = source.region;
        quant.a_dst = fresh(Buffer::A8);
        quant.K = descriptor.K;
        LinearTask t;
        t.ctx = context(op, stage, layer, uint8_t(b), source.row_space,
                        uint16_t(row), count);
        t.a = quant.a_dst;
        t.w = rt.current_weight_ref;
        t.ps = fresh(Buffer::PS);
        t.dst = output.ref;
        t.weight = key;
        t.K = descriptor.K; t.N = descriptor.N;
        t.dst_region = dst_region;
        t.bias_kind = descriptor.bias_kind;
        TaskContext producer_context;
        c = full_source_query(rt, source, uint8_t(b), uint16_t(row), count,
                              producer_context);
        if (!c || producer_context.task_id >= quant.ctx.task_id) {
          if (c) c = {Status::E_PROTOCOL, detail(7, uint8_t(op), 14)};
          break;
        }
        // The complete parent exists before Q is sent. P is the real typed
        // task that closed this source window, never an inferred neighbour ID.
        rt.dispatch_binding.producer_context = producer_context;
        rt.dispatch_binding.quant = quant; rt.dispatch_binding.linear = t;
        if (!rt.portal_reservations.can(1 + view_count(count))) return {Status::E_PROTOCOL, detail(7, uint8_t(op), 9)};
        rt.dispatch_binding.quant_generation = rt.portal_reservations.next();
        if (!reserve_views(rt.portal_reservations, count, rt.dispatch_binding.view, rt.dispatch_binding.views))
          return {Status::E_INTERNAL, detail(7, uint8_t(op), 9)};
        rt.dispatch_binding.valid = true;
        rt.dispatch_command_generation = rt.dispatch_binding.quant_generation;
        c = full_bind_quant_source(rt, source);
        if (c) c = issue(quant, uint32_t(count) * descriptor.K / 32u,
                         OutputUnit::Q8_GROUP
                         LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
        if (c) c = issue(t, uint32_t(count) * descriptor.N, OutputUnit::F32
                         LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
        rt.dispatch_binding.valid = false;
        if (!c) break;
      }
    rt.dispatch_binding.valid = false;
    if (c && qkv)
      c = publish_qkv_pair(pair LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    else if (c && !scorer_lease)
      c = publish_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c && qkv) {
      pair_output[0] = pair[0];
      pair_output[1] = pair[1];
    }
    return c;
  }
  Check linear(Op op, WeightKey key, const FullOwnerSpec& source,
               uint8_t stage, uint8_t layer, BufferRef dst_ref,
               uint8_t dst_region, FullOwnerSpec& output,
               FullOwnerSpec (&qkv_pair)[2]
               LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
    return linear_impl(op, key, source, stage, layer, dst_ref,
                       dst_region, output, true, qkv_pair
                       LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
  }
  Check linear(Op op, WeightKey key, const FullOwnerSpec& source,
               uint8_t stage, uint8_t layer, BufferRef dst_ref,
               uint8_t dst_region, FullOwnerSpec& output
               LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
    FullOwnerSpec unused_pair[2];
    return linear_impl(op, key, source, stage, layer, dst_ref,
                       dst_region, output, false, unused_pair
                       LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
  }
  Check geglu_down(const FullOwnerSpec& wide, uint8_t layer,
                   FullOwnerSpec& down
                   LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(2, Op::GEGLU);
    const BufferRef gate_ref = fresh(Buffer::GATE);
    const BufferRef down_ref = fresh(Buffer::TMP);
    // Look up only the immutable structural table. Any descriptor failure is
    // reported at the original Down LOAD point, after all G producers.
    FullWeightDescriptor descriptor;
    const Check descriptor_check = full_lookup_weight({4, layer}, descriptor);
    GDownPlan& plan = rt.g_down_plan;
    Check c = reserve_g_down(rt.dispatch_reservations, rt.portal_reservations, rt.last_task_id, rt.inputs.identity,
        layer, wide.ref, gate_ref, down_ref, committed_epoch(Buffer::WEIGHT),
        committed_epoch(Buffer::A8), committed_epoch(Buffer::PS),
        descriptor_check ? descriptor.bias_kind : 0, plan);
    if (!c) return c;
    FullOwnerSpec gated = matrix(gate_ref, 0, 2, layer, RowSpace::TOKEN, 2624);
    c = claim_owner(gated LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    for (unsigned i = 0; i < plan.count && c; ++i) {
      GDownWindow& record = plan.window[i];
      rt.dispatch_binding.producer_context = record.producer.ctx;
      rt.dispatch_binding.quant = record.quant; rt.dispatch_binding.linear = record.linear;
      rt.dispatch_binding.quant_generation = record.quant_generation;
      for (unsigned v = 0; v < kMatrixViews; ++v) rt.dispatch_binding.view[v] = record.view[v];
      rt.dispatch_binding.views = record.views; rt.dispatch_binding.valid = true;
      rt.dispatch_command_generation = record.producer_generation;
      c = bind(wide);
      if (c) c = issue(record.producer,
                       uint32_t(record.producer.ctx.rows) * 2624u,
                       OutputUnit::F32
                       LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      if (c) record.state = WindowState::PRODUCED;
    }
    if (c) c = publish_owner(gated LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) c = release_owner(wide LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) { plan.cancel(); rt.dispatch_binding.valid = false; return c; }
    phase(2, Op::LOAD_W);
    if (!descriptor_check) { plan.cancel(); rt.dispatch_binding.valid = false; return descriptor_check; }
    rt.dispatch_command_generation = plan.load_generation;
    c = issue(plan.load, plan.load.byte_count, OutputUnit::BYTES
              LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c && rt.current_weight_ref != plan.load.dst) c = {Status::E_INTERNAL, detail(7, uint8_t(Op::LOAD_W), 14)};
    phase(2, Op::LIN_DOWN);
    down = matrix(down_ref, 0, 2, layer, RowSpace::TOKEN, 1024);
    if (c) c = claim_owner(down LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    for (unsigned i = 0; i < plan.count && c; ++i) {
      GDownWindow& record = plan.window[i];
      rt.dispatch_binding.producer_context = record.producer.ctx;
      rt.dispatch_binding.quant = record.quant; rt.dispatch_binding.linear = record.linear;
      rt.dispatch_binding.quant_generation = record.quant_generation;
      for (unsigned v = 0; v < kMatrixViews; ++v) rt.dispatch_binding.view[v] = record.view[v];
      rt.dispatch_binding.views = record.views; rt.dispatch_binding.valid = true;
      rt.dispatch_command_generation = record.quant_generation;
      c = full_bind_quant_source(rt, gated);
      if (c) c = issue(record.quant,
                       uint32_t(record.quant.ctx.rows) * 82u,
                       OutputUnit::Q8_GROUP
                       LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      if (c) record.state = WindowState::QUANT_DONE;
      if (c) c = issue(record.linear,
                       uint32_t(record.linear.ctx.rows) * 1024u,
                       OutputUnit::F32
                       LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      if (c) record.state = WindowState::LINEAR_DONE;
    }
    if (c) c = publish_owner(down LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) c = release_owner(gated LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) plan.cancel(); else plan.valid = false;
    rt.dispatch_binding.valid = false;
    return c;
  }
  Check attention(uint8_t stage, uint8_t layer,
                  const FullOwnerSpec (&produced)[2],
                  FullOwnerSpec& output
                  LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(stage, stage == 2 ? Op::ROPE : Op::QK);
    FullOwnerSpec final[2] = {produced[0], produced[1]};
    Check c = ok();
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
      for (unsigned row = 0; row < rt.inputs.identity.S; row += 16) {
        TaskContext close[2], inherited_v[2];
        c = full_source_query_qkv(rt, produced, uint8_t(b), uint16_t(row),
                                  16, close, inherited_v);
        if (!c) break;
      }
    if (!c) return c;
    if (stage == 2) {
      const uint8_t mode = layer % 3 == 0 ? 0 : 1;
      LoadTask load;
      load.ctx = context(Op::LOAD_ROPE, 2, layer, 0,
                         RowSpace::BATCH, 0, 1);
      load.kind = 3; load.dst = fresh(Buffer::ROPE_TABLE, mode);
      load.weight = {0, 255}; load.head = 255;
      load.byte_count = 2u * 1025u * 64u * 4u;
      c = issue(load, load.byte_count, OutputUnit::BYTES
                LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      if (!c) return c;
      phase(stage, Op::ROPE);
      for (unsigned shard = 0; shard < 2; ++shard) {
        final[shard].ref.epoch = produced[shard].ref.epoch + 1;
        final[shard].content = Content::QKV_FINAL;
      }
      c = begin_qkv_rope_pair(produced, final
                              LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      if (!c) return c;
      for (unsigned head = 0; head < 16 && c; ++head)
        for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
          for (unsigned row = 0; row < rt.inputs.identity.S; row += 16) {
            RopeTask t;
            t.ctx = context(Op::ROPE, 2, layer, uint8_t(b),
                            RowSpace::TOKEN, uint16_t(row), 16);
            t.src_qkv_ref = {produced[0].ref, produced[1].ref};
            t.dst_qkv_ref = {final[0].ref, final[1].ref};
            t.head = uint8_t(head); t.mode = mode; t.table_set = mode;
            c = issue(t, 16u * 128u, OutputUnit::F32
                      LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
            if (!c) break;
          }
      if (c) c = commit_qkv_rope_pair(produced, final
                                      LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      if (!c) return c;
      for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
        for (unsigned row = 0; row < rt.inputs.identity.S; row += 16) {
          TaskContext close[2], inherited_v[2];
          c = full_source_query_qkv(rt, final, uint8_t(b), uint16_t(row),
                                    16, close, inherited_v);
          if (!c) break;
        }
      if (!c) return c;
    }
    output = matrix(fresh(Buffer::ATT_OUT), 0, stage, layer,
                    RowSpace::TOKEN, 1024);
    phase(stage, Op::AV);
    c = claim_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) return c;
    for (unsigned head = 0; head < 16 && c; ++head) {
      LoadTask load;
      load.ctx = context(Op::LOAD_KV, stage, layer, 0,
                         RowSpace::BATCH, 0, 1);
      load.kind = 1; load.dst = fresh(Buffer::KV);
      load.weight = {0, 255}; load.head = uint8_t(head);
      load.planes = 3;
      load.byte_count = 2u * rt.inputs.identity.B *
                        rt.inputs.identity.S * 64u * 4u;
      c = issue(load, load.byte_count, OutputUnit::BYTES
                LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      if (!c) break;
      phase(stage, Op::QK);
      for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
        for (unsigned row = 0; row < rt.inputs.identity.S; row += 16) {
          QKTask qk;
          qk.ctx = context(Op::QK, stage, layer, uint8_t(b),
                           RowSpace::TOKEN, uint16_t(row), 16);
          qk.qkv_ref = {final[0].ref, final[1].ref};
          qk.kv = load.dst;
          qk.score = fresh(Buffer::SCORE_PROB);
          qk.head = uint8_t(head);
          qk.mask_mode = stage == 2 && layer % 3 != 0 ? 1 : 0;
          qk.S = rt.inputs.identity.S;
          c = issue(qk, 16u * qk.S, OutputUnit::F32
                    LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
          if (!c) break;
          const FullOwnerSpec raw{qk.score, 0, stage, layer, uint8_t(b),
                                   RowSpace::TOKEN, uint16_t(row), 16,
                                   qk.S, Content::SCORE};
          FullOwnerSpec prob = raw;
          prob.ref.epoch += 1;
          prob.content = Content::PROB;
          c = begin_inplace_owner(raw, prob
                                  LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
          if (!c) break;
          SoftmaxTask sm;
          sm.ctx = context(Op::SOFTMAX_ATT, stage, layer, uint8_t(b),
                           RowSpace::TOKEN, uint16_t(row), 16);
          sm.src = raw.ref; sm.dst = prob.ref;
          sm.length = qk.S; sm.mode = 0;
          c = issue(sm, 16u * sm.length, OutputUnit::F32
                    LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
          if (!c) break;
          AVTask av;
          av.ctx = context(Op::AV, stage, layer, uint8_t(b),
                           RowSpace::TOKEN, uint16_t(row), 16);
          av.prob = prob.ref; av.kv = load.dst;
          av.partial = fresh(Buffer::AV_PARTIAL);
          av.dst = output.ref; av.head = uint8_t(head); av.S = qk.S;
          c = issue(av, 16u * 64u, OutputUnit::F32
                    LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
          if (!c) break;
        }
    }
    if (c) c = publish_att(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) c = release_qkv_pair(final LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    return c;
  }

  Check residual(uint8_t stage, uint8_t layer,
                 const FullOwnerSpec& tmp, FullOwnerSpec& hidden
                 LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(stage, Op::ADD_RESIDUAL);
    FullOwnerSpec next;
    Check c = vector(Op::ADD_RESIDUAL, tmp, hidden, stage, layer,
                     fresh(Buffer::HIDDEN, uint8_t(1 - hidden.ref.bank)),
                     0, 1024, next
                     LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) c = release_owner(tmp LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) c = release_owner(hidden LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) hidden = next;
    return c;
  }

  Check transform(Op op, const FullOwnerSpec& old, uint16_t length,
                  uint16_t bias_id, FullOwnerSpec& next
                  LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(old.stage, op);
    next = old;
    next.ref.epoch = old.ref.epoch + 1;
    Check c = begin_inplace_owner(old, next
                                  LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) return c;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b)
      for (unsigned row = 0; row < old.rows; row += 16) {
        VectorTask t;
        t.ctx = context(op, old.stage, old.layer, uint8_t(b),
                        old.row_space, uint16_t(row),
                        uint8_t(old.rows - row < 16 ? old.rows - row : 16));
        t.src0 = old.ref; t.src0_region = old.region;
        t.src1 = none();
        t.dst = next.ref; t.dst_region = next.region;
        t.length = length; t.bias_id = bias_id;
        c = issue(t, uint32_t(t.ctx.rows) * length, OutputUnit::F32
                  LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
        if (!c) break;
      }
    if (c) c = commit_inplace_owner(old, next
                                    LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) (void)invalidate_owner(next
                                   LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    return c;
  }

  Check type_add(FullOwnerSpec& hidden
                 LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(3, Op::EMB_TYPE);
    const FullOwnerSpec types{fresh(Buffer::TYPE_ROWS), 0, 3, 255, 0,
                              RowSpace::BATCH, 0, 3, 1024, Content::F32};
    Check c = claim_owner(types LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) return c;
    for (uint8_t type = 0; type < 3 && c; ++type) {
      bool used = false;
      for (unsigned b = 0; b < rt.inputs.identity.B; ++b)
        if (rt.inputs.qtype[b] == type) used = true;
      if (!used) continue;
      EmbeddingTask t;
      t.ctx = context(Op::EMB_TYPE, 3, 255, 0, RowSpace::BATCH, 0, 1);
      t.table = 1; t.dst = types.ref; t.type_id = type;
      c = issue(t, 1024, OutputUnit::F32
                LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    }
    if (!c) return c;
    c = owner_event(provenance::Action::PUBLISH, &types, nullptr, 1
                    LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) return c;
    FullOwnerSpec next;
    c = vector(Op::ADD_TYPE, hidden, types, 3, 255,
               fresh(Buffer::HIDDEN, uint8_t(1 - hidden.ref.bank)),
               0, 1024, next LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) c = release_owner(types LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) c = release_owner(hidden LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) {
      hidden = next;
      checkpoint("type_add", hidden);
    }
    return c;
  }

  Check fp_linear(Op op, WeightKey key, const FullOwnerSpec& source,
                  uint8_t stage, uint8_t src_region,
                  uint8_t dst_region, uint16_t K, uint16_t N,
                  FullOwnerSpec& output
                  LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(stage, op);
    output = matrix(fresh(Buffer::HEAD_WORK, 0, dst_region),
                    dst_region, stage, 255, source.row_space, N);
    Check c = claim_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) return c;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b) {
      FPLinearTask t;
      t.ctx = context(op, stage, 255, uint8_t(b), source.row_space,
                      0, uint8_t(source.rows));
      t.src = source.ref; t.src_region = src_region;
      t.dst = output.ref; t.dst_region = dst_region;
      t.weight = key; t.K = K; t.N = N;
      c = bind(source);
      if (c) c = issue(t, uint32_t(t.ctx.rows) * N, OutputUnit::F32
                       LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    }
    if (c) c = publish_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    return c;
  }

  Check gather(const FullOwnerSpec& hidden, FullOwnerSpec& output
               LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(5, Op::GATHER_MARKER);
    output = matrix(fresh(Buffer::MARKER), 0, 5, 255,
                    RowSpace::MARKER, 1024);
    Check c = claim_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) return c;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b) {
      GatherTask t;
      t.ctx = context(Op::GATHER_MARKER, 5, 255, uint8_t(b),
                      RowSpace::MARKER, 0, 16);
      t.hidden = hidden.ref; t.markers = output.ref;
      c = bind(hidden);
      if (c) c = issue(t, 16u * 1024u, OutputUnit::F32
                       LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    }
    if (c) c = publish_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) checkpoint("marker_gather", output);
    return c;
  }

  Check candidate_masked(const FullOwnerSpec& raw,
                         FullOwnerSpec& output
                         LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    Check c = vector(Op::APPLY_CAND_MASK, raw, 5, 255,
                     fresh(Buffer::HEAD_WORK, 0,
                           uint8_t(Region::CAND_MASKED)),
                     uint8_t(Region::CAND_MASKED), 16, output
                     LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) checkpoint("candidate_masked", output);
    return c;
  }

  Check candidate_probability(const FullOwnerSpec& masked,
                              FullOwnerSpec& output
                              LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(6, Op::SOFTMAX_CAND);
    const uint8_t region = uint8_t(Region::CAND_PROB);
    output = matrix(fresh(Buffer::HEAD_WORK, 0, region), region,
                    6, 255, RowSpace::BATCH, 16);
    Check c = claim_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) return c;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b) {
      SoftmaxTask t;
      t.ctx = context(Op::SOFTMAX_CAND, 6, 255, uint8_t(b),
                      RowSpace::BATCH, 0, 1);
      t.src = masked.ref; t.src_region = masked.region;
      t.dst = output.ref; t.dst_region = region;
      t.length = 16; t.mode = 1;
      c = bind(masked);
      if (c) c = issue(t, 16, OutputUnit::F32
                       LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    }
    if (c) c = publish_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) checkpoint("candidate_prob", output);
    return c;
  }

  Check candidate_statistics(const FullOwnerSpec& prob,
                             FullOwnerSpec& output
                             LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(6, Op::CAND_STATS);
    const uint8_t region = uint8_t(Region::STATS);
    output = matrix(fresh(Buffer::HEAD_WORK, 0, region), region,
                    6, 255, RowSpace::BATCH, 4);
    Check c = claim_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) return c;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b) {
      StatsTask t;
      t.ctx = context(Op::CAND_STATS, 6, 255, uint8_t(b),
                      RowSpace::BATCH, 0, 1);
      t.probs = prob.ref; t.prob_region = prob.region;
      t.stats = output.ref; t.stats_region = region;
      for (unsigned i = 0; i < 16; ++i)
        t.valid_options += rt.inputs.marker_mask[b][i];
      c = bind(prob);
      if (c) c = issue(t, 4, OutputUnit::F32
                       LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    }
    if (c) c = publish_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) checkpoint("stats", output);
    return c;
  }

  Check act_concat(const FullOwnerSpec& hidden,
                   const FullOwnerSpec& stats,
                   FullOwnerSpec& output
                   LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
#pragma HLS inline off
#endif
    phase(6, Op::CONCAT_ACT);
    const uint8_t region = uint8_t(Region::ACT_INPUT);
    output = matrix(fresh(Buffer::HEAD_WORK, 0, region), region,
                    6, 255, RowSpace::BATCH, 1028);
    Check c = claim_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (!c) return c;
    for (unsigned b = 0; b < rt.inputs.identity.B && c; ++b) {
      ConcatActTask t;
      t.ctx = context(Op::CONCAT_ACT, 6, 255, uint8_t(b),
                      RowSpace::BATCH, 0, 1);
      t.hidden = hidden.ref; t.stats = stats.ref;
      t.stats_region = stats.region;
      t.dst = output.ref; t.dst_region = region;
      c = bind(hidden);
      if (c) c = bind(stats);
      if (c) c = issue(t, 1028, OutputUnit::F32
                       LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    }
    if (c) c = publish_owner(output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    if (c) checkpoint("act_input", output);
    return c;
  }

#ifndef LAYA_PARTITIONED_PRODUCTION_CALLER
  Check frontend_from_hidden(FullOwnerSpec& hidden, bool cpu_raw) {
    if (cpu_raw) rt.cpu_import.reached_phase = 6;
    Check c = load_gamma(1);
    if (!c) return c;
    if (cpu_raw) rt.cpu_import.reached_phase = 7;
    FullOwnerSpec normed;
    c = norm(Op::LN_EMB, hidden, 1, 255,
             fresh(Buffer::HIDDEN, uint8_t(1 - hidden.ref.bank)),
             0, 1, normed);
    if (!c) return c;
    c = release_owner(hidden);
    if (!c) return c;
    hidden = normed;
    checkpoint("embedding_norm", hidden);
    if (cpu_raw) rt.cpu_import.reached_phase = 8;
    return ok();
  }

  Check frontend(FullOwnerSpec& hidden) {
    Check c = embed_tokens(hidden);
    return c ? frontend_from_hidden(hidden, false) : c;
  }

  Check frontend_cpu(FullOwnerSpec& hidden) {
    Check c = full_import_cpu_raw(rt, memory, hidden);
    if (!c) return c;
    checkpoint("embedding_raw", hidden);
    return frontend_from_hidden(hidden, true);
  }
#endif

#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
  Check execute_graph_action(const GraphAction& action, GraphState& state
                             LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#pragma HLS inline off
    FullOwnerSpec& source = state.slot[action.src];
    FullOwnerSpec& output = state.slot[action.dst];
    switch (action.kind) {
      case GraphActionKind::EMBED:
        return embed_tokens(state.slot[SLOT_HIDDEN]
                            LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      case GraphActionKind::LOAD_GAMMA:
        return load_gamma(action.gamma LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      case GraphActionKind::NORM:
        return norm(action.op, source, action.stage, action.layer,
                    fresh(action.dst_buffer, action.dst_bank,
                          action.dst_region),
                    action.dst_region, action.gamma, output
                    LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      case GraphActionKind::RELEASE:
        return release_owner(source LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      case GraphActionKind::LINEAR: {
        BufferRef dst_ref;
        if (action.inplace) {
          output = source;
          output.ref.epoch = source.ref.epoch + 1;
          phase(action.stage, action.op);
          Check result = begin_inplace_owner(
              source, output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
          if (!result) return result;
          dst_ref = output.ref;
        } else {
          dst_ref = fresh(action.dst_buffer, action.dst_bank,
                          action.dst_region);
        }
        Check result = linear_impl(
            action.op, action.weight, source, action.stage, action.layer,
            dst_ref, action.dst_region, output, action.qkv, state.qkv
            LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
        if (action.inplace) {
          if (result) result = commit_inplace_owner(
              source, output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
          if (!result) (void)invalidate_owner(
              output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
        }
        return result;
      }
      case GraphActionKind::ATTENTION:
        return attention(action.stage, action.layer, state.qkv, output
                         LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      case GraphActionKind::RESIDUAL:
        return residual(action.stage, action.layer, source,
                        state.slot[SLOT_HIDDEN]
                        LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      case GraphActionKind::GEGLU_DOWN:
        return geglu_down(source, action.layer, output
                          LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      case GraphActionKind::TYPE_ADD:
        return type_add(state.slot[SLOT_HIDDEN]
                        LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      case GraphActionKind::TRANSFORM:
        return transform(action.op, source, action.length,
                         state.bias_id[action.bias], output
                         LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      case GraphActionKind::GATHER:
        return gather(source, output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      case GraphActionKind::LOOKUP_BIAS: {
        FullTensorDescriptor descriptor;
        const char* name = action.bias ? "act_fc1.bias" :
                                         "scorer_fc1.bias";
        return full_lookup_tensor_indexed(name, descriptor,
                                          state.bias_id[action.bias]);
      }
      case GraphActionKind::FP_LINEAR:
        return fp_linear(action.op, action.weight, source, action.stage,
                         source.region, action.dst_region, action.K, action.N,
                         output LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      case GraphActionKind::CANDIDATE_MASKED:
        return candidate_masked(source, output
                                LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      case GraphActionKind::CANDIDATE_PROBABILITY:
        return candidate_probability(source, output
                                     LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      case GraphActionKind::CANDIDATE_STATISTICS:
        return candidate_statistics(source, output
                                    LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      case GraphActionKind::ACT_CONCAT:
        return act_concat(state.slot[SLOT_HIDDEN],
                          state.slot[SLOT_STATS], output
                          LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
    }
    return {Status::E_INTERNAL, detail(7, 0, 14)};
  }

  Check graph_partitioned(FullOwnerSpec& candidate, FullOwnerSpec& act
                          LAYA_PARTITIONED_IO_APPEND_PARAMETERS) {
#pragma HLS inline off
    enum ProgramCounter : uint8_t {
      PC_EMBED = 0,
      PC_LOAD_GAMMA_EMB,
      PC_NORM_EMB,
      PC_RELEASE_EMB,
      PC_ENCODER_NORM_ATTN,
      PC_ENCODER_QKV,
      PC_ENCODER_RELEASE_NORM_ATTN,
      PC_ENCODER_ATTENTION,
      PC_ENCODER_WO,
      PC_ENCODER_RELEASE_ATTENDED,
      PC_ENCODER_RESIDUAL_ATTN,
      PC_ENCODER_NORM_FFN,
      PC_ENCODER_WI,
      PC_ENCODER_RELEASE_NORM_FFN,
      PC_ENCODER_GEGLU_DOWN,
      PC_ENCODER_RESIDUAL_FFN,
      PC_LOAD_GAMMA_FINAL,
      PC_NORM_FINAL,
      PC_RELEASE_FINAL,
      PC_TYPE_ADD,
      PC_DECISION_NORM_ATTN,
      PC_DECISION_QKV,
      PC_DECISION_RELEASE_NORM_ATTN,
      PC_DECISION_ATTENTION,
      PC_DECISION_WO,
      PC_DECISION_RELEASE_ATTENDED,
      PC_DECISION_RESIDUAL_ATTN,
      PC_DECISION_NORM_FFN,
      PC_DECISION_FC1,
      PC_DECISION_RELEASE_NORM_FFN,
      PC_DECISION_RELU,
      PC_DECISION_FC2,
      PC_DECISION_RELEASE_RELU,
      PC_DECISION_RESIDUAL_FFN,
      PC_GATHER,
      PC_NORM_MARKER,
      PC_RELEASE_MARKERS,
      PC_SCORER_FC1,
      PC_LOOKUP_SCORER_BIAS,
      PC_SCORER_BIAS_GELU,
      PC_SCORER_FC2,
      PC_CANDIDATE_MASK,
      PC_CANDIDATE_PROBABILITY,
      PC_CANDIDATE_STATISTICS,
      PC_ACT_CONCAT,
      PC_ACT_FC1,
      PC_LOOKUP_ACT_BIAS,
      PC_ACT_BIAS_GELU,
      PC_ACT_FC2,
      PC_DONE,
    };

    GraphState state;
    uint8_t pc = PC_EMBED;
    uint8_t layer = 0;
    for (unsigned control = 0; control < 512 && pc != PC_DONE; ++control) {
      GraphAction action;
      uint8_t next_pc = uint8_t(pc + 1);
      bool execute = true;
      switch (pc) {
        case PC_EMBED:
          action.kind = GraphActionKind::EMBED;
          break;
        case PC_LOAD_GAMMA_EMB:
          action.kind = GraphActionKind::LOAD_GAMMA;
          action.gamma = 1;
          break;
        case PC_NORM_EMB:
          action.kind = GraphActionKind::NORM;
          action.op = Op::LN_EMB;
          action.src = SLOT_HIDDEN;
          action.dst = SLOT_NORMALIZED;
          action.stage = 1;
          action.dst_buffer = Buffer::HIDDEN;
          action.dst_bank = uint8_t(1 - state.slot[SLOT_HIDDEN].ref.bank);
          action.gamma = 1;
          break;
        case PC_RELEASE_EMB:
          action.kind = GraphActionKind::RELEASE;
          action.src = SLOT_HIDDEN;
          break;
        case PC_ENCODER_NORM_ATTN:
          if (!layer) {
            pc = PC_ENCODER_QKV;
            execute = false;
            break;
          }
          action.kind = GraphActionKind::NORM;
          action.op = Op::LN_ATTN;
          action.src = SLOT_HIDDEN;
          action.dst = SLOT_NORMALIZED;
          action.stage = 2;
          action.layer = layer;
          action.dst_buffer = Buffer::NORM;
          break;
        case PC_ENCODER_QKV:
          action.kind = GraphActionKind::LINEAR;
          action.op = Op::LIN_QKV;
          action.weight = WeightKey{1, layer};
          action.src = layer ? SLOT_NORMALIZED : SLOT_HIDDEN;
          action.dst = SLOT_QKV_PRIMARY;
          action.stage = 2;
          action.layer = layer;
          action.dst_buffer = Buffer::QKV;
          action.qkv = true;
          break;
        case PC_ENCODER_RELEASE_NORM_ATTN:
          if (!layer) {
            pc = PC_ENCODER_ATTENTION;
            execute = false;
            break;
          }
          action.kind = GraphActionKind::RELEASE;
          action.src = SLOT_NORMALIZED;
          break;
        case PC_ENCODER_ATTENTION:
          action.kind = GraphActionKind::ATTENTION;
          action.dst = SLOT_ATTENDED;
          action.stage = 2;
          action.layer = layer;
          break;
        case PC_ENCODER_WO:
          action.kind = GraphActionKind::LINEAR;
          action.op = Op::LIN_WO;
          action.weight = WeightKey{2, layer};
          action.src = SLOT_ATTENDED;
          action.dst = SLOT_PROJECTED;
          action.stage = 2;
          action.layer = layer;
          action.dst_buffer = Buffer::TMP;
          break;
        case PC_ENCODER_RELEASE_ATTENDED:
          action.kind = GraphActionKind::RELEASE;
          action.src = SLOT_ATTENDED;
          break;
        case PC_ENCODER_RESIDUAL_ATTN:
          action.kind = GraphActionKind::RESIDUAL;
          action.src = SLOT_PROJECTED;
          action.stage = 2;
          action.layer = layer;
          break;
        case PC_ENCODER_NORM_FFN:
          action.kind = GraphActionKind::NORM;
          action.op = Op::LN_FFN;
          action.src = SLOT_HIDDEN;
          action.dst = SLOT_NORMALIZED;
          action.stage = 2;
          action.layer = layer;
          action.dst_buffer = Buffer::NORM;
          break;
        case PC_ENCODER_WI:
          action.kind = GraphActionKind::LINEAR;
          action.op = Op::LIN_WI;
          action.weight = WeightKey{3, layer};
          action.src = SLOT_NORMALIZED;
          action.dst = SLOT_WIDE;
          action.stage = 2;
          action.layer = layer;
          action.dst_buffer = Buffer::WI;
          break;
        case PC_ENCODER_RELEASE_NORM_FFN:
          action.kind = GraphActionKind::RELEASE;
          action.src = SLOT_NORMALIZED;
          break;
        case PC_ENCODER_GEGLU_DOWN:
          action.kind = GraphActionKind::GEGLU_DOWN;
          action.src = SLOT_WIDE;
          action.dst = SLOT_DOWN;
          action.layer = layer;
          break;
        case PC_ENCODER_RESIDUAL_FFN:
          action.kind = GraphActionKind::RESIDUAL;
          action.src = SLOT_DOWN;
          action.stage = 2;
          action.layer = layer;
          next_pc = PC_ENCODER_NORM_ATTN;
          break;
        case PC_LOAD_GAMMA_FINAL:
          action.kind = GraphActionKind::LOAD_GAMMA;
          action.gamma = 2;
          break;
        case PC_NORM_FINAL:
          action.kind = GraphActionKind::NORM;
          action.op = Op::LN_FINAL;
          action.src = SLOT_HIDDEN;
          action.dst = SLOT_NORMALIZED;
          action.stage = 3;
          action.dst_buffer = Buffer::HIDDEN;
          action.dst_bank = uint8_t(1 - state.slot[SLOT_HIDDEN].ref.bank);
          action.gamma = 2;
          break;
        case PC_RELEASE_FINAL:
          action.kind = GraphActionKind::RELEASE;
          action.src = SLOT_HIDDEN;
          break;
        case PC_TYPE_ADD:
          action.kind = GraphActionKind::TYPE_ADD;
          next_pc = PC_DECISION_NORM_ATTN;
          break;
        case PC_DECISION_NORM_ATTN:
          action.kind = GraphActionKind::NORM;
          action.op = Op::LN_ATTN;
          action.src = SLOT_HIDDEN;
          action.dst = SLOT_NORMALIZED;
          action.stage = 4;
          action.layer = layer;
          action.dst_buffer = Buffer::NORM;
          break;
        case PC_DECISION_QKV:
          action.kind = GraphActionKind::LINEAR;
          action.op = Op::LIN_QKV;
          action.weight = WeightKey{5, layer};
          action.src = SLOT_NORMALIZED;
          action.dst = SLOT_QKV_PRIMARY;
          action.stage = 4;
          action.layer = layer;
          action.dst_buffer = Buffer::QKV;
          action.qkv = true;
          break;
        case PC_DECISION_RELEASE_NORM_ATTN:
          action.kind = GraphActionKind::RELEASE;
          action.src = SLOT_NORMALIZED;
          break;
        case PC_DECISION_ATTENTION:
          action.kind = GraphActionKind::ATTENTION;
          action.dst = SLOT_ATTENDED;
          action.stage = 4;
          action.layer = layer;
          break;
        case PC_DECISION_WO:
          action.kind = GraphActionKind::LINEAR;
          action.op = Op::LIN_WO;
          action.weight = WeightKey{6, layer};
          action.src = SLOT_ATTENDED;
          action.dst = SLOT_PROJECTED;
          action.stage = 4;
          action.layer = layer;
          action.dst_buffer = Buffer::TMP;
          break;
        case PC_DECISION_RELEASE_ATTENDED:
          action.kind = GraphActionKind::RELEASE;
          action.src = SLOT_ATTENDED;
          break;
        case PC_DECISION_RESIDUAL_ATTN:
          action.kind = GraphActionKind::RESIDUAL;
          action.src = SLOT_PROJECTED;
          action.stage = 4;
          action.layer = layer;
          break;
        case PC_DECISION_NORM_FFN:
          action.kind = GraphActionKind::NORM;
          action.op = Op::LN_FFN;
          action.src = SLOT_HIDDEN;
          action.dst = SLOT_NORMALIZED;
          action.stage = 4;
          action.layer = layer;
          action.dst_buffer = Buffer::NORM;
          break;
        case PC_DECISION_FC1:
          action.kind = GraphActionKind::LINEAR;
          action.op = Op::LIN_DEC_FC1;
          action.weight = WeightKey{7, layer};
          action.src = SLOT_NORMALIZED;
          action.dst = SLOT_FC1;
          action.stage = 4;
          action.layer = layer;
          action.dst_buffer = Buffer::DEC_FF;
          break;
        case PC_DECISION_RELEASE_NORM_FFN:
          action.kind = GraphActionKind::RELEASE;
          action.src = SLOT_NORMALIZED;
          break;
        case PC_DECISION_RELU:
          action.kind = GraphActionKind::TRANSFORM;
          action.op = Op::RELU;
          action.src = SLOT_FC1;
          action.dst = SLOT_RELU;
          action.length = 4096;
          break;
        case PC_DECISION_FC2:
          action.kind = GraphActionKind::LINEAR;
          action.op = Op::LIN_DEC_FC2;
          action.weight = WeightKey{8, layer};
          action.src = SLOT_RELU;
          action.dst = SLOT_FC2;
          action.stage = 4;
          action.layer = layer;
          action.dst_buffer = Buffer::TMP;
          break;
        case PC_DECISION_RELEASE_RELU:
          action.kind = GraphActionKind::RELEASE;
          action.src = SLOT_RELU;
          break;
        case PC_DECISION_RESIDUAL_FFN:
          action.kind = GraphActionKind::RESIDUAL;
          action.src = SLOT_FC2;
          action.stage = 4;
          action.layer = layer;
          next_pc = PC_DECISION_NORM_ATTN;
          break;
        case PC_GATHER:
          action.kind = GraphActionKind::GATHER;
          action.src = SLOT_HIDDEN;
          action.dst = SLOT_MARKERS;
          break;
        case PC_NORM_MARKER:
          action.kind = GraphActionKind::NORM;
          action.op = Op::LN_MARKER;
          action.src = SLOT_MARKERS;
          action.dst = SLOT_MARKER_NORM;
          action.stage = 5;
          action.dst_buffer = Buffer::HEAD_WORK;
          action.dst_region = uint8_t(Region::SCORER_ACT);
          break;
        case PC_RELEASE_MARKERS:
          action.kind = GraphActionKind::RELEASE;
          action.src = SLOT_MARKERS;
          break;
        case PC_SCORER_FC1:
          action.kind = GraphActionKind::LINEAR;
          action.op = Op::LIN_SCORER_FC1;
          action.weight = WeightKey{9, 255};
          action.src = SLOT_MARKER_NORM;
          action.dst = SLOT_SCORER_BAKED;
          action.stage = 5;
          action.dst_region = uint8_t(Region::SCORER_ACT);
          action.inplace = true;
          break;
        case PC_LOOKUP_SCORER_BIAS:
          action.kind = GraphActionKind::LOOKUP_BIAS;
          action.bias = 0;
          break;
        case PC_SCORER_BIAS_GELU:
          action.kind = GraphActionKind::TRANSFORM;
          action.op = Op::BIAS_GELU_SCORER;
          action.src = SLOT_SCORER_BAKED;
          action.dst = SLOT_SCORER_HIDDEN;
          action.length = 1024;
          action.bias = 0;
          break;
        case PC_SCORER_FC2:
          action.kind = GraphActionKind::FP_LINEAR;
          action.op = Op::FP_SCORER_FC2;
          action.weight = WeightKey{10, 255};
          action.src = SLOT_SCORER_HIDDEN;
          action.dst = SLOT_RAW;
          action.stage = 5;
          action.dst_region = uint8_t(Region::CAND_RAW);
          action.K = 1024;
          action.N = 1;
          break;
        case PC_CANDIDATE_MASK:
          action.kind = GraphActionKind::CANDIDATE_MASKED;
          action.src = SLOT_RAW;
          action.dst = SLOT_CANDIDATE;
          break;
        case PC_CANDIDATE_PROBABILITY:
          action.kind = GraphActionKind::CANDIDATE_PROBABILITY;
          action.src = SLOT_CANDIDATE;
          action.dst = SLOT_PROBABILITY;
          break;
        case PC_CANDIDATE_STATISTICS:
          action.kind = GraphActionKind::CANDIDATE_STATISTICS;
          action.src = SLOT_PROBABILITY;
          action.dst = SLOT_STATS;
          break;
        case PC_ACT_CONCAT:
          action.kind = GraphActionKind::ACT_CONCAT;
          action.dst = SLOT_ACT_INPUT;
          break;
        case PC_ACT_FC1:
          action.kind = GraphActionKind::FP_LINEAR;
          action.op = Op::FP_ACT_FC1;
          action.weight = WeightKey{11, 255};
          action.src = SLOT_ACT_INPUT;
          action.dst = SLOT_ACT_DOT;
          action.stage = 6;
          action.dst_region = uint8_t(Region::ACT_HIDDEN);
          action.K = 1028;
          action.N = 256;
          break;
        case PC_LOOKUP_ACT_BIAS:
          action.kind = GraphActionKind::LOOKUP_BIAS;
          action.bias = 1;
          break;
        case PC_ACT_BIAS_GELU:
          action.kind = GraphActionKind::TRANSFORM;
          action.op = Op::BIAS_GELU_ACT;
          action.src = SLOT_ACT_DOT;
          action.dst = SLOT_ACT_HIDDEN;
          action.length = 256;
          action.bias = 1;
          break;
        case PC_ACT_FC2:
          action.kind = GraphActionKind::LINEAR;
          action.op = Op::LIN_ACT_FC2;
          action.weight = WeightKey{12, 255};
          action.src = SLOT_ACT_HIDDEN;
          action.dst = SLOT_ACT_OUTPUT;
          action.stage = 6;
          action.layer = 255;
          action.dst_buffer = Buffer::HEAD_WORK;
          action.dst_region = uint8_t(Region::ACT_LOGITS);
          next_pc = PC_DONE;
          break;
        default:
          return {Status::E_INTERNAL, detail(7, 0, 14)};
      }
      if (!execute) continue;
      const uint8_t executed_pc = pc;
      Check result = execute_graph_action(
          action, state LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
      if (!result) return result;
      pc = next_pc;
      switch (executed_pc) {
        case PC_RELEASE_EMB:
          state.slot[SLOT_HIDDEN] = state.slot[SLOT_NORMALIZED];
          checkpoint("embedding_norm", state.slot[SLOT_HIDDEN]);
          break;
        case PC_ENCODER_RESIDUAL_FFN:
          ++rt.encoder_layers_completed;
          checkpoint_name("encoder_", layer, state.slot[SLOT_HIDDEN]);
          ++layer;
          pc = layer < 28 ? PC_ENCODER_NORM_ATTN : PC_LOAD_GAMMA_FINAL;
          break;
        case PC_RELEASE_FINAL:
          state.slot[SLOT_HIDDEN] = state.slot[SLOT_NORMALIZED];
          checkpoint("final_norm", state.slot[SLOT_HIDDEN]);
          break;
        case PC_TYPE_ADD:
          layer = 0;
          break;
        case PC_DECISION_RESIDUAL_FFN:
          ++rt.decision_layers_completed;
          checkpoint_name("decision_", layer, state.slot[SLOT_HIDDEN]);
          ++layer;
          pc = layer < 2 ? PC_DECISION_NORM_ATTN : PC_GATHER;
          break;
        case PC_RELEASE_MARKERS:
          checkpoint("marker_norm", state.slot[SLOT_MARKER_NORM]);
          break;
        case PC_SCORER_FC1:
          checkpoint("scorer_fc1_baked", state.slot[SLOT_SCORER_BAKED]);
          break;
        case PC_SCORER_BIAS_GELU:
          checkpoint("scorer_post_bias_gelu",
                     state.slot[SLOT_SCORER_HIDDEN]);
          break;
        case PC_SCORER_FC2:
          checkpoint("candidate_raw", state.slot[SLOT_RAW]);
          break;
        case PC_ACT_FC1:
          checkpoint("act_dot", state.slot[SLOT_ACT_DOT]);
          break;
        case PC_ACT_BIAS_GELU:
          checkpoint("act_hidden", state.slot[SLOT_ACT_HIDDEN]);
          break;
        case PC_ACT_FC2:
          checkpoint("act_logits", state.slot[SLOT_ACT_OUTPUT]);
          break;
        default:
          break;
      }
    }
    if (pc != PC_DONE)
      return {Status::E_INTERNAL, detail(7, 0, 14)};
    candidate = state.slot[SLOT_CANDIDATE];
    act = state.slot[SLOT_ACT_OUTPUT];
    return ok();
  }
#endif

#ifndef LAYA_PARTITIONED_PRODUCTION_CALLER
  Check graph(FullOwnerSpec& candidate, FullOwnerSpec& act,
              bool cpu_raw = false) {
    FullOwnerSpec hidden;
    Check c = cpu_raw ? frontend_cpu(hidden) : frontend(hidden);
    if (!c) return c;
    for (uint8_t layer = 0; layer < 28; ++layer) {
      FullOwnerSpec att_source = hidden;
      FullOwnerSpec normalized;
      if (layer) {
        c = norm(Op::LN_ATTN, hidden, 2, layer,
                 fresh(Buffer::NORM), 0, 0, normalized);
        if (!c) return c;
        att_source = normalized;
      }
      FullOwnerSpec qkv[2];
      FullOwnerSpec qkv_primary;
      c = linear(Op::LIN_QKV, {1, layer}, att_source,
                 2, layer, fresh(Buffer::QKV, 0), 0,
                 qkv_primary, qkv);
      if (!c) return c;
      if (layer) {
        c = release_owner(normalized);
        if (!c) return c;
      }
      FullOwnerSpec attended;
      c = attention(2, layer, qkv, attended);
      if (!c) return c;
      FullOwnerSpec projected;
      c = linear(Op::LIN_WO, {2, layer}, attended, 2, layer,
                 fresh(Buffer::TMP), 0, projected);
      if (!c) return c;
      c = release_owner(attended);
      if (!c) return c;
      c = residual(2, layer, projected, hidden);
      if (!c) return c;

      c = norm(Op::LN_FFN, hidden, 2, layer,
               fresh(Buffer::NORM), 0, 0, normalized);
      if (!c) return c;
      FullOwnerSpec wide;
      c = linear(Op::LIN_WI, {3, layer}, normalized, 2, layer,
                 fresh(Buffer::WI), 0, wide);
      if (!c) return c;
      c = release_owner(normalized);
      if (!c) return c;
      FullOwnerSpec down;
      c = geglu_down(wide, layer, down);
      if (!c) return c;
      c = residual(2, layer, down, hidden);
      if (!c) return c;
      ++rt.encoder_layers_completed;
      checkpoint_name("encoder_", layer, hidden);
    }

    c = load_gamma(2);
    if (!c) return c;
    FullOwnerSpec final_norm;
    c = norm(Op::LN_FINAL, hidden, 3, 255,
             fresh(Buffer::HIDDEN, uint8_t(1 - hidden.ref.bank)),
             0, 2, final_norm);
    if (!c) return c;
    c = release_owner(hidden);
    if (!c) return c;
    hidden = final_norm;
    checkpoint("final_norm", hidden);
    c = type_add(hidden);
    if (!c) return c;

    for (uint8_t layer = 0; layer < 2; ++layer) {
      FullOwnerSpec normalized;
      c = norm(Op::LN_ATTN, hidden, 4, layer,
               fresh(Buffer::NORM), 0, 0, normalized);
      if (!c) return c;
      FullOwnerSpec qkv[2];
      FullOwnerSpec qkv_primary;
      c = linear(Op::LIN_QKV, {5, layer}, normalized,
                 4, layer, fresh(Buffer::QKV, 0), 0,
                 qkv_primary, qkv);
      if (!c) return c;
      c = release_owner(normalized);
      if (!c) return c;
      FullOwnerSpec attended;
      c = attention(4, layer, qkv, attended);
      if (!c) return c;
      FullOwnerSpec projected;
      c = linear(Op::LIN_WO, {6, layer}, attended, 4, layer,
                 fresh(Buffer::TMP), 0, projected);
      if (!c) return c;
      c = release_owner(attended);
      if (!c) return c;
      c = residual(4, layer, projected, hidden);
      if (!c) return c;

      c = norm(Op::LN_FFN, hidden, 4, layer,
               fresh(Buffer::NORM), 0, 0, normalized);
      if (!c) return c;
      FullOwnerSpec fc1;
      c = linear(Op::LIN_DEC_FC1, {7, layer}, normalized,
                 4, layer, fresh(Buffer::DEC_FF), 0, fc1);
      if (!c) return c;
      c = release_owner(normalized);
      if (!c) return c;
      FullOwnerSpec relu;
      c = transform(Op::RELU, fc1, 4096, 65535, relu);
      if (!c) return c;
      FullOwnerSpec fc2;
      c = linear(Op::LIN_DEC_FC2, {8, layer}, relu,
                 4, layer, fresh(Buffer::TMP), 0, fc2);
      if (!c) return c;
      c = release_owner(relu);
      if (!c) return c;
      c = residual(4, layer, fc2, hidden);
      if (!c) return c;
      ++rt.decision_layers_completed;
      checkpoint_name("decision_", layer, hidden);
    }

    FullOwnerSpec markers;
    c = gather(hidden, markers);
    if (!c) return c;
    FullOwnerSpec marker_norm;
    c = norm(Op::LN_MARKER, markers, 5, 255,
             fresh(Buffer::HEAD_WORK, 0,
                   uint8_t(Region::SCORER_ACT)),
             uint8_t(Region::SCORER_ACT), 0, marker_norm);
    if (!c) return c;
    c = release_owner(markers);
    if (!c) return c;
    checkpoint("marker_norm", marker_norm);

    FullOwnerSpec scorer_baked = marker_norm;
    scorer_baked.ref.epoch += 1;
    phase(5, Op::LIN_SCORER_FC1);
    c = begin_inplace_owner(marker_norm, scorer_baked);
    if (!c) return c;
    c = linear(Op::LIN_SCORER_FC1, {9, 255}, marker_norm,
               5, 255, scorer_baked.ref,
               uint8_t(Region::SCORER_ACT), scorer_baked);
    if (c) c = commit_inplace_owner(marker_norm, scorer_baked);
    if (!c) {
      (void)invalidate_owner(scorer_baked);
      return c;
    }
    checkpoint("scorer_fc1_baked", scorer_baked);
    FullTensorDescriptor scorer_bias;
    uint16_t scorer_bias_id = 65535;
    c = full_lookup_tensor_indexed("scorer_fc1.bias", scorer_bias,
                                   scorer_bias_id);
    if (!c) return c;
    FullOwnerSpec scorer_hidden;
    c = transform(Op::BIAS_GELU_SCORER, scorer_baked, 1024,
                  scorer_bias_id, scorer_hidden);
    if (!c) return c;
    checkpoint("scorer_post_bias_gelu", scorer_hidden);

    FullOwnerSpec raw;
    c = fp_linear(Op::FP_SCORER_FC2, {10, 255}, scorer_hidden,
                  5, scorer_hidden.region, uint8_t(Region::CAND_RAW),
                  1024, 1, raw);
    if (!c) return c;
    checkpoint("candidate_raw", raw);
    c = candidate_masked(raw, candidate);
    if (!c) return c;
    FullOwnerSpec prob;
    c = candidate_probability(candidate, prob);
    if (!c) return c;
    FullOwnerSpec stats;
    c = candidate_statistics(prob, stats);
    if (!c) return c;
    FullOwnerSpec act_input;
    c = act_concat(hidden, stats, act_input);
    if (!c) return c;
    FullOwnerSpec act_dot;
    c = fp_linear(Op::FP_ACT_FC1, {11, 255}, act_input,
                  6, act_input.region, uint8_t(Region::ACT_HIDDEN),
                  1028, 256, act_dot);
    if (!c) return c;
    checkpoint("act_dot", act_dot);
    FullTensorDescriptor act_bias;
    uint16_t act_bias_id = 65535;
    c = full_lookup_tensor_indexed("act_fc1.bias", act_bias, act_bias_id);
    if (!c) return c;
    FullOwnerSpec act_hidden;
    c = transform(Op::BIAS_GELU_ACT, act_dot, 256,
                  act_bias_id, act_hidden);
    if (!c) return c;
    checkpoint("act_hidden", act_hidden);
    c = linear(Op::LIN_ACT_FC2, {12, 255}, act_hidden,
               6, 255,
               fresh(Buffer::HEAD_WORK, 0,
                     uint8_t(Region::ACT_LOGITS)),
               uint8_t(Region::ACT_LOGITS), act);
    if (c) checkpoint("act_logits", act);
    return c;
  }
#endif

  Check invalidate_incomplete(LAYA_PARTITIONED_IO_PARAMETERS) {
    rt.g_down_plan.cancel(); rt.dispatch_binding.valid = false;
    bool qkv_done[2] = {};
    for (unsigned i = 0; i < 32; ++i) {
      FullOwnerRecord& owner = rt.owners.record[i];
      if (owner.ref.id == Buffer::NONE) continue;
      if (owner.state == CacheState::READ || owner.readers)
        return {Status::E_INTERNAL, detail(7, 0, 14)};
      if (owner.state == CacheState::FILL ||
          owner.state == CacheState::EXCLUSIVE_RW) {
        if (owner.ref.id == Buffer::QKV) {
          if (owner.ref.bank > 1 || qkv_done[owner.ref.bank]) continue;
          FullOwnerSpec pair[2];
          bool found[2] = {};
          for (unsigned j = 0; j < 32; ++j) {
            const FullOwnerRecord& candidate = rt.owners.record[j];
            if (candidate.ref.id == Buffer::QKV &&
                candidate.ref.epoch == owner.ref.epoch &&
                candidate.ref.bank < 2 &&
                (candidate.state == CacheState::FILL ||
                 candidate.state == CacheState::EXCLUSIVE_RW)) {
              pair[candidate.ref.bank] = owner_from_record(candidate);
              found[candidate.ref.bank] = true;
            }
          }
          if (!found[0] || !found[1])
            return {Status::E_INTERNAL, detail(7, 0, 14)};
          Check physical = owner_event(provenance::Action::INVALIDATE,
                                       pair, nullptr, 2
                                       LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
          Check first = full_invalidate_owner(rt, pair[0].ref,
                                              pair[0].region);
          Check second = full_invalidate_owner(rt, pair[1].ref,
                                               pair[1].region);
          qkv_done[0] = qkv_done[1] = true;
          if (!physical) return physical;
          if (!first) return first;
          if (!second) return second;
          continue;
        }
        Check c = invalidate_owner(owner_from_record(owner)
                                   LAYA_PARTITIONED_IO_APPEND_ARGUMENTS);
        if (!c) return c;
      }
    }
    return ok();
  }
};

} // namespace

namespace {
#ifndef LAYA_PARTITIONED_PRODUCTION_CALLER
Check cpu_admit(FullRuntime& rt, FullMemory& memory, bool& accepted) {
  accepted = false;
  full_begin_request(rt);
  FullInputs next;
  uint32_t frame_bytes = 0;
  Check c = full_decode_validate_request(rt, memory, next, frame_bytes);
  if (!c) return c;
  c = full_validate_cpu_raw_descriptor(rt, memory, next, frame_bytes);
  if (!c) {
    rt.cpu_import.first_error_stage = 1;
    rt.cpu_import.first_error_operator = uint8_t(Op::IO_VALIDATE);
    return c;
  }
  c = full_admit_request(rt, next);
  if (!c) return c;
  accepted = true;
  rt.cpu_import.admitted = true;
  rt.cpu_import.reached_phase = 2;
  return ok();
}

void cpu_record_execution_error(FullRuntime& rt, const Controller& controller,
                                Check result) {
  if (result) return;
  auto& d = rt.cpu_import;
  d.first_error_stage = 1;
  d.first_error_operator = uint8_t(Op::IO_VALIDATE);
  d.first_error_task_id = 0;
  if (controller.error_task_id) {
    d.first_error_stage = controller.error_stage;
    d.first_error_operator = controller.error_op;
    d.first_error_task_id = controller.error_task_id;
  } else if (d.reached_phase >= 6) {
    d.first_error_stage = controller.current_stage;
    d.first_error_operator = controller.current_op;
  }
}
#endif
} // namespace

#ifndef LAYA_PARTITIONED_PRODUCTION_CALLER
Check full_execute_request(FullRuntime& rt, FullMemory& memory) {
  rt.last_commit_error = ok();
  rt.last_cleanup_error = ok();
  Controller controller{rt, memory};
  Check result = full_parse_request(rt, memory);
  const bool accepted = bool(result);
  FullOwnerSpec candidate, act;
  if (result) result = controller.graph(candidate, act);
  rt.last_execution_error = result;
  if (!result && accepted && controller.error_task_id == 0) {
    controller.error_stage = controller.current_stage;
    controller.error_op = controller.current_op;
  }
  if (!result && accepted) {
    Check cleanup = controller.invalidate_incomplete();
    rt.last_cleanup_error = cleanup;
    if (!cleanup) return result;
  }
  Check committed = full_write_result(rt, memory, result, accepted,
                                      controller.error_stage,
                                      controller.error_op,
                                      controller.error_task_id,
                                      candidate.ref, act.ref);
  if (result && !committed) rt.last_execution_error = committed;
  return committed;
}
#endif

#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
#ifndef LAYA_PARTITIONED_PRODUCTION_CALLER
Check full_execute_request_portal(
    FullRuntime& rt, FullMemory& memory,
    hls::stream<ap_uint<512>>& command_stream,
    hls::stream<ap_uint<512>>& response_stream,
    hls::stream<ap_uint<512>>& provenance_command_stream,
    hls::stream<ap_uint<512>>& provenance_response_stream) {
  PortalEndpoint endpoint;
  Check result = portal::build_l13m_model_binding(endpoint.model);
  if (!result) return result;
  endpoint.command = &command_stream;
  endpoint.response = &response_stream;
  endpoint.provenance_command = &provenance_command_stream;
  endpoint.provenance_response = &provenance_response_stream;
  endpoint.valid = true;
  rt.last_commit_error = ok();
  rt.last_cleanup_error = ok();
  Controller controller{rt, memory};
  controller.portal_endpoint = &endpoint;
  result = full_parse_request(rt, memory);
  const bool accepted = bool(result);
  FullOwnerSpec candidate, act;
  if (result) result = controller.graph(candidate, act);
  rt.last_execution_error = result;
  if (!result && accepted && controller.error_task_id == 0) {
    controller.error_stage = controller.current_stage;
    controller.error_op = controller.current_op;
  }
  if (!result && accepted) {
    Check cleanup = controller.invalidate_incomplete();
    rt.last_cleanup_error = cleanup;
    if (!cleanup) return result;
  }
  Check committed = full_write_result(rt, memory, result, accepted,
                                      controller.error_stage,
                                      controller.error_op,
                                      controller.error_task_id,
                                      candidate.ref, act.ref);
  if (result && !committed) rt.last_execution_error = committed;
  return committed;
}
#endif

#ifdef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
Check full_execute_request_graph_sequencer(
    FullRuntime& rt, FullMemory& memory,
    hls::stream<ap_uint<512>>& transaction_request_stream,
    hls::stream<ap_uint<512>>& transaction_completion_stream) {
#else
Check full_execute_request_partitioned(
    FullRuntime& rt, FullMemory& memory,
    hls::stream<ap_uint<512>>& command_stream,
    hls::stream<ap_uint<512>>& response_stream,
    hls::stream<ap_uint<512>>& provenance_command_stream,
    hls::stream<ap_uint<512>>& provenance_response_stream,
    hls::stream<ap_uint<512>>& producer_request_stream,
    hls::stream<ap_uint<512>>& producer_completion_stream) {
#endif
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
  portal::ModelBinding portal_model;
  Check result = portal::build_l13m_model_binding(portal_model);
  if (!result) return result;
  const bool portal_available = true;
  const bool provenance_available = true;
  const bool producer_available = true;
#else
  PortalEndpoint endpoint;
  Check result = portal::build_l13m_model_binding(endpoint.model);
  if (!result) return result;
  endpoint.command = &command_stream;
  endpoint.response = &response_stream;
  endpoint.provenance_command = &provenance_command_stream;
  endpoint.provenance_response = &provenance_response_stream;
  endpoint.producer_request = &producer_request_stream;
  endpoint.producer_completion = &producer_completion_stream;
  endpoint.valid = true;
#endif
  rt.last_commit_error = ok();
  rt.last_cleanup_error = ok();
  Controller controller{rt, memory};
#ifndef LAYA_PARTITIONED_PRODUCTION_CALLER
  controller.portal_endpoint = &endpoint;
#endif
  result = full_parse_request(rt, memory);
  const bool accepted = bool(result);
  FullOwnerSpec candidate, act;
  if (result) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
    result = controller.graph_partitioned(
        candidate, act, LAYA_PARTITIONED_IO_ARGUMENTS);
#else
    result = controller.graph(candidate, act);
#endif
  }
  rt.last_execution_error = result;
  if (!result && accepted && controller.error_task_id == 0) {
    controller.error_stage = controller.current_stage;
    controller.error_op = controller.current_op;
  }
  if (!result && accepted) {
    Check cleanup = controller.invalidate_incomplete(
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
        LAYA_PARTITIONED_IO_ARGUMENTS
#endif
    );
    rt.last_cleanup_error = cleanup;
    if (!cleanup) return result;
  }
  Check committed = full_write_result(rt, memory, result, accepted,
                                      controller.error_stage,
                                      controller.error_op,
                                      controller.error_task_id,
                                      candidate.ref, act.ref);
  if (result && !committed) rt.last_execution_error = committed;
  return committed;
}

#ifdef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
Check full_execute_generated_layernorm_lifecycle_transaction(
    FullRuntime& rt, FullMemory& memory, const FullOwnerSpec& source,
    const FullOwnerSpec& output, const LayerNormTask& task,
    uint32_t elements, bool publish_output,
    hls::stream<ap_uint<512>>& transaction_request_stream,
    hls::stream<ap_uint<512>>& transaction_completion_stream) {
  portal::ModelBinding portal_model;
  Check result = portal::build_l13m_model_binding(portal_model);
  if (!result) return result;
  Controller controller{rt, memory};
  result = controller.claim_owner(
      output, transaction_request_stream, transaction_completion_stream,
      portal_model, false, true, true);
  if (result) result = controller.bind(source);
  if (result)
    result = controller.issue(
        task, elements, OutputUnit::F32, transaction_request_stream,
        transaction_completion_stream, portal_model, false, true, true);
  if (result && publish_output)
    result = controller.publish_owner(
        output, transaction_request_stream, transaction_completion_stream,
        portal_model, false, true, true);
  if (!result && !rt.generated_store.active) {
    FullOwnerRecord record;
    const Check snapshot = full_owner_snapshot(rt, output.ref, output.region,
                                               record);
    if (snapshot && (record.state == CacheState::FILL ||
                     record.state == CacheState::EXCLUSIVE_RW))
      (void)controller.invalidate_owner(
          output, transaction_request_stream, transaction_completion_stream,
          portal_model, false, true, true);
  }
  return result;
}
#endif
#endif

#ifndef LAYA_PARTITIONED_PRODUCTION_CALLER
Check full_execute_frontend(FullRuntime& rt, FullMemory& memory,
                            FullOwnerSpec& output) {
  rt.last_commit_error = ok();
  rt.last_cleanup_error = ok();
  Controller controller{rt, memory};
  Check result = full_parse_request(rt, memory);
  const bool accepted = bool(result);
  if (result) result = controller.frontend(output);
  rt.last_execution_error = result;
  if (!result && accepted && controller.error_task_id == 0) {
    controller.error_stage = controller.current_stage;
    controller.error_op = uint8_t(controller.current_op);
  }
  if (!result && accepted) {
    Check cleanup = controller.invalidate_incomplete();
    rt.last_cleanup_error = cleanup;
  }
  return result;
}

Check full_execute_cpu_frontend(FullRuntime& rt, FullMemory& memory,
                                FullOwnerSpec& output) {
  output = FullOwnerSpec{};
  rt.last_commit_error = ok();
  rt.last_cleanup_error = ok();
  Controller controller{rt, memory};
  bool accepted = false;
  Check result = cpu_admit(rt, memory, accepted);
  FullOwnerSpec hidden;
  if (result) result = controller.frontend_cpu(hidden);
  rt.last_execution_error = result;
  if (!result && accepted) {
    cpu_record_execution_error(rt, controller, result);
    rt.cpu_import.cleanup_attempted = true;
    const Check cleanup = controller.invalidate_incomplete();
    rt.last_cleanup_error = cleanup;
    rt.cpu_import.cleanup_completed = bool(cleanup);
  }
  if (result) output = hidden;
  return result;
}

Check full_execute_cpu_request(FullRuntime& rt, FullMemory& memory) {
  rt.last_commit_error = ok();
  rt.last_cleanup_error = ok();
  Controller controller{rt, memory};
  bool accepted = false;
  Check result = cpu_admit(rt, memory, accepted);
  FullOwnerSpec candidate, act;
  if (result) result = controller.graph(candidate, act, true);
  rt.last_execution_error = result;
  if (!result && accepted) {
    cpu_record_execution_error(rt, controller, result);
    rt.cpu_import.cleanup_attempted = true;
    const Check cleanup = controller.invalidate_incomplete();
    rt.last_cleanup_error = cleanup;
    rt.cpu_import.cleanup_completed = bool(cleanup);
    if (!cleanup) return result;
  }
  Check committed = full_write_result(rt, memory, result, accepted,
                                      rt.cpu_import.first_error_stage,
                                      rt.cpu_import.first_error_operator,
                                      rt.cpu_import.first_error_task_id,
                                      candidate.ref, act.ref);
  if (result && !committed) rt.last_execution_error = committed;
  return committed;
}
#endif

#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
#ifndef LAYA_PARTITIONED_PRODUCTION_CALLER
Check full_execute_g_down_portal(
    FullRuntime& rt, FullMemory& memory, const FullOwnerSpec& wide,
    uint8_t layer, hls::stream<ap_uint<512>>& command_stream,
    hls::stream<ap_uint<512>>& response_stream, FullOwnerSpec& down) {
  down = FullOwnerSpec{};
  PortalEndpoint endpoint;
  Check result = portal::build_l13m_model_binding(endpoint.model);
  if (!result) return result;
  endpoint.command = &command_stream;
  endpoint.response = &response_stream;
  endpoint.valid = true;
  Controller controller{rt, memory};
  controller.portal_endpoint = &endpoint;
  result = controller.geglu_down(wide, layer, down);
  if (!result) down = FullOwnerSpec{};
  return result;
}

Check full_execute_linear_portal(
    FullRuntime& rt, FullMemory& memory, const FullOwnerSpec& source, Op op,
    WeightKey weight, uint8_t stage, uint8_t layer, BufferRef dst,
    uint8_t dst_region, hls::stream<ap_uint<512>>& command_stream,
    hls::stream<ap_uint<512>>& response_stream, FullOwnerSpec& output) {
  output = FullOwnerSpec{};
  if (op == Op::LIN_QKV || op == Op::LIN_DOWN ||
      uint8_t(op) < uint8_t(Op::LIN_WO) ||
      uint8_t(op) > uint8_t(Op::LIN_ACT_FC2))
    return {Status::E_PROTOCOL, detail(7, uint8_t(op), 5)};
  PortalEndpoint endpoint;
  Check result = portal::build_l13m_model_binding(endpoint.model);
  if (!result) return result;
  endpoint.command = &command_stream;
  endpoint.response = &response_stream;
  endpoint.valid = true;
  Controller controller{rt, memory};
  controller.portal_endpoint = &endpoint;
  result = controller.linear(op, weight, source, stage, layer, dst,
                             dst_region, output);
  if (!result) output = FullOwnerSpec{};
  return result;
}

Check full_execute_generated_vector_portal(
    FullRuntime& rt, FullMemory& memory, const FullOwnerSpec& source0,
    const FullOwnerSpec& source1, const VectorTask& task, uint32_t elements,
    hls::stream<ap_uint<512>>& provenance_command_stream,
    hls::stream<ap_uint<512>>& provenance_response_stream) {
  PortalEndpoint endpoint;
  Check result = portal::build_l13m_model_binding(endpoint.model);
  if (!result) return result;
  endpoint.provenance_command = &provenance_command_stream;
  endpoint.provenance_response = &provenance_response_stream;
  endpoint.valid = true;
  Controller controller{rt, memory};
  controller.portal_endpoint = &endpoint;
  result = controller.bind(source0);
  if (result) result = controller.bind(source1);
  if (result) result = controller.issue(task, elements, OutputUnit::F32);
  return result;
}

Check full_execute_generated_vector_lifecycle_portal(
    FullRuntime& rt, FullMemory& memory, const FullOwnerSpec& source0,
    const FullOwnerSpec& source1, const FullOwnerSpec& output,
    const VectorTask& task, uint32_t elements, bool release_output,
    hls::stream<ap_uint<512>>& provenance_command_stream,
    hls::stream<ap_uint<512>>& provenance_response_stream) {
  PortalEndpoint endpoint;
  Check result = portal::build_l13m_model_binding(endpoint.model);
  if (!result) return result;
  endpoint.provenance_command = &provenance_command_stream;
  endpoint.provenance_response = &provenance_response_stream;
  endpoint.valid = true;
  Controller controller{rt, memory};
  controller.portal_endpoint = &endpoint;
  result = controller.claim_owner(output);
  if (result) result = controller.bind(source0);
  if (result && source1.ref.id != Buffer::NONE)
    result = controller.bind(source1);
  if (result) result = controller.issue(task, elements, OutputUnit::F32);
  if (result) result = controller.publish_owner(output);
  if (result && release_output) result = controller.release_owner(output);
  if (!result && !rt.generated_store.active) {
    FullOwnerRecord record;
    const Check snapshot = full_owner_snapshot(rt, output.ref, output.region,
                                               record);
    if (snapshot && (record.state == CacheState::FILL ||
                     record.state == CacheState::EXCLUSIVE_RW))
      (void)controller.invalidate_owner(output);
  }
  return result;
}
#endif

#ifndef LAYA_CONTROLLER_TRANSACTION_SEQUENCER
Check full_execute_generated_layernorm_lifecycle_portal(
    FullRuntime& rt, FullMemory& memory, const FullOwnerSpec& source,
    const FullOwnerSpec& output, const LayerNormTask& task,
    uint32_t elements, bool publish_output,
    hls::stream<ap_uint<512>>& provenance_command_stream,
    hls::stream<ap_uint<512>>& provenance_response_stream,
    hls::stream<ap_uint<512>>& producer_request_stream,
    hls::stream<ap_uint<512>>& producer_completion_stream) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
  portal::ModelBinding portal_model;
  Check result = portal::build_l13m_model_binding(portal_model);
  if (!result) return result;
#else
  PortalEndpoint endpoint;
  Check result = portal::build_l13m_model_binding(endpoint.model);
  if (!result) return result;
  endpoint.provenance_command = &provenance_command_stream;
  endpoint.provenance_response = &provenance_response_stream;
  endpoint.producer_request = &producer_request_stream;
  endpoint.producer_completion = &producer_completion_stream;
  endpoint.valid = true;
#endif
  Controller controller{rt, memory};
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
  result = controller.claim_owner(
      output, provenance_command_stream, provenance_response_stream,
      provenance_command_stream, provenance_response_stream,
      producer_request_stream, producer_completion_stream,
      portal_model, false, true, true);
#else
  controller.portal_endpoint = &endpoint;
  result = controller.claim_owner(output);
#endif
  if (result) result = controller.bind(source);
  if (result) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
    result = controller.issue(
        task, elements, OutputUnit::F32,
        provenance_command_stream, provenance_response_stream,
        provenance_command_stream, provenance_response_stream,
        producer_request_stream, producer_completion_stream,
        portal_model, false, true, true);
#else
    result = controller.issue(task, elements, OutputUnit::F32);
#endif
  }
  if (result && publish_output) {
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
    result = controller.publish_owner(
        output, provenance_command_stream, provenance_response_stream,
        provenance_command_stream, provenance_response_stream,
        producer_request_stream, producer_completion_stream,
        portal_model, false, true, true);
#else
    result = controller.publish_owner(output);
#endif
  }
  if (!result && !rt.generated_store.active) {
    FullOwnerRecord record;
    const Check snapshot = full_owner_snapshot(rt, output.ref, output.region,
                                               record);
    if (snapshot && (record.state == CacheState::FILL ||
                     record.state == CacheState::EXCLUSIVE_RW))
#ifdef LAYA_PARTITIONED_PRODUCTION_CALLER
      (void)controller.invalidate_owner(
          output, provenance_command_stream, provenance_response_stream,
          provenance_command_stream, provenance_response_stream,
          producer_request_stream, producer_completion_stream,
          portal_model, false, true, true);
#else
      (void)controller.invalidate_owner(output);
#endif
  }
  return result;
}
#endif
#endif

} // namespace laya::full
