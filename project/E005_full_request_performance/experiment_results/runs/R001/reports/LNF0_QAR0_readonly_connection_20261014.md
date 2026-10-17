# LNF0→QAR0只读接点：真实来源与单量化器约束

2026-10-14；M003/M004、SM005/E005/R001；A002定向只读核查。未改DUT/TB，未运行HLS、RTL或新长链。依据为[AT040限定结果](LNF0_four_row_rtl_result_20261014.md)、[AT035限定结果](QAR0_shared_quant_admission_20261014.md)及本项目当前/冻结接口；两条历史PASS不可拼作同runtime通过。

| 接点 | 当前已证/源码事实 | 下一同runtime连接的必要条件 |
| --- | --- | --- |
| LN输出与来源权威 | AT040的`laya_layernorm_producer_portal_shell_v1`经真实W/B、END、PUBLISH后，`laya_generated_provenance_hub_v1`按完整source query授予读lease；四行NORM实际写地址以STATE0 BO base `0x300000000`、offset `0x800000`表示。LNF0 shell同时内建`laya_gate_quant_portal_binding_v1`及自己的Q/fullA实例。 | 接QAR0时保留原LN producer/monitor/hub和唯一物理ledger；必须让AT035长链**原有那一套**quant_task/dualA接收LN源。不能把LNF0 shell与AT035 bridge并列后让两个Q都运行。 |
| AT035外部Q准入 | 冻结`geglu_gate_quant_bridge_v1`在IDLE/G优先仲裁后由ext_quant字段喂同一个quant_task；冻结TB第610行给`ext_quant_source_published(1'b1)`，第568行将`source_quant_owner_admitted`初始化为1。它在地址`DDR_BASE+327680 = 0x100050000`预装LN_FFN四行F32后实际读256R。 | 移除中间F32预装。ext_quant接受必须与hub的完整identity/model/P/Q/L/Ref/范围/窗口、真实PUBLISH和source-query/grant原子对应；拒绝时不能产生AR或lease。原G优先和已受理任务至响应消费的归属保持。不能把一个布尔publish或仅地址相等当准入。 |
| 地址和物理R | AT040 NORM逻辑区与AT035当前`SOURCE_BASE`不是同一物理地址；AT035 TB只在393216B诊断DDR内映射预装源、Wi/GATE/Down。 | 为一个共享物理存储模型配置合法STATE0/NORM地址及Wi/GATE/Down区域；Q实际AR/R必须返回同runtime LN真实AW/W写入的字节。保留STATE0容量16920576B及NORM offset8MiB、各原输出地址/保护字节和真实AXI响应；允许稀疏映射，但每笔地址、写集合、有效区及邻接保护区仍须核验。不能默默把LN目的重命名为AT035预装源。 |
| lease与完成 | 原`laya_gate_quant_portal_binding_v1`在普通Q接受时使用`source_query_ready/granted`，Q实际完成、响应消费和物理读债清零共同使`source_release_valid/ready`闭合。AT035 ext_quant_active也等到响应消费才释放其量化器归属，但没有接这份hub lease。 | 外部Q完整命令必须可被hub识别；租约从Q受理延续至Q真实R债、fullA提交/响应消费的原合同边界，失败/拒绝后按真实债务释放。QAR0桥的ext端口只有NumericIdentity、P/Q/L、Refs和地址/步长，没有完整L13M及portal generation输入；生成完整source-query packet的来源与单调generation需明确接线，不得用固定常量或新全局READY表代替。 |
| 普通逐窗口P范围 | 当前RTL hub的`source_owner_supported`限定fullwidth/layout0/role6，`source_window_event_ok`按一条END覆盖一个标准窗口；AT040使用四行局部owner，因此真实证明仅限该窗口。C侧`laya_full_owner.cpp`已有更广的普通/Attention/QKV窗口账本逻辑，不能由AT040代签其物理接口。 | M003完整普通Q/L仍需按`ordinary_linear_provenance_contract_20261012.md`补多窗口/多贡献、完整tensor发布、原地旧epoch等真实物理证明。单个LN四行→QAR0连接可以作为下一个有限样本，但不关闭全类普通来源或M003。 |

两侧已有解码和算术字段可复用，剩余实质问题集中在**唯一量化器路由、portal完整命令/lease适配及共享地址存储**。`quant_task_to_dual_a_v1`的`cfg_ready`由空闲/容量决定，`cfg_source_published`参与`command_ok`而不是ready；这提供了同一受理边沿核grant的可能接点，但是否直接组合连接或采用有界待受理槽，须在下一阶段合同中明确并经真实双valid、拒绝、响应反压和债务测试，不能由源码可能性预签活性。

定向接口身份（bytes/SHA256）：当前LN producer shell 32685/`406c02d56f76c0bcca4129d8956ffc9fbc4957a905f497e5bb5146e74a4b307d`；LNF0组合shell 12680/`03cdbeac0dc761f5b71bfd59a557194fa37c4d60e9c52bcbb2af77e135ff48c7`；hub 63077/`a735cae418e181fab0f719613d217b125e8e8763f0b74afd426e85f7e8a06271`；普通portal binding 22226/`5ceed688d9d7f408c0d7d039a6b90717e2fb789174dac18ea931a07d00b78167`。AT035冻结bridge 21537/`dee63d8f3c41c4dade074eda72a5eeaee3b6d9e46427b3ad3428e2479d9ecceb`、冻结TB 91807/`9d90afd50a9e1babcd058eb55e05baede95c5d3d1ed01a3e9959747ee555d4f0`。这些是只读定位身份，不代表新冻结实验清单或动态验证。
