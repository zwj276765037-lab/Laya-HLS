# 完整 top 扩大内存综合：单次运行结果

**结论：本次完整 top C-Synthesis 未完成。** 2026-10-07 15:21:47–15:32:23（Asia/Shanghai；原始日志为 UTC）的运行在服务器 `MemAvailable` 达到保护阈值后由独立监控器停止。未生成完整 top 的资源、时延、物理接口报告或 RTL，因此没有 FPGA 资源适配、时序或上板结论。原 CPU 完整图门禁与真实 13 参数顶层 HLS CSim PASS 仍是各自独立的功能证据。

## 身份和执行范围

- 冻结 build tag：`4f12ecfe940ecf2a8998a8626fc1ed1c`；模型 manifest SHA-256：`0d3ef9fbcc0de7ddf49c26921b523f4ca22a16d856c58e1c523b52b61e7dbec3`。本次 [63 项输入检查](baseline_hash_check.log) 全部 `OK`；与前次清单比较，62 条非配置记录的 hash 全相同（其中同一 header 重复登记一次，共 61 个不同路径）。[生成的 full_top.cfg](../../../build/full-hls-csynth-expanded-memory-20261007T072000Z/full_top.cfg) 与前次逐字节相同，SHA-256 均为 `375f990e2dfc3eaad5ac848deac43f0892df465a937be639145c03515dfe0730`。生产 runner SHA-256 仍为 `fca0fcc0bab379e9d5a2ba0ff538ccdee7d2763fefb65ed185257f9b7ccc3e4e`。
- 命令和环境见 [wrapper_plan.json](wrapper_plan.json) 与 [csynth.command](csynth.command)：Vitis 2025.2、实验 part `xcu55c-fsvh2892-2L-e`、150 MHz 请求、Vivado flow，配置保留关闭自动 pipeline 和自动 array partition。本次仅新建独立结果及构建目录；生产 HLS 源、模型包、构建 tag 和配置选项未改。
- [启动前策略](preexec_policy.json) 为 PASS：受控 session/group leader PID `2098008`，`nice=19`、CPU `[0,1,2,3]`、I/O idle；运行期 [11 份优先级样本](policy_samples.jsonl) 共观察 59 个匹配进程记录，均满足同一策略。这是抽样证据，不代表每个子进程在每一瞬间都被观察。

## 内存保护和退出

| 项目 | 实测或配置 |
| --- | --- |
| 守护阈值 | `MemAvailable <= 67,108,864 KiB`（64 GiB）或受控进程树 RSS `>= 398,458,880 KiB`（380 GiB），先到者生效；约 2 秒采样 |
| 实际触发 | 15:32:22（Asia/Shanghai），`MemAvailable=65,439,676 KiB`（62.408 GiB），原因为 `mem_available_at_or_below_64_GiB` |
| 最后已记录的树 RSS／最大单进程 RSS | `379,135,724 KiB`（361.572 GiB）／`378,146,812 KiB`（360.629 GiB）；均为离散采样的**已记录峰值**，不是进程生命周期绝对峰值 |
| 退出 | wrapper 退出码 `1`，其受控 leader 被 SIGKILL 后退出码 `-9`；`csynth.exit` 未写出，不能据此虚构工具自身正常退出码 |

[memory_timeline.csv](memory_timeline.csv) 保存 303 次约两秒采样；最后一行在 15:32:20（Asia/Shanghai）记录 `MemAvailable=67,731,080 KiB`（64.593 GiB），下一次阈值检查读到 62.408 GiB。用户态周期监测存在约 1.6 GiB 越阈和瞬时分配盲区，不能声称绝对零影响。[guard_trigger.json](guard_trigger.json) 保存触发值、受控组身份、停止时快照和工具尾日志；[wrapper_result.json](wrapper_result.json) 保存监控器结果。

终止后按已登记 PID 启动时间与独立 session/group 清理。一次事后核查未见任何相同启动时间的已登记任务进程或该 session/group 成员，`MemAvailable` 回升至 `448,692,448 KiB`（427.906 GiB）；五个预先识别的其他 Vivado PID 在后续抽查仍运行。监控器只对本次归属进程发信号，并限制本任务优先级/CPU；这些观察不证明服务器其他工作绝对未受影响，也没有前后 OOM 计数可作此结论。细节见 [postrun_verification.json](postrun_verification.json)。

## 综合阶段与报告边界

[Design Size Report](../../../build/full-hls-csynth-expanded-memory-20261007T072000Z/csynth/hls/syn/report/csynth_design_size.rpt) 明示 `C-Synthesis has not completed`。最后**已完成统计**是 Performance 第 4 步的 `1,078,825` 条内部指令；下一栏 HW Transforms 仍为 `pending`。[阶段报告头部](design_size_head.txt) 和 [clang reflow 尾部](clang_reflow_tail.txt) 单独保存。尾部出现模型元数据字段的 complete-partition remark，但仅凭该尾部不能确定内存增长的根因或指向硬件资源超限。

本次只有不完整的 design-size `.rpt/.xml`；未找到完整 `csynth.rpt`、完整资源/时延/接口报告或生成的 Verilog/SystemVerilog/VHDL。既有 [180 GiB 门槛运行](../csynth_array_f0_final_20261007/csynth.log) 与 [启动前 ps 字段解析失败记录](../csynth_expanded_memory_20261007T071141Z/guard_trigger.json) 均保留；旧综合日志 SHA-256 仍为 `710121ef53c819bc576bf552e3a0cf17878227585e635c1bf027606f89688174`。当前 CPU 门禁、CSim、旧综合日志和模型 manifest 的文件修改时间均早于本次启动；身份核查与产物清单见 [postrun_verification.json](postrun_verification.json)。

后续若要取得完整 top RTL/资源报告，需要在单独审核资源预算与综合路径后另行处理；本次没有再启动其他综合，也未修改算术、模型、接口或验收判据。
