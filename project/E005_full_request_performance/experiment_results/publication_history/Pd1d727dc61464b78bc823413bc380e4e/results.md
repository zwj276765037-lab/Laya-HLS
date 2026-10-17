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

## GQD0四行真实G→量化→Down接链（AT023–AT025）

AT025 static/pilot/full均PASS，原独立gold验证10496 GATE F32、328量化组及Down335872 PS lane-group/4096F32；真实GATE 656 AW/W/B及656 R、Down82次A返回和256 AW/W/B、末B/局部publication/一次done消费保持。G cfg接受cycle25→Down consume102659为102634cycles，全冷TB102660cycles；W加载27064、Down cfg→consume16190。full guard747.161240s/peak1483444KiB、child0/null。AT023 pilot120.341961s timeout；AT024 full127.533100s semantic_stall仅因新进展标记未被原guard识别，其已经实际推进到第2行Wi。AT025第二轮只改进展标记，未改DUT/fixture/gold。独立源身份80项与原始六类Down计量详见GQD0报告和复核JSON。精确GATE首AW/末B边沿未记录，报告保留可证界限；联合物理资源/时序、完整请求及恢复未验。

## WI0四行真实resident Wi输出（AT026–AT028）

AT028 static/pilot/full均PASS；A物理256 half/128 scale提交，严格W q0/q1/scale实际R为41984/41984/5248，完整20992 stripes/671744 PS lane-group、2624 packet及20992 F32实际AXI逐位原gold通过。writer AW/W/B各1312、有效/物理83968B，末B、lease、一次发布与一次done消费闭合。cfg→done有效46911、→消费46918、全冷TB101335cycles；W加载54124cycles。full guard893.130500s/peak1456184KiB、child0/null，三guard 45条policy合规。AT026 pilot源ref误配FAIL；AT027 pilot120.371s COST_STOP；AT028只补真实W进展/前缀pilot后取得完整结果。独立事务地址与WSTRB逐笔检查范围外无写，但未做字节DDR哨兵最终读回。原始范围、精确边沿、失败与限制见R001/WI0报告及证据核验。WI0尚非Wi→G同runtime、错误恢复、全请求或物理时序通过。

## WIGQD0单引擎连续链有界停止（AT029–AT031）

AT029静态预填端口名错误FAIL；AT030 static/pilot PASS，full在Wi W长读取无可识别进度标记时COST_STOP；AT031第二轮补真实进度，static/pilot PASS。AT031 full在同进程真实Wi resident完整20992F32/671744 PS、1312 AW/W/B、末B、lease/读债及一次done消费后，对唯一DDR的Wi有效区83968B逐字节与独立gold核对通过。Wi cfg→首次done46911、→实际消费46918，全冷至Wi完成101335cycles。随后G命令接受，末条观测marker为cycle101339；120s无新语义进度，full COST_STOP（1137.182375s、峰1504604KiB）。没有完整Wi reader AR/R、G/GATE/量化/Down、最终哨兵全扫或整链周期；101339不是最终停拍，停止原因未定位。三尝试各102身份引用、冻结身份零不符；7guard串行、122policy合规。按一次接链加两次有因修复上界停排，不第三版/不加帽。原WI0/GQD0局部PASS不代签此链；完整M003/M004及物理/生产义务未完成。详见WIGQD0阶段报告、连接表、原AT031收据与日志。

## WIGQD1同DUT完整四行连续链（AT032）

AT032 static/pilot/full均PASS；相对AT031只有被动观察TB变化，DUT/fixture/gold/响应策略不变。四行原预量化LN_FFN A→真实Wi resident 20992 F32/671744 PS及1312 AW/W/B→实际DDR/reader 1312 R→G 10496 GATE F32和656 AW/W/B→656 R量化328组→唯一dualA epoch2→Down 335872 PS/4096 F32及256 AW/W/B，同进程无链间reset，原独立gold、末B、lease、一次完成消费均通过。全DDR 327680B终扫：Wi 83968B/GATE 41984B/Down 16384B逐字节gold，余185344B哨兵及written标记保持。全冷TB205314cycles；G cfg101339→全TB结束103975，Down cfg189122→实际消费205313为16191。旧AT031空窗内本次真实Wi reader、G/GATE、量化均有进展，历史COST_STOP不改写。full guard1750.811857s/峰1504888KiB、child0/trigger null；49条实际policy合规。仅有限B1/S128四行normal链；生产请求、错误恢复、全模型、联合资源和物理时序未验。详见R001 WIGQD1报告与原收据。

## QWIGQD0真实LN_FFN源量化供Wi的四行连续链（AT033/AT034）

AT034 static/pilot/full PASS：原LN_FFN 16384B F32经实际256个512bit R输入原唯一quant_task，4096 INT8/128 FP16 scale逐字节对原Wi独立gold，256 half commit并在cycle1101发布epoch1 A。Wi完整20992F32/671744 PS及1312 AW/W/B，真实reader1312R接G；G完整10496F32/656 AW/W/B，GATE重读656R，同量化器本任务328组/656 half发布epoch2 A；Down完整335872 PS/4096F32及256 AW/W/B、最后B/lease和真实响应消费。全冷206133cycles；源Q接受23，Wi完成102154，G接受102158，G A发布162862，Down消费206132。终扫393216B：只读源16384B、三段输出合142336B逐字节gold/written，余234496B哨兵未写。AT032旧预量化边界205314cycles仅作不同入口参考，不将新增819cycles归因单个量化核。AT034 full guard1778.416778s/峰1510892KiB，49实际policy符合CPU0–3/nice19/idle；静态/前缀分别82.810202/28.706722s，均child0无触发。AT033 full1276.007880s在G后A发布后因TB累计计数断言FAIL，旧收据不改。源AR首末拍未打印；仅R总数/地址界限/完成闭合。完整模型/生产恢复/联合资源及物理时序UNKNOWN。见R001/QWIGQD0结果、连接表、AT034原收据/核验。

