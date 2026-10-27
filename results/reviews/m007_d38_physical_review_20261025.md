# M007 D38：完整生产顶层物理结果集中审核

审核日期：2026-10-25；2026-10-26 接续 AT015 集中审核。审核者：A014，派发配置 `gpt-6-astra/xhigh`；本记录不声称独立核实服务端实际 runtime 模型身份。范围：SM012 D38 / E022 R001。实现与运行唯一 owner 为 A010；A014 只读源码、工具文档和原始证据，不启动 EDA，不改 RTL/Tcl/XDC/合同。本页为本阶段持续复用的集中审核记录，不增加逐尝试放行门。

## 当前判断（AT015 六小时实际结果，2026-10-26 更新）

**AT015 已实际运行六小时，在综合内部 Timing Optimization 阶段触发原单次 21600s 墙钟帽，未生成 DCP。此次不是内存停止：owned 峰值 110.976433GiB，未触后来生效的 256GiB；最低 MemAvailable 343.694820GiB，高于 192GiB。** 工具确已完成 RTL 展开、面积优化并进入时序优化，比 AT014 有实质进展，但无完成比例、ETA 或时序优化完成标记，不能说“快完成了”。现已无原 owned 进程，无可支持原次恢复的 DCP；若继续，只能是新尝试。

当前仍未得到完整顶层综合网表/资源分项，P&R 和 setup/hold 为 NOT_RUN。原始 Python receipt 保留 FAIL/-9、trigger=null；外部监督原始触发与合并收据明确 `original_stage_or_category_deadline`，所以集中判定为 COST_STOP，不能误报工具功能失败。f849 源与 manifest_v3/bottom_up_v6 保持，原 D37 与已验 operand 等价桥范围不扩大。

**唯一推荐下一步：同一 f849 核心、同器件/参数/OOC/flat none/单worker，单独增加官方 `synth_design -no_timing_driven`，以实际网表和资源为本次直接产物。** 依据是本次已完成前段处理、随后约 2h28m 停留于综合时序优化；本机 Vivado 2025.2 文档明确该选项关闭综合内部时序驱动算法并降低综合运行时间。保留原 3.333333333ns XDC、完整时钟/内部路径，后续真实链接、实现和 STA 仍按 300MHz 验收；该策略可能降低映射质量，不代签时序，也不改变 RTL 数值或周期。

综合已用 26321.033669102s / 43200s，余 16878.966330898s。主控采纳仅此一次 core 策略尝试，守卫沿原规则取 min(21600s, 实际综合余额)，当前为 16878.966330898s，不另加更低帽；这不是承诺剩余足够完成完整 top。维持现有 256GiB/192GiB余量/CPU0–3/低优先级/单重工具保护。不恢复旧 PS 候选，不改 RTL，不同源原配置盲重跑，不扩预算。本页旧 24GiB 和 PS 准入条件仅保留为历史，已被用户后续预算授权覆盖。

## AT003 后提出、AT005 已执行的原源码方案

当时唯一建议是以原 RTL 自然模块串行 OOC 产生可复用 DCP：先 `laya_m007_matrix_engine_v1`（`PROFILE_ENABLE=0`，原 dot_array/format 子树保留），再 façade、resident、完整 parent 链接和实现。依据是 AT003 的完整父约 13.54GiB 与 worker 约 9.81GiB 同时驻留。该假设合理但未经验证；AT005 现已表明首个独立核心仍不能完成。下面保留原流程与最终链接验收要求，作为实际已尝试方案和后续新源若通过局部等价后的可复用流程，**不构成继续同源重跑指令**。

不推荐仅把完整顶层的 `flatten_hierarchy rebuilt` 改成 `none` 后重新整轮执行；AT005 已使用 `none` 仍达到内存帽。工具文档说明 `none` 保留层次并限制跨层次优化，不承诺降低内存或修复存储推断问题。也不推荐增加内存帽、隐藏工具参数、将局部数字相加、最终留黑盒或改变生产功能来取得表面通过。

## 已核实的实际证据

证据根：`project/E022_m007_full_top_physical/experiment_results/runs/R001/`。

| 项目 | 实际事实 | 判定范围 |
| --- | --- | --- |
| 冻结生产源 | 91 源及 ROM 闭包；source_manifest SHA256 `21e3c7a326056c62b56ed1e739b3913005d7207731d8d1a0f0bac4b5fef5d113` | 当前物理输入身份 |
| 生产顶层 | `laya_m007_single_parent_v3`，SHA256 `9d87721737ceea74e47f565321ed83a625abae89931287d8a002d4f8e1534db6` | 复用 D37 已验源码 |
| 有效参数 | `input/physical_configuration_v2.json` 绑定全部 11 generic，SHA256 `7333c74a81c9422e3287d3e3a18ce986a8833b4803d32bebd2d35a1fcf19b3c4` | 正式 VERIFY=0、有效地址 profile/跨度/平台身份 |
| AT001 | 工具、器件与依赖预检 PASS | 不代替综合/资源/时序 |
| AT002 | 错误默认平台 generic；126.709649772s 后 owned RSS 达帽 | 保留 COST_STOP；该配置会拒绝 setup，无完整核签署资格 |
| AT003 | 正确全部 generic，general.maxThreads=1；709.993409556s 后 owned RSS 达帽 | 完整综合 COST_STOP，无 DCP |
| AT003 RSS | 收据峰值 25,479,056 KiB = 24.298721GiB，含采样停止延迟 | 软件运行成本，不是 FPGA 用量 |
| AT003 清理 | `owned_after_cleanup=[]`，源身份复核 true；1 个短命身份政策未观测 | 不把未知项改写为通过 |
| AT004 | 实际工具参数只读查询 PASS，8.089555168s | 无新增综合/实现结果 |
| AT005 | 原 matrix engine、PROFILE=0、flat none、无 stub；868.242573546s 后 RSS 达帽 | 独立核心 COST_STOP，无 DCP |
| AT005 清理 | `owned_after_cleanup=[]`，源身份复核 true；1 个短命身份政策未观测 | 保留实际未知项 |
| AT005 收尾时综合累计 | AT002/AT003/AT005 合计 1704.945632874s；原 9000s 帽剩 7295.054367126s | 余额存在不代表仍有依据继续同源试跑；新源综合后由原账本继续扣减 |
| 布局布线 | 未开始 | NOT_RUN，原因是没有完整综合网表/DCP |

原始入口：`attempts/AT003_synth/receipt.json`、`vivado.log`、`frozen/full_top_d38.tcl`、`frozen/full_top_d38.xdc`；收据 SHA256 `9acb9e9a90084235d16a1fd70f01fb343713d3b3271a759bb6dbb559286d3eaf`。AT003 的 `done synthesizing module` 日志只证明对应 RTL 处理阶段已到达，不能当作最终综合 PASS。

## 峰值定位：实际证据与推断分开

AT003 的真实收据政策样本同时存在完整父 Vivado 约 13.536751GiB、`parallel_synth_` 约 0.505016GiB、实际映射子 Vivado 约 9.809513GiB。`general.maxThreads=1` 已限制为一个 synthesis worker，但并不表示只有一个驻留进程。把单个自然子树放入独立进程，可以释放原完整父设计的无关中间表示；这就是下一方案的可检验依据。具体可释放多少、单个模块及最终链接是否能过 24GiB，目前 UNKNOWN。

更具体的原始证据来自隐藏工具日志：

`attempts/AT003_synth/work/.Xil/Vivado-2891801-user/realtime/tmp/78A22E40.rtd.pb.log`

其相邻 `.rtd.tcl` 明确 `genomeName=laya_m007_matrix_engine_v1`，执行 `rt::sequential_dfg_opt_pass1`。日志报告：

- `[Synth 8-5856] 3D RAM op0_reg ... is not supported ... most likely ... registers`。
- `[Synth 8-11357] ... op0_reg with 524288 registers`。
- `op1_reg` 同样 524288 registers。

冻结 `input/rtl/laya_m007_matrix_engine_v1.sv:124` 的 `logic [63:0][255:0][31:0] op0,op1` 与该位数相符。L194 为异步寻址读取；L326/L332/L359 对 op0 有不同事件的写入；L326/L335/L354 对 op1 有不同事件的写入，且同周期的条件和顺序优先级是语义的一部分。这里不只是“一维/二维声明写法不同”：未经证明的单/双口同步 BRAM 替换可能改变端口并发、读延迟、写冲突优先级及握手周期。**这份日志支持存在昂贵展开路径的判断，不是已映射 1,048,576 FF 的最终利用率报告。**

另一个明确问题为 `input/rtl/laya_m007_matrix_facade_v2.sv:198` 的 canonical bias 存储：288×64×32 = 589824 位；L220 动态半组部分写，L224 同步整组读。AT003 `[Synth 8-7186]` 报 `ram_style="block"` 因 usage 忽略。这具有更简单的等价分银行表达候选，但仍为生产源变化，且单修它不消除上述 operand pool 问题。两处存储位数均不得直接列作最终 FF 数。

工具保存的中间文件还显示 `laya_attention_qk_av_engine_v1`、matrix façade 有较大的 RTL 中间表示；文件大小只能提示后续分区关注点，不能换算 RSS、LUT 或 FF。

## 串行 OOC 的最小实施与保真条件

1. **先原 matrix engine。** 独立新 Vivado 进程读取冻结原源，仅以 `laya_m007_matrix_engine_v1` 为 top，显式 `PROFILE_ENABLE=0`，器件与 3.333333333ns 时钟不变，OOC、单 synthesis worker、原 24GiB owned-tree 保护及全项目锁。原 `dot_array` 和 `format` 子树必须真实综合。成功立即保存源绑定 DCP 和实际利用率/存储/黑盒报告；退出进程释放内存。该项是下一唯一首选执行，不先跑完整 façade 或再次重跑 full top。首项仍须接受原总预算及单次上限，不能用“分区”重置额度。
2. **再沿自然父子关系装配。** 原 matrix façade 以真实 engine DCP 替换中间综合 stub；参数必须逐项绑定 `PROFILE_ENABLE=0`、`CANONICAL_MODEL=1` 和 `CANONICAL_MODEL_ID=64'h9db40381604108af`（即原 top 的 `MODEL_ID[63:0]`，其 MODEL_ID 来自 `MODEL_SHA256[255:128]`，不能误取整个 SHA 的低 64 位）。resident 子树保持其原参数及全部真实共享资源、workspace 和银行；特别注意 `laya_m007_resident_joint_v3.sv:481` 在端口声明之后还有 body parameter `TANH_FORCE_CORE_CE=0`，仅机械截取 module header 不能当作完整参数检查，父未覆盖，本次 OOC 也固定 0。若实际局部证据显示有必要，可继续在既有自然子模块边界拆分；这属于同一串行流程，无需新建逐尝试审核门。不得人为拆割/改写 operand array、修改 control q/next 组合接口或增加流水延迟。
3. **原生产顶层综合和完整链接。** 使用与真实子 DCP 对应的端口声明构造仅供综合使用的临时 black-box stub，或采用等价的标准 OOC 引用方式；不得覆盖生产 RTL 或冻结包。stub 只允许留在中间装配阶段，不承担任何行为；所有动态输入、参数和连接位宽/顺序与原例化一致。保存分区→实例路径→参数→源闭包→DCP SHA 的映射，`read_checkpoint -cell` 将真实子网表填入正确实例，最终完整 DCP 中黑盒必须为 0。
4. **只在完整链接后的实际设计报全核用量。** 对链接网表做原定 opt 和报告，保留所有跨分区 net；检查被裁剪资源是否为合法原连接优化，尤其完整 matrix、FP256、DIV8、EXP/TANH、H/QKV/context/PS/G/type/bias、父控制及 AXI transport 路径。matrix engine 在 façade 中以 `.*` 连接，façade 的内部 `trace_*` 线不能因 stub 省略而悄悄改变连接；子 OOC 保留完整端口，到完整设计 opt 后可以裁剪原父本就未用的观察逻辑。不得增添 DONT_TOUCH 强制保留本应裁剪的 trace 造成资源虚高，也不得为降低资源主动删除生产公开 trace/check。分区汇总仅作定位，完整资源值必须出自完整链接设计的 `report_utilization`/RAM/层次报告。OOC 保留边界可能牺牲跨层次优化，应在结果中标明综合策略差异。
5. **从同一完整 DCP 连续实现。** 按 D38 原顺序 opt/place/phys_opt/route，逐阶段保存 DCP。完整连接后若资源超过器件/合法性检查不通过，保存实际工具错误和用量，停止无法成立的 place/route；不可禁用合法性检查换取“成功”。若只超过用户核预算但尚合法，报告预算 FAIL，仍依合同和剩余预算推进可行的物理验证。

以上改变为综合调度及网表装配变化，保持生产源/接口/数值不变；D37 原正常路径 PASS 可以按原身份复用，不重跑完整 30 层。标准综合工具的网表生成可信边界仍须明确；若出现 RTL 改动则不再属于该复用条件。

## 时钟与完整物理验收

- 叶子 OOC 的 clk 只作局部真实同步时钟，不能在每个分区额外插入独立根时钟缓冲。最终裸核只保留明确的一套根时钟/必要标准时钟缓冲；检查导入 DCP 后的 clock 与 scoped XDC，避免多重 `create_clock`、多余 leaf IO delay 或例外残留。是否需普通 BUFG 适配由实际实现工具报告决定并记录，不改数据通路。
- 最终完整连接设计中的跨分区 reg-to-reg 路径必须参与 STA，不能由于 OOC 分区把它们降格为“平台未知 IO”。只有最终裸核公开接口的真实 shell IO/CDC/板级约束缺失可标为未约束边界。
- 当前 XDC 仅 `create_clock -period 3.333333333 [get_ports clk]`；无显式 uncertainty、IO delay 或 reset exception。零/工具默认 uncertainty 是当前建模假设，不是已获得真实平台预算。导入后的实际时钟、uncertainty、例外和未约束路径都要检查并报告。
- 对完整网表检查 0 black box、无意外 latch/多驱动、完整功能层次和全部内部端点计时；最终同一 routed DCP 报 route status、setup WNS/TNS、hold WHS/THS、违例数、关键路径及 DRC/拥塞。
- 只有合法完整 route、所有内部路径约束完整且 setup/hold 均通过，才能签“当前 OOC 裸核内部 300MHz 时序 PASS”。不能外推真实 shell、HBM/PCIe 接口、上板或端到端吞吐。

## 成本出口与源修复边界

若单独 matrix engine 仍触发 24GiB 或预算帽，保留其真实失败边界；不得原样加帽重跑。届时结论为“当前生产存储/算术 RTL 的单自然模块综合仍超本阶段软件预算”，完整资源/实现继续 NOT_RUN；不是已证器件超容。进一步拆分原有算术子模块只有在实际证据表明可减少驻留且检查点能复用时才有意义；把同一巨大 packed state 换层次外壳没有新依据。

canonical bias 的静态银行化、operand pool 的等价展开或存储组织调整一旦改生产源码，必须保存 diff/新身份并做受影响局部等价或回归。等价必须保留所有有效读写、相同周期响应、同时事件优先级、reset/invalid/uninitialized 行为边界以及背压、取消、清退；不只比较一条正常样本。可用原冻结实现作为局部对照，但不得更改独立 gold/容差或省略受影响错误路径。原 D37 结论仍属于旧源身份；不能仅凭新版本综合完成将其改签到新物理版。需要新增端口仲裁、延迟或资源职责时属于实质架构变化，交主控集中处理受影响合同。

## 所用标准工具依据

只读核本机 Vivado 2025.2 文档，未为本次审核启动工具：

- `/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/doc/eng/man/synth_design`：OOC、flatten_hierarchy、generic 的 top-only 覆盖范围及 maxThreads 含义。
- 同目录 `read_checkpoint`：`-cell` 向当前设计的指定 black-box 实例加载真实检查点；`-incremental` 不能用于合并网表。
- 同目录 `link_design`：链接网表与约束，OOC 模式避免内部宽口占用封装 IO，并维持端口逻辑的实现语义。

后继实际 OOC、完整链接与物理结果在本页追加集中审核；当前尚未签资源或时序通过。

## AT005 实际失败后的集中审核（2026-10-25）

### 运行身份和资源事实

本次实际命令由 `attempts/AT005_core_synth/vivado.log` 明确记录：

`synth_design -top laya_m007_matrix_engine_v1 -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy none -generic PROFILE_ENABLE=1'b0`

`input/bottom_up_configuration_v3.json` 的 core_synth `stub_modules=[]`、`expected_blackboxes=[]`；冻结流程据该列表读取原生产源，原 dot_array/format 的全部子模块在实际日志中出现。没有用 stub 代替核心内部算术。engine 源 SHA256 `2147d041620a158cf7f2cddfd172b538e54ba78c5d340507a8c5ce08cfff069f`，冻结生产闭包未改。收据的 `source_identity.top` 仍描述整项根生产设计，**本次实际运行 top 以上述命令和 bottom-up stage 配置为准**，不误当作完整 top 再次综合完成。

收据 `attempts/AT005_core_synth/receipt.json`（SHA256 `427f6201b409c60b7abf5845c9a35d7d9467699ba3c85005b550640991afe356`）记录：

- elapsed 868.242573546s、exit -9、verdict COST_STOP、`owned_RSS_at_or_above_24GiB`。
- peak owned RSS 25,380,228KiB；809 个 guard 样本，最后触发样本 elapsed 866.120308654s。触发到收据的清理时间并非新增计算阶段。
- `guard_trigger.json` 停止快照中主 Vivado PID 2907497 占 24,840,628KiB = 23.689868927GiB；helper 529,320KiB，另有小 launcher/loader，总计 24.209712982GiB。没有 AT003 那样约 9.81GiB 的第二映射 Vivado。收据内较早 policy sample 的主 RSS 不能误当作触发峰值。
- minimum MemAvailable 469,152,764KiB，停止原因不是整机空闲内存不足；政策与原 24GiB owned-tree 上限保持。
- `owned_after_cleanup=[]`、`source_verify_after=true`。PID 2907643 是未观测到完整政策样本的短命身份，保留 UNKNOWN。

