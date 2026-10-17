# M003：generated 非门户 producer 的物理 Context 绑定缺口

消息 ID：`generated-source-binding-question-20261012`。工程在既有 M003/L1 授权内请求一个具体生产接口决定；不请求新增成本或扩大外部 ABI。

## 已核实现状

当前内部 C top `laya_typed_q8_forward_controller` 的实际源码接口只有：

- 原 13 个 BO 对应的 13 路 generated `m_axi`；
- 原 `s_axi_control` 与 `s_axi_control_r`；
- 私有 `compute_cmd` 输出 FIFO 与 `compute_rsp` 输入 FIFO。

工具探针 `portal_fifo_probe_04` 已实际生成并冻结六个 FIFO 信号，receipt 为 `project/E003_production_chain_closure/experiment_results/runs/R003/portal_fifo_probe_04/receipt.json`。当前 top 没有 generated `TaskDone`、producer Context、typed Ref、窗口 coverage 或 request NumericIdentity 的独立物理端口。`portal_controller_11` 已冻结当前完整 C++ closure，证明 caller 会在后继 QUANT 命令中携带 P/Q/L 与 source range，但该受控服务测试不提供物理 producer 事件。

外层现在可以做到：

1. 逐 BO 统计 generated controller 的真实 AR/R/AW/W/B 债务；
2. 按物理地址记录某 source 窗口的实际 WSTRB/末 B 覆盖；
3. 在收到后继 QUANT command 时核其 P/Q/L、source Ref、BO role/offset/span/stride 与已写物理范围；
4. 只在 generated owner 的相关 AXI 债务为零后切换给物理 service。

但外层在 producer 写发生时看不到该写对应的完整 P Context/Ref/NumericIdentity，因此无法证明“这些物理写就是 command 所声称的 P”，只能事后把地址覆盖与 C command 的 P 关联。D-M003-ORDINARY-SOURCE-PROVENANCE-01 又明确禁止把 C READY 或布尔 echo 直接当作物理 source 成功，并要求实际 generated 非门户 producer 身份绑定到物理 ledger。

## 需要主控决定

请确定下列生产绑定中的一项，或给出等价的既有合同机制：

1. **允许地址覆盖后绑定**：在单 generated owner、严格任务顺序、相关 BO 全部真实末 B、全 owner debt=0、source range/shape/窗口完整匹配的前提下，后继 QUANT command 的 P/Ref/NumericIdentity 可把这份尚未命名的物理覆盖原子命名并冻结；必须拒绝重叠、额外写、错范围和复用。若允许，请明确足以防止错 P 的顺序/唯一性条件。
2. **新增内部 provenance sideband**：给内部 generated controller 增加私有、Host 不可见的固定 TaskDone/provenance FIFO，外层以其完整身份绑定已观测物理覆盖。请冻结字段、深度、生产时机和取消规则；这会改变 §3.9 当前“两条私有 FIFO”的内部接口。
3. **使用现有门户的显式 publication 命令**：若要通过现 cmd/rsp FIFO发布非门户 producer，请明确 service/op、字段映射和任务/command计数；现合同禁止新增第五 service/publication typed op，工程不会自行发明。

仅靠现有端口无法同时满足“完整身份物理绑定”和“禁止地址后绑定/禁止新 sideband”两项。工程会继续控制面、LOAD/G/Q/MATRIX 独立服务封装、AXI 债务和原 ABI工作；真实 ordinary producer→QUANT 的物理身份验收在本答复前保持未闭合。
