# E003：真实 generated producer 来源接入

A002单owner，唯一实现根E002/experiment；按既定生产HLS分区和provenance双FIFO合同持续实现，E003仅保存证据。真实LayerNorm generated engine与原浮点IP已经连接STATE0 HIDDEN→NORM的monitor/hub，BEGIN响应完整消费前不放行producer，真实读写/末B及八拍completion参与END fence。canonical SV包现在由实际选定生产生成头产生，并与engine冻结头逐字节核一致；ROM DAT从冻结副本落位并核SHA。

本入口当前限定gamma0 LN_ATTN、D1024、一个诚实rows16 owner。单行pilot和完整16行使用相同冻结RTL/IP/no-wave profile；完整工作量、当前cycles/s和1.5系数在full前决定RUN_FULL/COST_STOP。完整16行的独立gold、原断言、原资源与进展保护保留。


---
Published: 2026-10-12T06:40:59.662522+00:00
Publication: Pc12e05ded50b47cbb482ec55b17aabad
