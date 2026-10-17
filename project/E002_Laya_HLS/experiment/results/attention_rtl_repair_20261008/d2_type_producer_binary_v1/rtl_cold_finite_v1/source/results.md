# Type producer cold finite RTL: evidence status

Source preparation began 2026-10-09 under the separately accepted [cold finite design](design.md). The original Type v1 C++/HLS outputs and independent CPU references are frozen. This sibling has not executed a materializer, compiler, simulator, HLS tool, or DUT.

| Stage | Actual status | Evidence or remaining condition |
| --- | --- | --- |
| Source geometry | Actual generated top binds 352 pins: seven 32-bit AXI masters, `s_axi_control` and `s_axi_control_r`. The accepted sparse map resolves to 206 distinct 4 KiB physical pages. | `port_page_binding.json` records every generated pin, CSR direction, address width, page base, BO capacity and usable bytes on partial pages. It binds the top to SHA-256 `c147a9f763b6eddcd6fab594639ece4b74f2ded629cc4d6d23d4a45971d1438e` and the frozen `../../tb/static_mapping.json`. |
| Cold numerical input | qtype2 and qtype1 inputs and independent CPU references already exist. | Type v1 `source/source_packet.json` and accepted CPU result; each RTL case requires a fresh simulator process. |
| Cycle bound | **Unresolved. Runtime held.** | HLS top latency is `?`; the generated FSM/call graph and dynamic loop exits require a separate finite watchdog certificate. No ceiling is inferred from that report. |
| Functional RTL simulation | Not run | Separate source and execution reviews are required. |
| Synthesis | Only the frozen upstream HLS synthesis was run. | Its 5.158 ns estimate exceeds the effective 4.87 ns target budget; no physical timing claim. |
| Implementation, timing, board | Not run | No release. |

The candidate verification scope is sparse mapped-page coverage with forbidden-address assertions. It cannot be described as a full physical BO dump. Retain first failure and all partial raw bytes in any future gated attempt.
