# Laya-HLS 当前概览

[FFN2准备停止已核](measurement_first_FFN2_review_20261014.md)：AT060缺完整库身份、AT061把Bash loader误送ldd，未进入xsim/prefix/full。当前[FFN3](../mission/ffn_typed_runtime_preparation_stage_20261014.md)固定DUT/TB/guard/data，按脚本/ELF分层核依赖；纯host在累计120s预算内连续准备，一次真实冷前缀后有据决定至多一次full，NOT_RUN。普通Q/L/整体生产控制停排，M003/M004开放。

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
| LNQ1观测修复 | AT048静态PASS；full缺7份ROM而COST_STOP | 新观察/下游未到达，旧额度结束 |
| LNQ2运行包有效重放 | AT049正常四行同runtime LN→Q→Wi→G→Q→Down PASS；全TB375074 | 限定接纳；外部residual、末FFN residual与生产/物理缺口保留 |
| FFREF0末残差独立源 | AT050 HOST_REFERENCE PASS，八组逐位比较零差 | 源身份闭合，不能代签残差硬件 |
| FFR0四行末残差RTL | AT053正常数值/事务/保护通过；52例槽通过 | 错误码、停滞guard及计量缺口；合同未闭合 |
| FFR1受影响修正 | AT054局部四行/有限错误/计量PASS | 保留；局部双外部源，无生产双lease |
| FFN0同runtime末残差 | AT057守卫观测漏W实读，COST_STOP | 原额度结束；后段及完整保护未到达 |
| FFN1受影响观察准备 | 局部短测PASS；pilot启动前超帽/full未准入 | 原准备纠正额度已收束，无新联合动态样本 |
| FFN2运行包准备 | host准备停止；无xsim/prefix/full | 脚本误作ELF，旧纠正额度收束 |
| FFN3类型感知启动 | NOT_RUN | 脚本/source链与ELF依赖核验；一次冷前缀后再有据full |
| 全模型/真实请求/恢复/资源 | M003/M004未完成 | 最终验收义务保留 |

WI0全TB101335，GQD0全TB102660各有自己的诊断边界，不相加成连续链延迟。当前连接统一B1/S128/batch0/row0四行窗口，AT032外部输入为预量化LN_FFN A，AT034已推进到原LN_FFN F32；链间无reset，原容量A/W单实例递增epoch复用，AT032已取得完整四行数值及最终有效区/保护区读回；LN producer已在AT049接入同一后段并通过限定四行检查；末FFN residual、完整模型与生产恢复未验证。WI0旧样本未做独立DDR哨兵读回，不回写成已完成。

A002唯一工具owner，原帽、整体控制/冷INIT/恢复停排、G仅OOC余额2338.224019s、5172s不重启、无新HLS/OOC/P&R/上板保持。见[硬件指标](hardware_metrics.md)、[SM005审核历史](reviews/SM005.md)。