### 对根因的证据强度

主日志现在直接包含 `op0_reg`、`op1_reg` 各 524288 registers 的 `[Synth 8-11357]` runtime 风险警告，以及 format 的 `aligned_reg` 32768 registers。两组大状态的实际源位置、读写端口和同时事件均已核对。AT005 隐藏目录只有根运行脚本及工具元数据，没有 AT003 的 per-worker `.rtd.pb.log`；因此不能声称从不存在的子日志或堆分析证明每一字节的归属。已取得的结论是“巨大多维、多端口核心状态是直接可见且需要处理的综合表示瓶颈”，不是“已严格证明它是唯一内存来源”。

核心内只有 `dot_array` 和 `format` 两个自然算术子模块；原 op0/op1 位于核心本层，不在这两棵子树中。继续把它们单独做 OOC 可能取得局部算术 DCP，但不会消除核心本层相同的 1,048,576 位多端口动态写入表示，也没有新测量证明能把核心剩余映射降到 24GiB 内。`format/aligned` 的已报警位数仅为 operand 两组总位数的 1/32，此比值不是内存占比；不能据此给出肯定或否定的 RSS 换算。核心独立 OOC 还保留原公开 trace 输出，可能比最终父原本未用的观察逻辑多，但不得无证据假设裁剪一项 trace 就足以解决根因。

**没有可据当前证据推荐为下一次完整物理执行的、更小原源码自然边界方案。** 这不是数学上排除所有工具策略，而是原预算内缺少进一步重复试跑的新可检验依据。当前实质阻塞足以报告：原生产设计在本机 Vivado 2025.2、原 24GiB 保护内，连矩阵核心 OOC 也无法产生 DCP；完整资源、布局布线和时序仍未取得。

### 最小生产源修复候选与准确语义

主控接续已选定唯一最小修改：仅在 `laya_m007_matrix_engine_v1` 将 op0/op1 声明改为 64 个 unpacked 槽，每槽仍为原 packed `[255:0][31:0]`；以 `genvar slot=0..63` 建立静态左值 `op0[slot]`、`op1[slot]` 的 always_ff 和原写地址比较，独立 if 顺序保持原同槽优先级。只把原六类数据写从控制 always_ff 移出，pool_state、数值/协议检查、所有控制与原异步读表达保持。op1 的 PS 更新沿原 16×16 lane 映射，不新增整个 tensor 副本、新模块或新延迟。此为生产源变化，必须记录新源身份，不把旧自然边界流程的身份沿用到新源。

该修改目的仅为避免综合器构造巨大多维动态左值的中间表示，**不宣称自动得到 BRAM、不减少逻辑状态位数，也不保证最终 LUT/FF/时序达标**。所有控制和 FP/INT 算术叶、pool state、slot 数、lease/debt、父接口保持不变。尽量保留现有异步读的索引表达；若显式构造 mux，必须检查未知索引的四态行为，不能用 default 0 悄悄替代原 X。

必须逐项保留的写更新关系如下；表中的条件均还受原 `rst_n` 分支约束，不能只复制数据源而丢掉原作用域：

| 状态 | 原事件与位置 | 对同一槽的原优先级（高到低） |
| --- | --- | --- |
| op0 | L326 format；L332 mul response；L359 non-bias add response | add response > mul response > format |
| op1 | L326 format；L335 首组加法操作数置零；L354 math PS response | math PS response > 首组置零 > format |

- format/mul/首组置零在原 `state==RUN` 作用域内；PS response 和 add response 更新在该作用域外，但仍在 `rst_n` 正常分支内。不能因“正常路径只在 RUN”假定而移错条件。
- 不同槽的多个写入必须同拍全部生效；不能以全局 `if/else if` 串行化互不冲突的槽。同槽冲突保留原非阻塞赋值的最后写优先级，即使该冲突同时触发 protocol fault，也不能依赖“协议应该禁止”而删去原行为。
- op0 的 mul/add/PS-write/trace 异步读及 op1 的 mul/add 异步读，地址、位序、使能边界与可观察时刻不变；同沿写入前后的读值须和原实现一致，不引入同步 RAM 的一拍。
- 原 reset 不清零 op0/op1 数据；它清理控制/有效状态。不得增加数据 reset，也不得在 reset 时执行原来没有的写入。新 always_ff 外层保留原 `if (!rst_n) begin /* 不写数据 */ end else begin ... end`，不要简化为 `if (rst_n)`：rst_n 为 X 时，两者的 Verilog if 分支语义不同。
- PS response 到每 lane 的 `512*tag[28]+32*a+16*tag[16]+c` 映射、lane `16*a+c`、256×32 的打包顺序须逐位保留。PS 槽地址为 `tag[18:13]`，其中 `tag[16]` 正是槽地址 bit3；TB 必须由同一完整 tag 派生两者，不能把槽和 bank-half 当作无来源独立输入。写前有效性/无效输出行为边界不扩大。

局部等价至少要覆盖：任意初始存储状态、64 个槽、全部写事件组合、同槽/异槽碰撞、有效/无效/取消/清退边界、读写同拍与复位前后；对外握手和数据应逐周期、逐位相同。可以在独立冻结旧实现与新实现间建立局部等价 miter，按任一槽/lane 的状态映射证明一步更新及组合读取，再覆盖 lane 和 PS 位序连线；不能以只验证新实现自己的写入结果替代等价。随后以原真实局部矩阵用例、原独立参考及受影响背压/取消测试确认集成，不需要重复未变的完整 30 层长跑。验证工具/成本须由主控在现行阶段受影响边界明确记账，不私自挪用实现预算。

### 已派发接续的可核等价方法

1. 从原冻结 `R001/input/rtl/laya_m007_matrix_engine_v1.sv` 和实际改后生产文件机械抽取存储声明、全部相关写语句及实际嵌套条件、全部原异步读取表达；保存抽取器、源 SHA 和来源行映射。不得手写一个简化“旧存储模型”再用它代替旧生产源。抽取保留 `state==RUN`、原 reset 外层及真实 valid/ready/tag 条件；若把组合条件作为测试输入，须明确对应的原表达并由同一输入构造，不将 storage 范围偷换为 full-core 等价。
2. 旧/新实例在同一 TB 接收相同完整 tag、数据和控制条件；比较两组全部 `64×256×32` 状态和原 mul/add/PS-write/trace 的异步读结果，覆盖时钟沿前及 NBA 更新后的值。初始化通过真实 format 写遍 64 槽，不用直接覆写内部数据掩盖初始化/写寻址错误；已初始化域内 reset 前后必须逐位相等。比较用 case equality，DUT 写使能保持原逻辑 equality。
3. 目标覆盖表至少包括每组 8 种三写事件使能组合、三个写地址的五种相等关系（全同、三种恰有一对相同、全异）、每个目标槽 0..63、各读端口与写地址的同/异关系、每个 lane 0..255 与 32 位有效变化、RUN/非 RUN、reset 与事件重合、PS tag[28] 两值和槽 bit3/tag[16] 两值。对不同地址写事件不能只检查最后一个槽；每拍所有受影响槽和保持槽都要核对。
4. 保留原作用域是关键：format/mul/zero 受 RUN 限制，add/PS 不受 RUN 限制；原数据写没有统一 `!aborting` 或“cancel 时禁止写”的条件，不得新增，否则可能改变取消后的实际返回清退。PS condition 保留 `ps_rd_rsp_valid && ps_rd_rsp_ready && ps_rsp_math`，其中 `ps_rsp_math=tag[31]`；add condition 保留原 valid、ready 与 `!tag[30]`。同时验证故障/取消期间发生这些真实条件时的数据行为。
5. 有限测试的覆盖统计必须忠实区分“所有使能组合/地址相等类型/全部槽 lane”与“穷举全部 64³ 地址及任意数据”。后者未执行不能宣称执行。用逐槽逐位的原/新一步更新关系审核补足任意数据的结构保真；如选形式证明，明确实际证明范围和结果。若后端只有两态，已初始化二态域与未初始化/未知索引四态域分开报告；不得把 case-equality 语法存在当成四态实测通过。

完成这些局部检查并结合机械 diff 确认控制与算术未改，可建立“原 D37 源 → 表示修复新源”的受影响语义桥；它不是重新执行完整 30 层，也不是独立证明所有全核故障行为。A010 可在该同一阶段连续实施、验证、综合并修复普通问题，无需逐次等待本报告签字。

另已知 canonical bias 的动态半组写可在后续修改其原 façade 时改为静态 half/lane 银行并保持同步读、写保护和 response hold；原 589824 位容量及填充映射不变。它不在 AT005 核心中，不能声称只修这处即可解除本次 core 阻塞。`format/aligned` 如仍形成实际工具瓶颈，可同样做静态 4 级移位表达，但必须保留每级原 enable、相同有效/tag 对齐和输出周期；不把未测变化一次扩展到全部工程。

任何改为少端口同步 RAM、减少槽数、借状态互斥合并物理存储、加入新调度或流水线的方案，都已超出上述纯表示等价修复，需要重新核实受影响架构/周期合同，不能直接继承 D37 正常路径证据。

### 当前可对用户报告的结果

已经实际尝试正确参数的完整顶层综合以及原矩阵核心独立综合；均在 24GiB 运行内存保护下停止。已查到矩阵核心多维、多端口操作数缓存触发工具展开风险，单核心主进程也达到约 23.69GiB，因此简单分模块未能解决。当前仍没有完整资源表或可布局布线的 DCP；这说明当前综合表示与既定运行预算存在阻塞，尚不能判断 FPGA 是否超容量。下一具体技术条件是完成上述存储表达的局部等价修复并取得新版本实际综合结果，而不是增加内存帽或沿用旧资源估算。

## 实际生产 diff 与等价抽取核对（新 engine e279968c，2026-10-25）

A010 已完成上述最小生产改动；本次 A014 只读核 `repair/production.diff`、`source_relation.json`、旧/新完整源快照、`old_storage.sv`、`new_storage.sv`、抽取脚本和正在编写的等价 TB。未运行 EDA 或测试。工程可继续普通编译/修复；本节不增加放行门。

独立读文件重算核实：旧 engine SHA256 `2147d041620a158cf7f2cddfd172b538e54ba78c5d340507a8c5ce08cfff069f`，新生产 engine SHA256 `e279968ca6407bc4c96687a689ba187cd7e29c1f0e2c61a358ecf1f18c917154`，repair 内两份完整快照分别与其对应源逐字一致。审核者从新源移除实际生成块、按记录的逆序偏移恢复六条原写操作、恢复声明后，**独立得到与原源逐字一致**的文本；所有 original/fixed fragment 的 offset/bytes 均与实际源内容相符。

实际 diff 符合选定边界：只更改 op0/op1 声明、加入 64 个静态槽写进程、移除控制进程中对应六类数据写；控制/pool_state/数值和协议检查未变。新块保留：

- 原 `if(!rst_n) ... else`，reset 不写数据。
- format、mul、zero 的 `state==RUN` 作用域；PS/add 在该作用域之外。
- 同槽 `op0 add > mul > format` 和 `op1 PS > zero > format`；异槽进程相互独立，同拍可各自更新。
- PS 槽 `[18:13]` 与原 bank selector `[28]`、`[16]` 及 256 lane scatter 表达。
- 六条实际异步 read RHS 以及原读选择控制逐字不变。genvar 槽取值 0..63，和 6 位已知地址比较的数值含义保持。

截至本次静态核对，未发现生产 diff 的具体 guard、优先级或数据映射缺口；这不等于 XSim 已通过。抽取器通过匹配原实际语句和条件重组存储 cone，新版本存储块则取自实际新生产块。抽取后的 bias 非存储分支被置空，属于隔离未变逻辑的测试投影；后续结论只能为“存储表示的所测局部等价 + 其余生产源码逐字未变”，不能说完整 core/30 层已重新仿真。

发现并已经 root 转 A010 的普通脚本/覆盖项：

1. 初次 `old_storage.sv` / `new_storage.sv` 的 PS-write read 分支拼成 `endend`，缺少分隔；需修抽取器并生成可编译版本，不涉及生产 RTL。
2. 初次 source_relation 的 `equivalence_scope` 提前写 `X data/reset/enable tested`，实际尚未运行；应先标计划范围，等真实收据再记录实测。
3. 初版 TB op1 碰撞循环 `b=s%32`，使所有事件组合/碰撞关系仅在低 32 槽执行；后续 PS 全 64 扫描是单写，尚缺高 32 槽 format 与 PS 同槽碰撞。应补 s=32..63 的 format/PS 四使能组合，并含低 32 槽 zero 同拍异槽；不要求不可能的 zero 高槽同址。
4. read coverage 初版共用一个地址位图，建议各实际读端口分别按其真实激活条件计数，避免一个端口的覆盖替代另一个。已知 64 地址、未知 slot 地址的声明范围须保持区分。

上述修改属同一工程修复循环，不影响已核生产 SHA 的源关系。本小节为测试前静态核对；随后实际 XSim 输入、日志和收据的集中结论见下一节，不把测试前状态当作最新结果。

## AT009 / AT010 局部四态等价实际结果集中接纳

**接纳 PASS，范围仅为实际原/新存储表示的所测局部四态等价，以及其余生产源码逐字不变。** 结合已独立核实的更新关系、作用域和源码逆变换，该证据可作为旧 engine `2147d041…069f` 到新 engine `e279968c…917154` 的受影响语义桥，支持按 D38 连续推进新源物理流程；不要求重跑未变完整 30 层。不把该桥改写为新源码完整 core 波形仿真或新 30 层实测 PASS。

核查入口：`repair/equivalence_result.json`、`attempts/AT009_repair_static/driver.log` 与 `receipt.json`、`attempts/AT010_repair_rtl/xsim.log` 与 `receipt.json`，以及两次 frozen 输入。

| 实际项目 | 审核结果 |
| --- | --- |
| 工具与编译 | xvlog / xelab 2025.2 实际完成静态展开并产生 `operand_eq`；AT009 rc0，9.768734056s |
| 四态 RTL | XSim 2025.2 实际执行、rc0、原始日志有 `OPERAND_STORAGE_EQUIVALENCE_PASS`，无 Fatal/Error；AT010 9.683605608s |
| 实际周期与检查 | 6721 cycles，13442 次完整两池检查（每周期沿前/沿后各一次） |
| 两组状态 | 每次逐槽对比全部 64×256×32 bit 的 op0/op1，使用 case inequality 触发 fatal |
| 写组合与碰撞 | op0、op1 各 2560 个使能×碰撞分类用例；op1 低 32 首组域中存在重复遍历，未宣称所有 64³ 地址穷举 |
| 高 32 槽补测 | 实际 frozen TB 加入 2 context×32 槽×4 format/PS 使能×2 低槽 zero = 512 用例；解决此前缺口 |
| reset | 64 个已写入状态上 reset 与所有写事件重合的用例 |
| 四态 | 192 个标记的 X control/reset/state 用例，另有 X/Z 数据写入及初始未初始化两池比较；known slot 地址不变 |
| 异步读取 | 六条生产 read RHS 均参与实际比较；mul、add、PS-write、trace 四类地址图（mul/add 各覆盖两池）分别按实际激活条件断言全 64 槽 |
| 位宽及数据 | 比较全部 256 lanes×32 bit；payload 提供逐 lane 不同数据，ones/zeros 位图断言通过；不是任意数据穷举 |
| 源与构建绑定 | 8 项记录输入的当前源、AT009 冻结、AT010 冻结共 24 个对应逐项 SHA 核验无失配；15 个实际 xsim.dir 构建文件含 xsimk 在 AT009→AT010 复制后全部 hash 一致 |
| 清理与保护 | 两收据 `source_verify_after=true`、`owned_after_cleanup=[]`，无 guard trigger |

关键身份：AT009 receipt SHA256 `bd902578ef50e53e75212a25a49fa97fec0254841d0a1a98d9ede5133e929583`；AT010 receipt SHA256 `77e13a509bbb5095da94248b17d93f3a4916e2d7ffb0136a86ac44cae60ab737`；实际 frozen TB SHA256 `fef256a206b4298b2938588eabfa5bfe6ea530aacc14a48b0d7c6e79739c46ef`。AT010 原日志中的 `$finish` 指向 AT009 冻结 TB，这是实际复用 AT009 构建 snapshot 的正常结果，已用 xsimk 及其余 14 个构建文件的一致性核实，非另一个未绑定构建。

原先 `endend` 已在真正编译的 frozen 文件中修复；高 32 碰撞与逐读取地址 coverage 已进入实际 frozen TB 并随终标通过。`source_relation.json` 仍将 X 测试描述为 planned，是保留的测试前源关系记录；实际测试状态由新 `equivalence_result.json` 与原日志/收据给出，不需回写历史输入。

限界与未外推项：

- 本次是存储相关逻辑投影的差分仿真与源码关系审核，没有形式证明穷举所有数据、所有事件序列或全部 64³ 地址；未知 slot 地址明确 `NOT_CLAIMED`。当前正常物理硬件域的地址为已知 6 bit，原 D37 正常路径在该范围内。
- 抽取模块将部分派生控制（例如 `ps_rsp_math`、ready）作为公共输入，且去掉不读取 operand 池的 bias 输出分支。其实际生产定义与其余控制逐字未改已由逆变换核实；测试不能另行证明这些控制或完整 core 的所有协议行为。
- static 及 RTL 的实际收据只捕获父 launcher 的完整政策样本；分别有 6、4 个短命子进程身份未获得完整政策采样，保持 UNKNOWN。不能从继承启动策略改写成每个身份均已观测通过。
- 通过只桥接本次 op0/op1 表示变化；生产顶层即使文件 SHA 不变，其依赖闭包已有新 engine，后续完整资源及 P&R 报告必须绑定新 manifest/配置。原 D37 仍是原闭包正常路径实测，新版 30 层重跑为 NOT_RUN。
- 新源码综合、完整联合网表、资源分项、300MHz route/setup/hold 均不由本局部 PASS 代签。工程继续现行同阶段，不设额外审核停点。

