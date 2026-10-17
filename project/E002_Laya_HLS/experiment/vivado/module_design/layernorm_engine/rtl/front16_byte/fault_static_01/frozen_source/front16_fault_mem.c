/* Fault-only DPI endpoint; the successful-run endpoint remains frozen. */
#define front16_mem_init front16_base_mem_init
#include "front16_mem.c"
#undef front16_mem_init

static int reset_case;
static int gamma_case;

static void inject_raw_nan(void) {
    bo[STATE0][0]=0; bo[STATE0][1]=0;
    bo[STATE0][2]=0xc0; bo[STATE0][3]=0x7f;
}

int front16_mem_init(void) {
    if (!front16_base_mem_init()) return 0;
    const char *kind=getenv("FRONT16_FAULT");
    if (!kind) return 0;
    reset_case=!strcmp(kind,"reset_raw");
    gamma_case=!strcmp(kind,"gamma_nan");
    if (!reset_case && !gamma_case && strcmp(kind,"raw_nan")) return 0;
    if (gamma_case) {
        bo[AUX][128]=0; bo[AUX][129]=0;
        bo[AUX][130]=0xc0; bo[AUX][131]=0x7f;
    } else if (!reset_case) inject_raw_nan();
    printf("FRONT16_FAULT_READY case=%s\n",kind); fflush(stdout);
    return 1;
}

int front16_fault_rearm(void) {
    if (!reset_case) return 0;
    memset(seen_import,0,sizeof(seen_import));
    memset(seen_ln,0,sizeof(seen_ln));
    memset(seen_gamma,0,sizeof(seen_gamma));
    memset(seen_norm,0,sizeof(seen_norm));
    memset(seen_obs,0,sizeof(seen_obs));
    import_count=ln_count=gamma_count=norm_count=obs_count=errors=0;
    memset(bo[STATE1],0xa5,bo_size[STATE1]);
    memset(bo[OBSERVED],0xa5,bo_size[OBSERVED]);
    inject_raw_nan();
    puts("FRONT16_FAULT_REARM raw_nan=1 output_cleared=1"); fflush(stdout);
    return 1;
}

int front16_fault_check(void) {
    const uint32_t raw_count=gamma_case?RAW_BYTES:4;
    const uint32_t status=gamma_case?2:1;
    const uint32_t row=gamma_case?UINT32_MAX:0;
    const uint32_t gamma_count_useful=gamma_case?4:0;
    const uint32_t expect[16]={0x31423146u,1,status,row,0,
        crc32c(bo[STATE0],raw_count),16,1024,raw_count,0,0,0,
        gamma_count_useful,0,0,0};
    if (errors || ln_count || norm_count || obs_count!=OBS_BYTES ||
        import_count<(int)raw_count || import_count>RAW_BYTES ||
        (gamma_case && (import_count!=RAW_BYTES || gamma_count<4 ||
                        gamma_count>GAMMA_BYTES)) ||
        (!gamma_case && gamma_count)) {
        fprintf(stderr,"FRONT16_FAULT_COVERAGE_FAIL errors=%d raw_R=%d gamma_R=%d ln_R=%d norm_W=%d observed_W=%d\n",
                errors,import_count,gamma_count,ln_count,norm_count,obs_count);
        return 0;
    }
    for (unsigned i=0;i<16;++i) if (le32(bo[OBSERVED]+4*i)!=expect[i]) {
        fprintf(stderr,"FRONT16_FAULT_OBS_FAIL word=%u got=%08x expected=%08x\n",
                i,le32(bo[OBSERVED]+4*i),expect[i]);
        return 0;
    }
    for (unsigned i=16;i<64;++i)
        if (le32(bo[OBSERVED]+4*i)) return 0;
    for (size_t i=0;i<bo_size[STATE1];++i)
        if (bo[STATE1][i]!=0xa5 || (i<RAW_BYTES && seen_norm[i])) return 0;
    for (size_t i=OBS_BYTES;i<bo_size[OBSERVED];++i)
        if (bo[OBSERVED][i]!=0xa5) return 0;
    printf("FRONT16_FAULT_MEM_PASS status=%u raw_useful=%u raw_physical=%d gamma_useful=%u gamma_physical=%d norm_W=%d observed_W=%d\n",
           status,raw_count,import_count,gamma_count_useful,gamma_count,
           norm_count,obs_count); fflush(stdout);
    return 1;
}
