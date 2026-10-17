# 门户 generation 生命周期补充

决定：D-M003-PORTAL-GENERATION-01；日期：2026-10-11；回复 `portal-generation-question-20261011`。

主控已核定，工程按原 M003/L1 授权连续实施。本文补充 [quant/G v2 合同](quant_g_portal_contract_v2_20261011.md) §3.3/§5.1，明确修正其中将持久 ticket 身份与单条 command generation 混写的歧义。采用**每 command 单调门户代号**，不改成请求或阶段共同代号；v2 wire 偏移、包长、单活动命令及原 13BO 均不变。本决定是接口/生命周期定义，不是实现 PASS。

## 1. 三个问题的直接结论

1. **是。** `command.GENERATION` 为 u64 非零门户命令代号，独立于 `NumericIdentity.generation`（session generation）、request_id、task_id、A/W/Buffer epoch。同一父 LinearTask 的四个 rows4 view 有四个不同、按实际提交顺序严格递增的门户代号。继续拒绝新命令 `g <= last_generation`，不放宽为同父可重复。
2. **持久实体与单命令分别绑定。** source/预约/父 lease 以完整 NumericIdentity、P/Q/L、相应 Ref/region、shape/slot epoch 识别；保存各实际 producer/consumer/view 的门户代号作为那条命令的来源/返回凭据。合法后继命令的当前 g 不需要、也不得被要求等于 producer g 或父任务首 view 的 g。caller 对预先保存的 command/view ticket 核验精确 g；transport 对当前 outstanding command 核验精确 g 和 v2 完整响应绑定。
3. **高水位跨请求、软取消和 session generation 切换保持。** 同 session、更大 request_id 可以正常恢复，但下一门户命令必须继续大于既有高水位。部分包只有第一拍完整握手且通过下述固定头校验，才取得可消耗的门户代号；不得从旧装配槽或未校验字节推进高水位。所有清理仍等真实 drain，不能因代号推进就复用有债务的槽。

## 2. 稳定实体键与命令键

持久实体键按操作归一化，不能直接比较四种操作的全部五 Ref 原始字节并要求相同：GEGLU.DST 是 GATE，QUANT.DST 是 A8，MATRIX.DST 才是线性输出。

对 G→Q→L 链，稳定绑定包含：完整 NumericIdentity；P/Q/L；quant-source Ref/region（GEGLU.DST = QUANT.SOURCE = MATRIX.SOURCE）；A/W/PS；future-linear dst/region；K/N/weight/bias/model 身份；A/W slot/epoch。GEGLU 的 WI source 另按其实际生产凭据检查。LOAD 的缓存生产绑定仍按 W Ref/epoch/model/descriptor 保存，LOAD 自己的门户 g 是来源记录，不是后续 matrix lease 必须复用的 g。

父 lease 保存完整 L 和上述链绑定、合法 view 序列/覆盖、真实债务、sticky error，以及各已执行 view 的返回关联。其创建者 g 可记录为 `origin_command_generation`，后续 view 到来时保持不变；另锁存当前 `active_command_generation`。禁止用覆盖父 origin g 的办法假装所有 view 是同一命令，或每换 g 就 release/reacquire 全 A。

单命令键为 `(g, service, CONTEXT, ROW_BLOCK, ROWS, 完整绑定)`。caller/transport 只接纳与当前 outstanding 键完全相同的 response；同父上一 view 的旧 response 即使 task_id 相同，也因 g/view 不同被排空或拒绝，不能累计 coverage/TaskDone。新 g 本身不授权实体操作：错 P/Q/L/Ref、重复/跳过 view、未生产的 source 仍须拒绝。

每条实际命令在接收/发射时锁存自己的 g，并用于自己的最终 response。会跨延迟返回的内部操作须绑定发射时的命令/slot/token 和原完整身份；不能在晚返回时读取“当前 g”替它重新贴标签。原 192bit 算术 tag 等既有数值接口不由本补充修改；可用有限外围命令账本和已有 tag/view/epoch 严格关联，且切换 view 前仍必须债务为零。

**不新增 future-G/Q/L/view-generation wire 字段。** caller 可提前持有全部命令代号；物理 hub 在各条命令到达时，从已有 GENERATION 字段取得其实际 g，并用稳定实体键、原任务次序和 view 覆盖检查是否是合法后继。物理侧未从 wire 获得的 future g，不得假称已经提前精确验证，也不得通过 task_id 算式推导它。一次只有一个活动命令、单调 g、完整实体绑定和确定的 view 次序共同防重放；无需把未来代号塞进剩余保留区。

