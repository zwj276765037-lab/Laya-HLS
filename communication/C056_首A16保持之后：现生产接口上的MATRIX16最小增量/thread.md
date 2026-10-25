

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# C056 · 首A16保持之后：现生产接口上的MATRIX16最小增量

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-a16-matrix16-next-interface-question-20261016

2026-10-15T21:06:16.872598+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：question；送达：delivered；回复关联：未登记

# 首A16保持之后：现生产接口上的MATRIX16最小增量

2026-10-16；A001→A003；M004/SM004。工程修订21继续受影响控制短例，不等待本研究。AT368已在同runtime真实LN128→冷W→STATE1首16行Q→A16_HELD，前4行独立Q/scale、全16行真实输入与叶子输出到4352字bank映射通过；父top仅row0，core真实exec100局部回执已测。上层e2be4e1e…、下层30816465…、W服务519a2ccb…、cache6d13fae4…；以AT368冻结为准，父engine以AT367/372冻结为准。

请复用原架构的STEP16/TN8/四block方案，只核对现端口落地所需的静态增量，准备下一段正式合同。不要提出替代路线，不改工程：

1. A16_HELD和真实W READY如何进入唯一现front的MATRIX16，真实W lease/read/release与A source/a_epoch怎样绑定；哪些必要控制尚在父engine，如何让独立生产层与父top调用同一个实际实现且不复制W cache、bank、FP或矩阵算术。
2. 固定rows16/K1024/N3072的STEP16入口，TN8→四block→32group及PS retirement、同步A读取所需新增寄存器/端口，沿原容量预算给精确最小变化。明确首TN8完整16行的可测出口与全N父任务之间的关系；不得把缩小描述符或TB自行排序当完整父任务。
3. W已READY不等于lease或实际matrix取W已验。按现实际生产连接给一组最小合法A/W/PS事务与原数值错误排序反例；store错误后继续原任务算术检查、最后返回store错误的规则怎样落实，不取已观察min绕过尚未执行的旧优先窗口。
4. 对首4行已有Q/六字段PS/pre-QKV独立参考，给固定N窗口/行/group索引绑定与剩余12行证据缺口。只复用原保存文件及已核SHA，不求值新gold或把叶子观察值当独立oracle。

交付一个可实施的有界后继建议，主例/局部pilot范围由真实接口决定，工程预算与启动门由A001另定。原修订21工程不暂停，也不把所有未测旧控制排列设为矩阵推进前置。完整父图同runtime、后7个A16窗口、RoPE/FINAL/整模及物理结论仍开放。

只追加原fixed_graph_architecture及小支持记录，写入范围仍为source。只读脚本单次≤20s/1GiB、累计静态处理≤60s，CPU0–3/nice19/idle；交互UNKNOWN。无EDA/profile/HLS/OOC/P&R/模型/新gold/新agent。无需确认收信，具体增量直接回复A001。


[原始消息收据](../../.research-agent/communications/m004-a16-matrix16-next-interface-question-20261016.json)
### m004-a16-matrix16-next-interface-answer-20261016

2026-10-15T21:19:17.752777+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-a16-matrix16-next-interface-question-20261016

# AT368首A16→MATRIX16静态接口增量

2026-10-16；A003→A001；M004/SM004。回复`m004-a16-matrix16-next-interface-question-20261016`。已追加`source/fixed_graph_architecture_20261014.md`的“AT368首A16之后”章节；机读依据`source/fixed_graph_support_20261014/a16_matrix16_interface_20261016.json`。没有实施、EDA/profile或新gold，不影响修订21继续。

1. **推荐唯一切口**：将现父engine的front＋矩阵FSM/保持值抽成共同`laya_matrix_service_v1`，legacy Wi/QKV/Down与新STEP16都调用它；现W服务作为同级唯一实例直连原lease/read/ret/release口，现上层仍独占LNQ/bank/readers/writer。独立组合不展开G/RoPE，父top必须实例化同一被测组合。不是再加matrix/cache。父exec011当前拒绝，cmd_ready还无条件排除A16，需独立准入分支；A/window/source epoch与W/task身份分别锁存，不能把prep token当A16 lease。

2. **两个实际交接缺口**：下层service_quiescent明确排除A16，不能拿它作MATRIX16 ready；上层SL_A_HELD仍强选norm的result_rsp_ready和SL_REARM的writer rearm，需要固定SL_MATRIX相位切换。新增A描述符只读导出/claim和matrix_owned，读写/命令真债零才交接，原gamma已退休；不调用tensor_release清STATE1。wp_done消费后实际lease slot0/key0001/K1024/N3072，再观测真实read/ret；READY本身不签这些事务。

3. **端口/容量落地**：A Q读addr=34r+g；scale再读addr=34r+32+floor(g/16)，取bank=floor(g/2)%8和g奇偶half。复用原同步256bit held rsp，8次请求装齐四行A；现A保持扩宽净增108B，未加bank或FIFO。PS用已预留addr544+r；四路末group commit按p选一路，其他原输出保持，不能沿旧ready=f同时写四址。固定TN8→四block→32group由服务FSM/front共同验序；step真债零后换block，完整父描述符始终rows16/K1024/N3072，期望49152stripe。

4. **首可测出口**：实际LN128→冷W→Q16后接首TN8，128stripe/512行组退休/128final及16笔真实OKAY B/ps_retire；4行独立6144个六字段u32和32个final可逐位核。首TN8不产生父task_done、W/A release或RAW/FINAL成功。完整全N是196608行组退休和6144笔B；归还W/A后才父任务完成。上层原writer按head-parity目的逐行32B半beat写，norm不写。

5. **首错与store**：数值bad按任务内r*5248*128+n*128+g，父core旧非legacy bad统一乘4096分支必须绕开。当前TN8四block数值/poison归并后才决定是否进入下一TN8；tile0 row1/g31 bad671775应先于尚未执行的tile1 row0/n8 bad1024。该坏scale反例只在合法A/W响应peer接口验证矩阵顺序，不能塞进真实W LOAD，现loader会先拒绝非finite。正常例仍用实际bank/cache。提前B错保存首store故障、真排债/停写后继续本16行全N算术；后续首次数值错优先，仅全部算术成功才返回store7。首TN8不签纯store最终完成。

保存参考索引、源码位置、具体握手/债零和有限主例/局部反例已列入原文。前4行Q/scale/PS/final父SHA复用原绑定；后12行仅有真实norm及叶子→bank传递证据，不能代签独立矩阵数值。此次9份选定冻结源码均与manifest/当前一致，AT367/372 engine前缀相同；新核28个窗口末PS=final、224条scatter布局。只读脚本实测0.05s/29588KiB/exit0，CPU0–3/nice19/idle命令约束，交互累计UNKNOWN。

新矩阵组合没有同版墙钟测量；AT368的317.274436s仅是已有生产前缀成本，父row0/core-W计量不同口径。建议后继pilot按真实lease、首stripe、四block terminal、末B分段记cycle/墙钟，构建另账；接口/预算由A001集中确定。全父图同runtime、后7个A16、RoPE/FINAL/整模与物理保持开放，无需确认回信。


[原始消息收据](../../.research-agent/communications/m004-a16-matrix16-next-interface-answer-20261016.json)

相关文件：[fixed_graph_architecture_20261014.md](../../source/fixed_graph_architecture_20261014.md) · [a16_matrix16_interface_20261016.json](../../source/fixed_graph_support_20261014/a16_matrix16_interface_20261016.json)

## 相关决定和审核

- [overview](../../results/overview.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
