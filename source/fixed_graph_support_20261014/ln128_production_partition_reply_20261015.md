# LN128生产抽取：两模块固定接口交付

2026-10-15；A003→A001；M004/SM004/E004/R001；回复 `m004-ln128-production-partition-interface-question-20261015`。仅静态设计，未启动实现或实验。

已追加原文档[“LN128实际生产服务抽取”](../fixed_graph_architecture_20261014.md#ln128实际生产服务抽取固定切口与端口2026-10-15)，给出唯一推荐：下层共享LNQ/final_bank/prep/Q16服务，上层共享实际STATE0/AUX/norm I/O与staged 128行/16行错误屏障。原父top必须实际调用同两模块；完整图只保留一个LN/Q/bank、原两reader和一个writer。原core/wrapper/sequencer做固定接线/代理，重matrix/G/ADD/RoPE仍在父图，独立阶段没有复制或替代算术。

已列具体状态/寄存器移动、8类bank访问和固定端口。关键限制是：

- 原G_R0/R1可能与G返回同拍，要求同bank不同addr的同步1R+1W；保留x同addr互锁，gate328..655与返回0..327不重叠。不能一概串行化或给无ready的G返回加阻塞。matrix末组8lane和ADD返回也不能丢写；原poison/finite/首错留在父执行器。
- G两组256bit保持、ADD bank操作数32bit、replay/Q16/result寄存器随bank移动，不新增整行RAM。G/ADD保持原读拍，外部结果口仍E0接索引/E1取八bank，rsp阻塞稳定且release等pending/rsp空。
- 两reader与单writer连同物理路由移上层；QKV/RoPE成为固定客户端。AUX LOAD、source与RoPE换路要等真实R债/holding退完；writer换段须末B、flush撤下及真债零。norm成功位还要下层release/done真实消费。gamma/A16及修订18partial ownership继续唯一持有；stage discard保留原16行数值优先规则。
- 给出4组回归：真实source→LN→norm及16行pilot/有条件LN128；Q16/部分窗口与bank并发；真实父图固定端口兼容；错误/末B/持有/reset。局部合法bank事务不代签matrix/G/ADD数值，独立LN128不代签完整父top同runtime或整模首错。

依据：[小身份/整数记录](ln128_production_partition_20261015.json)、[静态脚本](check_ln128_production_partition_20261015.py)、[计量](ln128_partition_static_time_20261015.txt)。本次8项定向身份与地址条件一致，core完整SHA `a73632b8a85fae646b36c0355065b19a5f91b4067440c5f96f14726726197e54`；wrapper/sequencer/leaf与本消息起点一致。静态脚本0.05s、峰16504KiB、exit0，CPU0–3/nice19/idle；交互读取累计UNKNOWN，状态/发送工具计量另存。AT304–306仅引用原工程报告，不重复成本调查，也不承诺抽取后的仿真加速。

接口已可转入A001后继合同；工程预算、pilot帽和实施仍由主控集中下达。本答复不阻塞修订18审核，无需确认回信。
