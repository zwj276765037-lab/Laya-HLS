#include "laya_controller_transaction_dispatch.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::transaction {
namespace {

Check protocol(uint16_t reason = 14) {
  return {Status::E_PROTOCOL, detail(7, 0, reason)};
}

Check rejected(uint32_t task_id, Check result, TaskDone& done,
               bool drained = true) {
  done = TaskDone{};
  done.task_id = task_id;
  done.status = result.code;
  done.error_detail = result.detail;
  done.bad_element = result.bad_element;
  done.drained = drained;
  return result;
}

bool usable_completion(const Completion& completion, Kind kind) {
  return completion.kind == kind && completion_frame_complete(completion) &&
      ((completion.flags & LOCAL_REJECT) ||
       completion_binding_ok(completion));
}

Check one(hls::stream<ap_uint<512>>& request_stream,
          hls::stream<ap_uint<512>>& completion_stream,
          const portal::Command& command, uint32_t elements, OutputUnit unit,
          TaskDone& done) {
  portal::Response response;
  uint32_t flags = 0;
  Check result = exchange_compute(request_stream, completion_stream, command,
                                  response, &flags);
  if (!(flags & FRAME_COMPLETE))
    return rejected(command.context.task_id, protocol(), done, false);
  const bool local_reject = flags & LOCAL_REJECT;
  done = TaskDone{};
  done.task_id = command.context.task_id;
  done.status = result.code;
  done.error_detail = result.detail;
  done.bad_element = result.bad_element;
  done.drained = local_reject || bool(flags & REMOTE_DRAINED);
  if (result) {
    done.output_elements = elements;
    done.output_unit = unit;
  }
  return result;
}

} // namespace

Check exchange_compute(hls::stream<ap_uint<512>>& request_stream,
                       hls::stream<ap_uint<512>>& completion_stream,
                       const portal::Command& command,
                       portal::Response& response,
                       uint32_t* completion_flags) {
  const Request request = make_request(command);
  Completion completion;
  Check result = exchange(request_stream, completion_stream, request,
                          completion);
  if (!usable_completion(completion, Kind::COMPUTE_TRANSACTION)) {
    if (completion_flags) *completion_flags = 0;
    return protocol();
  }
  if (completion_flags) *completion_flags = completion.flags;
  response = completion.compute;
  return result;
}

Check exchange_provenance(hls::stream<ap_uint<512>>& request_stream,
                          hls::stream<ap_uint<512>>& completion_stream,
                          const provenance::Request& request_value,
                          provenance::Response& response,
                          uint32_t* completion_flags) {
  const uint32_t flags =
      request_value.action == provenance::Action::END ||
      request_value.action == provenance::Action::RELEASE ||
      request_value.action == provenance::Action::INVALIDATE ?
          uint32_t(CANCEL_CLEANUP) : 0u;
  const Request request = make_request(request_value, flags);
  Completion completion;
  Check result = exchange(request_stream, completion_stream, request,
                          completion);
  if (!usable_completion(completion, Kind::PROVENANCE_TRANSACTION)) {
    if (completion_flags) *completion_flags = 0;
    return protocol();
  }
  if (completion_flags) *completion_flags = completion.flags;
  response = completion.provenance;
  return result;
}

Check exchange_producer(hls::stream<ap_uint<512>>& request_stream,
                        hls::stream<ap_uint<512>>& completion_stream,
                        const producer::Request& request_value,
                        producer::Completion& response,
                        uint32_t* completion_flags) {
  const Request request = make_request(request_value);
  Completion completion;
  Check result = exchange(request_stream, completion_stream, request,
                          completion);
  if (!usable_completion(completion, Kind::PRODUCER_TRANSACTION)) {
    if (completion_flags) *completion_flags = 0;
    return protocol();
  }
  if (completion_flags) *completion_flags = completion.flags;
  response = completion.producer;
  return result;
}

