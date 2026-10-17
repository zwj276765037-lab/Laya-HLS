# Laya-HLS 当前概览

[LNQ0有界失败已核](measurement_first_LNQ0_review_20261014.md)：AT047真实四行LN完成原数值/存储检查并到PUBLISH，随后错误时点的TB coverage检查Fatal；后段Q/Wi/G/Down尚未到达。旧候选/两修正收束。下一[LNQ1](../mission/ln_qar_observation_repair_stage_20261014.md)只修TB历史覆盖观测，保持DUT/数据/profile，静态核定与成本准入后至多一次新full；新结果NOT_RUN。完整加速器仍未验收。

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
| LNREF0上游独立源 | AT038原独立参考前缀/源身份PASS | 保存完整/四行residual与LN输出；无LN DUT结论 |
| LNF0四行LN_FFN→Q | AT040有限RTL PASS，全TB170031 | 诊断身份/单窗口；未接QAR0后段 |
| LNQI0共同身份准备 | AT041 HOST_ONLY；六段载荷兼容，编码差异已解释 | 诊断W表未证明实际BO绑定 |
| LNQ0单实例联合链 | AT047发布后TB观测Fatal；后段NOT_REACHED | 原FAIL保留，旧候选/两修正收束 |
| LNQ1观测修复 | 新RTL NOT_RUN | 同DUT/数据/profile，修覆盖证据采样时点，至多一次full |
| 全模型/真实请求/恢复/资源 | M003/M004未完成 | 最终验收义务保留 |

WI0全TB101335，GQD0全TB102660各有自己的诊断边界，不相加成连续链延迟。当前连接统一B1/S128/batch0/row0四行窗口，AT032外部输入为预量化LN_FFN A，AT034已推进到原LN_FFN F32；链间无reset，原容量A/W单实例递增epoch复用，AT032已取得完整四行数值及最终有效区/保护区读回；LN producer已在AT040独立有限样本通过，尚未接入该后段；完整模型与生产恢复未验证。WI0旧样本未做独立DDR哨兵读回，不回写成已完成。

A002唯一工具owner，原帽、整体控制/冷INIT/恢复停排、G仅OOC余额2338.224019s、5172s不重启、无新HLS/OOC/P&R/上板保持。见[硬件指标](hardware_metrics.md)、[SM005审核历史](reviews/SM005.md)。
