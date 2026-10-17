#include "laya_controller_transaction.h"
#include "laya_model_layout_generated.h"

#include <cassert>
#include <fstream>
#include <iostream>

using namespace laya;

namespace {

NumericIdentity identity() {
  NumericIdentity id;
  id.request_id = 61; id.generation = 73; id.B = 1; id.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = full::kFullModelTag[i];
    id.numeric_tag[i] = full::kFullNumericTag[i];
    id.layout_tag[i] = full::kFullLayoutTag[i];
    id.build_tag[i] = full::kFullBuildTag[i];
  }
  return id;
}

std::array<uint8_t, 416> model_identity() {
  std::array<uint8_t, 416> value{};
  const uint8_t* tags[4] = {full::kFullModelTag, full::kFullNumericTag,
      full::kFullLayoutTag, full::kFullBuildTag};
  for (unsigned tag = 0; tag < 4; ++tag)
    for (unsigned byte = 0; byte < 16; ++byte)
      value[16 * tag + byte] = tags[tag][byte];
  portal::put(value.data(), 64, 0x4d33314cu, 4);
  portal::put(value.data(), 68, 1, 2);
  portal::put(value.data(), 70, 416, 2);
  portal::put(value.data(), 76, 1, 4);
  for (unsigned byte = 0; byte < 32; ++byte)
    value[80 + byte] = full::kFullSourceSha256[byte];
  portal::put(value.data(), 112, 5, 4);
  portal::put(value.data(), 116, 16, 4);
  portal::put(value.data(), 120, 128, 4);
  constexpr uint32_t roles[5] = {0, 2, 3, 4, 5};
  for (unsigned i = 0; i < 5; ++i) {
    const unsigned off = 128 + 16 * i;
    portal::put(value.data(), off, roles[i], 4);
    portal::put(value.data(), off + 4, 1, 4);
    portal::put(value.data(), off + 8, full::kFullModelBoSizes[i], 8);
  }
  return value;
}

portal::Command compute_request() {
  portal::Command c;
  c.service = portal::Service::MATRIX; c.generation = 101;
  c.identity = identity();
  c.context = {19, Op::LIN_QKV, 2, 1, 0, RowSpace::TOKEN, 16, 16};
  c.producer_context = {17, Op::LN_ATTN, 2, 1, 0,
                        RowSpace::TOKEN, 16, 16};
  c.quant_context = {18, Op::QUANT, 2, 1, 0,
                     RowSpace::TOKEN, 16, 16};
  c.linear_context = c.context;
  c.source = {Buffer::NORM, 0, 2}; c.a = {Buffer::A8, 0, 3};
  c.w = {Buffer::WEIGHT, 0, 4}; c.ps = {Buffer::PS, 0, 5};
  c.dst = {Buffer::QKV, 0, 6}; c.future_dst = c.dst;
  c.model_identity = model_identity();
  c.K = 1024; c.N = 1024; c.rows = 4; c.row_block = 4;
  c.a_epoch = 3; c.w_epoch = 4; c.weight_key = 0x0101;
  c.output_role[0] = Bo::QKV0;
  c.output[0] = {12u * 1024u * 1024u, 16u * 4096u, 16u * 4096u};
  c.row_stride = 4096; c.batch_stride = 4u * 1024u * 1024u;
  return c;
}

portal::Response compute_response(const portal::Command& c) {
  portal::Response r;
  r.status = Status::OK; r.service = c.service; r.rows = c.rows;
  r.row_block = c.row_block; r.generation = c.generation;
  r.task_id = c.context.task_id; r.output_elements = 4096;
  r.unit = OutputUnit::F32; r.drained = true; r.published = true;
  r.identity = c.identity; r.context = c.context;
  r.source = c.source; r.a = c.a; r.w = c.w; r.ps = c.ps; r.dst = c.dst;
  r.a_epoch = c.a_epoch; r.w_epoch = c.w_epoch;
  r.producer_context = c.producer_context;
  r.quant_context = c.quant_context; r.linear_context = c.linear_context;
  r.future_dst = c.future_dst;
  return r;
}

provenance::OwnerDescriptor descriptor() {
  provenance::OwnerDescriptor d;
  d.target_ref = {Buffer::NORM, 0, 2}; d.stage = 2; d.layer = 1;
  d.batch = 255; d.row_space = RowSpace::TOKEN; d.rows = 64;
  d.width = 1024; d.content = Content::F32; d.role = Bo::STATE1;
  d.bo_span = 16919104; d.row_stride = 4096;
  d.batch_stride = 4194304; d.owner_extent_span = 262144;
  return d;
}

