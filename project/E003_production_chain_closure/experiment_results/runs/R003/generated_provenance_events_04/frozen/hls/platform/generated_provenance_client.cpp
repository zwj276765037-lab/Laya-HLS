#include "laya_generated_provenance_client.h"

namespace laya::provenance {

RequestWords request_words(const RequestPacket& packet) {
  RequestWords words{};
  for (unsigned beat = 0; beat < kRequestBeats; ++beat)
    for (unsigned byte = 0; byte < 64; ++byte)
      words[beat].byte[byte] = packet[beat * 64 + byte];
  return words;
}

ResponseWords response_words(const ResponsePacket& packet) {
  ResponseWords words{};
  for (unsigned beat = 0; beat < kResponseBeats; ++beat)
    for (unsigned byte = 0; byte < 64; ++byte)
      words[beat].byte[byte] = packet[beat * 64 + byte];
  return words;
}

ResponsePacket response_packet(const ResponseWords& words) {
  ResponsePacket packet{};
  for (unsigned beat = 0; beat < kResponseBeats; ++beat)
    for (unsigned byte = 0; byte < 64; ++byte)
      packet[beat * 64 + byte] = words[beat].byte[byte];
  return packet;
}

Check verify_response(const ResponseWords& words, const Request& request,
                      Response& response) {
  return decode(response_packet(words), request, response);
}

} // namespace laya::provenance
