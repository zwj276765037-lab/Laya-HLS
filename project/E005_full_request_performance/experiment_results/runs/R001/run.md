# R001：SM005首轮有限算术测量

Execution state: completed（本轮KB0/KB1及P0/P3有界交付）
Verdict: supported（局部normal冷样本）

D-M004-MEASUREMENT-FIRST-01。AT001/AT002各static→pilot→full真实完成，重工具串行，无在跑owned工具。执行命令、真实起止及exit0分别在AT001_completed_20261013.json与AT002_completed_20261013.json；工作目录为唯一E002/experiment。Vivado/xsim2025.2，项目part xcu55c-fsvh2892-2L-e；行为仿真并非实现时序或板端频率。

四distinct预量化A、K2624/N1024、bias0/冷reset。26冻结source/脚本、12独立fixture、3native IP按各input_manifest记录，A/B唯一DUT差异为writer rowpack。原全部335872 PS lane-group及4096最终F32逐位通过，真实A/W读取、输出地址去重、实际末B、局部publication及一次done消费通过。响应策略按物理beat的17+(beat%3) B延迟、AW/W周期门及7cycle完成反压保持。

| 同边界cycles | KB0 | KB1 |
| --- | ---: | ---: |
| cfg→first done | 21100 | 16183 |
| cfg→实际consume | 21107 | 16190 |
| 全冷TB | 48864 | 43947 |
| cfg前A/W加载 | 666 / 27064 | 666 / 27064 |

KB1实际AW/W/B512→256，物理字节32768→16384、有效16384不变。命令与全冷周期分别减少23.30%与10.06%，保留候选。本轮仅一个改进DUT，不追加KB2。

[完整比较与适用边界](reports/KB0_KB1_Down_comparison_20261013.md)、[数据JSON](reports/KB0_KB1_Down_comparison_20261013.json)、[原始证据核查](reports/KB0_KB1_Down_verification_20261013.json)。互斥状态和等于各自cfg→done区间，重叠接口stall另列；工具墙钟不当硬件性能。

P0盘点已收束。P3薄HLS固定RAM/有限步骤优先、同schema RTL备选；下一目标必须涵盖原容量关键表的全键校验/候选/提交，具体schema与生成目标未冻结。FullRuntime/冷INIT和生产控制工具仍停排。[P3报告](reports/control_architecture_comparison_20261013.md)。

额外1923bits字段账；LUT/FF/BRAM/物理时序/联合资源UNKNOWN，OOC/P&R/上板NOT_RUN。两个继承writer错误窗口未测；完整LINEAR/Wi-G-Q同runtime、13BO请求、恢复与M003/M004总验收未完成。cfg前W加载为27064cycles，但[同profile供数下界补充](reports/KB1_W_load_service_bound_20261013.md)说明单改读取器调度的乐观余量最多约825cycles；不把TB供数gap视作已证可消除DUT停顿。

[KB1输出服务下界补充](reports/KB1_output_service_bound_20261013.md)：16384B恰占满256个512-bit写拍，当前TB逐笔等待B后才接下一笔；首AW到末B4927cycles中有4608次固定B延迟decrement。保持首AW时刻及这一响应策略时，其余输出间隙的理想压缩余量最多约319cycles，不能从writer/PS重叠stall直接推导相同的整命令收益。
