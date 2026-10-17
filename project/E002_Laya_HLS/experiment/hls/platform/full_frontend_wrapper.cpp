#include "laya_frontend_observed.h"
#include "laya_full_runtime.h"
#include "laya_model_layout_generated.h"

namespace {
static laya::full::FullRuntime runtime;
static laya::full::FullRuntime cpu_runtime;

uint32_t lo(uint64_t value) { return uint32_t(value); }
uint32_t hi(uint64_t value) { return uint32_t(value >> 32); }

uint32_t tag_word(const uint8_t tag[16], unsigned word) {
  const unsigned i = 4 * word;
  return uint32_t(tag[i]) | (uint32_t(tag[i + 1]) << 8) |
         (uint32_t(tag[i + 2]) << 16) | (uint32_t(tag[i + 3]) << 24);
}

void write_owner(const laya::full::FullRuntime& rt, uint32_t* observed,
                 unsigned ordinal, laya::Buffer id, uint8_t bank) {
  using namespace laya::full::front_observed;
  const unsigned base = kGlobalWords + ordinal * kOwnerWords;
  for (unsigned i = 0; i < kOwnerWords; ++i) observed[base + i] = 0;
  for (unsigned slot = 0; slot < 32; ++slot) {
    const laya::full::FullOwnerRecord& r = rt.owners.record[slot];
    if (r.ref.id != id || r.ref.bank != bank || r.region != 0) continue;
    observed[base + FOUND] = 1;
    observed[base + SLOT] = slot;
    observed[base + REF_ID] = uint8_t(r.ref.id);
    observed[base + REF_BANK] = r.ref.bank;
    observed[base + REF_EPOCH] = r.ref.epoch;
    observed[base + MAX_CLAIMED_EPOCH] = r.max_claimed_epoch;
    observed[base + REGION] = r.region;
    observed[base + STAGE] = r.stage;
    observed[base + LAYER] = r.layer;
    observed[base + BATCH] = r.batch;
    observed[base + ROW_SPACE] = uint8_t(r.row_space);
    observed[base + ROW0] = r.row0;
    observed[base + ROWS] = r.rows;
    observed[base + WIDTH] = r.width;
    observed[base + CONTENT] = uint8_t(r.content);
    observed[base + STATE] = uint8_t(r.state);
    observed[base + READERS] = r.readers;
    observed[base + VALID] = r.valid;
    observed[base + IDENTITY_B] = r.identity.B;
    observed[base + IDENTITY_S] = r.identity.S;
    observed[base + IDENTITY_REQUEST_LO] = lo(r.identity.request_id);
    observed[base + IDENTITY_REQUEST_HI] = hi(r.identity.request_id);
    observed[base + IDENTITY_GENERATION_LO] = lo(r.identity.generation);
    observed[base + IDENTITY_GENERATION_HI] = hi(r.identity.generation);
    for (unsigned w = 0; w < 4; ++w) {
      observed[base + MODEL_TAG0 + w] = tag_word(r.identity.model_tag, w);
      observed[base + NUMERIC_TAG0 + w] = tag_word(r.identity.numeric_tag, w);
      observed[base + LAYOUT_TAG0 + w] = tag_word(r.identity.layout_tag, w);
      observed[base + BUILD_TAG0 + w] = tag_word(r.identity.build_tag, w);
    }
    for (unsigned w = 0; w < 64; ++w)
      observed[base + COVERAGE0 + w] = r.covered_rows[w];
    break;
  }
}

void write_observation(const laya::full::FullRuntime& rt,
                       const laya::Check result,
                       const laya::full::FullOwnerSpec& output,
                       uint32_t* observed, bool cpu_profile = false) {
  using namespace laya::full::front_observed;
  for (unsigned i = 0; i < kGlobalWords; ++i) observed[i] = 0;
  observed[MAGIC] = cpu_profile ? kCpuMagic : kMagic;
  observed[VERSION] = kVersion;
  observed[WORDS] = cpu_profile ? kCpuWords : kWords;
  observed[STATUS] = uint16_t(result.code);
  observed[DETAIL] = result.detail;
  observed[BAD_ELEMENT_LO] = lo(result.bad_element);
  observed[BAD_ELEMENT_HI] = hi(result.bad_element);
  observed[LAST_EXEC_STATUS] = uint16_t(rt.last_execution_error.code);
  observed[LAST_EXEC_DETAIL] = rt.last_execution_error.detail;
  observed[LAST_CLEANUP_STATUS] = uint16_t(rt.last_cleanup_error.code);
  observed[LAST_CLEANUP_DETAIL] = rt.last_cleanup_error.detail;
  observed[REQUEST_VALID] = rt.request_valid;
  observed[MODEL_HEADER_VALID] = rt.model_header_valid;
  observed[DIAGNOSTIC_IDENTITY_VALID] = rt.diagnostic_identity_valid;
  observed[DIAGNOSTIC_SHAPE_VALID] = rt.diagnostic_shape_valid;
  observed[DIAGNOSTIC_REQUEST_LO] = lo(rt.diagnostic_request_id);
  observed[DIAGNOSTIC_REQUEST_HI] = hi(rt.diagnostic_request_id);
  observed[DIAGNOSTIC_GENERATION_LO] = lo(rt.diagnostic_generation);
  observed[DIAGNOSTIC_GENERATION_HI] = hi(rt.diagnostic_generation);
  observed[DIAGNOSTIC_B] = rt.diagnostic_B;
  observed[DIAGNOSTIC_S] = rt.diagnostic_S;
  observed[INPUT_REQUEST_LO] = lo(rt.inputs.identity.request_id);
  observed[INPUT_REQUEST_HI] = hi(rt.inputs.identity.request_id);
  observed[INPUT_GENERATION_LO] = lo(rt.inputs.identity.generation);
  observed[INPUT_GENERATION_HI] = hi(rt.inputs.identity.generation);
  observed[INPUT_B] = rt.inputs.identity.B;
  observed[INPUT_S] = rt.inputs.identity.S;
  observed[SESSION_GENERATION_LO] = lo(rt.session_generation);
  observed[SESSION_GENERATION_HI] = hi(rt.session_generation);
  observed[LAST_ACCEPTED_REQUEST_LO] = lo(rt.last_accepted_request_id);
  observed[LAST_ACCEPTED_REQUEST_HI] = hi(rt.last_accepted_request_id);
  observed[TASKS_RETIRED] = rt.tasks_retired;
  observed[LAST_TASK_ID] = rt.last_task_id;
  observed[OWNER_CLAIMS] = rt.owner_claims;
  observed[OWNER_LEASES] = rt.owner_leases;
  observed[EMB_TOKEN_CALLS] = rt.op_calls[uint8_t(laya::Op::EMB_TOKEN)];
  observed[LOAD_LN_PARAMS_CALLS] = rt.op_calls[uint8_t(laya::Op::LOAD_LN_PARAMS)];
  observed[LN_EMB_CALLS] = rt.op_calls[uint8_t(laya::Op::LN_EMB)];
  observed[ENCODER_LAYERS] = rt.encoder_layers_completed;
  observed[DECISION_LAYERS] = rt.decision_layers_completed;
  observed[OUTPUT_ID] = uint8_t(output.ref.id);
  observed[OUTPUT_BANK] = output.ref.bank;
  observed[OUTPUT_EPOCH] = output.ref.epoch;
  observed[OUTPUT_REGION] = output.region;
  observed[OUTPUT_STAGE] = output.stage;
  observed[OUTPUT_LAYER] = output.layer;
  observed[OUTPUT_BATCH] = output.batch;
  observed[OUTPUT_ROW_SPACE] = uint8_t(output.row_space);
  observed[OUTPUT_ROW0] = output.row0;
  observed[OUTPUT_ROWS] = output.rows;
  observed[OUTPUT_WIDTH] = output.width;
  observed[OUTPUT_CONTENT] = uint8_t(output.content);
  uint32_t live_readers = 0;
  uint32_t incomplete_owners = 0;
  for (unsigned i = 0; i < 32; ++i) {
    const auto& r = rt.owners.record[i];
    live_readers += r.readers;
    if (r.ref.id != laya::Buffer::NONE &&
        (r.state == laya::CacheState::FILL ||
         r.state == laya::CacheState::READ ||
         r.state == laya::CacheState::EXCLUSIVE_RW))
      ++incomplete_owners;
  }
  observed[LIVE_READERS] = live_readers;
  observed[INCOMPLETE_OWNERS] = incomplete_owners;
  write_owner(rt, observed, 0, laya::Buffer::HIDDEN, 0);
  write_owner(rt, observed, 1, laya::Buffer::LN_GAMMA, 0);
  write_owner(rt, observed, 2, laya::Buffer::HIDDEN, 1);
  if (cpu_profile) {
    for (unsigned i = PROFILE; i < kCpuWords; ++i) observed[i] = 0;
    const auto& d = rt.cpu_import;
    observed[PROFILE] = 1;
    observed[DESCRIPTOR_VALID] = d.descriptor_valid;
    observed[ADMITTED] = d.admitted;
    observed[IMPORTS_STARTED] = d.imports_started;
    observed[IMPORTS_COMMITTED] = d.imports_committed;
    observed[RAW_VERIFIED] = d.raw_verified;
    observed[EXPECTED_RAW_CRC] = d.expected_raw_crc;
    observed[ACTUAL_RAW_CRC] = d.actual_raw_crc;
    observed[RAW_BYTES_LO] = lo(d.raw_bytes_scanned);
    observed[RAW_BYTES_HI] = hi(d.raw_bytes_scanned);
    observed[RAW_ELEMENTS_LO] = lo(d.raw_elements_scanned);
    observed[RAW_ELEMENTS_HI] = hi(d.raw_elements_scanned);
    observed[IMPORT_ROWS_COVERED] = d.import_rows_covered;
    observed[DESCRIPTOR_ERROR_OFFSET] = d.descriptor_error_offset;
    observed[IMPORT_BAD_ELEMENT_LO] = lo(d.import_bad_element);
    observed[IMPORT_BAD_ELEMENT_HI] = hi(d.import_bad_element);
    observed[REACHED_PHASE] = d.reached_phase;
    observed[FIRST_ERROR_STAGE] = d.first_error_stage;
    observed[FIRST_ERROR_OPERATOR] = d.first_error_operator;
    observed[FIRST_ERROR_TASK_ID] = d.first_error_task_id;
    observed[CLEANUP_ATTEMPTED] = d.cleanup_attempted;
    observed[CLEANUP_COMPLETED] = d.cleanup_completed;
    observed[SCAN_COMPLETE] = d.scan_complete;
    observed[REQUEST_CRC_VALID] = d.request_crc_valid;
    observed[DESCRIPTOR_CRC_VALID] = d.descriptor_crc_valid;
    observed[EXPECTED_REQUEST_CRC] = d.expected_request_crc;
    observed[ACTUAL_REQUEST_CRC] = d.actual_request_crc;
    observed[EXPECTED_DESCRIPTOR_CRC] = d.expected_descriptor_crc;
    observed[ACTUAL_DESCRIPTOR_CRC] = d.actual_descriptor_crc;
  }
}
} // namespace

