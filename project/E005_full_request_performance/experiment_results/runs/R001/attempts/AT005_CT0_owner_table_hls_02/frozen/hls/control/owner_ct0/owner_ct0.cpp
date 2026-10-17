#include "owner_ct0.h"

namespace {
using namespace laya::owner_ct0;

constexpr unsigned kEntries = 32;
constexpr unsigned kIdentity = 0, kRef = 672, kRegion = 800;
constexpr unsigned kStage = 808, kLayer = 816, kBatch = 824;
constexpr unsigned kSpace = 832, kRow0 = 840, kRows = 856;
constexpr unsigned kWidth = 872, kContent = 888, kState = 896;
constexpr unsigned kReaders = 904, kCovered = 912, kValid = 5008;

enum Phase : unsigned { INIT, WAIT, SCAN, VERIFY, COMMIT, RESPOND };

Record default_record() {
  Record r = 0;
  r.range(kLayer + 7, kLayer) = 255;
  r.range(kState + 7, kState) = 6; // CacheState::INVALID
  return r;
}

ap_uint<8> ref_id(ap_uint<48> ref) { return ref.range(7, 0); }
ap_uint<8> ref_bank(ap_uint<48> ref) { return ref.range(15, 8); }
ap_uint<32> ref_epoch(ap_uint<48> ref) { return ref.range(47, 16); }
ap_uint<48> record_ref(const Record& r) { return r.range(kRef + 47, kRef); }
ap_uint<48> spec_ref(const Spec& s) { return s.range(47, 0); }
ap_uint<8> spec_id(const Spec& s) { return ref_id(spec_ref(s)); }

bool same_physical(const Record& r, const Spec& s) {
  if (r.range(kRegion + 7, kRegion) != s.range(55, 48)) return false;
  const ap_uint<48> a = record_ref(r), b = spec_ref(s);
  if (ref_id(a) == 0x2b && ref_id(b) == 0x2b) return true;
  if (ref_bank(a) != ref_bank(b)) return false;
  if (ref_id(a) == ref_id(b)) return true;
  return (ref_id(a) == 6 && ref_id(b) == 9) ||
         (ref_id(a) == 9 && ref_id(b) == 6);
}

bool same_spec(const Record& r, const Spec& s) {
  return record_ref(r) == spec_ref(s) &&
         r.range(kRegion + 7, kRegion) == s.range(55, 48) &&
         r.range(kStage + 7, kStage) == s.range(63, 56) &&
         r.range(kLayer + 7, kLayer) == s.range(71, 64) &&
         r.range(kBatch + 7, kBatch) == s.range(79, 72) &&
         r.range(kSpace + 7, kSpace) == s.range(87, 80) &&
         r.range(kRow0 + 15, kRow0) == s.range(103, 88) &&
         r.range(kRows + 15, kRows) == s.range(119, 104) &&
         r.range(kWidth + 15, kWidth) == s.range(135, 120) &&
         r.range(kContent + 7, kContent) == s.range(143, 136);
}

bool valid_identity(const Identity& id) {
  const ap_uint<16> b = id.range(143, 128), s = id.range(159, 144);
  return id.range(63, 0) != 0 && id.range(127, 64) != 0 &&
         b >= 1 && b <= 2 &&
         (s == 64 || s == 128 || s == 256 || s == 512 || s == 1024) &&
         id.range(287, 160) != 0 && id.range(415, 288) != 0 &&
         id.range(543, 416) != 0 && id.range(671, 544) != 0;
}

bool valid_ref(ap_uint<48> ref, ap_uint<8> region) {
  const ap_uint<8> id = ref_id(ref), bank = ref_bank(ref);
  const ap_uint<32> epoch = ref_epoch(ref);
  if (id == 0 || epoch == 0 || epoch > 0xfffffffeu) return false;
  if (!((id >= 1 && id <= 11) || (id >= 0x20 && id <= 0x2b)))
    return false;
  const bool dual = id == 1 || id == 5 || (id >= 0x20 && id <= 0x2b);
  if (bank > (dual ? 1 : 0)) return false;
  return id == 10 ? region <= 7 : region == 0;
}

ap_uint<16> legal_width(ap_uint<8> id, ap_uint<8> region) {
  if (id == 1 || id == 2 || id == 3 || id == 4 || id == 8 ||
      id == 11 || id == 0x20 || id == 0x2a) return 1024;
  if (id == 6) return 5248;
  if (id == 7) return 2624;
  if (id == 9) return 4096;
  if (id == 5 || id == 0x25 || id == 0x27 || id == 0x28 ||
      id == 0x29 || id == 0x2b) return 64;
  if (id == 10) {
    if (region == 7) return 0;
    constexpr unsigned widths[8] = {1024,1028,256,16,2,4,16,16};
    return region < 8 ? widths[region] : 0;
  }
  return 0;
}

bool legal_spec(const Identity& identity, const Spec& spec) {
  const ap_uint<48> ref = spec_ref(spec);
  const ap_uint<8> id = ref_id(ref), region = spec.range(55, 48);
  const ap_uint<8> stage = spec.range(63, 56);
  const ap_uint<8> batch = spec.range(79, 72), space = spec.range(87, 80);
  const ap_uint<16> row0 = spec.range(103, 88);
  const ap_uint<16> rows = spec.range(119, 104);
  const ap_uint<16> width = spec.range(135, 120);
  const ap_uint<16> S = identity.range(159, 144);
  const ap_uint<16> B = identity.range(143, 128);
  if (!valid_ref(ref, region) || !valid_identity(identity) || stage > 7 ||
      rows == 0 || width == 0 || width > 5248) return false;
  if (id >= 0x20 && id <= 0x29 && ref_bank(ref) != 0) return false;
  const ap_uint<16> fixed = legal_width(id, region);
  if (fixed && width != fixed) return false;
  if (id == 0x26 && width != S) return false;
  if (id == 10 && region == 7 &&
      !(space == 1 && width == 1 && row0 == 0 && rows == 16))
    return false;
  const ap_uint<16> extent = space == 0 ? S :
      ap_uint<16>(space == 1 ? 16 : space == 2 ? 3 : 0);
  if (!extent || ap_uint<17>(row0) + rows > extent ||
      (batch != 255 && batch >= B)) return false;
  if (id == 11) return batch == 0 && space == 2 && row0 == 0 && rows == 3;
  if (id == 8) return batch == 255 && space == 0 && row0 == 0 && rows == S;
  if (id == 0x23 || id == 0x2a || id == 0x2b)
    return batch == 0 && space == 2 && row0 == 0 && rows == 1;
  if (space == 2) return row0 == 0 && rows == 1;
  return true;
}

bool in_scope(const Identity& identity, const Spec& spec,
              ap_uint<8> batch, ap_uint<16> row0, ap_uint<16> rows) {
  const ap_uint<8> id = spec_id(spec), sb = spec.range(79, 72);
  const ap_uint<16> sr = spec.range(103, 88), sn = spec.range(119, 104);
  if (!rows || batch >= identity.range(143, 128) ||
      (sb != 255 && sb != batch) || row0 < sr ||
      ap_uint<17>(row0) + rows > ap_uint<17>(sr) + sn) return false;
  return id != 11 || batch == 0;
}

bool covered(const Record& record, const Spec& spec,
             ap_uint<8> batch, ap_uint<16> row0, ap_uint<16> rows,
             ap_uint<3> type_valid) {
  const ap_uint<8> id = spec_id(spec), space = spec.range(87, 80);
  const unsigned stride = space == 0 ? 1024 : space == 1 ? 16 : 1;
  for (unsigned row = row0; row < unsigned(row0) + rows; ++row) {
#pragma HLS unroll off
    const unsigned bit = id == 11 ? row : unsigned(batch) * stride + row;
    if (bit >= 2048 || !record[kCovered + bit] ||
        (id == 11 && !type_valid[row])) return false;
  }
  return true;
}

Response result(const Command& cmd, unsigned code, unsigned reason,
                const Record& record, ap_uint<32> commits) {
  Response out{};
  out.status = code;
  out.detail = code == 0 ? 0 :
      code == 5 ? (4u << 24) | (unsigned(spec_id(cmd.spec)) << 16) | reason :
                  (7u << 24) | reason;
  out.bad_element = ~ap_uint<64>(0);
  out.index = cmd.index;
  out.commit_count = commits;
  out.record = record;
  return out;
}
} // namespace

