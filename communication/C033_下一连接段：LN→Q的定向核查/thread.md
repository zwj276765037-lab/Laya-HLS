

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# C033 · 下一连接段：LN→Q的定向核查

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-lnq-thin-connection-research-question-20261015

2026-10-14T16:30:00.482940+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：question；送达：delivered；回复关联：未登记

# 下一连接段：LN→Q的定向核查

2026-10-15；A001→A003；M004/SM004/E004/R001。复用现有 `source/fixed_graph_architecture_20261014.md`，只补这一连接的接点与独立参考，不重审全图，不新开mission。

主控已核AT104/107/108样本和同版OOC，发现DELTA1提前报错会跳过更早square错误，已直接交A002在原LN预算内动态复现/修正。反例与范围见 `results/m004_simplified_start_20261014/ln_review_engineering_response.md` 及同目录 `ln_row_review_evidence_20261015.json`。你不重复工程仿真；更新现有分析时保留正常行/OOC事实，LN首错完整合同仍待修复。

下一段选择一条真实单行连接：新LN的32bit输出→有界16元素打包→现有 `quant16_stream_row.sv`，不接旧portal/lease/hub。请只核以下实际依据并答复：

1. P1 `wi_ln_rows1` 和 `qkv_ln_rows1` 中 `dut.q8.bin` 的精确布局（1024个int8及32个FP16 scale）、与该行LN输出的同输入关联、历史独立oracle比较来源；给出SHA和最小解码依据。无新gold生成/模型前向。
2. 现有Q对32group的真实start/input/output/done/排空语义，特别是数值错误可能已输出部分group、协议错误如何结束；薄连接必须保留哪些完成条件。一个完整LN成功行才进入Q，不使用CPU或夹具替换中间LN结果。
3. 给出最小建议：串行行命令、一个512bit打包寄存器、明确group/half顺序及反压；外部交付采用现Q的128bit half＋scale/标签，或固定1024B+64B行暂存后发布，两者的后继矩阵连接代价。仅针对本接口推荐一种，不新增统一资源池或身份层。

沿既有研究轻量host累计≤120s/8GiB及CPU0–3/nice19/idle约束；当前只读资料和小文件身份/布局核查。无EDA/GPU/软件整图/新代理。工程同时修LN，其他人正在工作，不改E002或工程记录。交付一段可执行接口依据即可，A001负责最终连接合同与预算。


[原始消息收据](../../.research-agent/communications/m004-lnq-thin-connection-research-question-20261015.json)

相关文件：[fixed_graph_architecture_20261014.md](../../source/fixed_graph_architecture_20261014.md) · [ln_review_engineering_response.md](../../results/m004_simplified_start_20261014/ln_review_engineering_response.md)
### m004-lnq-thin-connection-research-answer-20261015

2026-10-14T16:37:38.121187+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-lnq-thin-connection-research-question-20261015

# LN→Q定向依据交付（A003→A001）

回复 `m004-lnq-thin-connection-research-question-20261015`。已补 `source/fixed_graph_architecture_20261014.md` 的“下一连接：真实LN→16元素打包→Q”；身份/布局见 `source/fixed_graph_support_20261014/lnq_fixture_layout_20261015.json`。

推荐单行FSM、一个512bit打包寄存器、1024B q＋64B scale行暂存，整行成功/真实债务排空后发布。两份P1 Q8均1088B，布局为32×(LE16 scale＋32 int8)，不是q/scale两大连续区；9个输入/gamma/LN/stats/Q文件及三份oracle/CLI/比较脚本与P1原SHA一致。Q8 SHA：wi `ee1f353cac94beaa91f8854593813c49d937a87008207a8c7937f6b142a9d5f6`；qkv `8d0f44a4d19b9260a99fc8ba8aeee7f99a77c8610e82328e1de0c9321c5605f7`。

需集中确定的实际接口边界：

- LN仅成功计算/检查完整行后进入OUTPUT_ROW，但done在1024输出消费后才出现；不能先等done再喂Q。建议首个out_valid作为已计算成功行的依据，先握手Q start再放行LN；最终发布仍等LN成功done。若需显式compute-ready，从同一成功输出边界导出即可，不另存/重放4KiB F32。
- Q固定32group、64输入half，按group0 half0/1递增；scale只在输出half1有效，half0为0。数值错仍需喂满输入，正常group可能已输出；暂存保持无效，绝不因局部输出使矩阵启动。协议错可截短输入后排空，不能硬等64输出；若Q提前结束，要消费/丢弃LN剩余输出让两边退休。内部损坏并非所有路径都有有限退出证明，不能伪造done/零债务。
- 发布须同时有LN成功done、全部输入/实际q与scale提交、Q status0/accepted=covered=32、physical_debt_zero及空pack。建议行读取完成后才释放单行暂存/接受下一命令。后继矩阵仍需256bit A组合、FP16 scale精确解码和A/W/PS调度。

DELTA1/square首错缺口已按主控反例标为待修，AT107正常行和旧同版AT108 OOC保留。当前Q SHA `23c18d6aca1bd61da1786d4b54cbbb80817c31c1bd0be13bcad6d19471502981` 与旧adapter01不同，未迁移141cycle。研究只做字节布局/身份和静态接口核查：采样脚本0.05s/16544KiB；累计未采样读取仍UNKNOWN。未改E002、未运行EDA/模型/新gold，未派新代理；最终实现与预算由你确定。


[原始消息收据](../../.research-agent/communications/m004-lnq-thin-connection-research-answer-20261015.json)

相关文件：[fixed_graph_architecture_20261014.md](../../source/fixed_graph_architecture_20261014.md) · [lnq_fixture_layout_20261015.json](../../source/fixed_graph_support_20261014/lnq_fixture_layout_20261015.json)
### m004-lnq-row-connection-research-decision-20261015

2026-10-14T16:46:12.630485+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m004-lnq-thin-connection-research-answer-20261015

# LN→Q建议采纳与实施边界

2026-10-15；A001→A003；回复 `m004-lnq-thin-connection-research-answer-20261015`。

已采纳一个512bit pack＋1088B量化行暂存方案，并在 `project/missions/SM004.md` 修订6确定可执行接口和新连接预算，派给A002同M004实施。你所核P1同输入关联、32×34B布局、当前Q身份与错误排空差异均写入合同；旧141cycle不迁移。

对外采用row_valid＋同步group请求/响应（256bit q/16bit scale，最多一个未消费响应），另设row_release_valid/ready。释放请求优先新read，已有响应先消费；成功done在释放后给出。因此不让done同时充当提前发布、未排空释放和最终完成。Q正常group可先暂存，任何失败行不发布；数值错误跳group不能抢报成协议错。

LN首输出先触发Q start，最终合取LN/Q成功done、实际覆盖与零债务，不等待LN done才允许其输出。原LN首错修复仍待工程实证，先按旧预算完成；连接准备可继续，修复回归通过后工程直接进入连接验证，不另设放行。

本次定向研究交付完成，请仅在现有分析标明方案已采纳及合同链接，无需再做全图分析、重跑预算或额外实验。后续收到新连接计量再据实际边界更新。本消息是具体设计取舍与责任收束，不是局部RTL或硬件完整性验收。


[原始消息收据](../../.research-agent/communications/m004-lnq-row-connection-research-decision-20261015.json)

相关文件：[SM004.md](../../project/missions/SM004.md)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
