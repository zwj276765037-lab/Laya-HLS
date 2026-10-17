# FFREF0：末FFN残差的独立数据与硬件接点

D-M004-FFN-RESIDUAL-SOURCE-01；M004/SM005/E005/R001；2026-10-14。依据[AT049限定审核](../results/measurement_first_LNQ2_review_20261014.md)及[工程残差只读定位](../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ2_FFN_residual_readonly_20261014.md)。A002唯一实现/工具，A001集中审核；在原完整加速器授权和测量优先范围内执行，普通准备与封装修正不需用户逐项批准。

## 本阶段要回答的问题

AT049已经以外部attention residual四行跑通LN→同Q→Wi→G→同Q→Down，接下来的算术缺口是末ADD_RESIDUAL。正确skip是LN之前的HIDDEN，原图最后做F32 `add(hidden, down)`，不是LN输出，也不加bias。现有Down gold已通过独立fixture oracle，但缺少与同一完整前向图Down中间值的直接逐位比对；原完整enc0输出存在，尚未为本链冻结四行出口身份。旧D2-I residual只有CPU/CSim及生成结构，固定B1/S64、stage4、64行、预填两源，不能当作本B1/S128、stage2、四行RTL入口。

本阶段形成可审核的独立两源/结果fixture和一个具体硬件接入方案，**只运行主机参考前缀，不运行DUT/HLS/RTL/OOC/P&R/上板或新的长链**。不以切片、主机PASS或接口图代签末残差硬件。

## 独立参考前缀与对照

复用AT038已经核验的原reference、GGUF、五ABI输入和request3/generation1/B1/S128原身份。先核实际SHA/bytes和完整model/numeric/layout/build来源，保留原生成器/参数区别，不通过改tag伪造生产兼容。数学、全S128 Attention依赖、矩阵完整K/N、GEGLU与量化/PS顺序保持；不缩成只算四token的前向图。

以一个最小、可审查的观察封装执行原图到enc0 `hidden=add(hidden,down)`、`keep("encoder_00_out",hidden)`，随后有意结束。允许给私有冻结reference派生添加观察/捕获钩子和明确终止点，保留原reference本体SHA与逐行差异；不得替换运算、从旧输出注入中间值、忽略异常或更改累加顺序。旧checkpoint与AT049 fixture只在新计算结束后用于比较。

需要冻结完整128×1024及batch0/row0–3的skip、Down和末残差结果，分别记录F32 little-endian bytes/SHA、来源坐标/模型/请求；完整各524288B、前四行各16384B。保留LN输出观察作为AT038/AT049入口复核，已有源可逐字节复用，不重新生成数学参考来迎合差异。主要比较为：

1. 新skip完整/四行与AT038匹配（完整SHA `bac04c09e6356fda7deb27c1889aaaccd803dca33bce87c3c92a6203e43482d8`，四行 `5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9`），LN观察与原AT038及AT049实际LN gold身份相同。
2. 新完整图Down前四行与AT049实际冻结Down gold逐F32 bit pattern对照，先按实际`.mem`字节顺序解码，不直接比较不同编码SHA。工程定位的独立binary应为16384B/SHA `4071d238f75711bf809dc06aaba5de3f364692419a07a38f7157910456b592b0`，启动前核实其manifest来源。
3. 新末残差完整结果与原独立oracle的B1_from_b0_S128/encoder_00_out逐字节比较。候选历史checkpoint完整SHA `9d1c8d619b5e29565ed37845bef4168986b90d0480b1e8f96b16f1507272e55b`；必须绑定实际本项目副本路径、原报告、请求身份，不因文件名相同就采用DUT输出或其他profile。冻结其四行切片身份并与新结果比较。
4. 明确原图F32加法的两个操作数及生产任务的src0=TMP/Down、src1=HIDDEN/skip字段映射。保留原有限数/异常数值规则、无bias及现有F32加法实现语义，不以宽精度加法/融合/不同舍入生成gold。额外检查4096结果有限且等于原图已得到的逐元素末加结果。

任何差异给首错位置、两边bit pattern、完整计数和实际来源；不改gold或数学让其吻合，不由局部同源声明代替直接对照。只读定位必要的Wi/G/权重边界可帮助解释，但不重跑全模型或追加别的reference候选。

## 同时完成的有限硬件接点设计

只核所选闭包，不重新盘点全仓库。给一页可执行接点表，引用实际源和冻结生成物SHA，选择一个下一阶段可证伪的四行残差producer路线。检查旧D2-I生成物是否存在可独立调用的可变四行/双源读写叶子；如参数已固化或依赖旧整体控制则明确不复用该wrapper，不启动HLS救活。可以推荐小型RTL搬运/控制连接既有位精确F32加法模块，但须点名可复用模块、握手/CE/reset/舍入与现有数值证据，不能只写“用一个加法器”。本阶段只设计，不实现新DUT或新算术。

接点至少明确：两个实际AXI读取源；原HIDDEN从LN到末加全过程的内容保存及租约；Down真实末B/发布后读取，禁止从gold数组代替读取；输出另一HIDDEN bank的合法地址/容量/Ref/epoch；完整model/request/generation/op0x62/stage2/layer0/rows4/D1024/bias_id65535；两源债务退休、目标写覆盖/末B/响应保持/实际消费及发布顺序。原生产映射HIDDEN bank0/1为STATE0/1 offset0，TMP为STATE1+8MiB，目的bank不能等于旧HIDDEN bank；不得把AT049只读source_mem冒作已发布生产HIDDEN，也不得无说明地把诊断Down地址`0x100040000`当生产TMP地址。

候选必须保留AT049单量化器/dualA、单矩阵/strict W，末加不经TB算完回灌。现KB1 writer的TN8/PS接口不自动适用于残差，明确新增搬运/打包状态、拟复用端口与存储规模。列出局部有效区/保护区和未扫完整BO的边界。下一阶段首先有限双源残差RTL，或在有成本依据时选择同runtime接链，具体取舍由主控依据本阶段真实材料确定；本合同不提前批准整合长链。

## 成本、修正与出口

一个参考捕获方案及最多一次有因封装修正；原数学/输入不变。每次实际host运行用原guard，CPU0–3/nice19/idle、MemAvailable>192GiB、≤8GiB/120s；全项目工具串行，原真实进展保护不变。可复用AT038已通过未变依赖，不重复生成全模型。计算前在新AT冻结输入/封装/工具清单与计划，保存原命令、guard、policy和所有失败；已有phase数学通过但收集脚本错误仅修受影响封装，不增候选或工具帽。若原完整前缀超帽，COST_STOP并交付已有边界，不以缩水S或模型换PASS。

出口是新独立skip/Down/enc0末输出完整及四行身份、逐位对照报告，以及点名现成算术核/合法双源存储/另bank输出的一个有限RTL接入方案和未知成本。尚未具备具体可复用生成物就写UNKNOWN，不宣称无需新HLS或物理可实现。无论结果如何更新E005三摘要并集中交付，A002不自行启动下一RTL/HLS/长链。

新准备脚本只在E002/experiment，证据E005/R001新AT；旧baseline及AT038/AT047–049原始证据不改，无新agent。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup继续停排；G2338.224019s仅OOC余额，5172s不重启。完整普通多窗口Q/L、Attention/WO/residual硬件上游、28+2层/122矩阵、13BO请求/恢复、联合资源/物理时序及M003/M004仍开放。
