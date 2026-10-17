// XRT engineering entry for one complete, pre-encoded Laya F0 request.
// The request frame must already carry this model package's four nonzero tags.
#if !__has_include(<xrt/xrt_bo.h>) || !__has_include(<xrt/xrt_device.h>) || \
    !__has_include(<xrt/xrt_kernel.h>) || !__has_include(<ert.h>)
#error "Laya XRT Host requires installed XRT C++ headers and a matching runtime"
#endif

#include <xrt/xrt_bo.h>
#include <xrt/xrt_device.h>
#include <xrt/xrt_kernel.h>
#include <ert.h>
#include <openssl/evp.h>

#include "laya_io.h"
#include "laya_model_layout_generated.h"

#include <algorithm>
#include <array>
#include <charconv>
#include <chrono>
#include <cstdint>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <stdexcept>
#include <string>
#include <string_view>
#include <vector>

namespace {
namespace fs = std::filesystem;

[[noreturn]] void fail(const std::string& message) {
  throw std::runtime_error(message);
}
void require(bool condition, const std::string& message) {
  if (!condition) fail(message);
}

// The exporter manifest has much more information than the Host needs. Parse
// real JSON objects and skip unrelated values while rejecting duplicate keys.
// This avoids accepting a hash from an unrelated nested object or an escaped
// string that a substring/regular-expression search would misinterpret.
class JsonCursor {
 public:
  explicit JsonCursor(std::string_view source) : source_(source) {}
  void space() {
    while (at_ < source_.size() &&
           (source_[at_] == ' ' || source_[at_] == '\n' ||
            source_[at_] == '\r' || source_[at_] == '\t')) ++at_;
  }
  bool done() { space(); return at_ == source_.size(); }
  char peek() { space(); require(at_ < source_.size(), "truncated manifest JSON");
                return source_[at_]; }
  void expect(char value) {
    space(); require(at_ < source_.size() && source_[at_] == value,
                     "malformed manifest JSON");
    ++at_;
  }
  std::string string() {
    expect('"');
    std::string result;
    while (at_ < source_.size()) {
      const unsigned char c = static_cast<unsigned char>(source_[at_++]);
      if (c == '"') return result;
      if (c == '\\') {
        require(at_ < source_.size(), "truncated JSON escape");
        const char escaped = source_[at_++];
        switch (escaped) {
          case '"': case '\\': case '/': result.push_back(escaped); break;
          case 'b': result.push_back('\b'); break;
          case 'f': result.push_back('\f'); break;
          case 'n': result.push_back('\n'); break;
          case 'r': result.push_back('\r'); break;
          case 't': result.push_back('\t'); break;
          default: fail("unsupported JSON string escape in manifest");
        }
      } else {
        require(c >= 0x20, "control character in manifest string");
        result.push_back(static_cast<char>(c));
      }
    }
    fail("unterminated manifest string");
  }
  std::string_view value() {
    space();
    const size_t start = at_;
    const char first = peek();
    if (first == '"') {
      string();
    } else if (first == '{' || first == '[') {
      const char closing = first == '{' ? '}' : ']';
      ++at_;
      while (peek() != closing) {
        if (first == '{') {
          string(); expect(':');
        }
        value();
        if (peek() == ',') { ++at_; continue; }
        require(peek() == closing, "malformed manifest compound value");
      }
      ++at_;
    } else {
      while (at_ < source_.size() && source_[at_] != ',' &&
             source_[at_] != '}' && source_[at_] != ']' &&
             source_[at_] != ' ' && source_[at_] != '\n' &&
             source_[at_] != '\r' && source_[at_] != '\t') ++at_;
      require(at_ > start, "empty manifest value");
    }
    return source_.substr(start, at_ - start);
  }
  std::map<std::string, std::string_view> object() {
    std::map<std::string, std::string_view> fields;
    expect('{');
    if (peek() == '}') { ++at_; return fields; }
    for (;;) {
      const std::string key = string();
      expect(':');
      const std::string_view item = value();
      require(fields.emplace(key, item).second, "duplicate manifest JSON key");
      const char next = peek();
      if (next == '}') { ++at_; return fields; }
      expect(',');
    }
  }
 private:
  std::string_view source_;
  size_t at_ = 0;
};

using JsonFields = std::map<std::string, std::string_view>;
JsonFields json_object(std::string_view source) {
  JsonCursor cursor(source);
  JsonFields fields = cursor.object();
  require(cursor.done(), "trailing manifest JSON");
  return fields;
}
std::string_view field(const JsonFields& object, const std::string& key) {
  const auto found = object.find(key);
  require(found != object.end(), "missing manifest field: " + key);
  return found->second;
}
std::string json_string(std::string_view source) {
  JsonCursor cursor(source);
  std::string result = cursor.string();
  require(cursor.done(), "trailing manifest string");
  return result;
}
uint64_t json_uint(std::string_view source) {
  uint64_t value = 0;
  const auto result = std::from_chars(source.data(), source.data() +
                                    source.size(), value);
  require(result.ec == std::errc{} &&
          result.ptr == source.data() + source.size(),
          "invalid manifest unsigned integer");
  return value;
}

std::string hex(const uint8_t* data, size_t size) {
  constexpr char digits[] = "0123456789abcdef";
  std::string result(size * 2, '0');
  for (size_t i = 0; i < size; ++i) {
    result[2 * i] = digits[data[i] >> 4];
    result[2 * i + 1] = digits[data[i] & 15];
  }
  return result;
}
void check_hex_sha256(const std::string& value, const std::string& label) {
  require(value.size() == 64, label + " must be 64 hex digits");
  for (char c : value)
    require((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f'),
            label + " has non-lowercase-hex digit");
}

using Digest = std::array<uint8_t, 32>;
class Sha256 {
 public:
  Sha256() : context_(EVP_MD_CTX_new(), EVP_MD_CTX_free) {
    require(bool(context_) && EVP_DigestInit_ex(context_.get(), EVP_sha256(),
                                               nullptr) == 1,
            "OpenSSL SHA-256 initialization failed");
  }
  void update(const void* data, size_t size) {
    require(EVP_DigestUpdate(context_.get(), data, size) == 1,
            "OpenSSL SHA-256 update failed");
  }
  Digest finish() {
    Digest result{};
    unsigned count = 0;
    require(EVP_DigestFinal_ex(context_.get(), result.data(), &count) == 1 &&
            count == result.size(), "OpenSSL SHA-256 final failed");
    return result;
  }
 private:
  std::unique_ptr<EVP_MD_CTX, decltype(&EVP_MD_CTX_free)> context_;
};

std::string sha256_file(const fs::path& path) {
  std::ifstream stream(path, std::ios::binary);
  require(bool(stream), "cannot open " + path.string());
  std::vector<uint8_t> chunk(4 * 1024 * 1024);
  Sha256 sha;
  while (stream.read(reinterpret_cast<char*>(chunk.data()), chunk.size()) ||
         stream.gcount())
    sha.update(chunk.data(), size_t(stream.gcount()));
  require(stream.eof(), "read failure: " + path.string());
  const Digest digest = sha.finish();
  return hex(digest.data(), digest.size());
}

std::vector<uint8_t> read_small(const fs::path& path, size_t limit) {
  const uintmax_t size = fs::file_size(path);
  require(size <= limit, "input exceeds limit: " + path.string());
  std::vector<uint8_t> data(size);
  std::ifstream stream(path, std::ios::binary);
  require(bool(stream) && bool(stream.read(reinterpret_cast<char*>(data.data()),
                                           data.size())),
          "cannot read " + path.string());
  return data;
}

struct ModelFile {
  const char* name;
  std::string file;
  uint64_t bytes = 0;
  std::string sha256;
};
struct Manifest {
  std::array<ModelFile, 5> model{};
  std::array<std::string, 4> tags{};
  std::string source_sha256;
};
Manifest parse_manifest(const fs::path& path) {
  const auto raw = read_small(path, 4 * 1024 * 1024);
  const std::string source(raw.begin(), raw.end());
  const JsonFields root = json_object(source);
  require(json_string(field(root, "schema")) == "laya-model-p2-v1",
          "wrong model package schema");
  const JsonFields bo = json_object(field(root, "bo"));
  const JsonFields tags = json_object(field(root, "tags"));
  const JsonFields source_model = json_object(field(root, "source_model"));
  Manifest manifest;
  constexpr const char* names[5] = {"embedding", "w_q0", "w_q1",
                                     "w_scale", "aux"};
  require(bo.size() == 5, "unexpected BO entry count");
  for (unsigned i = 0; i < 5; ++i) {
    const JsonFields item = json_object(field(bo, names[i]));
    manifest.model[i] = {names[i], json_string(field(item, "file")),
                         json_uint(field(item, "size")),
                         json_string(field(item, "sha256"))};
    check_hex_sha256(manifest.model[i].sha256, names[i]);
    require(manifest.model[i].file == std::string(names[i]) + ".bin" &&
            manifest.model[i].bytes == laya::full::kFullModelBoSizes[i],
            "BO file name/size differs from generated model table");
  }
  constexpr const char* tag_names[4] = {"model", "numeric", "layout", "build"};
  const uint8_t* expected[4] = {laya::full::kFullModelTag,
                                laya::full::kFullNumericTag,
                                laya::full::kFullLayoutTag,
                                laya::full::kFullBuildTag};
  for (unsigned i = 0; i < 4; ++i) {
    manifest.tags[i] = json_string(field(tags, tag_names[i]));
    require(manifest.tags[i].size() == 32 &&
            manifest.tags[i] == hex(expected[i], 16),
            std::string("manifest ") + tag_names[i] + " tag mismatch");
  }
  manifest.source_sha256 = json_string(field(source_model, "sha256"));
  check_hex_sha256(manifest.source_sha256, "source GGUF SHA");
  require(manifest.source_sha256 ==
          hex(laya::full::kFullSourceSha256, 32),
          "manifest source GGUF differs from compiled model");
  return manifest;
}

struct Options {
  fs::path xclbin, package, request, result;
  std::string xclbin_sha256;
  unsigned device = 0;
  unsigned timeout_ms = 0;
};
unsigned unsigned_arg(const std::string& value, const char* label) {
  unsigned output = 0;
  const auto parsed = std::from_chars(value.data(), value.data() + value.size(),
                                      output);
  require(parsed.ec == std::errc{} &&
          parsed.ptr == value.data() + value.size(),
          std::string("invalid ") + label);
  return output;
}
Options parse_options(int argc, char** argv) {
  Options options;
  for (int i = 1; i < argc; i += 2) {
    require(i + 1 < argc, "missing option value");
    const std::string key = argv[i], value = argv[i + 1];
    if (key == "--xclbin") options.xclbin = value;
    else if (key == "--xclbin-sha256") options.xclbin_sha256 = value;
    else if (key == "--package") options.package = value;
    else if (key == "--request") options.request = value;
    else if (key == "--result") options.result = value;
    else if (key == "--device") options.device = unsigned_arg(value, "device");
    else if (key == "--timeout-ms")
      options.timeout_ms = unsigned_arg(value, "timeout-ms");
    else fail("unknown option: " + key);
  }
  require(!options.xclbin.empty() && !options.package.empty() &&
          !options.request.empty() && !options.result.empty() &&
          !options.xclbin_sha256.empty() && options.timeout_ms > 0,
          "usage: laya_host --xclbin FILE --xclbin-sha256 HEX "
          "--package DIR --request FRAME --result RESULT "
          "--timeout-ms N [--device INDEX]");
  check_hex_sha256(options.xclbin_sha256, "expected xclbin SHA");
  return options;
}

void verify_aux_header(const uint8_t* aux, uint64_t size) {
  require(size >= 128 && std::memcmp(aux, "LYMP", 4) == 0 &&
          laya::read_u16(aux, 4) == 1 && laya::read_u16(aux, 6) == 0 &&
          laya::read_u32(aux, 8) == 128 &&
          laya::read_u32(aux, 12) == 13 &&
          laya::read_u32(aux, 16) == 1,
          "model aux header format mismatch");
  for (unsigned i = 20; i < 32; ++i)
    require(aux[i] == 0, "model aux header reserved bytes");
  const uint8_t* tags[4] = {laya::full::kFullModelTag,
                            laya::full::kFullNumericTag,
                            laya::full::kFullLayoutTag,
                            laya::full::kFullBuildTag};
  for (unsigned i = 0; i < 4; ++i)
    require(std::memcmp(aux + 32 + 16 * i, tags[i], 16) == 0,
            "model aux tag mismatch");
  require(std::memcmp(aux + 96, laya::full::kFullSourceSha256, 32) == 0,
          "model aux complete GGUF SHA mismatch");
}

void upload_model(xrt::bo& bo, const fs::path& path,
                  const ModelFile& expected) {
  require(fs::file_size(path) == expected.bytes,
          "model BO size mismatch: " + path.string());
  std::ifstream stream(path, std::ios::binary);
  require(bool(stream), "cannot open model BO: " + path.string());
  auto* mapped = bo.map<uint8_t*>();
  Sha256 sha;
  constexpr size_t chunk = 4 * 1024 * 1024;
  size_t offset = 0;
  while (offset < expected.bytes) {
    const size_t count = std::min(chunk, size_t(expected.bytes - offset));
    require(bool(stream.read(reinterpret_cast<char*>(mapped + offset), count)),
            "short model BO read: " + path.string());
    sha.update(mapped + offset, count);
    offset += count;
  }
  const Digest digest = sha.finish();
  require(hex(digest.data(), digest.size()) == expected.sha256,
          "model BO SHA mismatch: " + path.string());
  bo.sync(XCL_BO_SYNC_BO_TO_DEVICE, expected.bytes, 0);
}

void write_result(const fs::path& path,
                  const std::array<uint8_t, laya::kResultBytes>& bytes) {
  std::ofstream output(path, std::ios::binary | std::ios::trunc);
  require(bool(output) && bool(output.write(
              reinterpret_cast<const char*>(bytes.data()), bytes.size())),
          "cannot write result frame");
}

int run_host(const Options& options) {
  require(sha256_file(options.xclbin) == options.xclbin_sha256,
          "xclbin full SHA-256 mismatch");
  const Manifest manifest = parse_manifest(options.package / "manifest.json");
  const auto request_frame = read_small(options.request, laya::kRequestLimit);
  laya::Identity expected;
  for (unsigned i = 0; i < 16; ++i) {
    expected.model[i] = laya::full::kFullModelTag[i];
    expected.numeric[i] = laya::full::kFullNumericTag[i];
    expected.layout[i] = laya::full::kFullLayoutTag[i];
    expected.build[i] = laya::full::kFullBuildTag[i];
  }
  laya::Request request;
  const laya::Check input_status =
      laya::parse_request(request_frame, request, &expected);
  require(bool(input_status), "pre-encoded request rejected: status=" +
          std::to_string(unsigned(input_status.code)) +
          " detail=" + std::to_string(input_status.detail));
  require(request_frame.size() == request.frame_bytes,
          "request file contains bytes beyond its ABI frame");

  xrt::device device(options.device);
  const auto uuid = device.load_xclbin(options.xclbin.string());
  xrt::kernel kernel(device, uuid, "laya_typed_q8_forward");
  constexpr size_t count = 13;
  const std::array<size_t, count> sizes = {
      laya::full::kFullModelBoSizes[0], 32768,
      laya::full::kFullModelBoSizes[1],
      laya::full::kFullModelBoSizes[2],
      laya::full::kFullModelBoSizes[3],
      laya::full::kFullModelBoSizes[4],
      32u * 1024u * 1024u, 32u * 1024u * 1024u,
      16u * 1024u * 1024u, 16u * 1024u * 1024u,
      48u * 1024u * 1024u, 24u * 1024u * 1024u,
      16u * 1024u * 1024u};
  std::vector<xrt::bo> ports;
  ports.reserve(count);
  for (unsigned i = 0; i < count; ++i)
    ports.emplace_back(device, sizes[i], kernel.group_id(i));

  constexpr unsigned model_ports[5] = {0, 2, 3, 4, 5};
  for (unsigned i = 0; i < 5; ++i) {
    const fs::path path = options.package / manifest.model[i].file;
    upload_model(ports[model_ports[i]], path, manifest.model[i]);
  }
  verify_aux_header(ports[5].map<uint8_t*>(), sizes[5]);

  constexpr unsigned workspace_ports[7] = {6, 7, 8, 9, 10, 11, 12};
  for (unsigned port : workspace_ports) {
    std::memset(ports[port].map<uint8_t*>(), 0, sizes[port]);
    ports[port].sync(XCL_BO_SYNC_BO_TO_DEVICE, sizes[port], 0);
  }
  auto* io = ports[1].map<uint8_t*>();
  std::memset(io, 0, sizes[1]);
  std::memcpy(io, request_frame.data(), request_frame.size());
  ports[1].sync(XCL_BO_SYNC_BO_TO_DEVICE, sizes[1], 0);

  auto run = kernel(ports[0], ports[1], ports[2], ports[3], ports[4],
                    ports[5], ports[6], ports[7], ports[8], ports[9],
                    ports[10], ports[11], ports[12]);
  const auto state = run.wait(std::chrono::milliseconds(options.timeout_ms));
  if (state == ERT_CMD_STATE_TIMEOUT) {
    // abort() is synchronous: its return value is the terminal command state.
    const auto retired = run.abort();
    require(retired == ERT_CMD_STATE_ABORT ||
            retired == ERT_CMD_STATE_COMPLETED,
            "HOST_DEVICE: abort returned state=" +
                std::to_string(unsigned(retired)));
    fail("HOST_TIMEOUT: kernel did not complete within timeout-ms");
  }
  require(state == ERT_CMD_STATE_COMPLETED,
          "HOST_DEVICE: kernel ended in state=" +
              std::to_string(unsigned(state)));

  ports[1].sync(XCL_BO_SYNC_BO_FROM_DEVICE, laya::kResultBytes,
                laya::kResultOffset);
  std::array<uint8_t, laya::kResultBytes> result_frame{};
  ports[1].read(result_frame.data(), result_frame.size(),
                laya::kResultOffset);
  write_result(options.result, result_frame);
  laya::Result result;
  const laya::Check decoded = laya::decode_result(
      {result_frame.begin(), result_frame.end()}, result, &expected);
  require(bool(decoded), "HOST_STALE_RESULT: invalid result ABI/tags");
  require(result.request_id == request.request_id &&
          result.generation == request.generation &&
          result.batch == request.batch && result.seq_len == request.seq_len,
          "HOST_STALE_RESULT: output request identity/shape mismatch");
  require(result.status == laya::Status::OK &&
          (result.flags & 3u) == 3u,
          "kernel returned error status=" +
              std::to_string(unsigned(result.status)) +
              " detail=" + std::to_string(result.error_detail));
  for (unsigned i = 0; i < 16u * result.batch; ++i)
    require((result.candidate_bits[i] & 0x7f800000u) != 0x7f800000u,
            "HOST_NUMERICAL: non-finite candidate output at index=" +
                std::to_string(i));
  for (unsigned i = 0; i < 2u * result.batch; ++i)
    require((result.act_bits[i] & 0x7f800000u) != 0x7f800000u,
            "HOST_NUMERICAL: non-finite act output at index=" +
                std::to_string(i));
  std::cout << "LAYA_HOST_PASS request_id=" << result.request_id
            << " generation=" << result.generation
            << " B=" << result.batch << " S=" << result.seq_len
            << " candidate_count=" << 16 * result.batch
            << " act_count=" << 2 * result.batch
            << " result=" << options.result << '\n';
  return 0;
}
}  // namespace

int main(int argc, char** argv) {
  try {
    return run_host(parse_options(argc, argv));
  } catch (const std::exception& error) {
    std::cerr << "LAYA_HOST_FAIL " << error.what() << '\n';
    return 1;
  }
}
