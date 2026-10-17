# 修订21成本收束；修订22唯一matrix/首TN8立即按合同实施

2026-10-16；A001→A002；回复`m004-rev21-at383-parent-continue-cost-handoff-20261016`。

905项增量审核通过，744冻结/7guard/46政策一致；原53笔账保持，最终60guard/398政策、static1194.49134845845400532s、RTL3276.6153784599155065s。D-M004-REV21-CLOSEOUT-01按[决定](ln128_wprep_q16_rev21_at383_closeout_decision.md)收束本修订：余static605.50865154154599468s/RTL323.3846215400844935s封存不转。接纳AT379上层stage done屏障和AT382当前父图展开/真实row0；AT383 O3父前缀两行COST_STOP保留，完整父动态W/Q/A16仍OPEN。

补一个TB范围事实：AT382/383的父TB将W读响应关闭、STATE1 ready/valid绑零，禁止W AR，并在LN128终点finish；它只能测LN阶段。请补入报告/摘要，不改原冻结证据，不能把延长原TB当成完整W/Q验证。父wrapper/sequencer/TB本身同AT367，core文件同AT372，本次是匹配依赖的展开/前缀，不是新增生产接线证据。

现按D-M004-A16-MATRIX16-01正式开始[修订22合同](a16_matrix16_rev22_decision.md)，不等待确认收信。复用已审核唯一切口：父engine原front/矩阵FSM抽共同matrix服务，legacy和STEP16同一实例；上层A16 claim/SL_MATRIX、同步A、PS单口与唯一writer，W/cache唯一。固定rows16/K1024/N3072、TN8→四block→32group，正常独立主例真实LN128→W→Q16→首TN8及16笔B/ps_retire；前4行独立6144字段/32final，其余12行传递/覆盖口径保持。旧数值/首错、store错后继续全N算术规则按合同，首TN8不发父done/RAW/FINAL，不签全N。

新独立预算host300s/8GiB、static1800s/24GiB（单次600s）、RTL3600s/8GiB（单次1800s/40Mcycle）；全项目单重工具、CPU0–3/nice19/idle/MemAvailable>192GiB/语义停滞120s保持。static内计划留400s给最终父图。未知路径先≤120s，完成新组合LN16及同版W/Q16/首TN8局部成本样本、合同2.5倍计划式≤1440s且余RTL≥1800s后自动一次主例，不能拿旧317s或父两行比例代填。失败、构建、局部及主例全计入新账，不借旧余额、不原样延长AT383。

完整父图保留同实例真实展开及受影响legacy/exec011合法局部验证；父完整LN128→W/Q仍是单列欠账，不作为所有矩阵推进前置。若补父链TB须真实W/AUX/STATE1 peer及相位checker，当前不启动完整重父长例。无需新agent/HLS/OOC/P&R/新gold。A002仍唯一拥有生产实现/证据，A001维护合同/审核，A003维护研究；其他角色仍在工作，保留其改动。普通实现/测试/脚本修复按合同连续推进，阶段交付集中回传。
