#include "laya_controller_transaction_hls.h"

#ifdef LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM
namespace laya::transaction {
namespace {

template<std::size_t Bytes>
std::array<uint8_t, Bytes> read_packet(hls::stream<ap_uint<512>>& stream) {
  std::array<uint8_t, Bytes> packet{};
  for (unsigned beat = 0; beat < Bytes / 64; ++beat) {
    const ap_uint<512> word = stream.read();
    for (unsigned byte = 0; byte < 64; ++byte)
      packet[beat * 64 + byte] =
          uint8_t(word.range(byte * 8 + 7, byte * 8));
  }
  return packet;
}

template<std::size_t Bytes>
void write_packet(hls::stream<ap_uint<512>>& stream,
                  const std::array<uint8_t, Bytes>& packet) {
  for (unsigned beat = 0; beat < Bytes / 64; ++beat) {
    ap_uint<512> word = 0;
    for (unsigned byte = 0; byte < 64; ++byte)
      word.range(byte * 8 + 7, byte * 8) = packet[beat * 64 + byte];
    stream.write(word);
  }
}

} // namespace

#ifndef LAYA_TRANSACTION_SEQUENCER_CODEC
Request read_request(hls::stream<ap_uint<512>>& stream, Check& result) {
  Request request;
  result = decode(read_packet<kRequestBytes>(stream), request);
  return request;
}
#endif

void write_request(hls::stream<ap_uint<512>>& stream,
                   const Request& request) {
  write_packet(stream, encode(request));
}

Completion read_completion(hls::stream<ap_uint<512>>& stream,
                           const Request& request, Check& result) {
  Completion completion;
  result = decode(read_packet<kCompletionBytes>(stream), request, completion);
  return completion;
}

void write_completion(hls::stream<ap_uint<512>>& stream,
                      const Completion& completion) {
  write_packet(stream, encode(completion));
}

Check exchange(hls::stream<ap_uint<512>>& request_stream,
               hls::stream<ap_uint<512>>& completion_stream,
               const Request& request, Completion& completion) {
  write_request(request_stream, request);
  Check result;
  completion = read_completion(completion_stream, request, result);
  return result;
}

} // namespace laya::transaction
#endif
