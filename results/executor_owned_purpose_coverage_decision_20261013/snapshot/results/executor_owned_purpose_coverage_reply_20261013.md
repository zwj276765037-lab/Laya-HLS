# Owned program purpose负例覆盖位置核定

决定：D-M003-OWNED-PURPOSE-COVERAGE-01。回复 executor-owned-purpose-negative-scope-question-20261013；M003/SM003/E003/R003，A002唯一整合。

工程指出的wire边界正确。主控已核现有 `handoff::decode`：LHC1 p[8]解为kind，source解码前明确恢复 `source[8]=1; source[9]=0`；LBS2自己的parser才从bytes8/9读取16bit purpose。当前GRANTED owner wire没有独立携带unsupported source purpose的位置。改kind、借保留位或另加字段均不能冒称原purpose负例，也不应为本次修复改schema。

因此，撤回[上一审核](executor_wide_fifo_program_repair_reply_20261013.md)中“至少用同一真实owner输入路径加入一个不支持purpose的负例”这一不可表达的路径要求，以本决定为准。历史审核原文保留，修复完整校验及真实生成物验证的要求不变。

## 接纳的最小覆盖

1. **实际owned top正路径**：沿原合法LHC1 kind4、解码后purpose1，继续正在运行的新program RTL原四case。证明真实安装、嵌套校验、canonical完整比较及原往返/成功行为；不能把寄存器初值或只完成初次decode当作canonical执行证据。已冻结RTL03不修改、不因本答复重启。
2. **同一冻结生成物的validator端口负例**：接纳独立有界TB实例化真正被nested `validate_2`调用的 `laya_graph_program_owned_sequencer_p_anonymous_namespace_validate_fields`，连同其实际生成依赖，不手写替身、不编辑生成RTL、不新增HLS。该模块实际接口为完整Message RAM的双512bit读口及16bit `purpose`；不是另一个64bit decoded RAM版本 `_18`。RAM按实际读时序提供同一完整合法Message，先purpose1正对照，再只改变真实scalar为0、2、0x0101。0x0101应拒绝，防止仅比较低8位。按实际ap_start/ap_done及ap_return核定完成和非OK，测试超时也不能算拒绝通过。所有其余模型/descriptor/RAM字节保持，记录模块、依赖、输入、caller连接及SHA。
3. **范围要准确**：该独立validator没有owner安装接口，故它只能签“实际生成validator对受控参数返回拒绝”，不能单独签“顶层无owner安装副作用”，也不能称LHC传输了unsupported purpose。顶层隔离/无派发属于原actual owned RTL的可表达错误case；host07 direct/nested负例仍只签host。主控已静态核HLS05 nested caller将寄存器接到真实16bit purpose、validator与16'd1比较；工程提供的m[207:192]实际提取定位连同顶层正路径和本端口负例，构成本次修复的分层证据，不合并成不可表达的端到端wire负例。

现阶段不另要求LBS2 wire负例或扩大测试矩阵；若原受影响LBS2 consumer回归本来需要该负例，则复用其真正purpose字段并单列范围，不能替代本次生成nested validator。无需改Host/LHC/LBS布局、挪保留位或常量化实际对象字段。

HLS05完成及RTL03运行作为工程新进展记录；本轮只核上述接口/源码，不以此代签HLS05整个冻结生成交付或尚未完成的RTL行为。工程可按此范围串行完成补例，普通program RTL、executor受影响host/候选和实际adapter准备继续，不等待逐项审批。C完整NORM周期基线先行，D/Q及完整CLOSED/rearm后置；C/D周期未取得、M003/M004未完成，原单重工具/资源帽/G仅OOC余额和不重启5172s组合保持。

证据快照与身份：[verification.json](executor_owned_purpose_coverage_decision_20261013/verification.json)。主控未运行DUT编译、仿真或HLS。
