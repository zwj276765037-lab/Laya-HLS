#include "laya_generated_provenance_client.h"
#include <cstdlib>
#include <fstream>
#include <iostream>

using namespace laya;

namespace {

[[noreturn]] void fail(const char* what) {
  std::cerr << "generated provenance codec failure: " << what << '\n';
  std::exit(1);
}
void require(bool condition, const char* what) {
  if (!condition) fail(what);
}
NumericIdentity identity() {
  NumericIdentity id;
  id.request_id = 31; id.generation = 7; id.B = 2; id.S = 64;
  for (unsigned i = 0; i < 16; ++i) {
    id.model_tag[i] = uint8_t(0x10 + i);
    id.numeric_tag[i] = uint8_t(0x30 + i);
    id.layout_tag[i] = uint8_t(0x50 + i);
    id.build_tag[i] = uint8_t(0x70 + i);
  }
  return id;
}
provenance::OwnerDescriptor descriptor() {
  provenance::OwnerDescriptor d;
  d.target_ref = {Buffer::HIDDEN, 0, 3};
  d.stage = 2; d.layer = 1; d.batch = 255;
  d.row_space = RowSpace::TOKEN; d.rows = 64; d.width = 1024;
  d.content = Content::F32; d.layout = 0; d.role = Bo::STATE0;
  d.bo_span = 16920576; d.owner_base_offset = 0;
  d.row_stride = 4096; d.batch_stride = 4194304;
  d.owner_extent_span = 4456448;
  return d;
}
provenance::WriteGeometry geometry() {
  provenance::WriteGeometry g;
  g.first_offset = 4194304 + 16 * 4096;
  g.segment_bytes = 4096; g.row_count = 16; g.repeat_count = 1;
  g.row_step = 4096; g.repeat_step = 0;
  g.total_write_bytes = 16 * 4096;
  g.component = provenance::Component::FULL_WIDTH;
  g.head = 255;
  return g;
}
provenance::Request begin_request() {
  provenance::Request r;
  r.action = provenance::Action::BEGIN; r.event_seq = 102;
  r.origin_seq = 102; r.context = {42, Op::LN_ATTN, 2, 1, 1,
                                    RowSpace::TOKEN, 16, 16};
  r.identity = identity();
  for (unsigned i = 0; i < r.model_identity.size(); ++i)
    r.model_identity[i] = uint8_t(i * 19u + 3u);
  r.descriptor_count = 1; r.expected_unit = OutputUnit::F32;
  r.expected_elements = 16384; r.descriptor[0] = descriptor();
  r.geometry[0] = geometry();
  return r;
}
provenance::Response response_for(const provenance::Request& request,
                                  bool end = false) {
  provenance::Response r;
  r.action = request.action; r.event_seq = request.event_seq;
  r.origin_seq = request.origin_seq; r.status = Status::OK; r.drained = true;
  r.scope_active = request.action == provenance::Action::BEGIN;
  r.owner_published = request.action == provenance::Action::PUBLISH;
  r.descriptor_count = request.descriptor_count; r.identity = request.identity;
  r.context = request.context;
  for (unsigned i = 0; i < request.descriptor_count; ++i) {
    r.target_ref[i] = request.descriptor[i].target_ref;
    r.target_region[i] = request.descriptor[i].target_region;
    r.old_ref[i] = request.descriptor[i].old_ref;
    r.old_region[i] = request.descriptor[i].old_region;
    if (end) r.observed_store_bytes[i] = request.issued_store_bytes[i];
  }
  if (end) {
    r.output_elements = request.expected_elements;
    r.unit = request.expected_unit;
  }
  return r;
}

} // namespace

template<class Packet>
void save(const char* directory, const char* name, const Packet& packet) {
  if (!directory) return;
  const std::string path = std::string(directory) + "/" + name;
  std::ofstream stream(path, std::ios::binary);
  stream.write(reinterpret_cast<const char*>(packet.data()), packet.size());
  if (!stream) fail("write packet fixture");
}

