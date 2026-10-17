# 综合为何增长到数百 GiB

**已定位到编译器处理全局初始值的一条异常昂贵路径：它把一个含数百万分片的大对象拼成宽整数，连“移位多少位”这样的小数字，也按整个宽整数的位宽创建并缓存。** 受限重放实测目标位宽为 **2,653,009 bits**，一次拼接含 **6,480,158 个分片**。这个乘法关系足以解释数百 GiB 的主机内存规模，比“综合时间长”或“有108万条独立指令”的解释准确得多。

唯一初值对照进一步支持了对象归属：只把复制IR里静态`runtime`的混合初值改成整体零初值，前面15个阶段的指令统计保持相同，随后以约3.57 GiB峰值跨过全局初值转换，在后续函数指针转换时报错退出。这不是完整HLSGen通过或生产修复成功。原360.6 GiB运行没有全程分配跟踪，不能声称每个字节都已归因。**生产源码、模型和综合配置未改；完整网络RTL仍未生成。**

## 现场发现了什么

相同bitcode和相同优化参数的重放，在 `Generate HLS compatible IR` 步骤出现以下真实调用栈：

`HLSGen → generateGlobals → rewriteGlobalVariableInitializer → mapBytes → GenerateBitConcat → ConstantInt::get`

也就是：生成硬件兼容中间表示 → 重写全局变量初始值 → 位拼接 → 创建整数常量。首轮栈和原运行的时间顺序一致：Performance后的简化已经结束，随后才出现持续的内存增长。原日志末尾的描述符partition提示早于这个位置，不能把它当成最后正在执行的高内存步骤。见[受限重放记录](reflow_probe/probe_findings.md)。

2026-10-07 16:27（Asia/Shanghai）的[精确断点记录](reflow_width_probe/width_captures.json)进一步读到了：

| 项目 | 实际值或明确口径 |
| --- | ---: |
| 目标整数位宽 W | 2,653,009 bits |
| 输入分片数 M | 6,480,158 |
| 创建移位常量时读到的位宽 | 同样是2,653,009 bits |
| 首次断点的移位偏移 | 0；未逐次跟踪完整循环 |
| 每份密集APInt的数据载荷 | 331,632 B，约323.86 KiB；按64bit存储单元向上取整 |
| 唯一常量的表键＋常量对象两份载荷 | 663,264 B，约647.72 KiB；不含其他管理开销 |
| 360 GiB所对应的这种不同常量个数 | 约58.3万个，仅相当于M的约9%；**量级换算，不是已观测计数** |

为什么小数字会占这么大？[当前编译器的只读反汇编](GenerateBitConcat.disassembly.txt)显示：循环先把分片转成目标类型，再用同一目标类型创建累计偏移常量，随后做移位。对结果是否为零的判断发生在偏移常量创建之后。[ConstantInt实现](ConstantInt_get.disassembly.txt)把APInt作为LLVMContext常量表的键，并另保存ConstantInt值；大于64bit的APInt使用完整宽度的密集载荷。

因此这里的危险规模是“不同偏移常量数 × 整个目标整数宽度”。如果处理到几十万个不同偏移，仅这些宽整数载荷就能达到数百GiB。当前证据支持这个**具体分配机制和量级解释**；没有测出完整循环的分配总数、峰值终点或严格的尺寸增长曲线，也不把常量表驻留直接称为内存泄漏。

## 与工程中哪个对象有关

对照支持的触发对象是静态`runtime`。它的类型布局为8,720,240 B，其中13个数值数组占8,641,536 B、共6,456,576个标量元素。源码在[full_kernel_wrapper.cpp](../../hls/platform/full_kernel_wrapper.cpp:5)把它声明为全局静态对象；[结构定义](../../include/laya_full_runtime.h:102)把大缓存、所有权记录和控制字段放在同一聚合体里。

原始IR中，`runtime`不是一个整体`zeroinitializer`，而是含208个嵌套零初值和少量非零默认值的显式ConstantStruct；非零值包括状态枚举和255类哨兵。其约646万个大数组元素与现场648万个分片处于同一规模，但首个断点没有直接取得全局变量名，**这一数量吻合本身不能替代对象归属证明**。源对象总位数也不能直接当作目标IntegerType位宽；报告中的常量大小只使用现场W。

### 唯一初值对照：避开全局初值热点，后续函数转换失败

在复制的LLVM IR里，仅把`@_ZN12_GLOBAL__N_17runtimeE`的顶层初始值换为`zeroinitializer`。[独立核验](review_prechecks.json)确认仅第2638行变化，类型、数组尺寸、链接属性、对齐、metadata、1045个函数定义及访问、其他全局变量均逐字保留；重新组装再反汇编仅ModuleID行不同。172项cc1参数在替换诊断目录后与原受限重放完全相同。

