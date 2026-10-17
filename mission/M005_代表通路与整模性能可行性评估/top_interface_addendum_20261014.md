# M005代表顶层：量化读债与固定G宽度接口决定

decision: D-M005-FEASIBILITY-01-A1
date: 2026-10-14（Asia/Shanghai）
owner: A001接口决定；A002唯一实现/验证
scope: M005 / SM006 / E006 / R001
implementation_status: 待实施与验证；不是硬件PASS

回复 `m005-top-quant-debt-interface-question-20261014`，同时处理 `m005-implicit-gate-k-finding-20261014` 和 `m005-at065-fail-semantic-down-admission-20261014`。本决定细化[现行M005阶段A](contract.md)，不另开mission、不增加工具次数或资源帽、不恢复普通Q/L生产控制。A002在现有预算内连续实现和受影响回归，无须再请求普通步骤批准。

## 1. 量化任务债与AXI读债必须由真实硬件闭合

接受工程提出的只读输出：在 `geglu_gate_quant_bridge_v1` 新增 `quant_task_debt_zero_o`，直接连接既有内部 `quant_task_debt_zero`。不改变量化计算、状态转移、外部Q/G仲裁或任务完成条件。既有 `read_debt_zero` 是fullA读取/返回债，含义保持，不能用它替换任务债。

最终代表top删除外部输入 `ln_physical_r_debt_zero`，在top内持续观察真实共享G/Q读主口 `g_m_axi_ar* / g_m_axi_r*`，构成源租约释放判据。不得依赖TB响应数组、TB计数、层次引用内部RTL或由外部调用者宣称已归零。

- 每次 `ARVALID && ARREADY` 记入 **ARLEN+1个beat**；先扩宽再加1，不能令255+1溢出。每次 `RVALID && RREADY` 才减一个beat。不能按AR次数、单独RVALID或RLAST直接清零。
- 现有feeder是单outstanding burst，64B/beat且不跨4KiB，所以实际burst不超过64beat。本次按这一真实支持范围实现剩余beat/在途状态；计数表示至少容纳ARLEN+1（可用9bit），用扩宽中间值检查溢出/下溢。无需增加多ID或多outstanding能力。
- 在途burst未结束时又受理AR、无对应债时受理R、RLAST与预期最后beat不一致或计数异常，置粘滞记账错误并禁止释放。异常路径不允许通过计数回绕或清零制造“已排空”。非OK RRESP仍遵循原任务错误处理，不能借错误响应抹去尚未返回的beat；本次不宣称生产恢复已通过。
- AR/R同拍组合必须显式、无算术歧义地处理；现有feeder不支持的组合可作为协议错误闭锁，不能静默漏记。按当前issuer核验单burst假设，不把这个有限监视器宣传为通用AXI interconnect。
- 计账连续覆盖共享读主口，不随LN/G阶段切换、任务受理或局部完成清零；仅冷复位清空。冷复位合同继续要求外部无遗留响应，本次不增加运行中复位/取消恢复声明。
- 保守释放条件为复位已解除、记账无错误、无在途burst/剩余beat、无待受理ARVALID及RVALID，并且 `quant_task_debt_zero_o` 为真。物理R全部返回而量化内部仍有输入/算术/返回槽债时不得释放；任务债归零而R尚未真实握手时也不得释放。

保留LN admission的 `ACTIVE→DRAINING→RELEASING`、held完整command及一次释放语义。用已寄存的实际握手事实判定归零，不用末R之前的组合预测提前退休；如新增监视器造成保守周期变化，在同top原日志测出，不冒称周期不变。目的地址、Context、Ref及原来源检查保持原合同，债归零不能替代身份正确。

## 2. G的K取实际固定硬件配置，不保留独立外部声明

已核当前bridge没有动态G cfg_K端口：向vector发出的 `cmd_k` 固定13'd2624，G自身量化路径的K也固定2624；LN外部Q的 `ext_quant_K` 属另一通路，不得混用。Wi输出宽度为5248，Down输入宽度为2624。

