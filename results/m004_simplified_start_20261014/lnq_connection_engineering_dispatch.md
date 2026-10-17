# 同M004下一段：LN→Q真实连接

2026-10-15；A001→A002；M004/SM004/E004/R001。接续LN单行交付与原首错修复指令；用户“支持开始实验”的现行授权覆盖本段，不新增mission或用户审批。

已根据A003 `m004-lnq-thin-connection-research-answer-20261015` 在 **`project/missions/SM004.md` 修订6** 集中给出完整接口、数值/完成条件、独立参考、验证与预算。请直接连续执行：原LN首错复现/修复仍消耗原LN段预算；连接源码准备可推进，修复及受影响回归通过后直接开始连接验证，不等待额外放行。旧AT108保持旧SHA，不重综旧独立LN。

选定：`laya_lnq_row_v1`＝修复版LN＋一个512bit pack＋现有quant16_stream_row＋q0/q1各32×128bit与scale32×16bit。新增payload1088B、pack64B，不是整个Q/LN资源。唯一实现仍在E002，复用既有模块目录，A002负责RTL/TB/runner、模块design/results及E004记录；其他会话也在工作，不撤销他人修改。

必须读修订6的具体接口，尤其这些边界：

- LN首out_valid表示整行计算检查成功，先Q start再放行数据，不能等LN done才喂Q。
- 真实数据按16元素/half、64half/32group流入Q；Q结果先写不可见暂存，LN成功done、Q成功done/实际覆盖、真实零债务及空pack全部满足才row_valid。
- 对外为可重复的同步group读，256bit q＋16bit原FP16 scale，最多一条未消费响应；独立row_release握手排空读返回后释放，成功done在释放后报告，之后才接下一行。release请求优先新read。
- Q数值错仍喂完；协议提前结束则消费丢弃LN余数并真实排空Q。错误group可以无输出，不能等64个输出或把合法缺口抢报为协议错。失败行不发布，无真实退休就不伪造done。
- 两真实P1行从原input/gamma驱动，LN/stats/Q只用作比较；Q文件是32×(LE16 scale＋32 int8)，共1088B，不是两大连续区。保留历史abi_replay B2单行身份，不能称production-v2完整请求。

范围包括正常/反压、连续行、重复组读取/释放、LN错误不启动Q、真实Q晚数值错部分暂存不发布、一次实际可退休的输入协议错、Q在途共同reset后新行。晚数值错优先使用后段有限大gamma制造FP16 scale溢出，独立局部参考核期望；若受控注入须明确限定，不修改原gold。修订6已给出具体约束和计量边界。

本连接新增host≤600s/8GiB、static累计≤1800s/24GiB且单次≤600s、RTL累计≤1200s/8GiB且单次≤300s/1Mcycle（pilot≤120s计入）；全项目单重工具、CPU0–3/nice19/idle、MemAvailable>192GiB。同版连接回归通过后联合OOC累计≤1800s/24GiB、单次≤1200s，最多两次启动且仅明确构建失败可有因第二次，成功即止；成本停止不加帽重试。核真实完整top资源、RAM和blackbox，去重ADD定义。没有P&R/旧FFN/full模型/GPU或新代理授权。

无需为每次常规修复另交审核。保存实际启动/终态及身份、原预算归属，阶段末集中交付一份连接结果；未测的外部搬运、矩阵、整图和布线频率保持未验证。下一实际目标是让后继矩阵读到这份真实量化行，不扩大控制体系。
