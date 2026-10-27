

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# E007 · m006_full_fpga_attention

关联：M006 / SM007

## 原始管理记录

- [实验协议](experiment_source/protocol.md)
- [来源摘要](experiment_source/summary.md)
- [结果摘要](experiment_results/summary.md)
- [状态摘要](experiment_status/summary.md)

## 当前结果摘录

# E007：关键结果摘要

用户暂停时最终真实记录为[AT001–023逐笔账](experiment_results/runs/R001/guard_ledger_AT001_AT023_20261017.json)：33guard/246条policy零失配，参考1.2089934079995146s、static186.702932331001643s、RTL56.612746981005330s、HLS＋模块OOC918.667736757997775s；后续预算余额封存待用户恢复指令，不转给其它任务。AT020 add8零黑盒OOC 215LUT/274FF/2DSP、综合WNS+1.727ns；AT021新add8、AT022新div8、AT023旧add11均在次正规样本Fatal，按实际FAIL_NUMERIC保留，child0不代PASS。具体原始位置见[add反例](experiment_results/runs/R001/reports/SM007_AT020_AT021_add_subnormal_risk_20261017.md)及[div反例](experiment_results/runs/R001/reports/SM007_AT022_divider_subnormal_risk_20261017.md)。

AT015–019直接除法增量见[工程报告](experiment_results/runs/R001/reports/SM007_AT015_AT019_direct_divider_engineering_milestone_20261017.md)及[26笔账](experiment_results/runs/R001/guard_ledger_AT001_AT019_20261017.json)：AT016原VHDL综合检出黑盒FAIL；AT017修复依赖后6拍IP零黑盒OOC为778LUT/333FF/0DSP、综合WNS−0.458ns；AT018同数值配置8拍IP零黑盒OOC为778LUT/451FF/0DSP、综合WNS+0.768ns；AT019同版真实生成IP的16个定向值连续RTL逐位PASS，首返回8拍且返回间隔1拍。均为单lane及综合阶段，非8路、完整数值域或布局布线300MHz验收。累计参考1.2089934079995146s、static151.683702415000875s、RTL40.636666693004372s、HLS＋OOC829.946112331996125s；host完整UNKNOWN。下文AT014账是旧快照，不作当前余额。

M006/SM007的strict expf leaf流水调度源码 `attention_exp_bits.cpp` SHA `54ff1196824eebbb638dc0f45b97f4113ec4e6d7a7e55ec18e6662a3717939f1`；生产共享FP阵列 `laya_shared_fp256_v1.sv` SHA `aac34506fdfdfe2f0525b1798998da35bb8098cb575559d6ae87c3903513d019`，固定QKV银行 `laya_attention_qkv_bank_v1.sv` SHA `15973d7a0d4a02485b770174d7f185c08f9b0fa9b22c97457eb857b5145d03fe`。当前[机读账](runs/R00

（摘录截断；完整记录见链接。）

## 每个运行批次

| 批次 | 详情 | 具体尝试数量 |
| --- | --- | --- |
| R001 | [本批结果与证据](experiment_results/runs/R001/README.md) | 23 |

## 原工程历史结果


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
