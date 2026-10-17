#include "laya_full_runtime.h"

using namespace laya;

namespace {
full::FullRuntime runtime;

full::FullOwnerSpec qkv_spec(uint8_t bank, uint32_t epoch) {
  return {{Buffer::QKV, bank, epoch}, 0, 2, 0, 255,
          RowSpace::TOKEN, 0, 64, 64, Content::QKV_RAW};
}
full::FullOwnerSpec a8_spec(uint32_t epoch) {
  return {{Buffer::A8, 0, epoch}, 0, 2, 0, 0,
          RowSpace::TOKEN, 0, 1, 1024, Content::Q8_TILE};
}
} // namespace

extern "C" void full_owner_index_pilot(
    uint8_t operation, uint32_t* status, uint32_t* slot0_epoch,
    uint32_t* slot1_epoch, uint32_t* slot2_epoch, uint32_t* numeric_epoch,
    uint32_t* claims, uint32_t* slot0_coverage,
    uint32_t* slot2_id, uint32_t* request_high, uint32_t* generation) {
#ifdef __SYNTHESIS__
#pragma HLS INTERFACE s_axilite port=operation bundle=control
#pragma HLS INTERFACE s_axilite port=status bundle=control
#pragma HLS INTERFACE s_axilite port=slot0_epoch bundle=control
#pragma HLS INTERFACE s_axilite port=slot1_epoch bundle=control
#pragma HLS INTERFACE s_axilite port=slot2_epoch bundle=control
#pragma HLS INTERFACE s_axilite port=numeric_epoch bundle=control
#pragma HLS INTERFACE s_axilite port=claims bundle=control
#pragma HLS INTERFACE s_axilite port=slot0_coverage bundle=control
#pragma HLS INTERFACE s_axilite port=slot2_id bundle=control
#pragma HLS INTERFACE s_axilite port=request_high bundle=control
#pragma HLS INTERFACE s_axilite port=generation bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control
#endif
  Check result = ok();
  switch (operation) {
  case 0:
    runtime.inputs.identity.request_id = 10;
    runtime.inputs.identity.generation = 1;
    runtime.inputs.identity.B = 1;
    runtime.inputs.identity.S = 64;
    runtime.inputs.identity.model_tag[0] = 1;
    runtime.inputs.identity.numeric_tag[0] = 2;
    runtime.inputs.identity.layout_tag[0] = 3;
    runtime.inputs.identity.build_tag[0] = 4;
    runtime.session_generation = 1;
    runtime.last_accepted_request_id = 10;
    runtime.request_valid = true;
    runtime.model_header_valid = true;
    break;
  case 1: {
    const full::FullOwnerSpec pair[2] = {qkv_spec(0, 1), qkv_spec(1, 1)};
    result = full::full_claim_qkv_pair(runtime, pair);
    break;
  }
  case 2:
    result = full::full_invalidate_owner(runtime, {Buffer::QKV, 0, 1}, 0);
    break;
  case 3: {
    const full::FullOwnerSpec pair[2] = {qkv_spec(0, 2), qkv_spec(1, 2)};
    result = full::full_claim_qkv_pair(runtime, pair);
    break;
  }
  case 4:
    result = full::full_recycle_request(runtime);
    break;
  case 5:
    result = full::full_invalidate_owner(runtime, {Buffer::QKV, 1, 1}, 0);
    break;
  case 6:
    result = full::full_recycle_request(runtime);
    break;
  case 7:
    // Saturate the 32-record table with no A8 owner. The numeric A8 history
    // requires a new slot, so recycle must fail before clearing any state.
    for (unsigned i = 2; i < 32; ++i)
      runtime.owners.record[i].ref = {Buffer::HIDDEN, 0, 1};
    runtime.owners.record[0].covered_rows[0] = 0x55;
    runtime.owner_claims = 7;
    runtime.cache.activation_meta.ref = {Buffer::A8, 0, 3};
    result = full::full_recycle_request(runtime);
    break;
  case 8:
    for (unsigned i = 2; i < 32; ++i)
      runtime.owners.record[i].ref = none();
    result = full::full_recycle_request(runtime);
    break;
  case 9:
    runtime.request_valid = true;
    runtime.model_header_valid = true;
    result = full::full_claim_owner(runtime, a8_spec(4));
    break;
  case 10:
    result = full::full_invalidate_owner(runtime, {Buffer::A8, 0, 4}, 0);
    if (result) {
      runtime.cache.activation_meta.ref = none();
      result = full::full_recycle_request(runtime);
    }
    break;
  case 11:
    runtime.cache.activation_meta.ref = {Buffer::A8, 0, 2};
    result = full::full_recycle_request(runtime);
    break;
  case 12:
    runtime.cache.activation_meta.ref = {Buffer::A8, 0, 6};
    result = full::full_recycle_request(runtime);
    break;
  case 13:
    result = full::full_soft_reset(runtime, 2);
    break;
  default:
    result = {Status::E_PROTOCOL, 0};
    break;
  }
  *status = uint32_t(result.code);
  *slot0_epoch = runtime.owners.record[0].ref.epoch;
  *slot1_epoch = runtime.owners.record[1].ref.epoch;
  *slot2_epoch = runtime.owners.record[2].ref.epoch;
  *numeric_epoch = runtime.cache.activation_meta.ref.epoch;
  *claims = runtime.owner_claims;
  *slot0_coverage = runtime.owners.record[0].covered_rows[0];
  *slot2_id = uint32_t(runtime.owners.record[2].ref.id);
  *request_high = uint32_t(runtime.last_accepted_request_id);
  *generation = uint32_t(runtime.session_generation);
}
