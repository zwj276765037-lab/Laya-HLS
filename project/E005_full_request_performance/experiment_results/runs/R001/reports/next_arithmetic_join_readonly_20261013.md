# 下一算术连接入口的只读定位

主控正在选择下一阶段时，工程只读定位了最短现有接点，未启动新工具或修改候选。旧 `t2_geglu_gate_quant_bridge_rtl_04/receipt.json` 的限定 PASS 覆盖四distinct原enc0 Wi输出行→真实G与AXI末B→量化→dualA commit/acquire/完整身份保持读与release；实际量化/读回共328组，即4行×82组。桥的读口已显式带slot/epoch、672bit numeric identity、96bit linear context、A ref、row block及group，返回四row q/scale；原收据明确**未**覆盖下游Down。KB1的四行Down输入仍是TB预量化A，K2624=82组、N1024，4096F32/335872 PS及256 AW/W/B已验。两边组数/行数吻合，是下一有限接链的具体候选；尚未逐SHA核四行数据、scale与Down输入的同源身份，也未证明同runtime交接、背压、双槽与完整生产控制。

证据：`project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_geglu_gate_quant_bridge_rtl_04/receipt.json`、`project/E002_Laya_HLS/experiment/vivado/module_design/activation_quantizer/rtl/geglu_gate_quant_bridge_v1.sv`、`project/E005_full_request_performance/experiment_results/runs/R001/reports/KB0_KB1_Down_comparison_20261013.md`。旧receipt的外部绝对路径仍指历史baseline，本项目复制树可读，但下一运行必须重新冻结并映射本项目路径，不能写回旧工程。
