# LNQ2：运行文件准入与一次同DUT冷启动重放

D-M004-LN-QAR-RUNTIME-01；M004/SM005/E005/R001；2026-10-14。依据[AT048主控审核](../results/measurement_first_LNQ1_review_20261014.md)，接续已结束的LNQ1。A002唯一实现与工具owner，A001集中审核。本合同在既有完整加速器授权及测量优先职责内执行；工程可按下列条件连续完成准备、短前缀和一次full，无需逐步请求用户或主控批准。

## 验证问题与不变量

AT048的新xsim运行目录漏放7份冻结LN ROM，启动报告无法读取，尚未达到LN source AR。这是具体的运行准备缺口；该次full额度已消耗，旧COST_STOP保持。LNQ2只修运行包和启动检查，随后检验AT048已经冻结的发布观察及原联合链。它不是再次修改联合DUT、TB断言或增加算术候选的额度。

以AT048 manifest为源，全部DUT、两份TB（`laya_lnq0_source_stage_v1.sv`、`lnq0_chain_tb_v1.sv`）、生成LN RTL/ROM、IP、fixture/gold、模型/请求、真实BO容量/地址、命令/反压/AXI响应策略逐SHA保持。仅允许修改并冻结Tcl/launcher、运行文件部署与核验脚本、只读前缀观察脚本和证据记录。禁止强置内部信号、添加模拟时钟等待、改驱动或将已有快照变为guard续命心跳。仍是外部enc0 residual四行→单LN→真实NORM写回/发布/source lease→原唯一Q/dualA→Wi→真实DDR/reader→G/GATE→同Q→Down；不并列第二Q、矩阵或缓存权威。

## 运行文件准备与启动前闸口

1. 新建AT和新运行目录，不补写AT048的xsim目录、冻结源、日志或收据。可复用工程已提交的`run_lnq0_chain_v1.tcl`和`stage_ln_roms_v1.tcl`准备方案，两者都必须进入新manifest。工程提交时SHA分别为`2c7f28d45a8af296b8026073cd989a2b2ac80f666b10551121c51a6819e489b6`和`31d7e56d5e2b63cf1510d84129db542f35779704dfc051cf9f36f11286e17a85`；如为以下启动闸口派生，保存差异与新SHA，不能悄悄复用旧身份。
2. 编译/elaborate后从AT040冻结源部署7份原ROM。逐一核文件名、源/目标绝对路径、bytes/SHA、目标真实cwd与xsimdir解析。7项338B的真源以AT048 manifest及原missing_dat_audit为依据，不依赖任意live文件，不重生成ROM。
3. **每次真正启动xsim之前**，对已部署目标做独立verify-only检查，重新核同一实际cwd/xsimdir中的7项及全部运行期fixture/plusarg路径，包含FIXTURE、LN_FIXTURE、BOUND_FIXTURE和原后段数据入口。记录快照、工具、命令、cwd与snapshot身份；遗漏、不匹配或路径冲突则拒绝spawn。不能仅凭static时的一次复制PASS放行后来直接启动的xsim；verify-only不得用自动覆盖目标掩盖破坏。重新部署属于明确准备步骤，之后重新核验。
4. 在一次性临时目录完成host正例、缺文件和错SHA反例，证明闸口拒绝时模拟器未启动；覆盖已部署目标的缺失/损坏，不只检查源文件。已有helper源损坏反例可以作为有限历史材料，新闸口的目标反例需留下可核原输出/返回值。不得损坏原证据目录。启动日志若仍出现必需ROM/fixture无法读取，立即按运行包错误结束owned模拟器并留原日志，不再等120秒无进度；原guard其它保护不变。

## 有界执行与成本

先静态编译和运行包检查，再做一次≤120s的guarded冷启动前缀。使用与full相同的冻结snapshot、fixture、plusargs和响应profile；只用外部Tcl/launcher限制运行时长、只读观察现有计数/握手，不改两份TB。前缀至少证明无必需文件读取警告、LN实际source AR受理和实际R退休各发生一次；从现有`source_ar_count`/`source_r_count`或等价真实握手取证，不能用ROM复制标记、周期推进或命令接受代替。达到边界即可主动结束，明确记录PREFIX_ONLY，不要求等待整个原pilot任务完成。若只能取得AR而没有R，不准入full。

本阶段是一个运行准备方案；full前最多一次有原因的launcher/部署/只读采样脚本修正，总计至多两次static和两次≤120s前缀启动（按受影响范围复用已通过项）。无需为普通准备修正再次审批。新DUT语义失败、无法用允许的运行准备变更解决的问题，或上述准备上界耗尽，即交付，不改变TB/DUT救跑。

前缀通过后，每次重新核验运行文件，并在full启动前冻结可复算成本准入。AT047同DUT有效LN区间168898cycles/723.247161s及pilot207.736164cycles/s可作历史锚，但须结合新前缀核查运行等价性/成本，保留未进入后段预算。原3464.199672s估计（LN170031、后段206136×2.5、1.05余量）仅是条件估计，不是确定上界；旧独立周期不能相加当联合延迟，旧独立墙钟不能相加预测组合工具成本。缺依据或新估计不满足3600s则COST_NOT_ADMITTED，不启动full。

**最多一次新full**，从正常初始reset冷启动，不从前缀checkpoint续跑。允许复用已编译snapshot及已核运行目录，原始前缀/全量日志分开保留。运行中沿用原真实语义进度正则，静态核验/ROM标记/状态快照不能续命。新full一旦启动即消耗本阶段full额度；任何准备遗漏、Fatal、数值/协议失败、成本停止都保存原证据交付，不作第二full或追加TB/DUT修正。

所有工具串行且保存实际guard/plan/policy：CPU0–3/nice19/idle I/O、MemAvailable>192GiB；static≤24GiB/1800s，RTL≤8GiB/3600s/40Mcycles，前缀≤120s，语义停滞120s。host准备检查≤8GiB/120s，不占用他人进程。没有新HLS/OOC/P&R/上板或更大工具帽。

## 完整验证与交付边界

只有原`LNQ0_CHAIN_PASS`及全部原检查实际到达才能提交有限四行联合结果。需保留有效时点coverage witness、完整END/PUBLISH身份/响应及发布后持久owner，真实末B/存储、NORM→Q实际AR/R、原子query/grant、拒绝零AXI、响应保持/隔离、物理读债退休后按全键release、高水位和W绑定拒绝，以及原LN/Q/Wi/G/Q/Down独立gold、有效区/保护区终扫、lease和实际done消费。child0不能覆盖Fatal或缺少最终PASS。若失败，分别给出已达/未达边界和原始反例，不将AT040与AT035局部PASS拼接成联合结果。

交付新manifest和相对AT048差异、ROM源/目标身份表、每次启动前闸口记录和负例、static/前缀/full原始日志、真实策略样本、启动前成本记录、精确计量边界及E005三摘要。工程代码仅E002/experiment，证据E005/R001新AT；不启动新agent、不改写旧失败。

G2338.224019s仅OOC余额、5172s组合不重启。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup继续停排。普通多窗口Q/L、Attention/QKV/原地epoch、完整28+2层/122矩阵、13BO生产请求/恢复、联合资源与物理时序/上板及M003/M004保持开放。本合同只回答有限四行链，不签生产权限、全模型或部署性能。
