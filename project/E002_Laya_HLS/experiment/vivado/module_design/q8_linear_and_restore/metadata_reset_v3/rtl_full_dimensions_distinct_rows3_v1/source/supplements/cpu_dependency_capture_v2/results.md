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
