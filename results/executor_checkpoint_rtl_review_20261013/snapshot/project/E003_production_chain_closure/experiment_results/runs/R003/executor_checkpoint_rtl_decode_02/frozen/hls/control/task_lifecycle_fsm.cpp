#include "laya_task_lifecycle_fsm.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::lifecycle {
namespace {
Check protocol(uint16_t reason = 14) {
  return {Status::E_PROTOCOL, detail(7, 0, reason)};
}

bool same_owner(const full::FullOwnerRecord& r,
                const full::FullOwnerSpec& o) {
  return r.ref == o.ref && r.region == o.region && r.valid &&
      r.state == CacheState::READY && r.stage == o.stage &&
      r.layer == o.layer && r.batch == o.batch &&
      r.row_space == o.row_space && r.row0 == o.row0 &&
      r.rows == o.rows && r.width == o.width && r.content == o.content;
}

void remember(full::FullRuntime& rt, Check result) {
  if (!result && rt.lifecycle_action.first_error)
    rt.lifecycle_action.first_error = result;
}

void failure(Machine& m, full::FullRuntime& rt, Check result) {
  remember(rt, result);
  m.phase = rt.generated_store.active ||
      rt.lifecycle_action.source_release_pending ?
          Phase::ISOLATED : Phase::CLEANUP;
}

bool remote_bound(const Machine& m) {
  constexpr uint32_t bound = transaction::FRAME_COMPLETE |
      transaction::BINDING_OK;
  return (m.response.flags & bound) == bound &&
      !(m.response.flags & transaction::LOCAL_REJECT);
}

bool remote_terminal(const Machine& m) {
  return remote_bound(m) &&
      (m.response.flags & transaction::REMOTE_DRAINED) &&
      (m.response.flags & transaction::REMOTE_TERMINAL) &&
      !(m.response.flags & transaction::REMOTE_SCOPE_ACTIVE);
}

void send(Machine& m, const transaction::Request& request, Phase next) {
  m.transaction = request;
  m.request_packet = transaction::encode(request);
  m.response = transaction::Completion{};
  m.response_result = ok();
  m.beat = 0;
  m.after_transaction = next;
  m.phase = Phase::TX_WRITE;
}

void owner_event(Machine& m, full::FullRuntime& rt,
                 const full::FullMemory& memory,
                 provenance::Action action, Phase next) {
  provenance::Request event;
  Check result = provenance::build_owner_event(
      rt, memory, m.model, action, &m.output, nullptr, 1, event);
  if (!result) {
    failure(m, rt, result);
    // A local INVALIDATE construction failure cannot trigger an endless
    // stream of fresh events or be reported as physical drain.
    if (action == provenance::Action::INVALIDATE) m.phase = Phase::ISOLATED;
    return;
  }
  const uint32_t flags = action == provenance::Action::INVALIDATE ?
      uint32_t(transaction::CANCEL_CLEANUP) : 0u;
  send(m, transaction::make_request(event, flags), next);
}

void base_completion(Machine& m, const action::Request& request) {
  m.completion = action::Completion{};
  auto& c = m.completion;
  c.kind = request.kind; c.pc = request.pc; c.op = request.op;
  c.stage = request.stage; c.layer = request.layer;
  c.ordinal = request.ordinal; c.identity = request.identity;
  c.flags = action::FRAME_COMPLETE | action::BINDING_OK;
}

void reject(Machine& m, Check result) {
  m.completion.result = result;
  m.completion.flags |= action::SAFE_TERMINAL | action::REMOTE_DRAINED |
      action::LOCAL_REJECT;
  m.phase = Phase::COMPLETE;
}

uint32_t output_epoch(const full::FullRuntime& rt, Buffer id,
                      uint8_t bank, uint8_t region) {
  uint32_t epoch = 0;
  for (const auto& record : rt.owners.record)
    if (record.ref.id == id && record.ref.bank == bank &&
        record.region == region && record.max_claimed_epoch > epoch)
      epoch = record.max_claimed_epoch;
  return epoch;
}

void finish(Machine& m, full::FullRuntime& rt) {
  auto& active = rt.lifecycle_action;
  auto& c = m.completion;
  c.result = active.first_error;
  if (rt.tasks_retired < active.previous_tasks_retired ||
      rt.last_task_id < active.previous_task_id ||
      rt.tasks_retired - active.previous_tasks_retired > UINT16_MAX ||
      rt.tasks_retired - active.previous_tasks_retired !=
          rt.last_task_id - active.previous_task_id) {
    remember(rt, protocol());
    m.phase = Phase::ISOLATED;
    return;
  }
  c.retired_tasks = uint16_t(rt.tasks_retired - active.previous_tasks_retired);
  if (c.retired_tasks) {
    c.first_task_id = active.previous_task_id + 1;
    c.last_task_id = rt.last_task_id;
  }
  if (active.active || rt.generated_store.active ||
      active.source_release_pending) {
    m.phase = Phase::ISOLATED;
    return;
  }
  c.flags |= action::SAFE_TERMINAL | action::REMOTE_DRAINED;
  if (c.result) {
    c.flags |= action::SLOT_UPDATE_VALID | action::TYPED_RETIRED;
    c.slot_delta.slot = m.action.target_slot;
    c.slot_delta.version = m.action.target_slot_version;
    c.slot_delta.owner = m.output;
  }
  m.phase = Phase::COMPLETE;
}

bool release_source(Machine& m, full::FullRuntime& rt) {
  Check released = full::full_release_read_owner(rt, m.action.source.owner);
  if (!released) {
    remember(rt, released);
    m.phase = Phase::ISOLATED;
    return false;
  }
  rt.generated_store.source_lease_active = false;
  rt.generated_store.source_lease = full::FullOwnerSpec{};
  rt.lifecycle_action.source_release_pending = false;
  return true;
}
} // namespace

