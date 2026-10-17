#include "laya_executor_wide_fifo_diagnostic.h"
#ifndef LAYA_WIDE_FIFO_DIAGNOSTIC_HOST_FIFO
#error "This backpressure test requires the explicitly bounded host peer"
#endif
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>

namespace {
using Packet = std::array<uint8_t, 1024>;
using Stream = hls::stream<ap_uint<8192>>;
void require(bool fact, const std::string& why) {
  if (!fact) throw std::runtime_error(why);
}
Packet load(const std::string& path) {
  std::ifstream input(path, std::ios::binary);
  require(input.good(), "fixture open: "+path);
  Packet packet{};
  input.read(reinterpret_cast<char*>(packet.data()), packet.size());
  require(input.gcount()==1024 && input.peek()==std::ifstream::traits_type::eof(),
          "fixture must contain exactly 1024 bytes: "+path);
  return packet;
}
void save(const std::string& path, const Packet& packet) {
  std::ofstream output(path, std::ios::binary);
  output.write(reinterpret_cast<const char*>(packet.data()), packet.size());
  require(output.good(), "capture write: "+path);
}
ap_uint<8192> word(const Packet& packet) {
  ap_uint<8192> value=0;
  for (unsigned byte=0; byte<1024; ++byte)
    value.range(byte*8+7,byte*8)=packet[byte];
  return value;
}
Packet check_word(const ap_uint<8192>& value, const Packet& expected,
                  const std::string& where) {
  Packet actual{};
  for (unsigned byte=0; byte<1024; ++byte) {
    actual[byte]=uint8_t(value.range(byte*8+7,byte*8));
    require(actual[byte]==expected[byte], where+" byte "+std::to_string(byte));
  }
  return actual;
}
struct Harness {
  Stream receipt,rejection,owner,owner_input,pending_input;
  unsigned calls=0;
  void step() {
    require(++calls<500, "bounded software call cap");
    laya_executor_wide_fifo_diagnostic(receipt,rejection,owner,owner_input,pending_input);
  }
  void wait(unsigned count=12) { for (unsigned i=0;i<count;++i) step(); }
  void inputs_held() {
    require(owner_input.reads==1 && pending_input.reads==1 &&
            owner_input.size()==1 && pending_input.size()==1,
            "blocked old output must retain both queued next inputs");
  }
};
void prefill(Stream& stream, const Packet& first, const Packet& second) {
  require(stream.write_nb(word(first)) && stream.write_nb(word(second)) && stream.full(),
          "actual bounded output peer prefill");
}
void remove_prefill(Stream& stream, const Packet& first, const Packet& second) {
  ap_uint<8192> value;
  require(stream.read_nb(value), "first sentinel actual read");
  check_word(value,first,"first sentinel");
  require(stream.read_nb(value), "second sentinel actual read");
  check_word(value,second,"second sentinel");
  require(stream.empty(), "sentinel FIFO drain");
}
void consume(Stream& stream,const Packet& expected,const std::string& path) {
  ap_uint<8192> value;
  require(stream.read_nb(value), "actual diagnostic output read: "+path);
  save(path,check_word(value,expected,path));
}
} // namespace

