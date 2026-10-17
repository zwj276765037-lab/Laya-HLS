# Distinct-row Scorer CPU dependency capture status

The source-only candidate keeps the two frozen C++ translation units and their
order, strict numerical flags, and the four ordered include roots. It prepares
one unique `-MD` dependency file and object for each unit, then one ordered
link with `-Wl,-t`. The future driver records actual local, Vitis, and system
headers, object and ELF identities, linker inputs, and direct ELF dependency
inspection. The glibc loader's `--list` is separately gated.

No compiler, preprocessor, CPU DUT, XSim, HLS, synthesis, implementation,
timing, or board operation has run under this source preparation. The command
manifest and source packet describe a proposed finite build for independent
review; they do not release it.
