#define _GNU_SOURCE
#include <dlfcn.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
static void *libm(void) {
  static void *h;
  if (!h) { h = dlopen("libm.so.6", RTLD_NOW | RTLD_LOCAL); if (!h) abort(); }
  return h;
}
#define WRAP(NAME, VERSION) \
float NAME(float x) { \
  static float (*f)(float); \
  if (!f) { f = (float (*)(float))dlvsym(libm(), #NAME, VERSION); if (!f) abort(); } \
  return f(x); \
}
#ifdef WRAP_EXPF
WRAP(expf, "GLIBC_2.27")
#endif
#ifdef WRAP_TANHF
WRAP(tanhf, "GLIBC_2.27")
#endif
#ifdef WRAP_LOGF
WRAP(logf, "GLIBC_2.27")
#endif
#ifdef WRAP_ROUNDF
WRAP(roundf, "GLIBC_2.2.5")
#endif
#ifdef WRAP_SQRTF
WRAP(sqrtf, "GLIBC_2.2.5")
#endif