## 3. 分配与预留

唯一 generated caller/dispatcher 为同一持久服务维护 u64 `H_alloc`（已分配最大门户代号），独立于 per-request `last_task_id` 和 typed Ref 的预约/claim 高水位。所有 LOAD/G/Q/MATRIX 命令共享此分配器。分配非零 g 时严格增加 H_alloc；允许跳号，不要求 transport 看到 `last_generation+1`。

采用工程建议：在已确定的有界阶段计划中，**为每条计划中的门户 command/view 保存明确的 g ticket**；已预约 typed task 与其 command tickets 分开存。一个 rows16 L 是一个 typed task、四条 MATRIX 命令。每个 view 的 ticket 至少记录 g、service、row_block、rows 和所属 L；不能只保存第一个 g 后用 task_id 推算其他代号。压缩存储允许保留一个经检查的已分配区间及显式 command ordinal/view 表，但必须可确定地还原该 ticket，不把 task 编号当 command 编号。

计划次序仍是所有 G → Down LOAD → 各窗口 Q、L 的各 view。正常 B2/S1024、128 个 rows16 窗口：typed task 仍为 385 个，门户 command 为 `128 + 1 + 128*(1+4) = 769` 条；这些是有界 metadata，不是 769 个活动槽或包。一般 rows1..16 的合法 4-row 加 1-row 尾部 view 数为 `floor(rows/4)+(rows%4)`，最大 6；若使用统一表，最多 128 项、每项六个 view ticket 加 G/Q ticket、一份 LOAD ticket即可，不能写死所有父任务都恰四 view。固定 shape 主路径仍按原合法 shape，不扩大模型范围。新增 metadata bytes/bits 计入资源。

实际提交顺序必须与已分配票据的递增次序相容；不能先发较大 g，再拿较小的预留 g 插入。原计划无关命令不插入活动父 lease；需要实际修改未发出的计划时，撤销未发 command ticket，再从 H_alloc 之上分配并保存新的有界计划，不重用旧 g。

**门户 g 一经分配就不回收，包括从未发送的 ticket。** 请求失败后丢弃未发票据的有效性，H_alloc 保留；新请求从其上方继续。因此 transport 可能观察到合法跳号。这个规则有意区别于原 v2 §3.3 允许在完整失效/drain 后按实际 committed high-water 重建的未激活 typed Ref 预约：后者仍依原 Ref/owner 规则，不能套用于门户 g。

u64 溢出在分配前拒绝，不回绕、不因请求初始化或更换 session generation 归零。若一次计划需 n 个新代号，先核 `n <= UINT64_MAX-H_alloc`。持久服务冷初始化从 0 开始；计数器耗尽后的重新初始化只能走全域安全卸载/冷启动，不能用软 reset 绕过。

## 4. transport 高水位、可信首拍与取消

### 4.1 两个状态量

推荐保留现 `last_generation` 的“已封闭命令高水位”含义，本文记为 `H_closed`，并显式增加当前帧的 `header_seen/header_trusted/active_g`（或等价有限状态）。`H_alloc` 属于 caller；`H_closed` 属于 transport，二者不必相等，也不依赖新增外部寄存器同步。

首拍与 packet 装配、service admission 是不同事件。首拍可信仅允许记录一个门户序号，**不允许 claim 数据 owner、lease、发 RAM/FP/AXI 或标记 typed task 已执行**。所有服务副作用仍在 16 拍整包与完整 v2 检查后。

在 `compute_cmd_write && compute_cmd_full_n` 且该帧 ingress_count=0 的时钟边沿，512bit 首拍包含固定头 `[0,64)` 的全部字节。直接从这次握手的 `compute_cmd_din` 校验并锁存，不等待 `cmd_pop/collect_count`，不引用可能尚未被本帧覆盖的 `service_command`。可信固定头要求：

- magic=CMD_MAGIC、VERSION=2、service=1..4；
- GENERATION 非零；TASK 符合已有合法 task_id 范围（非零且非保留溢出值）；
- COMMAND_BEATS=16、RESPONSE_BEATS=8；FLAGS_DETAIL=0，bytes `[28,64)` 全零。

