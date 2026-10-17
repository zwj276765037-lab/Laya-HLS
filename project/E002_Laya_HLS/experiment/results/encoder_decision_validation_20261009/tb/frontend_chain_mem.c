#define _POSIX_C_SOURCE 200809L
#include <fcntl.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

enum { EMBEDDING, IO, AUX, STATE0, STATE1, OBSERVED, PORTS };
enum { DATA_BYTES = 128 * 1024 * 4, OBS_WORDS = 400,
       OBS_BYTES = OBS_WORDS * 4 };
static const char *names[PORTS] = {
    "embedding", "io", "aux", "state0", "state1", "observed"};
static const size_t sizes[PORTS] = {
    54803648u, 32768u, 1671872u, 16920576u, 16919104u, OBS_BYTES};
static uint8_t *bo[PORTS], *gold_raw, *gold_norm;
static uint8_t *seen_raw, *seen_norm, *seen_obs;
static uint8_t *read_state0, *read_gamma;
static size_t seen_raw_count, seen_norm_count, seen_obs_count;
static size_t read_state0_count, read_gamma_count;
static size_t request_bytes;
static uint64_t reads[PORTS], writes[PORTS], read_after_raw;
static int errors;

static void problem(const char *reason, int port, uint64_t addr) {
    if (errors++ < 12)
        fprintf(stderr, "FRONTEND_AXI_ERROR %s port=%s address=%llu\n",
                reason, port >= 0 && port < PORTS ? names[port] : "?",
                (unsigned long long)addr);
}
static uint8_t *map_file(const char *path, size_t expected) {
    int fd = open(path, O_RDONLY);
    struct stat st;
    if (fd < 0 || fstat(fd, &st) || (size_t)st.st_size != expected) {
        fprintf(stderr, "FRONTEND_FILE_ERROR %s expected=%zu\n", path,
                expected);
        exit(2);
    }
    void *result = mmap(NULL, expected, PROT_READ, MAP_PRIVATE, fd, 0);
    close(fd);
    if (result == MAP_FAILED) { perror("mmap"); exit(2); }
    return result;
}
static uint8_t *new_sentinel(size_t bytes) {
    uint8_t *result = malloc(bytes);
    if (!result) { perror("malloc"); exit(2); }
    memset(result, 0xa5, bytes);
    return result;
}
static uint32_t le32(const uint8_t *p) {
    return (uint32_t)p[0] | (uint32_t)p[1] << 8 |
           (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24;
}
static uint32_t obs(unsigned word) { return le32(bo[OBSERVED] + 4u * word); }
static int equal(unsigned word, uint32_t wanted, const char *name) {
    uint32_t got = obs(word);
    if (got == wanted) return 1;
    fprintf(stderr, "FRONTEND_OBS_FAIL %s word=%u expected=%u actual=%u\n",
            name, word, wanted, got);
    return 0;
}

int thin_mem_init(void) {
    const char *package = getenv("LAYA_FRONT_PACKAGE");
    const char *request = getenv("LAYA_FRONT_REQUEST");
    const char *oracle = getenv("LAYA_FRONT_ORACLE");
    if (!package || !request || !oracle) {
        fputs("FRONTEND_FILE_ERROR missing environment\n", stderr); return 0;
    }
    char path[4096];
    for (int i = 0; i < PORTS; ++i) {
        if (i == EMBEDDING || i == AUX) {
            if (snprintf(path, sizeof path, "%s/%s.bin", package, names[i]) >=
                (int)sizeof path) return 0;
            bo[i] = map_file(path, sizes[i]);
        } else bo[i] = new_sentinel(sizes[i]);
    }
    int fd = open(request, O_RDONLY);
    struct stat st;
    if (fd < 0 || fstat(fd, &st) || st.st_size != 1152 ||
        read(fd, bo[IO], 1152) != 1152) {
        fputs("FRONTEND_FILE_ERROR B1 request\n", stderr); return 0;
    }
    close(fd);
    request_bytes = 1152;
    if (memcmp(bo[IO], "LYRQ", 4) || bo[IO][20] != 1 ||
        bo[IO][22] != 128 || bo[IO][24] != 3 || bo[IO][32] != 1) {
        fputs("FRONTEND_FILE_ERROR request shape/identity\n", stderr);
        return 0;
    }
    if (snprintf(path, sizeof path, "%s/embedding_raw.f32.bin", oracle) >=
        (int)sizeof path) return 0;
    gold_raw = map_file(path, DATA_BYTES);
    if (snprintf(path, sizeof path, "%s/embedding_norm.f32.bin", oracle) >=
        (int)sizeof path) return 0;
    gold_norm = map_file(path, DATA_BYTES);
    seen_raw = calloc(DATA_BYTES, 1);
    seen_norm = calloc(DATA_BYTES, 1);
    seen_obs = calloc(OBS_BYTES, 1);
    read_state0 = calloc(DATA_BYTES / 4, 1);
    read_gamma = calloc(1024, 1);
    if (!seen_raw || !seen_norm || !seen_obs ||
        !read_state0 || !read_gamma) return 0;
    puts("FRONTEND_MEM_READY B=1 S=128 six_ports=6 observed_words=400");
    fflush(stdout);
    return 1;
}
int thin_mem_read(int port, unsigned long long address) {
    if (port < 0 || port >= PORTS ||
        (address & ~3ull) + 4 > sizes[port] || port == OBSERVED) {
        problem("read range/direction", port, address); return 0;
    }
    uint32_t value = le32(bo[port] + (address & ~3ull));
    return (int)value;
}
void thin_mem_read_accept(int port, unsigned long long address) {
    if (port < 0 || port >= PORTS ||
        (address & ~3ull) + 4 > sizes[port] || port == OBSERVED) {
        problem("accepted read range/direction", port, address); return;
    }
    ++reads[port];
    if (port == STATE0) {
        const uint64_t aligned = address & ~3ull;
        if (aligned >= DATA_BYTES) {
            problem("LN read outside B1 raw region", port, address);
            return;
        }
        if (seen_raw_count != DATA_BYTES)
            problem("LN read before raw complete", port, address);
        else {
            ++read_after_raw;
            const size_t word = aligned / 4;
            if (!read_state0[word]) {
                read_state0[word] = 1;
                ++read_state0_count;
            }
        }
    }
    if (port == AUX) {
        const uint64_t aligned = address & ~3ull;
        if (aligned >= 128 && aligned < 128 + 4096) {
            const size_t word = (aligned - 128) / 4;
            if (!read_gamma[word]) {
                read_gamma[word] = 1;
                ++read_gamma_count;
            }
        }
    }
}
void thin_mem_write(int port, unsigned long long address, int word,
                    unsigned char strobe) {
    if (port < 0 || port >= PORTS ||
        (address & ~3ull) + 4 > sizes[port] ||
        port == EMBEDDING || port == AUX || port == IO) {
        problem("write range/direction", port, address); return;
    }
    const uint64_t aligned = address & ~3ull;
    uint8_t bytes[4];
    memcpy(bytes, &word, 4);
    uint8_t *seen = port == STATE0 ? seen_raw :
                    port == STATE1 ? seen_norm : seen_obs;
    size_t *count = port == STATE0 ? &seen_raw_count :
                    port == STATE1 ? &seen_norm_count : &seen_obs_count;
    const size_t active = port == OBSERVED ? OBS_BYTES : DATA_BYTES;
    for (unsigned lane = 0; lane < 4; ++lane) {
        if (!(strobe & (1u << lane))) continue;
        const uint64_t at = aligned + lane;
        if (at >= active) {
            problem("write outside active B1/observed span", port, at);
            return;
        }
        bo[port][at] = bytes[lane];
        if (!seen[at]) { seen[at] = 1; ++*count; }
    }
    ++writes[port];
}
int thin_mem_progress(void) {
    uint64_t value = 0;
    for (int i = 0; i < PORTS; ++i) value += reads[i] + writes[i];
    return value > INT32_MAX ? INT32_MAX : (int)value;
}
int thin_mem_raw_bytes(void) { return (int)seen_raw_count; }
int thin_mem_norm_bytes(void) { return (int)seen_norm_count; }
int thin_mem_obs_bytes(void) { return (int)seen_obs_count; }
int thin_mem_state0_read_words(void) { return (int)read_state0_count; }
int thin_mem_gamma_read_words(void) { return (int)read_gamma_count; }
int thin_mem_errors(void) { return errors; }
int thin_mem_check(void) {
    if (errors || seen_raw_count != DATA_BYTES ||
        seen_norm_count != DATA_BYTES || seen_obs_count != OBS_BYTES ||
        read_state0_count != DATA_BYTES / 4 ||
        read_gamma_count != 1024 || !read_after_raw) {
        fprintf(stderr, "FRONTEND_COVERAGE_FAIL errors=%d raw=%zu norm=%zu "
                "obs=%zu state0_read_words=%zu gamma_read_words=%zu "
                "state0_reads_after_raw=%llu\n", errors,
                seen_raw_count, seen_norm_count, seen_obs_count,
                read_state0_count, read_gamma_count,
                (unsigned long long)read_after_raw);
        return 0;
    }
    for (unsigned i = 0; i < DATA_BYTES; i += 4)
        if (le32(bo[STATE0] + i) != le32(gold_raw + i)) {
            fprintf(stderr, "FRONTEND_RAW_FAIL index=%u expected_bits=%08x "
                    "actual_bits=%08x\n", i / 4, le32(gold_raw + i),
                    le32(bo[STATE0] + i));
            return 0;
        }
    unsigned bit_equal = 0, first_diff = UINT32_MAX;
    float max_abs = 0, max_rel = 0;
    for (unsigned i = 0; i < DATA_BYTES; i += 4) {
        uint32_t actual_bits = le32(bo[STATE1] + i);
        uint32_t ref_bits = le32(gold_norm + i);
        float actual, ref;
        memcpy(&actual, &actual_bits, 4);
        memcpy(&ref, &ref_bits, 4);
        if (!isfinite(actual) || !isfinite(ref)) {
            fprintf(stderr, "FRONTEND_NORM_NONFINITE index=%u\n", i / 4);
            return 0;
        }
        if (actual_bits == ref_bits) ++bit_equal;
        else if (first_diff == UINT32_MAX) first_diff = i / 4;
        float abs_err = fabsf(actual - ref);
        float rel_err = abs_err / fmaxf(fabsf(ref), 1e-30f);
        if (abs_err > max_abs) max_abs = abs_err;
        if (rel_err > max_rel) max_rel = rel_err;
        if (abs_err > 1e-4f + 1e-4f * fabsf(ref)) {
            fprintf(stderr, "FRONTEND_NORM_FAIL index=%u ref=%g actual=%g "
                    "abs=%g rel=%g\n", i / 4, ref, actual,
                    abs_err, rel_err);
            return 0;
        }
    }
    for (int port = STATE0; port <= STATE1; ++port)
        for (size_t i = DATA_BYTES; i < sizes[port]; ++i)
            if (bo[port][i] != 0xa5) {
                fprintf(stderr, "FRONTEND_SENTINEL_FAIL port=%s byte=%zu\n",
                        names[port], i); return 0;
            }
    for (size_t i = request_bytes; i < sizes[IO]; ++i)
        if (bo[IO][i] != 0xa5) {
            fprintf(stderr, "FRONTEND_IO_FAIL byte=%zu\n", i); return 0;
        }
    int pass = 1;
    pass &= equal(0, 0x314f464c, "magic");
    pass &= equal(1, 1, "version");
    pass &= equal(2, OBS_WORDS, "words");
    pass &= equal(3, 0, "status");
    pass &= equal(4, 0, "detail");
    pass &= equal(5, UINT32_MAX, "bad element low");
    pass &= equal(6, UINT32_MAX, "bad element high");
    pass &= equal(7, 0, "execution status");
    pass &= equal(8, 0, "execution detail");
    pass &= equal(9, 0, "cleanup status");
    pass &= equal(10, 0, "cleanup detail");
    pass &= equal(11, 1, "request valid");
    pass &= equal(12, 1, "model header valid");
    pass &= equal(13, 1, "diagnostic identity valid");
    pass &= equal(14, 1, "diagnostic shape valid");
    pass &= equal(15, 3, "diagnostic request");
    pass &= equal(16, 0, "diagnostic request high");
    pass &= equal(17, 1, "diagnostic generation");
    pass &= equal(18, 0, "diagnostic generation high");
    pass &= equal(19, 1, "B");
    pass &= equal(20, 128, "S");
    pass &= equal(21, 3, "input request");
    pass &= equal(22, 0, "input request high");
    pass &= equal(23, 1, "input generation");
    pass &= equal(24, 0, "input generation high");
    pass &= equal(25, 1, "input B");
    pass &= equal(26, 128, "input S");
    pass &= equal(27, 1, "session generation");
    pass &= equal(28, 0, "session generation high");
    pass &= equal(29, 3, "accepted request");
    pass &= equal(30, 0, "accepted request high");
    pass &= equal(31, 17, "tasks retired");
    pass &= equal(32, 17, "last task");
    pass &= equal(33, 3, "claims");
    pass &= equal(34, 0, "exclusive leases");
    pass &= equal(35, 8, "embedding calls");
    pass &= equal(36, 1, "gamma calls");
    pass &= equal(37, 8, "norm calls");
    pass &= equal(38, 0, "encoder layers");
    pass &= equal(39, 0, "decision layers");
    pass &= equal(40, 1, "output id");
    pass &= equal(41, 1, "output bank");
    pass &= equal(42, 1, "output epoch");
    pass &= equal(43, 0, "output region");
    pass &= equal(44, 1, "output stage");
    pass &= equal(45, 255, "output layer");
    pass &= equal(46, 255, "output batch");
    pass &= equal(47, 0, "output row space");
    pass &= equal(48, 0, "output row0");
    pass &= equal(49, 128, "output rows");
    pass &= equal(50, 1024, "output width");
    pass &= equal(51, 1, "output content");
    pass &= equal(52, 0, "live readers");
    pass &= equal(53, 0, "incomplete owners");
    for (unsigned owner = 0; owner < 3; ++owner) {
        unsigned base = 64 + 112 * owner;
        pass &= equal(base, 1, "owner found");
        pass &= equal(base + 1, owner, "owner slot");
        pass &= equal(base + 2, owner == 1 ? 0x2a : 1, "owner id");
        pass &= equal(base + 3, owner == 2 ? 1 : 0, "owner bank");
        pass &= equal(base + 4, 1, "owner epoch");
        pass &= equal(base + 5, 1, "owner max claimed epoch");
        pass &= equal(base + 6, 0, "owner region");
        pass &= equal(base + 7, 1, "owner stage");
        pass &= equal(base + 8, 255, "owner layer");
        pass &= equal(base + 9, owner == 1 ? 0 : 255, "owner batch");
        pass &= equal(base + 10, owner == 1 ? 2 : 0, "owner row space");
        pass &= equal(base + 11, 0, "owner row0");
        pass &= equal(base + 12, owner == 1 ? 1 : 128, "owner rows");
        pass &= equal(base + 13, 1024, "owner width");
        pass &= equal(base + 14, 1, "owner content");
        pass &= equal(base + 15, owner == 0 ? 0 : 2, "owner state");
        pass &= equal(base + 16, 0, "owner readers");
        pass &= equal(base + 17, owner != 0, "owner valid");
        pass &= equal(base + 18, 1, "owner B");
        pass &= equal(base + 19, 128, "owner S");
        pass &= equal(base + 20, 3, "owner request");
        pass &= equal(base + 21, 0, "owner request high");
        pass &= equal(base + 22, 1, "owner generation");
        pass &= equal(base + 23, 0, "owner generation high");
        for (unsigned word = 0; word < 4; ++word) {
            pass &= equal(base + 24 + word, le32(bo[IO] + 40 + 4 * word),
                          "owner model tag");
            pass &= equal(base + 28 + word, le32(bo[IO] + 56 + 4 * word),
                          "owner numeric tag");
            pass &= equal(base + 32 + word, le32(bo[IO] + 72 + 4 * word),
                          "owner layout tag");
            pass &= equal(base + 36 + word, le32(bo[IO] + 88 + 4 * word),
                          "owner build tag");
        }
        for (unsigned word = 0; word < 64; ++word)
            pass &= equal(base + 48 + word,
                          owner == 2 && word < 4 ? UINT32_MAX :
                          owner == 1 && word == 0 ? 1 : 0,
                          "owner coverage");
    }
    if (!pass) return 0;
    printf("FRONTEND_CHAIN_RTL_COMPARE_PASS raw_f32=131072 "
           "norm_f32=131072 bit_equal=%u first_diff=%u max_abs=%g "
           "max_rel=%g observed_words=400 state0_read_words=%zu "
           "gamma_read_words=%zu state0_reads_after_raw=%llu\n",
           bit_equal, first_diff, max_abs, max_rel,
           read_state0_count, read_gamma_count,
           (unsigned long long)read_after_raw);
    fflush(stdout);
    return 1;
}
