# Current AT019 artifact and documented recovery boundaries

Read-only inventory is intermediate_inventory.json (340 files at that snapshot). Canonical R001/checkpoints is empty, and this attempt has no .dcp/.edf/.edif/.ngc/.v/.vm/.xpr output, no intermediate_scope.txt, no stage_complete.txt and no final receipt. The original native synthesis report is retained; its completion line is not a saved design checkpoint.

61 internal .rtd files total1,217,755,216 bytes (1,217,888,256 allocated bytes), including elab.rtd, realtime/tmp/design.rtd, straps.rtd and global_name.straps.rtd. There are48 .rtd.completed markers,48 .pb artifacts, internal Tcl/log files, a90-byte CRC performance report and a zero-byte synthesis.wdf. None is labelled a verified reloadable mapped netlist. Internal .completed names do not replace the complete-stage marker or effective receipt. Original ROM input and frozen source/flow enable reproduction from inputs, not continuation from mapped state. No cache has been removed, renamed, converted or tested by a new EDA run.

Installed official2025.2 manuals, frozen with byte hashes in official_recovery_manual_sources.json:

- write_checkpoint L4-8 saves a design checkpoint containing netlist/constraints and possible physical data; L16-17 loads it through open_checkpoint. It is an operation on a current design in a responsive Vivado command context, not a documented external-process memory export.
- open_checkpoint L4-13 opens an existing DCP as an in-memory non-project design, including OOC checkpoints. read_checkpoint L4-13 reads existing DCP data and uses link_design/open_checkpoint to create the design.
- open_run L9-15 is for Project Mode design runs; L37-39 requires synthesis/implementation to have completed.
- launch_runs L4-16 requires an existing Project Mode run and explicitly contrasts direct non-project synth_design. L93-95 -next_step continues a run previously stopped by -to_step; this does not document resuming inside a blocked synth_design command.
- Local installed Tcl-man search for .rtd/read_rtd has no match (exit1). This is bounded evidence that the examined supported interfaces do not document an .rtd reload path, not proof that no vendor/private recovery exists.

This flow calls synth_design directly and writes core_synth.dcp only after it returns and passes blackbox checks. No valid input for the documented checkpoint reopening path currently exists. A second Vivado, direct write_checkpoint injection, internal-cache experiment or production-thread manipulation would require a new explicit engineering boundary; none was attempted. Offline.so symbol interpretation belongs solely to A014. The actual stack identifies thread wait states, without proving a zombie cause or a safe recovery.
