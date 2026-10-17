# E005当前结果

本轮AT001 KB0、AT002 KB1实际full PASS：四distinct K2624/N1024预量化A/bias0/冷reset，全部335872 PS lane-group及4096F32原独立gold，末B/局部publication/一次consume保持。512TN8 packet不变，实际AW/W/B512→256；有效字节16384不变、物理字节32768→16384。

cfg→first done21100→16183（减少23.3033%），cfg→实际consume21107→16190（23.2956%），全冷TB48864→43947（10.0626%）。A/W加载666/27064不变、原7cycle反压保持。互斥state只和为各自命令区间，接口stall重叠单列；同beat响应策略，减少事务自然减少按事务B等待，仅适用于本profile。

26源仅writer改变，12fixture/3native IP/TB/runner/guard一致。KB1额外1923bits字段，物理资源/时序UNKNOWN；两个继承错误窗口未测，不签恢复或生产请求。保留KB1候选。冷W加载27064cycles占KB1全冷61.58%，但同TB供数profile下q0/q1各20992拍至少需26239cycles，单改读取器调度的乐观余量最多约825cycles（全冷1.88%）；这不是可实现收益承诺。KB2两个64tile块候选已按本轮成本/进展规则退出，不能据其有限pilot判数值或收益。

输出写回同profile下界：16384B恰占满256个512-bit拍，TB逐笔待B；首AW→末B4927cycles内固定B延迟decrement为4608次。首AW不变时只压其他输出间隙的理想余量最多319cycles，PS/writer stall互相重叠不能直接当整命令收益。

P3有界设计排序之后，CT0选定原32项FullOwnerRecord表的REQUIRE/ACQUIRE/RELEASE_READ有限路径；实际生成与有限RTL已取得限定结果。

## AT003 KB2终态与CT0边界

AT003：measurement_01静态接口漂移失败；measurement_02/03 static与pilot有限PASS，full均COST_STOP；delta_01同snapshot有限诊断COST_STOP。三个停止的末条真实marker同为`cycle=33397 stripes=5151 ps0=5120 outputs=0`，33397仅是末次观测周期，5120仅直接表示ps0。没有完整数值、末B、done消费或性能结果，根因UNKNOWN。KB1保持已核范围。详见KB2原报告与主控停止审核。

CT0 AT006薄HLS生成PASS：真实32×5009bit索引RAM及两根512bit FIFO；HLS估计BRAM18 8、DSP1、FF49533、LUT39937、URAM0，不是物理或联合资源。AT012 generated RTL PASS：normal 131笔、1572入拍/1441出拍全字比较，73429诊断cycles、617拍实际待发响应受阻；独立request-off/model-off各9笔与原FullRuntime helper一致，旧READ租约在两种无效上下文与错live identity下仍各释放一次。实际原始收据、冻结身份与静态复核见CT0报告。CT0不接生产owner/CLAIM/发布/退休，不代签完整请求或恢复。


## LQ0有限算术基线（AT014）

原`layernorm_quant_source_03`冻结153文件仅观察TB变化；16384 LN F32、16384 Q INT8、512 FP16 scale与独立gold，真实LN store 65536B、Q重读及fullA/末B/END/lease/零债务均PASS。全TB659334cycles与原冻结样本相同。互斥TB阶段25+54+72+655290+3838+55=659334；生成run子图4441→653821含读算写，Q命令655498→实际响应消费658765。static/pilot/full均child0无触发，full735.843213s、peak863076KiB。详见LQ0报告和AT014收据。LQ1最终归一化循环II1候选AT015生成PASS、AT016有限16行RTL PASS；完整结果如下。

## LQ1同边界16行结果（AT015/AT016）

真实LN 16384 F32、Q 16384 INT8、512 FP16 scale及store→重读、末B、END/发布、lease、fullA和最终零债务均保持原gold通过。全TB659334→528307cycles，减少131027（19.8726%）；LN run含读算写649380→518354，减少131026（20.1771%）；Q接受→响应消费3267→3266。互斥TB阶段25/54/72/655290/3838/55→25/54/72/524264/3837/55，分别和为全TB。196608B三向传输及事务数不变。