## AT011 持续运行中的集中成本判断与最小接续

本节依据 `attempts/AT011_core_synth/vivado.log`、实时 guard 样本和实际 `input/rtl_v2/laya_m007_matrix_engine_v1.sv`。实际源 SHA 与已验第一版 `e279968ca6407bc4c96687a689ba187cd7e29c1f0e2c61a358ecf1f18c917154` 相同；新完整 source manifest SHA 为 `052694c6c505803fcab20838b46d703d982964e5566a43c34b25c79e66398c85`，流程为 bottom_up_v5。core 仍为原 PROFILE=0、OOC、flat none、一个 synthesis worker，无 stub 替代。

独立读取到的 2026-10-25 08:13:19 UTC 样本：elapsed 1700.736003679s、owned RSS 16,774,800KiB（约 16GiB）、owned CPU ticks 175787、`last_progress_age_seconds=0`、6 个 owned 进程、trigger=null。此前 1607.466s 样本 owned RSS 16,777,108KiB、CPU ticks 166157，表明 CPU 持续活动且当时内存稳定。主日志仍在 RTL elaboration 路径，没有完整综合完成标记/DCP。**不能因日志静默判 stall，不能把当前稳定 RSS 认定为最终峰值，也不能仅与 AT005 触帽轨迹比较就签“峰值改善已经完成”。**

实际源码仍是 `logic [255:0][31:0] op0[0:63],op1[0:63];`，即 1 个槽维度及 2 个 packed payload 维度。AT011 对 op0/op1 仍逐项报告 `[Synth 8-11357] Potential Runtime issue for 3D-RAM or RAM from Record/Structs ... with 524288 registers`。这说明第一版静态槽左值没有消除工具仍识别出的多维存储表示。**AT011 当前消息是 runtime 风险警告，不是语法错误、不能综合的最终宣告或映射失败报告**；AT003 的历史“不支持此模式”信息也不能代替 AT011 尚未完成的最终结果。仍有可能继续计算后完成，但没有成本预测或 checkpoint 支持肯定时间。

本次唯一建议是由 A010 安全结束 AT011 并保留实际成本，继续具体、同语义的一维 payload 修复，而非等到原单次 7200s。主控已实际采纳派发。决定依据是：

- 原针对性修复的实际日志仍明确指出同一可避免的 payload 维度问题；下一步修改只需精确降低该表示的维度，有新、可检验的源码差异，不是更换壳层次或原样重跑。
- 已消耗 1704.9456s 的既往综合预算；若 AT011 用满单次 7200s，则原综合总 9000s 仅余约 95.0544s，几乎没有后续 façade/resident/完整 parent 链接空间。单次上限是允许的最大成本，并非必须耗尽的最低等待。
- 已有相同容量和相同读写行为的机械关系/6721-cycle 四态验证方法，上一轮实际 compile 与 RTL 各约 10s，为此次受影响验证提供真实成本依据；不需要扩预算或完整 30 层重跑。

这属于**主动的有因成本重规划**；最终收据须明确人工/owner 停止原因与实际耗时。不得伪写 `RSS_at_or_above_24GiB`、300s stall、功能 FAIL 或工具内部失败。当前工具仍有 CPU 活动这一事实必须保留。A014 本身没有控制进程或写生产源。

第二步唯一最小源差异如下：

1. 每槽 payload 从 `[255:0][31:0]` 改为 `[8191:0]`；仍是 64 个 unpacked 槽，原 `g_operand_slot` 静态写结构、全部 if 顺序及条件保持。
2. 原 PS-write 数据读取 `op0[write_next[5:0]][16*a+c]` 改为同一槽的 `[32*(16*a+c)+:32]`。
3. 原 PS-response 数据写入 `op1[slot][16*a+c]` 改为同一槽的 `[32*(16*a+c)+:32]`。

其余整字 8192-bit 赋值/读取不需逻辑变化。严格位对应为：原 lane `l` 的 32 bit 等于新 payload 的 `[32*l+:32]`，l=0 对应 `[31:0]`，l=255 对应 `[8191:8160]`。保持 reset 不清数据、add/mul/format 和 PS/zero/format 优先级、PS tag[28]/tag[16] 位选择、同拍多槽并发、所有异步读及全部接口周期。此次不增加独立槽模块、不修改 format/aligned 或其他生产文件，以免把明确的最小修复扩为多项未测变化。

新旧关系必须绑定原冻结 engine `2147d041…069f` 与最新源，而不是仅把第一版的 PASS 标签复用到第二版。机械逆变换应额外核验一维声明和两处 slice 映射；此前“六条 read RHS 全部逐字一致”对于第二版将改为“五条逐字一致，一条经过上述精确位映射”，不能沿用旧断言而漏测改变。抽取新生产真实表达，沿用已完成的 6721-cycle 测试覆盖及沿前/沿后完整槽 8192-bit case comparison，保留原生产语句作为 old 侧。新 manifest、构建和实际收据均须重新绑定。

本建议不预言这一修改能消除所有 runtime 警告，也不承诺 BRAM 推断、最终内存峰值、LUT/FF 数或 300MHz。多写口/异步读本身仍可能产生大的合法寄存器和 mux 网表。成功与否必须由新实际综合证据判断；若相同风险再次出现，应据新结果集中判断，不能把“再改层次”当作默认无限重试。

AT011 实际停止收尾已独立读取 `receipt.json`（SHA256 `a80752af215971cbc607874eb51fee9148e5d1e66c92c8bf90c8ab136996e9a1`）、`controller_replan_decision.json` 和 `result_classification.json`：elapsed 1736.656508570s，raw verdict COST_STOP、trigger `requested_stop`、明确分类 `CONTROLLED_REPLAN_STOP`；峰值 16,777,212KiB，为**这次主动提前结束区间内的观测峰值**，不是完整综合的最终峰值。最后决定样本仍 CPU 活动、trigger=null，故不是自动 RSS/stall 故障。`source_verify_after=true`、`owned_after_cleanup=[]`，一个瞬态 PID 2931973 政策未观测仍为 UNKNOWN。综合累计 3441.602141444s / 9000s，余额 5558.397858556s；后续仍按原总额度扣减，未产生 DCP。工程正在执行已派发的一维 payload 修复，等待其实际 diff 和等价结果在本页接续集中核查，不增加逐项放行。

## 第二版一维 payload：实际 diff 与 AT012/AT013 集中接纳

**限定接纳原 engine `2147d041…069f` → 最新 `f8493b130354123a57115f85bc1d6cdeab776a64697234962063604594b9c1cd` 的局部四态表示等价 PASS。** 适用范围沿用前述已知 64 槽、原相关存储逻辑及全部 8192-bit 读写；不能外推为完整 core/新 30 层重跑或形式穷举。该结果支持 A010 在同一 D38 阶段连续推进新源综合，不要求额外签字。

实际新证据保存在 `repair_v2/`，原 `repair/` 与 AT009/AT010 冻结输入保持独立。读取 `production_from_prior.diff`、`production_from_original.diff`、`source_relation.json` 及原/prior/最新完整源后，独立核实只有三处差异：声明 `[8191:0]`、PS-response lane 写 `[32*(16*a+c)+:32]`、PS-write lane 读同样的 32-bit indexed part-select。每处新版片段恰出现一次；逐项反向替换后与 e279 完整源逐字相同，再按原记录恢复六条写和原声明后与 2147 完整源逐字相同。该逆变换由审核者独立复算，不只接受 JSON 中的 true。

新写进程、reset/作用域/优先级、PS tag[28]/tag[16] 来源均未改；全部整字赋值依 SystemVerilog packed bit ordering 仍为原 8192 bit。PS 两处 lane 映射已在实际抽取与仿真中改变，未错误沿用“六条读 RHS 都逐字相同”的第一版说明。最新 `new_storage.sv` 包含实际一维声明和真实新写块，old_storage SHA 仍为 `7a1ce92238fd9bdafcbe7e79df81316d6a386afbb5f702ef2b140fa71061597e`，即原 2147 的存储逻辑投影；没有只拿 e279 作旧侧替代原基线。

实际验证链核实：

- AT012 `repair_static`：实际 xvlog/xelab 2025.2，9.696188813s、rc0、PASS，peak owned RSS 337432KiB，`source_verify_after=true`、`owned_after_cleanup=[]`。
- AT013 `repair_rtl`：实际 XSim 2025.2 四态运行，8.653027590s、rc0、PASS，peak owned RSS 802864KiB；原始 xsim.log 出现 `OPERAND_STORAGE_EQUIVALENCE_PASS cycles=6721 full_pool_checks=13442 ...`，无 Fatal/Error，`source_verify_after=true`、`owned_after_cleanup=[]`。
- 实际 TB SHA256 仍为已核的 `fef256a206b4298b2938588eabfa5bfe6ea530aacc14a48b0d7c6e79739c46ef`，与 AT009 逐字相同。因而原两池各 2560 使能×碰撞用例、高 32 槽 512 补测、64 reset、192 标记 X 用例、各激活 read 地址图全 64、全部槽/lane/bit 的沿前沿后比较，均在此新构建再次实际执行；不是复用旧仿真 PASS。
- 两收据的 10 项 repair_inputs 完全相同；审核者核当前输入、AT012 frozen、AT013 frozen 共 30 个对应，全部 SHA 匹配。AT012 实际 xsim.dir 的 15 个文件（含 xsimk）与 AT013 执行副本逐项 hash 相同。AT013 日志 `$finish` 指向 AT012 frozen TB，和实际构建/复制链一致。
- source relation 内的“planned”属于测试前冻结记录；新的实际 PASS 由 AT012/AT013 原日志和收据提供。审查读取时 `repair_v2/equivalence_result.json` 尚未落盘，未以摘要缺席否定已有原始结果，也未假称已经读到它；工程可普通归档。

收据身份：AT012 SHA256 `ef4c308f06be65da28371e0866c244a64a46deb21c8e1e9380dd82d9be41fe8a`；AT013 SHA256 `ba2fe8491c84baab4a3e98706722a9f94af23b3f35101580400e2d37703d58ae`。static/RTL 分别有 5/4 个短命进程未取得完整政策采样，保持 UNKNOWN，不补写为实测全部通过。

本轮没有发现需要阻止工程继续的生产语义缺口。未知 slot 地址、任意数据及所有地址组合的形式穷举仍不声称覆盖；同一抽取中部分派生控制作为共享输入及未变 bias 分支隔离的范围限界保持。原 D37 全图正常路径记录保持原源身份，最新物理结果需绑定 f849 及其新闭包；一维修改是否减少工具展开成本、能否完成完整网表/资源/300MHz P&R，仍待实际综合与实现报告。

后续归档核查：`repair_v2/equivalence_result.json` 现已落盘并实际读取，SHA256 `59c764d2125b78fefadc5f6554ebc850fea24f6a7e62d4347fa7b63d366edef7`。其 PASS、原 2147→最新 f849 范围、6721 cycles / 13442 checks、两池各 2560 组合、高 32 槽 512 碰撞、64 reset、192 X 用例及各激活读取全 64 槽，与前述已核原始日志及实际 TB 一致；明确保留 `unknown_slot_addresses=NOT_CLAIMED`、`full30_new_source_rerun=NOT_RUN`。这补齐结果摘要归档，不新增或扩大已有 PASS 范围。本次集中审核完成；后续仅在实际新源综合结果形成后接续资源及物理判定。

## AT014 最新一维版实际成本出口与有界诊断条件

### 独立核实的结果与归因限界

本次实际读取 `attempts/AT014_core_synth/receipt.json`、`initial_guard_trigger.json`、`guard_trigger.json`、`guard_samples.jsonl`、`vivado.log`、冻结 manifest/配置/Tcl，以及隐藏工作目录和实际 v3 源。重新计算 91 项冻结源 SHA 和 1 项 ROM SHA，均与本次冻结 manifest 一致；engine 为已验 `f8493b130354123a57115f85bc1d6cdeab776a64697234962063604594b9c1cd`。core 为 `PROFILE_ENABLE=0`、器件 `xcu55c-fsvh2892-2L-e`、OOC、flat none、单 synthesis worker、无 stub，实际 dot/format 子树保留。完整父配置仍绑定原 11 项 generic，不能把 receipt 中记录的父 top 误认成本次 synth 的实际 top；真实命令为 matrix engine。

| 项目 | AT014 实际结果 |
| --- | --- |
| 耗时及退出 | 1278.032619354s；COST_STOP；child exit -9 |
| 首要保护原因 | `owned_RSS_at_or_above_24GiB`，不是 stall/数值 FAIL/主动重规划 |
| owned 峰值 | 25,454,276KiB = 24.275089GiB；含采样停止延迟 |
| 首次触发快照 | 主 Vivado 24,909,352KiB = 23.755409GiB；helper 529,332KiB = 0.504810GiB |
| 后续快照差别 | `guard_trigger.json` 主进程已为 24,915,024KiB；不要拿这个稍后快照去反推首次采样的精确合计 |
| 主机余量 | 最低 MemAvailable 468,981,172KiB，高于 192GiB；这是 owned 成本帽触发，并非主机物理内存耗尽 |
| 源/清理 | `source_verify_after=true`、`owned_after_cleanup=[]`；1 个瞬态 PID 2954711 未取得完整政策样本，保持 UNKNOWN |
| 输出 | 实际证据根无 `.dcp`；没有完整 RTL elaboration、synth 成功终标或映射资源报告 |
| 新日志差异 | op0/op1 的 3D/524288 警告未出现；仍有 `aligned_reg ... 32768` runtime 警告 |
| 原预算 | 逐项重算 ledger：综合累计 4719.634760798s，余额 4280.365239202s；不重置或挪用实现预算 |

120.143s 样本 owned RSS 15,559,676KiB；300–1200s 约 16,059,800KiB 且 CPU ticks 持续增加；1276.135s 样本达到 25,454,276KiB，CPU ticks 131724、`last_progress_age_seconds=0`。这说明早期约 15GiB 稳定区间不能代表最终峰值，也不能用 stdout 静默判停滞。日志中的 `done synthesizing module 'laya_m007_matrix_engine_v1'` 仅为局部 RTL 处理标记，后续仍在整个 RTL elaboration 阶段；不能当作已完成映射。

隐藏目录仅保存生成的 engine 流脚本及少量元数据，没有可定位此增长到具体 PS 对象/优化 pass 的详细执行日志或完成检查点。生成脚本列出 `rt::run_rtlelab` 与后续流程，只说明将要执行的流程，不能当作已到达某个内部 pass 的证据。故本次事实仅支持：一维表示已消除对应警告，但核心实际运行仍超帽；不能断言已定位最后耗时点为 PS、aligned 或某个算术叶。

关键 SHA256：receipt `051d497aa3700ac166a9c9d5c7580e4b7d4de49745ae3b5b5c71a380186f1ab0`；initial trigger `00276d4a10929f57ae03b938e1e582f77b27294bdd8024ec9b4fbfc0c2eeaecc`；log `5324a0b76b7713c9189f18e36932644c430849bdc3f20d4101336a3a72bb7382`；manifest `735e0a3a14677d089c93ada10fa7ba6fadb867133c1189fc86dd9572e23bda5e`；bottom-up configuration `9639656a734c5bed308d53936e66ce5c5ebb9fafb97d121eb83f372eed82a31c`。

### 唯一可保留的具体假设：真实 PS 输出 cone 的静态 bank 表达

实际 `input/rtl_v3/laya_m007_matrix_engine_v1.sv` L202–206 在三个顺序分支向 1024-bank `ps_rd_mask/addr` 动态写入；L222–228 在 bias 优先的二分支向 `ps_wr_mask/addr/data` 动态写入。256 次迭代的目的 bank 不是任意 0..1023，而是 `512*C + 32*A + 16*H + J`，其中 A=0..15、J=0..15 为循环常量，C/H 各一位。因此可把每个固定 bank b 的目标反解为 C=b[9]、A=b[8:5]、H=b[4]、J=b[3:0]；lane=16*A+J，使用固定左值。这个反解直接来自实际源，具有明确的语义和成本假设：避免宽 packed 动态左值的逐次覆盖中间表示。它未证明是 AT014 内存热点，且不能预言工具原本没有完成同样优化。

固定 bank 的读选择依次保持 math、bias、retire 三个原独立 if，后者覆盖前者。math/bias 匹配对应 context 和 next[3]，原 4-bit 地址表达不变；retire 匹配 context 和 retire_next[4:1]==A，原 retire 地址表达不变。写侧必须保留**全局 bias if / math else-if**：当 bias 分支已经被选中时，不能因某个 bank 的 context/half 不匹配而让该 bank 回落到 math 写。仅在已选分支内部匹配 C/H，并取原固定 lane 数据。默认 mask/addr/data 全零、valid/tag/ready、所有使能和无效周期输出保持；不可只比 mask 命中的数据。

不建议本轮同时改 aligned、存储容量、异步读、算术叶或控制，不能把多个未定位假设捆绑成一次综合变化。普通 OOC 分区继续不能移走本层组合逻辑；原 warning 剩余的 32768 位也没有成本占比证据，消掉最后一条警告本身不构成下一次整 core 的依据。

### 原预算内的诊断边界与可证伪门（提案，尚未运行）

以下是供主控定义的单个有界诊断，不是 A014 启动命令。生产 owner 仍为 A010；先保留 f849 原生产/失败证据，候选放在实验独立路径。现有 AGENTS 的具体修复记录只覆盖 operand 表示，主控应把新的 PS 纯组合表示诊断范围与下面成本门写入本阶段决定；不需要改数据协议/架构，也不以审批替代普通工程修复。

