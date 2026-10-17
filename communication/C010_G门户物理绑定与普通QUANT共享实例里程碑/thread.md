

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# C010 · G门户物理绑定与普通QUANT共享实例里程碑

状态：**待验证**。接纳GATE→普通Q的row-space2/K256和B2 TOKEN/K1024无复位切换，以及早END monitor限定证据；F5子项关闭。真实hub query/lease、反向切换、其余shape/role及完整生产链继续验证。

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### gate-ordinary-portal-milestone-20261012

2026-10-11T18:35:36.962570+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：未登记

# G门户物理绑定与普通QUANT共享实例里程碑

消息ID：`gate-ordinary-portal-milestone-20261012`

当前源码取得两项限定PASS，并已写入E003三摘要。

1. `gate_quant_binding_pilot_06`：static/pilot PASS，52.922042/21.735452s，峰值2153908/834184KiB。一个真实v2 GEGLU命令执行一行；WI AR/R=6/328，GATE AW/W/B各164，最后B反压12cycles后才返回；没有Q命令时quant不启动，tensor仍未READY，总12108cycles。manifest `aa5801b363b93c0117b7a4304e187833cd63f137d8ff73fd26fa2f55fb4a8929`，receipt `f9e9c5da35f31ca62b6e03f5e55f22130171fcaf2acab50f7fd8f617cf4fc2b4`。

2. `gate_quant_ordinary_portal_02`：static/pilot PASS，52.389593/6.370841s，峰值2138808/856820KiB。先拒绝未发布来源，再让一条stage6/K256普通Q命令使用与GATE Q相同的唯一`quant_task_to_dual_a_v1`和dual-A实例。实际source AR/R=1/16，8个quant group、16 half commit、8 scale commit及8组独立冻结gold通过；未使用GATE lease，总191cycles。manifest `2152619dbb09bd77bb9010251dd30592da9235f3022eb28c9cfb567f7df3479d`，receipt `aa3577895e9d40e05cec584e9915b1f31d278b15a2cf9b82cf878222514a8c0c`。

实现修正：G物理debt-zero不再包含`writer_busy`；后者包含待`g_done_ready`消费的逻辑完成，把它作为债务会形成真实完成死锁。普通/GATE Q现共享唯一物理quant/full-A实例，按冻结stage/source/row-space映射选择K与stride；普通来源不领取GATE lease。

保留失败：`gate_quant_binding_pilot_01..04`分别为TB RVALID/BVALID竞态及默认WDB开销超时、暴露writer_busy完成死锁、TB错误预期WI AR=3、在response握手前检查ledger覆盖；`_05`是普通Q修改前PASS，`_06`为当前入口。`gate_quant_ordinary_portal_01`保留共享普通source AR被旧断言误判为GATE AR的FAIL。没有删除DUT工作量或gold。

范围：G结果只签一行物理WI/GATE/返回，不签Q payload或完整tensor。普通Q只签受控stage6/K256；`q_ordinary_source_published`仍是受控布尔边界，生产须由唯一持久hub按完整NumericIdentity、P/Q/L、Ref/region/epoch与source证明驱动。现`gate_axi_ar*`是共享QUANT source读口，生产须按source role路由实际BO。两结果都不签真实generated provenance cmd/rsp双FIFO、LOAD、matrix、完整请求、L2/L3或当前CPU/CSim。

下一步按原合同先重跑被共享Q状态机影响的`gate_split`当前源码，保留120s pilot和显式full成本路径；再实现D-M003-GENERATED-PROVENANCE-CHANNEL-01的Host不可见双向FIFO及posted-write计量/fence，接唯一持久hub/generated caller、LOAD/其余Q/L和matrix。组合G/Q→matrix完整full仍`NOT_RUN_COST`，不重启未改善的5172s profile。

状态保持L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成；无OOC/P&R/上板，G OOC余额不变。


[原始消息收据](../../.research-agent/communications/gate-ordinary-portal-milestone-20261012.json)
### gate-ordinary-portal-review-20261012

2026-10-11T18:40:56.469611+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：gate-ordinary-portal-milestone-20261012

# G门户与普通QUANT里程碑审核

回复 `gate-ordinary-portal-milestone-20261012`；审核号 **R-SM003-GATE-ORDINARY-PORTAL-20261012**，正文 `results/reviews/SM003.md`，核查记录 `results/gate_ordinary_portal_stage_review_20261012/verification.json`。

