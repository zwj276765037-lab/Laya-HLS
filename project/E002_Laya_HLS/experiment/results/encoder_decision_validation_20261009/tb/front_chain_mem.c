#define _POSIX_C_SOURCE 200809L
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

/* 13 physical BOs in the production top's exact port order. */
static const char *names[13] = {"embedding", "io", "w_q0", "w_q1",
    "w_scale", "aux", "state0", "state1", "qkv0", "qkv1",
    "ff0", "ff1", "att_out"};
static const size_t sizes[13] = {54803648u, 20480u, 184682496u,
    184680448u, 23085184u, 1671872u, 16920576u, 16919104u,
    12u << 20, 12u << 20, 41u << 20, (21u << 20) - (512u << 10),
    8u << 20};
static uint8_t *bo[13];
static uint8_t *oracle;
static uint8_t *front_seen;
static size_t front_seen_count;
static uint64_t reads[13], writes[13], state1_reads_after_complete;
static int errors;

static void problem(const char *reason, int port, uint64_t address) {
    if (errors++ < 8)
        fprintf(stderr, "FRONT_AXI_ERROR %s port=%s address=%llu\n", reason,
                port >= 0 && port < 13 ? names[port] : "?",
                (unsigned long long)address);
}

static uint8_t *file_image(const char *path, size_t expected) {
    int fd = open(path, O_RDONLY);
    struct stat st;
    if (fd < 0 || fstat(fd, &st) || (size_t)st.st_size != expected) {
        fprintf(stderr, "FRONT_FILE_ERROR %s expected=%zu\n", path, expected);
        exit(2);
    }
    void *value = mmap(NULL, expected, PROT_READ, MAP_PRIVATE, fd, 0);
    close(fd);
    if (value == MAP_FAILED) { perror("mmap"); exit(2); }
    return value;
}

int front_mem_init(void) {
    const char *package = getenv("LAYA_FRONT_PACKAGE");
    const char *request = getenv("LAYA_FRONT_REQUEST");
    const char *gold = getenv("LAYA_FRONT_ORACLE");
    if (!package || !request || !gold) {
        fputs("FRONT_FILE_ERROR missing environment\n", stderr); return 0;
    }
    const int model_ports[5] = {0, 2, 3, 4, 5};
    for (unsigned i = 0; i < 5; ++i) {
        int port = model_ports[i];
        char path[4096];
        if (snprintf(path, sizeof path, "%s/%s.bin", package, names[port]) >=
            (int)sizeof path) return 0;
        bo[port] = file_image(path, sizes[port]);
    }
    for (int port = 1; port < 13; ++port) {
        if (bo[port]) continue;
        bo[port] = malloc(sizes[port]);
        if (!bo[port]) { perror("malloc"); return 0; }
        memset(bo[port], port == 1 ? 0 : 0xa5, sizes[port]);
    }
    int fd = open(request, O_RDONLY);
    struct stat st;
    if (fd < 0 || fstat(fd, &st) || st.st_size != 1856 ||
        read(fd, bo[1], 1856) != 1856) {
        fputs("FRONT_FILE_ERROR B2 request\n", stderr); return 0;
    }
    close(fd);
    if (memcmp(bo[1], "LYRQ", 4) || bo[1][20] != 2 || bo[1][22] != 128 ||
        bo[1][24] != 1) {
        fputs("FRONT_FILE_ERROR request identity\n", stderr); return 0;
    }
    oracle = file_image(gold, 2u * 128u * 1024u * 4u);
    front_seen = calloc(2u * 128u * 1024u * 4u, 1);
    if (!front_seen) return 0;
    printf("FRONT_MEM_READY request=B2_S128 model_ports=5 oracle_bytes=1048576\n");
    fflush(stdout);
    return 1;
}