## QAR0共享量化入口有限修复（AT035）

AT035 static/pilot/full均PASS。IDLE双valid真实RTL在cycle23唯一接受G并因owner拒绝，外部Q保持到cycle24接受；外部真实Q及其七拍响应保持期间G等待，真实G/GATE-Q及响应保持期间外部等待，原TB后置断言核两次释放/拒绝且无串响应。原LN_FFN四行16384B F32→4096 INT8/128scale、Wi20992F32/1312 AW-W-B→真实reader1312R→G10496F32/656 AW-W-B→同量化器656R/328组→Down335872 PS/4096F32/256 AW-W-B均原gold；最后B、lease、真实消费及393216B源/输出/哨兵终读回PASS。源Q为4个AR burst、请求/实际256R，首末AR27/712、R31/938；全TB206136cycles。AT034的206133不同探针/绝对相位，不判性能变化。106 manifest行/104冻结路径全SHA与bytes核，只有bridge/TB/runner三行改变；45 policy样本匹配。static/pilot/full 83.022106/29.197961/1782.005508s，full峰1505004KiB，child0/trigger null。仅签四行normal及定向竞争，非一般公平性、恢复、完整请求或物理时序。详见[R001 QAR0报告](runs/R001/reports/QAR0_shared_quant_admission_20261014.md)及原AT035收据。

AT036对AT035相同冻结bridge作默认EXT_QUANT=0顶层真实Vivado compile/elaborate，PASS_SCOPED_DEFAULT_STATIC：53.105357s、child0/trigger null、峰2212056KiB、31条policy匹配，106行继承身份零差异。仅签默认分支构建可行，G-only动态行为未新跑；见[R001 QAR0报告](runs/R001/reports/QAR0_shared_quant_admission_20261014.md)与AT036收据。

## LNREF0独立enc0 LN_FFN前缀（AT037/AT038）

AT038以原request3/generation1、B1/S128五ABI输入与GGUF独立计算完整Attention→WO→residual→LN_FFN；新residual完整128×1024 F32 SHA `bac04c09e6356fda7deb27c1889aaaccd803dca33bce87c3c92a6203e43482d8`，前四行SHA `5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9`。新LN完整输出与旧DUT capture的131072个F32逐位一致，前四行与AT035冻结源的4096个F32逐位一致；独立四行Q8 q/scale SHA也与原gold一致。主机guard3.225s/peak106568KiB、child0/null；没有DUT运行或新硬件周期。AT037相对路径启动错误及ABI tag封装错误保留原FAIL；AT038仅修为四个16B原package tag逐项核对。原LQ0 71 `.v`/7 `.dat`/5 Tcl逐SHA一致，但四行LN_FFN外层请求、真实AXI/末B/源lease/发布及AT035 Q地址映射仍待实际接链；新RTL成本、物理时序UNKNOWN。详见[R001 LNREF0报告](runs/R001/reports/LNREF0_independent_source_20261014.md)、[AT038原收据](runs/R001/attempts/AT038_LNREF0_reference_prefix_02/receipt.json)及[核验](runs/R001/attempts/AT038_LNREF0_reference_prefix_02/verification.json)。M003/M004未完成。

## LNF0四行LN_FFN→真实store→Q/fullA有限RTL（AT039/AT040）

AT040 static/pilot/full PASS；原baseline LN核接AT038独立四行 residual，真实source 4AR/256R、目的4AW/256W/4B/16384B，4096 F32逐位gold通过。末W167202→末B167215（13拍），END168843、publish168898、Q接受168900；Q实际4AR/256R读刚写LN字节，4096 INT8/128 FP16 scale由fullA32组逐项gold通过，响应消费169846后lease释放，fullA release169976，最终ledger/读债归零。本地65536B目的终扫目标16384B逐字节及邻接49152B哨兵/未写标记通过，未扫完整STATE0 BO。全冷TB170031cycles，非原16行LQ0同口径性能比较。AT039单行pilot因owner descriptor遗留layer1使END E_PROTOCOL=7 FAIL、full NOT_RUN；AT040只修该字段。AT040 static/pilot/full工具83.828/56.207/195.557s、39条实际policy合规，83项原生成物保持；原始细节见[R001 LNF0报告](runs/R001/reports/LNF0_four_row_rtl_result_20261014.md)、[AT040收据](runs/R001/attempts/AT040_LNF0_ffn4_02/receipt.json)及[核验](runs/R001/attempts/AT040_LNF0_ffn4_02/verification.json)。未接同runtime QAR0 Wi/G/Down，联合资源、生产请求、恢复、物理时序与M003/M004仍未完成。


---
Published: 2026-10-13T18:12:09.644611+00:00
Publication: P988d5e7b20de407085d01dcd7d622335