1. **固定原/改身份与真实边界。** 原侧取 AT014 manifest 中 f849 的实际 PS 完整组合 fan-in，保留原动态左值/顺序及原函数定义；改侧仅作上面的固定 bank 反解。输出至少包括上述五向量及相关 PS valid/tag/ready，所有输出均保留为 OOC 端口。输入以原主端口和状态 q 为边界；真实 `op0[write_next[5:0]]` 64×8192 异步选择、动态 pool_state、原 grant/priority/room 计算均保留。**不可把 operand 预先选为一个 8192-bit 外部输入、把派生 grants 直接绑真/常量、缩到少量 bank/lane、移除未命中的输出或去掉困难逻辑来取得漂亮结果。** 本诊断排除的是两侧相同且位于组合 fan-in 之外的状态更新和 dot/format；这必须在映射表中明确，不能冒称全 core。记录两侧源 SHA、逐片段提取来源/范围、端口表、候选应用到完整 f849 后的预期 diff/逆变换；逆变换必须逐字恢复 f849，原/改仅五输出表达允许变化。
2. **先在剩余 repair 桶内验证语义。** 建议 compile/elaboration 和四态比较各单次上限 180s，仍受现有各 600s 桶的真实余额限制，失败准备也扣账。使用原实际 cone 作对照，检查全部 1024 bank 的 mask、4-bit addr、32-bit data、valid/tag/ready，包括全零未选 bank。覆盖全部已知 context/half/row/address 位组合和有效/无效分支、可产生的并发读、全局 bias 抑制 math、任意输入数据的逐位映射结构，以及 lane 不同值、0/1、X/Z 载荷。特别加入 bank-selector 和 branch-control 的 X/Z：旧动态左值未知索引及 Verilog if 的四态规则不能凭二态代数假定；不能用 ternary 的 X 合并替换原 if。slot 未知范围如仍不覆盖，必须明确记录，真实 slot 选择在两侧逐字相同。该验证是源映射与差分仿真，不误称任意序列形式证明或全 core 仿真。
3. **仅两次顺序物理对照，合计最多 360s。** 原 cone 和候选 cone 各一次最多 180s，从当前综合余 4280.365239202s 扣，失败/提前停止照实计费；不另开预算桶、不自动延长或重试。两次使用同 Vivado 2025.2、同器件、PROFILE=0 相关常量、OOC/flat none/单 worker、同 clk 约束、全部动态端口、同 heavy lock/24GiB/CPU0–3/nice19/idle/MemAvailable>192GiB 和原 stall 定义。若为纯组合且 clk 无内部端点，必须如实说明，本诊断不输出时序 PASS。保留实际工具配置、源 manifest、完整日志、guard/峰值/CPU/耗时、阶段终标、DCP SHA、blackbox/利用率/层次和被优化输出记录。新侧必须实际完成 mapped synthesis 和 DCP，0 blackbox；只过 parse/elaboration 不满足。
4. **预先固定成本门，避免事后追逐微小差异。** 这是保守的本次决策阈值，不是工具理论定律：两侧都完成时，原侧峰值 owned RSS 至少 4GiB，候选峰值不超过原侧一半，且绝对下降至少 2GiB；或者原侧实际触 24GiB RSS 帽，而候选在 180s 内完整完成且峰值不超过 12GiB。只有这两类明显内存差异，连同语义 PASS、完整真实边界和无常量化/输出裁剪证据，才支持一次整 core 接续。原侧仅超 180s、候选较快，或两侧都很小、都触帽、仅 warning 减少、仅局部资源变少，都**不**单独满足内存问题的准入门。若某侧 source/配置/guard 不一致，结果无资格用于归因；本次诊断按实际未证实结束，不自动补第三个对照。
5. **满足门后也只允许一次条件化的整 core 验证。** 主控可在相同源关系和全保护下将候选应用到完整 f849，冻结新身份，单次建议最多 1800s，并受实际剩余综合桶限制。若诊断用满 360s 且该次用满 1800s，仍保留 2120.365239202s 给后续真实 façade/resident/parent/链接；这只是成本保留，不保证后续够用。整 core 的实际 source-bound DCP 才能证明当前表示在原帽内完成；局部 cone 成本改善只提供尝试依据。新整 core 再触 RSS/时间帽或无有效 DCP，则终止本轮该路径，不继续扩大修改或同源重跑。成功后普通串行实网表装配和实现沿前述条件推进；完整资源仍仅出自完整链接/优化设计。

**明确出口：** 在上述诊断前，D38 物理流程保持实质阻塞，完整资源/fit 为 UNKNOWN、P&R/setup/hold 为 NOT_RUN，绝不把候选写成修复完成。若原/改对照没有形成准入差异，应归档“PS 静态散写假设未在既定真实边界和成本下提供足够内存改善证据”，结束本轮完整物理尝试；不能据此数学排除所有 PS 优化，但没有继续消耗原预算的具体依据。再启动物理的下一可实施条件应是新的可归因证据与局部等价闭包，或经主控明确处理的新存储/调度架构合同；普通同步 BRAM 化、减槽、串行化多口、增延迟都不能沿用现有表示等价结论。无论此候选是否成立，AT014 的软件成本限制都不等同于 FPGA 资源超容量。

## AT015 六小时最终结果：阶段定位、可恢复性与最小策略接续

本次有界只读审核实际读取 AT015 主日志、raw receipt、`rss256_handoff/effective_receipt_verified.json`、原始 guard trigger/最后两条 samples、隐藏 worker 日志与脚本、当前 f849 源及本机 synth_design 文档。未启动 EDA/测试、未改 RTL/工程或控制进程。

### 实际阶段证据

| 日志位置 | 实际已完成或开始的阶段 | 日志内 elapsed |
| --- | --- | --- |
| vivado.log L280 | Finished RTL Elaboration | 00:37:11 |
| L309 | Finished Constraint Validation | 01:11:54 |
| L326 | Finished RTL Optimization Phase 2 | 01:24:59 |
| L2376 | Finished Cross Boundary and Area Optimization | 03:29:03 |
| L3158 | Finished ROM, RAM, DSP, Shift Register and Retiming Reporting | 无独立耗时 |
| L3164 | Finished Applying XDC Timing Constraints | 03:31:29 |
| L3167（主日志最后阶段标记） | Start Timing Optimization | 没有 Finished 对应项 |

主日志最后修改为 2026-10-25 15:13:26 UTC；实际时间保护触发为 17:41:34.658 UTC（北京时间 2026-10-26 01:41:34.658）。两者相隔约 2h28m。最后两个监督样本 owned CPU ticks 从 2750408 增到 2750517，`last_progress_age_seconds=0`，故不能把日志静默认作 stall。CPU 活动只证明工具在计算，不提供剩余时长或完成百分比。后续可能仍有映射/清理/网表写出，当前没有证据量化它们；不能从阶段名称承诺再等一会即可成功。

实际总耗时 21601.398908304s（含停止收尾），合并峰值 116,367,224KiB = 110.976433GiB；最低 MemAvailable 360,390,140KiB = 343.694820GiB。最后触发字段为 `original_stage_or_category_deadline`，effective RSS cap 为 256GiB。raw receipt 因原 guard 暂停期间由外部监督结束工具，真实保留 FAIL/-9、trigger=null；合并收据把原始监督原因、峰值和政策样本归并为 COST_STOP，不能覆写 raw 或把该差异当成 Vivado 自发报错。`source_verify_after=true`、`owned_after_cleanup=[]`，本次只读检查全部原 known PID 均已不存在。仍有一个历史瞬态身份 PID 3089334 政策未完整采样，保持 UNKNOWN。

关键身份：raw receipt SHA256 `a353abd85eb7bff823a000b8bd4f59b0aae4b01d26687a08239bfcf94519b34b`；verified effective receipt `ed5202d2fbf770fc32c4c9a3295f968176c809296c63f2670305b3f4ffbada56`；实际 trigger `029a57d81005282afee4c7878c6e689cce50d1815bccc64a39fc25f900e4a6df`；主 log `60ce62c970e343b9846ce2b1b510a4d96319c303cc233ff3c9b880266412d2e0`；manifest 仍 `735e0a3a14677d089c93ada10fa7ba6fadb867133c1189fc86dd9572e23bda5e`，当前 engine 重算仍为 `f8493b130354123a57115f85bc1d6cdeab776a64697234962063604594b9c1cd`。

### 当前结构与资源不能外推的部分

本次真正到达的 RTL Component Statistics（L329–430）列出例如 64 个 8192-bit register 元件、192 个 8192-bit 二选一 mux 元件；这与源码中宽 operand 状态、多事件写优先级及多路异步选择的结构压力一致，但它们是 RTL 中间统计，**不是最终 FPGA FF/LUT 使用量**，也不能按维度加总成器件超容量判定。当前源仍是 64 unpacked 槽、每槽 8192 bit、静态槽写、六条相关异步读取，PS bank 散写也保持原 f849；本次没有更改容量、时序或吞吐职责。

L433 的 `Part Resource Summary` 中 DSPs 9024、BRAMs 4032 是目标器件容量，不是设计用量。L2766 的 DSP 表明确为 Preliminary Mapping Report，表尾还说明后续可能改用非 DSP 原语且多次实例未逐次展开，不能当作完整核心或完整 top 的最终 DSP 总数。隐藏 worker 日志中的 `do_reinfer_area_combined`、DSP 吸收和 `.rtd.completed` 支持部分面积处理确已执行；没有把最后 2h28m 的时序成本定位到某条具体 PS/operand 路径的 timing/path 报告。因此当前有依据调整综合时序驱动策略，尚无依据宣称某个新 RTL 表示已被证明是必须的修复。

实际 work 中无 DCP/EDF，有 3 个内部 `.rtd`、47 组 `.rtd.tcl/.rtd.completed/.rtd.pb.log`；整个 E022 R001 亦无 DCP。这些内部中间文件不是公开、已验证的 `read_checkpoint` 恢复产物，不支持据其文件名声称可接着第六小时续算。原 Vivado 已退出，内存工作状态已丢失。使用私有 `rt::` 脚本拼接内部状态不是本次最小接续，也不能代替真实 DCP 证据。

### 可直接实施的唯一最小策略变化

本机官方文档 `/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/doc/eng/man/synth_design` L328–330 写明：`-no_timing_driven` “Disables the default timing driven synthesis algorithm. This results in a reduced synthesis runtime, but ignores the effect of timing on synthesis.” 同文档 L118–119 的 `runtimeoptimized` 会减少 timing 优化并去掉部分 RTL 优化，变化范围更广；本次先只选前者，不同时叠加策略、隐藏参数或 RTL 变更。

建议 A010 在现有 core_synth 命令唯一加入 `-no_timing_driven`，其余 f849/manifest_v3、PROFILE=0、器件、OOC、flat none、单worker、真实 dot/format、全部端口及原 XDC 保持。独立记录策略配置与原 AT015 差异；不覆盖其失败冻结。综合成功立即写 source/strategy-bound core DCP 和实际层次资源/blackbox 报告，保留完整原端口，不靠常量化或主动裁剪 trace 换取成功。

该选项改变的是工具选择网表时是否优化时序，不是功能架构。它可能增加最终关键路径延迟或改变面积/布局质量；不能因为拿到了网表就宣称 300MHz。XDC 不删除、不拉长周期，不加 false path 或放宽内部端点。后续完整真实 DCP 链接、opt/place/phys_opt/route、完整内部 STA 仍按原 3.333333333ns、setup/hold/DRC/route 完整性标准执行。即使最后 timing FAIL，也必须报告真实结果，而非更换验收标准。core DCP/资源只代表核心；完整 top 总量仍须来自完整链接/优化网表。

主控最终采纳**一次**新的有因策略尝试，守卫沿原规则取 min(21600s, 实际综合余额)，当前上限为 16878.966330898s；预算不增，也不另加审核者建议的更低帽。此前已完成前段约 3h31m 只是策略判断的实际证据，不是新运行时间承诺。core 成功须立即先保存 DCP，再做报告，以免后续报告成本影响已完成网表的留存。实际 core 结果后继续按账本评估其余分区；若本次耗尽综合余额，则没有该类别余量继续父 top，不能承诺原余预算足以收完整核。若这一次仍无有效 DCP，保留具体失败阶段后停止同源策略重复；如需少端口 RAM、减槽、串行共享、增加流水或重排数据生命周期，属于实质设计/周期变化，须由主控清楚处理新合同，不能伪装成此次工具策略修复。

A014 对该最小策略接续没有额外语义阻碍；本节是实际结果后的集中建议，不添加新的用户审批或普通工程逐项门。旧 PS 候选继续暂停且未采用。

## AT019 原生报告完成后的等待：并发只读简报（2026-10-26 05:52 UTC）

本节覆盖此前 AT015 状态：当前实际 AT019 继续存活，已按用户授权切到无墙钟期限，core-only `-no_timing_driven`、f849 功能源及既定物理保护不变。A014 本轮只读工程观察 JSON、冻结 Tcl/runner、外部监督源码及 `/proc`，仅追加本节；没有 attach、发信号、注入、EDA 执行或工程修改，未干预同项目其他 owner。

**已确认原生 `Synthesis finished with 0 errors, 0 critical warnings and 2749 warnings`，工具报告 elapsed 05:29:43；尚无 core DCP、intermediate_scope 或本阶段成功标记。** 冻结 Tcl L124 调用 synth_design，随后 L125–127 还会执行 get_cells/blackbox 核对，L128 才写 scope，L129 写 DCP。因此缺 scope 只证明尚未达到该标记，不能独立区分“synth_design 清理/返回未完成”与“返回后 get_cells 等待”；本轮不把原生成功消息升级为 D38 交付完成。

### 实际进程和等待证据

- Vivado PID/start 为 3583093/66052106，原 leader 为 3583000/66052093；四线程身份仍在。05:48:19 UTC 独立读取时，主线程 3583093 的 CPU ticks=130，原高 CPU 线程 3583107=1835679，均与工程 05:28、05:35 记录相同，wchan 均为 `futex_do_wait`。线程 3583368 从 05:35 的 262974 增至 271660，采样时在 `hrtimer_nanosleep`（另一次采样为 R）；线程 3634083 仍 11 ticks。可据此说关键线程持续等待，不能说其余 CPU 增长就是综合网表继续推进。
- 写 I/O 计数仍为 `write_bytes=17941233664`、`wchar=17940344840`，原生日志不增长；读取计数 rchar/syscr 有增长，故不能笼统说全部 I/O 完全不动。当前监督按全树 CPU 增长保留 `last_progress_age_seconds=0`，它与上述线程级等待事实可同时成立；本轮不擅自把保护标准换成新 stall 条件或触发停止。
- 原 Python guard 3582995/start66052065 保持 T，直接 children 为原 leader 和 zombie 3633734/start66420454。该 zombie PPID=3582995、PGID/SID=3583000，实际 Z、零 RSS；Vivado 四个线程各自的 children 文件均为空。原 `/proc/locks` 实际仍显示 guard 持有 inode156929132 的 WRITE FLOCK，guard FD3 指向同一 heavy.lock。
- 05:52:41 新监督 live 为 elapsed23086.749s、owned RSS100204620KiB、trigger=null、wall_time_limit_disabled=true、原guard状态T。monitor3595603、watchdog3595604、observer3595805仍在。原 finite runner 的缓存 limit=16878.966s 已过，不能直接恢复其正常循环。

**僵尸与等待目前只有共现证据，没有因果证据。** Z 进程已退出、不持有其原用户地址空间或打开的文件描述符；正常 waitpid 不会等待一个已被别的父进程收养的非子进程。仍存在工具按 PID 存活状态轮询、管理器清退协调等假设，但需要调用栈或明确日志证明。原 runner 的 `reap()` 只在 finally/退出清理中调用，正常监控循环没有该调用；所以即使只取消旧 deadline 后 CONT，也不会立即收割该 zombie，不能用“原guard暂停导致未reap”直接解释当前 futex 等待。

### 最小取证与条件化无重启恢复

**先取一次短小、只读的 Vivado 四线程回溯。** 前提是已有合法 root/CAP_SYS_PTRACE，或目标明确允许且符合 ptrace 权限的父进程诊断通道；由工程 owner 限定 PID/start3583093/66052106，取 `info threads` 与 `thread apply all bt 16`，不执行 inferior 函数、不注入 Tcl、不改对象、不生成百GiB core dump，可靠 detach 后核原 PID/start、外部 heartbeat 和线程恢复。重点看 3583368 轮询调用链、3583093/3583107 futex 上层：这能区分 worker join/进程轮询/IPC 或其他同步；若工具缺符号，库名与偏移也可提供定位，但不保证直接给出锁地址/目标 PID。短暂诊断暂停不是更改生产或重启，仍不得触动原guard/锁。

本机确有 `/usr/bin/gdb`，但当前读取 `ptrace_scope=1`、本会话 CapEff=0、目标 TracerPid=0，`/proc/3583093/{syscall,stack}` 已实际 Permission denied。A014 没有 attach 试探；当前没有已经核验可用的访问权，不修改全机内核策略、绕过权限或承诺已能取得回溯。无该权限时保留现场与上述证据，交由具有合法目标访问权的诊断通道；不能把假设当恢复依据。

若回溯明确指向等待 zombie3633734 消失，则最小可证伪修复才是**在其真实父 guard 上只执行一次准确 PID 的非阻塞 waitpid**，保存实际返回状态并观察相同 Vivado 是否越过 scope/开始写 DCP；外部 monitor 不是该父进程，普通 waitpid/pidfd 不赋予它回收非子进程的权利。不能用 `waitpid(-1)` 误收原 leader、不能杀原父后靠重归属回收、不能以清理 Z 为理由重启 Vivado。

