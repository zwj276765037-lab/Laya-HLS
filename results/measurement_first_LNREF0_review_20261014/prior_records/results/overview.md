# Laya-HLS 当前概览

[QAR0已限定接纳](measurement_first_QAR0_review_20261014.md)：AT035同套硬件完成四行源Q→Wi→真实DDR/reader→G→同Q→Down及定向入口竞争；全gold/393216B终检PASS，全冷206136。AT036默认单入口真实静态配置通过。下一[LNREF0](../mission/ln_ffn_reference_source_stage_20261014.md)先取得独立LN_FFN前residual并核对输出身份，LN DUT尚未接入。完整加速器未验收。

| 工作 | 当前结论 | 接下来的处理 |
| --- | --- | --- |
| Down KB1 | 完整数值PASS，实际消费延迟−23.30%，全冷−10.06% | 保留，联合资源/物理时序未知 |
| Down KB2 | 重复COST_STOP，无完整样本 | 停止，不扫参数或加帽 |
| CT0 32项owner | 原helper/HLS/generated RTL有限PASS | 保存，不扩控制链 |
| LN→Q LQ0 | 独立gold通过，全TB659334 | 保留冻结基线 |
| LN LQ1 | 同gold通过，全TB528307；HLS slack−48.76ns | 保留周期证据，不生产采用 |
| LN LQ1R | 两版slack−0.43/−0.41ns；RTL/F9未运行 | no-go收束，无第三版 |
| Attention ATN0 | 全部原gold通过；全TB1608896，SM287173/EXP270525 | 接纳正常完整head基线 |
| Attention ATN1 | 原gold及同DUT首错/CE/reset通过；SM−7.6919%、正常计算−3.6552%、全TB−1.3729% | 限定保留，本轮结束；物理/生产未验 |
| GQD0连续算术链 | 四行normal真实交接/原gold/完成PASS；链区间102634cycles | 限定接纳，Wi仍是外部输入；物理/完整请求未验 |
| WI0实际Wi出口 | 原671744 PS/20992F32与1312 AW/W/B通过；cfg→消费46918cycles | 限定接纳；独立DDR哨兵读回缺项保留 |
| WIGQD0完整四行算术连接 | AT031 Wi数值/实际DDR有效区读回通过；后续COST_STOP，整链未通过 | 旧实现/两修复收束，G阶段存在观测空窗 |
| WIGQD1同DUT连续链 | AT032正常四行完整链/全存储保护PASS；全TB205314 | 限定接纳，仍以预量化LN_FFN A为外部输入 |
| QWIGQD0真实量化供数 | AT034正常顺序链/全存储PASS；全TB206133 | 有限数值接纳；LN producer仍外部，共享仲裁与opcode语义缺口保留 |
| QAR0共享入口修复 | AT035定向竞争/四行全链PASS；AT036默认配置静态PASS | 限定接纳；无一般公平性/恢复/生产权限结论 |
| LNREF0上游独立源 | 新结果NOT_RUN | 原request3参考前缀捕获residual/LN输出，核对源身份；LN接入另选 |
| 全模型/真实请求/恢复/资源 | M003/M004未完成 | 最终验收义务保留 |

WI0全TB101335，GQD0全TB102660各有自己的诊断边界，不相加成连续链延迟。当前连接统一B1/S128/batch0/row0四行窗口，AT032外部输入为预量化LN_FFN A，AT034已推进到原LN_FFN F32；链间无reset，原容量A/W单实例递增epoch复用，AT032已取得完整四行数值及最终有效区/保护区读回；LN producer、完整模型与生产恢复未验证。WI0旧样本未做独立DDR哨兵读回，不回写成已完成。

A002唯一工具owner，原帽、整体控制/冷INIT/恢复停排、G仅OOC余额2338.224019s、5172s不重启、无新HLS/OOC/P&R/上板保持。见[硬件指标](hardware_metrics.md)、[SM005审核历史](reviews/SM005.md)。
