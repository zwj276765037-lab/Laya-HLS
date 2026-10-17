# D2-I vector mode3 static RTL pilot results

State on 2026-10-09: source preparation only. No mode3 page materialization, CPU/CSim, RTL static compilation, XSim runtime, OOC, implementation, board test or 50 ms measurement has run.

The frozen generated closure has 226 Verilog, 73 DAT and eight FP simulation VHDL wrappers; seven 32-bit AXI ports and two Lite banks were read from the immutable generated top. The 14 mapped 4 KiB pages and single B1/S64 mode3 request are source-contract counts, not runtime observations. Physical beat counts, service cycles, simulator rate, RSS and wall allowances must be derived from the actual generated producer/read/write paths and independent source review before any execution gate. Existing D2-I CPU/CSim/synthesis success and the accepted bounded endpoint do not substitute for mode3 RTL evidence.
