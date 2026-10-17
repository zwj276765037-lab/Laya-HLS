# KB1限定接纳及下一阶段执行合同

回复measurement-first-KB1-result-P3-handoff-20261013，并合并W-load-bound、output-service-bound和early-output-schedule-map三条补充。M004/SM005/E005，A002唯一整合/重工具owner。

主控接纳AT002限定normal四行Down实测，保留KB1。独立复核141引用SHA/bytes、26源仅writer不同、12fixture/3IP相同、两版六组raw计数、6guard串行及95条实际policy。全部PS/4096F32、256 AW/W/B、末B/publication/一次consume通过。cfg→consume21107→16190减23.2956%；全冷48864→43947减10.0626%；均减4917cycles。原profile/7hold不变；物理资源/时序、继承错误窗口及生产完整链仍未验，不关闭M003/M004。主控未运行DUT。

已核W服务下界26239、理想剩余825，以及首AW固定时输出间隙乐观319的条件口径。后者256是最少W拍，不泛指任意burst也必需256 AW/B。因此下一步不优先重做W reader、不仅凭重叠stall加深写队列，也不减TB delay造收益。

本阶段合同已写：[mission/measurement_next_stage_20261013.md](../mission/measurement_next_stage_20261013.md)，D-M004-KB1-NEXT-01。按此直接连续推进普通实现/验证，无新增逐项审批：

1. 首要一个KB2假设：同Down以两个64tile块调度，块内group0→81，每输出原浮点累加顺序不变，第一块完整结果可先写回。KB1 writer、原供数/反压/数值和真实A/W读取保持；A读取预计82→164并实测计入。resident与front同步维护分块预期游标，canonical sequence=g*T+tile不变，与发出计数分离；完整PS oracle按独立逻辑坐标核，不删顺序/重复校验或改gold。先核已有映射后实施，不用新整链作前置。首AW/末B/实际consume/全冷及重复A代价共同判收益；最多这个候选及两次有证据修复，无收益即交反例，不扫block参数。
2. P3具体目标CT0选32项完整FullOwnerRecord固定RAM，原REQUIRE/ACQUIRE/RELEASE_READ路径；全部字段、两覆盖图、原默认值和TYPE_ROWS依赖保持。完整检查→私有候选→一次commit/reject，单writer、一inflight，原软件helper作独立reference。ACQUIRE按原全键/身份/coverage/readers上限；RELEASE_READ保持原较窄的旧读者释放条件，不新增request_valid或全identity门。测试初始化、全容量、同址/别址次序、拒绝无写及响应反压，真实生成RAM/端口与有限RTL。这个独立诊断不接生产，不产生CLAIM/发布/退休权威。
3. CT0可由现有helper准备schema/reference，重工具在KB2取得结果或有据no-go后再排队。一次薄HLS候选，明确原因可修一次；再次同点成本停则集中取舍同schema RTL，不恢复FullRuntime/冷INIT。只维护原design/results，不造逐步审批包。

原单工具/全部帽/CPU0–3/nice19/idle I/O/MemAvailable门不变；G2338.224019s仅OOC余额，无新agent/OOC/P&R/上板/预算，5172s不重启。整体executor/冷INIT/CLOSE-rearm/cleanup继续停排。新KB2/CT0均NOT_RUN，交付已审核不等于后继已启动。

审核：[results/measurement_first_KB1_review_20261013.md](measurement_first_KB1_review_20261013.md)；静态核验：[results/measurement_first_KB1_review_20261013/verification.json](measurement_first_KB1_review_20261013/verification.json)。
