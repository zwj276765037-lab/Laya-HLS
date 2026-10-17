#define _POSIX_C_SOURCE 200809L
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum {STATE0, AUX, STATE1, OBSERVED, PORTS};
enum {RAW_BYTES=65536, GAMMA_BYTES=4096, OBS_BYTES=256};
static uint8_t *bo[PORTS], *raw_gold, *norm_gold;
static size_t bo_size[PORTS] = {RAW_BYTES+64, 128+GAMMA_BYTES+64,
                              RAW_BYTES+64, OBS_BYTES+64};
static uint8_t seen_import[RAW_BYTES], seen_ln[RAW_BYTES],
               seen_gamma[GAMMA_BYTES], seen_norm[RAW_BYTES],
               seen_obs[OBS_BYTES];
static int import_count, ln_count, gamma_count, norm_count, obs_count;
static int errors;

static void fail(const char *what, int port, uint64_t address) {
    if (errors++ < 12)
        fprintf(stderr,"FRONT16_MEM_ERROR %s port=%d address=%llu\n",
                what,port,(unsigned long long)address);
}
static uint8_t *load(const char *path, size_t min_size, size_t *size) {
    FILE *f=fopen(path,"rb");
    if (!f) { perror(path); exit(2); }
    if (fseek(f,0,SEEK_END)) exit(2);
    long length=ftell(f);
    if (length<(long)min_size || fseek(f,0,SEEK_SET)) exit(2);
    uint8_t *p=malloc((size_t)length);
    if (!p || fread(p,1,(size_t)length,f)!=(size_t)length) exit(2);
    fclose(f); *size=(size_t)length; return p;
}
static uint32_t le32(const uint8_t *p) {
    return (uint32_t)p[0] | (uint32_t)p[1]<<8 |
           (uint32_t)p[2]<<16 | (uint32_t)p[3]<<24;
}
static uint32_t crc32c(const uint8_t *p, size_t n) {
    uint32_t crc=0xffffffffu;
    for (size_t i=0;i<n;++i) {
        crc^=p[i];
        for (unsigned b=0;b<8;++b)
            crc=(crc>>1)^((crc&1)?0x82f63b78u:0u);
    }
    return crc^0xffffffffu;
}
int front16_mem_init(void) {
    const char *paths[4]={getenv("FRONT16_STATE0"),getenv("FRONT16_AUX"),
                          getenv("FRONT16_RAW_GOLD"),getenv("FRONT16_NORM_GOLD")};
    for (int i=0;i<4;++i) if (!paths[i]) {
        fputs("FRONT16_MEM_ERROR missing input environment\n",stderr);return 0;
    }
    size_t size;
    uint8_t *raw=load(paths[0],RAW_BYTES,&size);
    bo[STATE0]=malloc(bo_size[STATE0]);
    if (!bo[STATE0]) return 0;
    memset(bo[STATE0],0xa5,bo_size[STATE0]);
    memcpy(bo[STATE0],raw,RAW_BYTES);
    free(raw);
    uint8_t *aux=load(paths[1],128+GAMMA_BYTES,&size);
    bo[AUX]=malloc(bo_size[AUX]);
    if (!bo[AUX]) return 0;
    memset(bo[AUX],0xa5,bo_size[AUX]);
    memcpy(bo[AUX],aux,128+GAMMA_BYTES);
    free(aux);
    for (int p=STATE1;p<=OBSERVED;++p) {
        bo[p]=malloc(bo_size[p]);
        if (!bo[p]) return 0;
        memset(bo[p],0xa5,bo_size[p]);
    }
    raw_gold=load(paths[2],RAW_BYTES,&size);
    norm_gold=load(paths[3],RAW_BYTES,&size);
    if (memcmp(bo[STATE0],raw_gold,RAW_BYTES)) {
        fputs("FRONT16_MEM_ERROR raw gold mismatch\n",stderr);return 0;
    }
    puts("FRONT16_MEM_READY rows=16 cols=1024"); fflush(stdout);
    return 1;
}
int front16_mem_read_word(int port, unsigned long long address) {
    if (port<STATE0 || port>AUX || address+4>bo_size[port]) {
        fail("read range/direction",port,address);return 0;
    }
    return (int)le32(bo[port]+address);
}
void front16_mem_read_accept(int port, unsigned long long address, int bytes) {
    if (bytes<1 || bytes>64) {fail("read size",port,address);return;}
    for (int i=0;i<bytes;++i) {
        uint64_t at=address+(unsigned)i;
        if (port==STATE0) {
            if (at>=RAW_BYTES) {fail("raw read range",port,at);continue;}
            uint8_t *seen = import_count<RAW_BYTES ? seen_import : seen_ln;
            int *count = import_count<RAW_BYTES ? &import_count : &ln_count;
            if (seen[at]) fail("duplicate raw read byte",port,at);
            else {seen[at]=1;++*count;}
        } else if (port==AUX) {
            if (at<128 || at>=128+GAMMA_BYTES) {
                fail("gamma read range",port,at);continue;
            }
            if (seen_gamma[at-128]) fail("duplicate gamma byte",port,at);
            else {seen_gamma[at-128]=1;++gamma_count;}
        } else fail("accepted read direction",port,at);
    }
}
void front16_mem_write_word(int port, unsigned long long address, int word,
                            unsigned char strobe) {
    if (!strobe) return;
    if (port<STATE1 || port>OBSERVED || address+4>bo_size[port]) {
        fail("write range/direction",port,address);return;
    }
    uint32_t bits=(uint32_t)word;
    for (unsigned lane=0;lane<4;++lane) {
        if (!(strobe&(1u<<lane))) continue;
        uint64_t at=address+lane;
        int max=port==STATE1?RAW_BYTES:OBS_BYTES;
        if (at>=(uint64_t)max) {fail("write outside useful span",port,at);continue;}
        uint8_t *seen=port==STATE1?seen_norm:seen_obs;
        int *count=port==STATE1?&norm_count:&obs_count;
        if (seen[at]) fail("duplicate output byte",port,at);
        else {seen[at]=1;++*count;}
        bo[port][at]=(uint8_t)(bits>>(8*lane));
    }
}
int front16_mem_import_bytes(void) {return import_count;}
int front16_mem_ln_bytes(void) {return ln_count;}
int front16_mem_gamma_bytes(void) {return gamma_count;}
int front16_mem_norm_bytes(void) {return norm_count;}
int front16_mem_obs_bytes(void) {return obs_count;}
int front16_mem_errors(void) {return errors;}
int front16_mem_progress(void) {
    return import_count+ln_count+gamma_count+norm_count+obs_count;
}
int front16_mem_capture(void) {
    const char *names[3]={"front16_actual_norm.bin","front16_norm_seen.bin",
                           "front16_actual_observed.bin"};
    const uint8_t *data[3]={bo[STATE1],seen_norm,bo[OBSERVED]};
    const size_t sizes[3]={RAW_BYTES,RAW_BYTES,OBS_BYTES};
    for (int i=0;i<3;++i) {
        FILE *f=fopen(names[i],"wb");
        if (!f || fwrite(data[i],1,sizes[i],f)!=sizes[i] || fclose(f)) return 0;
    }
    return 1;
}
int front16_mem_check(void) {
    if (errors || import_count!=RAW_BYTES || ln_count!=RAW_BYTES ||
        gamma_count!=GAMMA_BYTES || norm_count!=RAW_BYTES ||
        obs_count!=OBS_BYTES) {
        fprintf(stderr,"FRONT16_COVERAGE_FAIL errors=%d import=%d ln=%d gamma=%d norm=%d obs=%d\n",
                errors,import_count,ln_count,gamma_count,norm_count,obs_count);
        return 0;
    }
    float max_abs=0,max_rel=0;
    for (int i=0;i<RAW_BYTES;i+=4) {
        float got,ref;
        memcpy(&got,bo[STATE1]+i,4);
        memcpy(&ref,norm_gold+i,4);
        if (!isfinite(got) || !isfinite(ref)) return 0;
        float abs_err=fabsf(got-ref);
        float rel_err=abs_err/fmaxf(fabsf(ref),1e-30f);
        if (abs_err>max_abs) max_abs=abs_err;
        if (rel_err>max_rel) max_rel=rel_err;
        if (abs_err>1e-4f+1e-4f*fabsf(ref)) {
            fprintf(stderr,"FRONT16_NORM_FAIL element=%d got=%a ref=%a\n",i/4,got,ref);
            return 0;
        }
    }
    for (size_t i=RAW_BYTES;i<bo_size[STATE1];++i)
        if (bo[STATE1][i]!=0xa5) return 0;
    for (size_t i=OBS_BYTES;i<bo_size[OBSERVED];++i)
        if (bo[OBSERVED][i]!=0xa5) return 0;
    const uint32_t expected[16]={0x31423146u,1,0,UINT32_MAX,UINT32_MAX,
       crc32c(bo[STATE0],RAW_BYTES),16,1024,RAW_BYTES,0,RAW_BYTES,0,
       GAMMA_BYTES,0,RAW_BYTES,0};
    for (unsigned i=0;i<16;++i)
        if (le32(bo[OBSERVED]+i*4)!=expected[i]) {
            fprintf(stderr,"FRONT16_OBS_FAIL word=%u got=%08x expected=%08x\n",
                    i,le32(bo[OBSERVED]+i*4),expected[i]);return 0;
        }
    for (unsigned i=16;i<64;++i)
        if (le32(bo[OBSERVED]+i*4)!=0) return 0;
    printf("FRONT16_MEM_PASS raw_f32=16384 norm_f32=16384 norm_max_abs=%g norm_max_rel=%g local_crc32c=%08x\n",
           max_abs,max_rel,expected[5]);fflush(stdout);
    return 1;
}
