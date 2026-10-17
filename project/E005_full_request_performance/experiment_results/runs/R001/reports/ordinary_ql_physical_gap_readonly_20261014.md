# 普通 Q/L 逐窗口来源：当前证据与物理缺口（只读）

2026-10-14；M003/M004、SM005/E005/R001；A002。此表只核对当前源码、冻结收据与既有[逐窗口合同](../../../../../../results/ordinary_linear_provenance_contract_20261012.md)，未修改 DUT，也未运行新工具。M003 新生产控制工作仍按当前重排停排；本记录供后继合同确定验收范围。

| 层面 | 已有证据 | 不能据此签署的部分 |
| --- | --- | --- |
| C 侧来源账本 | [source_provenance_06](../../../../../E003_production_chain_closure/experiment_results/runs/R003/source_provenance_06/receipt.json) 为 PASS：B1/B2 Attention、普通窗口、QKV pair、scorer 原地旧/新 epoch，含发布、重复/失败与旧租约边界。当前 `laya_full_owner.cpp` 的 `full_source_accept_completion` 在窗口所需分量首次完整时保存原 Context，`full_source_query` 要求已发布且所有窗口闭合。 | 这只是软件 metadata/退休；没有生成核实际 AW/W/B、逐窗口物理覆盖或真实 Q 的 AXI R。旧 `source_provenance_02` FAIL 保留，最新证据应引用 06。 |
| Caller/门户 | [portal_controller_25](../../../../../E003_production_chain_closure/experiment_results/runs/R003/portal_controller_25/receipt.json) 为 PASS：B1/S64 普通 P→Q→父 L、跨 stage producer Context 和四个 MATRIX view，受控 service responses。 | 没有数值 payload、持久 RTL hub、实际 Q/MATRIX 硬件或同 runtime 物理来源。 |
| RTL 来源 hub | [generated_source_lease_05](../../../../../E003_production_chain_closure/experiment_results/runs/R003/generated_source_lease_05/receipt.json) 为 PASS：单个 B1/S64、role6、TOKEN/F32 全宽 owner 的四个 rows16 窗口，各自 P；整 tensor 发布前拒绝，query/lease/drained release 与 generation 重读受控通过。 | query 是直接 sideband，物理观察为受控输入，未连真实 Q AXI 读取、caller 预约或多贡献 Attention/QKV/原地更新。 |
| 同 runtime 算术接点 | [AT040 LNF0](LNF0_four_row_rtl_result_20261014.md) 实测一个 LN_FFN 四行窗口：最后 B 后发布，Q 真实从写入地址读 256 R，fullA/lease 闭合。 | 不是四个或更多逐窗口来源，不含父 L；[AT035 QAR0](QAR0_shared_quant_admission_20261014.md) 的外部 LN 输入仍为预装存储，未接 AT040 的 hub/query。两份 PASS 不能拼接。 |

当前 [RTL hub](../../../../../E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_generated_provenance_hub_v1.sv) 的 `source_owner_supported`（349 行）仅接受 layout0、全宽、role6 等限定描述符；`source_window_event_ok`（367 行）要求每个 END 是一个完整标准窗口，`source_query_granted`（689 行）查该窗口 P 及整 tensor 发布。这与 C 侧可记录多分量 Attention/QKV、原地旧 epoch 的范围不同。源码比较是**静态边界**，不声称所有未支持路径都已跑出动态失败。

按原合同闭合普通 Q/L 时，仍须在同一当前身份硬件中证明：真实 producer 的逐窗口输出覆盖和最后写退休形成各自 P；整 tensor 发布独立于早窗口闭合；caller 的完整 P/Q/L、Ref、model 与 source query 同一任务绑定；Q 实际读租约/AXI 债务与 fullA 到父 L 的四 view 身份、完成和释放闭合。Attention 多 head、QKV pair/RoPE 及原地旧 epoch 的差异用例保留各自受影响验证，不能由 AT040 单窗口代签。当前 LN→QAR0 下一有限连接还需先解决[单量化器、真实地址与 portal 适配](LNF0_QAR0_readonly_connection_20261014.md)以及模型布局身份差异。M003/M004 与完整请求、联合资源、时序仍未完成。

只读文件身份：`laya_full_owner.cpp` SHA256 `0039a7424411ceb8166602df423b0231667d58f279eaa0323ac772887c30f5ae`；`laya_generated_provenance_hub_v1.sv` SHA256 `a735cae418e181fab0f719613d217b125e8e8763f0b74afd426e85f7e8a06271`；逐窗口合同 SHA256 `0a07853ea2dc3c6f95bea9bd13543c0be6073f008a119861933f7a6222694320`。
