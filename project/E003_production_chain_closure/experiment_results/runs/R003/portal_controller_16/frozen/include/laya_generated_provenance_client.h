#pragma once

#include "laya_generated_provenance.h"

namespace laya::provenance {

struct Word512 { std::array<uint8_t, 64> byte{}; };
using RequestWords = std::array<Word512, kRequestBeats>;
using ResponseWords = std::array<Word512, kResponseBeats>;

RequestWords request_words(const RequestPacket&);
ResponseWords response_words(const ResponsePacket&);
ResponsePacket response_packet(const ResponseWords&);
Check verify_response(const ResponseWords&, const Request&, Response&);

template<class Sink, class Source>
Check exchange(Sink& sink, Source& source,
               const Request& request, Response& response) {
  const RequestWords outbound = request_words(encode(request));
  for (const Word512& word : outbound) sink.write(word);
  ResponseWords inbound{};
  for (Word512& word : inbound) word = source.read();
  return verify_response(inbound, request, response);
}

} // namespace laya::provenance
