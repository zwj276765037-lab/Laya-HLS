#include "laya_generated_provenance_hls.h"

#ifdef LAYA_GENERATED_PROVENANCE_HAS_HLS_STREAM
namespace laya::provenance {

void write_request(hls::stream<ap_uint<512>>& command_stream,
                   const RequestWords& words) {
  for (unsigned beat = 0; beat < kRequestBeats; ++beat) {
    ap_uint<512> packed = 0;
    for (unsigned byte = 0; byte < 64; ++byte)
      packed.range(byte * 8 + 7, byte * 8) = words[beat].byte[byte];
    command_stream.write(packed);
  }
}

ResponseWords read_response(hls::stream<ap_uint<512>>& response_stream) {
  ResponseWords words{};
  for (unsigned beat = 0; beat < kResponseBeats; ++beat) {
    const ap_uint<512> packed = response_stream.read();
    for (unsigned byte = 0; byte < 64; ++byte)
      words[beat].byte[byte] = uint8_t(packed.range(byte * 8 + 7, byte * 8));
  }
  return words;
}

Check exchange(hls::stream<ap_uint<512>>& command_stream,
               hls::stream<ap_uint<512>>& response_stream,
               const Request& request, Response& response) {
  write_request(command_stream, request_words(encode(request)));
  return verify_response(read_response(response_stream), request, response);
}

} // namespace laya::provenance
#endif