这只是有前提的单点检验，当前监督尚不允许直接执行：monitor L240 检查原guard必须保持 T，检测恢复/消失会进入无deadline fallback；相关 finally/watchdog 会先停止 owned，再恢复旧 finite guard。ptrace 的 t 状态或临时 CONT 都可能撞上该联锁。因此必须先由 owner 验证一个保持无deadline保护、heartbeat、锁/身份和原状态的受控维护交接机制，再通过合法父上下文执行定点回收；不得用“很快 CONT 再 STOP”赌原有限时间判断尚未运行。回收成功只说明 zombie 被收割；只有同一 Vivado 随后产生 scope/DCP 或其他真实推进，才支持该因果假设。若回溯指向其他等待对象，应据其具体栈修复，而不是重复收割/试信号。

**当前结论：已有明确等待现象，原因未定；现权限和监督联锁下没有可直接执行并已验证安全的无重启恢复动作。最小下一步是合法只读四线程回溯。** 此结论不要求暂停现监督、加帽或重跑，也没有新增用户审批；生产现场保持。

### 原生 cell 表对 900k LUT 目标的有限判断

本次仅核实际原生 `Report Cell Usage`：LUT1=14156、LUT2=190656、LUT3=522898、LUT4=97801、LUT5=523638、LUT6=1106985；六项 cell 合计2456134，约900000的2.73倍，且仅 LUT6 项就约为目标的1.23倍。**当前核心这份映射表对 900k LUT 目标存在明显资源风险**，不能因原生0 errors忽略。这里计算的是该原生表中的 cell 数，不是声称已经取得器件占用率。

尚无可读取 DCP、完整父层合法优化/资源报告及器件 fit 结果；OOC 边界保留的公开输出也可能在原父实际连接后合法裁剪。故不据这张表签最终 FPGA 超容量、完整 top 用量失败或实现必然不可行；后续应先拿 DCP，核层次、实际可裁剪边界和完整链接报告。DSP内部子类也不能与DSP48E2简单相加作最终DSP总数。

证据身份：05:35线程观察 SHA256 `96378a8a2acfefb3d20c7cb41699d361279a92366db4c7b2bd1b8454b10727c7`；05:38 guard子进程观察 `2a90175b91bf836f33a03517a60f47887e397d445e0e11abe31bbe7b64fb8d69`；AT019冻结 Tcl `34d23e3b33f95ee5fb7a472cf3d71b51f303026030900790ffa5383b3dad321a`；原runner `f8c1886ab93b9925c683a79c11653cc9eb69673eea4a8ff0e317b8edd314ab61`；无deadline交接配置 `37a21b6fcb91184bb5c8b6bb604178d84c49e52aea75794a16e5c2d0b018de47`。过程现场读数是本节注明时点的快照，不能当作后续持续状态。


## AT019 管理员栈的离线符号核对（2026-10-26 10:26 UTC）

本节接续管理员实际诊断 `AT019_core_synth/admin_stack_diagnostics/DG_20261026T101440Z_108d446e/`。A014 仅离线读取本机 ELF、符号表和有界反汇编，并核对实际 `/proc/3583093/maps`；未 attach、读取目标内存、调用目标函数、发信号、CONT 原 guard、运行 EDA 或改工程。唯一写入仍是追加本报告。沿用 research-agent 的原始证据、限定结论与单 owner 规则。

**已把等待定位到 HARTSJobManager 的线程收尾，并在本机二进制中确认其按 `kill(pid, 0)` 轮询工作进程是否存在。未回收僵尸因而成为有具体机制支持的可检验假设，但实际 worker PID 尚未从管理器对象读取，根因仍未确认。** 原生综合报告完成依然不等于 core DCP 或完整父 top 交付完成。

### 诊断可信度与库身份

管理员 capture 于 `2026-10-26T10:14:40.714738Z` 开始，耗时 0.365388097s、debugger exit 0、无 timeout/cleanup signals、detach_verified=true；postflight 核原 PID/start 3583093/66052106、TracerPid=0、旧 guard 仍 T、三外部监督仍在。此轮未改变该现场。

`set auto-solib-add off` 的回溯在经过未加载符号的库后存在明显错误展开：若干所谓帧为栈/数据地址或 ASCII 数据。因此采用三个独立条件核对候选返回点：实际映射及 ELF PT_LOAD 得到 load bias、地址落在动态 FUNC 符号的明确 size 范围内、其前一条指令确是相应调用。不能仅凭 addr2line 的“最近较低符号名”命名函数，更不能把所有 `??` 连成真实调用链。

库路径基准为 `/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/lib/lnx64.o/`，实际 maps 的设备均为 `103:02`，同路径 stat inode 与映射相符。各 ELF 的相关 PT_LOAD 均支持下表偏移换算（synth 可执行段 fileoff/vaddr 同为 0xe02000；common 使用多个含执行权限的 LOAD；commonmain 为 0xc000；libstdc++ 为 0x9d000）。

| 库 | load bias | inode | SHA256 |
| --- | --- | --- | --- |
| libxv_synth.so | 0x773067400000 | 158628289 | f8aa557764afc68ab13fb747fa3801ec4d66659ce404ffef3d38f380dceeb6cc |
| libxv_common.so | 0x773085a00000 | 158633462 | 8f48fdabae5e38648d5998595f37792ba9a7e16e6897aa52022dabf7bd9e69be |
| libxv_commonmain.so | 0x773086c5d000 | 158633760 | 1210fcf2f42ef849e554041e5d5b605d11f4ff36d27c6dcbc37d0f7945eef8b4 |
| Ubuntu/24/libstdc++.so.6 | 0x77307b000000 | 158888927 | a68762c86d371e6041f03f03a33a78fa235809ae7d81c90185940c93c3535aed |

前三库的 readelf notes 未列 GNU Build ID；libstdc++ Build ID 为 `ca77dae775ec87540acd7218fa990c40d1c94ab1`。不将不存在的 Build ID 填为已核。

### 可核实的函数与调用点

| 线程/捕获地址 | ELF 相对地址与函数范围 | 调用点核对及解释 |
| --- | --- | --- |
| 3583107：0x77307b0ece33 | libstdc++ +0xece33；std::thread::join，起点0xece10、size57 | +0xece2e 调 pthread_join，返回点恰为0xece33。该线程在 join 等待。 |
| 3583107：0x773068c8710a | synth +0x188710a；HARTSJobManager 析构，起点0x1886e00、size1596 | +0x1887105 调 std::thread::join，返回点完全吻合；其间有错误展开帧，故动态对象/目标仍须实读。 |
| 3634083：0x773068c869c5 | synth +0x18869c5；thisThreadWaitForChildError，起点0x1886980、size328 | +0x18869c0 调 nanosleep；这是可靠的 libc 上层返回点。 |
| 3583368：0x773086219ba4 | common +0x819ba4；HUTPssMemWatcher::trackPssPeakForProgram，起点0x819b8e、size32 | +0x819b9f 调 sleep(10)，返回后调用 mayUpdatePeakForProgram，再循环。这是内存峰值统计线程。 |
| 3583368：0x773086219bd1/0x773086219fbf | common +0x819bd1（trackPssPeakForProgram包装），+0x819fbf（std::thread::_State_impl::_M_run） | 分别紧接对上述成员函数、线程函数指针的调用，且均在对应 FUNC size 内，与监视线程角色一致。 |
| 3583093：0x7730864da0c4 | common +0xada0c4；HCTNativeThread::join，起点0xada0ac、size26 | +0xada0bf 调 pthread_join，返回点吻合。 |
| 3583093：0x773086c6b1d4 | commonmain +0xe1d4；rdimain::main，起点0xdd50、size2253 | +0xe1cf 调 HCTNativeThread::join，返回点吻合；这是启动主线程等待被创建线程的结构。 |

PSS 监视器的 `mayUpdatePeakForProgram()` 调用 `getPssAndVssForProcess()` 并比较/更新峰值。它的周期性活动可以解释既有辅助线程 CPU/read 计数增长，不能作为有效综合网表继续推进的证据；不据此擅自重定义或触发当前 aggregate CPU stall 保护。

两个特别易误判的地址应排除过度命名：common+0x530ac7 不在 addr2line 给出的 `boost::...condition_error::clone()` 符号 size 内，只是无名代码中紧接 pthread_mutex_lock 的位置；不能据此声称发生 boost 异常或 mutex 死锁。libstdc+++0xecdb4 同样不在最近的 `std::error_code::default_error_condition()` size 内，局部指令呈线程状态虚调用/析构结构；不能把这个最近符号名当真实函数。

### 工作进程轮询与析构的实际条件

以下字段名称仅描述反汇编用途，不冒称已取得源码类型或现场值。`thisThreadWaitForChildError()` 的正常路径为：

1. 每轮休眠 5 秒；synth RO 常量 0x35f7220 的16字节为 timespec `{5,0}`，EINTR 时用返回的剩余时间继续 nanosleep。
2. 读取 `u32(this+0x10)`，按该数量遍历 worker。记录起始地址取 `u64(this+0xe0)`，每记录步长 `0x2050`，PID 取记录 `+8` 的32位值。
3. +0x1886a00 调 `kill(pid,0)`。若返回不是 -1，继续检查下一 worker，扫描完后再次休眠；**这一分支完全不检查结束 flag**。count=0 亦直接回到休眠，而非按 flag 退出。
4. 仅在返回 -1 时，+0x1886a0a 检查 `u8(this+0x131)`；非零才 return。为零则走状态错误标记/广播并调用 exit(7)。此处没有按 errno 区分 ESRCH/EPERM，故只读 PID 之前不能把所有失败解释为“进程已不存在”。正常轮询路径没有 wait/waitpid。

析构入口 +0x1886e1e 先把 `this+0x131` 写为1；经过工作状态结束/通知等清理后，+0x1887105 对 `u64(this+0x180)` 指向的 std::thread 调 join。构造函数 +0x188a4dd..0x188a51c 从 GOT 项0x40d41d0取得 `thisThreadWaitForChildError` 地址，创建成员线程并存到同一 +0x180；readelf relocation 明确为该函数的 R_X86_64_GLOB_DAT。因此二进制结构支持“析构等待该错误监视线程退出”，而不只是两个相似函数名的猜测。

**还有第二个退出条件：** join 返回之后，析构 +0x1887130..0x1887168 再次对全部 worker 作 `kill(pid,0)` 检查；发现一个仍存在即从头继续。仅改结束 flag、强迫管理线程返回或伪造 join 成功，不会满足这一条件，还可能破坏工具内部状态，不是保留成果的恢复方案。

Linux 下未回收但仍存在且有权限的正 PID 僵尸通常满足 `kill(pid,0)==0`。因此，若实际向量含3633734，则“flag已置位，却因 PID 仍存在而不能走 return；析构join持续等待”是完整可检验机制。root 10:24:24 UTC 的独立只读快照 `.research-agent/automations/d38_report/reports/20261026_1825_candidate_worker.json` 还记录该候选 Z/PPID3582995/start66420454、原始 exit_status=0；这是 root 提供的进程事实，**尚未绑定到 HARTS worker 向量，不能升级为根因确认**。同理，目前两个 pthread join 的 threadid 参数被隐藏，未直接确认“主线程→3583107→3634083”的动态关系。

### 已发送 A010 的最小第二次只读规格

A010 负责独立 v2 脚本，v1 保持冻结；A014 已通过实际消息发送下列规格并抄 root。此处只记录取证规格，尚未执行第二次生产诊断。

优先取 `worker_count / worker PID / 结束flag` 三类现场值，辅以必需的指针验证，避免泛化调试。仍限定 PID/start3583093/66052106、LWP3634083、原20秒读取与可靠detach保护；保持禁止函数调用、内存/寄存器写入、断点和tracepoint。身份或形状不符合就返回“未确认”，不猜指针、不扩大读取。

无需加载整个 Vivado 的符号即可安全恢复候选 this，但须先严格匹配以下已离线验证的 libc 字节与栈形状：`/usr/lib/x86_64-linux-gnu/libc.so.6` SHA256=`3a15d66867d83762c7f2f1e37359cb8f6c5743edb369c65285cb0b1c4f7498bf`，inode227566829，Build ID=`a4a7992a8e66555c8141ab2a08a8465ff6e0ea65`，实际 bias0x77307a800000、RX/fileoff0x28000。libc 与 synth 文件SHA、maps路径/inode/load bias/权限均必须一致。

- 仅接受该线程 frame0 PC 为 `libc_bias+0xecbdf` 的已核 syscall 返回点；其它PC在最小v2中安全退出，不扩大恢复规则。
- 令 `B=frame0.rbp`。clock_nanosleep 起点0xecb20先建rbp帧，再依次保存r15/r14/r13/r12/rbx，故调用者rbx保存于 `B-0x28`。nanosleep起点0xf9b10只建rbp帧，不修改rbx；HARTS等待函数在+0x188698f设置rbx=this，整个正常循环保持该寄存器。
- 先确认所有读区间属于可读栈映射，读取 `N=u64(B)`、`H=u64(N)`，核 `N==B+0x10`、`H==N+0x50`、`u64(B+8)==libc_bias+0xf9b27`、`u64(N+8)==synth_bias+0x18869c5`。可选再核frame0.r12等于 `H-0x40`（timespec地址）。这些具体间距来自两层libc及HARTS已核prologue，不是通用ABI假定。
- 上述全部成立后，`this=u64(B-0x28)`。不能直接把当前frame0.rbx当this。验证对象各读取范围可读后，仅取 count、flag、begin/end，核begin<=end、长度为0x2050的整数倍、count不大于向量长度且count<=64；0或异常数量如实报告/退出。仅读每条记录+8的4字节PID，不倾倒整个对象或worker。PID<=0不按普通进程解释。
- 可选读取 `thread_obj=u64(this+0x180)` 及其首字 pthread handle，与本次 info threads 的LWP3634083 handle核对；也可从已正确展开的glibc `__pthread_clockjoin_ex` 帧读取两个threadid。它们补充依赖证据，不替代实际worker PID。

### 保留已算结果的最小恢复边界

当前已证机制使“等待更久”没有新的完成依据，但没有授权 A014 改变现场。下一步仍是上述小字段只读确认，维持原 Vivado、无deadline监督、256GiB/系统余量/CPU/锁与现有保护。

只有实际 worker PID/flag 与候选僵尸身份匹配后，才考虑在**真实父进程上下文**准确回收已退出的该 worker，令工具自身的存在性检查自然失败并自行退出收尾线程；不修改 Vivado 的 flag/PC/寄存器或伪造返回。不用 waitpid(-1)，不回收 leader、不杀父或重启工具，任何多 worker 情况都要先逐项解释其实际身份。

但原 guard 的有限deadline已过，正常循环不主动reap，且现外部监督要求它保持T；不能直接CONT、临时attach它或赌短暂维护不会触发停止。执行回收以前，必须由 A010/root 提供并先在隔离小进程验证有界维护交接：无deadline保护、heartbeat、原lock/父子关系及leader退出状态均保持，相关monitor/watchdog联锁与失败出口有明确协调。当前没有已经验证可直接运行的生产回收通道，A014未执行任何恢复。单纯外部waitpid/pidfd不提供非父的回收权。

回收候选后仍只能按真实新证据判定：同一Vivado是否解除两层join、越过原Tcl scope并生成可读DCP；如无推进，保留新等待证据，不反复注入或尝试信号。即便 core DCP 保存成功，完整父链接/资源/布线和300MHz STA仍单独验收，先前900k LUT风险判断亦不因此取消。

本次原始诊断SHA256：gdb.txt=`0f5e38385c2deb33e9bddf8e5ca6a51b5d9c256acca24d38f5a018bc9a4f06e6`；capture.json=`11d234da7656be64f797f537f1732a335ab39c8fd243b9aaab6b0388a3189419`；postflight.json=`3074ab605b247c3fb2e448857bf8cdf60b0ceadfc78daf3a1485da27a02abe37`。本节区分原始采样事实、离线机器码机制与未验证的动态对象值，不把后两者混写成已恢复成功。


### 条件成立后的单点回收评估（10:29 UTC，仅方案）

按 root 补充要求，范围仅评估一次 `waitpid(3633734, NULL, WNOHANG)`，不设计通用监督框架、不实施。若 v2 实读 worker_count=1、PID=3633734、flag=1，且动作前该 PID/start66420454 仍为原 guard3582995 的 Z 子进程、exit_status_raw=0，则由该真实父进程执行上述调用，预期立即返回3633734并回收该 zombie。在无PID复用或其他状态改变的条件下，下一次5秒轮询的 kill(pid,0) 会返回-1，结束flag允许监视线程return；析构join后的第二轮存在性检查亦可结束。这证明单点回收在机制上可能同时解除两关，不保证后续DCP写出必然成功。若count>1，必须先解释全部实际worker；移除其中一个只足以释放监视线程，剩余PID仍可卡住析构第二关。

NULL不会保留wait返回的退出状态，故原始Z/exit0证据必须先归档；还应保留实际调用返回值。返回0、-1或身份变化均不是回收成功，不允许自动改成waitpid(-1)、阻塞等待或反复试验。外部诊断进程不能以普通waitpid回收非子进程。

**当前仍不可直接实施。** 对已停止的原 guard 执行哪怕原生 libc waitpid 或 wait4 syscall，也需要暂时运行其执行上下文。理论上可以避免运行 Python 字节码，但无法据“调用很短”保证监督采样看不到 t/R/S，也不能自动保证原指令流、原寄存器/系统调用状态和最后T状态全部恢复。现 monitor 只接受原guard为T；一旦联锁进入fallback，可能先停止owned工具。原finite deadline已过，任何意外恢复Python正常监控循环还可能触发旧上限。

本轮要求的“不执行运行期Python代码、不重启Vivado、保持锁/父子关系、原guard最终仍T”均须由实际可审查且预先验证的短维护步骤保证；当前没有这样的已验证步骤，不能把原生调用或GDB的call本身当作安全方案。继续保持现场并完成v2只读确认；不建议kill父进程、强行return线程、改结束flag或直接CONT。A010当前授权仅准备独立v2字段读取器，没有获得本节所述生产回收的执行指令。