AT015目标II1实际II2；HLS循环估计10249→2049cycles，单top BRAM18 29→29、DSP13→18、FF19765→19804、LUT47775→48104；估计slack0.00→−48.76ns。调度路径F32减30.745ns接F32乘20.420ns，未经物理时序验证。该候选只保留为同profile局部周期结果，不能声称150MHz实现收益。详见R001 LQ1报告、AT015/AT016原收据与日志。

## LQ1R有界时序修复停止（AT017/AT018）

两版g++/HLS类型模型原16行对照及单LN HLS生成PASS。AT017实际注册减/乘wrapper5/4级、native core latency3/2，II9/循环估计9224cycles，fsub末级→fmul首级路径5.298ns、top slack−0.43ns。AT018只加减法约束一级，实际wrapper6/4级、core latency4/2，II10/估计10249cycles，同点路径5.277ns、top slack−0.41ns。有效预算4.867ns，两版均未过本阶段RTL准入；static/pilot/full和F9 case5/6均NOT_RUN，没有LQ1R动态周期。单top估计BRAM18 29/29、DSP18/18、FF20136/20111、LUT48112/48107；非物理资源。按两版上界停止，LQ0/LQ1原限定结果保留；详见R001 LQ1R停止报告与原收据。

## Attention ATN0有限完整head计量（AT019/AT020）

AT019观察断言FAIL，原数值tile marker不追认为终态PASS。AT020 static/pilot/full均PASS：enc0/head0 B1/S128全部128query，原独立中间与最终逐位gold、M/A/D 2129920/2146176/16384、EXP16384及accepted=retired191088。全TB1608896cycles；正常QK250888、SM287173、AV66256与原v10相同，实际消费各比首次done累计多24cycles。SM互斥MAX2176/EXP270525/TREE8576/DIV5888/launch-report8合计287173。四worker实际core-busy898680 slot-edges，条件四worker服务下界224670enabled；与当前EXP阶段相差45855，仅为乐观可压缩空隙上界。ASUB输入待算147456 slot-edges、A credit阻塞0。full guard499.307597s/peak1109036KiB，物理资源与全请求UNKNOWN。详见R001 ATN0报告及AT020 full原始计量。

## Attention ATN1同资源调度限定结果（AT021/AT022）

AT021 static/pilot/full 全部 child0、无保护触发；128行正常完整head的原中间/最终逐位gold、M/A/D/EXP工作量及191088受理/退休配平通过。ATN0→ATN1：SM首次done287173→265084（减22089，7.6919%），实际consume287197→265108；QK250888、AV66256不变；三段首次done和604317→582228（减3.6552%），全TB1608896→1586807（减1.3729%）。SM净差只在EXP互斥区间270525→248436；四worker总core-busy仍898680 slot-edges，ASUB物理请求16000→4096而lane16384不变。新增179bit逻辑暂存含数据寄存器，物理资源/时序UNKNOWN。

AT022 同DUT协议16行 static/RTL均child0；两种新暂存状态实际命中并通过8拍CE保持和reset清理，原四类活动管线、六首错、合法重载/chain/ledger及末尾正常16行gold通过。accepted210966=retired210960+cancelled6。AT022全TB含协议额外工作，不与正常128行周期比较。行完成债务依据源码一批接受→真实A返回→按完整key分发→唯一EXP提交的守恒关系和原gold动态佐证；无内部所有槽位逐边沿形式证明。AT021正常full guard482.110123s/peak1108904KiB，AT022协议guard226.536195s/peak955724KiB。候选只在有限模块仿真范围保留；生产、物理和完整请求未验。详见 R001 ATN1对照报告及两份attempt收据。



---
Published: 2026-10-13T11:03:27.827852+00:00
Publication: P31e8ec7956f4460e94c2b7a7dddcbad3
