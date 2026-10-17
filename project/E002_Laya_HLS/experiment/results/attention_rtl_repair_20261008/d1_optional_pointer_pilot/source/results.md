# D1 nullable metadata pointer最小对照：结果

## 当前结果：D1局部控制语义修复通过

[独立审核](../../reviewer_d1_review.json)已接受原错误复现与显式presence修复，并放行P1/P2/P3迁入唯一生产controller；完整数值RTL与完整top HLS仍未放行。A/B采用同一源码与独立期望TB，仅`EXPLICIT_PRESENCE=1`配置不同。

| 阶段 | 实际结果 | 范围 |
| --- | --- | --- |
| A原nullable CPU/CSim | 120 assertions通过 | C++控制语义期望正确 |
| A原nullable Verilog/XSim | exit1；独立解码15条AXI输出，6条不符 | 3个合法QKV错误E_INTERNAL/0x07000004；3个binary vector丢失第二来源；其余9条逐字匹配 |
| B显式presence CPU/CSim与Verilog/XSim | 120 assertions通过，cosim exit0 | 15×36个输出字与A/B的C期望及帧格式逐byte一致，SHA `605f9caa0f3d47e1a87ec9b7251e806f89a5755bf196dfbe566f1c77f3e79c95` |
| 合法/非法覆盖 | QKV stage2/4、epoch/双bank、缺pair、load失败优先；Residual/Type第二来源id/bank/epoch/region、unary/absence；attention选路与norm失败 | P3在A/B都通过，是独立等价简化，非已复现根因 |
| HLS原型估算 | A：1,973 LUT/1,089 FF；B：6,701 LUT/1,813 FF；均0 DSP/BRAM/URAM，时钟估算4.867ns | 仅控制probe，含公开stub，不是数值算子或整网映射结果 |
| 守护 | 六个工具阶段无资源触发；A/B cosim约60.84/62.21s | 四CPU/nice/IO记录与策略匹配 |

B通过只证明本小top的控制表示，尚不包含生产QKV算术/owner/RoPE/Attention联合链。特别是ADD_TYPE在probe中为模拟stage，真实stage3/layer255及实际owner需D2验证。原/改日志及manifest留在[runs](../runs/)与[AXI比较](../axi_tv_comparison.json)，不改原A失败或将其记作通过。

2026-10-08：隔离A/B诊断已完成。设计与边界见[design.md](design.md)及[修复合同](../../repair_contract.md)。同一份probe源通过`EXPLICIT_PRESENCE`宏切换：A保留nullable metadata pointer，B采用显式presence和reference。完整输入与原始证据SHA分别在[`input_hashes.sha256`](../input_hashes.sha256)和[`evidence_hashes.sha256`](../evidence_hashes.sha256)；两清单已逐条校验。Vitis/Vivado为2025.2 build 6295257；CPU编译器为GCC 13.3.0。目标U55C xcu55c-fsvh2892-2L-e、150MHz，关闭自动loop pipeline及size/throughput驱动的自动array partition。

| 阶段 | 当前状态 | 验收范围 |
| --- | --- | --- |
| 原/改A/B小top | 已实现 | 同源C++，仅配置宏区别；真实FullOwnerSpec/BufferRef/VectorTask结构，load/bind/issue为明确标记的probe stub |
| CPU、Vitis CSim | A/B通过 | 每版15笔输入、120条独立断言；包含stage2/4 QKV、ADD_RESIDUAL/ADD_TYPE、动态id/bank/epoch/region、非法absence、load/norm失败顺序 |
| 局部csynth | A/B完成 | 各生成独立Verilog；A/B guard exit 0 |
| Verilog/XSim cosim | A复现失败，B通过 | A的3笔合法QKV均返回E_INTERNAL/0x07000004且pair全零；3笔binary vector均返回E_SHAPE/0x07030001且第二来源与bind全零。其他9笔逐word等于C。B的15笔×36个AXI输出word与C字节一致，cosim PASS且C后检查120条通过。 |
| 资源/时序/性能 | 只测守护资源 | A/B csynth任务树峰值RSS分别2.28/2.31GiB；cosim分别3.03/3.12GiB，均低于所用8GiB严格限；MemAvailable最低仍高于424GiB。诊断top资源与延迟不外推整网或50ms。 |

原始守护位于`runs/vitis_{a,b}_{csim,csynth,cosim}_guard/`，工作目录位于相应`runs/vitis_{a,b}_{csim,csynth}_work/`。A/B CPU和CSim均通过；A XSim实际运行了全部15笔、然后在首个输出的C后检查失败，guard child exit 1且无超限触发。B XSim实际运行全部15笔并通过，guard child exit 0。两版C期望TV SHA均为`605f9caa0f3d47e1a87ec9b7251e806f89a5755bf196dfbe566f1c77f3e79c95`；B RTL TV SHA与之相同，A RTL TV SHA为`13ad993c17719fa917af8798a0dd5476127014243d06acf765ec55062138518d`。D1是metadata控制语义的复现和等价修复验证；生产真实owner/数值联合链和整网回归仍待D2/D3。
