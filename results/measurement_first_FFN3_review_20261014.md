# FFN3审核：Wi reader配置语义失败，限定分离存储描述符

2026-10-14；R-SM005-FFN3-20261014；M004/SM005/E005/R001；A001。回复`measurement-first-FFN3-AT062-semantic-wi-reader-handoff-20261014`，合并`measurement-first-FFN3-Wi-done-edge-addendum-20261014`。

**核定AT062 FAIL_SEMANTIC_WI_READER_CONFIG。** 类型感知准备和真实冷前缀按已列范围通过，唯一full在cycle271096触发`Fatal: WIGQD Wi reader cfg rejected`；child0/trigger null不能覆盖语义Fatal。FFN3额度收束，不改AT062或之前的失败/停止记录。

[主控只读核验](measurement_first_FFN3_review_20261014/verification.json)检查1549条唯一文件路径：336源码引用、262文件/130020393B原编译包、未运行bundle及pilot/full两份运行副本的冻结文件逐bytes/SHA一致，7 ROM/63 fixture/11个fixture根一致。5 ELF根和80项已列解析身份、脚本/source链、实际preflight/命令/启动顺序已核。运行后额外WDB（头为Xilinx WAVE DATABASE）、日志及调试文件单列，不误作冻结输入变化。

完整包及五项缺/坏ROM、缺reloc、错ELF/库身份反例分别ACCEPT/REJECT，冻结launcher同verify路径在spawn前拒绝。prefix/full实际命令分别含12/11个plusarg（前者另含PREFIX=1），与临近启动preflight一致；新成本决定早于full。一次prefix和full早期的活体maps未见清单外ELF，不能据此签所有后期dlopen/脚本资源完备。

| 运行 | 原始结果 | 接纳范围 |
| --- | --- | --- |
| host准备 | 累计7.112138s；自/子进程rusage峰1522944/88796KiB | 准备预算及分类/已列身份；不是owned进程树采样峰。CPU0–3/nice19有记录，host实际idle I/O采样UNKNOWN。 |
| 冷prefix | 28.989676s、1035900KiB；cycle5224、真实LN 1AR/64R；自然PREFIX_PASS | 新启动路径和首LN读取；不代表后段成本。 |
| 冷full | 1696.153932s、1036100KiB；85次认可进展；Wi reader cfg Fatal | 真实LN/Q/Wi已到达前缀；G及后段没有通过。 |

两个动态guard串行，8条实际CPU0–3/nice19/idle样本全匹配；无资源/semantic触发。host无完整树采样与I/O记录的缺项保留，不用动态guard样本替代它。

真实完成边沿以[原full日志](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT062_FFN3_typed_xsim_01/guard_full/driver.log)为准：LN源四行gold/store/lease PASS170043、Q A发布169979；Wi三W端口R=41984/41984/5248，1312 AW/W/B、83968B输出和原数值检查达到。Wi末B271074、first_done_valid271082、**actual_done_consume271089**、完成标记271090。工程已补证更正原交付混写。日志复用的`DOWN_MEASURE_BOUNDARIES`在此测的是Wi，不证明Down执行。guard末周期快照的mwr3821/mret0早于这些末端事件，不能当最终写事务/消费总数。

G cfg受理271094，Wi reader cfg271096随即拒绝。真实Wi reader R、G/GATE、第二Q、Down STATE1 TMP、末残差和655360B最终保护、整链周期均NOT_REACHED。AT049到Down与AT054独立末残差的限定PASS不能相加成联合结论。

根因定位可信且范围明确：[实际冻结TB](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT059_FFN1_progress_replay_02/frozen_new/ffn0_chain_tb_v1.sv)第724/748行将Wi区域固定于`0x100001000`，BO却取共享矩阵槽。该槽在第2465行为未来Down切到STATE1 `0x310000000`；原reader `command_ok`要求region≥BO，此时必然为假。reader拒绝保护正常发挥作用，应修TB绑定。该静态矛盾与日志一致，但本轮没有新单因RTL测试，也不能据此保证所有其它reader字段已正确。

成本记录3536.346080s的算术和时间先后成立；其500000cycles仍来自独立AT049/AT054加余量、统一旧速率及5%余量，后段没有分阶段新证据。仅接纳为当时规划估计，不认证为新链上界或下一轮自动准入。full本次按语义失败结案，不改称成本失败。

选择[D-M004-FFN-WI-DESCRIPTOR-REPLAY-01／FFN4](../mission/ffn_wi_descriptor_replay_stage_20261014.md)：稳定分离Wi DDR与Down STATE1描述符，不改reader校验或功能DUT；新static、受影响reader正反短测、一次真实冷前缀后，按AT062实际到Wi证据和分阶段剩余成本重新决定至多一次cold full。允许本方案内有限普通修正，不逐个脚本异常重新请用户批准。AT062旧snapshot不能代表新TB；运行包/输入重新冻结核验，guard及算术身份保留。

新阶段NOT_RUN；本次A001仅核文件、日志与合同，未运行参考/DUT/EDA。普通Q/L/整体executor/恢复停排，外部attention residual、生产双lease、全模型/13BO/联合物理和M003/M004继续开放。
