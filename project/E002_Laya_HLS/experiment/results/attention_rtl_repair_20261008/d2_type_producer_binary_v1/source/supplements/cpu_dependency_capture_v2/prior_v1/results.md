# D2 Type Producer CPU dependency capture status

The source-only candidate retains the frozen 26 translation units, their order,
the four strict numeric/language flags, and the four ordered include roots. It
prepares one unique `-MD` dependency file and object per translation unit, then
one ordered link with `-Wl,-t`. The future driver records actual emitted
headers, object and ELF identities, linker inputs, and direct ELF dependency
inspection. The glibc loader's `--list` is separately gated.

No compiler, preprocessor, CPU DUT, CSim, HLS, RTL, synthesis, implementation,
timing, or board operation has run under this source preparation. The command
manifest and source packet describe a proposed finite build for independent
review; they do not release it.
