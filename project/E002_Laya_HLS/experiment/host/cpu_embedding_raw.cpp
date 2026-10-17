// Host-side token embedding producer for the CPU_EMBED_RAW_V1 input profile.
// Reads the Q8_0 table directly from the supplied GGUF; it never reads an
// oracle, a model BO, or a DUT tensor to produce the raw values.
#include <array>
#include <cerrno>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <fcntl.h>
#include <limits>
#include <stdexcept>
#include <string>
#include <sys/stat.h>
#include <unistd.h>
#include <vector>

namespace {
constexpr uint32_t kHidden = 1024;
constexpr uint32_t kVocab = 50368;
constexpr uint32_t kQ8RowBytes = 1088;
constexpr uint32_t kRowBytes = kHidden * 4;
constexpr uint32_t kBatchStride = kHidden * kRowBytes;
constexpr uint32_t kState0Bytes = 16920576;

uint16_t le16(const uint8_t* p) {
  return uint16_t(p[0]) | uint16_t(uint16_t(p[1]) << 8);
}
uint32_t le32(const uint8_t* p) {
  return uint32_t(p[0]) | uint32_t(p[1]) << 8 |
         uint32_t(p[2]) << 16 | uint32_t(p[3]) << 24;
}
uint64_t le64(const uint8_t* p) {
  uint64_t v = 0;
  for (unsigned i = 0; i < 8; ++i) v |= uint64_t(p[i]) << (8 * i);
  return v;
}
void put32(uint8_t* p, uint32_t value) {
  for (unsigned i = 0; i < 4; ++i) p[i] = uint8_t(value >> (8 * i));
}
void put16(uint8_t* p, uint16_t value) {
  p[0] = uint8_t(value); p[1] = uint8_t(value >> 8);
}
void put64(uint8_t* p, uint64_t value) {
  for (unsigned i = 0; i < 8; ++i) p[i] = uint8_t(value >> (8 * i));
}
uint32_t crc32c(const uint8_t* p, size_t length, size_t zero = SIZE_MAX) {
  uint32_t crc = 0xffffffffu;
  for (size_t i = 0; i < length; ++i) {
    crc ^= i >= zero && i < zero + 4 ? 0 : p[i];
    for (unsigned bit = 0; bit < 8; ++bit)
      crc = (crc >> 1) ^ (crc & 1 ? 0x82f63b78u : 0u);
  }
  return crc ^ 0xffffffffu;
}
uint32_t bits(float value) {
  uint32_t result;
  std::memcpy(&result, &value, sizeof(result));
  return result;
}
float from_bits(uint32_t value) {
  float result;
  std::memcpy(&result, &value, sizeof(result));
  return result;
}
float half_to_f32(uint16_t h) {
  const uint32_t sign = uint32_t(h & 0x8000u) << 16;
  uint32_t exponent = (h >> 10) & 31u;
  uint32_t fraction = h & 1023u;
  if (exponent == 0) {
    if (fraction == 0) return from_bits(sign);
    int e = -14;
    while ((fraction & 1024u) == 0) { fraction <<= 1; --e; }
    return from_bits(sign | (uint32_t(e + 127) << 23) |
                     ((fraction & 1023u) << 13));
  }
  if (exponent == 31) return from_bits(sign | 0x7f800000u | (fraction << 13));
  return from_bits(sign | ((exponent + 112u) << 23) | (fraction << 13));
}
void must(bool condition, const char* message) {
  if (!condition) throw std::runtime_error(message);
}
void read_at(int fd, uint64_t offset, void* dst, size_t count) {
  uint8_t* out = static_cast<uint8_t*>(dst);
  while (count) {
    const ssize_t got = pread(fd, out, count, off_t(offset));
    if (got <= 0) throw std::runtime_error("short GGUF/request read");
    offset += size_t(got);
    out += got;
    count -= size_t(got);
  }
}
uint64_t file_size(int fd) {
  struct stat st {};
  must(fstat(fd, &st) == 0 && st.st_size >= 0, "cannot stat input");
  return uint64_t(st.st_size);
}
class Reader {
 public:
  Reader(int fd, uint64_t size) : fd_(fd), size_(size) {}
  uint64_t position() const { return position_; }
  uint8_t u8() { uint8_t v; take(&v, 1); return v; }
  uint16_t u16() { uint8_t b[2]; take(b, 2); return le16(b); }
  uint32_t u32() { uint8_t b[4]; take(b, 4); return le32(b); }
  uint64_t u64() { uint8_t b[8]; take(b, 8); return le64(b); }
  std::string string() {
    const uint64_t n = u64();
    must(n <= 4096, "GGUF metadata key/tensor name too long");
    std::string s(size_t(n), '\0');
    if (n) take(s.data(), size_t(n));
    return s;
  }
  void skip(uint64_t n) {
    must(n <= size_ - position_, "GGUF metadata outside file");
    position_ += n;
  }
  void skip_value(uint32_t kind, unsigned depth = 0) {
    must(depth < 4, "nested GGUF metadata too deep");
    switch (kind) {
      case 0: case 1: case 7: skip(1); return;
      case 2: case 3: skip(2); return;
      case 4: case 5: case 6: skip(4); return;
      case 10: case 11: case 12: skip(8); return;
      case 8: { const uint64_t n = u64(); skip(n); return; }
      case 9: {
        const uint32_t element = u32();
        const uint64_t count = u64();
        must(count <= 100000000, "GGUF metadata array too large");
        for (uint64_t i = 0; i < count; ++i) skip_value(element, depth + 1);
        return;
      }
      default: throw std::runtime_error("unknown GGUF metadata type");
    }
  }
 private:
  void take(void* dst, size_t n) {
    must(n <= size_ - position_, "GGUF metadata outside file");
    read_at(fd_, position_, dst, n);
    position_ += n;
  }
  int fd_;
  uint64_t size_;
  uint64_t position_ = 0;
};
struct Table { uint64_t offset; uint32_t rows; };
Table find_token_table(int fd, uint64_t size) {
  Reader reader(fd, size);
  std::array<uint8_t, 4> magic {};
  for (auto& c : magic) c = reader.u8();
  must(magic == std::array<uint8_t, 4>{'G','G','U','F'}, "not a GGUF");
  must(reader.u32() == 3, "unexpected GGUF version");
  const uint64_t tensors = reader.u64();
  const uint64_t metadata = reader.u64();
  must(tensors == 153 && metadata <= 10000, "unexpected GGUF inventory");
  uint64_t alignment = 32;
  for (uint64_t i = 0; i < metadata; ++i) {
    const std::string key = reader.string();
    const uint32_t kind = reader.u32();
    if (key == "general.alignment") {
      must(kind == 4 || kind == 10, "invalid GGUF alignment type");
      alignment = kind == 4 ? reader.u32() : reader.u64();
    } else reader.skip_value(kind);
  }
  must(alignment && alignment <= 4096 && (alignment & (alignment - 1)) == 0,
       "invalid GGUF alignment");
  bool found = false;
  uint64_t relative = 0;
  for (uint64_t i = 0; i < tensors; ++i) {
    const std::string name = reader.string();
    const uint32_t rank = reader.u32();
    must(rank >= 1 && rank <= 4, "invalid GGUF tensor rank");
    uint64_t ne[4] = {1,1,1,1};
    for (unsigned j = 0; j < rank; ++j) ne[j] = reader.u64();
    const uint32_t type = reader.u32();
    const uint64_t offset = reader.u64();
    if (name == "tok_emb.weight") {
      must(!found && type == 8 && ne[0] == kHidden && ne[1] == kVocab &&
               ne[2] == 1 && ne[3] == 1, "invalid token embedding tensor");
      found = true;
      relative = offset;
    }
  }
  must(found, "missing tok_emb.weight");
  const uint64_t base = (reader.position() + alignment - 1) & ~(alignment - 1);
  must(base <= size && relative <= size - base &&
       uint64_t(kVocab) * kQ8RowBytes <= size - base - relative,
       "token embedding tensor outside GGUF");
  return {base + relative, kVocab};
}
std::vector<uint8_t> read_file(const char* path) {
  int fd = open(path, O_RDONLY);
  must(fd >= 0, "cannot open request");
  const uint64_t size = file_size(fd);
  must(size >= 320 && size <= 16384, "invalid request file size");
  std::vector<uint8_t> data(size_t(size), 0);
  read_at(fd, 0, data.data(), data.size());
  close(fd);
  return data;
}
void write_file(const char* path, const std::vector<uint8_t>& data) {
  std::string temporary = std::string(path) + ".tmp." + std::to_string(getpid());
  int fd = open(temporary.c_str(), O_WRONLY | O_CREAT | O_EXCL, 0644);
  must(fd >= 0, "cannot create output file");
  size_t done = 0;
  while (done < data.size()) {
    const ssize_t n = write(fd, data.data() + done, data.size() - done);
    must(n > 0, "short output write");
    done += size_t(n);
  }
  must(fsync(fd) == 0 && close(fd) == 0, "cannot flush output file");
  must(rename(temporary.c_str(), path) == 0, "cannot publish output file");
}
} // namespace

