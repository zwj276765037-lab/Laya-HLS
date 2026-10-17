#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <unistd.h>

/* The offset TV is ASCII and the original parser uses fscanf, not fread. */
long long phase_probe_file_bytes(const char *path) {
    struct stat details;
    return stat(path, &details) == 0 ? (long long)details.st_size : -1;
}

/* Read-only stage observation in the actual XSim kernel process. */
void phase_probe_stage(const char *label, long long sim_time_ps,
                       long long clock_count, long long value0, long long value1) {
    long rss_kb = -1, hwm_kb = -1;
    char line[256];
    FILE *status = fopen("/proc/self/status", "r");
    if (status != NULL) {
        while (fgets(line, sizeof line, status) != NULL) {
            if (strncmp(line, "VmRSS:", 6) == 0) sscanf(line + 6, "%ld", &rss_kb);
            if (strncmp(line, "VmHWM:", 6) == 0) sscanf(line + 6, "%ld", &hwm_kb);
        }
        fclose(status);
    }
    struct timeval now;
    gettimeofday(&now, NULL);
    fprintf(stdout, "D2_PHASE_STAGE wall_ms=%lld pid=%ld sim_ps=%lld clock=%lld label=%s value0=%lld value1=%lld rss_kb=%ld hwm_kb=%ld\n",
            (long long)now.tv_sec * 1000 + now.tv_usec / 1000, (long)getpid(),
            sim_time_ps, clock_count, label, value0, value1, rss_kb, hwm_kb);
    fflush(stdout);
}