## AT019 v2 最小字段读取器实施审核（2026-10-26 10:44 UTC）

A014按root接续范围只读审核A010实际实现：`physical_d38/admin_harts_object_reader_d38.py`、`admin_harts_diagnostic_v2_d38.py`及其复用的冻结v1入口；未重复反汇编、未运行脚本或测试、未attach生产/读取生产内存/修改工程。最终实际重算身份为：reader SHA256 `389c4dcd41fc3c9deb84016684751decdadb31cd55f5dbca52d43e94c987492a`；driver SHA256 `75f3ea56536e1786f98fce471242a379cd5dc6381d3e6a502a7443247530c9af`；v1仍为 `6621497d6e4e815a2076ce565d9d820e7f5e8236c21b5149b17f0157c286e4b0`。driver内冻结READER_SHA已与最终reader一致。

**审核结论：未发现该版本字段提取或有界只读退出路径的实质缺陷，符合已限定的第二次管理员只读取证规格。** 本结论不是生产v2已执行、字段已取得或根因已确认；管理员执行与实际detach/字段结果仍须另核。

- 读取前固定PID/start与LWP/start（3634083/66421453），校验两ELF完整SHA、设备/inode、可执行PT_LOAD、实际maps路径与固定load bias。选择该LWP的frame0，PC严格等于libc+0xecbdf，其它PC直接失败。
- 栈字计算与此前已核prologue一致：B为frame0.rbp，验证16字节对齐、RSP及栈读数在同一可读写非执行映射；N=B+0x10、H=N+0x50及两个精确返回地址全部匹配后，才读取B-0x28保存的调用者rbx作为this。没有把当前rbx当this，也不依赖错误展开的后续候选帧。B对齐检查符合本次特定调用路径。
- count/flag/begin/end与PID偏移分别为0x10/0x131/0xe0/0xe8、记录+8，stride0x2050。`count <= vector_elements <= 64`是安全的保守收紧；它可能拒绝超出该形状的现场，但不会扩大读取。count为0如实记录，不先假定flag=1或PID=3633734。每次读前核可读maps，先验证所有PID地址再逐条取4字节。该decode函数显式read_memory合计最多317字节；这个上限不包括GDB线程枚举等内部读取。
- 所有字段/布局不符、读取异常会保存valid=false和已读原始值，不能被解释为已证明对象关系。PID<=0单独标明、不按普通worker解释；正PID的/proc快照仅补充身份，valid=true代表字段读取有效，不自动推断原因或采取回收。
- GDB显式禁止目标函数调用、内存/寄存器写入、断点/tracepoint；禁自动加载和debuginfod。读取器只有寄存器表达式读取和inferior.read_memory，没有执行目标代码的接口。source之后安排detach/quit；异常/超时采用20秒读取与最多7秒的原有有界清理，仅针对新建GDB独立进程组，随后核原PID/start、TracerPid=0及非T/t/Z。detach失败会留下失败收据，不会CONT生产或旧guard作补救。
- 审核提出的两处小入口加严已由A010实施并在最终版本核实：两新模块用非assert条件拒绝Python优化模式，防止安全assert被禁用；v2在冻结v1检查之上要求原guard恰为T且TracerPid=0。未修改v1、未增加目标字段或恢复行为。

A010已提供原plan-only、四个人造内存边界例和无inferior GDB安全失败的检查结果；最终两处加严后的同范围快检由A010负责。本审核未运行或代签这些测试，更不把人造字节/plan-only当作真实管理器观测。已有生产Vivado、guard、三监督和锁保持原职责；下一步仅是最终v2只读执行与结果核对，不包含waitpid/回收授权。


最终收尾补记：A014已读取A010的 `AT019_core_synth/post_synthesis_wait_diagnosis_engineering/v2_final_checks_20261026T104343Z/test_result.json`，其10:43:44 UTC结果为plan-only exit0、guard=T/TracerPid0、两模块优化模式入口拒绝PASS，明确未生产attach或读取目标内存。不变decoder的四例/无inferior测试按root收束要求复用旧版本收据，没有重跑。A014另仅在本地内存中去掉新增入口检查并还原driver的reader SHA字符串，所得两文件SHA分别逐字回到原reader978c9d与driver839c3e，确认实际算法及原detach代码未变；未向工程写回任何内容。root已独立核最终就绪记录 `.research-agent/automations/d38_report/reports/20261026_1844_harts_v2_ready.json`。本轮审核封存，可交付最终v2只读命令；实际生产字段、根因及恢复仍未发生，本轮不扩展。


## AT019 实际HARTS对象确认与自停回收核心审核（2026-10-26 11:09 UTC）

**实际v2已把唯一worker绑定到原guard持有的僵尸：当前收尾阻塞机制已明确。** A014独立读取 `AT019_core_synth/admin_stack_diagnostics/DG_OBJECT_20261026T104830Z_8a4d5837/` 的object_fields、capture、postflight、gdb、script_identity及冻结reader，并按原始地址重新计算，不仅依赖valid=true：B=0x77303abfc600、N=B+0x10、H=N+0x50，两层返回地址分别为libc+0xf9b27与synth+0x18869c5；保存rbx确由B-0x28取得，this=0x16b7e28000。count字段地址this+0x10实际为1；flag地址this+0x131实际为1；worker向量0x1542f02000..0x1542f04050恰为一条0x2050记录，+8的实际PID为3633734。该PID的同次/proc观察为start66420454、Z、PPID3582995、PGID/SID3583000，与既有候选身份一致。其退出状态0另有root 10:24:24原快照支持。

结合此前完整机器码：这个线程每5秒以kill(pid,0)检查上述唯一PID；PID仍存在的分支不检查flag。已退出但未回收的worker继续保有PID，故结束flag=1也不能使该循环退出；这解释了管理器析构等待。不是继续做综合网表计算，也不能靠重新设置结束flag解决。该对象地址与v1析构线程候选栈中的重复0x16b7e28000还具有辅助一致性，但两个pthread join的精确threadid仍未独立读取，不伪造完整动态调用链。

本次capture为10:48:30.870615Z开始，0.465525069s、exit0、无timeout/cleanup信号、detach_verified=true；原Vivado3583093/start66052106、TracerPid0保持。postflight旧guard仍T/TracerPid0、三监督存活，实际driver75f3ea/reader389c4d与审核身份一致，冻结reader重算SHA也一致。**这些是因果定位证据；尚未实际回收生产worker，没有恢复成功或DCP落盘证据。** 也不能把僵尸归因仅写成“guard暂停”；原正常monitor循环本来就不reap，当前直接障碍是该父进程尚未回收工具正在轮询的子进程。

证据SHA256：object_fields=`cc9c74587da72b2a6a6a25b75e794a682cde05ba7ba5352d1414dd803694dce2`；capture=`3603798f135d5f788659eb5f6d483be14766fa7ae84a74fc585bb1316c57148d`；postflight=`c9224a37218691d0893624fcfea5412d629fecc26262442474ef42b9d917b1a2`；gdb=`5f6c4260f8d1fb19e89f5f30b6f305dca34794a6c188be1e9427830ef4247a2c`。

### 监督状态条件更正及单点必要条件

本轮重新逐行读取实际冻结 `unlimited_wall_handoff/frozen/handoff_guard_d38.py`，L239接受 **T或t**；本报告此前关于“只有T、t自身也触发主monitor联锁”的表述不准确，在此更正。真正被该条件拒绝的是R/S/消失。旧watchdog只检查monitor身份存在与heartbeat<15秒，monitor为T仍算存在；observer亦没有对guard瞬时R/S直接触发的规则。v2诊断预检要求guard恰为T/TracerPid0仍是有意加严，不与该源码事实矛盾。

任何后继单点回收仍须操作前重新核guard/worker PID+start、worker为该guard的Z子、原exit0记录、工具身份、锁及无deadline监督。仅允许exact PID3633734的非阻塞wait4/waitpid，不能wait(-1)、误收leader、重启Vivado或让旧guard正常Python/过期deadline循环执行。count=1意味着该PID消失可同时满足监视线程和析构后续两关存在性检查；真实推进仍须观测原Vivado，不预签后续DCP。

最小监督候选只暂停主monitor单PID，watchdog/observer在线；独立有界维护与救援承担窗口内RSS/系统余量/owned/锁检查，不修改长驻代码、不把原15秒heartbeat余量当唯一保障，不写伪造heartbeat。必须先证明guard真正T、原上下文/字节已恢复，才恢复主monitor。该外层交接当时仍由A010实现/验证，以下核心通过不能代签整个维护入口。

### 无代码写入的单STEP候选已被真实反例否决

A014读取旧隔离probe源码及normal、before_step、during_step原记录：`guard_single_syscall_probe_1793012176366141368/tracer_killed_during_step/observed.json` 明确tracer_exit=-9、guard4142907/start70182259从T变为S，worker已消失，锁仍持有。故“原SIGSTOP会在tracer意外死亡后自动保证guard仍停”不成立；正常路径及before_step通过不能弥补这个窗口。该记录的python_resumed=false只代表当次未看到延后标志，不证明守卫没有恢复执行。核心要求的最终T已直接失败，因此这个候选禁止进入生产，不继续靠采样速度规避。

反例SHA256=`fac12f50a51d808958d7d67f9c8b2945ddb22385593aaf19c4ccb3b1780118a3`。该probe是隔离小进程，不涉及生产guard/Vivado；未完成的后续故障分支没有伪记PASS。

### 固定原生自停核心：选址与限定接受

root另行允许隔离评估后，A014只离线确认严格ELF映射尾padding，未扫描任意函数代码洞。固定SHA libc的RX PT_LOAD：fileoff=vaddr=0x28000、filesz=memsz=0x188039，真实段和.text结束均为0x1b0039；页映射末端与下一RO PT_LOAD/.rodata起点均为0x1b1000。因此0x1b0039..0x1b1000有4039字节段外页尾，磁盘全零。选用ELF+0x1b0040..0x1b0070的48字节，当前guard映射bias0x77f6f6600000，对应0x77f6f67b0040；须以操作前guard自己的真实maps及目标48字节全零再次核实，磁盘零不能替代目标读数。48个零的SHA为17b0761f87b081d5cf10757ccc89f12be355c70e2e29df288b65b30710dcbcd1。

核心 `guard_selfstop_native_d38.py` SHA256=`89cd5cfa91888f2e8cc0bc4329fc793a4429ff712ae146e806fa3d0fff556577` 实现44字节原生stub加4字节零：一次SYS_wait4(exact worker,NULL,WNOHANG,NULL)，将返回值暂存r12，然后SYS_kill(positive self PID,SIGSTOP)，短跳只回自停段。wait4 syscall在stub+0x14，stop段在+0x19，末尾eb ed从44返回25，不会循环再次wait4。没有call/ret、堆栈读写或跳回旧Python的路径。仅临时修改该guard私有RX页；不改磁盘libc、不触Vivado代码或内存。这是一项真实目标代码修改，后续管理员动作必须明确说明，不能继续称纯只读诊断。

A014核实际实现：仅单LWP、PID/start/T/TracerPid0可进入；完整寄存器及原48字节先保存，目标原字节须逐字为零；ELF hash/PT_LOAD/下一RO段/文件padding/maps全核。执行后先通过detach(SIGSTOP)和/proc确认真正job-control T且TracerPid0；随后重新attach/interrupt，从T恢复原字节/完整寄存器并回读，**恢复过程中不restart旧上下文**，最后仍detach到T。异常执行者必须由外层作为独立短进程退出或有界终止，不能长期保留一个仍持ptrace的异常执行者；核心本身不是完整生产维护监督。

A014未运行测试，只审核A010真实9例及源码。`guard_selfstop_tests_1793012624052245119/test_result.json`（SHA256=`cd80b7e6784d5efe63f1329dd6ed3f4dd12684f3e9b5c5fa54e61788f9837eb6`）共1.409058773s，源码test SHA=`a628721a55230f2135ec4d54072a7af0feafeebf668103f3def346ad861f1632`，与实际文件一致。覆盖normal、before_write、partial_write、after_registers、running_1、before_real_stop、after_real_stop、restore_partial_write、restore_after_registers；重点独立读running_1、signal-delivery-stop附近及两恢复故障原记录，均返回T/TracerPid0、最终regs/48B逐字还原、锁保留、leader同身份且存活。normal测试源码还明确发一次意外CONT，再验证自停回T。执行前故障保持worker Z；执行后故障只回收指定worker。各fixture最后实际检查guard/leader/zombie均清理。

**限定接受该固定自停核心及已测故障点；不把9例升级为任意故障形式证明，也不代签尚待审核的monitor交接/独立救援。** 测试中old_python_marker位于60秒睡眠之后，在1.4秒测试内未出现只能作辅助观测；不回旧Python的判断主要依据闭合原生控制流、真实停态与完整上下文恢复。未重跑未变化9例，未对生产做attach/内存写/信号/回收；本轮仅A010执行隔离小测试，A014只读审核并追加原报告。


## 后续阶段防复发定点回收窄核（2026-10-26）

A014只读核对A010按root授权修改的canonical `physical_d38/run_physical_d38.py`，重算SHA256为 `42164971755a1dcc57a01ddc0c9101cb6af19a2db5506924a2debd7007569f89`。`reap_adopted_zombies`仅允许known中的精确PID/start、PPID为当前guard且已为Z的子进程；排除leader和显式managed Popen。调用前重新读取stat校验start/PPID/Z，仅执行 `waitpid(pid,WNOHANG)`，没有wait(-1)或阻塞等待。采集原始wait status、解释后的exit code并写专用记录；主循环及finally均调用，原leader的退出码仍由其Popen poll/wait取得。此变更不触及资源、stall或wall-time判断。

实际隔离测试 `R001/adopted_reap_tests_1793013134986611194/test_result.json`（SHA256 `1dd4b891bba4f37d017dc6a4c91ecdf78a1b901527c945a9434671eda8fbb6e1`）与测试源码（SHA256 `c37a25bdcdf5e070193ffe1fff71648feba161d11541fd53edc5e2c137406873`）相符：真实收养孤儿Z退出11被精确回收；leader退出7与managed退出13均保留；nonowned Z、错误start Z和仍运行子进程均跳过，第二次调用无重复回收。A014未执行测试或EDA。

**接受该防复发补丁的限定职责。** 它只覆盖实际被owned发现并记录的后代，不声称能识别从未观测到身份的任意孤儿。新阶段加载canonical版本后才生效；当前AT019冻结runner仍为 `f8c1886ab93b9925c683a79c11653cc9eb69673eea4a8ff0e317b8edd314ab61`，本次重算未变。补丁不会回溯改变已加载的原guard，也不等于当前生产僵尸已回收或DCP已完成。


## 单monitor维护、独立救援与固定管理员入口最终窄核（2026-10-26）

**A014限定接受已封存版本及其已测故障范围，可交root作管理员动作审核；这不是生产执行授权，也不是恢复已发生或DCP已成功。** 本轮只读源码、已有plan/隔离收据与原记录，未运行测试/EDA、未attach生产、未读取生产目标内存、未发信号或回收进程。仅追加本报告。

最终实际重算SHA256：

- 固定入口 `physical_d38/admin_exact_child_reap_d38.py`：`c3bedb2648eb5b2724ccf999902434f66b5b6a14e5fe7afa5b798cb976afea9f`。
- 外层 `guard_reap_maintenance_d38.py`：`5a52d2d3cfc657920ad57532926ecfb60417554a13e3bf47d2074be481356003`。
- 原生核心保持 `89cd5cfa91888f2e8cc0bc4329fc793a4429ff712ae146e806fa3d0fff556577`，不重跑未改九例。
- 外层测试源码保持 `9f14b42e6e632b57b2d6505b4069c46310515a341aed5d7e9ffd618220724df3`。
- 最终五例收据 `R001/reap_maintenance_tests_1793013667619000659/test_result.json`：`f180d37d6641eb6c886dc25c95594a3cf81b5b7062760cfbdb2a2e2f789c4cc7`。
- 准备就绪收据 `R001/exact_child_recovery_ready_receipt.json`：`47ddeda99890c33a0e188df14580833dc16bec1feed008a55e5c405416140150`。

### 实际交接与期限机制

管理员入口先固定校验v2证据SHA、count=1、flag=1、worker3633734/start66420454仍为guard3582995/start66052065的Z子、PGID/SID3583000、原exit_status_raw=0；固定库/映射/单LWP与已核guard RX padding由原生模块再核。默认plan-only不attach；`--execute`要求管理员身份，明示将临时修改guard私有RX页48字节及寄存器，绝不称只读。Vivado不被attach或发信号。依赖校验及优化模式入口拒绝保持生效。

进入前把原完整寄存器和目标48零字节快照保存为journal，且先持久写出维护意图与同一monotonic+4截止时间，再仅对主monitor单PID发送STOP。watchdog、observer维持在线；不停止进程组，不修改它们的长驻代码，不写原heartbeat。A014另重算测试使用的handoff/observer SHA，分别4ead4e76…6b8aa1ec与325c2e68…6ae220b，均与AT019冻结副本逐字一致。

worker与native helper均为新进程，独立coordinator在worker之外持续采样：锁及inode、known身份所覆盖的owned RSS、MemAvailable、nice/CPU affinity、三监督身份和fallback文件。ps采样本身有不超过0.2秒的超时；原生产配置继续使用RSS256GiB、MemAvailable大于192GiB、CPU0–3/nice19/idle、无wall-clock上限。外层没有重置原monitor内存中的stall进展时间；短暂停顿后由同一原monitor继续原语义。

