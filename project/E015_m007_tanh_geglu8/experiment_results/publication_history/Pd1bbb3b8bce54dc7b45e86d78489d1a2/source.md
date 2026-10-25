# E015：冻结TANH与G生产验证方法

SM011 TANH-G8-08；A008仅写vector_and_ffn新M007文件/source增量和E015。原canonical/gold、A007共享FP/EXP/DIV/storage及A010矩阵只读。期望gpt-6.1-sol/xhigh，实际未核实。

TANH保留原glibc42节点、23add/17mul/2direct-div及逐F32舍入；现add3_e/mul4/radix4-div12、原DAG152edge，AT055八lane证据冻结复用、不重跑。小叶仅Vivado2025.2/U55C综合+opt，全IOdelay0.5ns/3.333ns/uncertainty0.1，物理阶段分开。

G纯engine只例化pair/math，公开96bit SFU与外9FP向量通道；验证恰一原storage/一TANH8/56mul16add，原phase1/双slot布局不改。实际32F32写ACK才置coverage，16bank同步读按一次whole-task命令自主s/row/chunk8；真实输出消费和所属slot债零才release。

AT058位保持整理AT007原128×2624全部x/gate/u/v/w/t/z/h/r/s/y/G产品，无新算术；原s-major索引回映行列。AT070仅对每案两个改动scalar用原SHA-bound primitive/libm重算，未变产品复用，按原input/u/v/w/t/z/y/gate及row/column检查全域首错。独立mask明确原域不可评估节点；错误和新genprefix均不伪造整任务成功。

所有actualcompute/EDA持同m007_heavy.lock、CPU0–3/nice19/idle I/O/MemAvailable>192GiB，RSS16/24/8/24GiB；原900/1800/3000/1800秒独立帽不重置。冻结v3生命周期由v4正常G、v5错误G只扩展cost绑定；真实同版pilot/原输入/编译SHA门、独立120秒checked-consume停滞、owned后代回收全部保留。完整命令和来源/版本/重现入口见R001/g_stage_handoff_20261022.md与AT081。

现接SM011 G-COMPACT-14，仍同E015/R001原余额、不OOC。仅math/pool改394条重复tag为完整seq16，公共96位保留gen/epoch/zero16/seq16全域校验；新增固定context/valid与输入/每FP通道顺序状态291bit全入账。其他mask/live/available/sent/received/真实债/coverage/first-error不删、不合并、不转payload，parent/shared源只读。


---
Published: 2026-10-22T10:14:59.861417+00:00
Publication: Ped06d615af1d49b88f038a7eae0f296a
