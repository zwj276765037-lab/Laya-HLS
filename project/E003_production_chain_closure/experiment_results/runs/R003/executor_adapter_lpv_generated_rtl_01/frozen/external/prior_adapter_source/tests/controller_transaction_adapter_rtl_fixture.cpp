#define main existing_adapter_host_test_main
#include "controller_transaction_adapter_test.cpp"
#undef main

#include <fstream>
#include <iomanip>
#include <string>

namespace {
template<std::size_t Bytes>
void hex_file(const std::string& directory, const std::string& name,
              const std::array<uint8_t, Bytes>& packet) {
  std::ofstream stream(directory + "/" + name + ".hex");
  assert(stream.good());
  stream << std::hex << std::setfill('0');
  for (unsigned beat = 0; beat < Bytes / 64; ++beat) {
    for (unsigned byte = 64; byte-- > 0;)
      stream << std::setw(2) << unsigned(packet[64 * beat + byte]);
    stream << '\n';
  }
}

template<class Remote>
void fixture(const std::string& directory, const std::string& name,
             const transaction::Request& request, const Remote& response,
             bool binding = true) {
  hex_file(directory, name + "_request", transaction::encode(request));
  hex_file(directory, name + "_completion", transaction::encode(
      transaction::make_completion(request, response, binding)));
}
} // namespace

int main(int argc, char** argv) {
  assert(argc == 2);
  const std::string directory = argv[1];
  auto compute = compute_request();
  auto compute_rsp = compute_response(compute);
  auto compute_tx = transaction::make_request(compute);
  fixture(directory, "compute", compute_tx, compute_rsp);
  hex_file(directory, "compute_external", portal::encode(compute));
  hex_file(directory, "compute_response", portal::encode(compute_rsp));

  auto begin = provenance_begin();
  provenance::Response begin_rsp;
  begin_rsp.action = begin.action; begin_rsp.event_seq = begin.event_seq;
  begin_rsp.origin_seq = begin.origin_seq; begin_rsp.status = Status::OK;
  begin_rsp.drained = true; begin_rsp.scope_active = true;
  begin_rsp.descriptor_count = begin.descriptor_count;
  begin_rsp.identity = begin.identity; begin_rsp.context = begin.context;
  begin_rsp.target_ref[0] = begin.descriptor[0].target_ref;
  fixture(directory, "begin", transaction::make_request(begin), begin_rsp);
  hex_file(directory, "begin_external", provenance::encode(begin));
  hex_file(directory, "begin_response", provenance::encode(begin_rsp));

  auto producer = producer_request_value();
  auto producer_rsp = producer_response(producer);
  auto producer_tx = transaction::make_request(producer);
  fixture(directory, "producer", producer_tx, producer_rsp);
  hex_file(directory, "producer_external", producer::encode(producer));
  hex_file(directory, "producer_response", producer::encode(producer_rsp));
  hex_file(directory, "cancel_producer_request", transaction::encode(producer_tx));
  hex_file(directory, "cancel_producer_completion", transaction::encode(
      transaction::make_local_reject(producer_tx,
          Check{Status::E_PROTOCOL, laya::detail(7, 0, 14)})));

  auto end = provenance_end(begin);
  auto end_tx = transaction::make_request(end, transaction::CANCEL_CLEANUP);
  auto end_rsp = provenance_end_response(end);
  fixture(directory, "end", end_tx, end_rsp);
  hex_file(directory, "end_external", provenance::encode(end));
  hex_file(directory, "end_response", provenance::encode(end_rsp));
  auto waiting = end_rsp;
  waiting.status = Status::E_BUFFER; waiting.unit = OutputUnit::NONE;
  waiting.output_elements = 0; waiting.drained = false; waiting.scope_active = true;
  fixture(directory, "wait_end", end_tx, waiting);
  hex_file(directory, "wait_end_external", provenance::encode(end));
  hex_file(directory, "wait_end_response", provenance::encode(waiting));

  auto wrong = end_rsp; ++wrong.event_seq;
  fixture(directory, "wrong_end", end_tx, wrong, false);
  hex_file(directory, "wrong_end_external", provenance::encode(end));
  hex_file(directory, "wrong_end_response", provenance::encode(wrong));
  auto bad_header = producer::encode(producer_rsp); bad_header[0] ^= 1;
  auto untrusted = producer_rsp; untrusted.finished = false;
  fixture(directory, "bad_producer", producer_tx, untrusted, false);
  hex_file(directory, "bad_producer_external", producer::encode(producer));
  hex_file(directory, "bad_producer_response", bad_header);
  std::cout << "FULL_CURRENT_CONTROLLER_ADAPTER_RTL_FIXTURE_PASS cases=7 "
            << "semantic_wire_encoders=1\n";
}