其中 CONTEXT/NumericIdentity 不在首拍，完整检查仍在 CHECK；“header_trusted”不声称这些后续字段已可信。`active_g>H_closed` 才是 fresh；可信但 `g<=H_closed` 是重放，不能进入 service，也不提高高水位。第一拍的临时拒绝分类不可越过原完整 frame/错误优先级对 caller 提前返回成功。

可保持在完整 CHECK 时再执行现有 `g<=H_closed` 判断；同一活动帧期间 H_closed 不提前变成 active_g，避免把自己误拒。若工程等价地在 header 接收时推进已接受高水位，则必须另存旧高水位和本帧已获准标志，不能再把新高水位用于无区别的 `<=` 自比较。两者语义应与本节状态表一致。

### 4.2 何时消耗、何时可以复用槽

| 情形 | transport 的高水位 | 退休/副作用规则 |
| --- | --- | --- |
| 没有首拍握手（仅 VALID 或 cancel 同拍阻止握手） | 不变 | 不读旧 header，不产生 service 工作 |
| 首拍在 FIFO 内已握手、尚未 pop，随后取消 | 若首拍可信且 fresh，封闭时置 max(H_closed,active_g) | 私有 FIFO/装配槽安全清空；不得因 collect_count=0 漏耗已接受代号 |
| 首拍可信/fresh，后续包不完整，随后取消 | 安全封闭时消耗 active_g | 不要求补齐缺失拍，不伪造成功 response；旧私有数据清理完成后才接下一包 |
| 首拍不可信，例如坏 magic/version/长度/头保留位且带任意大 g | 不变 | 完整收到则沿原 ABI 失败响应，部分取消则丢弃；不能用该 g 污染高水位或制造计数器耗尽 |
| 首拍可信/fresh，整包随后因 Context/Ref/尾部保留位等失败 | 失败 response 完整消费或安全取消时消耗 active_g | 不到 service，不产生 typed claim/退休；失败也不能复用该门户 g |
| 合法包已发射 service，正常/数值失败/协议失败 | 完整 response 被 caller 消费后封闭并消耗 active_g | 沿真实 completion 与物理债务检查，不能提前释放槽 |
| 合法包已发射 service，活动取消或 response 尚未读完时取消 | 已接受工作安全 drain、旧 response 被清理后封闭并消耗 active_g | 接受过的 R/B/FP、半事务与 held returns 仍记账；不因 cancel 清债务 |
| 可信重放 `g<=H_closed` | 保持 H_closed | 原拒绝，不计新 service accepted；不能用更换 request_id 或 parent 标签赦免旧 g |

首拍在 FIFO 等待、同拍 pop/取消、完整包刚到 CHECK、response 最后 pop/取消竞争均须使用当前帧的已锁存信任状态。每次帧清理都清 `header_seen/trusted/active_g` 有效位；COLLECT 中 `service_command` 残留字节不是新帧证据。

`accepted_commands` 仍按真实 service_command valid/ready 计数；首拍握手或消耗 g 不增加它。`retired_responses` 沿原 caller 完整读完统计，不为被取消丢弃的响应虚增。g 消耗、命令 admission、typed TaskDone 是三类独立事件。

### 4.3 已确认的现实现缺口

R003/transport_v2_01 冻结的 `laya_compute_portal_v1.sv`：

- lines 91–96 正确保留每 command 的 `g<=last_generation` 拒绝。
- lines 67–71 取消只检查 `collect_count!=0` 后从装配槽取 g，没有可信首拍记录；无法区分坏 header，也覆盖不到“首拍已 push 但未 pop”的取消。
- lines 80–86 在完整 response 退休时无条件取包的 g 推进高水位，即使该响应源于坏 magic/version 的包，也可污染高水位。正常退休路径与取消路径都应按上表修复，不能只改 cancel 分支。
- line 65 `rst_n` 清高水位只适用于下面定义的安全冷初始化，不能让活动请求 reset 绕过持久单调。

既有 transport_v2_01 PASS 仅证明当时受控 service 端点的已覆盖用例；TB lines 171–174 为三拍部分包取消，没有证明上述新首拍边界/坏 header 规则。保留其历史 PASS，不把本补充记成该测试已覆盖。

## 5. 请求切换与 reset 域

