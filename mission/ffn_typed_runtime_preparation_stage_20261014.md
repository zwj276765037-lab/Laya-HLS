# FFN3：按文件类型核运行依赖并完成直接xsim准入

D-M004-FFN-TYPED-RUNTIME-PREPARATION-01；2026-10-14；M004/SM005/E005/R001。依据[FFN2审核](../results/measurement_first_FFN2_review_20261014.md)。A002唯一实现/工具owner，A001集中验收。旧FFN2已停止；此合同授权受影响启动准备及有据回放，新结果NOT_RUN。

## 实现边界和依赖规则

沿用[FFN2](ffn_direct_xsim_replay_stage_20261014.md)的AT059编译snapshot来源、隔离副本、冷启动、实际命令/plusarg、preflight与成功出口。只修改launcher、包清单、依赖分类/解析和host检查；AT059功能DUT、联合TB、35分项观察器、guard/parser、生成核/IP/ROM、gold/fixture、模型/请求/Ref/BO、正常激励/反压不变。无新compile/elaborate、参考、HLS/OOC/P&R或vendor安装修改。

将上一合同“完整运行依赖”落实为以下可核字段，不用文件名猜类型，也不将ldd成功等同一般运行依赖完全闭合：

1. 依据实际文件magic分类。脚本入口记录路径、bytes/SHA、shebang/解释器以及实际source链；至少覆盖已核xsim wrapper、loader、setupEnv.sh、rdiArgs.sh及此分支进一步加载的脚本/配置。脚本不送ldd；解释器本身按ELF处理。symlink记录入口和解析目标，不更改安装文件。
2. ELF根包含选定snapshot xsimk、真正执行的unwrapped xsim、解释器及明确使用的vendor kernel库。记录ELF解释器/DT_NEEDED、在本次实际搜索规则下解析出的路径、bytes/SHA及未解析项；用readelf/ldd等只读host检查，递归按已访问身份去重，保存原输出/返回码。静态链接或无DT_NEEDED须由ELF信息判定；不能一律忽略非零退出，也不能把脚本作为坏ELF误拒绝。
3. 保存与解析有关的显式环境和wrapper规则，库解析与后续启动保持一致。不能继续用AT061两个猜测目录代替wrapper实际解析环境；不打印无关环境/凭据。vendor late-load模块和脚本资源另列可核来源，DT_NEEDED闭包与运行期实际加载范围分别报告，不遍历整个工具安装树充作完整性。新前缀只作被动依赖核对；若实际启动暴露未声明的库/脚本/环境差异，在full前停止准入并交付，不能把差异忽略成已闭合。
4. 清单写入采用完整准备后提交，失败只留独立原输出/返回码和部分产物，不发布半份可准入清单。每一版本独立冻结，不改AT060/061或AT059旧目录。新完整清单须核262项snapshot包及原336源码引用、7 ROM、63 fixture和11个实际根，保持FIXTURE=LN_FIXTURE；prefix额外PREFIX=1，full不含早停参数。原文件数量若因纯日志/元数据隔离而变化，逐项说明，不能漏二进制/内存/重定位/配置依赖。

## host准备连续执行与停止边界

本阶段纯host准备只有一个方案，**累计实际host子进程墙钟≤120s、owned RSS≤8GiB**，CPU0–3/nice19/idle、MemAvailable>192GiB。从首个新准备子进程开始累计复制/hash/分类/库解析/正负preflight执行时间；agent编辑/等待不算执行，不能重启计时或换AT重置。运行前检查剩余预算，单命令timeout不超过余额；保留命令、原stdout/stderr、返回码、实际时长/采样。无采样写UNKNOWN，不把规划上限当实测。

在上述总预算和同方案内，路径、解析、类型、序列化等普通host错误允许连续修正，不再按一次异常停止整阶段或逐次请主控批准。每个失败版本和差异保留。预算耗尽、依赖无法确定、需要改变DUT/TB/guard/工具配置或新增编译时停止并交付，不扩大范围。

启动前先做缺ROM、错SHA、缺reloc、ELF根/已列库缺失或身份错误的同launcher拒绝检查，以及脚本正确归类/合法ELF合法解析对照。可在临时受控副本/清单测试缺库，不删除或改系统/vendor库。保存真实拒绝返回码和未调用spawn的执行路径，不能仅写spawned=false字段。既有短算术/适配器/观察器/host逻辑时间结果按同SHA复用，不重跑。

## 前缀、成本与一次full

host准备完整后，继承FFN2实际preflight→spawn的隔离路径：每次临近spawn核真实cwd/包/命令身份；prefix/full各自原始编译包副本、新进程、初始reset。至多一次≤120s/8GiB真实冷xsim前缀，沿用run70us/真实1AR和64R目标；必须SIM_START、实际计数、PREFIX_PASS/$finish、无Fatal/ERROR/guard触发。前缀失败即结束，不重试或把未启动结果补签为PASS。

只有这次前缀合格且实际运行依赖与冻结身份相符，才按FFN2的分阶段/保守成本规则决定full。首AR/64R速率不能代表所有后段；必须先写成本决定，再至多一次新的冷四行full。完整LN→Q→Wi→G→Q→Down→residual、同skip/刚写TMP、固定HIDDEN真实受理写回、原独立gold/末B/债务/lease/响应/655360B保护/整链周期和加法计量均保持。full≤8GiB/3600s/40Mcycles、真实semantic stall120s；启动后任何失败/COST_STOP或自然结束即交付，不追加第二次。

本合同只替代FFN2“首次xsim前一次纯准备纠正”的停点方式，其余冻结/验收/运行帽与停止要求保留。单重工具、无新agent/上板，G2338.224019s仅原OOC余额、5172s组合不重启；普通Q/L与整体生产控制/恢复停排，M003/M004不关闭。工程更新唯一E002实现的相关design/results、E005三摘要/A002真实状态并直接交付；不需要用户转发或批准普通host修复。