Check start(Machine& m, full::FullRuntime& rt,
             const action::Request& request) {
  if (m.phase != Phase::IDLE || rt.lifecycle_action.active ||
      rt.generated_store.active) return protocol();
  m.action = request;
  base_completion(m, request);
  Check result = action::validate(request);
  if (!result || !rt.request_valid || !rt.model_header_valid ||
      !numeric_identity_equal(request.identity, rt.inputs.identity) ||
      request.ordinal <= m.action_high_water ||
      request.source.version != request.source.owner.ref.epoch) {
    result = result ? protocol(4) : result;
    reject(m, result);
    return result;
  }
  // Only a syntactically admitted action consumes the action key.  Rejected
  // families still consume its ordinal, but no business protocol numbers.
  m.action_high_water = request.ordinal;
  if (request.kind != action::Kind::NORM ||
      (request.op != Op::LN_ATTN && request.op != Op::LN_FFN) ||
      (request.stage != 2 && request.stage != 4) ||
      (request.op == Op::LN_ATTN && request.stage == 2 && request.layer == 0) ||
      request.gamma != 0 || request.target_buffer != Buffer::NORM ||
      request.target_region != 0 || request.source.owner.ref.id != Buffer::HIDDEN ||
      request.source.owner.region != 0 || request.source.owner.batch != 255 ||
      request.source.owner.row_space != RowSpace::TOKEN ||
      request.source.owner.row0 != 0 ||
      request.source.owner.rows != request.identity.S ||
      request.source.owner.width != 1024 ||
      request.source.owner.content != Content::F32) {
    result = protocol(5); reject(m, result); return result;
  }
  full::FullOwnerRecord source;
  result = full::full_owner_snapshot(rt, request.source.owner.ref,
                                     request.source.owner.region, source);
  if (!result || !same_owner(source, request.source.owner)) {
    result = result ? protocol(9) : result;
    reject(m, result); return result;
  }
  result = portal::build_l13m_model_binding(m.model);
  if (!result) { reject(m, result); return result; }
  if (!rt.dispatch_reservations.can_tasks(
          rt.last_task_id, unsigned(request.identity.B) *
              ((unsigned(request.identity.S) + 15u) / 16u))) {
    result = protocol(9); reject(m, result); return result;
  }
  const BufferRef target = rt.dispatch_reservations.ref(
      request.target_buffer, request.target_bank, request.target_region,
      output_epoch(rt, request.target_buffer, request.target_bank,
                   request.target_region));
  if (!target.epoch) { result = protocol(9); reject(m, result); return result; }
  m.output = {target, request.target_region, request.stage, request.layer,
              255, request.source.owner.row_space, 0, request.identity.S,
              1024, Content::F32};
  auto& active = rt.lifecycle_action;
  active = full::FullRuntime::LifecycleActionTracker{};
  active.active = true; active.identity = request.identity;
  active.kind = uint8_t(request.kind); active.pc = request.pc;
  active.op = uint8_t(request.op); active.stage = request.stage;
  active.layer = request.layer; active.request_flags = request.flags;
  active.ordinal = request.ordinal;
  active.source = request.source.owner;
  active.source_slot = request.source.slot;
  active.source_version = request.source.version;
  active.output = m.output; active.target_slot = request.target_slot;
  active.target_slot_version = request.target_slot_version;
  active.target_buffer = uint8_t(request.target_buffer);
  active.target_bank = request.target_bank;
  active.target_region = request.target_region; active.gamma = request.gamma;
  active.previous_task_id = rt.last_task_id;
  active.previous_tasks_retired = rt.tasks_retired;
  m.batch = 0; m.row = 0; m.cancel_pending = false;
  m.phase = Phase::CLAIM;
  return ok();
}