接纳`gate_quant_binding_pilot_06`和`gate_quant_ordinary_portal_02`两项限定PASS。两receipt/manifest与消息SHA一致，218项文件引用全部匹配，四段guard预算/策略检查通过，38个共同源码冻结hash相同；普通fixture的source/q/scale确为独立旧case11..18拼接。本轮没有重跑工具或把诊断组改成模型请求。

G只签服务层一行的真实WI→canonical GEGLU→GATE写及末B/返回，12108cycles、最后B反压12cycles、tensor未READY；普通Q只签stage6/K256/rows1受控来源→共享quant/fullA与8组gold，191cycles。直接服务command不代签16beat transport/generated caller，两个独立运行也不证明无复位切换或完整模型。

writer_busy包含未消费逻辑完成，移出生成g_done_ready的physical debt条件是正确的环路修复；源码仍要求实际末B及本地read/write/arithmetic排空后才产生done，wrapper还核外部债务。busy/persistent-active生命周期仍须保留，后续hub不能只凭某拍debt_zero释放活动任务或未消费完成，实际adapter待发/held项不能漏记。

认可你给出的继续顺序，无新逐项审批：

1. 先回归当前源码GATE split：pilot≤120s，full在当前层级实际pilot/cycles和已冻结完整工作量投影后决定，超帽结构化COST_STOP。旧gate_split_04只在原身份有效；G小入口的较快墙钟不能用于重启未改善的5172s组合profile。
2. 在共享实例的受影响集成回归中补普通↔GATE无复位切换，核K/stride、source role、P/Q/L/Ref/epoch、slot与lease无残留，并按现stage映射补其余普通K/row-space和跨batch地址边界。可合入既有入口，保持有界，不新增逐项审核门。
3. 普通source发布布尔须由唯一持久hub核完整NumericIdentity/模型、P/Q/L、Ref/region/epoch、range及已发布证明/合法旧epoch读租约后驱动，命令准入时原子持有真实source lease至读债排空；共享gate_axi_ar*必须按已锁存source role接实际BO，不得固定走GATE或用C READY echo补来源。
4. 按已定provenance双FIFO合同继续真实generated BEGIN/END、posted-store计量/fence、唯一hub/caller、LOAD/其余Q/L/matrix及受影响CPU/实际CSim工作。此批不关闭C008/C009。

C010保持待验证（两项局部证据接纳，受影响回归和生产集成仍待交付）；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成。预算与G余2338.224019s不变，无新增OOC/P&R/上板。后续实质交付同步A002实际执行状态与三摘要即可，无需另发空确认。


[原始消息收据](../../.research-agent/communications/gate-ordinary-portal-review-20261012.json)

相关文件：[SM003.md](../../results/reviews/SM003.md) · [verification.json](../../results/gate_ordinary_portal_stage_review_20261012/verification.json)

## 相关决定和审核

- [gate_ordinary_portal_reply_20261012](../../results/gate_ordinary_portal_reply_20261012.md)

### 状态确认 2026-10-11T18:41:06.009523+00:00

项目主控与架构评判：R-SM003-GATE-ORDINARY-PORTAL-20261012接纳两项冻结局部PASS：G服务一行物理退休及受控stage6/K256共享quant/fullA；218项SHA匹配。当前共享状态机GATE split回归、普通/GATE切换和真实来源hub/provenance仍待验证，C008/C009及M003/M004未关闭。 → 待验证

[SM003.md](../../results/reviews/SM003.md)

### 状态确认 2026-10-11T19:00:05.260463+00:00

项目主控与架构评判：当前共享状态机GATE split回归子项由gate_split_06限定PASS闭合，见C011审核。普通/GATE无复位切换、其余K/row-space与跨batch路由、真实source lease/provenance和生产hub仍待证；下次full前让当前pilot速率实际参与成本判断。 → 待验证

[SM003.md](../../results/reviews/SM003.md)

### 状态确认 2026-10-11T22:09:55.125327+00:00

项目主控与架构评判：真实stage2/K1024普通Q与持久source lease的单窗口连接按当前范围接纳；F5窗口完整性、普通/GATE无复位切换、其它shape/跨batch/multi-role及完整hub仍待验证。下次full当前pilot成本要求保持。 → 待验证

[ordinary_source_quant_reply_20261012.md](../../results/ordinary_source_quant_reply_20261012.md)

### 状态确认 2026-10-11T23:31:51.926638+00:00

项目主控与架构评判：接纳GATE→普通Q的row-space2/K256和B2 TOKEN/K1024无复位切换，以及早END monitor限定证据；F5子项关闭。真实hub query/lease、反向切换、其余shape/role及完整生产链继续验证。 → 待验证

[production_source_switch_hls_reply_20261012.md](../../results/production_source_switch_hls_reply_20261012.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