int main(int argc,char** argv) {
  try {
    require(argc==2, "usage: executable FIXTURE");
    const std::string fixture=argv[1];
    const Packet owner0=load(fixture+"/owner_0.bin"),pending0=load(fixture+"/pending_0.bin");
    const Packet owner1=load(fixture+"/owner_1.bin"),pending1=load(fixture+"/pending_1.bin");
    const Packet mixed0=load(fixture+"/mixed_0.bin"),mixed1=load(fixture+"/mixed_1.bin");
    Packet sentinel0{},sentinel1{};
    for (unsigned byte=0;byte<1024;++byte) { sentinel0[byte]=0xa5;sentinel1[byte]=0x5a; }
    Harness h;
    h.wait();
    require(h.receipt.empty() && h.rejection.empty() && h.owner.empty() &&
            h.owner_input.reads==0 && h.pending_input.reads==0,
            "empty input cannot create diagnostic output");
    prefill(h.receipt,sentinel0,sentinel1);prefill(h.rejection,sentinel0,sentinel1);
    prefill(h.owner,sentinel0,sentinel1);
    require(h.owner_input.write_nb(word(owner0)), "owner0 actual enqueue");
    h.step();h.wait();
    require(h.owner_input.empty() && h.owner_input.reads==1 && h.pending_input.reads==0 &&
            h.receipt.writes==2 && h.rejection.writes==2 && h.owner.writes==2,
            "only one collected full input cannot emit a pair");
    require(h.pending_input.write_nb(word(pending0)), "pending0 actual enqueue");
    h.step();h.wait();
    require(h.pending_input.empty() && h.pending_input.reads==1 &&
            h.receipt.writes==2 && h.rejection.writes==2 && h.owner.writes==2 &&
            h.receipt.blocked_writes>=12 && h.rejection.blocked_writes>=12 &&
            h.owner.blocked_writes>=12, "all three actual write_nb calls must fail under capacity");
    check_word(h.receipt.front(),sentinel0,"blocked receipt sentinel stable");
    check_word(h.rejection.front(),sentinel0,"blocked rejection sentinel stable");
    check_word(h.owner.front(),sentinel0,"blocked owner sentinel stable");
    check_word(h.receipt.blocked_word(),owner0,"blocked receipt full payload");
    check_word(h.rejection.blocked_word(),pending0,"blocked rejection full payload");
    check_word(h.owner.blocked_word(),mixed0,"blocked owner full payload");

    require(h.owner_input.write_nb(word(owner1)) && h.pending_input.write_nb(word(pending1)),
            "next complete pair actual enqueue while old output blocked");
    remove_prefill(h.receipt,sentinel0,sentinel1);h.step();h.wait();h.inputs_held();
    require(h.receipt.size()==1 && h.receipt.writes==3 && h.rejection.writes==2 && h.owner.writes==2,
            "independent receipt success must not pop next input or duplicate");
    check_word(h.receipt.front(),owner0,"old accepted-named raw output stable");
    remove_prefill(h.owner,sentinel0,sentinel1);h.step();h.wait();h.inputs_held();
    require(h.owner.size()==1 && h.owner.writes==3 && h.rejection.writes==2,
            "independent owner success must not release old pending input");
    consume(h.owner,mixed0,fixture+"/actual_owner_0.bin");h.wait();h.inputs_held();
    check_word(h.receipt.front(),owner0,"old record retained until final output");
    check_word(h.rejection.front(),sentinel0,"final blocked lane sentinel stable");
    remove_prefill(h.rejection,sentinel0,sentinel1);h.step();
    require(h.rejection.size()==1 && h.rejection.writes==3 &&
            h.owner_input.reads==1 && h.pending_input.reads==1,
            "last original write must precede next input collection");
    check_word(h.rejection.front(),pending0,"old rejection-named raw output");
    h.step();
    require(h.owner_input.empty() && h.pending_input.empty() &&
            h.owner_input.reads==2 && h.pending_input.reads==2,
            "both next inputs must be actually consumed");
    h.step();h.wait();
    require(h.receipt.size()==2 && h.rejection.size()==2 && h.owner.size()==1 &&
            h.receipt.writes==4 && h.rejection.writes==4 && h.owner.writes==4,
            "second raw frame must write exactly once on all lanes");
    consume(h.receipt,owner0,fixture+"/actual_receipt_0.bin");
    consume(h.receipt,owner1,fixture+"/actual_receipt_1.bin");
    consume(h.rejection,pending0,fixture+"/actual_rejection_0.bin");
    consume(h.rejection,pending1,fixture+"/actual_rejection_1.bin");
    consume(h.owner,mixed1,fixture+"/actual_owner_1.bin");
    h.wait();
    require(h.receipt.empty() && h.rejection.empty() && h.owner.empty() &&
            h.owner_input.empty() && h.pending_input.empty() &&
            h.receipt.writes==4 && h.rejection.writes==4 && h.owner.writes==4 &&
            h.receipt.reads==4 && h.rejection.reads==4 && h.owner.reads==4 &&
            h.owner_input.reads==2 && h.pending_input.reads==2 &&
            !h.receipt.blocked_payload_changed && !h.rejection.blocked_payload_changed &&
            !h.owner.blocked_payload_changed,
            "finite diagnostic must finish empty without duplicate output");
    std::cout << "FULL_CURRENT_EXECUTOR_WIDE_FIFO_DIAGNOSTIC_HOST_PASS"
              << " raw_pairs=2 input_actual_reads=4 diagnostic_output_actual_writes=6"
              << " complete_bytes_per_packet=1024 output_lanes_blocked=3"
              << " complete_blocked_payloads_stable=3"
              << " bounded_host_peer_depth=2 software_calls=" << h.calls
              << " same_source_nb=1 generated_RTL_backpressure_NOT_RUN=1"
              << " executor_authority_NOT_RUN=1\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "WIDE_FIFO_DIAGNOSTIC_HOST_FAIL: " << error.what() << '\n';
    return 1;
  }
}
