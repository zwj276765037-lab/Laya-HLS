#include "laya_full_runtime.h"
#include "attention_preloaded_abi.h"
#include "sha256_test_only.h"

#include <array>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <map>
#include <sstream>
#include <string>
#include <vector>

extern "C" void attention_preloaded_slice(uint32_t, const uint32_t*,
                                            uint8_t*, const uint8_t*,
                                            uint8_t*, uint8_t*, uint8_t*,
                                            uint32_t*);

namespace {
namespace abi = laya::d2_preload;
using Words = std::array<uint32_t, abi::kWords>;
using Observed = std::array<uint32_t, abi::kObservedWords>;

struct Hashes {
  std::string source, prefix[2], host[2];
};
struct Gold {
  unsigned head = 0, query = 0;
  std::string score, probability, av;
};
struct Manifest {
  std::map<std::string, Hashes> cases;
  std::map<std::string, Gold> gold;
};

void require(bool ok, const std::string& message) {
  if (!ok) {
    std::fprintf(stderr, "D2_PRELOADED_FAIL %s\n", message.c_str());
    std::exit(1);
  }
}

void require_sentinel(const std::vector<uint8_t>& memory,
                      const std::string& message) {
  for (uint8_t byte : memory)
    if (byte != 0xa5) require(false, message);
}

std::vector<uint8_t> serialize(const Words& words) {
  std::vector<uint8_t> bytes(4u * words.size());
  for (unsigned i = 0; i < words.size(); ++i)
    for (unsigned b = 0; b < 4; ++b)
      bytes[4u * i + b] = uint8_t(words[i] >> (8u * b));
  return bytes;
}

std::vector<uint8_t> read_file(const std::string& name) {
  std::ifstream in(name, std::ios::binary);
  require(bool(in), "open " + name);
  return {std::istreambuf_iterator<char>(in), std::istreambuf_iterator<char>()};
}

Manifest read_manifest(const std::string& name) {
  std::ifstream stream(name);
  require(bool(stream), "open expected hashes");
  Manifest manifest;
  std::string line;
  while (std::getline(stream, line)) {
    std::istringstream row(line);
    std::string type, name;
    row >> type >> name;
    if (type == "CASE") {
      Hashes hashes;
      row >> hashes.source >> hashes.prefix[0] >> hashes.prefix[1]
          >> hashes.host[0] >> hashes.host[1];
      require(bool(row), "complete CASE manifest line");
      manifest.cases.emplace(name, hashes);
    } else if (type == "GOLD") {
      Gold gold;
      row >> gold.head >> gold.query >> gold.score
          >> gold.probability >> gold.av;
      require(bool(row), "complete GOLD manifest line");
      manifest.gold.emplace(name, gold);
    } else require(false, "known manifest record");
  }
  require(manifest.cases.size() == 4 && manifest.gold.size() == 3,
          "frozen expected scenario/gold count");
  return manifest;
}

uint32_t word(const uint8_t* p) {
  return uint32_t(p[0]) | uint32_t(p[1]) << 8 |
         uint32_t(p[2]) << 16 | uint32_t(p[3]) << 24;
}
uint64_t wide(const uint32_t* p, unsigned i) {
  return uint64_t(p[i]) | uint64_t(p[i + 1]) << 32;
}
float f32(uint32_t raw) {
  float value;
  std::memcpy(&value, &raw, 4);
  return value;
}
uint32_t bits(float value) {
  uint32_t raw;
  std::memcpy(&raw, &value, 4);
  return raw;
}
bool near(float actual, float expected) {
  return std::isfinite(actual) && std::isfinite(expected) &&
         std::abs(actual - expected) <=
             1.0e-4f + 1.0e-4f * std::abs(expected);
}
void put64(uint8_t* p, uint64_t value) {
  for (unsigned i = 0; i < 8; ++i) p[i] = uint8_t(value >> (8 * i));
}
void put64(Words& p, unsigned at, uint64_t value) {
  p[at] = uint32_t(value);
  p[at + 1] = uint32_t(value >> 32);
}
uint8_t unhex(char c) {
  if (c >= '0' && c <= '9') return uint8_t(c - '0');
  if (c >= 'a' && c <= 'f') return uint8_t(c - 'a' + 10);
  require(false, "lowercase SHA-256 hex");
  return 0;
}
void put_digest(Words& p, unsigned first, const std::string& hex) {
  require(hex.size() == 64, "SHA-256 hex length");
  for (unsigned i = 0; i < 8; ++i) {
    uint8_t bytes[4];
    for (unsigned b = 0; b < 4; ++b)
      bytes[b] = uint8_t(unhex(hex[8 * i + 2 * b]) << 4 |
                         unhex(hex[8 * i + 2 * b + 1]));
    p[first + i] = word(bytes);
  }
}

Words descriptor(const std::vector<uint8_t>& io, const Hashes& hashes,
                 unsigned head, unsigned query, unsigned scenario) {
  require(io.size() >= 104, "request header present");
  Words p{};
  p[0] = abi::kMagic;
  p[1] = abi::kVersion;
  p[2] = abi::kBegin;
  p[3] = (1u << 16) | 64u;
  p[4] = word(io.data() + 24);
  p[5] = word(io.data() + 28);
  p[6] = word(io.data() + 32);
  p[7] = word(io.data() + 36);
  p[10] = 0;
  p[11] = 1;
  p[14] = abi::kSourceBytes;
  p[15] = abi::kPrefixBytes;
  put_digest(p, 16, hashes.source);
  put_digest(p, 24, hashes.prefix[0]);
  put_digest(p, 32, hashes.prefix[1]);
  for (unsigned i = 0; i < 4; ++i) p[40 + i] = word(io.data() + 88 + 4 * i);
  p[44] = head;
  p[45] = query;
  p[46] = abi::kWords;
  p[47] = scenario;
  return p;
}

std::vector<uint8_t> request(const std::vector<uint8_t>& source,
                             uint64_t id, uint64_t generation) {
  require(source.size() == 832, "original request span");
  std::vector<uint8_t> result = source;
  put64(result.data() + 24, id);
  put64(result.data() + 32, generation);
  result.resize(32768, 0);
  return result;
}

void invoke(uint32_t command, const Words& desc, std::vector<uint8_t>& io,
            const std::vector<uint8_t>& aux, std::vector<uint8_t>& bank0,
            std::vector<uint8_t>& bank1, std::vector<uint8_t>& out,
            Observed& observed) {
  observed.fill(0xdeadbeefu);
  attention_preloaded_slice(command, desc.data(), io.data(), aux.data(),
                            bank0.data(), bank1.data(), out.data(),
                            observed.data());
}

struct Image {
  std::vector<uint8_t> bank[2];
  std::array<uint64_t, 48> masks{};
  Image() : bank{std::vector<uint8_t>(abi::kHostBytes, 0xa5),
                 std::vector<uint8_t>(abi::kHostBytes, 0xa5)} {}
};

void scatter(Image& image, const std::vector<uint8_t>& raw,
             const std::string& scenario) {
  require(raw.size() == abi::kSourceBytes, "raw source size");
  laya::full::FullMemory memory;
  memory.qkv0 = image.bank[0].data(); memory.qkv0_bytes = abi::kHostBytes;
  memory.qkv1 = image.bank[1].data(); memory.qkv1_bytes = abi::kHostBytes;
  for (unsigned plane = 0; plane < 3; ++plane)
    for (unsigned head = 0; head < 16; ++head)
      for (unsigned row = 0; row < 64; ++row) {
        const bool absent = (scenario == "missing_plane" && plane == 2) ||
                            (scenario == "missing_row" && plane == 1 &&
                             head == 1 && row == 63);
        if (absent) continue;
        laya::Address address;
        laya::Check c = laya::qkv_address(uint8_t(plane), 0, uint8_t(head),
                                         uint16_t(row), 0, 1, 64, address);
        require(bool(c), "producer qkv_address");
        const unsigned source = 4u * (row * 3072u + plane * 1024u + head * 64u);
        c = laya::full::full_write(memory, address.bo, address.offset,
                                   raw.data() + source, 256);
        require(bool(c), "producer full_write completes before row receipt");
        image.masks[plane * 16 + head] |= uint64_t(1) << row;
      }
}

struct ImageCheck {
  bool valid = true;
  size_t checked = 0;
  size_t first_bad = 0;
  std::string actual_prefix[2], actual_host[2];
};

ImageCheck check_image(const Image& image, const std::vector<uint8_t>& raw,
                       const Hashes& expected) {
  ImageCheck result;
  require(d2_test_hash::sha256(raw.data(), raw.size()) == expected.source,
          "source hash matches independent manifest");
  for (unsigned shard = 0; shard < 2; ++shard) {
    const auto& bank = image.bank[shard];
    require(bank.size() == abi::kHostBytes, "full host shard size");
    // Independent inverse layout: derive source coordinates from every
    // physical word; do not call qkv_address or use the scatter offset.
    for (size_t byte = 0; byte < bank.size(); ++byte) {
      const size_t index = byte >> 2;
      const unsigned plane = unsigned(index >> 20);
      const unsigned batch = unsigned(index >> 19) & 1u;
      const unsigned local_head = unsigned(index >> 16) & 7u;
      const unsigned row = unsigned(index >> 6) & 1023u;
      const unsigned d = unsigned(index) & 63u;
      const unsigned head = 2 * local_head + shard;
      uint8_t correct = 0xa5;
      if (plane < 3 && batch == 0 && row < 64 &&
          (image.masks[plane * 16 + head] & (uint64_t(1) << row))) {
        const size_t source =
            4u * (row * 3072u + plane * 1024u + head * 64u + d) + (byte & 3u);
        correct = raw[source];
      }
      if (bank[byte] != correct && result.valid) {
        result.valid = false;
        result.first_bad = shard * abi::kHostBytes + byte;
      }
      ++result.checked;
    }
    result.actual_prefix[shard] = d2_test_hash::sha256(bank.data(), abi::kPrefixBytes);
    result.actual_host[shard] = d2_test_hash::sha256(bank.data(), bank.size());
    if (result.actual_prefix[shard] != expected.prefix[shard] ||
        result.actual_host[shard] != expected.host[shard])
      result.valid = false;
  }
  return result;
}

Words receipt(Words begin, const Observed& observed, const Image& image) {
  begin[2] = abi::kRun;
  put64(begin, 8, wide(observed.data(), abi::kObsTicketLo));
  begin[12] = observed[4];
  begin[13] = observed[5];
  for (unsigned i = 0; i < 48; ++i)
    put64(begin, abi::kDescriptorMasks + 2 * i, image.masks[i]);
  return begin;
}

void check_begin(const Observed& seen, const Image& image) {
  require(seen[0] == 0 && seen[2] == 1 && seen[3] == 0 &&
          seen[4] != 0 && seen[5] != 0 &&
          seen[12] == uint32_t(laya::Buffer::QKV) && seen[13] == 0 &&
          seen[14] == uint32_t(laya::Buffer::QKV) && seen[15] == 1 &&
          wide(seen.data(), abi::kObsTicketLo) != 0 &&
          seen[abi::kObsCoverageBits] == 0 &&
          seen[abi::kObsOwner0State] == uint32_t(laya::CacheState::FILL) &&
          seen[abi::kObsOwner1State] == uint32_t(laya::CacheState::FILL) &&
          seen[abi::kObsFinal0Epoch] == 0 &&
          seen[abi::kObsFinal1Epoch] == 0 && seen[9] == 0,
          "BEGIN claimed two empty FILL owners without tasks");
  require_sentinel(image.bank[0], "BEGIN left entire QKV0 host image sentinel");
  require_sentinel(image.bank[1], "BEGIN left entire QKV1 host image sentinel");
}

void check_numeric(const Observed& seen, const std::vector<uint8_t>& raw,
                   const std::vector<uint8_t>& out,
                   const std::string& fixture, const std::string& gold_name,
                   const Gold& expected) {
  const auto score = read_file(fixture + "/" + gold_name + "_score.f32.bin");
  const auto probability = read_file(fixture + "/" + gold_name + "_probability.f32.bin");
  const auto av = read_file(fixture + "/" + gold_name + "_av.f32.bin");
  require(score.size() == 256 && probability.size() == 256 && av.size() == 256 &&
          d2_test_hash::sha256(score.data(), score.size()) == expected.score &&
          d2_test_hash::sha256(probability.data(), probability.size()) == expected.probability &&
          d2_test_hash::sha256(av.data(), av.size()) == expected.av,
          "independent numerical gold identities");
  require(seen[0] == 0 && seen[1] == 0 && seen[2] == 13 && seen[3] == 4 &&
          seen[6] == 32768 && seen[9] == 4 && seen[10] == 0 &&
          seen[abi::kObsQkElements] == 64 &&
          seen[abi::kObsSoftmaxElements] == 64 &&
          seen[abi::kObsAvElements] == 64 &&
          seen[abi::kObsOwner0State] == uint32_t(laya::CacheState::READY) &&
          seen[abi::kObsOwner1State] == uint32_t(laya::CacheState::READY) &&
          seen[abi::kObsCoverageBits] == 3072 &&
          seen[abi::kObsFinal0Epoch] == seen[4] &&
          seen[abi::kObsFinal1Epoch] == seen[5] &&
          seen[11] >= 5 &&
          seen[7] == uint32_t(laya::Status::E_BUFFER) &&
          seen[8] == laya::detail(4, uint8_t(laya::Buffer::ATT_OUT), 9) &&
          seen[abi::kObsCleanupStatus] == 0,
          "published QKV, four TaskDone values, partial ATT_OUT rejection");
  for (unsigned key = 0; key < 64; ++key) {
    require(seen[16 + key] == word(score.data() + 4 * key),
            "QK exact independent score");
    require(near(f32(seen[80 + key]), f32(word(probability.data() + 4 * key))),
            "softmax independent nonlinear tolerance");
  }
  const size_t selected = 4u * (expected.query * 1024u + expected.head * 64u);
  for (unsigned d = 0; d < 64; ++d) {
    float exact = 0.0f;
    for (unsigned key = 0; key < 64; ++key) {
      const size_t src = 4u * (key * 3072u + 2048u + expected.head * 64u + d);
      const float product = f32(seen[80 + key]) * f32(word(raw.data() + src));
      exact = exact + product;
    }
    require(seen[144 + d] == bits(exact), "AV exact from actual probability");
    require(near(f32(seen[144 + d]), f32(word(av.data() + 4 * d))),
            "AV independent end-to-end tolerance");
    require(word(out.data() + selected + 4 * d) == seen[144 + d],
            "ATT_OUT physical word equals observed AV");
  }
  for (size_t byte = 0; byte < out.size(); ++byte)
    if (byte < selected || byte >= selected + 256)
      require(out[byte] == 0xa5, "all other ATT_OUT bytes remain sentinel");
  require(seen[208] == 0xdeadbeefu,
          "observed numerical tail remains sentinel");
}

void expect_protocol(const Observed& seen, uint32_t phase,
                     abi::Reason reason, unsigned command) {
  require(seen[0] == uint32_t(laya::Status::E_PROTOCOL) &&
          seen[1] == laya::detail(0xd2, uint8_t(command), uint16_t(reason)) &&
          seen[2] == phase,
          "diagnostic E_PROTOCOL detail/phase");
}

}  // namespace

