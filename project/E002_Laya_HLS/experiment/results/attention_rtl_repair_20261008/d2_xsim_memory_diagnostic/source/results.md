# XSim generated memory model diagnostic results

设计、权威源位置和限制见[design.md](design.md)及[合同§7.8](../../repair_contract.md)。2026-10-08在Vivado Simulator v2025.2完成独立小诊断，使用冻结fixture的单事务前缀；**没有运行Attention DUT、综合、实现或数值RTL检查**。

## 执行和完整性

从冻结v3生成的`file_agent_pkg.sv`、`file_read_agent.sv`、`file_write_agent.sv`、`mem_model.sv`保存[原件与哈希](source_manifest.json)，诊断修改仅见[精确diff](instrumentation.diff)。[最终packet](../runs/final_packet.json)绑定了testbench、DPI C与实际`.so`、每条编译/运行命令和守护、XSim snapshot及全部输入hash；[逐次日志/阶段结果](../runs/diagnostic_results.json)和[量化分析](../runs/analysis.json)为机器可查证据。

每个job使用2GiB任务树RSS、120s、2个逻辑CPU、nice19/idle IO、主机MemAvailable至少192GiB，守护间隔0.1s，逐项串行。最终`gcc`、带`-L uvm`的`xvlog`、`-mt off`的`xelab`和12个XSim进程均exit 0且未触发守护。首版`xvlog`漏`-L uvm`，首版`xelab`诊断DPI库定位错误；失败命令/日志及修正后的命令均在packet中，两个失败均发生在任何样本运行前。成功xelab历时66.49s、树峰644,888KiB；12个XSim单次约5.35–5.47s、最大树峰852,532KiB。12次进程最低主机MemAvailable大于448,000,000KiB。

Python独立解析冻结fixture的8B大端数量头`786432`、8B固定trailer`5a5aa5a50f0ff0f0`及786,432B payload，再生成1/4/16/64KiB小TV，并重新核对长度、数量、trailer和完整前缀。XSim中实际reader的`$fread`总数分别为1,040/4,112/16,400/65,552B，都是payload+16B；每次实际1个事务、queue深度等于payload字节数、二维queue复制数等于该深度、最终文件位置为payload+16且EOF。F每次建立1页、`mem`和`IsWr`各声明depth、逐字节copy次数等于depth、offset文件实际绑定`fixture_r=0`；Q/M/F所有payload逐字节读回完全匹配。12/12显示独立`DIAG_PASS`。

## 测得的RSS

表中`基线→读回`是**实际XSim kernel进程**在阶段调用时的当前RSS（KiB）；`树峰`是外部守护0.1s采样的整任务树峰值，包含约650MiB的XSim父进程启动/运行开销。`queue复制增量`是紧邻`TV_Queue.push_back(TV)`前后的当前RSS；`mem`和`IsWr`是紧邻各动态分配前后的当前RSS，受页提交/舍入影响。DPI每次读取自身`/proc/self/status`的VmRSS/VmHWM，观测调用和日志会带来小的固定开销，未插入仿真暂停。

| 深度 | 模式 | 基线→完整读回 KiB | queue复制增量 KiB | `mem`分配增量 KiB | `IsWr`分配增量 KiB | 树峰 KiB |
| ---: | :---: | ---: | ---: | ---: | ---: | ---: |
| 1,024 | Q | 84,040→84,404 | 8 | — | — | 852,356 |
| 1,024 | M | 83,872→84,024 | — | 128 | 4 | 852,240 |
| 1,024 | F | 83,892→84,536 | 8 | 136 | 4 | 852,152 |
| 4,096 | Q | 84,012→84,452 | 32 | — | — | 852,488 |
| 4,096 | M | 83,888→84,096 | — | 140 | 4 | 852,512 |
| 4,096 | F | 83,928→84,680 | 32 | 148 | 4 | 852,304 |
| 16,384 | Q | 83,896→84,560 | 128 | — | — | 852,248 |
| 16,384 | M | 83,896→84,316 | — | 152 | 16 | 852,360 |
| 16,384 | F | 83,896→85,040 | 132 | 156 | 0 | 852,388 |
| 65,536 | Q | 83,892→85,356 | 512 | — | — | 852,320 |
| 65,536 | M | 83,860→85,148 | — | 260 | 56 | 852,348 |
| 65,536 | F | 83,908→86,312 | 512 | 268 | 52 | 852,532 |

Q/F中`TV_Queue.push_back(TV)`的观测RSS增量随深度分别为约8B/元素（16KiB F为132KiB，页/分配粒度使其略偏离）；在4→16→64KiB相邻深度，复制前queue当前RSS的基线归一增量为8.33和8.67B/输入字节。F中offset绑定前后各增68–76KiB；`pages`逐字节写入前后未观察到新的RSS页增长，因前面动态分配可能已经提交物理页，**这不能解释为写入零成本**。F的完整读回后基线增量依次为644/752/1,144/2,404KiB；相邻4→16和16→64KiB深度折算32.67和26.25B/新增输入字节。Q、M、F末端还包括各模式的读回和模拟器运行期开销，不能把这些斜率解释成单一SV数据结构的固定元素大小。

这些数字直接支持小规模queue复制和动态内存分配具有可测成本，也表明先前把16GiB v3树峰除以21,304,580B计划payload得到的806.6B/B**不是已测元素成本**。v3日志的`0/1 @117000`只是首个进度打印；实际autotb的`PROGRESS_TIMEOUT=10000000`和`wait_start`使随后是否继续推进、何时处于reader/初始化/DUT/AXI阶段不能由该末行判断，v3 RSS增长的具体活动阶段仍未知。本小诊断不把根因预设为reader。64KiB以内的单口前缀不能排除更大depth、多个端口共存、32位元素或XSim运行期非线性行为；不得据此宣称完整Attention的内存上界、允许扩大样本或重跑第四次完整RTL。FPGA资源/频率/性能和Attention数值RTL在本模块均未验证。历史终态见[v3审核](../../reviewer_d2_r_depth_v3_final_review.json)。
