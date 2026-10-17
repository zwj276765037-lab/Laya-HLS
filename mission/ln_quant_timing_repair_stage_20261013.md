# LN下一入口：固定时钟目标下的有界流水修复

D-M004-LNQ-TIMING-01；2026-10-13；M004/SM005/E005/R001，A002唯一实现、整合与重工具owner。本决定承接用户测量优先重排与[D-M004-LNQ-MEASUREMENT-01](ln_quant_measurement_stage_20261013.md)，使用原LQ1至多两次有证据受影响修复的剩余额度，不另开优化候选扫描，也不重置任何资源帽。

## 选择依据与目标

LQ1同输入、同TB/响应及真实store→Q边界已取得全TB659334→528307（−19.8726%），全部独立gold通过；但HLS估计slack−48.76ns。主控已核AT015调度State3内row读→F32减→F32乘→检查形成53.626ns路径，且AT016实际两个新增native IP的`C_Latency=0`、`Has_ACLKEN=false`；对应wrapper没有时钟端口。旧LN使用有寄存器的浮点算子，配置仍可核。

下一问题是：**在原时钟目标与数值/错误合同下，明确保留浮点算子的寄存器流水后，还能保留多少LN周期收益？** LQ1原样保存为正常样本周期候选，不替换生产默认或作为部署加速结论。LQ0继续作为有冻结身份的比较基线；其HLS估计也不等于物理时序通过。

## 唯一修复方向

从AT015的31文件冻结闭包派生LQ1R，保留已核唯一normalize-loop变化的来历。仅调整最终1024元素循环中`delta=row[i]-m`与`norm=delta*inv`两项F32运算的实现/延迟约束及该循环局部调度。优先使用工具实际支持的局部operator binding/latency约束，参考原已生成的注册浮点算子配置；由工程核语法及实际生效映射后直接实施，不等待逐项审批。

不再把II1当必须达到的目标；允许调度器根据真实寄存器延迟和错误返回依赖给出可实现II。目标频率150MHz、period6.667ns和uncertainty1.800ns保持，不通过放宽时钟掩盖路径。旧wrapper名的HLS stage4/3和native FP core的`c_latency=2/1`是不同口径，不能把数字直接互填；新值必须由工具配置、wrapper和实际调度报告共同确认。禁止仅手改生成IP/Tcl/RTL给组合算子补寄存器，那会脱离HLS状态机的延迟合同。

原binary32运算、相邻树mean/variance、eps/sqrt/reciprocal/normalize顺序、gamma能力、finite检查/首错row+col、错误优先级和外部可见写入保持。不开fast-math/FMA，不改gold/容差，不删early return、不把错误判定移到全部输出提交后。若需局部纯算术helper边界，仍只能表达原相同操作与校验顺序，不能引入新的候选输出/发布权威或整表架构。若现有错误依赖使该方向不能达到目标，交具体依赖与有据no-go，不偷偷改错误合同。

## 连续执行与收束

1. 先在既有source/design/results记录两算子旧/新实际映射、约束及可证伪预期；保持原g++主机/HLS类型模型对照及其错误检查。只重生成受影响的单LN核，按实际报告核操作流水、最终II、时序估计与资源；不能只查看pragma或生成退出码。
2. 若候选仍有该路径时序违例、工具忽略绑定或仍落回零内部流水链，先保留收据和有界定位。只允许一处有新证据的第二版受影响修复，两版耗尽或同点重复无新依据即结束；不扫II/latency/资源组合。尚未改善时序的候选不再投入rows16 full来重复证明已知的低周期现象。
3. 当实际报告显示寄存器边界生效，原时钟/uncertainty下候选top及受影响子模块没有估计时序违例，再串行static→≤120s rows1 pilot→有成本依据的rows16 full。此为工程自动检查条件，不是等主控再签一次。若周期收益消失或资源代价不合适，同样如实完成判断，不设置新的提升百分比门槛。
4. 比较LQ0、LQ1、LQ1R同口径完整gold、全TB/真实LN run/末B/END/Q实际消费/fullA/零债务与三向196608B流量；response profile、真实存储与lease边界不变。报告II、注册FP配置、HLS估计资源与slack。更改的仅是生成LN，其他冻结控制连接不带入live漂移。
5. 候选若拟保留为后续接入基础，复用原已定义的F9 case5/6一行真实producer错误归属窗口做受影响有限回放，保留caller completion=0及scope/tracker retained断言。case1–4未变前置拒绝按身份继承；不扩完整恢复/重入矩阵，也不修改原错误gold。若没有拟保留候选，不为凑覆盖启动这些工具。原主机partial/error检查不替代这一生成核回放。

本阶段最多两版有依据修复，工具预算仍是原分类内存/墙钟和120s真实语义停滞保护。若第一版可用，停止追加改动并交付；没有可用修复，LQ0保留、LQ1周期证据保存，主控据结果选择下一算术入口。全部尝试保持原始失败、冻结与运行证据，不改历史收据。

## 层级与排程

即使HLS估计满足目标且RTL周期下降，也只支持功能/周期与HLS估计层级；本轮没有OOC/P&R/物理Fmax/板端或联合资源结论。不能用假定150MHz换算部署收益，不能把LN与Down局部cycles相加。

KB1保留，KB2/CT0本轮收束。整体executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup继续停排，不新增Attention/矩阵/控制候选，不增加agent。现有helper可按原职责复用，A002单owner串行发工具。CPU0–3/nice19/idle I/O/MemAvailable>192GiB；HLS/static24GiB/1800s，LN/Q RTL8GiB/3600s/5Mcycles、pilot≤120s、120s真实停滞保护不变。G2338.224019s仍只OOC余额，无新OOC/P&R/上板或预算，5172s组合不重启。M003/M004最终完整请求、模型、恢复与资源义务未关闭。
