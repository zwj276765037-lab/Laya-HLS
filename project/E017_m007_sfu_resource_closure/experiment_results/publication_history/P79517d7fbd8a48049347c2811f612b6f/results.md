# E017资源测量阶段结果

execution_state: running
verdict: unassessed
applicability: 原生成EXP整数helper32×32配置；Vivado2025.2/U55C/300MHz完整IO；synth+opt，无P&R

| 测量 | DSP | LUT | FF | setup WNS ns | hold WHS ns | 费用s | 证据 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 32×32→50 | 4 | 33 | 34 | +0.624 | +0.386 | 87.964250 | R001/attempts/AT004_mul50_complete_io_ooc |
| 32×32→64 | 4 | 47 | 34 | +0.624 | +0.386 | 88.890460 | R001/attempts/AT005_mul64_complete_io_ooc |

两个DCP均零黑盒；check_timing全部12项0；TNS/THS0。XDC请求周期3.333333ns，Vivado实际按1ps粒度取3.333ns/300.030MHz；uncertainty0.100ns、全部数据输入及输出delay0.500ns。OOC未设HD.CLK_SRC，工具无法估计父布线钟偏；不签物理300MHz。

AT003整数独立RTL PASS：17601连续输入；总40340逐位检查、18116接受/2054CE保持/172 reset+CE更新/1030 reset+CE保持，20170拍；一有效边沿捕获/II1。reset在原raw helper未引用，不清payload。reference0.216636/static3.504946/RTL5.310044s。

原ID/NUM_STAGE均未被引用。F64实例NUM_STAGE2，而DCP/整数TB保留默认0；数据宽度真实32/32/50或64，未使用元参数差异不改变逻辑，后续链接显式记录。

原冻结AT005保留native-double参考生成代码，未保留binary64向量；后续按相同finite域、volatile binary64 RNE规则定向生成本helpergold并计reference。AT010原F64mul六文件RTL PASS：100400连续finite独立native-RNE向量，总101424精确输出/接受、1034CE保持、147 reset+CE更新/523 reset+CE保持，102490拍；延迟16/II1，raw reset未清payload。native参考0.117716s，短运行RSS/策略未捕获（UNKNOWN）。

AT011底向上首pilot COST_STOP120.223383s，两个child DCP成功导出EDIF，父stub综合cross-boundary area优化未完成，无parent DCP/最终资源；不能判F64资源FAIL。原导出27s+14s可复用，A001明确接纳分阶段重用：AT012仅父stub综合<=120s并立即保存DCP/EDIF；有真实parent产物后AT013另link/opt/report<=120s；不重开child、不原样延帽。AT012已真实启动。

AT007为工具启动前错误预留整120s造成的脚本断言，未启动重工具/无guard，prelaunch_failure.json保留；新AT008按实际余额119s上限完成，不增加reference120s总帽。资源不能直接外推为EXP8联合fit；生产文件未修改。
