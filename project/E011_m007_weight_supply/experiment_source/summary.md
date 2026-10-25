# E011 / SM010 source summary

Authority: [SM010](../../../mission/M007_完整Attention高性能主干与部署闭合/tasks/SM010.md), decision D-M007-SM010-WSUPPLY-01; full steps/resources in [protocol](protocol.md). Sole implementation remains E002 hbm_loader_and_cache/new M007 files plus tools/m007_weight_pack.py. A010 owns this segment; old t4, parent/gold, A007/A008 untouched.

Deliver pure-byte M007-W576-v1 packing and inverse/independent old-BO checks for qkv.0 K1024/s0, mlp_wi.0 K1024/s81, mlp_wo.0 K2624/s0, head_fc2.0 K4096/s0. Real GGUF and original manifest identity comes from source/m007_matrix_supply_map_20261021.json. Four AXI512 readers with 8 real burst IDs each, <=16 beats/page split and bounded credit feed two actual 278528B superblock slots. Independent source expected data, public synchronous full-slot scan, lease/hold/alternate-slot prefetch and real error-debt drain are required.

Service targets are accepted LOAD to completely readable slot: 1024/2224/3328 cycles under declared peer service. Functional, numerical/protocol, cycle and synthesis evidence remain separate. Real HBM, CDC, parent integration, full matrix and physical300MHz are not established by this experiment.