| 核验项 | 本轮实际结果 |
| --- | --- |
| HLSGen之前15个cmplx阶段 | 所有函数按名称/来源归一后的指令、块、访存及深度统计逐阶段相同；ID排列差异未当作语义变化 |
| 最后fe.simplify | 两侧函数自身指令合计62,066，顶层inclusive为1,078,899 |
| 运行时间 | 2026-10-07 16:35:56–16:39:18，约202.57秒；HLSGen在16:39:15进入 |
| 已记录树/clang RSS峰值 | 3,738,992 KiB，约3.566 GiB；未触及8 GiB停止阈值 |
| 最低主机MemAvailable | 436,453,228 KiB，约416.23 GiB；底线192 GiB |
| 退出与输出 | cc1自然退出1；HLSGen无完成标记，未生成`a.g.lto.bc`，没有启动后续综合 |

实际错误为诊断变体的`full_recycle_request`指针phi/selection及`Select(a8)`类型转换失败。只读汇编确认`HLSBuilder::buildModule`在`0x23c0b1e`先调用`generateGlobals`，再在`0x23c0b36`调用`generateFunctions`；后者调用`FunctionBuilder::buildFunction`，其`visitSelectInst`分别调用与日志一致的`emitUnsupportedSelectOnPointers`和`emitUnsupportedSelectOnDiffTypes`。因此这一变体推进到了全局初值转换之后，并非在原热点之前就提前退出。

这项证据把原调用栈和`runtime`初值联系起来：大零数组与少量非零元数据混在同一全局聚合初值，会触发已定位的昂贵转换；整体零初值避开了本次热点。由于对照故意改变初始状态，**不能把清零当生产修复，也不能认定诊断变体的后续指针错误必然存在于冻结生产输入**。后续完整编译峰值和物理综合结果仍未知。见[运行结果](reflow_runtime_zero_probe/probe_result.json)、[15阶段比较](reflow_runtime_zero_probe/cmplx_comparison.json)和[原始日志](reflow_runtime_zero_probe/driver.log:994092)。

## 为什么此前的数字容易误导

Design Size Report中的顶层计数包括重复调用路径，并不是互不重复的IR节点数。

| 阶段/运行 | 顶层inclusive累计 | 函数自身指令合计 |
| --- | ---: | ---: |
| 原自动化配置的Performance数组划分 | 64,221,604 | 143,277 |
| 仅关闭自动pipeline的同阶段 | 63,796,796 | 106,921 |
| 关闭相关自动数组划分后的同阶段 | 1,361,775 | 72,264 |
| 最后Performance简化 | 1,078,825 | 61,991 |
| 随后的fe.simplify | 1,078,899 | 62,066 |

这些变化说明工具变换和调用路径展开确实存在，不能据此推导“108万个独立操作需要360GiB”。真正定位到的后续热点属于全局初值转换，而非从这张表直接得出的硬件规模。[任务记录](../../hardware_agent/task.md)的当前解释已按此纠正；原始日志保持不变。

## 下一步应改哪里

后续应优先验证**编译输入的状态组织和初始化方式**，例如将大数值缓存与带非零默认值的控制元数据分开，或者在保持请求/复位语义的前提下避免一个巨大全局混合初值。候选方案还必须核查所有权初始状态、255哨兵、错误恢复和持久状态，不能直接删除这些字段或把所有默认值清零。工具版本对照或向AMD提交最小复现，也应围绕已经捕获的全局初值/宽整数常量路径。

本轮只诊断，没有实施上述生产修复。继续单纯扩大主机内存不能消除“分片数×目标位宽”的开销；现有证据也没有给出FPGA资源超限、布局布线或上板结论。

## 补充实验与保护边界

- 首轮相同reflow重放在约4.02 GiB树RSS结束；此前约2.7 GiB的CUDD初始化峰后来回落，不能与最终持续增长混为一谈。
- 精确位宽探针配置8 GiB上限、192 GiB可用内存底线；实际1秒采样在8.44 GiB树RSS读到越限并清理，最小可用内存仍约410.8 GiB。[结果记录](reflow_width_probe/probe_result.json)保留这次约0.44 GiB超调，未声称严格无瞬时越限。
- [四个4KB/16KB小例](init_probe/init_probe_findings.md)都被工具拆为独立flag/data变量；编译仅约0.109秒，采样可能漏短峰。它们未复现原聚合路径，不能作为排除该机制的证据。
- 诊断均串行、低优先级、限制4个逻辑CPU和idle I/O，只作用于自身进程；未调整服务器全局设置或其他项目。原始记录使用UTC，人读时间使用Asia/Shanghai。

源对象总位数69,761,920与现场W不相等；当前编译器从类型字段的24位内容读取整数宽度。源总位数对2^24取余为2,653,056，与现场W差47位。这仅是供工具方调查转换/编码边界的线索，尚不能认定发生截断或数值错误，也没有用于上面的内存换算。

[分析方案与实验合同](analysis_plan.md) · [二进制证据摘要](binary_evidence.json) · [最终审核](final_review.json)

初值转换与函数错误的先后顺序：[buildModule](HLSBuilder_buildModule.disassembly.txt) · [generateFunctions](HLSBuilder_generateFunctions.disassembly.txt) · [visitSelectInst](FunctionBuilder_visitSelectInst.disassembly.txt) · [诊断发射入口](emitUnsupportedSelectOnPointers.disassembly.txt)。这些均来自本次实际安装编译器的只读反汇编，未修改编译器。
