// DPI surface for the isolated AXI endpoint protocol test. No model data.
#include <stdint.h>
int front16_mem_read_word(int port, uint64_t address) { (void)port; (void)address; return 0; }
void front16_mem_read_accept(int port, uint64_t address, int bytes) {
    (void)port; (void)address; (void)bytes;
}
void front16_mem_write_word(int port, uint64_t address, int word, unsigned char strobe) {
    (void)port; (void)address; (void)word; (void)strobe;
}
int front16_mem_import_bytes(void) { return 0; }
int front16_mem_gamma_bytes(void) { return 0; }
