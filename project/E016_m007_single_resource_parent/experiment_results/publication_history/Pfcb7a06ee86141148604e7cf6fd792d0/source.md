# E016/R007 current source and validation boundaries

Canonical parent_v3 ABI cedb4c130303f16da9fa1c605b2cf985 and kind5/6/7 production are unchanged. Current dependency closure contains92 RTL files (81SV+11V) plus one EXP ROM initialization .dat,93 source/data items. Original v2/R006 and all frozen attempts remain untouched. Production implements the source graph; complete Encoder/kind7 mathematics has not run.

Original complete kind5/layer0 checker37e8c147 compiled AT036 and passed QKV3 AT037. Its matrix/A/W/prebias/issue/PS,16head, G-node, real residual/LN→quant/A→FFN and final-H/output/receipt assertions remain preserved. New pure1D compatibility checker5f759fe2 changes only top name and four rope readmemh operations to a1D8192x32 temporary plus zero-delay element copies; all original math/peer/fixtures are identical. New binary kind5 successor719e63ca replaces only the W simulation source and catalog/W mux, with exact baseline reconstruction; it is source-only.

The all120 binary AXI source4d9265c2 reads original TN8 BOs by immutable actual-AR descriptor/port/local origin/ID and explicit little-endian Q/F16 bytes. AT038/039 validated independent original-GGUF bytes; AT040/041 then validated unchanged production W reader_v2/supply_v2/bank_v1 plus this peer through actual last parser consumption/cache use and retirement. No new floating oracle, model run or full120 packing.

New m007_fullgraph_binary_tb677e5bc9 (public-boundary revision2) independently prepares real public kind6/7 checking. Kind7 drives only original embedding_norm at one BEGIN, follows actual global0..29, checks all30 final residual H endpoints plus final_norm Q/type_add H, and original Decision1 marker+CLS544 public vectors. Kind6 is explicitly a standalone complete Decision with its original public component input, not its preceding producer. AT044 rechecked all47 original raw SHA and serialized exact integer bytes. There are34 FPGA/input/gather checkpoint records with planned value comparisons;13 other original47 records are identity binding only. Intermediate per-layer score/QKV/G all-value gold is not added. Both binary successors are frozen source-only, NOT_COMPILED/NOT_RUN.

[Current staged delivery](../experiment_results/runs/R007/AT038_044_staged_delivery.json), [checkpoint map](../experiment_results/runs/R007/fullgraph_checkpoint_mapping.json), [original47 binding](../experiment_results/runs/R007/fullgraph_original_input_binding.json).

Revision2 adds only current public ABI normal assertions: every kind7 output row must match original slot0:23,slot1:33,inactive slots2..15:0 and CLS16:0; actual tail_begin request/generation/source_epoch/69632B must match the accepted request; independent SIM commit uses and checks the immutable tail acceptance identity. Existing slot/column/data assertions remain. V1 prepared snapshot87cca31b and all its metadata, original gold, production and oldkind5/1D/binary sources remain byte-identical. Current source-only freeze: prepared/fullgraph_kind6_kind7_public_boundary_v2; no EDA. [Minimal diff and exact identities](../experiment_results/runs/R007/fullgraph_public_boundary_v2_delivery.json).

Current pending kind5 successors correct an inherited residual reference loader defect: m007_fullmodel_encoder_1d_tb172d3019 and binary-kind5 successor246c2d6a load the entire original131072x32bit GOLD.hex into a scalar temporary, then zero-delay pack residual_a[g][32*l+:32]=scalar[32*g+l] for all4096x32 lanes. Top names, original files, clocks/delays, W peers and numerical assertions are preserved. Old5f759f/719e/frozen37e8/R006 and original failures remain historical. New fullgraph677e5bc9 does not use this scalar fixture and remains unchanged. [Repair, exact source manifests and minimal diffs](../experiment_results/runs/R007/residual_loader_repair_delivery.json).


---
Published: 2026-10-23T10:51:12.958647+00:00
Publication: Pb6e063e05f264f3a91c1774fd0734169
