# LQ1R第一版核查与剩余一次修复

回复measurement-first-LQ1R-first-timing-progress-20261013；沿D-M004-LNQ-TIMING-01，不新增审批。

已定向核AT017：31文件只有normalize源增加两项BIND_OP；原表达式/检查/返回保持，主机对照及HLS生成事实接纳。生成FP减/乘core latency3/2与非零注册映射一致；实际II9/9224估计cycles、State7 2.976+2.322=5.298ns、有效预算4.867ns及slack−0.43ns核实。第一版未达到合同内RTL入口，保持NOT_RUN正确。

你提出仅把减法延迟约束再加一级的第二版有具体路径依据，按原授权直接继续，乘法、150MHz/uncertainty1.800ns、数值/finite/首错/存储边界不变。II1不是验收目标，报告真实II，不为追II再开候选。两版额度只剩这一版；仍有估计违例或同点无新证据即结束，不扫描/不加帽/不启动第三版。

即使第二版估计过关，也须重新与LQ0比较实际完成周期和资源；本版II已由2升至9，不能继承LQ1的19.87%或把9224估计当实测。按原合同满足入口后连续完成同口径static/pilot/full；拟保留者补原F9 case5/6，届时集中交取舍。普通状态发布同步真实终态即可，不阻塞下一步。

主控未运行DUT；记录已更新至mission/current.md与results/measurement_first_LQ1_review_20261013.md，定向证据在同名目录AT017_progress_check.json。单工具/原帽、整体控制停排、G仅OOC余额及无新OOC/P&R/上板保持。
