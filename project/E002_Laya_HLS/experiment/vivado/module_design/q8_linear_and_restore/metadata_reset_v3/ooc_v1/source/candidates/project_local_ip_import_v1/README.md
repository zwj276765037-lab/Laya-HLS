# Project-local IP import candidate (source only)

This directory is an isolated correction candidate for the stopped Q8 same-source OOC project-preparation run. It has not been substituted for the accepted V4 scripts and has not been run in Vivado. The partial `project_prepare_v1` XPR and logs remain sealed. Any future execution needs a fresh project directory and a separate reviewed release.

The governing Astra xhigh contract is `results/attention_rtl_repair_20261008/reviewer_q8_ooc_project_local_ip_import_source_correction_contract.json` (SHA256 `cf19f1acb262e80fc0289238f7101f4c259ffa9cbc5e7537d7cea888d650fb4e`).

The first failure is `Common 17-170` at `tb/create_project.tcl:27`: direct `set_property` parses the leading `-mode out_of_context` value as a command option. The previously successful `vivado/project/scripts/create_project.tcl:27` uses `set_property -dict [list {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} {-mode out_of_context}]`. The candidate adopts that exact form.

All seven original XCI files have `ip_inst.gen_directory` under the old `subcore_prj.gen`. Staging them in one flat `stage/ip` directory and registering them with `add_files` produced seven `IP_Flow 19-2162` shared-output locks and seven `Vivado 12-13650` warnings pointing outside the run. The installed Vivado 2025.2 manual at `Vivado/doc/eng/man/import_ip` says `import_ip -srcset sources_1 <files>` copies an XCI into the project-local source tree. The candidate imports each staged XCI separately, without `-quiet`, and checks all seven imported IP objects before any `generate_target` call.

The pre-generation gate requires each `IP_FILE`, `IP_OUTPUT_DIR`, and imported XCI `gen_directory` to resolve within the fresh project. It requires each output directory to be exactly `vivado/q8_same_source_ooc.gen/sources_1/ip/<name>`, each `IS_LOCKED` to be false, and each original/staged XCI to match the frozen input manifest byte-for-byte. It records imported XCI hashes and exact JSON differences; only `/ip_inst/gen_directory` and `/checksum` may differ. This preserves every FP parameter, component reference, boundary, and other XCI field. A failed check stops before target generation and leaves the imported copy and `ip_import_preflight.json` for review.

`verify_project.tcl` follows the imported file rather than expecting the stage XCI to be directly registered. On promotion, the accepted source packet must bind the revised scripts and checker; the existing exact product identity and compile-order checks remain in force. No generated IP product or OOC synthesis claim is made here.

The source-only checks are `mock_control_check.tcl` (seven imports precede the preflight; the locked-IP branch generates nothing), `test_xci_whitelist.py` (allowed exact paths and configuration/path escape rejection), Tcl completeness and Python syntax checks. The packet binds these results and both canonical diffs.