native执行约0.6秒预算；未出现恢复记录时coordinator在维护起点约1秒后接管。worker死亡/超时后，救援先确保该worker结束，再按PID/start终止属于本次操作的tracer，保证不并发恢复。先让guard达到真实T且TracerPid0，调用已核核心恢复/回读原48字节与完整寄存器，落盘恢复证据，再在CONT主monitor紧前复核统一剩余预算。之后等待原monitor自己产生新heartbeat，正常/backup路径均记录统一窗口和截止判断。

A014发现并促成两轮局部收口：初版仅事后assert四秒、ps无timeout；中版先STOP后才写截止记录，worker若在间隙退出会另获新四秒。最终版本已改为先记录维护意图、缺记录不重新授予暂停预算、coordinator保守起始deadline及CONT前再检查。当前四秒是该实现与已测故障的操作期限，**不是任意内核调度、不可中断I/O或文件系统停顿下的实时保证**。

### 实际五例与边界

最终收据使用真实原handoff monitor/watchdog/observer和已过期的两秒toy guard，五例安全恢复均PASS：normal 0.138645s、before_write 0.305708s、native_timeout 0.847482s、native_killed 0.485658s、worker_killed 0.182196s。旧Python计数分别5→5、8→8、5→5、8→8、8→8；guard为T，锁和同身份leader保留，无原监督fallback、无heartbeat伪写。worker_killed原始restoration记录确认由独立coordinator恢复guard4162016/start70332767为T/TracerPid0，完整48字节/寄存器验证完成。11:23:10 UTC补审收据逐项列出五组共40个toy guard/leader/Z/monitor/watchdog/observer/maintenance worker/native tracer身份均已从/proc消失，未把遗留fixture当成功。

只有normal的operation PASS为true；另外四例operation PASS仍为false并保留相应退出/超时错误，外层测试PASS代表故障后的安全恢复通过，不能写成五次正常回收成功。before_write确在monitor已暂停、尚未写native字节时触发，不冒称暂停前入口故障实测。暂停前和自然完成边界本轮主要由静态顺序核查支持，没有增补或伪造相应注入案例。

恢复交还瞬间必须有T/TracerPid0与完整上下文/字节恢复证据；交还后原作业可能自然完成，此时读原receipt/owned清空结果，不强制原guard永远T，也不拿恢复前的live-process预检否定自然退出。管理员成功判据仍要求本次native wait4实际返回精确CHILD、原僵尸身份消失、coordinator成功及统一deadline通过。该动作成功与原硬件阶段验收分别记录。

若上下文恢复失败或截止已过，不为强行交接而CONT主monitor；失败记录保留guard/monitor/helper和恢复状态，原watchdog/observer继续其既有失联兜底。管理员七秒总调用超时只结束新coordinator，单独worker仍有自己的期限；不会自动再wait4、盲CONT旧guard或广泛清理生产进程。该异常边界可能保不住原长作业，不能从隔离PASS推导“所有故障均无损”。本次验收范围是已核闭合原生控制流、独立worker救援及列明故障点，并非协调器/OS任意组合失效证明。

截至本审核封存，最终plan-only与准备就绪收据均明确未生产恢复、未切换生产监督；root负责后续授权与实际结果判定。后续应分别核真实wait4返回值、恢复证据、原Vivado推进、DCP/阶段receipt，再判断硬件结果；当前不预签资源适配或时序通过。


## AT019 实际精确回收结果增量审核（2026-10-26 11:45 UTC执行）

**实际恢复成功：指定僵尸被精确回收，原guard上下文和48字节恢复校验通过，同一Vivado已越过原等待并进入网表转换。** 本节将此前“尚未生产回收”的状态更新为已执行且已核；不把这一结果升级为DCP、综合阶段或物理实现完成。A014按root要求仅增量读取实际RC记录与新日志，未重审/重跑已冻结机制，未启动EDA、发信号、attach或读取生产进程内存。

实际证据目录为 `AT019_core_synth/admin_stack_diagnostics/RC_EXACT_20261026T114520Z_9baee073/`。preflight时间11:45:20.693595 UTC，入口记录SHA `c3bedb2648eb5b2724ccf999902434f66b5b6a14e5fe7afa5b798cb976afea9f` 与已接受版本一致；该次冻结core、maintenance、handoff文件重新计算分别为89cd5cfa…556577、5a52d2d3…356003、4ead4e76…8aa1ec，均吻合，未以准备阶段测试代替此次执行结果。

- 操作前真实child为3633734/start66420454、Z、PPID3582995、PGID/SID3583000；journal绑定原guard3582995/start66052065及同一child。native_result实际 `wait4_return=3633734`，保存的r12亦为3633734；停止RIP恰为所选slot+42，即原生自停syscall之后，原RSP保持。postflight的original_child为null，证明该次精确回收确已完成，不是仅发送停止信号或报告计划成功。
- journal原48字节确为全零，SHA为 `17b0761f87b081d5cf10757ccc89f12be355c70e2e29df288b65b30710dcbcd1`，位置为0x77f6f67b0040；保存了此前约定的27项x86-64通用寄存器结构字段。实际restoration在11:45:21.266085 UTC记录原guard同PID/start、真实T/TracerPid0及 `full_registers_and_48_bytes_verified=true`。该证据来自此次冻结核心实际执行的逐字回读/寄存器比较成功；没有另行导出恢复后全量寄存器/字节原值，A014没有假称做第二次生产内存读取。
- 保存维护意图到完成恢复为0.088498s；统一维护窗口0.901117602s、worker0.852216477s、coordinator1.037309292s，管理员包围调用1.248205594s。coordinator exit0、operation PASS=true、deadline通过、未使用backup。恢复证据比原monitor新heartbeat早0.708295s；heartbeat从11:45:20.909705推进到11:45:21.974380，间隔1.064675s，原monitor3595603/start66153245已回到R。原heartbeat没有由维护代码伪写。
- 原Vivado在pre/post均为3583093/start66052106，PPID3583020、PGID/SID3583000、TracerPid0、同一AT019冻结Tcl命令行；原guard前后均为3582995/start66052065、T、TracerPid0。维护配置仍绑定leader3583000/start66052093和原锁inode156929132，RSS256GiB、MemAvailable大于192GiB、wall limit为null。13个coordinator样本均锁持有、active_owned=3，RSS约95.220GiB，最低MemAvailable约347.280GiB。所有helper stdout/stderr为空，无error.json或failed_closed.json；独立文件result/restoration/native_result与postflight内嵌副本逐项一致。

**根因获得实际干预实证。** 此前实际HARTS对象已确认count=1、flag=1、唯一轮询PID正是该未回收僵尸；此次仅回收该PID并还原guard，没有触碰Vivado内存或重启工具。随后原 `vivado.log` L7596新增 `Synthesis Optimization Complete`，L7597为 `INFO: [Project 1-571] Translating synthesized netlist`；日志mtime为11:45:24.789448 UTC，距离回收/恢复约3.5秒，符合既有五秒存在性轮询机制。该前后关联直接支持“该僵尸保有PID阻挡HARTS清理，精确回收解除当时等待”的判断；不补写未经采集的精确pthread join目标或其它线程现场。

11:47:44 UTC原handoff状态继续为三owned活跃、guard T、trigger=null、stall进展年龄0、无wall limit；observer记录monitor/watchdog存活、fallback_confirmation_pending=false。审核时checkpoint目录仍空，AT019无stage_complete.txt或receipt.json。故当前只确认原运行恢复推进至网表转换，尚不能确认DCP写出、阶段验收、全top资源适配或时序通过；既有LUT原生计数风险也不因基础设施恢复而消失。原serial由工程继续，本轮没有重复启动或复测。

本次核心证据SHA256：preflight=`a66563426764efb40674023b899c1692882636add628c01a5448f882ffdbb26b`；journal=`b5c1454af5ebe993b31fef02cbf546494abe247936e63fa269ea7641dce91b4a`；native_result=`95563ec2427adf22c797a28fcab70cdcad5bed46a610650200c9962c2dac630a`；restoration=`b7b34be753fdddb21518a62a65c3807f7552cb8e4fd5c5e1cbeb6abaaeb7a2cb`；result=`b995831ecddf18d64d9e78e034a322420585f9ee7db3dbbdb190af002b4ec760`；postflight=`725070fa4cf3137fa69b3cef180e8063c267429d6479043a60a5398e1ac10168`。此次读取时日志885161字节，读取前后size/mtime稳定，SHA=`a9440d045696e8c9248821ce48c86d880404bfab6b65b7361681ca2a4ed07a5d`；该运行日志仍可继续增长，此SHA仅标识本次审核快照。


## AT019真实DCP完成与AT020综合态资源异常集中审核（2026-10-26）

**当前完整矩阵core的综合态资源不通过：已计LUT combining的CLB LUT为2,139,515，超过器件可用量1,303,680，也超过用户为整个kernel设定的900,000预算。建议优先对同一真实core DCP进行一次受控opt及前后资源定位，再决定全父装配；不把“尚未测最终fit”用作继续无条件重阶段的理由。** 本轮只读取root限定的完成/成本/身份收据、AT020已完成资源报表及当前日志，未改RTL、架构、预算或执行计划，未启动任何EDA，未中断正在运行的AT020。

### 完成身份和证据口径

AT019原receipt与unlimited-wall effective receipt均为PASS、child_exit_code=0、guard_trigger=null、owned_after_cleanup为空、source_verify_after=true；有效收据另确认external_guard_trigger=null、原锁已释放。二者、core_synth.identity及completion audit的source_identity逐项一致。checkpoint身份记录为 `core_synth.dcp`，520,296,664字节、SHA256 `a92039524cb313526500315841ecbbdeff0c2f1a5fd971b1680a3ca9b3b23f90`，本次独立stat大小吻合；不另启动工具读取/重写checkpoint。scope marker明确 `top=laya_m007_matrix_engine_v1`、blackboxes为空、`full_kernel_accepted=0`，stage marker明确仅子树/中间结果。identity内的parent top字段属于既有源配置上下文，不改变实际报告设计为matrix core的范围。

实际累计wall时间50,108.013762秒（约13小时55分08秒），有效峰值owned RSS172.063992GiB、最低主机MemAvailable285.097225GiB。原guard在交接前的较小内存统计不是全过程峰值，应使用effective统计；管理员恢复的耗时已包含于同一次原运行wall时间，不另重复累计。completion audit记录旧guard/Vivado/monitor/watchdog/observer五个身份全部退出，原serial验证释放锁后启动AT020_report_core；这是一次原运行的真实PASS出口，不是重跑core。

AT020日志明确打开上述core_synth.dcp，报表头为Vivado2025.2、器件xcu55c-fsvh2892-2L-e、设计laya_m007_matrix_engine_v1、状态Synthesized。utilization、hierarchical_utilization、ram、clocks均有REPORT_END；其原文件与engineering_resource_snapshot逐字相同，SHA与resource_finding记录吻合。因此无需等待整个报告阶段receipt才能接受这些已完成资源表。审核时日志仍在check_timing，stage_complete/receipt未形成；不将分项报表完成冒称AT020总体PASS。

### 已发生的资源超额

| 资源 | 当前core | 器件可用 | 用户全kernel预算 | 当前含义 |
|---|---:|---:|---:|---|
| CLB LUTs（已combining） | 2,139,515 | 1,303,680 | 900,000 | 器件164.11%；全核预算237.72%，两项均超 |
| FF | 1,391,977 | 2,607,360 | 1,800,000 | 器件53.39%；全核预算已用77.33%，余408,023 |
| DSP | 4,352 | 9,024 | 7,200 | 器件48.23%；全核预算已用60.44%，余2,848 |
| BRAM tile | 0 | 2,016 | 1,200 | 仅表明本core没有映射BRAM |
| URAM | 0 | 960 | 640 | 仅表明本core没有映射URAM |

寄存器全为FF，latch=0；LUTRAM/SRL亦为0。CARRY8=37,476、F7 MUX=402,340、F8 MUX=196,736。BRAM/URAM空闲不能在当前网表中自动抵偿LUT超额；FF/DSP在各自上限内也不能抵偿LUT不通过。

当前LUT比器件多835,835（相对器件超64.11%），比用户全核预算多1,239,515（相对预算超137.72%）。从当前值回到器件上限至少要削减39.0666%，回到900,000至少要削减57.9344%；后一个数还没有给facade/resident/parent及其它全核逻辑留任何LUT余量，故是必要而非充分目标。

原native LUT1–6实例和2,456,134不是这次应采用的资源总量；已完成报表已将combining计入，得到2,139,515，差316,619。不能再把“稍后会LUT combining”作为未经量化的额外减额承诺。报表确实另注明opt_design/物理优化后计数可能下降，因此不能据综合态直接断言所有合法后继都不可能装入；但该提示没有给出本设计能削减39%或58%的任何证据。

### 超额来源已定位到哪一层

hierarchical报告L25–27及L94的同一层分项如下；顶层合计与本层/子实例三项精确相加，不重复累加子孙行：

| 分项 | LUT | 占core LUT | FF | DSP |
|---|---:|---:|---:|---:|
| matrix_engine_v1本层直接逻辑 | 1,946,767 | 90.9910% | 1,065,794 | 0 |
| dot_array完整子树 | 137,962 | 6.4483% | 272,916 | 4,096 |
| format完整子树 | 54,786 | 2.5607% | 53,267 | 256 |
| 合计 | 2,139,515 | 100% | 1,391,977 | 4,352 |

本层直接逻辑单独就超过器件643,087 LUT、超过全核预算1,046,767 LUT，并持有76.57%的core FF。故当前主要LUT缺口并不来自报告中只有137,962 LUT的dot_array；只盯4,096 DSP点积子树无法解释90.99%的本层用量。AT020开DCP日志也提示core cellview包含大量直接primitive，层级表不能再把这些本层资源自动细分成RTL语义模块。

大量本层FF、F7/F8 MUX和零RAM映射值得优先查来源，但本次报表不足以确认是某个缓存、权重选择、复位结构、索引展开或其它数据通路；不能未经网表名称/源对象对应就宣布根因或实施RAM化。最小定位产物应将本层LUT/FF/MUX按可追溯且互斥的网表名称/源对象分组，列出主要对象、原语类型/数量与未归类余量；若来源属性不足，应明确未知，避免将推测当归因。

### 最小有价值后继与判定出口

建议root正式派发一个独立的同DCP实验，在AT020由现有owner结束并完成边界持留后串行运行一次opt_design。原DCP及identity只读保留，候选优化DCP另存，输入绑定上述SHA；不重跑综合，不做directive扫参，不更改RTL、器件、数值规则或预算。保持已有3.333ns时钟及约束、全部core公开接口及完整功能cone，不借dummy tieoff、删端口/输出、缩小工作模式或解除保留属性来制造资源下降，也不以虚构外部时钟源位置掩盖OOC时序警告。

同一次实验应有opt前后同口径utilization、hierarchical utilization和原语分项，尤其核对1,946,767 LUT本层的变化与来源；记录接口/约束一致性、实际优化命令、工具信息、耗时/峰值内存/退出状态与新checkpoint身份。利用已有未优化报表作基线，确认读入同DCP后只需避免不必要重复报告。比较目标是量化当前真实网表的合法优化空间并定位主要保留逻辑；该实验仍只属于core，不签完整parent/kernel或300MHz实现验收。

一次opt后的出口应集中判断：

1. 若仍大于1,303,680 LUT，该完整core候选仍超过器件容量，不能继续直接place/route期待布局自动解决主要数量缺口；带着前后差值和本层来源包返回集中架构/映射审查。
2. 若不超过器件但仍大于900,000 LUT，core已单独违反用户全kernel预算，仍为资源门槛不通过，同样返回集中架构/映射审查，不默许提高预算继续全父重阶段。
3. 若不超过900,000 LUT，仅满足一个必要条件；必须将剩余900,000减去core用量的LUT余量与FF/DSP余量一起供全父装配决策，并在真实全核报告中再验预算。余量不足不能因core单独低于900,000就放行。

架构出口应先给出经实际网表证明的主要资源对象、其接口/并行访问/复位/读写语义及保留功能约束，再由root组织选择合法实现映射或架构修订；本轮不选择或修改这些方案。继续全父装配的价值主要是集成验证及真实上下文优化，只有可核实的接口/功能约束理由或资源余量支持时才值得追加；当前本层已严重超额，而同DCP一次opt能直接检验最关键的未测假设，成本和判别价值更合适。

直接进入place目前没有足够理由：当前已知LUT超器件64.11%，且仍在core层；place增加时间和主机资源成本，不能替代先量化opt后的资源可行性。这里不预言最终fit永远失败，而是明确当前候选没有通过继续重物理阶段的资源门槛。

clocks表3.333ns只是约束；日志还明确OOC clk未设HD.CLK_SRC、时钟延迟/偏斜不可据此准确估计。无论一次opt后资源降多少，都不能从该时钟表或未完成check_timing推出300MHz routed timing通过。

本次证据身份：completion audit SHA=`7024ecb447c9e5c29f71f3d2acaaf2f2060baa0598beeaa0927bce05678913b5`；cost=`6d57a31ac1669273a34c738c251c2277dce90625ebfe593aa87b2ebd5572d60d`；checkpoint identity=`045a30e7031f1eb4c4079a2094130abcf1863093c0cac7250bed0f99ca247a7f`；raw receipt=`af4dea69062924930a997b3b63bc435ca2a86f7daaccda6e06643a282851d3cf`；effective receipt=`68564f729201e5f0de57c673376a52ea4ada7f6281629f2da0b53a2e9500d41b`。utilization SHA=`0e1bc880ad81d66e93a7ce76443f675350f5106e572fcacafc11c44cd8b2e101`；hierarchical=`5fde63ca1b8078606f132aeb4c060783a3b50ff719c3c05b338b57c615023f37`；ram=`51b2967cc5ba679c3930c75e4d06a2f81b6daec621e73afb00e2fbbd7059e001`；clocks=`7e378c64e8dd371c087f232051fe3e1a9fcb907f58f37820a19850a615f8f3d9`；resource_finding=`9137b6c73adcac0f09d2e5740d95157e49e7c2075af10d97e693ee53a26cff2b`。