int front_mem_read(int port, unsigned long long address) {
    if (port < 0 || port >= 13 || (address & ~3ull) + 4 > sizes[port]) {
        problem("read range", port, address); return 0;
    }
    const uint64_t aligned = address & ~3ull;
    uint32_t value = 0;
    memcpy(&value, bo[port] + aligned, 4);
    return (int)value;
}

/* Called only for an accepted AXI R beat; RDATA's combinational DPI lookup
   may be evaluated repeatedly while the receiver holds RREADY low. */
void front_mem_read_accept(int port, unsigned long long address) {
    if (port < 0 || port >= 13 || (address & ~3ull) + 4 > sizes[port]) {
        problem("accepted read range", port, address); return;
    }
    ++reads[port];
    if (port == 7 && front_seen_count == 1048576u &&
        ((address < 128u * 1024u * 4u) ||
         (address >= 1024u * 1024u * 4u &&
          address < (1024u + 128u) * 1024u * 4u)))
        ++state1_reads_after_complete;
}

void front_mem_write(int port, unsigned long long address, int word,
                     unsigned char strobe) {
    if (port < 0 || port >= 13 || (address & ~3ull) + 4 > sizes[port]) {
        problem("write range", port, address); return;
    }
    if (port == 0 || (port >= 2 && port <= 5)) {
        problem("write to read-only model", port, address); return;
    }
    const uint64_t aligned = address & ~3ull;
    uint8_t bytes[4];
    memcpy(bytes, &word, 4);
    for (unsigned lane = 0; lane < 4; ++lane) {
        if (!(strobe & (1u << lane))) continue;
        const uint64_t at = aligned + lane;
        bo[port][at] = bytes[lane];
        if (port == 7) {
            uint64_t slot = UINT64_MAX;
            if (at < 128u * 1024u * 4u) slot = at;
            else if (at >= 1024u * 1024u * 4u &&
                     at < (1024u + 128u) * 1024u * 4u)
                slot = 128u * 1024u * 4u + at - 1024u * 1024u * 4u;
            if (slot < 1048576u && !front_seen[slot]) {
                front_seen[slot] = 1;
                ++front_seen_count;
            }
        }
    }
    ++writes[port];
}

int front_mem_seen(void) { return (int)front_seen_count; }
int front_mem_progress(void) {
    uint64_t accepted = 0;
    for (int port = 0; port < 13; ++port)
        accepted += reads[port] + writes[port];
    return accepted > 0x7fffffffu ? 0x7fffffff : (int)accepted;
}
int front_mem_consumed(void) { return state1_reads_after_complete > 0; }
int front_mem_errors(void) { return errors; }
int front_mem_result_status(void) {
    if (memcmp(bo[1] + 16384, "LYRS", 4)) return -1;
    return bo[1][16394] | (bo[1][16395] << 8);
}
int front_mem_check(void) {
    if (front_seen_count != 1048576u || !state1_reads_after_complete || errors)
        return 0;
    for (unsigned batch = 0; batch < 2; ++batch)
        for (unsigned row = 0; row < 128; ++row) {
            const size_t physical = ((size_t)batch * 1024u + row) * 4096u;
            const size_t dense = ((size_t)batch * 128u + row) * 4096u;
            if (memcmp(bo[7] + physical, oracle + dense, 4096u)) {
                for (size_t byte = 0; byte < 4096; ++byte)
                    if (bo[7][physical + byte] != oracle[dense + byte]) {
                        fprintf(stderr, "FRONT_NUMERIC_FAIL batch=%u row=%u byte=%zu expected=%02x actual=%02x\n",
                                batch, row, byte, oracle[dense + byte],
                                bo[7][physical + byte]);
                        return 0;
                    }
            }
        }
    printf("FRONT_CHAIN_COMPARE_PASS bytes=1048576 state0_writes=%llu state1_writes=%llu state1_reads_after_complete=%llu\n",
           (unsigned long long)writes[6], (unsigned long long)writes[7],
           (unsigned long long)state1_reads_after_complete);
    fflush(stdout);
    return 1;
}