extern "C" void laya_frontend_chain(
    const uint8_t* embedding, uint8_t* io, const uint8_t* aux,
    uint8_t* state0, uint8_t* state1, uint32_t* observed) {
#ifdef __SYNTHESIS__
#pragma HLS INTERFACE m_axi port=embedding offset=slave bundle=embedding max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=io offset=slave bundle=io max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=aux max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=state0 offset=slave bundle=state0 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=state1 offset=slave bundle=state1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=observed offset=slave bundle=observed max_widen_bitwidth=32 num_write_outstanding=1
#pragma HLS INTERFACE s_axilite port=return bundle=control
#endif
  laya::full::FullMemory memory{};
  memory.embedding = embedding;
  memory.embedding_bytes = laya::full::kFullModelBoSizes[0];
  memory.io = io;
  memory.io_bytes = 32768u;
  memory.aux = aux;
  memory.aux_bytes = laya::full::kFullModelBoSizes[4];
  memory.state0 = state0;
  memory.state0_bytes = 16920576u;
  memory.state1 = state1;
  memory.state1_bytes = 16919104u;
#ifndef __SYNTHESIS__
  runtime.memory = memory;
#endif
  laya::full::FullOwnerSpec output{};
  const laya::Check result =
      laya::full::full_execute_frontend(runtime, memory, output);
  write_observation(runtime, result, output, observed);
}

