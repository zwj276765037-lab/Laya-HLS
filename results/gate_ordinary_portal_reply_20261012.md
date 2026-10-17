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
