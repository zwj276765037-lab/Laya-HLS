# E007：实验依据摘要

AT015–019直接除法边界采用同一生产 `laya_attention_fdiv_lane_v1_ip.tcl`：单精度直接Divide、无结果ready、8拍流水及原数值配置；AT018生成真实IP并综合，AT019冻结该生成IP作定向RTL。单lane结果与未测范围见[工程报告](../experiment_results/runs/R001/reports/SM007_AT015_AT019_direct_divider_engineering_milestone_20261017.md)；TANH旧384拍与当前≤160拍要求的冲突已报主控。

M006/SM007授权完整板端Attention首段：以唯一E002生产RTL实现共享256-lane FP、银行与阶段租约、严格SFU/divider，再验S128单head和同版OOC。权威来源为[SM007](../../../mission/M006_CPU_FPGA协同高性能推理实现/tasks/SM007.md)与[协议](protocol.md)。工程配置part为`xcu55c-fsvh2892-2L-e`，目标300MHz；实际板卡、完整物理证据仍未知。严格expf单lane采用原独立libm参考；共享FP局部试验使用原真实乘/加IP，对四路及256路定向数据检查响应；固定QKV物理银行按M006 §10.2三plane×64bank×2048word实现并独立仿真/模块OOC。原F64加法子模块真实OOC已完成，F64乘法子模块限时未完成；直接divider单lane已补定向RTL与模块OOC，严格TANH本段仍未实测。旧四路非流水EXP和原M004局部PASS均不代签新合同。
