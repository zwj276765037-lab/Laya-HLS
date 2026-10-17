#include "laya_controller_transaction_adapter.h"

#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string>

using namespace laya;

namespace {
void require(bool ok, const char* message) {
  if (!ok) { std::cerr << message << '\n'; std::exit(1); }
}
template<std::size_t Bytes>
std::array<uint8_t, Bytes> read_hex(const std::string& path) {
  std::ifstream file(path);
  require(bool(file), "actual RTL capture missing");
  std::array<uint8_t, Bytes> packet{};
  std::string line;
  for (unsigned beat = 0; beat < Bytes / 64; ++beat) {
    require(bool(file >> line) && line.size() == 128, "capture beat width");
    for (unsigned byte = 0; byte < 64; ++byte) {
      const std::string value = line.substr(126 - 2 * byte, 2);
      require(value.find_first_not_of("0123456789abcdefABCDEF") == std::string::npos,
              "capture contains unknown byte");
      packet[beat * 64 + byte] = uint8_t(std::stoul(value, nullptr, 16));
    }
  }
  require(!(file >> line), "capture extra beat");
  return packet;
}
struct Streams {
  hls::stream<ap_uint<512>> request, completion, compute_cmd, compute_rsp;
  hls::stream<ap_uint<512>> provenance_cmd, provenance_rsp, producer_cmd, producer_rsp;
};
void step(Streams& s) {
  laya_command_provenance_adapter(false, s.request, s.completion,
      s.compute_cmd, s.compute_rsp, s.provenance_cmd, s.provenance_rsp,
      s.producer_cmd, s.producer_rsp);
}
template<std::size_t Bytes>
void enqueue(hls::stream<ap_uint<512>>& stream,
             const std::array<uint8_t, Bytes>& packet) {
  for (unsigned beat = 0; beat < Bytes / 64; ++beat) {
    ap_uint<512> word = 0;
    for (unsigned byte = 0; byte < 64; ++byte)
      word.range(byte * 8 + 7, byte * 8) = packet[beat * 64 + byte];
    stream.write(word);
  }
}
template<std::size_t Bytes>
std::array<uint8_t, Bytes> dequeue(hls::stream<ap_uint<512>>& stream) {
  require(stream.size() == Bytes / 64, "adapter packet length");
  std::array<uint8_t, Bytes> result{};
  for (unsigned beat = 0; beat < Bytes / 64; ++beat) {
    const ap_uint<512> word = stream.read();
    for (unsigned byte = 0; byte < 64; ++byte)
      result[beat * 64 + byte] = uint8_t(word.range(byte * 8 + 7, byte * 8));
  }
  return result;
}
transaction::Completion adapt(Streams& s, const provenance::Request& request,
                             const provenance::RequestPacket& wire_request,
                             const provenance::ResponsePacket& response) {
  const transaction::Request tx = transaction::make_request(request);
  enqueue(s.request, transaction::encode(tx));
  for (unsigned i = 0; i < 1000 && s.provenance_cmd.size() < provenance::kRequestBeats; ++i) step(s);
  require(dequeue<provenance::kRequestBytes>(s.provenance_cmd) == wire_request,
          "adapter changed actual request bytes");
  enqueue(s.provenance_rsp, response);
  for (unsigned i = 0; i < 1000 && s.completion.size() < transaction::kCompletionBeats; ++i) step(s);
  transaction::Completion result;
  const auto packet = dequeue<transaction::kCompletionBytes>(s.completion);
  transaction::decode(packet, tx, result);
  require(s.request.empty() && s.provenance_cmd.empty() && s.provenance_rsp.empty() &&
          s.compute_cmd.empty() && s.compute_rsp.empty() && s.producer_cmd.empty() &&
          s.producer_rsp.empty(), "adapter leftover FIFO");
  return result;
}
}

int main(int argc, char** argv) {
  require(argc == 2, "actual RTL fixture directory required");
  Streams streams;
  const char* names[] = {"source_conflict_before", "source_conflict_live",
                        "wrong_end_active", "target_end_actual"};
  for (unsigned index = 0; index < 4; ++index) {
    const std::string prefix = std::string(argv[1]) + "/actual_" + names[index];
    const auto wire_request = read_hex<provenance::kRequestBytes>(prefix + "_request.hex");
    const auto wire_response = read_hex<provenance::kResponseBytes>(prefix + "_response.hex");
    provenance::Request request;
    require(bool(provenance::decode(wire_request, request)), "actual request syntax rejected");
    provenance::Response response;
    const Check parsed = provenance::decode(wire_response, request, response);
    const Status expected = index < 2 ? Status::E_BUFFER : Status::E_PROTOCOL;
    const bool drained = index >= 2, scope_active = index == 2;
    require(parsed.code == expected && response.status == expected &&
            response.event_seq == request.event_seq && response.origin_seq == request.origin_seq &&
            numeric_identity_equal(response.identity, request.identity) &&
            response.context.task_id == request.context.task_id &&
            response.drained == drained && response.scope_active == scope_active &&
            !response.owner_published && response.output_elements == 0 &&
            response.unit == OutputUnit::NONE &&
            response.error_detail == uint32_t(portal::get(wire_response.data(), 28, 4)),
            "actual response binding/status/terminal mismatch");
    require(provenance::encode(response) == wire_response, "actual response roundtrip changed bytes");
    if (index == 3) require(response.observed_store_bytes[0] == 4096,
                            "actual short window observed bytes lost");
    const auto completion = adapt(streams, request, wire_request, wire_response);
    require(transaction::completion_frame_complete(completion) &&
            transaction::completion_binding_ok(completion) &&
            transaction::completion_safe_terminal(completion) == (index == 3) &&
            completion.provenance.status == expected &&
            completion.provenance.drained == drained &&
            completion.provenance.scope_active == scope_active &&
            !(completion.flags & transaction::LOCAL_REJECT),
            "actual adapter lost trusted error or forged terminal");
    if (index == 1) {
      auto old_response = wire_response;
      old_response[26] |= 2; // Reproduce the frozen F16 non-END scope flag.
      provenance::Response rejected;
      require(provenance::decode(old_response, request, rejected).code == Status::E_PROTOCOL,
              "original F16 scope flag unexpectedly accepted by decoder");
      const auto invalid = adapt(streams, request, wire_request, old_response);
      require(!transaction::completion_binding_ok(invalid) &&
              !transaction::completion_safe_terminal(invalid) &&
              invalid.provenance.event_seq == 0,
              "original F16 scope flag exposed trusted adapter output");
    }
    std::cout << "actual_response=" << names[index] << " status=" << uint16_t(expected)
              << " drained=" << drained << " scope=" << scope_active << '\n';
  }
  std::cout << "FULL_CURRENT_BOOTSTRAP_SOURCE_CONFLICT_ADAPTER_PASS actual_RTL_responses=4 "
               "idle_nonEND=1 active_nonEND=1 wrong_END_scope_retained=1 "
               "actual_short_END_terminal=1 original_F16_negative=1 all_streams_empty=1\n";
}