extern "C" void laya_cpu_embedding_ln_chain(
    const uint8_t* io, const uint8_t* aux,
    const uint8_t* state0, uint8_t* state1, uint32_t* observed) {
#ifdef __SYNTHESIS__
#pragma HLS INTERFACE m_axi port=io offset=slave bundle=io max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=aux offset=slave bundle=aux max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=state0 offset=slave bundle=state0 max_widen_bitwidth=512 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=state1 offset=slave bundle=state1 max_widen_bitwidth=512 num_read_outstanding=1 num_write_outstanding=1
#pragma HLS INTERFACE m_axi port=observed offset=slave bundle=observed max_widen_bitwidth=32 num_write_outstanding=1
#pragma HLS INTERFACE s_axilite port=return bundle=control
#endif
  laya::full::FullMemory memory{};
  memory.io = const_cast<uint8_t*>(io);
  memory.io_bytes = 32768u;
  memory.aux = aux;
  memory.aux_bytes = laya::full::kFullModelBoSizes[4];
  memory.state0 = const_cast<uint8_t*>(state0);
  memory.state0_bytes = 16920576u;
  memory.state1 = state1;
  memory.state1_bytes = 16919104u;
#ifndef __SYNTHESIS__
  cpu_runtime.memory = memory;
#endif
  laya::full::FullOwnerSpec output{};
  const laya::Check result =
      laya::full::full_execute_cpu_frontend(cpu_runtime, memory, output);
  write_observation(cpu_runtime, result, output, observed, true);
}
