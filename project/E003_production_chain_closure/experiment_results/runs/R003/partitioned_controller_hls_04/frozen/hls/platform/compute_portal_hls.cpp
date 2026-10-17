#include "laya_compute_portal_hls.h"

#ifdef LAYA_COMPUTE_PORTAL_HAS_HLS_STREAM
namespace laya::portal {

void write_command(hls::stream<ap_uint<512>>& command_stream,
                   const CommandWords& words) {
  for (unsigned beat = 0; beat < kCommandBeats; ++beat) {
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
               const Command& command, Response& response) {
  write_command(command_stream, command_words(encode(command)));
  return verify_response(read_response(response_stream), command, response);
}

} // namespace laya::portal
#endif