代表top将handoff的gate_k接到与上述实际实现一致的内部固定配置（例如 `localparam logic [12:0] GATE_K=13'd2624`），删除候选top独立的 `g_cfg_K` 输入。该固定配置是当前有限硬件身份的一部分，不扩展动态K能力、不放宽handoff `static_ok`。后续若实际G实现改为可配置，须再定义真实同边沿配置传递，不能保留两个彼此独立的声明。

下一版工作TB明确声明13bit gate K并由相同受支持配置驱动，打印/断言真实G接受边沿的K、rows和相应已锁存描述符。核验实际Wi N5248、G K2624、Down K2624的对应关系；共享matrix cfg可能已被改作Down，不能错误地在G边沿把共享当前N1024当成先前Wi的N。使用实际对应或已捕获的配置来源。不得用force、TB代做计算或更改gold获得PASS。

对新top、编辑后的TB和wrapper做有范围的声明、位宽、未驱动及四态检查；可使用局部 `default_nettype none` 并恢复，避免无关地改动全部历史生成RTL。AT065未声明g_cfg_K的冻结证据保留。

## 3. 受影响验证与冻结身份

在原static/短测累计预算内验证只读端口、真实burst计账与释放：AR等待、R中间/最后beat反压、物理读已清而内部量化未清、响应保持及仅一次消费/释放；加入小范围异常计账检查，证明不能错误释放。冷负例只覆盖本次新增监视逻辑，不铺开全局恢复矩阵。

K修正短测必须使用实际受控来源，检查G接受后held K为已知2624，逐项检查Down准入的受影响条件和真实接受边沿；AT064受控合法K不能代签联合链。完整正常/确定合法反压样本继续覆盖同top、同gold、实际存储交接、末B/物理债及655360B局部保护。

新状态输出、top计数器/故障位、固定K接线、LN shell及所有真实子实例必须纳入同一冻结功能/综合/route身份和资源统计。外部存储响应、fixture和调用者激励留在TB；新top尚未编译/验证/综合，不能提前标PASS。

## 4. AT065终态和剩余额度

主控核对原 `result_full.json`、guard和日志：AT065于2026-10-14 11:00:32 CST结束，2080.617893s，child0/trigger null，峰1036444KiB；原日志有Fatal、runner判FAIL，无CHAIN_PASS。采用工程交付的 **FAIL_SEMANTIC_DOWN_ADMISSION_UNKNOWN**。

cycle358880的Down W发布后，TB已过negedge并驱动cfg_valid；采样cfg_ready/ledger_ready/ledger_admitted/candidate_ready均1，但static_ok/matrix_valid为x。故本次确定到达受理前未知值断言，不是guard停滞。未驱动K是明确静态缺陷及X来源候选，尚不能声称是全部static_ok操作数中唯一根因。Down真实cfg受理/TMP写、末残差、最终gold和保护均未到；AT063旧停止记录不追写成此次Fatal。

AT065已消费M005新full **1/3、2080.617893/10800s**；已报短RTL48.884175/600s、static111.926796/5400s。原attempt不重启、不回写，剩余最多两次full优先最终同一可综合top正常/反压，每次仍须真实≤120s前缀与本次成本准入。新联合综合/route仍NOT_RUN；按原A→B依赖和总帽执行，不能换名追加。

依据：[AT065原full日志](../../project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT065_M005_down_boundary_observe_01/guard_full/driver.log)、[原结果](../../project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT065_M005_down_boundary_observe_01/result_full.json)、[bridge工作源](../../project/E002_Laya_HLS/experiment/vivado/module_design/activation_quantizer/rtl/geglu_gate_quant_bridge_v1.sv)、[候选top工作源](../../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_ffn_representative_top_v1.sv)。工作源可继续由A002修改，不能替代冻结attempt身份。工程已交付342条source引用及runtime三副本终态核验；本次主控没有重算其全部清单，不补称独立全量复核。

本决定只解除上述接口选择缺口。M005仍执行，阶段C v4条件预算与当前“不扩大串行路线投入”的建议保持；完整代表链及联合物理结果继续待验。