一个常驻 service 从安全冷初始化到安全卸载期间，H_alloc/H_closed 跨 request_id 和 session generation 保持。请求失败/软 reset：取消活动命令与依赖 parent/source bindings，drain 所有真实债务，清私有 FIFO/旧 response，按可信首拍规则封闭当前 g，撤销剩余 command ticket；新的合法请求使用更大的 g。typed task_id 仍按原 per-request 规则初始化，已 claim Ref/slot epoch 不回退。因提前预约而未发送的 g 只在 caller 高水位中烧掉，transport 接受之后的跳号。

跨 view 间隙可能 `transport.busy=0`，但 parent A/W pin 仍活动；取消必须传达到持久 parent/source 账本并安全释放，不能仅用门户busy门控整个取消域。此时没有新帧，H_closed保持，不能从残留service_command消耗代号。现transport line49的`cancel && busy`只能描述单条命令，生产hub还需覆盖该跨命令持久状态。

新 session generation 同样不能将 portal g 置零。当前 wire 的 `NumericIdentity.generation` 与 command.GENERATION 必须分开保存/比较，绝不能简单赋同一个值。

若外部要求活动 reset，应映射到现 cancellation/drain 域，或把门户高水位状态放在不被该软 reset 清除的域；不能在有债务时直接拉低实际清零计数器/FIFO/slot 的冷 reset。`rst_n` 清零只允许整个有关 caller、transport、service 和互连返回路径已安全结束/隔离、确认不存在可回来命中当前 runtime 的旧 R/B/FP/response 的冷启动。不能仅凭 physical_debt_zero 的局部一拍就推断全系统可以冷复位。此处不新增 ABI、硬件工具或上板授权，只明确原 active-reset 安全合同的计数器生命周期。

## 6. 受影响验证与下一步

工程继续 v2 caller/有界预约/G 分期/父 lease，实现本补充需要的有限 metadata 和高水位保护。在原资源帽内补充以下真正区分问题的用例：

1. 同一 NumericIdentity、同一 rows16 L，四 view 使用不同 g，保持一次真实 A parent lease 和一次 typed TaskDone；旧 view response 插入下一 view 时不得退休下一 view。
2. G、Q、L 与 LOAD 各用不同 g，source/parent binding 按归一化实体匹配；同 g replay 即使换 request/task 也拒绝，新 g 但错误实体/重复 view 也拒绝。
3. 取消覆盖：无首拍握手、仅首拍 push 未 pop、可信部分包、坏 header 部分包、完整包 CHECK/ISSUE、在途 service、部分 response 及两个 view 之间的空闲门户/活动 parent pin；确认高水位、FIFO、实际 lease/debt、accepted/retired 计数各正确。
4. 坏头中伪造超大 g 后仍能执行下一个正常 g；可信头加错误包尾则消耗其 g，重放被拒。验证正常失败 response 退休和 cancel 两条更新路径。
5. 同 session、更大 request_id 以及新 session generation 的恢复均继续门户单调；撤销未发送预约后允许跳号；软取消不回退 H_alloc/H_closed，u64 分配溢出不回绕。

不要求重跑未受影响的独立算术或 LOAD 数据通路来证明生命周期定义。当前 LOAD native/v2 codec、matrix 单 view 的局部验证按各冻结范围继续；完整父视图/请求恢复只有新增对应证据后才能宣称通过。保持单重工具与所有原预算，G OOC 余 2338.224019s 不重置；本轮主控未启动任何工程实验。

## 7. 核查身份与修订记录

问题已送达主控：`portal-generation-question-20261011`；工程 thread `01a129af-29ef-7102-b86a-a43995a36279`。证据：R003/transport_v2_01 的 frozen transport/layout/TB、input_manifest.json 与 receipt.json；本次核查身份见 [证据清单](portal_generation_lifecycle_evidence_20261011.json)。5 份 frozen source 的 SHA 与其 manifest 相符，receipt 中 manifest/driver log SHA 相符；这是只读核查，不扩张测试结论。

此前 quant/G 合同原文存于 [修订前副本](history/quant_g_portal_contract_v2_before_generation_clarification_20261011.md)，SHA256=`234f0f331cdd3a5f2f9daada1f5105f12c51f15f209870a164eb3f4d5ac7cdc6`；原 `quant_g_portal_contract_v2_evidence_20261011.json` 的 contract_sha256 对应此副本，不再代表修订后入口文件。原答复/通信回执不改。本补充优先于旧 §3.3 对 portal generation 的含混表述，其余 quant/G 合同保持。
