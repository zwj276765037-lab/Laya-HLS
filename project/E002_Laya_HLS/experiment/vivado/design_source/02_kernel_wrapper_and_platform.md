# 02 HLS 工程、HBM 连接与 U55C 上板流程

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

本文回答：模块写好以后，怎样变成 CPU 能调用的 U55C 推理程序。参考 [Tiny 构建脚本](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/hardware_implement.sh) 和 [7B 构建脚本](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/llama2-7b-baseline/hardware_implement.sh)。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 目标板卡与交付 | U55C完整模型推理；xclbin、Host、模型包、测试记录 | 当前只有设计文档 | 明确要求 | U2；S6 |
| 参考构建路线 | HLS→Vitis链接/Vivado实现→XRT | 两个Llama仓库均有对应源码/脚本 | 工程事实 | S4；16 |
| 顶层/访存方案 | 一个forward核，13个候选512bit m_axi及HLS控制接口 | 尚未生成接口RTL和连接元数据 | 推断 | S3；本文§2、§3 |
| 实际器件与环境 | part/package/speed grade、platform、shell、XRT/IP及工具版本 | 参考组合为2023.2/U55C XDMA平台；目标服务器未冻结 | 待确认 | G1；本文§5、§8 |
| 时钟复位 | 单用户计算域；分析请求150MHz | 复位极性、同步方式、CDC边界和实时时钟未知 | 推断 | S3；G1；本文§8 |

## 1. 首版采用什么工具路线

与两个 baseline 一样，首版用 Vitis HLS 编译 C++ 硬件代码，再用 Vitis 链接 U55C 平台。链接过程调用 Vivado 完成实现。最终交付物是 **xclbin + Host 程序 + 模型包 + 配置/验证记录**。

单独生成 Vivado bitstream，或单独通过 HLS C 仿真，都不能算已完成 XRT 上板部署。

```text
共享配置与数值参考
  ├─ HLS C++ / C testbench → C 仿真、综合 → laya_forward.xo
  ├─ U55C 连接配置 + platform + xo → 实现 → laya_forward.xclbin
  └─ C++ Host + XRT → laya_host

laya_host + 模型包 + 请求文件 + xclbin → U55C 推理 → logits / 比较 / 耗时
```

## 2. 对 CPU 暴露一个完整前向核

核名计划为 `laya_typed_q8_forward`，一次调用处理一个 B<=2 的完整请求。外部控制采用 HLS 生成的 `s_axilite`/`ap_ctrl_hs`，数据采用 `m_axi`。首版不启用自动重启；上一个请求结束并读回后再提交下一个。

**C++ 顶层参数顺序、HLS bundle 名称、连接配置和 Host 的参数编号必须来自同一份接口定义。** 不再手写 0x20、0x100 等 AXI-Lite offset 作为首版要求；实际 offset 从生成的控制头文件与 xclbin 元数据核查。

B/S、request_id、model_tag 和张量位置放在01定义的请求头中。模型维度上限和工作区容量来自共享配置。HLS 顶层接收下表的 13 个 BO 指针，参数编号按表顺序规划，实施时与生成产物核对。

## 3. 13 个访存端口是候选配置

| 参数编号 / 名称 | 用途 | 候选 HBM bank |
| --- | --- | --- |
| 0 `embedding` | token/type Q8 embedding | 0 |
| 1 `io` | 请求、logits、状态和计数 | 1 |
| 2 / 3 `w_q0` / `w_q1` | Linear 权重 q 的两个分片 | 4 / 5 |
| 4 `w_scale` | FP16 scales | 6 |
| 5 `aux` | bias、RoPE、浮点尾层和模型头 | 7 |
| 6 / 7 `state0` / `state1` | hidden、norm、residual 等工作区 | 12 / 13 |
| 8 / 9 `qkv0` / `qkv1` | 按 head 奇偶分片的 Q/K/V | 14 / 15 |
| 10 / 11 `ff0` / `ff1` | Wi 与 gate / Decision FF 临时区 | 16 / 17 |
| 12 `att_out` | attention 结果 | 18 |

