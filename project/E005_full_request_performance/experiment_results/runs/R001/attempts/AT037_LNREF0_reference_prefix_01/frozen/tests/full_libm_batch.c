/* Independent oracle adapter: call the host's scalar libm entrypoints on
 * arrays without paying Python-call overhead for every element. */
#include <math.h>
#include <stddef.h>

void full_ref_expf(const float *input, float *output, size_t count) {
  for (size_t i = 0; i < count; ++i) output[i] = expf(input[i]);
}

void full_ref_tanhf(const float *input, float *output, size_t count) {
  for (size_t i = 0; i < count; ++i) output[i] = tanhf(input[i]);
}

void full_ref_logf(const float *input, float *output, size_t count) {
  for (size_t i = 0; i < count; ++i) output[i] = logf(input[i]);
}
