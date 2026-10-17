# KB2有据no-go，CT0可入队

M004/SM005/E005/R001/AT003。沿D-M004-KB1-NEXT-01，two-64-tile Down 候选从KB1冻结闭包派生；保留原gold、四distinct预量化A、KB1 writer、AXI响应与7周期完成保持。`measurement_02`与`measurement_03`均static/pilot PASS，pilot实际每行256 PS比对通过；两个full均在同一cycle33397、5151 stripes、每行5120 PS、0输出处无真实进展，由原120s guard以semantic_stall/child-9收束。增加有限delta检测的同一已编译快照也在相同点停滞，无可用报错。所有运行串行、原帽不变，原始证据与判断见 `project/E005_full_request_performance/experiment_results/runs/R001/reports/KB2_two64_no_go_20261013.md`。

KB2未取得完整数值/周期样本，不能判断收益；根因仍UNKNOWN。按合同同点重复停止规则，本轮不扫块大小、不提高帽、不原样重跑；保留已审核KB1。CT0的5009bit×32 schema及真实helper REQUIRE/ACQUIRE/RELEASE_READ差异已写 `project/E002_Laya_HLS/experiment/hls/control/owner_ct0/source/design.md`，其HLS/RTL仍NOT_RUN。现在无owned重工具在跑，工程将沿合同转入CT0独立薄HLS诊断，不把CT0代签生产owner。