要获得独立 master，HLS 顶层必须为相应参数指定不同 `bundle`。只在连接文件写多个 bank 不够。计划的数据宽度为 512 bit，实际是否生成该宽度、是否有效 burst，都看 HLS/link 报告。

每个 BO 用 `kernel.group_id(arg_index)` 分配。连接文件计划采用下面的形式（示意片段，当前尚无可构建工程）：

```ini
[connectivity]
nk=laya_typed_q8_forward:1:laya_forward_1
sp=laya_forward_1.embedding:HBM[0]
sp=laya_forward_1.io:HBM[1]
sp=laya_forward_1.w_q0:HBM[4]
sp=laya_forward_1.w_q1:HBM[5]
```

其余端口按表补齐。首版由工具放置，不照抄 Llama 三核的 SLR0/SLR1 约束；拿到拥塞和时序报告后再做有依据的调整。13 个 master 的互连面积和时序也属于待验证项，不能先假定全部可满速。

## 4. 工程准备怎样落到文件

下面是后续实施交付清单，**这些是计划文件，不表示现在已经存在**。在项目目录内保持与 baseline 相近的职责划分，避免在 CPU 与 FPGA 两边复制维护不同配置。

| 计划文件/目录 | 作用 |
| --- | --- |
| `include/laya_config.h`、`laya_io.h` | CPU/HLS 共用尺寸、输入输出结构和版本 |
| `tools/export_gguf.py` | 导出 q/scale/浮点数据及各矩阵 offset，生成 manifest 和模型布局头文件 |
| `reference/` | 可执行的软件黄金参考及中间结果 |
| `host/laya_host.cpp` | XRT 常驻会话、模型装载、运行、回读和计时 |
| `hls/laya_forward.cpp` | 一个外部 kernel 和内部层循环 |
| `hls/operators/` | 本目录06–13对应的计算模块 |
| `tests/` | 算子、联合链路、全图及 Host 回放测试 |
| `config/hls.cfg`、`u55c_link.cfg` | 时钟、综合源文件、HBM 连接和平台参数 |
| `scripts/`、`build/`、`results/` | 可复现构建脚本、生成产物和测试记录 |

当前按用户指定路径维护[15个模块工作区](../module_design/README.md)，每模块分source/、rtl/、tb/。source只保留详细design.md和平台/资源/性能results.md，原规格路径和对应章节在design.md中引用；rtl用于后续自定义/封装RTL，tb用于模块与关联链路验证。上表中的Host、HLS、共享头文件及硬件构建代码仍待实现；reference已有真实原生CPU采集和ABI离线回放，见14§10.3。HLS自动生成RTL仍保留在构建目录。

内部模块采用函数和缓存/流接口连接，由 HLS 产生控制电路。共享矩阵引擎要通过函数实例控制和综合层级报告确认，不能因为 C++ 中写了同名函数，就认定 HLS 没有复制硬件。

## 5. 工具和平台先核对什么

baseline 使用 `xilinx_u55c_gen3x16_xdma_3_202210_1`，环境脚本指向 Vitis/Vivado 2023.2。这是参考组合，实际板卡必须核对已安装 platform、shell、XRT、工具版本和器件信息。首版申请150 MHz，最终性能计算用实现后的时钟。

在实际 U55C 主机上先保存设备发现、平台版本、内存拓扑和健康状态，再检查 xclbin 的 kernel 名、参数、bank 连接和时钟。`xbutil examine`/`xbmgmt examine`/`xclbinutil --info` 等命令按安装版本使用；当前文档没有在本机执行板卡探测或编译。

## 6. 编译和验证怎样逐步推进

沿用 baseline 的阶段，但每一步保存本项目自己的输出：

1. **C 仿真**：直接调用 HLS 函数，与相同输入的 CPU 参考比较；先测一个链路，再测完整网络。
2. **HLS 综合**：产生 xo，检查接口宽度、II、资源、片上数组位置及函数复制；不能把整个模型意外变成片上数组。
3. **软件仿真**：Host 通过 XRT 调用软件仿真 xclbin，检查模型包、参数、数据布局和回读。
4. **关键硬件仿真**：选 LN→量化→Linear 和 QKV→attention 等短用例验证流、反压与完成；不用仿真速度判断真实吞吐。
5. **硬件链接/实现**：将 xo 与实际 U55C platform 链接为硬件 xclbin，检查资源、时序和 HBM 连接。
6. **板上运行**：清除仿真模式，用硬件 xclbin 和同一请求数据回读 logits，先验正确性再测性能。

