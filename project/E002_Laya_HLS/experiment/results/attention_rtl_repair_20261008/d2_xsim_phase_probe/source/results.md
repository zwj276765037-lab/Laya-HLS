# Full generated XSim environment phase probe results

设计与来源见[design.md](design.md)和[合同§7.9](../../repair_contract.md)。最终静态绑定证据为[`binding_packet_v5.json`](binding_packet_v5.json)，SHA256 `2e20a3d2862fff936e7ad606863259250aa49888c6ac47e7ec9c2c07df9a9a08`；精确观测diff为[`instrumentation_v5.diff`](instrumentation_v5.diff)。原v3 Verilog侧278个复制文件中272个byte相同，差异仅为testbench、编译清单和四个只读观测位置；25个TV文件全部相同，所有原188直接编译源保留并仅增一个monitor源。完整树核查包含transitive include，见[`full_snapshot_validation_v5.json`](full_snapshot_validation_v5.json)。三份原生成C postcheck文件与v3逐byte相同。

只读DPI `phase_rss.so`已编译，导出`phase_probe_stage`与`phase_probe_file_bytes`；后者从拟运行工作目录读取七个实际offset文件均为85B。二进制TV独立解析核得七口共21,304,580B payload，observed为256个U32；offset为ASCII各一事务、一个元素。读事务ring的48B/口元数据和其他固定计数只是逻辑位数预算，不等于XSim宿主内存占用。

最终受控静态xelab在[`runs/static_xelab_v5`](../runs/static_xelab_v5)成功：exit 0、无guard触发、117.07s、峰值进程树RSS 6,519,036KiB、MemAvailable最低434,121,524KiB，已生成`attention_slice` snapshot。早期v1源顺序错误及v2–v4静态版本日志均保留；最终使用v5 snapshot。Astra xhigh在[`reviewer_d2_phase_probe_v5_runtime_gate.json`](../../reviewer_d2_phase_probe_v5_runtime_gate.json)放行了唯一8GiB/180s/复位后1,000,000周期窗口。

## 唯一XSim观测窗口

[`phase_window_once`](../runs/phase_window_once)保留完整[`driver.log`](../runs/phase_window_once/driver.log)、[`memory_timeline.csv`](../runs/phase_window_once/memory_timeline.csv)、[`guard_result.json`](../runs/phase_window_once/guard_result.json)、[`guard_trigger.json`](../runs/phase_window_once/guard_trigger.json)及机器可核查的[`phase_analysis.json`](../runs/phase_window_once/phase_analysis.json)。受控运行于2026-10-08按180s时间上限停止：实际180.36s，guard `trigger=timeout`，子进程退出码-9；进程树RSS峰值5,107,676KiB，最低MemAvailable 435,921,148KiB，均未触发内存限制。绑定的4核、nice 19、idle I/O检查通过。运行后复核冻结绑定包中56个唯一path/SHA256条目，均存在且哈希相符。无第二次运行或预算延长。

时间零点七口TV均完成装载，payload合计21,304,580B，每口一项binary事务、一项ASCII offset事务；`memory_ready`时XSim RSS为540,464KiB。复位在绝对clock 18释放（589,772KiB），真实kernel start在clock 64、TB辅助start在clock 65。运行继续到复位后220,000周期（绝对clock 220,018）；该点所有七口AXI计数已记录，XSim RSS为4,372,956KiB。原kernel done、TB done、`finish_cnt=1`均未出现；没有把受控停止当成原事务结束。

| 复位后周期 | XSim RSS KiB | fixture AR/RLAST | io AR/RLAST | aux AR/RLAST | qkv0 AW/B |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 10,000 | 758,688 | 0/0 | 439/439 | 66/66 | 0/0 |
| 100,000 | 2,270,600 | 60/60 | 439/439 | 117/117 | 3,612/3,612 |
| 220,000 | 4,372,956 | 144/144 | 439/439 | 117/117 | 8,974/8,973 |

最后一点qkv0仅有1笔AW尚未收到B；fixture读取144笔均收到RLAST。截至该点，qkv1与att_out尚无AXI握手，observed已有1笔写地址、4个W beat和1个B。35次完整七口队列采样截至绝对clock 210,018，所见所有per-ID长度不超过1；clock 220,018的队列报告在aux ID1后被timeout截断，因此最后一次队列采样是**不完整**的，不能补记缺失四口为零。全部七口AXI计数在该点完整。复位后100,000至220,000周期，XSim RSS增加2,102,356KiB，约17.52KiB/周期；它与周期及持续AXI活动相关，但现有观测不足以定位分配来源，也不能把短队列直接当成根因排除证明。

五个生成RTL输出TV均为0B。受控窗口在原事务完成前停止，原C postcheck的条件不满足，故未运行。**本窗口结论仅是诊断性timeout，完整top RTL数值结果仍未判定。**
