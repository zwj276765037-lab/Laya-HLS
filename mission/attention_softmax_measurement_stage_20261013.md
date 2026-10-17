# 下一算术阶段：Attention softmax计量与一个调度候选

D-M004-ATTENTION-MEASUREMENT-01；2026-10-13；M004/SM005/E005/R001。A002唯一实现、整合及重工具owner，现有helper按原职责复用，不新增agent。沿用户测量优先重排，在LQ1R两版修复no-go后切换实际算术入口。

## 入口及要回答的问题

选择本项目E002复制树内的`results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/source_manifest_v10.json`完整冻结闭包，SHA256 `34145bda45ba482150a8be37876288771e01b3952bbb5de6ba892340d5f8b0b2`。原93源、81项head snapshot及3项数值引用已按现有有界盘点重核；运行器须将历史绝对路径显式映射至本项目副本并核SHA，禁止读写旧Laya-baseline作为新运行入口。唯一实现仍为E002/experiment，后续AT证据进入E005/R001。

历史真实enc0/head0、B1/S128、128query/K128/D64、72有效mask的正常计算为604317cycles：QK250888、softmax287173（47.52%）、AV66256。完整TB1608896与加载140288为不同口径。旧head128_01真实471.004332s仅作成本参考；tile16_03的首错/CE/reset范围单独继承。Attention现物理OOC是COST_STOP，不因切换阶段重启。

本阶段问题是：**softmax的287173拍主要花在原EXP等算子自身服务，还是可由当前调度消除的供给、提交及阶段切换等待？** 保持原M16/A16/D4/EXP4资源与数值图，先新增最少计量ATN0，再只选择一个有实测依据的调度候选ATN1。原604317用于定位和核对；新baseline是为回答上述缺失观测执行，不是为盘点重复运行head。

## 数值、接口与能力不变

保持原真实Q/K/V、mask和所有独立中间/最终gold；QK64项相邻树、原scale/finite mask/sliding规则，softmax完整行max→原exp→固定相邻树sum→原F32除法，AV按key升序非FMA。沿原逐位比较，不换在线softmax、近似exp、reciprocal乘法或归约树，不改容差、gold、shape及mask。所有128query/8个16row tile连续完成；输入与输出不得由TB预计算替代真实QK→SM→AV。

原M16/A16/D4及4个EXP实例、原FP/EXP内部实现与寄存器延迟、RAM容量/访问语义、命令端口、完整身份与epoch、validate-before-commit、首错rank/返回元素及已受理队列债务保持。不是原生IP或算术HLS重新生成任务；不得用零流水组合FP链换低cycle。候选只改softmax局部issue/retire/调度握手及必要小量metadata，不能无记录增加算子、更多query上下文、改变bank所有权或扩生产控制。

保持ap_ce低时实际状态/管线保持、reset在既有优先级抢占和清理、旧epoch/scratch不复用、实际ap_done/continue退休。正常head的PROTOCOL=0与tile16的协议/首错检查分开报告；不得把正常full的PASS称为整个协议覆盖。

## ATN0：一次同源可复算基线

从冻结v10派生仅观察TB/runner，所有原gold、完整数值检查、命令输入/消费和CE/反压安排保持。源路径映射、观察引用适配、保护/runner普通修复按授权连续完成，保留差异和原失败，不再逐项请求主控放行。

优先利用现有状态与真实接受/返回事件，增加以下最少计数：

- 全TB、配置/加载/读回开销，真实cmd19/20/21接受→实际完成/消费；同时报告wall clock edges、ap_ce enabled edges与故意暂停。旧每阶段正常命令含8个launch边沿、enabled profile不含的口径差异须明确处理。
- softmax每行SM_MAX/SM_EXP/SM_TREE/SM_DIV与阶段切换的互斥enabled状态账，和等于相同softmax区间；QK/AV独立统计。内部读、算、写或多worker活动重叠不能相加成总延迟。
- 每个EXP worker实际开始/完成/结果提交、占用时间、可接受而未发射/输入未就绪/完成待提交；按真实transaction资格排除idle ap_done。先定位已有1/78/89/97 enabled-gap分布的实际服务边界，不能把所有gap自动叫调度浪费。
- 原A/D发射、返回、queue/credit、tree层次屏障与RAM供数等待，区分模式闲置、算法依赖与可改变阻塞。原M_wait/A_wait含非该模式工作边沿，不是全部可消除stall。

保留原所有基本运算/中间值/最终输出检查、实际EXP16384、D16384及其他既有服务账；动态计量不改变原任务工作量。对4个EXP给出由真实服务时间和可并发性限定的条件下界/区间，说明资源空隙与下游阻塞是否重叠。若旧日志已足以回答某项，按身份继承，不为重复取得相同数字重跑。

执行static→原入口支持的最小完整tile normal pilot（优先16query、K128/D64、PROTOCOL=0，≤120s）→有依据full128query normal。pilot不足以证明完整head/协议；full成本用旧471s、实际pilot及新增观察开销保守估计，不线性担保。保持单一连续full进程，不拼接reset窗口冒充head。最多两次有具体原因的观察/runner修复仍无有效基线即交有据停止，不能扩大帽。

## ATN1：有可改变成本才做一个候选

ATN0后工程自主在上述范围内选一个实测支持的softmax调度改动，写清阻塞证据、预期改变的真实边沿及原服务下界。不得仅看47.52%就认定同样比例可消除，也不因算子空闲于其它阶段而盲加队列。若主要时间已受原EXP服务或数值屏障限制，没有同资源有效改动，则交no-op结论，阶段可以有据完成。

候选及其至多两次有具体证据的受影响修复在原帽内连续执行；不同时调多条路径、不扫参数、不增加EXP/M/A/D实例。新候选必须与ATN0相同完整输入、缓存/复位状态、命令/CE/消费策略、原gold及计时端点比较。任何新增pending/占用字段计入逻辑资源账；既有FP时序边界和全容量保持，不宣称物理LUT/FF/Fmax。

保留拟采用候选前，复用原tile16_03的PROTOCOL=1有界首错/CE/reset/合法重载/chain/ledger回放，与新候选冻结绑定；新的pending字段纳入原真实CE/reset状态快照。原六类Q/math首错和M/A/D/EXP活动覆盖不删除，不用正常head替代。未变而与改动无关的helper/容量证据按原身份继承，不重做全模型或全恢复矩阵。

交付ATN0/ATN1同口径表：全部数值、真实cmd完成和消费、互斥状态、重叠等待、算子服务/占用、完整head与加载/读回成本、工具成本及逻辑资源代价/物理UNKNOWN。收益不足或无改动同样收束，不设新的百分比门槛。此模块无AXI master/13BO末B，不声称该端点已覆盖物理内存或完整请求。

## 不变约束与停止线

不重启Attention OOC，不新跑算术HLS、整体OOC/P&R/上板，不恢复executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup。LQ1R两版上界保持关闭，没有第三版；LQ0/LQ1历史证据保持，LQ1不是生产采用。KB1保留，KB2/CT0当前轮收束。

全项目一个重工具，CPU0–3/nice19/idle I/O/MemAvailable>192GiB；static24GiB/1800s、Attention原RTL8GiB/3600s/40Mcycles、pilot≤120s及120s真实语义停滞保护不变。重复同点无新依据即停止，不延长保护/改TB delay，G2338.224019s仅OOC余额、5172s组合不重启，无新预算。工程A002按阶段自主执行，主控集中审核；M003/M004、完整模型/请求/恢复、联合物理资源及板端最终验收仍未完成。
