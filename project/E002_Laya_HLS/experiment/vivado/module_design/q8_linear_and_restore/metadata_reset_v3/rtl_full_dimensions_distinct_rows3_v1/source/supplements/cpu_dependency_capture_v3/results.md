# Distinct-row Scorer CPU dependency capture status

The source-only candidate keeps the two frozen C++ translation units and their
order, strict numerical flags, and the four ordered include roots. It prepares
one unique `-MD` dependency file and object for each unit, then one ordered
link with `-Wl,-t`. The future driver records actual local, Vitis, and system
headers, object and ELF identities, linker inputs, and direct ELF dependency
inspection. The glibc loader's `--list` is separately gated.

No compiler, preprocessor, CPU DUT, XSim, HLS, synthesis, implementation,
timing, or board operation is authorized under this v3 source preparation.
A separate v2 build attempt already ran once and stopped at the parser after
its first compile; that first failure is preserved and accepted. The command
manifest and source packet describe a proposed finite build for independent
review; they do not release it.

## v2 reviewer corrections (source only)

The reviewed v1 preimages are retained byte-for-byte in `prior_v1/` and in
place. This v2 candidate changes only the capture driver and its new output
identity. A shared library may have zero or one ELF interpreter; an interpreter
when present must resolve to the bound glibc loader. The final executable
still requires exactly one matching interpreter. Raw readelf output remains
bound to the build packet.

The bound `/usr/bin/dpkg-query` binary queries only the accepted host-chain
manifest's `installed_package_versions_for_bound_files` names before and after
the future build. Each command and raw stdout/stderr file is preserved. Any
version or query failure is a recorded first failure. No compiler,
preprocessor, linker, CPU DUT, or EDA operation has run for this v2 source
candidate; its build still requires a separate exact release and root slot.

## v3 parser repair (source only)

The v2 raw depfile has SHA-256 `8ce95b9b8a446d8fde776480e20bc11832d9a3e23993c3ec16f196a4d7697966`.
Read-only parsing must preserve 303 ordered prerequisites and 301 unique names;
`gmp.h` and `mpfr.h` occur twice each. The v3 self-test covers duplicate
prerequisites, empty prerequisites, continuations, escapes, and malformed
syntax. The default source checker must pass without running a compiler.
The future build remains held behind a separate release and 8 GiB/600-second
aggregate guard. No v3 CPU numerical or EDA result is claimed.
