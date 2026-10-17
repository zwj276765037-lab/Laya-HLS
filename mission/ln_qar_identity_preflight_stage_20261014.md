# LNQI0：LN→QAR0共同身份、权重与单实例接口准备

D-M004-LN-QAR-IDENTITY-01；2026-10-14；M004/SM005/E005/R001。接续[LNF0限定审核](../results/measurement_first_LNF0_review_20261014.md)。A002唯一工程owner，A001集中判定。按既有授权直接执行本有界准备，不需逐项用户批准。当前结果NOT_RUN；本合同不启动联合RTL。

## 必须先解决的问题

AT040的canonical L13M与AT035两份Wi/Down `model_identity.hex`解码后各有233/416字节差异。前32B模型/数值tag相同，layout/build不同，64B之后的结构也不同。AT040的64B处是L13M magic/version/size；AT035对应位置不是同一编码。相同位宽不能视为相同schema，当前证据既不能断言权重数值不同，也不能证明两端身份兼容。

LN生成核已固定在`build/model-current-production-v2-20261011`对应header。以该真实项目包作为本轮唯一共同身份候选，不改83项生成物，不把AT035旧tag直接覆盖成canonical来消除报错。原包实际位于E002/experiment/build，不能写回历史工程；源GGUF/数学/独立gold不变。主控已读两份当前manifest，production-v2与cpu-embedding-ln-v4的W q0/q1/scale声明SHA相同而aux不同；这还不是实际文件或AT035抽取权重的兼容性证明。

## 本轮交付

1. **解码两个身份格式并定位实际消费者。** 依据各自冻结生成器、strict W/aux reader、portal/hub与LN header，列出416B字段、tag、版本、BO及aux约束；每个差异归类为编码、布局、build/ABI、真实数据或尚未知。明确哪些字段比较完整身份、哪些只比较选定字段。AT035实际数值request/generation为`0x100000001/0x200000001`，AT040为3/1；NORM Ref分别epoch1/epoch9。后继有限候选统一为AT040真实来源的3/1、B1/S128、batch0/row0四行和合法Ref，不把旧样本改写成新身份已过。
2. **从真实canonical包核Wi/Down数据。** 核原GGUF/包manifest/header/五BO身份、实际W q0/q1/scale和aux边界；从原描述符提取enc0 Wi K1024/N5248、Down K2624/N1024所需权重/scale/aux字段，逐字节对AT035冻结的完整相关payload及独立fixture。给出offset/bytes/SHA和布局公式，不只看文件名或头tag。涉及bias0也明确其真实配置与权限，不靠绕过aux检查。若同数学数据仅物理布局或元数据格式不同，允许在新AT中生成可复算的host fixture/编码映射，证明重排后逻辑元素、原PS/输出gold及容量不变；禁止从DUT输出反造gold或修改旧fixture。
3. **给出可实施的单实例接口表。** 保留AT040独立producer/monitor/hub；后段保留AT035唯一quant_task/dualA/resident/strict W/writer，不能并列实例化两套完整shell。列出完整P/Q/L、model、Ref、window、portal generation的包来源、传递和保存位置；source-query/grant与外部Q实际接受的同边沿关系、G优先不提前取得lease、拒绝路径只报一次且零AXI、响应被消费并且物理R债退休后按完整原键release。高水位不能被丢掉；外部Q端口缺L13M/generation须由明确适配边界保存和校验，不新增全局READY权威，不将grant替换为常量。
4. **共同地址和后继验证清单。** 保留STATE0容量16920576B、HIDDEN offset0、NORM offset8MiB；Q必须读LN实际store而非AT035预装`0x100050000`。列出真实LN/Wi/GATE/Down地址、未授权区、source lease/dualA epoch1→2/矩阵分时复用顺序，以及每一处合法身份转换依据。原G优先仲裁和QAR0定向竞争保持。列出新组合static/prefix pilot/full的可测前缀和成本估计方法，不能相加AT040/AT035旧墙钟作准入保证；不在本轮运行这些工具。

本轮实现范围仅必要的host解码/校验/fixture生成脚本及报告，不修改RTL/数值算法/独立gold/生成核，不生成新模型包或扩生产控制。轻量字段方程检查只作静态证据，不标成RTL PASS。若canonical包不能在原strict W/aux合同内表示，或payload/布局不能逐项对齐，保存首个具体反例与受影响边界并交付，不扩大为通用schema迁移或盲目改tag。无依赖的只读核查可继续完成。

## 成本和验收

一个共同包候选，最多一次有明确原因的host封装修正；不存在第二个模型/数值候选。脚本仍在E002/experiment，输出和冻结证据在E005/R001新AT；尊重其他人的修改，旧manifest/receipt/raw不变，不新增agent。主机执行沿原CPU0–3/nice19/idle I/O、MemAvailable>192GiB、8GiB/120s有界入口，重工具全项目串行；若无法完成即保留COST_STOP，不加帽。单纯文件读取/人工源码核对按只读事实记录，不能补写不存在的guard采样。

交付字段对照、包/权重实际SHA与逻辑字节比较、生成脚本/新fixture身份、单实例接口表及未解决反例，更新三摘要并直接回主控。通过只表示联合入口准备有依据；LN→QAR0同runtime仍NOT_RUN。后继联合RTL由主控在这些具体证据基础上形成下一有限合同，不要求用户转发或重新授权常规工作。

本轮仅为四行单窗口连接准备。`source_provenance_06`的C账本、`portal_controller_25`受控caller、`generated_source_lease_05`四窗口sideband与AT040单窗口真实Q证据分别保留；不合并成完整普通Q/L物理PASS。M003真实逐窗口producer/portal查询/Q债务/父L、多贡献Attention、QKV和原地epoch仍是最终义务。无新HLS/OOC/P&R/上板/预算；G2338.224019s仅原OOC余额，5172s组合不重启；整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排，M003/M004开放。