int main(int argc, char** argv) {
  try {
    must(argc == 5 || argc == 6,
         "usage: cpu_embedding_raw GGUF REQUEST RAW_OUT STATE0_OUT [IO_OUT]");
    int gguf = open(argv[1], O_RDONLY);
    must(gguf >= 0, "cannot open GGUF");
    const uint64_t gguf_bytes = file_size(gguf);
    must(gguf_bytes == 455179648ull, "unexpected GGUF byte size");
    const Table table = find_token_table(gguf, gguf_bytes);
    const std::vector<uint8_t> request = read_file(argv[2]);
    const uint8_t* p = request.data();
    must(std::memcmp(p, "LYRQ", 4) == 0 && le16(p + 4) == 1 &&
             le16(p + 8) == 128 && le16(p + 10) == 32 && le16(p + 12) == 5,
         "invalid request header");
    const uint32_t frame_bytes = le32(p + 16);
    const uint16_t B = le16(p + 20), S = le16(p + 22);
    const uint64_t request_id = le64(p + 24), generation = le64(p + 32);
    must((B == 1 || B == 2) && S == 128 && request_id && generation &&
             frame_bytes == request.size(), "invalid request shape/identity");
    must(le16(p + 128) == 1 && le32(p + 132) == 320 &&
             le32(p + 136) == 4u * B * S &&
             le16(p + 140) == B && le16(p + 142) == S &&
             le32(p + 144) == 4u * S && le32(p + 148) == 4 &&
             le32(p + 152) == B * S &&
             le16(p + 160) == 2, "invalid token/mask descriptors");
    const uint32_t mask_offset = le32(p + 164);
    must(320u + 4u * B * S <= request.size() &&
             mask_offset <= request.size() &&
             B * S <= request.size() - mask_offset,
         "mask outside request");
    const uint64_t raw_bytes = uint64_t(B) * S * kRowBytes;
    std::vector<uint8_t> raw(size_t(raw_bytes), 0);
    std::vector<uint8_t> state0(kState0Bytes, 0xa5);
    unsigned padding_rows = 0;
    std::array<uint8_t, kQ8RowBytes> row {};
    for (unsigned b = 0; b < B; ++b) {
      for (unsigned s = 0; s < S; ++s) {
        const unsigned index = b * S + s;
        const uint32_t token = le32(p + 320 + 4 * index);
        must(token < table.rows, "token outside embedding vocabulary");
        must(p[mask_offset + index] <= 1, "invalid attention mask");
        padding_rows += p[mask_offset + index] == 0;
        read_at(gguf, table.offset + uint64_t(token) * kQ8RowBytes,
                row.data(), row.size());
        for (unsigned group = 0; group < 32; ++group) {
          const unsigned qoff = group * 34;
          const float scale = half_to_f32(le16(row.data() + qoff));
          must(std::isfinite(scale) && !(scale < 0.0f),
               "invalid Q8 embedding scale");
          for (unsigned lane = 0; lane < 32; ++lane) {
            const unsigned element = group * 32 + lane;
            const unsigned byte = row[qoff + 2 + lane];
            const int q = byte < 128 ? int(byte) : int(byte) - 256;
            must(q >= -127 && q <= 127, "invalid Q8 embedding element");
            const float value = float(q) * scale;
            must(std::isfinite(value), "nonfinite CPU embedding result");
            uint8_t word[4];
            put32(word, bits(value));
            std::memcpy(raw.data() + size_t(index) * kRowBytes + element * 4,
                        word, 4);
            std::memcpy(state0.data() + size_t(b) * kBatchStride +
                        size_t(s) * kRowBytes + element * 4, word, 4);
          }
        }
      }
    }
    close(gguf);
    write_file(argv[3], raw);
    write_file(argv[4], state0);
    if (argc == 6) {
      std::vector<uint8_t> io(32768, 0xa5);
      std::memcpy(io.data(), request.data(), request.size());
      uint8_t* descriptor = io.data() + 20480;
      std::memset(descriptor, 0, 256);
      std::memcpy(descriptor, "LYER", 4);
      put16(descriptor + 4, 1);
      put16(descriptor + 6, 256);
      put32(descriptor + 8, 1);
      put64(descriptor + 16, request_id);
      put64(descriptor + 24, generation);
      std::memcpy(descriptor + 32, p + 40, 64);
      put16(descriptor + 96, B);
      put16(descriptor + 98, S);
      put16(descriptor + 100, kHidden);
      put16(descriptor + 102, 1);
      put32(descriptor + 120, kRowBytes);
      put32(descriptor + 124, kBatchStride);
      put64(descriptor + 128, raw_bytes);
      put64(descriptor + 136, uint64_t(B - 1) * kBatchStride +
                                  uint64_t(S) * kRowBytes);
      put32(descriptor + 144, frame_bytes);
      put32(descriptor + 148, crc32c(request.data(), request.size()));
      put32(descriptor + 152, crc32c(raw.data(), raw.size()));
      put32(descriptor + 156, crc32c(descriptor, 256, 156));
      write_file(argv[5], io);
    }
    std::printf("CPU_EMBED_RAW_PASS B=%u S=%u request=%llu generation=%llu "
                "rows=%u padding_rows=%u raw_bytes=%zu state0_bytes=%zu "
                "table_offset=%llu\n", B, S,
                static_cast<unsigned long long>(request_id),
                static_cast<unsigned long long>(generation), B * S,
                padding_rows, raw.size(), state0.size(),
                static_cast<unsigned long long>(table.offset));
    return 0;
  } catch (const std::exception& e) {
    std::fprintf(stderr, "CPU_EMBED_RAW_FAIL %s\n", e.what());
    return 1;
  }
}
