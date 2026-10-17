#include "laya_compute_portal_dispatch.h"

#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
namespace laya::portal {
namespace {

bool same_context(const TaskContext& a, const TaskContext& b) {
  return a.task_id == b.task_id && a.op == b.op && a.stage == b.stage &&
         a.layer == b.layer && a.batch == b.batch &&
         a.row_space == b.row_space && a.row0 == b.row0 && a.rows == b.rows;
}

bool trusted_failure(const Response& response, const Command& command,
                     Check result) {
  return !result && response.status == result.code &&
         response.error_detail == result.detail &&
         response.bad_element == result.bad_element && response.drained &&
         !response.published && response.service == command.service &&
         response.generation == command.generation &&
         response.task_id == command.context.task_id &&
         numeric_identity_equal(response.identity, command.identity) &&
         same_context(response.context, command.context) &&
         same_context(response.producer_context, command.producer_context) &&
         same_context(response.quant_context, command.quant_context) &&
         same_context(response.linear_context, command.linear_context) &&
         response.source == command.source && response.a == command.a &&
         response.w == command.w && response.ps == command.ps &&
         response.dst == command.dst && response.future_dst == command.future_dst &&
         response.source_region == command.source_region &&
         response.dst_region == command.dst_region &&
         response.future_dst_region == command.future_dst_region &&
         response.a_epoch == command.a_epoch && response.w_epoch == command.w_epoch &&
         response.rows == command.rows && response.row_block == command.row_block;
}

Check rejected(uint32_t task_id, Check result, TaskDone& done) {
  done = TaskDone{};
  done.task_id = task_id;
  done.status = result.code;
  done.error_detail = result.detail;
  done.bad_element = result.bad_element;
  done.drained = true;
  return result;
}

Check one(hls::stream<ap_uint<512>>& command_stream,
          hls::stream<ap_uint<512>>& response_stream,
          const Command& command, uint32_t elements, OutputUnit unit,
          TaskDone& done) {
  Response response{};
  const Check result = exchange(command_stream, response_stream,
                                command, response);
  if (!result && !trusted_failure(response, command, result))
    return rejected(command.context.task_id,
                    {Status::E_PROTOCOL, detail(4, 0, 21)}, done);
  done = TaskDone{};
  done.task_id = command.context.task_id;
  done.status = result.code;
  done.error_detail = result.detail;
  done.bad_element = result.bad_element;
  done.drained = true;
  if (result) {
    done.output_elements = elements;
    done.output_unit = unit;
  }
  return result;
}

} // namespace

Check dispatch_load(hls::stream<ap_uint<512>>& command_stream,
                    hls::stream<ap_uint<512>>& response_stream,
                    const NumericIdentity& identity,
                    const full::FullMemory& memory,
                    const ModelBinding& model,
                    const full::FullWeightDescriptor& descriptor,
                    const LoadTask& task, uint64_t generation,
                    TaskDone& done) {
  Command command;
  Check result = build_load_command(identity, memory, model, descriptor,
                                    task, generation, command);
  if (!result) return rejected(task.ctx.task_id, result, done);
  return one(command_stream, response_stream, command, task.byte_count,
             OutputUnit::BYTES, done);
}

Check dispatch_quant(hls::stream<ap_uint<512>>& command_stream,
                     hls::stream<ap_uint<512>>& response_stream,
                     const NumericIdentity& identity,
                     const full::FullMemory& memory,
                     const ModelBinding& model, const TaskBinding& binding,
                     uint64_t generation, TaskDone& done) {
  Command command;
  Check result = build_quant_command(identity, memory, model, binding,
                                     generation, command);
  if (!result) return rejected(binding.quant.ctx.task_id, result, done);
  const uint32_t elements = uint32_t(binding.quant.ctx.rows) *
                            binding.quant.K / 32u;
  return one(command_stream, response_stream, command, elements,
             OutputUnit::Q8_GROUP, done);
}

Check dispatch_geglu(hls::stream<ap_uint<512>>& command_stream,
                     hls::stream<ap_uint<512>>& response_stream,
                     const NumericIdentity& identity,
                     const full::FullMemory& memory,
                     const ModelBinding& model, const VectorTask& producer,
                     const TaskBinding& binding, uint64_t generation,
                     TaskDone& done) {
  Command command;
  Check result = build_geglu_command(identity, memory, model, producer,
                                     binding, generation, command);
  if (!result) return rejected(producer.ctx.task_id, result, done);
  const uint32_t elements = uint32_t(producer.ctx.rows) * producer.length;
  return one(command_stream, response_stream, command, elements,
             OutputUnit::F32, done);
}

Check dispatch_matrix(hls::stream<ap_uint<512>>& command_stream,
                      hls::stream<ap_uint<512>>& response_stream,
                      const NumericIdentity& identity,
                      const full::FullMemory& memory,
                      const ModelBinding& model, const TaskBinding& binding,
                      const full::ViewTicket* views, uint8_t count,
                      TaskDone& done) {
  if (!views || !count || count > full::kMatrixViews)
    return rejected(binding.linear.ctx.task_id,
                    {Status::E_PROTOCOL,
                     detail(7, uint8_t(Service::MATRIX), 9)}, done);
  Check first_error = ok();
  uint64_t first_rank = UINT64_MAX;
  uint32_t rows = 0;
  for (unsigned index = 0; index < count; ++index) {
    Command command;
    Check result = build_matrix_command(identity, memory, model, binding,
                                        views[index], command);
    if (!result)
      return rejected(binding.linear.ctx.task_id, result, done);
    Response response{};
    result = exchange(command_stream, response_stream, command, response);
    if (!result && !trusted_failure(response, command, result))
      return rejected(binding.linear.ctx.task_id,
                      {Status::E_PROTOCOL, detail(4, 0, 21)}, done);
    rows += command.rows;
    if (!result && (first_error || response.first_error_rank < first_rank)) {
      first_error = result;
      first_rank = response.first_error_rank;
    }
  }
  if (rows != binding.linear.ctx.rows)
    return rejected(binding.linear.ctx.task_id,
                    {Status::E_PROTOCOL,
                     detail(7, uint8_t(Service::MATRIX), 9)}, done);
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

} // namespace laya::portal
#endif