## AT020综合态时序/DRC实证与首错归并链源码绑定（2026-10-26）

**新增实际结论：当前综合后完整matrix core不满足3.333ns时钟，且UTLZ-1已明确报Error；最差setup路径可绑定到错误候选的线性比较/选择归并。** 该判断来自已完成的timing/setup/hold/DRC原报告和AT019真实冻结源码，不再只是“时序未测”。它仍不是placed/routed结果或全kernel验收。本轮只读增量核查，未改源码、接口、数值/错误规则、约束或执行流程，未启动EDA；已授权的一次同DCP opt诊断合同保持不变。

### 实际报告核对

`AT020_report_core/reports/timing_summary.rpt` L173505–173510明确：WNS=-1289.339ns、TNS=-301158.188ns，setup失败132,577/3,273,333端点，`Timing constraints are not met`；WHS=0.065ns、THS=0、hold失败0；pulse失败0。clock为core、period3.333ns。check_timing列no_clock=0、unconstrained_internal_endpoints=0、loops=0，另有60,880个输入和112,483个输出未设I/O delay。OOC缺HD.CLK_SRC及大量未约束外部接口限制完整时序验收，但本次最差是同一core时钟的内部寄存器到寄存器CE路径，不能据这些限制忽略其已报告setup失败。

A014只流读95,473,184字节setup_paths中的首条完整路径（L16–20365，共1,909,433字节，在第二条Slack前停止），未将95MB全表展开。原文header与工程有界摘要一致：起点 `n_reg[1]/C`，实际数据从其Q端进入组合逻辑，终点 `error_col_reg[0]/CE`；数据路径1292.568ns，其中logic359.024ns、unplaced route估计933.522ns。两个分项之和1292.546ns与总量相差0.022ns，本审核原样保留，不擅自判定差额原因。

逐行独立数出6091个组合逻辑级：CARRY8=2032、LUT2=840、LUT3=72、LUT4=1074、LUT5=110、LUT6=1963，与工具header完全一致。路径开头经n[1]、out_col选择逻辑进入error_key，随后反复经过error_key/error_col和cycle_numeric命名的carry/lookup选择链，末尾经error_row比较逻辑驱动error_col寄存器CE。路径内`error_key_reg[...]_i_*`等名字对应的实际primitive仍为CARRY8/LUT，不能因名字含reg就当中间流水寄存器。即使把unplaced route估计暂时置零，当前映射的logic359.024ns仍远大于3.333ns；因此这是实际组合深度问题，不能仅解释成布线估计悲观。opt可能改变映射，但收益须另测。

`reports/drc.rpt` L31、L40–42明确UTLZ-1#1为Error：本设计需要2,139,515个LUT as Logic，而目标仅1,303,680个兼容site；错误没有降级。其余为DPIP-2 8,192条、DPOP-3 4,096条、DPOP-4 4,352条warning及CHECK-2 48条advisory。日志的`report_drc completed successfully`与REPORT_END仅证明命令完成，不表示DRC通过；DPIP/DPOP描述DSP流水结构，不能替代这次error-control长链的来源证据。审核时methodology仍在运行，尚不把分项完成升级为整阶段验收。

### 冻结/当前源码身份与准确对应位置

AT019 `frozen/sources.tcl` L57实际读取 `R001/input/rtl_v3/laya_m007_matrix_engine_v1.sv`；冻结source_manifest L798–805记录原/冻结SHA均为 `f8493b130354123a57115f85bc1d6cdeab776a64697234962063604594b9c1cd`。本次重算该实际冻结文件与当前 `project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/rtl/laya_m007_matrix_engine_v1.sv`，均34,369字节、同一完整SHA，逐字一致。因此以下行号对两者均有效，并非把后来改动错认成本次DCP源码：

- L117声明16位n；L310在合法命令处写入n。L151–154的global_column读取n：n==5248选择32列/2624偏移映射，其余为64*block_s+local_n。这解释n_reg为何能进入错误列候选的控制cone；路径初段实际n/out_col→error_key与之吻合。
- L120–121定义persistent error_key及共享的cycle_numeric、cycle_numeric_key、cycle_r/c/g/stage。L155–160的numeric_candidate用32位candidate=`(r*8192+c)*256+g`，以 `!cycle_numeric || candidate < cycle_numeric_key` 选择并通过blocking赋值更新同一组共享临时变量。
- L281开始的always_ff在非reset分支L293先初始化该拍共享候选；多个调用均在这一次过程执行中按程序顺序读取前一次调用更新后的值，不含迭代之间的寄存器或显式平衡树。always_ff语法本身不会把for的每次迭代分成不同拍。
- 条件候选调用位置及展开上限：L329–332权重返回16项；L343–346 format错误256项；L349–352乘法返回256项；L376–379普通加法返回256项；L391 bias加法返回256项；L400–403输出检查32项；L425–428另有cancel候选1项。静态合计1073个条件调用位置。这个数不是“同一拍必有1073个有效错误”，普通/偏置加法条件还由tag区分；它表示综合展开后共享归并依赖的规模，不与6091逻辑级或2032个CARRY一一等同。
- L431在最终cycle_numeric候选基础上，再与持久error_key作严格小于比较，更新error_row/error_col/error_group/error_stage并设置aborting/status；L432的protocol分支随后优先写status=3/error_stage=7。最差路径尾部到error_col CE符合这一条件更新结构。

这段RTL的语义是按程序次序的最小键归并：第i次有效候选要比较其key与先前已选择的key，再决定后续使用哪一组payload。严格`<`使同键保留先前选中候选，stage不参与key，但随被选payload保留；跨拍持久error_key也仅被更小key替换。因此它不只是“找第一个置位bit”，不能未经论证用另一种优先编码替换。源码共享blocking递推与实际路径中反复出现的cycle_numeric/error_key比较选择段共同证明：本次映射确实形成了很长的线性归并控制链。

绑定范围也须限定：现有报告没有给每个生成门的HDL行/循环迭代唯一映射，A014不能把6091门逐个指定到某个i，更不能由一条最差路径推出此前1,946,767个本层LUT全部由此归并产生。此次已确认的是最差控制cone及其顺序依赖来源；核心本层总资源的互斥名源归组仍属于既有opt诊断的定位工作。

### 对既有一次opt诊断的影响

不改变现有同DCP、完整接口/功能cone、同器件/3.333ns、不tieoff/剪功能的实验边界。将上述error-control cone作为opt前后观察项：保留其起终点与实际逻辑级、CARRY/LUT分项和有界路径摘要，检查优化是否改变共享归并长链；结合已要求的资源前后值观察，避免仅报LUT降低而忽略仍存在的巨大setup失败。无须为这个发现增加新的综合/布局尝试或再生成50条巨大路径文件。

若opt后该链仍深且时序显著不通过，届时与资源结果一并进入集中设计决策；未来任何候选都必须保留最小键/同键次序、错误payload一致性、protocol优先级及外部可见周期语义。本轮不实施树化、流水化或其它RTL方案，也不预签opt能自动修复该问题。

证据SHA：timing_summary=`130c1aaf1b5adcbf957faeb02fc48fd277b60d9e9ccce06f845c70fff2aaf60d`；hold_paths=`ea00cd3fe3e8926a4ab76b41cf8ee8d0125552a1b8e07a320cd284c265143128`；drc=`86c69993da2cd312e7c107f4be3d6923c66137fc3756ac91e3d1f56f8c957c36`，本轮均重算吻合工程记录。首setup路径有界片段SHA=`296f04071a6144513e98c3b442eb221c2cb067afa0eb13351798d879067e50cb`；全setup文件SHA `4ead17f32a680a9325205884314de06106574f2ba5fbca3410d2a8373fd417d5`由工程收据保留，本轮未为重算其全文件而越过有界读取范围。timing_finding=`51a8da177b99a4719292d922dedb80d325b0473f3e948cb61f0714a50a3a200a`；worst_setup_path_header=`18d16444491c7fd4bbef339a4c1eb88427051fc1f43e825c8b850b70b8ac205f`；drc_finding=`93855ac65d3baba6475749a227131e31d176121c46fd19fe38467b799d9782a1`。


## AT021–AT024唯一opt诊断终态审核与D38阻塞归档（2026-10-27）

**授权的一次opt及后续报表诊断已经完成；候选core资源FAIL、已观察setup FAIL，完整物理目标保持blocked、未完成。** 优化没有解除继续全父装配/place/route的资源门槛。本节只增量核既有文件，未启动EDA、测试或新测量，未改RTL、接口、数值、约束及预算。主控已接受该终态，并反馈任务/控制台已记blocked、阶段timer配置及systemd timer/service已关闭且inactive/dead；此处如实记录主控收尾，不冒称A014执行或独立复测了该管理动作。

### 执行身份、完整边界与成本

原始`core_synth.dcp`继续保留，身份SHA为`a92039524cb313526500315841ecbbdeff0c2f1a5fd971b1680a3ca9b3b23f90`；独立候选`core_opt.dcp`为493,065,634字节，身份SHA为`97426945bdf39b3ad1b6e0056583fa5153df570018efb219a017e9a87ca942f3`。本轮核identity/收据，不再次全量读取大型DCP。四次receipt与原/新checkpoint identity的source_identity逐项相同，仍绑定f849冻结矩阵源码、91项源闭包、ROM、11个parent参数和原3.333ns XDC；source_verify_after均true、original_core_checkpoint_unchanged均true。

实际`opt_design`只在AT023执行一次，日志L69–70为invocation=1及实际命令，L226–228为成功和END；AT024仅重新打开候选作报告。AT021/AT022在opt前因checkpoint顶层身份API误判而FAIL，分别将设计对象名/空fileset TOP误作实际RTL top；两次失败保留，不计作两次opt、不删成本。修正后核实actual_report_design为`laya_m007_matrix_engine_v1`、器件`xcu55c-fsvh2892-2L-e`；`checkpoint_core_synth`只是checkpoint设计对象名。完整kernel仍`full_kernel_accepted=0`。

A014本轮逐字比较AT023 before/after及AT024 reopened三组完整文件：190,017行标量ports完全相同，SHA均`7e3f0ffc8a6fc14f738ac825fa60577e83874a5cea076d78cd79cedcaa244b2d`；boundary SHA均`12cea865f889597ed55b7bff981f34ac1467ebc52045c093e25d0b10034a6a5a`；clocks SHA均`24b6a893bfc1a18dc9060853902e690e4ef08d7838e0cca8374a65e029b5a5e1`，内容为`{core 3.333 {0.000 1.666} clk}`。XDC生成文件注释中的文件名不同，去除空行/注释后的有效内容逐行相同，仅原`create_clock -period 3.333 -name core [get_ports clk]`和`current_instance -quiet`。这是完整端口/方向与约束的结构见证，不能提升为另行完成的时序功能等价证明。

| 尝试 | 执行结果 | elapsed秒 | 峰值owned RSS GiB |
|---|---|---:|---:|
| AT021_core_opt | opt前身份API FAIL | 434.210853 | 15.724281 |
| AT022_core_opt | opt前身份API FAIL | 455.505929 | 15.719967 |
| AT023_core_opt | 单次opt/checkpoint执行PASS | 1992.074475 | 16.459915 |
| AT024_report_core_opt | 候选报告执行PASS | 1024.074499 | 17.560764 |

各项elapsed、verdict与budget_ledger一致，最终汇总与原receipt的elapsed/peak RSS逐项相符。implementation合计2881.791256890秒，reports为1024.074499061秒，本次诊断合计3905.865755951秒（约65分05.866秒）。opt命令及写checkpoint子耗时已经包含于AT023，不重复加；此前AT019的实际恢复亦已包含于其历史wall成本，不能重置。AT023/024最低MemAvailable分别402.565830/405.382271GiB。

四次receipt的guard_trigger均null、owned_after_cleanup均空；两次成功exit0，两次前置失败exit1。工程final_state记录16个AT020–024 tool身份gone、serial/stage guards已退出、重锁释放、无下一重阶段排队；主控另反馈新鲜核过共21个tool/guard/serial原身份均gone且锁释放。A014没有再次探测进程或发送信号。原/新候选均保留，没有自动转入facade、full-parent或place/route。

### 物理门槛的实际失败

| 项目 | opt前 | opt后 | 判定 |
|---|---:|---:|---|
| CLB LUT（已combining） | 2,139,515 | 2,091,399 | 降48,116，仅2.248921%；仍为器件160.42% |
| FF | 1,391,977 | 1,391,977 | 未减少 |
| DSP | 4,352 | 4,352 | 未减少 |
| BRAM / URAM / LUTRAM / latch | 0 | 0 | 未出现RAM映射 |
| CARRY8 | 37,476 | 37,412 | 减64 |
| MUXF7 / MUXF8 | 402,340 / 196,736 | 402,340 / 196,736 | 未减少 |

候选超过器件1,303,680 LUT上限787,719，超过全kernel 900,000 LUT预算1,191,399。要从候选降至两项上限至少还需分别减少37.664692%及56.966605%；后者仍未给其它全核逻辑预留余量。不能再次把已计入的LUT combining当作未来额外减额，也不能用FF/DSP余量或未使用RAM抵销LUT失败。

AT024全局最差及固定基线路径的元数据完全相同：`n_reg[1]/C → error_col_reg[0]/CE`，原requirement=3.333ns，slack从−1289.339变为**−1289.374ns**，logic levels从6091变为**6090**。候选data path=1292.603ns，logic=359.288ns，未布局net估计=933.294ns；报告总值与两分项和的0.021ns差值保留，不猜原因。对应原语为CARRY8 2031、LUT2 840、LUT3 87、LUT4 1074、LUT5 94、LUT6 1964，合计6090级。主控也已独立核原util和两份路径属性；现有证据足以接受观察到的setup FAIL。

该候选为Optimized/unplaced状态；HD.CLK_SRC仍未设，OOC时钟偏斜估计局限保留。PATH_GROUP/LOGIC_DELAY/NET_DELAY属性不可用时，实际可用GROUP、DATAPATH_LOGIC_DELAY、DATAPATH_NET_DELAY已导出；`report_timing -of_objects`忽略`-input_pins`只是格式选项警告，并非缺少实际路径。没有post-opt完整TNS/hold总结，没有placed/routed或上板结果；不据此给出最终可达频率或完整kernel验收。

### 下一版RTL的两个最小静态方向

1. **先审错误候选的同周期稳定平衡归并。** 上节已将线性链绑定至冻结源L155–160的blocking最小键递推及L332–428各条件调用；单次opt仅少一级，未自动消除该链。后继可静态设计`valid/key/原调用顺序/payload`的平衡归并，保留现有32位键表达式/类型语义，键相等时仍选原调用顺序较早者，stage只随获胜payload传递而不进入键；与跨周期error_key比较仍使用严格`<`，同键不得覆盖旧记录。所有候选使能、cancel、abort/status更新及L432协议错误优先级必须保持，不能为了树化改变外部可见周期或加入未约定流水。验证义务包括并发来源、同键不同stage、cancel、协议冲突及跨周期同键；本轮不实现或执行这些验证，也不宣称它能消除全部LUT超额。
2. **先建立operand池访问合同，再决定存储映射。** 冻结源L124的`op0/op1[0:63]`各8192位，合计1,048,576位，与优化后`g_operand_slot`名组的1,048,576个FDRE精确吻合。导出样本FILE_NAME确指向同一f849冻结源，FDRE样本LINE_NUMBER=269，写选择LUT样本为274/277，mul_a读选择样本为194；这比单凭名称更有来源支持，但不是全网表逐cell因果证明。该名组仍有LUT3 491,520、LUT5 475,136、LUT4 49,152、LUT2 32,825、LUT6 10,048；mul/add/ps_wr_data/trace_commit_data名组还有大量LUT与MUX，提示优先审写优先选择及异步多地址读网络。导出是直接primitive原始数量、511个归一化组中的前256组，不能等同packed-LUT贡献或预报删除某组能节省多少。

operand现有语义须先逐项列明：L194 mul读op0/op1，L216–217 add读op0/op1，L226–228部分和写数据读op0，L231公开trace读op0，均为变量索引异步读取。L263–280允许不同来源同周期写多个槽，且同槽顺序决定最后赋值优先：op0的add响应高于mul响应及format；op1的PS响应高于初始化零及format。L265复位分支为空，payload没有复位清零，不能把不存在的payload reset当根因。后继合同应固定64槽容量、实际并发读写/碰撞、同槽优先级、读写同拍可见性、有效门控、背压和trace语义；**任何BRAM化及由此引入的延迟或并发改变都需另立接口合同并单独验收**，不能靠RAM属性假定原多端口异步语义自动成立，不能删公开trace或缩小模式/容量来降数。

本阶段到此关闭，后继仅保留上述静态方向。没有追加普通opt、重综合、parent、place或route的自动授权；资源及setup双FAIL不因诊断执行PASS而解除，物理目标未完成。

最终工程收据SHA=`f2065e44e6b940ec40f45f034f698ae2a05254c3fd95efed25f5e601bda90acd`；工程终态`core_opt_diagnostic_final_state.json` SHA=`28088b88789b7a8fb2232ee39ed7a702138ef86521227a5f650b398fcca875fd`，其pending_controller/timer未改字段是主控收尾前的工程快照，主控后续决定如本节首段所记。两份路径report SHA分别`985916478fc8df4bff562a091bda7f23fd1bf1f1cd4c0c8e02f9fba0d2b7aae0`、`5f4d1d7751b8b0c63239e75f2a78ca7249a74be290d1335634a2254dbbe8c3b1`；两份properties SHA均`2edaf7504b75a2c1b9d1a1531fec199bcb1486d603813b735e911ee8c138f378`。四次receipt本轮重算SHA吻合最终工程收据，未改任何原始证据。
