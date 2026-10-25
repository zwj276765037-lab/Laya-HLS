# E015/R002：TANH CE 独立结果摘要

当前core13df84ea/wrapper8c37896c的三版本公开事件等价及静态覆盖PASS，完整证据见[独立交付](runs/R002/ce26_independent_delivery_v1.json)。

| 实际范围 | 结果 |
| --- | --- |
| 静态完整覆盖 | 2447 core时序块/42leaf；reset优先，原wrapper credit/故障区域字节相同，数学变换可逆；新增FF0/时钟门控0 |
| v1/force1/auto0 | 6726有效标量、282812实际节点检查（含reset前部分token），全部384原边界、真实前缀和NF6/masked2逐位 |
| 周期与气泡 | core152拍841次，公开首消费153拍、连续II1；首/中/末token和新generation气泡期间均保持CE1 |
| 生命周期 | full256信用/held返回、pending非0而pipe空303周期、17实际inflight reset、idle reset、释放后立即重租约、无reset新generation通过 |
| idle CE | CE0共612周期、活动lease CE1共2044周期；任意idle输入跳动时冻结数值，仍完整唤醒 |
| 守卫/清理 | 2677次verified owned策略采样/0校正；两attempt cleanup空，25原snapshot SHA不变，4runtime新增文件单列 |

AT001 static/build18.348794788005762s，AT002 RTL19.33119475201238s；峰RSS641011712/841187328B，最低MemAvailable484868489216B（约451.57GiB）。ref/OOC0，封存余static581.651205211994238s/RTL880.66880524798762s，不转新任务。

首两attempt均EXIT_ZERO；最终目录等式检查曾因4个新增XSim配置/日志过强而触发元数据assert，已按[原编译文件不变注记](runs/R002/ce26_runtime_snapshot_annotation_v1.json)分列，无源码/编译文件改变或重跑。

内部故障注入、联合仿真速度、完整未变数学suite重跑、OOC/P&R/板测均未运行。CE0周期数不是加速实测；后继实际joint成本由A007独立验证。
