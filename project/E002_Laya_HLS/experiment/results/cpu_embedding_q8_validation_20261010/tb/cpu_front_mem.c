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

enum { IO, AUX, STATE0, STATE1, OBSERVED, PORTS };
enum { DATA_BYTES = 128 * 1024 * 4, OBS_WORDS = 432,
       OBS_BYTES = OBS_WORDS * 4 };
static const char *names[PORTS] = {
    "io", "aux", "state0", "state1", "observed"};
static const size_t sizes[PORTS] = {
    32768u, 1671872u, 16920576u, 16919104u, OBS_BYTES};
static uint8_t *bo[PORTS], *gold_raw, *gold_norm;
static uint8_t *seen_norm, *seen_obs;
static uint8_t *read_import, *read_ln, *read_gamma;
static size_t seen_norm_count, seen_obs_count;
static size_t read_import_count, read_ln_count, read_gamma_count;
static uint64_t reads[PORTS], writes[PORTS];
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
    const char *io_image = getenv("LAYA_FRONT_IO");
    const char *state0_image = getenv("LAYA_FRONT_STATE0");
    const char *oracle = getenv("LAYA_FRONT_ORACLE");
    if (!package || !io_image || !state0_image || !oracle) {
        fputs("FRONTEND_FILE_ERROR missing environment\n", stderr); return 0;
    }
    char path[4096];
    for (int i = 0; i < PORTS; ++i) {
        if (i == AUX) {
            if (snprintf(path, sizeof path, "%s/%s.bin", package, names[i]) >=
                (int)sizeof path) return 0;
            bo[i] = map_file(path, sizes[i]);
        } else if (i == IO) {
            bo[i] = map_file(io_image, sizes[i]);
        } else if (i == STATE0) {
            bo[i] = map_file(state0_image, sizes[i]);
        } else bo[i] = new_sentinel(sizes[i] + (i == OBSERVED ? 4 : 0));
    }
    if (memcmp(bo[IO], "LYRQ", 4) || bo[IO][20] != 1 ||
        bo[IO][22] != 128 || bo[IO][24] != 3 || bo[IO][32] != 1 ||
        memcmp(bo[IO] + 20480, "LYER", 4)) {
        fputs("FRONTEND_FILE_ERROR request shape/identity\n", stderr);
        return 0;
    }
    if (snprintf(path, sizeof path, "%s/embedding_raw.f32.bin", oracle) >=
        (int)sizeof path) return 0;
    gold_raw = map_file(path, DATA_BYTES);
    if (snprintf(path, sizeof path, "%s/embedding_norm.f32.bin", oracle) >=
        (int)sizeof path) return 0;
    gold_norm = map_file(path, DATA_BYTES);
    seen_norm = calloc(DATA_BYTES, 1);
    seen_obs = calloc(OBS_BYTES, 1);
    read_import = calloc(DATA_BYTES / 4, 1);
    read_ln = calloc(DATA_BYTES / 4, 1);
    read_gamma = calloc(1024, 1);
    if (!seen_norm || !seen_obs || !read_import || !read_ln ||
        !read_gamma) return 0;
    for (unsigned i = 0; i < DATA_BYTES; i += 4)
        if (le32(bo[STATE0] + i) != le32(gold_raw + i)) {
            fprintf(stderr, "FRONTEND_RAW_INPUT_FAIL word=%u\n", i / 4);
            return 0;
        }
    for (size_t i = DATA_BYTES; i < sizes[STATE0]; ++i)
        if (bo[STATE0][i] != 0xa5) {
            fprintf(stderr, "FRONTEND_STATE0_SENTINEL_FAIL byte=%zu\n", i);
            return 0;
        }
    puts("FRONTEND_MEM_READY B=1 S=128 five_ports=5 observed_words=432");
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
            problem("raw read outside B1 region", port, address);
            return;
        }
        const size_t word = aligned / 4;
        if (read_gamma_count == 1024) {
            if (read_import_count != DATA_BYTES / 4)
                problem("LN read before import coverage", port, address);
            if (!read_ln[word]) { read_ln[word] = 1; ++read_ln_count; }
        } else {
            if (!read_import[word]) {
                read_import[word] = 1;
                ++read_import_count;
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
        port == STATE0 || port == AUX || port == IO) {
        problem("write range/direction", port, address); return;
    }
    const uint64_t aligned = address & ~3ull;
    uint8_t bytes[4];
    memcpy(bytes, &word, 4);
    uint8_t *seen = port == STATE1 ? seen_norm : seen_obs;
    size_t *count = port == STATE1 ? &seen_norm_count : &seen_obs_count;
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
int thin_mem_raw_bytes(void) { return (int)(read_import_count * 4); }
int thin_mem_norm_bytes(void) { return (int)seen_norm_count; }
int thin_mem_obs_bytes(void) { return (int)seen_obs_count; }
int thin_mem_state0_import_words(void) { return (int)read_import_count; }
int thin_mem_state0_ln_read_words(void) { return (int)read_ln_count; }
int thin_mem_gamma_read_words(void) { return (int)read_gamma_count; }
int thin_mem_errors(void) { return errors; }
static int write_capture(const char *name, const uint8_t *data, size_t bytes) {
    FILE *stream = fopen(name, "wb");
    if (!stream) {
        perror(name);
        return 0;
    }
    int ok = fwrite(data, 1, bytes, stream) == bytes;
    if (fclose(stream)) ok = 0;
    if (!ok) fprintf(stderr, "FRONTEND_CAPTURE_FAIL %s\n", name);
    return ok;
}
int thin_mem_capture_first_done(void) {
    /* Preserve the actual bytes before any first-done protocol assertion.
       The bitmap distinguishes unwritten bytes from a genuine 0xa5 result. */
    int ok = 1;
    ok &= write_capture("actual_norm.f32.bin", bo[STATE1], DATA_BYTES);
    ok &= write_capture("actual_norm_seen.bin", seen_norm, DATA_BYTES);
    ok &= write_capture("actual_observed.bin", bo[OBSERVED], OBS_BYTES);
    printf("FRONTEND_FIRST_DONE_CAPTURE ok=%d norm_bytes=%zu "
           "observed_bytes=%zu\n", ok, seen_norm_count, seen_obs_count);
    fflush(stdout);
    return ok;
}
int thin_mem_check(void) {
    if (errors || seen_norm_count != DATA_BYTES ||
        seen_obs_count != OBS_BYTES ||
        read_import_count != DATA_BYTES / 4 ||
        read_ln_count != DATA_BYTES / 4 || read_gamma_count != 1024) {
        fprintf(stderr, "FRONTEND_COVERAGE_FAIL errors=%d norm=%zu "
                "obs=%zu import_words=%zu ln_words=%zu gamma_words=%zu\n",
                errors, seen_norm_count, seen_obs_count,
                read_import_count, read_ln_count, read_gamma_count);
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
    for (size_t i = DATA_BYTES; i < sizes[STATE1]; ++i)
        if (bo[STATE1][i] != 0xa5) {
            fprintf(stderr, "FRONTEND_SENTINEL_FAIL port=state1 byte=%zu\n", i);
            return 0;
        }
    if (le32(bo[OBSERVED] + OBS_BYTES) != 0xa5a5a5a5u) {
        fputs("FRONTEND_OBS_GUARD_FAIL\n", stderr);
        return 0;
    }
    int pass = 1;
    pass &= equal(0, 0x314f4643, "magic");
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
    pass &= equal(31, 9, "tasks retired");
    pass &= equal(32, 9, "last task");
    pass &= equal(33, 3, "claims");
    pass &= equal(34, 0, "exclusive leases");
    pass &= equal(35, 0, "embedding calls");
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
    for (unsigned word = 54; word < 64; ++word)
        pass &= equal(word, 0, "global reserved");
    for (unsigned owner = 0; owner < 3; ++owner) {
        unsigned base = 64 + 112 * owner;
        pass &= equal(base, 1, "owner found");
        if (obs(base + 1) >= 32) {
            fprintf(stderr, "FRONTEND_OWNER_SLOT_FAIL ordinal=%u slot=%u\n",
                    owner, obs(base + 1));
            pass = 0;
        }
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
        for (unsigned word = 40; word < 48; ++word)
            pass &= equal(base + word, 0, "owner reserved");
        for (unsigned word = 0; word < 64; ++word)
            pass &= equal(base + 48 + word,
                          owner == 2 && word < 4 ? UINT32_MAX :
                          owner == 1 && word == 0 ? 1 : 0,
                          "owner coverage");
    }
    if (obs(65) == obs(177) || obs(65) == obs(289) ||
        obs(177) == obs(289)) {
        fputs("FRONTEND_OWNER_SLOT_FAIL duplicate slots\n", stderr);
        pass = 0;
    }
    const uint8_t *descriptor = bo[IO] + 20480;
    const uint32_t extra[32] = {
        1, 1, 1, 1, 1, 1,
        le32(descriptor + 152), le32(descriptor + 152),
        DATA_BYTES, 0, DATA_BYTES / 4, 0, 128, UINT32_MAX,
        UINT32_MAX, UINT32_MAX, 8, 0, 0, 0, 0, 0,
        1, 1, 1,
        le32(descriptor + 148), le32(descriptor + 148),
        le32(descriptor + 156), le32(descriptor + 156), 0, 0, 0
    };
    for (unsigned word = 0; word < 32; ++word)
        pass &= equal(400 + word, extra[word], "CFO1 import field");
    if (!pass) return 0;
    printf("FRONTEND_CHAIN_RTL_COMPARE_PASS raw_f32=131072 "
           "norm_f32=131072 bit_equal=%u first_diff=%u max_abs=%g "
           "max_rel=%g observed_words=432 import_words=%zu "
           "ln_read_words=%zu gamma_read_words=%zu\n",
           bit_equal, first_diff, max_abs, max_rel,
           read_import_count, read_ln_count, read_gamma_count);
    fflush(stdout);
    return 1;
}

// A descriptor CRC rejection exercises the same observed AXI completion path
// without the long LayerNorm run.  This is a scoped adapter-monitor check;
// the accepted B1/S128 numerical case remains a separate RTL requirement.
int thin_mem_check_reject(void) {
    if (errors || seen_norm_count != 0 || seen_obs_count != OBS_BYTES ||
        read_import_count != 0 || read_ln_count != 0 ||
        read_gamma_count != 0) {
        fprintf(stderr, "FRONTEND_REJECT_COVERAGE_FAIL errors=%d norm=%zu "
                "obs=%zu import_words=%zu ln_words=%zu gamma_words=%zu\n",
                errors, seen_norm_count, seen_obs_count,
                read_import_count, read_ln_count, read_gamma_count);
        return 0;
    }
    for (size_t i = 0; i < sizes[STATE1]; ++i)
        if (bo[STATE1][i] != 0xa5) {
            fprintf(stderr, "FRONTEND_REJECT_STATE1_WRITE byte=%zu\n", i);
            return 0;
        }
    if (le32(bo[OBSERVED] + OBS_BYTES) != 0xa5a5a5a5u) {
        fputs("FRONTEND_REJECT_OBS_GUARD_FAIL\n", stderr);
        return 0;
    }
    int pass = 1;
    pass &= equal(0, 0x314f4643u, "reject magic");
    pass &= equal(1, 1, "reject version");
    pass &= equal(2, OBS_WORDS, "reject words");
    pass &= equal(3, 1, "reject E_ABI");
    pass &= equal(4, 0x0a010005u, "reject descriptor CRC detail");
    pass &= equal(31, 0, "reject tasks retired");
    pass &= equal(33, 0, "reject owner claims");
    pass &= equal(401, 0, "reject descriptor valid");
    pass &= equal(402, 0, "reject admitted");
    pass &= equal(403, 0, "reject imports started");
    pass &= equal(413, 156, "reject descriptor offset");
    if (!pass) return 0;
    puts("FRONTEND_REJECT_RTL_COMPARE_PASS observed_words=432 norm_bytes=0 "
         "import_words=0 reason=descriptor_crc");
    fflush(stdout);
    return 1;
}
