# LNF0四行RTL限定结果交付

回复`measurement-first-LNREF0-review-LNF0-dispatch-20261014`；M004/SM005/E005/R001，A002。按D-M004-LN-FFN-RTL-01执行，**AT040 static/rows1 pilot/rows4 full均PASS_SCOPED**。本轮无新HLS/OOC/P&R/上板，无第二LN或Q算术候选；工程暂停下一长链，待主控集中审核与选择。

AT038独立enc0 attention residual前四行16384B作声明外部输入；原AT014 baseline LN生成物83项不变。P为request3/generation1/B1S128、LN_FFN0x12/stage2/layer0/batch0/row0/rows4、Q为0x20；STATE0容量16920576B，HIDDEN offset0、NORM offset8MiB。canonical L13M与原生成核模型header一致，但原ABI capture build tag与诊断生成配置不同，不签完整原ABI生产请求身份。

AT040同runtime仅初始reset，LN真实源4AR/256R、目的4AW/256W/4B、16384B；4096 F32逐位对AT038独立gold。末W167202→末B167215（13拍），生成完成168789、END消费168843、发布168898。Q接受168900，真实4AR/256R读取刚写目的字节；fullA 32组覆盖4096 INT8/128 FP16 scale原独立gold，Q响应169841→消费169846，lease关闭169847，fullA release169976，零债务170031。目的本地65536B终扫：目标16384B逐位/written，邻接49152B哨兵及未写；全BO 16920576B未逐字节扫描，未分配地址由AXI界限检查。全冷TB170031cycles；新四行与旧LQ0十六行不同口径，不推性能收益或部署频率。

AT039 static PASS，rows1 pilot实际完成LN读写/末B后因派生owner descriptor仍layer1，在END被原hub以E_PROTOCOL=7拒绝；pilot FAIL/full NOT_RUN保留。AT040仅改fixture descriptor为layer0；DUT、算术、独立源/gold、容量和原自检不变。AT040 static/pilot/full工具83.827585/56.206804/195.556890s，child0/null、peak2370544/863288/863192KiB；39实际CPU0–3/nice19/idle policy样本全合规。151条冻结身份逐SHA/bytes核对，AT039→AT040冻结源码仅fixture生成器一项差异。单行pilot 47308cycles/56.207s，给四行producer及额外128组Q预算的准入估455s<3600s；实际full195.557s。receipt中cost_decision.started=false是准入决策初始化字段，实际full.started=true并有原guard/log。

工程报告：[LNF0_four_row_rtl_result_20261014.md](LNF0_four_row_rtl_result_20261014.md)。原证据：[AT040 receipt](../attempts/AT040_LNF0_ffn4_02/receipt.json)、[full raw](../attempts/AT040_LNF0_ffn4_02/guard_full/driver.log)、[verification](../attempts/AT040_LNF0_ffn4_02/verification.json)、[AT039 failure](../attempts/AT039_LNF0_ffn4_01/receipt.json)。E005三摘要已发布，A002真实状态已同步；当前无本项目重工具。QAR0/AT035 Wi→G→Down未与本LN同runtime，Attention/WO/residual硬件上游、FFN residual、完整请求/恢复、联合资源、物理时序及M003/M004均未完成。建议主控以本真实NORM store/发布/lease边界判断是否选择下一单实例LN→QAR0连接；本消息不预签它。
