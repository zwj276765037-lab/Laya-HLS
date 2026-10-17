# E004：限定结果

AT091 完整软件正常请求 47项/4,523,596 F32 对独立gold逐字节PASS（Attention仍为CPU叶子）；AT101受控AXI4向量服务4096项正常/反压6955/7206cycle。LN首错旧版AT109动态FAIL，修复版AT110六边界＋原九行PASS；AT108资源仅旧版。

LN→Q顶层SHA `7c194fa3…`，AT121五条正常行与四类错误按原范围局部PASS；原reset计数64来自上一行，未证明本行Q在途。AT123定向实测新row31命令及已接受但未处理的一组；AT124再实测FP除法已发未返时共同reset，16拍覆盖12拍quarantine，旧原始FP valid一次但无旧返回接纳/协议错/行发布，下一行逐位gold通过；AT122新增TB断言错误保留。历史P1两真实行原input/gamma经真实LN和Q，LN 1024输出/统计值及32组Q8/FP16 scale均逐位对独立核验保存夹具。gamma0 cmd→row_valid 8573cycle；gamma1输入空拍/Q输出42cycle阻塞为11064cycle；含34次故意阻塞的消费者读取至最终done为8855/11346cycle。晚Q数值错已有62个half暂存但无发布，协议早停真实排空后无reset下一行恢复。

AT116同版U55C联合OOC DCP/blackbox0：41655 LUT、12192 FF、50 DSP、16 RAMB18（8 tile）、0 URAM，q0/q1/scale 1088B映射LUTRAM。内部WNS−49.011ns、TNS−50792.254ns@6.667ns，150MHz综合内部检查FAIL；AT120同DCP核row_valid/done_valid均为逻辑LUT2而非GND。未布线、95输入/416输出无delay，物理频率UNKNOWN。连接守卫累计host1.606030s、static404.133281s、RTL175.407140s、OOC242.194084s。详见[报告](runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)与[证据](runs/R001/reports/SM004_lnq_row_stage_evidence_20261015.json)。


---
Published: 2026-10-14T17:39:34.197712+00:00
Publication: P11cb3b2497664852ac36ddcd198d9803
