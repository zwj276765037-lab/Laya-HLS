# E017/R001 — SFU最小测量交付

执行已结束；判断inconclusive。原整数helper测量与原F64mul finite域功能已验证，F64父资源及最终链接未完成。

| 原helper | 实际DSP/LUT/FF | setup WNS/hold WHS | DCP |
| --- | --- | --- | --- |
| 32×32→50 | 4/33/34 | +0.624/+0.386ns | AT004 work/helper.dcp |
| 32×32→64 | 4/47/34 | +0.624/+0.386ns | AT005 work/helper.dcp |

U55C/Vivado2025.2，完整IO synth+opt；实际周期3.333ns（请求3.333333），IO0.500ns/uncertainty0.100ns。零blackbox、12类check_timing全0、TNS/THS0；无HD.CLK_SRC父钟偏信息/P&R，不能签物理300MHz或联合fit。

AT003：17601连续独立整数输入，40340检查，18116接受/2054保持，reset+CE更新172/保持1030。raw reset忽略；ID/NUM_STAGE未引用；有效边沿捕获1/II1。

AT010：100400连续finite独立native-RNE binary64输入，总101424精确输出，16拍/II1，CE保持1034、reset+CE更新147/保持523。102490拍。原六文件来源SHA固定，不放宽FTZ/数值；raw无token接口，不代签服务reset隔离。

AT011120.223383s COST_STOP：child DCP导出完成，父stub停cross-boundary/area。A001准复用41s已完成导出后的AT012 parent-only120.264021s COST_STOP：到Start Technology Mapping，无DCP/EDIF；AT013未创建。当前无F64最终link/resources/timing，非方法FAIL，HLS16DSP不是新实测。无进一步EDA或预算。

AT007 prelaunch预算预留脚本错误保留，无工具启动；AT0080.117716s快速参考的RSS/策略样本未捕获，UNKNOWN。其余59真实策略样本一致、143SHA检查成立，两次timeout无残留非僵尸owned后代。

精确费用（reference/static/RTL/OOC，s）：0.33435211703181268/9.5405862600309774/14.7341321029816755/417.34211491607130，各帽120/600/600/900。所有失败/成本出口保留，未用额度不转。

结构化结果及所有SHA在[final_delivery.json](final_delivery.json)，原始AT/guard/driver.log与receipt.json保留；[budget_ledger.json](budget_ledger.json)、[final_evidence_audit.json](final_evidence_audit.json)。生产六份当前SHA与六文件原RTL均保持；无完整EXP/8lane/公共池/P&R/上板结论。
