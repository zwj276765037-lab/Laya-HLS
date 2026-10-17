#pragma once

#include "laya_compute_portal.h"
#include "laya_full_runtime.h"
#include <array>

namespace laya::portal {

// Portable byte-exact representation of one private 512-bit FIFO beat.  The
// wire byte at the lower bit index is byte[0].  The generated HLS wrapper may
// convert this value to ap_uint<512>; no C++ object or pointer representation
// is part of the private ABI.
struct Word512 { std::array<uint8_t, 64> byte{}; };
using CommandWords = std::array<Word512, kCommandBeats>;
using ResponseWords = std::array<Word512, kResponseBeats>;

CommandWords command_words(const CommandPacket&);
ResponseWords response_words(const ResponsePacket&);
ResponsePacket response_packet(const ResponseWords&);

// Decode and bind a complete response to one exact outstanding command, then
// enforce the service-specific successful extent and publication contract.
Check verify_response(const ResponseWords&, const Command&, Response&);

// A portable blocking caller. Sink::write(Word512) and Source::read() are the
// only required operations, so the byte/beat protocol can be tested without
// Vitis headers.  The production wrapper supplies the ap_uint<512> adapter.
template<class Sink, class Source>
Check exchange(Sink& command_sink, Source& response_source,
               const Command& command, Response& response) {
  const CommandWords outbound = command_words(encode(command));
  for (const Word512& word : outbound) command_sink.write(word);
  ResponseWords inbound{};
  for (Word512& word : inbound) word = response_source.read();
  return verify_response(inbound, command, response);
}

// MODEL_IDENTITY remains an explicit input until the 13-BO model-session
// encoding/lifecycle is fixed.  Builders never synthesize it from pointers.
struct ModelBinding {
  std::array<uint8_t, 416> identity{};
  std::array<uint8_t, 128> expected_aux_header{};
};

// Stable source/parent binding shared by GEGLU, QUANT, and every MATRIX view.
// producer is the real typed source completion, not an ID-derived guess.
struct TaskBinding {
  TaskContext producer;
  QuantTask quant;
  LinearTask linear;
};

Check build_load_command(const NumericIdentity&, const full::FullMemory&,
                         const ModelBinding&, const full::FullWeightDescriptor&,
                         const LoadTask&, uint64_t generation, Command&);
Check build_quant_command(const NumericIdentity&, const full::FullMemory&,
                          const ModelBinding&, const TaskBinding&,
                          uint64_t generation, Command&);
Check build_matrix_command(const NumericIdentity&, const full::FullMemory&,
                           const ModelBinding&, const TaskBinding&,
                           const full::ViewTicket&, Command&);
Check build_geglu_command(const NumericIdentity&, const full::FullMemory&,
                          const ModelBinding&, const VectorTask&,
                          const TaskBinding&, uint64_t generation, Command&);

} // namespace laya::portal