int main(int argc, char** argv) {
  using namespace laya::provenance;
  Request begin = begin_request(), decoded;
  const RequestPacket begin_packet = encode(begin);
  save(argc > 1 ? argv[1] : nullptr, "begin.bin", begin_packet);
  require(bool(decode(begin_packet, decoded)), "BEGIN decode");
  require(decoded.action == Action::BEGIN && decoded.event_seq == 102 &&
          decoded.origin_seq == 102 && decoded.context.task_id == 42,
          "BEGIN header roundtrip");
  require(same_descriptor(decoded.descriptor[0], begin.descriptor[0]) &&
          same_geometry(decoded.geometry[0], begin.geometry[0]),
          "BEGIN binding roundtrip");
  require(begin_packet[576] == 1 && begin_packet[577] == 0 &&
          begin_packet[578] == uint8_t(OutputUnit::F32) &&
          begin_packet[736] == 0 && begin_packet[928] == 0,
          "unused descriptor and geometry are zero");

  RequestPacket malformed = begin_packet;
  malformed[992] = 1;
  require(!decode(malformed, decoded), "request reserved mutation");
  malformed = begin_packet; malformed[608 + 29] = 1;
  require(!decode(malformed, decoded), "descriptor reserved mutation");
  malformed = begin_packet; malformed[864 + 43] = 1;
  require(!decode(malformed, decoded), "geometry reserved mutation");
  malformed = begin_packet; malformed[32] ^= 1;
  require(!decode(malformed, decoded), "BEGIN origin mismatch");

  Response response;
  ResponsePacket response_packet_ok = encode(response_for(begin));
  require(bool(decode(response_packet_ok, begin, response)),
          "BEGIN response binding");
  ResponsePacket response_bad = response_packet_ok;
  response_bad[8] ^= 1;
  require(!decode(response_bad, begin, response), "response seq mutation");
  response_bad = response_packet_ok; response_bad[192] = 1;
  require(!decode(response_bad, begin, response), "response reserved mutation");

  Request end = begin;
  end.action = Action::END; end.event_seq = 103; end.origin_seq = 102;
  end.reported_status = Status::OK; end.reported_unit = OutputUnit::F32;
  end.reported_elements = end.expected_elements;
  end.reported_bad_element = UINT64_MAX;
  end.issued_store_bytes[0] = end.geometry[0].total_write_bytes;
  const RequestPacket end_packet = encode(end);
  save(argc > 1 ? argv[1] : nullptr, "end.bin", end_packet);
  require(bool(decode(end_packet, decoded)), "END decode");
  response_packet_ok = encode(response_for(end, true));
  require(bool(decode(response_packet_ok, end, response)),
          "END response binding");
  response_bad = response_packet_ok; response_bad[48] ^= 4;
  require(!decode(response_bad, end, response), "END observed bytes mutation");

  Request claim;
  claim.action = Action::CLAIM; claim.event_seq = 100;
  claim.identity = identity(); claim.descriptor_count = 1;
  claim.descriptor[0] = descriptor();
  for (unsigned i = 0; i < claim.model_identity.size(); ++i)
    claim.model_identity[i] = begin.model_identity[i];
  const RequestPacket claim_packet = encode(claim);
  save(argc > 1 ? argv[1] : nullptr, "claim.bin", claim_packet);
  require(bool(decode(claim_packet, decoded)), "CLAIM decode");
  for (unsigned i = 864; i < 992; ++i)
    require(claim_packet[i] == 0, "metadata geometry zero");

  Request publish = claim;
  publish.action = Action::PUBLISH; publish.event_seq = 104;
  Response publish_response = response_for(publish);
  response_packet_ok = encode(publish_response);
  save(argc > 1 ? argv[1] : nullptr, "publish_response.bin", response_packet_ok);
  require(bool(decode(response_packet_ok, publish, response)),
          "PUBLISH response binding");

  const RequestWords words = request_words(begin_packet);
  require(words[0].byte[0] == 'L' && words[0].byte[1] == 'P' &&
          words[0].byte[2] == 'V' && words[0].byte[3] == '1' &&
          words[15].byte[63] == begin_packet[1023], "beat order");
  std::cout << "FULL_CURRENT_GENERATED_PROVENANCE_CODEC_PASS "
            << "requests=4 mutations=8 bytes=1536\n";
  return 0;
}