void step(Machine& m, full::FullRuntime& rt, const full::FullMemory& memory,
          bool cancel, hls::stream<ap_uint<512>>& request_stream,
          hls::stream<ap_uint<512>>& completion_stream) {
#pragma HLS pipeline off
  if (m.phase == Phase::IDLE || m.phase == Phase::COMPLETE ||
      m.phase == Phase::ISOLATED) return;
  if (cancel) {
    m.cancel_pending = true;
    remember(rt, protocol());
  }
  auto& active = rt.lifecycle_action;
  Check result = ok();
  switch (m.phase) {
    case Phase::CLAIM:
      if (m.cancel_pending) { m.phase = Phase::CLEANUP; return; }
      result = full::full_claim_owner(rt, m.output);
      if (!result) { active.active = false; remember(rt, result);
        m.phase = Phase::FINISH; return; }
      active.owner_local_claimed = true; active.claim_sent = true;
      owner_event(m, rt, memory, provenance::Action::CLAIM, Phase::OWNER_RESULT);
      return;
    case Phase::OWNER_RESULT:
      if (!remote_bound(m)) { failure(m, rt, protocol()); return; }
      if (!m.response_result || !remote_terminal(m)) {
        failure(m, rt, m.response_result ? protocol() : m.response_result);
        return;
      }
      if (m.transaction.provenance.action == provenance::Action::CLAIM) {
        active.claim_remote_terminal = true;
        m.phase = Phase::PREPARE_WINDOW;
      } else {
        if (!(m.response.flags & transaction::REMOTE_PUBLISHED)) {
          failure(m, rt, protocol()); return;
        }
        active.publish_remote_terminal = true;
        result = full::full_publish_owner(rt, m.output);
        if (!result) { failure(m, rt, result); return; }
        active.active = false;
        m.phase = Phase::FINISH;
      }
      return;
    case Phase::PREPARE_WINDOW: {
      if (!active.first_error || m.cancel_pending) {
        m.phase = Phase::CLEANUP; return;
      }
      if (m.batch == m.action.identity.B) { m.phase = Phase::PUBLISH; return; }
      m.task = LayerNormTask{};
      m.task.ctx = rt.dispatch_reservations.context(
          rt.last_task_id, m.action.op, m.action.stage, m.action.layer,
          m.batch, m.action.source.owner.row_space, m.row,
          uint8_t(m.action.identity.S - m.row < 16 ?
                  m.action.identity.S - m.row : 16));
      m.task.src = m.action.source.owner.ref; m.task.dst = m.output.ref;
      m.task.gamma = m.action.gamma;
      result = full::full_bind_task_source(rt, m.action.source.owner);
      bool protected_task = false;
      if (result) result = provenance::build_generated_begin(
          rt, memory, m.model, m.task, uint32_t(m.task.ctx.rows) * 1024u,
          OutputUnit::F32, m.scope, protected_task);
      if (!result || !protected_task) {
        failure(m, rt, result ? protocol(5) : result); return;
      }
      full::FullOwnerSpec source, destination;
      result = producer::prepare_layernorm(rt, memory, m.task, source, destination);
      if (!result) { failure(m, rt, result); return; }
      active.source_release_pending = true;
      result = producer::build_layernorm_request(
          rt, memory, m.model, m.task, m.scope, m.producer_request);
      if (result) result = provenance::arm_generated_store_tracker(rt, m.scope);
      if (!result) {
        remember(rt, result);
        if (release_source(m, rt)) m.phase = Phase::CLEANUP;
        return;
      }
      rt.generated_store.source_lease = source;
      rt.generated_store.source_lease_active = true;
      active.begin_event_seq = m.scope.event_seq;
      active.begin_response_bound = false; active.begin_scope_active = false;
      send(m, transaction::make_request(m.scope), Phase::BEGIN_RESULT);
      return;
    }
    case Phase::BEGIN_RESULT:
      if (!remote_bound(m)) { failure(m, rt, protocol()); return; }
      active.begin_response_bound = true;
      active.begin_scope_active = m.response.flags & transaction::REMOTE_SCOPE_ACTIVE;
      if (!m.response_result) {
        remember(rt, m.response_result);
        if (!remote_terminal(m)) { m.phase = Phase::ISOLATED; return; }
        if (!release_source(m, rt)) return;
        provenance::clear_generated_store_tracker(rt);
        active.begin_event_seq = 0; active.begin_scope_active = false;
        m.phase = Phase::CLEANUP; return;
      }
      if (!(m.response.flags & transaction::REMOTE_DRAINED) ||
          !(m.response.flags & transaction::REMOTE_SCOPE_ACTIVE) ||
          (m.response.flags & transaction::REMOTE_TERMINAL)) {
        failure(m, rt, protocol()); return;
      }
      send(m, transaction::make_request(m.producer_request), Phase::PRODUCER_RESULT);
      return;
    case Phase::PRODUCER_RESULT: {
      const bool local = m.response.flags & transaction::LOCAL_REJECT;
      if (!(m.response.flags & transaction::FRAME_COMPLETE) ||
          (!local && (!remote_bound(m) || !m.response.producer.finished))) {
        failure(m, rt, protocol()); return;
      }
      result = local ? producer::accept_layernorm_local_reject(
          rt, m.task, m.action.source.owner, m.output, m.scope,
          m.response_result, m.logical_done) :
          producer::accept_layernorm_completion(
              rt, m.task, m.action.source.owner, m.output, m.scope,
              m.response.producer, m.logical_done);
      active.source_release_pending = rt.generated_store.source_lease_active;
      if (result.code != m.response_result.code ||
          result.detail != m.response_result.detail ||
          result.bad_element != m.response_result.bad_element) {
        failure(m, rt, protocol()); return;
      }
      remember(rt, result);
      provenance::Request end;
      result = provenance::build_generated_end(rt, m.scope, m.logical_done, end);
      if (!result) { failure(m, rt, result); return; }
      m.scope = end;
      send(m, transaction::make_request(m.scope, transaction::CANCEL_CLEANUP),
           Phase::END_RESULT);
      return;
    }
    case Phase::END_RESULT: {
      // Never reuse a previous trusted response after this round rejects.
      if (!remote_bound(m)) { failure(m, rt, protocol()); return; }
      active.begin_scope_active = m.response.flags & transaction::REMOTE_SCOPE_ACTIVE;
      if (!remote_terminal(m)) {
        send(m, m.transaction, Phase::END_RESULT); return;
      }
      const auto& response = m.response.provenance;
      TaskDone done;
      done.task_id = m.task.ctx.task_id; done.status = response.status;
      done.error_detail = response.error_detail; done.bad_element = response.bad_element;
      done.output_elements = response.output_elements; done.output_unit = response.unit;
      done.drained = response.drained;
      // A terminal response does not excuse a remaining local reader lease.
      if (rt.generated_store.source_lease_active || active.source_release_pending) {
        failure(m, rt, protocol()); return;
      }
      provenance::clear_generated_store_tracker(rt);
      active.begin_event_seq = 0; active.begin_response_bound = false;
      active.begin_scope_active = false;
      result = full::full_retire_prepared_task(rt, m.task.ctx, done);
      if (result.code != done.status || result.detail != done.error_detail ||
          result.bad_element != done.bad_element) {
        failure(m, rt, protocol()); return;
      }
      result = check_done(done, m.task.ctx.task_id,
                           uint32_t(m.task.ctx.rows) * 1024u, OutputUnit::F32);
      if (result) result = full::full_source_accept_completion(
          rt, m.task.dst, 0, m.task.ctx, 0, 1, done,
          uint32_t(m.task.ctx.rows) * 1024u, OutputUnit::F32);
      if (!result) { failure(m, rt, result); return; }
      m.row = uint16_t(m.row + m.task.ctx.rows);
      if (m.row == m.action.identity.S) { m.row = 0; ++m.batch; }
      m.phase = Phase::PREPARE_WINDOW;
      return;
    }
    case Phase::PUBLISH:
      if (!active.first_error || m.cancel_pending) {
        m.phase = Phase::CLEANUP; return;
      }
      active.publish_sent = true;
      owner_event(m, rt, memory, provenance::Action::PUBLISH, Phase::OWNER_RESULT);
      return;
    case Phase::CLEANUP:
      if (rt.generated_store.active || active.source_release_pending) {
        m.phase = Phase::ISOLATED; return;
      }
      if (!active.owner_local_claimed) {
        active.cleanup_local_complete = true; active.active = false;
        m.phase = Phase::FINISH; return;
      }
      active.cleanup_pending = true;
      owner_event(m, rt, memory, provenance::Action::INVALIDATE, Phase::CLEANUP_RESULT);
      return;
    case Phase::CLEANUP_RESULT:
      if (!remote_bound(m)) { m.phase = Phase::ISOLATED; return; }
      if (!m.response_result || !remote_terminal(m)) {
        // Continue only this immutable cleanup inside the current action.
        send(m, m.transaction, Phase::CLEANUP_RESULT); return;
      }
      active.cleanup_remote_terminal = true;
      result = full::full_invalidate_owner(rt, m.output.ref, m.output.region);
      if (!result) { m.phase = Phase::ISOLATED; return; }
      active.cleanup_local_complete = true; active.cleanup_pending = false;
      active.active = false; rt.expected_task_source_count = 0;
      m.phase = Phase::FINISH; return;
    case Phase::TX_WRITE: {
      ap_uint<512> word = 0;
      for (unsigned byte = 0; byte < 64; ++byte) {
#pragma HLS unroll off
        word.range(byte * 8 + 7, byte * 8) = m.request_packet[m.beat * 64 + byte];
      }
      if (request_stream.write_nb(word) && ++m.beat == transaction::kRequestBeats) {
        m.beat = 0; m.phase = Phase::TX_READ;
      }
      return;
    }
    case Phase::TX_READ: {
      ap_uint<512> word;
      if (!completion_stream.read_nb(word)) return;
      for (unsigned byte = 0; byte < 64; ++byte) {
#pragma HLS unroll off
        m.response_packet[m.beat * 64 + byte] =
            uint8_t(word.range(byte * 8 + 7, byte * 8));
      }
      if (++m.beat == transaction::kCompletionBeats) {
        m.beat = 0; m.phase = Phase::TX_VALIDATE;
      }
      return;
    }
    case Phase::TX_VALIDATE:
      m.response = transaction::Completion{};
      m.response_result = transaction::decode(
          m.response_packet, m.transaction, m.response);
      if (!(m.response.flags & transaction::FRAME_COMPLETE)) {
        failure(m, rt, protocol());
        // A transport rejection never becomes a legitimate END wait/retry.
        m.phase = Phase::ISOLATED;
      } else m.phase = m.after_transaction;
      return;
    case Phase::FINISH: finish(m, rt); return;
    default: return;
  }
}

Check completion_consumed(Machine& m, const full::FullRuntime& rt) {
  constexpr uint32_t safe = action::SAFE_TERMINAL | action::REMOTE_DRAINED;
  if (m.phase != Phase::COMPLETE ||
      (m.completion.flags & safe) != safe || rt.lifecycle_action.active ||
      rt.generated_store.active || rt.lifecycle_action.source_release_pending)
    return protocol();
  m.phase = Phase::IDLE;
  return ok();
}
} // namespace laya::lifecycle
#endif