provenance::Request provenance_request() {
  provenance::Request r;
  r.action = provenance::Action::BEGIN; r.event_seq = 102;
  r.origin_seq = 102; r.identity = identity();
  r.context = {20, Op::LN_ATTN, 2, 1, 0, RowSpace::TOKEN, 16, 16};
  r.model_identity = model_identity(); r.descriptor_count = 1;
  r.expected_unit = OutputUnit::F32; r.expected_elements = 16384;
  r.descriptor[0] = descriptor();
  r.geometry[0].first_offset = 16u * 4096u;
  r.geometry[0].segment_bytes = 4096;
  r.geometry[0].row_count = 16; r.geometry[0].repeat_count = 1;
  r.geometry[0].row_step = 4096;
  r.geometry[0].total_write_bytes = 65536;
  r.geometry[0].component = provenance::Component::FULL_WIDTH;
  r.geometry[0].head = 255;
  return r;
}

provenance::Response provenance_response(const provenance::Request& q) {
  provenance::Response r;
  r.action = q.action; r.event_seq = q.event_seq; r.origin_seq = q.origin_seq;
  r.status = Status::OK; r.drained = true; r.scope_active = true;
  r.descriptor_count = 1; r.identity = q.identity; r.context = q.context;
  r.target_ref[0] = q.descriptor[0].target_ref;
  return r;
}

producer::Request producer_request() {
  producer::Request r;
  r.request_seq = 103; r.provenance_origin_seq = 102;
  r.identity = identity();
  r.context = {20, Op::LN_ATTN, 2, 1, 0, RowSpace::TOKEN, 16, 16};
  r.model_identity = model_identity();
  r.source = {Buffer::HIDDEN, 0, 1};
  r.destination = {Buffer::NORM, 0, 2};
  r.source_role = Bo::STATE0; r.destination_role = Bo::STATE1;
  r.source_first_offset = 16u * 4096u;
  r.destination_first_offset = 16u * 4096u;
  r.source_bo_span = 16920576; r.destination_bo_span = 16919104;
  r.expected_elements = 16384;
  return r;
}

producer::Completion producer_completion(const producer::Request& q) {
  producer::Completion r;
  r.family = q.family; r.request_seq = q.request_seq;
  r.provenance_origin_seq = q.provenance_origin_seq;
  r.status = Status::OK; r.unit = OutputUnit::F32; r.finished = true;
  r.bad_element = UINT64_MAX; r.output_elements = q.expected_elements;
  r.issued_store_bytes = uint64_t(q.expected_elements) * 4u;
  r.consumed_source_bytes = r.issued_store_bytes;
  r.identity = q.identity; r.context = q.context;
  r.source = q.source; r.destination = q.destination;
  r.D = q.D; r.gamma = q.gamma; r.source_region = q.source_region;
  r.destination_region = q.destination_region;
  r.source_role = q.source_role; r.destination_role = q.destination_role;
  r.eps_bits = q.eps_bits; r.row_bytes = q.row_bytes;
  r.source_first_offset = q.source_first_offset;
  r.destination_first_offset = q.destination_first_offset;
  r.source_row_step = q.source_row_step;
  r.destination_row_step = q.destination_row_step;
  return r;
}

template<class Packet>
void save(const char* directory, const char* name, const Packet& packet) {
  if (!directory) return;
  std::ofstream stream(std::string(directory) + "/" + name,
                       std::ios::binary);
  stream.write(reinterpret_cast<const char*>(packet.data()), packet.size());
  assert(stream);
}

void assert_completion_untrusted(const laya::transaction::Completion& value) {
  using namespace laya::transaction;
  assert(value.flags == 0 && !completion_frame_complete(value) &&
         !completion_binding_ok(value) && !completion_safe_terminal(value) &&
         value.compute.generation == 0 &&
         value.compute.context.task_id == 0 &&
         value.provenance.event_seq == 0 &&
         value.provenance.origin_seq == 0 &&
         value.producer.request_seq == 0 &&
         value.producer.provenance_origin_seq == 0 &&
         value.producer.source.id == Buffer::NONE &&
         value.producer.destination.id == Buffer::NONE);
}

void expect_bad_completion_header(
    laya::transaction::CompletionPacket packet,
    const laya::transaction::Request& expected,
    const laya::transaction::Completion& preset, unsigned offset,
    uint8_t value) {
  packet[offset] = value;
  laya::transaction::Completion decoded = preset;
  assert(!laya::transaction::decode(packet, expected, decoded));
  assert_completion_untrusted(decoded);
}

} // namespace

