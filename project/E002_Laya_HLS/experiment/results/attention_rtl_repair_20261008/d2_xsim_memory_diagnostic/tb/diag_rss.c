#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>

/* Diagnostic-only observation. Each call reads only this process's /proc status. */
void diag_stage(const char *label, long long elements, long long aux) {
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
    fprintf(stdout, "DIAG_STAGE epoch_ms=%lld pid=%ld label=%s elements=%lld aux=%lld rss_kb=%ld hwm_kb=%ld\n",
            (long long)now.tv_sec * 1000 + now.tv_usec / 1000, (long)getpid(),
            label, elements, aux, rss_kb, hwm_kb);
    fflush(stdout);
}