Check dispatch_load(hls::stream<ap_uint<512>>& request_stream,
                    hls::stream<ap_uint<512>>& completion_stream,
                    const NumericIdentity& identity,
                    const full::FullMemory& memory,
                    const portal::ModelBinding& model,
                    const full::FullWeightDescriptor& descriptor,
                    const LoadTask& task, uint64_t generation,
                    TaskDone& done) {
  portal::Command command;
  Check result = portal::build_load_command(identity, memory, model,
                                            descriptor, task, generation,
                                            command);
  if (!result) return rejected(task.ctx.task_id, result, done);
  return one(request_stream, completion_stream, command, task.byte_count,
             OutputUnit::BYTES, done);
}

Check dispatch_quant(hls::stream<ap_uint<512>>& request_stream,
                     hls::stream<ap_uint<512>>& completion_stream,
                     const NumericIdentity& identity,
                     const full::FullMemory& memory,
                     const portal::ModelBinding& model,
                     const portal::TaskBinding& binding,
                     uint64_t generation, TaskDone& done) {
  portal::Command command;
  Check result = portal::build_quant_command(identity, memory, model, binding,
                                             generation, command);
  if (!result) return rejected(binding.quant.ctx.task_id, result, done);
  const uint32_t elements = uint32_t(binding.quant.ctx.rows) *
                            binding.quant.K / 32u;
  return one(request_stream, completion_stream, command, elements,
             OutputUnit::Q8_GROUP, done);
}

Check dispatch_geglu(hls::stream<ap_uint<512>>& request_stream,
                     hls::stream<ap_uint<512>>& completion_stream,
                     const NumericIdentity& identity,
                     const full::FullMemory& memory,
                     const portal::ModelBinding& model,
                     const VectorTask& producer_task,
                     const portal::TaskBinding& binding,
                     uint64_t generation, TaskDone& done) {
  portal::Command command;
  Check result = portal::build_geglu_command(identity, memory, model,
                                             producer_task, binding,
                                             generation, command);
  if (!result) return rejected(producer_task.ctx.task_id, result, done);
  const uint32_t elements = uint32_t(producer_task.ctx.rows) *
                            producer_task.length;
  return one(request_stream, completion_stream, command, elements,
             OutputUnit::F32, done);
}

Check dispatch_matrix(hls::stream<ap_uint<512>>& request_stream,
                      hls::stream<ap_uint<512>>& completion_stream,
                      const NumericIdentity& identity,
                      const full::FullMemory& memory,
                      const portal::ModelBinding& model,
                      const portal::TaskBinding& binding,
                      const full::ViewTicket* views, uint8_t count,
                      TaskDone& done) {
  if (!views || !count || count > full::kMatrixViews)
    return rejected(binding.linear.ctx.task_id,
                    {Status::E_PROTOCOL,
                     detail(7, uint8_t(portal::Service::MATRIX), 9)}, done);
  Check first_error = ok();
  uint64_t first_rank = UINT64_MAX;
  uint32_t rows = 0;
  for (unsigned index = 0; index < count; ++index) {
    portal::Command command;
    Check result = portal::build_matrix_command(identity, memory, model,
                                                binding, views[index],
                                                command);
    if (!result)
      return rejected(binding.linear.ctx.task_id, result, done);
    portal::Response response;
    uint32_t flags = 0;
    result = exchange_compute(request_stream, completion_stream, command,
                              response, &flags);
    if (!(flags & FRAME_COMPLETE))
      return rejected(binding.linear.ctx.task_id, protocol(), done, false);
    if (flags & LOCAL_REJECT)
      return rejected(binding.linear.ctx.task_id, result, done);
    rows += command.rows;
    if (!result && (first_error || response.first_error_rank < first_rank)) {
      first_error = result;
      first_rank = response.first_error_rank;
    }
  }
  if (rows != binding.linear.ctx.rows)
    return rejected(binding.linear.ctx.task_id,
                    {Status::E_PROTOCOL,
                     detail(7, uint8_t(portal::Service::MATRIX), 9)}, done);
  if (!first_error)
    return rejected(binding.linear.ctx.task_id, first_error, done);
  done = TaskDone{};
  done.task_id = binding.linear.ctx.task_id;
  done.status = Status::OK;
  done.output_elements = uint32_t(binding.linear.ctx.rows) * binding.linear.N;
  done.output_unit = OutputUnit::F32;
  done.drained = true;
  return ok();
}

} // namespace laya::transaction
#endif