int main(int argc, char** argv) {
  using namespace laya::transaction;
  unsigned request_mutations = 0, completion_mutations = 0;

  const portal::Command compute = compute_request();
  const provenance::Request provenance = provenance_request();
  const producer::Request producer = producer_request();
  const Request requests[3] = {make_request(compute),
      make_request(provenance), make_request(producer)};

  for (unsigned i = 0; i < 3; ++i) {
    const RequestPacket packet = encode(requests[i]);
    Request decoded;
    const Check request_check = decode(packet, decoded);
    if (!request_check) {
      std::cerr << "request roundtrip failed kind=" << i + 1
                << " status=" << unsigned(request_check.code)
                << " detail=" << request_check.detail << '\n';
      return 1;
    }
    const RequestPacket roundtrip = encode(decoded);
    if (decoded.kind != requests[i].kind || roundtrip != packet) {
      unsigned first = 0;
      while (first < packet.size() && roundtrip[first] == packet[first]) ++first;
      std::cerr << "request re-encode mismatch kind=" << i + 1
                << " byte=" << first << " expected="
                << (first < packet.size() ? unsigned(packet[first]) : 0)
                << " actual="
                << (first < packet.size() ? unsigned(roundtrip[first]) : 0)
                << '\n';
      return 1;
    }
    auto bad = packet; bad[12] = 1; assert(!decode(bad, decoded));
    ++request_mutations;
    bad = packet; bad[1535] = 1; assert(!decode(bad, decoded));
    ++request_mutations;
    bad = packet; bad[10] ^= 1; assert(!decode(bad, decoded));
    ++request_mutations;
    save(argc > 1 ? argv[1] : nullptr,
         i == 0 ? "compute_request.bin" :
         i == 1 ? "provenance_request.bin" : "producer_request.bin",
         packet);
  }

  assert(portal::get(encode(requests[0]).data(), 0, 4) == kRequestMagic);
  assert(portal::get(encode(requests[0]).data(), 6, 2) == 24);
  assert(encode(requests[0])[160] == full::kFullModelTag[0]);
  assert(portal::get(encode(requests[2]).data(), 612, 4) == 4096);

  const Completion completions[3] = {
      make_completion(requests[0], compute_response(compute), true),
      make_completion(requests[1], provenance_response(provenance), true),
      make_completion(requests[2], producer_completion(producer), true)};
  for (unsigned i = 0; i < 3; ++i) {
    const CompletionPacket packet = encode(completions[i]);
    Completion decoded;
    Check result = decode(packet, requests[i], decoded);
    assert(result.code == Status::OK);
    assert(completion_frame_complete(decoded) && completion_binding_ok(decoded));
    if (i == 1) assert(!completion_safe_terminal(decoded));
    else assert(completion_safe_terminal(decoded));
    auto bad = packet; bad[16] ^= 1;
    assert(!decode(bad, requests[i], decoded)); ++completion_mutations;
    bad = packet; bad[1023] = 1;
    assert(!decode(bad, requests[i], decoded)); ++completion_mutations;
    save(argc > 1 ? argv[1] : nullptr,
         i == 0 ? "compute_completion.bin" :
         i == 1 ? "provenance_completion.bin" :
                  "producer_completion.bin", packet);
  }

  Completion rejected = make_local_reject(
      requests[2], {Status::E_PROTOCOL, detail(7, 0, 14)});
  Completion decoded_reject;
  const Check rejected_check = decode(encode(rejected), requests[2],
                                       decoded_reject);
  assert(rejected_check.code == Status::E_PROTOCOL &&
         (decoded_reject.flags & LOCAL_REJECT) &&
         !completion_binding_ok(decoded_reject) &&
         !completion_safe_terminal(decoded_reject));
  CompletionPacket bad_reject = encode(rejected);
  bad_reject[16] ^= 1;
  assert(!decode(bad_reject, requests[2], decoded_reject));
  bad_reject = encode(rejected);
  bad_reject[12] |= uint8_t(REMOTE_TERMINAL);
  assert(!decode(bad_reject, requests[2], decoded_reject));

  // Every fixed-header rejection clears a caller-owned Completion even when
  // that object previously carried trusted success or LOCAL_REJECT fields.
  const CompletionPacket valid = encode(completions[2]);
  const CompletionPacket valid_reject = encode(rejected);
  expect_bad_completion_header(valid, requests[2], completions[2], 0,
                               uint8_t(valid[0] ^ 1u));
  expect_bad_completion_header(valid_reject, requests[2], rejected, 4,
                               uint8_t(valid_reject[4] ^ 1u));
  expect_bad_completion_header(valid, requests[2], completions[2], 6,
                               uint8_t(valid[6] + 1u));
  expect_bad_completion_header(valid_reject, requests[2], rejected, 8, 0);
  expect_bad_completion_header(valid, requests[2], completions[2], 32, 0xff);
  expect_bad_completion_header(valid_reject, requests[2], rejected, 34, 0xff);
  expect_bad_completion_header(valid, requests[2], completions[2], 12,
                               uint8_t(valid[12] | 0x80u));
  expect_bad_completion_header(valid_reject, requests[2], rejected, 52, 1);

  Completion invalid_ok_reject = rejected;
  invalid_ok_reject.producer.status = Status::OK;
  invalid_ok_reject.producer.error_detail = 0;
  invalid_ok_reject.producer.bad_element = UINT64_MAX;
  Completion reused = completions[2];
  assert(!decode(encode(invalid_ok_reject), requests[2], reused));
  assert_completion_untrusted(reused);

  std::cout << "FULL_CURRENT_CONTROLLER_TRANSACTION_CODEC_PASS kinds=3 "
            << "request_bytes=1536 completion_bytes=1024 request_mutations="
            << request_mutations << " completion_mutations="
            << completion_mutations
            << " completion_header_mutations=8 local_reject_nonok=1\n";
  return 0;
}