构建命令由所选工具版本生成脚本。baseline 中 `v++ -c --mode hls ...` 和 `v++ -l -t hw ...` 是可参照的流程；原脚本的绝对路径、并行任务数和 hw_emu 拼写错误不应复制。

## 7. 第一次上板如何缩小问题范围

| 板上步骤 | 测什么 | 进入下一步的条件 |
| --- | --- | --- |
| HBM 回环/校验核 | 13 个候选端口、BO 分组、地址、实际读写速率 | 所有分配区域往返一致，无越界和超时 |
| Q8 Linear 测试核 | 实际 GGUF 一张矩阵、量化/恢复和输出 | 与软件参考对账，周期与流量可解释 |
| 单个完整 Encoder 层 | QKV/RoPE/attention/FFN/residual | 中间检查点全部满足误差要求 |
| 完整 Laya forward | 28+2层、scorer/act及业务输出 | 真实两题和质量集通过 |
| 连续请求及 GPU 对照 | 常驻运行、P50/P95、长短S、两题及多批 | 稳定、口径一致且记录可复查 |

前面的测试核是开发阶段验证工具，不是最终“只把一部分模型放到 FPGA”。最终部署仍要求整个神经网络前向在 U55C 中执行。错误恢复、质量与性能指标见 [14](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md)。


## 8. 时钟、复位与平台边界

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 用户计算时钟 | 首版候选一个计算域，分析请求150MHz | 尚无生成kernel时钟约束；实际Fmax未知 | 推断 | S3；15 |
| 平台AXI/HBM时钟 | 服从选定platform；域间通过平台/HLS适配 | 频率、比例与转换位置未指定 | 待确认 | G1 |
| 时钟端口/CDC | 从生成RTL及platform连接核查具体端口和CDC实例 | 不臆造端口名、相位关系或CDC已经存在 | 待确认 | G1/G2 |
| 复位极性与同步 | 由生成IP/平台确定极性、同步或异步、释放顺序 | 目前未指定；不能照默认值手填 | 待确认 | G1 |
| 恢复后的逻辑状态 | 不发布上次结果；清空控制/FIFO有效状态和缓存所有权，重新校验模型上下文 | 是拟采用行为；不要求清零全部HBM | 推断 | 03、14、15 |
| 运行中异常 | 先停止新提交，确认设备静止/完成恢复，再复用BO和新generation | timeout本身不证明停止，恢复API未冻结 | 推断 | 01、14；G5 |

复位可能使缓存有效位失效；是否需要重装模型取决于实际平台恢复是否保留HBM和xclbin状态，当前不假定保留。后续记录复位前/期间/后的在途事务处理，确认不会让旧写响应污染新请求。

综合/实现时还需交付：生成时钟清单、reset连接、CDC报告、实际用户区资源、工具/IP版本与许可检查。功能C仿真阶段可先推进，不必为了该阶段虚构part或speed grade。

## 9. 本次逻辑接口与实际生成接口的边界

01§6的请求字节、14§9结果/错误码、04§7工作区和15§10–§14的分类型任务/数据协议为下一步实现输入；02§3的13 BO参数顺序保持不变。C++顶层可使用与所选工具兼容的指针类型／宽口打包形式，但每参数arg_index、bundle、读写权限与BO字节布局必须一致，由HLS接口报告和xclbin metadata回查。此处不将文档Task/BufferRef变成新的外部kernel参数。

目前已有1856B真实输入的离线ABI fixture，三个硬件身份tag仍为零占位、production-ineligible；它验证打包／解包，尚未在XRT/软件仿真/硬件仿真中提交。真实复位、AXI完成保证、实际master宽度／outstanding／时钟与IP latency依旧待平台和生成报告确认。
