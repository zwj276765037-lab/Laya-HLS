# D2 AXI allocation diagnostic v2 results

The stable-sampling v2 source is prepared for consolidated Astra review. The 32-file RTL closure, test, build entry, DPI and guard are byte-identical to v1. Only the passive monitor and top response-snapshot references differ; their exact diff and all input hashes are in `source_binding_packet.json`.

No v2 static build or runtime has executed. The v1 idle run completed with zero traffic and rising RSS; its traffic run failed the first B observer assertion before a readback or final memory check. Those results remain [recorded in the canonical results document](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/source/results.md). They are not a paired v2 contrast.

The pending v2 static build has a 16 GiB owned RSS and 300 s cap. After successful source/snapshot review, the pending idle and traffic runs each have a 4 GiB/90 s/100,000-clock cap. No new memory-growth or transaction-completion claim is available yet.
