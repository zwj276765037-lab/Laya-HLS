# 当前共享QUANT GATE split回归里程碑

消息ID：`gate-split-current-milestone-20261012`

按R-SM003-GATE-ORDINARY-PORTAL-20261012要求，已对共享普通/GATE唯一quant实例后的当前RTL重跑原四窗口split入口。

`gate_split_06` static/pilot/full全部PASS：50.023254/31.830809/1038.453534s；峰值2103036/1314936/1332376KiB，均在原帽内，无停滞/资源触发。pilot 11769cycles，一行G的WI/G words=5248/2624、AW/B=164/164。full 758736cycles；四个rows16 G命令共64行且共用同一GATE epoch，WI/G words=335872/167936，AW/B各10496；全部G完成后才发独立Q，window0的AR/R=56/2624、quant rows/halves=16/2624、fullA检查1312 words，GATE window release与tensor cancel cleanup通过。manifest `6f129b48ac1b197dde0f0c9cfea11a65b893ae9d84be81f3b686d3c6f9f27aba`，receipt `7e8810b7b8a257e18a117964bb7aaea62e9de850c3b11986512fc4679c3ae1fb`。

full启动依据保持原冻结工作量：当前pilot 11769cycles/31.830809s；历史四行94.854549s×16×1.5得到2277s，低于3600s，实际full 1038.453534s。没有用较快G门户小入口重估组合G/Q→matrix，后者5172s `NOT_RUN_COST`不变。

`gate_split_05`保留static FAIL：新增DUT output `g_cfg_admitted`后旧TB以`.*`实例化但未声明同名信号，elaboration报错；receipt `0f4ac4ed96910317ba489188f896e446581aab0a83529d605ad39cd55fcf6ebc`。`_06`仅增加TB signal声明，DUT/fixture/gold/full工作量未改。

限定：该PASS重新签当前RTL的canonical GEGLU多窗口同epoch→独立GATE Q window0→fullA；仍不含普通↔GATE无复位切换、普通其它K/row-space、跨batch source路由、真实source lease/hub、LOAD/fullW/matrix、完整请求或性能/资源结论。

工程已开始D-M003-GENERATED-PROVENANCE-CHANNEL-01：新增LPV1/LPA1协议类型/codec/client/HLS adapter严格语法通过，并把`provenance_cmd/rsp`两条512bit depth2 ap_fifo追加到实际controller top源码签名/pragmas；实际任务BEGIN/END、CLAIM/PUBLISH、posted-store计量/fence、生成12信号和hub接收器仍待验证，暂不称实现PASS。

E003三摘要已同步。L0/L1 PARTIAL、L2–L5 NOT_RUN，C010继续待生产集成，M003/M004未完成；无OOC/P&R/上板，G余额不变。
