#include "laya_producer_engine_hls.h"
#include "laya_full_numeric.h"
#include "laya_numeric.h"
#include "laya_model_layout_generated.h"

#ifdef LAYA_PRODUCER_ENGINE_HAS_HLS_STREAM
namespace laya::producer {
namespace {

bool same_bytes(const uint8_t* a, const uint8_t* b, unsigned count) {
  for (unsigned i = 0; i < count; ++i)
    if (a[i] != b[i]) return false;
  return true;
}

bool exact_model(const Request& request) {
  const uint8_t* p = request.model_identity.data();
  if (!same_bytes(p, full::kFullModelTag, 16) ||
      !same_bytes(p + 16, full::kFullNumericTag, 16) ||
      !same_bytes(p + 32, full::kFullLayoutTag, 16) ||
      !same_bytes(p + 48, full::kFullBuildTag, 16) ||
      !same_bytes(p + 80, full::kFullSourceSha256, 32) ||
      !same_bytes(request.identity.model_tag, full::kFullModelTag, 16) ||
      !same_bytes(request.identity.numeric_tag, full::kFullNumericTag, 16) ||
      !same_bytes(request.identity.layout_tag, full::kFullLayoutTag, 16) ||
      !same_bytes(request.identity.build_tag, full::kFullBuildTag, 16))
    return false;
  constexpr uint8_t roles[5] = {uint8_t(Bo::EMBEDDING), uint8_t(Bo::W_Q0),
      uint8_t(Bo::W_Q1), uint8_t(Bo::W_SCALE), uint8_t(Bo::AUX)};
  for (unsigned i = 0; i < 5; ++i) {
    const unsigned off = 128 + 16 * i;
    if (portal::get(p, off, 4) != roles[i] ||
        portal::get(p, off + 4, 4) != 1 ||
        portal::get(p, off + 8, 8) != full::kFullModelBoSizes[i])
      return false;
  }
  return true;
}

Check supported(const Request& r) {
  const bool op = r.context.op == Op::LN_ATTN || r.context.op == Op::LN_FFN;
  const bool stage = r.context.stage == 2 || r.context.stage == 4;
  const uint64_t source_expected =
      (uint64_t(r.context.batch) * 1024u + r.context.row0) * 4096u;
  const uint64_t destination_expected =
      8u * 1024u * 1024u + source_expected;
  const Bo source_role = r.source.bank ? Bo::STATE1 : Bo::STATE0;
  if (!exact_model(r))
    return {Status::E_MODEL, detail(4, 0, 4)};
  if (!op || !stage || r.context.row_space != RowSpace::TOKEN ||
      r.gamma != 0 || r.source.id != Buffer::HIDDEN ||
      r.destination.id != Buffer::NORM || r.source_region ||
      r.destination_region || r.source_role != source_role ||
      r.destination_role != Bo::STATE0 ||
      r.source_first_offset != source_expected ||
      r.destination_first_offset != destination_expected)
    return {Status::E_SHAPE, detail(7, uint8_t(r.context.op), 5)};
  return ok();
}

Completion base_completion(const Request& r) {
  Completion c;
  c.family = r.family; c.request_seq = r.request_seq;
  c.provenance_origin_seq = r.provenance_origin_seq;
  c.identity = r.identity; c.context = r.context;
  c.source = r.source; c.destination = r.destination;
  c.D = r.D; c.gamma = r.gamma;
  c.source_region = r.source_region;
  c.destination_region = r.destination_region;
  c.source_role = r.source_role; c.destination_role = r.destination_role;
  c.eps_bits = r.eps_bits; c.row_bytes = r.row_bytes;
  c.source_first_offset = r.source_first_offset;
  c.destination_first_offset = r.destination_first_offset;
  c.source_row_step = r.source_row_step;
  c.destination_row_step = r.destination_row_step;
  c.finished = true;
  return c;
}

void finish_error(Completion& c, Check result) {
  c.status = result.code; c.error_detail = result.detail;
  c.bad_element = result.bad_element; c.unit = OutputUnit::NONE;
  c.output_elements = 0;
}

void run(const ap_uint<512>* source, ap_uint<512>* destination,
         const Request& request, Completion& completion) {
  completion = base_completion(request);
  Check result = supported(request);
  if (!result) { finish_error(completion, result); return; }

  float gamma[1024] = {};
  for (unsigned local_row = 0;
       local_row < request.context.rows && result; ++local_row) {
    float x[1024], y[1024];
    const uint64_t source_byte = request.source_first_offset +
        uint64_t(local_row) * request.source_row_step;
    const uint64_t destination_byte = request.destination_first_offset +
        uint64_t(local_row) * request.destination_row_step;
    for (unsigned beat = 0; beat < 64; ++beat) {
      const ap_uint<512> word = source[source_byte / 64 + beat];
      for (unsigned lane = 0; lane < 16; ++lane) {
        const uint32_t bits =
            uint32_t(word.range(lane * 32 + 31, lane * 32));
        x[beat * 16 + lane] = numeric_bits_f32(bits);
      }
      completion.consumed_source_bytes += 64;
    }
    float mean = 0.0f, variance = 0.0f, inverse = 0.0f;
    result = layernorm_row_arithmetic(request.context.op, local_row, x,
                                      gamma, 0, y, mean, variance, inverse);
    if (!result) break;
    for (unsigned beat = 0; beat < 64; ++beat) {
      ap_uint<512> word = 0;
      for (unsigned lane = 0; lane < 16; ++lane)
        word.range(lane * 32 + 31, lane * 32) =
            numeric_f32_bits(y[beat * 16 + lane]);
      destination[destination_byte / 64 + beat] = word;
      // This is the actual HLS store-helper submission point.  Physical AW/W
      // and B retirement remain the downstream monitor/hub responsibility.
      completion.issued_store_bytes += 64;
    }
  }
  if (!result) { finish_error(completion, result); return; }
  completion.status = Status::OK;
  completion.unit = OutputUnit::F32;
  completion.output_elements = request.expected_elements;
  completion.bad_element = UINT64_MAX;
}

} // namespace
} // namespace laya::producer

extern "C" void laya_layernorm_producer_engine(
    const ap_uint<512>* source, ap_uint<512>* destination,
    hls::stream<ap_uint<512>>& request_stream,
    hls::stream<ap_uint<512>>& completion_stream) {
#pragma HLS INTERFACE m_axi port=source offset=slave bundle=source max_read_burst_length=64 num_read_outstanding=1
#pragma HLS INTERFACE m_axi port=destination offset=slave bundle=destination max_write_burst_length=64 num_write_outstanding=1
#pragma HLS INTERFACE ap_fifo port=request_stream depth=2
#pragma HLS INTERFACE ap_fifo port=completion_stream depth=2
#pragma HLS INTERFACE ap_ctrl_none port=return
  laya::Check decode_result;
  const laya::producer::Request request =
      laya::producer::read_request(request_stream, decode_result);
  laya::producer::Completion completion;
  if (decode_result) {
    laya::producer::run(source, destination, request, completion);
  } else {
    completion.family = laya::producer::Family::LAYERNORM;
    completion.status = decode_result.code;
    completion.error_detail = decode_result.detail;
    completion.bad_element = decode_result.bad_element;
    completion.finished = true;
  }
  laya::producer::write_completion(completion_stream, completion);
}
#endif