extern "C" void laya_owner_ct0(hls::stream<Command>& request,
                                hls::stream<Response>& response) {
#pragma HLS interface ap_ctrl_none port=return
#pragma HLS interface ap_fifo port=request
#pragma HLS interface ap_fifo port=response
#pragma HLS pipeline off
  static Record table[kEntries];
#pragma HLS bind_storage variable=table type=ram_1p impl=bram
  static ap_uint<3> phase = INIT;
  static ap_uint<6> cursor = 0, found = kEntries;
  static ap_uint<1> operations_started = 0;
  static Identity identity = 0;
  static ap_uint<1> request_valid = 0, model_header_valid = 0;
  static ap_uint<3> type_valid = 0;
  static ap_uint<32> commits = 0;
  static Command pending_cmd;
  static Response pending_response;
  static Record candidate;

  if (phase == INIT) {
    table[cursor] = default_record();
    if (cursor == kEntries - 1) { cursor = 0; phase = WAIT; }
    else ++cursor;
    return;
  }
  if (phase == RESPOND) {
    if (response.write_nb(pending_response)) phase = WAIT;
    return;
  }
  if (phase == WAIT) {
    Command cmd;
    if (!request.read_nb(cmd)) return;
    pending_cmd = cmd;
    if (cmd.op == LOAD && !operations_started && cmd.index < kEntries) {
      table[cmd.index] = cmd.record;
      pending_response = result(cmd, 0, 0, table[cmd.index], commits);
      phase = RESPOND;
    } else if (cmd.op == CONTEXT && !operations_started) {
      identity = cmd.identity;
      request_valid = cmd.request_valid;
      model_header_valid = cmd.model_header_valid;
      type_valid = cmd.type_valid;
      pending_response = result(cmd, 0, 0, 0, commits);
      phase = RESPOND;
    } else if (cmd.op == READ && cmd.index < kEntries) {
      pending_response = result(cmd, 0, 0, table[cmd.index], commits);
      phase = RESPOND;
    } else if (cmd.op == REQUIRE || cmd.op == ACQUIRE ||
               cmd.op == RELEASE_READ) {
      operations_started = 1;
      cursor = 0;
      found = kEntries;
      phase = SCAN;
    } else {
      pending_response = result(cmd, 7, 4, 0, commits);
      phase = RESPOND;
    }
    return;
  }
  if (phase == SCAN) {
    const Record r = table[cursor];
    if (ref_id(record_ref(r)) != 0 && same_physical(r, pending_cmd.spec)) {
      found = cursor;
      phase = VERIFY;
    } else if (cursor == kEntries - 1) {
      pending_response = result(pending_cmd, 5, 9, 0, commits);
      phase = RESPOND;
    } else ++cursor;
    return;
  }
  if (phase == VERIFY) {
    const Record r = table[found];
    const ap_uint<8> state = r.range(kState + 7, kState);
    const ap_uint<8> readers = r.range(kReaders + 7, kReaders);
    const bool valid = r[kValid];
    bool accepted = false;
    if (pending_cmd.op == RELEASE_READ) {
      accepted = same_spec(r, pending_cmd.spec) && state == 3 &&
                 readers != 0 && valid;
    } else {
      accepted = request_valid && model_header_valid &&
          legal_spec(identity, pending_cmd.spec) &&
          in_scope(identity, pending_cmd.spec, pending_cmd.batch,
                   pending_cmd.row0, pending_cmd.rows) &&
          same_spec(r, pending_cmd.spec) &&
          r.range(kIdentity + 671, kIdentity) == identity && valid &&
          (state == 2 || state == 3) &&
          covered(r, pending_cmd.spec, pending_cmd.batch,
                  pending_cmd.row0, pending_cmd.rows, type_valid);
      if (pending_cmd.op == ACQUIRE && readers == 255) accepted = false;
    }
    if (!accepted) {
      pending_response = result(pending_cmd, 5, 9, r, commits);
      pending_response.index = found;
      phase = RESPOND;
    } else if (pending_cmd.op == REQUIRE) {
      pending_response = result(pending_cmd, 0, 0, r, commits);
      pending_response.index = found;
      phase = RESPOND;
    } else {
      candidate = r;
      if (pending_cmd.op == ACQUIRE) {
        candidate.range(kReaders + 7, kReaders) = readers + 1;
        candidate.range(kState + 7, kState) = 3;
      } else {
        candidate.range(kReaders + 7, kReaders) = readers - 1;
        if (readers == 1) candidate.range(kState + 7, kState) = 2;
      }
      phase = COMMIT;
    }
    return;
  }
  if (phase == COMMIT) {
    table[found] = candidate;
    ++commits;
    pending_response = result(pending_cmd, 0, 0, candidate, commits);
    pending_response.index = found;
    phase = RESPOND;
  }
}
