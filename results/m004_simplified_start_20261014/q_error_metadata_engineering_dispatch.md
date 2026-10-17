# 修订7限定接纳；直接实施修订8错误元数据切分

2026-10-15；A001→A002/A003；M004/SM004/E004/R001；决定 `D-M004-Q-ERROR-METADATA-PIPE-01`。正式范围/验收/预算已写 `project/missions/SM004.md` 修订8末节。延续用户批准的完整推理目标，无新mission或逐步审批。

A001已核761项冻结/guard/日志/产物身份及AT130/131全部352共同文件一致，复核选择器/真实排空/TB相位。接纳 **PASS_SCOPED_Q_PARTITION_AND_LNQ**：独立Q、真实LN→Q正常/错误/反压/释放/复位和同版资源按交付范围成立；AT131内部WNS−1.750ns仍FAIL，实际Fmax未知。gamma0/gamma1至行可用增24/23拍，LUT减少4309；快速供数82组Q的2156cycle/输入停1173也保留，不能泛化成所有Q消费者无吞吐代价。

AT133现有DCP定点查询与A003分析已采纳。first_error_key、numerical_error本身分别−1.134/−1.519ns，故只删done的本拍best_error引用不足。选择唯一最小结构：原mul_pop数据写入/物理返回计数保持，坏mask的OR立即标ERROR_SLOT；新增valid＋16bit mask＋64bit完整key前缀（81bit）。下一拍平衡最低坏lane编码＋AMAX/DIV/已提交key的两级四输入min；候选消费与新捕获可同拍，不受out_ready影响。numerical_error改原本地坏事件sticky OR；done只读已提交状态，新增valid纳入done/start/物理债务及共同reset。不新建FMUL数据FIFO/credit或改变数值。保留int8原舍入、FP16 RNE、tag/epoch、protocol优先及旧返回隔离。

连续完成原独立Q/真实LN→Q受影响回归，加末坏half、连续坏事件/跨来源首错、候选提交与slot释放同拍、err_valid时reset/后继真实行等短测。罕见MUL坏事件可在真实返回握手上做有明确独立预期的有限数值注入，分开标为控制覆盖；不得伪造valid/pending或改gold。

新同版联合OOC必须**在synth_design前读入6.667ns时钟XDC**，核实际综合识别；不假造I/O delay/HD.CLK_SRC，不用时序例外隐藏组合逻辑。报告约束覆盖、WNS/TNS/新最长路径，保留RAM写数据定点查询未获路径的边界。比较标注RTL与约束流程共同变化，不为拆因补跑AT131。首个成功网表后收束，即使时序仍负。

修订8新候选预算：host300s/8GiB；static累计1200s、单次600s/24GiB；RTL累计900s、单次300s/8GiB/1Mcycle，pilot≤120s计入；联合OOC累计1800s、单次1200s/24GiB，最多2次且第二次仅首个普通构建失败有因修正。单重工具/CPU0–3/nice19/idle/MemAvailable>192GiB保持。无P&R/独立Q OOC/新代理/模型前向/旧full。原修订7static269.456193s（含AT133）、RTL100.811515s、唯一OOC248.809009s收束，未采样host仍UNKNOWN，旧账不迁移。

A002现在按同一设计/结果文件连续实施并阶段末集中交付。A003原定向分析已完成，只更新主控采纳与未测边界，不另开实验。完整硬件图与端到端性能仍开放，下一整体方向仍是矩阵A连接。
