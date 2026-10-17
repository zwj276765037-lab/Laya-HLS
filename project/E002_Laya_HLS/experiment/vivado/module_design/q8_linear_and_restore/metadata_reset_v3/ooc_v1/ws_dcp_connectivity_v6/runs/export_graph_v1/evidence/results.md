# Ws v6 single DCP export and graph extraction

2026-10-09. The one released Vivado invocation exited 0 in 89.017 seconds. It opened the sealed checkpoint once, exported all eight exact Ws bank functional netlists (1,858,508 bytes combined), and flushed all 11 graph tables. The Tcl terminal record is `extraction COMPLETE`; the raw graph contains 368 selected cells, 37,936 pins and 1,330 nets. The raw property extraction reports 768 gaps, retained in the property and issue tables for a later explicit join.

The guard recorded peak owned RSS 3,952,328 KiB, minimum MemAvailable 436,329,984 KiB, no trigger, and matching CPU 0–3/nice 19/idle I/O policy. All 112 bound input records, including the DCP and source packet, matched their expected bytes and SHA256 after the run. The launcher's four observed owned PIDs have no remaining process-group members. All 30 output files were copied byte-for-byte with modes into `archive/`; `output_manifest.json` and `evidence_packet.json` bind the copies and raw outputs.

This run did not invoke the actual exported-netlist parser, property join or mapping evaluator. The 8 × 20,992 × 16-bit Ws physical mapping, including addresses 16,384–20,991, remains unproved. No re-synthesis, optimization, implementation, timing, CPU/RTL numerical run or board test occurred.
