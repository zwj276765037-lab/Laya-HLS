#include "laya_producer_engine_hls.h"
#include "laya_model_layout_generated.h"

#include <ap_int.h>
#include <hls_stream.h>
#include <cassert>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

extern "C" void laya_layernorm_producer_engine(
    const ap_uint<512>*, ap_uint<512>*, hls::stream<ap_uint<512>>&,
    hls::stream<ap_uint<512>>&);

namespace {

using namespace laya;

std::vector<uint8_t> read_file(const char* path, std::size_t bytes) {
  std::ifstream stream(path, std::ios::binary);
  std::vector<uint8_t> data(bytes);
  stream.read(reinterpret_cast<char*>(data.data()), data.size());
  assert(stream && stream.peek() == std::ifstream::traits_type::eof());
  return data;
}

void copy_bytes(uint8_t* dst, const uint8_t* src, unsigned count) {
  for (unsigned i = 0; i < count; ++i) dst[i] = src[i];
}

producer::Request make_request(uint64_t seq, uint64_t origin) {
  producer::Request r;
  r.request_seq = seq;
  r.provenance_origin_seq = origin;
  r.identity.request_id = 41;
  r.identity.generation = 7;
  r.identity.B = 1;
  r.identity.S = 128;
  copy_bytes(r.identity.model_tag, full::kFullModelTag, 16);
  copy_bytes(r.identity.numeric_tag, full::kFullNumericTag, 16);
  copy_bytes(r.identity.layout_tag, full::kFullLayoutTag, 16);
  copy_bytes(r.identity.build_tag, full::kFullBuildTag, 16);
  r.context = {11, Op::LN_ATTN, 2, 1, 0, RowSpace::TOKEN, 0, 16};
  uint8_t* model = r.model_identity.data();
  copy_bytes(model, full::kFullModelTag, 16);
  copy_bytes(model + 16, full::kFullNumericTag, 16);
  copy_bytes(model + 32, full::kFullLayoutTag, 16);
  copy_bytes(model + 48, full::kFullBuildTag, 16);
  portal::put(model, 64, 0x4d33314cu, 4);
  portal::put(model, 68, 1, 2); portal::put(model, 70, 416, 2);
  portal::put(model, 76, 1, 4);
  copy_bytes(model + 80, full::kFullSourceSha256, 32);
  portal::put(model, 112, 5, 4); portal::put(model, 116, 16, 4);
  portal::put(model, 120, 128, 4);
  constexpr uint8_t roles[5] = {uint8_t(Bo::EMBEDDING), uint8_t(Bo::W_Q0),
      uint8_t(Bo::W_Q1), uint8_t(Bo::W_SCALE), uint8_t(Bo::AUX)};
  for (unsigned i = 0; i < 5; ++i) {
    portal::put(model, 128 + 16 * i, roles[i], 4);
    portal::put(model, 132 + 16 * i, 1, 4);
    portal::put(model, 136 + 16 * i, full::kFullModelBoSizes[i], 8);
  }
  r.source = {Buffer::HIDDEN, 0, 3};
  r.destination = {Buffer::NORM, 0, 9};
  r.source_role = Bo::STATE0;
  r.destination_role = Bo::STATE0;
  r.source_first_offset = 0;
  r.destination_first_offset = 8u * 1024u * 1024u;
  r.source_bo_span = 16920576u;
  r.destination_bo_span = 16920576u;
  r.expected_elements = 16u * 1024u;
  return r;
}

void put_bytes(std::vector<ap_uint<512>>& memory, uint64_t offset,
               const std::vector<uint8_t>& data) {
  assert(!(offset & 63u) && !(data.size() & 63u));
  for (std::size_t beat = 0; beat < data.size() / 64; ++beat) {
    ap_uint<512> word = 0;
    for (unsigned byte = 0; byte < 64; ++byte)
      word.range(byte * 8 + 7, byte * 8) = data[beat * 64 + byte];
    memory[offset / 64 + beat] = word;
  }
}

void check_bytes(const std::vector<ap_uint<512>>& memory, uint64_t offset,
                 const std::vector<uint8_t>& expected, std::size_t bytes) {
  for (std::size_t at = 0; at < bytes; ++at) {
    const ap_uint<512>& word = memory[(offset + at) / 64];
    const unsigned lane = unsigned((offset + at) & 63u);
    const uint8_t actual = uint8_t(word.range(lane * 8 + 7, lane * 8));
    assert(actual == expected[at]);
  }
}

producer::Completion invoke(std::vector<ap_uint<512>>& source,
                            std::vector<ap_uint<512>>& destination,
                            const producer::Request& request,
                            Check& result) {
  hls::stream<ap_uint<512>> commands, completions;
  producer::write_request(commands, request);
  laya_layernorm_producer_engine(source.data(), destination.data(),
                                 commands, completions);
  return producer::read_completion(completions, request, result);
}

} // namespace

int main(int argc, char** argv) {
  assert(argc == 3);
  constexpr std::size_t bytes = 16u * 1024u * 4u;
  const std::vector<uint8_t> source_bytes = read_file(argv[1], bytes);
  const std::vector<uint8_t> gold = read_file(argv[2], bytes);
  constexpr std::size_t bo_bytes = 16920576u;

  std::vector<ap_uint<512>> source((bo_bytes + 63) / 64);
  std::vector<ap_uint<512>> destination((bo_bytes + 63) / 64);
  put_bytes(source, 0, source_bytes);
  const producer::Request normal = make_request(1, 11);
  Check result;
  producer::Completion completion = invoke(source, destination, normal, result);
  assert(result && completion.status == Status::OK);
  assert(completion.issued_store_bytes == bytes);
  assert(completion.consumed_source_bytes == bytes);
  check_bytes(destination, normal.destination_first_offset, gold, bytes);

  std::vector<uint8_t> fault_source = source_bytes;
  const uint32_t qnan = 0x7fc00000u;
  std::memcpy(fault_source.data() + 4096, &qnan, 4);
  std::fill(source.begin(), source.end(), ap_uint<512>(0));
  std::fill(destination.begin(), destination.end(), ap_uint<512>(0));
  put_bytes(source, 0, fault_source);
  producer::Request fault = make_request(2, 12);
  fault.context.task_id = 12;
  completion = invoke(source, destination, fault, result);
  assert(!result && result.code == Status::E_NUMERICAL);
  assert(completion.issued_store_bytes == 4096);
  assert(completion.consumed_source_bytes == 8192);
  assert(completion.bad_element == 1024);
  check_bytes(destination, fault.destination_first_offset, gold, 4096);
  for (unsigned at = 4096; at < 8192; ++at) {
    const ap_uint<512>& word = destination[(fault.destination_first_offset + at) / 64];
    const unsigned lane = unsigned((fault.destination_first_offset + at) & 63u);
    assert(uint8_t(word.range(lane * 8 + 7, lane * 8)) == 0);
  }

  std::cout << "FULL_CURRENT_LAYERNORM_PRODUCER_CSIM_PASS rows=16 values=16384 "
               "issued=65536 partial_issued=4096 partial_read=8192\n";
  return 0;
}