int main(int argc, char** argv) {
  require(argc == 4, "usage: TB PACKAGE OLD_FIXTURE PRELOADED_FIXTURE");
  const std::string package = argv[1], old = argv[2], fixture = argv[3];
  const auto original_request = read_file(old + "/request.bin");
  const auto base = read_file(old + "/qkv_final.f32.bin");
  const auto changed = read_file(fixture + "/qkv_changed.f32.bin");
  const auto aux = read_file(package + "/aux.bin");
  const auto manifest = read_manifest(fixture + "/expected_hashes.txt");
  require(original_request.size() == 832 && base.size() == abi::kSourceBytes &&
          changed.size() == abi::kSourceBytes && aux.size() == 1671872,
          "frozen request, raw QKV and package spans");
  require(d2_test_hash::sha256(reinterpret_cast<const uint8_t*>("abc"), 3) ==
          "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
          "testbench SHA-256 known-answer vector");
  Words known_digest{};
  put_digest(known_digest, 16,
             "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
  require(known_digest[16] == 0xbf1678bau && known_digest[17] == 0xeacf018fu &&
          known_digest[23] == 0xad1500f2u,
          "independent SHA-256 abc digest serialized as little-endian U32 words");
  const Words serialization = descriptor(request(original_request, 301, 1),
                                         manifest.cases.at("base"), 0, 0, 1);
  require(serialization[16] == 0xe00e3fceu &&
          serialization[24] == 0xf981e992u &&
          serialization[40] == 0x8a7c06feu,
          "frozen SHA/build-tag byte-to-word little-endian serialization");
  require(manifest.cases.at("base").source != manifest.cases.at("changed").source &&
          manifest.gold.at("base_h0_r0").score != manifest.gold.at("changed_h0_r0").score &&
          manifest.gold.at("base_h0_r0").probability != manifest.gold.at("changed_h0_r0").probability &&
          manifest.gold.at("base_h0_r0").av != manifest.gold.at("changed_h0_r0").av,
          "changed source changes QK, probability and AV independent gold");

  uint64_t sequence = 301;
  uint64_t last_ticket = 0;
  uint32_t last_epoch[2] = {};
  unsigned scenarios = 0, negatives = 0;
  auto next_io = [&]() {
    const uint64_t id = sequence++;
    return request(original_request, id, id - 300);
  };
  auto check_fresh = [&](const Observed& seen) {
    const uint64_t ticket = wide(seen.data(), abi::kObsTicketLo);
    require(ticket == last_ticket + 1 && seen[4] == last_epoch[0] + 1 &&
            seen[5] == last_epoch[1] + 1,
            "ticket and both QKV epochs advance exactly once across recovery");
    last_ticket = ticket;
    last_epoch[0] = seen[4];
    last_epoch[1] = seen[5];
  };

  auto legal = [&](const std::string& name, const std::vector<uint8_t>& raw,
                   unsigned head, unsigned query, const std::string& gold_name,
                   bool check_pending_begin, bool check_replay) {
    auto io = next_io();
    Image image;
    std::vector<uint8_t> out(8u << 20, 0xa5);
    Words begin = descriptor(io, manifest.cases.at(name), head, query,
                             unsigned(sequence));
    if (name == "base" && head == 0 && query == 0) {
      const auto frozen = read_file(fixture + "/base_h0_r0_begin.u32le.bin");
      require(serialize(begin) == frozen,
              "first BEGIN descriptor equals independently frozen 640-byte page");
    }
    Observed seen;
    invoke(abi::kBegin, begin, io, aux, image.bank[0], image.bank[1], out, seen);
    check_begin(seen, image);
    check_fresh(seen);
    require(seen[abi::kObsRequestLo] == begin[4] &&
            seen[abi::kObsGenerationLo] == begin[6],
            "BEGIN reports accepted request and generation");
    const Observed begin_seen = seen;
    if (check_pending_begin) {
      invoke(abi::kBegin, begin, io, aux, image.bank[0], image.bank[1], out, seen);
      expect_protocol(seen, 1, abi::BEGIN_PENDING, abi::kBegin);
      require(seen[abi::kObsOwner0State] == uint32_t(laya::CacheState::FILL),
              "rejected second BEGIN preserved pending import");
      require_sentinel(out, "rejected second BEGIN leaves whole ATT_OUT sentinel");
      ++negatives;
      std::printf("D2_PRELOADED_NEGATIVE_PASS begin_while_pending E_PROTOCOL\n");
    }
    scatter(image, raw, name);
    const ImageCheck physical = check_image(image, raw, manifest.cases.at(name));
    require(physical.valid && physical.checked == 2u * abi::kHostBytes,
            "complete independent inverse-layout and hash check before RUN");
    Words run = receipt(begin, begin_seen, image);
    if (name == "base" && head == 0 && query == 0) {
      const auto frozen = read_file(fixture + "/base_h0_r0_run_ticket1_epoch1.u32le.bin");
      require(serialize(run) == frozen,
              "first RUN receipt equals independently frozen 640-byte page");
    }
    invoke(abi::kRun, run, io, aux, image.bank[0], image.bank[1], out, seen);
    require(check_image(image, raw, manifest.cases.at(name)).valid,
            "RUN preserved both full physical QKV images and hashes");
    check_numeric(seen, raw, out, fixture, gold_name, manifest.gold.at(gold_name));
    if (check_replay) {
      const auto accepted_output = out;
      invoke(abi::kRun, run, io, aux, image.bank[0], image.bank[1], out, seen);
      expect_protocol(seen, 3, abi::NO_PENDING, abi::kRun);
      require(seen[3] == 4 && seen[9] == 4 &&
              seen[abi::kObsCoverageBits] == 3072,
              "replayed RUN leaves tasks and coverage unchanged");
      require(out == accepted_output, "replayed RUN leaves complete ATT_OUT unchanged");
      require(check_image(image, raw, manifest.cases.at(name)).valid,
              "replayed RUN preserved both full QKV images and hashes");
      ++negatives;
      std::printf("D2_PRELOADED_NEGATIVE_PASS replay_RUN E_PROTOCOL\n");
    }
    ++scenarios;
    std::printf("D2_PRELOADED_CASE_PASS %s head=%u row=%u qkv_bytes=%u tasks=4 owner_claims=%u prefix0=%s prefix1=%s\n",
                name.c_str(), head, query, abi::kSourceBytes,
                seen[11], physical.actual_prefix[0].c_str(),
                physical.actual_prefix[1].c_str());
  };

  auto missing = [&](const std::string& name) {
    auto io = next_io();
    Image image;
    std::vector<uint8_t> out(8u << 20, 0xa5);
    Words begin = descriptor(io, manifest.cases.at(name), 0, 0,
                             unsigned(sequence));
    Observed seen;
    invoke(abi::kBegin, begin, io, aux, image.bank[0], image.bank[1], out, seen);
    check_begin(seen, image);
    check_fresh(seen);
    const Observed begin_seen = seen;
    scatter(image, base, name);
    const ImageCheck physical = check_image(image, base, manifest.cases.at(name));
    require(physical.valid && physical.checked == 2u * abi::kHostBytes,
            "missing image independently verified with sentinel holes");
    Words run = receipt(begin, begin_seen, image);
    invoke(abi::kRun, run, io, aux, image.bank[0], image.bank[1], out, seen);
    require(check_image(image, base, manifest.cases.at(name)).valid,
            "failed publish preserved both full QKV images and hashes");
    require(seen[0] == uint32_t(laya::Status::E_BUFFER) &&
            seen[1] == laya::detail(4, uint8_t(laya::Buffer::QKV), 9) &&
            seen[2] == 5 &&
            seen[3] == 0 && seen[9] == 0 &&
            seen[abi::kObsFinal0Epoch] == 0 &&
            seen[abi::kObsFinal1Epoch] == 0 &&
            seen[abi::kObsOwner0State] == uint32_t(laya::CacheState::INVALID) &&
            seen[abi::kObsOwner1State] == uint32_t(laya::CacheState::INVALID) &&
            seen[abi::kObsCleanupStatus] == 0,
            "real publish rejects missing coverage and cleanup invalidates FILL");
    require_sentinel(out, "missing coverage leaves entire ATT_OUT sentinel");
    ++negatives;
    std::printf("D2_PRELOADED_NEGATIVE_PASS %s publish E_BUFFER\n", name.c_str());
  };

  auto bad_receipt = [&](const std::string& name, unsigned slot,
                         abi::Reason reason) {
    auto io = next_io();
    Image image;
    std::vector<uint8_t> out(8u << 20, 0xa5);
    Words begin = descriptor(io, manifest.cases.at("base"), 0, 0,
                             unsigned(sequence));
    Observed seen;
    invoke(abi::kBegin, begin, io, aux, image.bank[0], image.bank[1], out, seen);
    check_begin(seen, image);
    check_fresh(seen);
    const Observed begin_seen = seen;
    scatter(image, base, "base");
    require(check_image(image, base, manifest.cases.at("base")).valid,
            "bad receipt case has valid physical image");
    Words run = receipt(begin, begin_seen, image);
    run[slot] ^= 1u;
    invoke(abi::kRun, run, io, aux, image.bank[0], image.bank[1], out, seen);
    require(check_image(image, base, manifest.cases.at("base")).valid,
            "bad receipt RUN preserved both full QKV images and hashes");
    expect_protocol(seen, 3, reason, abi::kRun);
    require(seen[3] == 0 && seen[9] == 0 &&
            seen[abi::kObsCoverageBits] == 0 &&
            seen[abi::kObsFinal0Epoch] == 0 &&
            seen[abi::kObsFinal1Epoch] == 0 &&
            seen[abi::kObsCleanupStatus] == 0 &&
            seen[abi::kObsOwner0State] == uint32_t(laya::CacheState::INVALID) &&
            seen[abi::kObsOwner1State] == uint32_t(laya::CacheState::INVALID),
            "bad receipt rejected before coverage and recovered FILL owners");
    require_sentinel(out, "bad receipt leaves entire ATT_OUT sentinel");
    ++negatives;
    std::printf("D2_PRELOADED_NEGATIVE_PASS %s E_PROTOCOL\n", name.c_str());
  };

  auto bad_begin = [&](const std::string& name, unsigned slot,
                       abi::Reason reason) {
    auto io = next_io();
    Image image;
    std::vector<uint8_t> out(8u << 20, 0xa5);
    Words begin = descriptor(io, manifest.cases.at("base"), 0, 0,
                             unsigned(sequence));
    if (slot == 44) begin[slot] = 16;
    else begin[slot] ^= 1u;
    Observed seen;
    invoke(abi::kBegin, begin, io, aux, image.bank[0], image.bank[1], out, seen);
    expect_protocol(seen, 1, reason, abi::kBegin);
    require(seen[3] == 0 && seen[9] == 0 &&
            seen[abi::kObsFinal0Epoch] == 0,
            "malformed BEGIN does not claim or publish QKV");
    require_sentinel(out, "malformed BEGIN leaves entire ATT_OUT sentinel");
    ++negatives;
    std::printf("D2_PRELOADED_NEGATIVE_PASS %s E_PROTOCOL\n", name.c_str());
  };

  legal("base", base, 0, 0, "base_h0_r0", true, true);
  missing("missing_plane");
  missing("missing_row");
  bad_receipt("stale_ticket", 8, abi::BAD_TICKET);
  bad_receipt("wrong_request", 4, abi::BAD_METADATA);
  bad_receipt("wrong_generation", 6, abi::BAD_METADATA);
  bad_receipt("wrong_bank", 11, abi::BAD_DESCRIPTOR);
  bad_receipt("wrong_epoch", 12, abi::BAD_EPOCH);
  bad_receipt("wrong_source_hash", 16, abi::BAD_METADATA);
  bad_receipt("wrong_image_hash", 24, abi::BAD_METADATA);
  bad_begin("wrong_version", 1, abi::BAD_DESCRIPTOR);
  bad_begin("wrong_shape", 44, abi::BAD_SHAPE);
  bad_begin("wrong_build_tag", 40, abi::BAD_IDENTITY);
  bad_begin("nonzero_reserved", 48, abi::BAD_DESCRIPTOR);
  bad_begin("wrong_words", 46, abi::BAD_DESCRIPTOR);
  legal("base", base, 15, 63, "base_h15_r63", false, false);
  legal("changed", changed, 0, 0, "changed_h0_r0", false, false);

  // A deliberately false complete receipt is blocked by the test producer's
  // independent physical checker. It is never handed to the hardware as a
  // claim that the hardware can authenticate arbitrary host payloads.
  Image corrupted;
  scatter(corrupted, base, "base");
  corrupted.bank[1][4u * ((1u * 2u * 8u + 0u) * 1024u * 64u)] ^= 1u;
  Words false_begin = descriptor(request(original_request, 301, 1),
                                 manifest.cases.at("base"), 0, 0, 302);
  Observed claimed{};
  claimed[4] = 1; claimed[5] = 1;
  claimed[abi::kObsTicketLo] = 1;
  Words false_run = receipt(false_begin, claimed, corrupted);
  require(serialize(false_run) ==
          read_file(fixture + "/base_h0_r0_run_ticket1_epoch1.u32le.bin"),
          "corrupt image has an otherwise complete, correctly serialized false receipt");
  const ImageCheck bad = check_image(corrupted, base, manifest.cases.at("base"));
  require(!bad.valid && bad.checked == 2u * abi::kHostBytes,
          "false complete receipt blocked by independent physical checker");
  ++negatives;
  std::printf("D2_PRELOADED_NEGATIVE_PASS corrupt_image blocked_before_RUN first_bad=%zu\n",
              bad.first_bad);
  std::printf("D2_ATTENTION_PRELOADED_CPU_PASS legal=%u negative=%u host_bytes_per_image=%u\n",
              scenarios, negatives, 2u * abi::kHostBytes);
}
