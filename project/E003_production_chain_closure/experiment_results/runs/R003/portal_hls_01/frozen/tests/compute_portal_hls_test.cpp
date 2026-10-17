#include "laya_compute_portal_hls.h"
#include <cassert>
#include <iostream>

using namespace laya;
using namespace laya::portal;

namespace {

NumericIdentity identity() {
  NumericIdentity id;
  id.request_id = 1; id.generation = 2; id.B = 1; id.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = uint8_t(1 + i);
    id.numeric_tag[i] = uint8_t(17 + i);
    id.layout_tag[i] = uint8_t(33 + i);
    id.build_tag[i] = uint8_t(49 + i);
  }
  return id;
}

Command command() {
  Command c;
  c.service = Service::MATRIX; c.generation = 9; c.identity = identity();
  c.context = {3, Op::LIN_DOWN, 2, 0, 0, RowSpace::TOKEN, 0, 16};
  c.producer_context = {1, Op::GEGLU, 2, 0, 0, RowSpace::TOKEN, 0, 16};
  c.quant_context = {2, Op::QUANT, 2, 0, 0, RowSpace::TOKEN, 0, 16};
  c.linear_context = c.context;
  c.source = {Buffer::GATE, 0, 1}; c.a = {Buffer::A8, 0, 1};
  c.w = {Buffer::WEIGHT, 0, 1}; c.ps = {Buffer::PS, 0, 1};
  c.dst = {Buffer::TMP, 0, 1}; c.future_dst = c.dst;
  c.K = 2624; c.N = 1024; c.rows = 4; c.row_block = 0;
  c.a_epoch = 1; c.w_epoch = 1; c.weight_key = 4;
  c.output_role[0] = Bo::STATE1;
  c.output[0] = {16919104, 8388608, 8388608};
  c.row_stride = 4096; c.batch_stride = 4194304;
  for (unsigned i = 0; i < c.model_identity.size(); ++i)
    c.model_identity[i] = uint8_t(i * 13u + 5u);
  return c;
}

Response success(const Command& c) {
  Response r;
  r.status = Status::OK; r.service = c.service; r.rows = c.rows;
  r.row_block = c.row_block; r.generation = c.generation;
  r.task_id = c.context.task_id; r.drained = true; r.published = true;
  r.output_elements = uint32_t(c.rows) * c.N; r.unit = OutputUnit::F32;
  r.identity = c.identity; r.context = c.context;
  r.producer_context = c.producer_context; r.quant_context = c.quant_context;
  r.linear_context = c.linear_context; r.source = c.source; r.a = c.a;
  r.w = c.w; r.ps = c.ps; r.dst = c.dst; r.future_dst = c.future_dst;
  r.a_epoch = c.a_epoch; r.w_epoch = c.w_epoch;
  return r;
}

ap_uint<512> pack(const Word512& word) {
  ap_uint<512> result = 0;
  for (unsigned byte = 0; byte < 64; ++byte)
    result.range(byte * 8 + 7, byte * 8) = word.byte[byte];
  return result;
}

} // namespace

int main() {
  const Command expected = command();
  const CommandWords expected_words = command_words(encode(expected));
  hls::stream<ap_uint<512>> command_stream, response_stream;
  const ResponseWords response = response_words(encode(success(expected)));
  for (const Word512& word : response) response_stream.write(pack(word));

  Response decoded;
  assert(exchange(command_stream, response_stream, expected, decoded));
  assert(command_stream.size() == kCommandBeats && response_stream.empty());
  for (const Word512& word : expected_words) {
    const ap_uint<512> actual = command_stream.read();
    for (unsigned byte = 0; byte < 64; ++byte)
      assert(uint8_t(actual.range(byte * 8 + 7, byte * 8)) == word.byte[byte]);
  }
  assert(command_stream.empty() && decoded.generation == expected.generation);
  std::cout << "FULL_CURRENT_PORTAL_HLS_PASS ap_uint_bits=512 command_beats=16 "
               "response_beats=8 blocking_exchange=1 byte_order=1\n";
}

