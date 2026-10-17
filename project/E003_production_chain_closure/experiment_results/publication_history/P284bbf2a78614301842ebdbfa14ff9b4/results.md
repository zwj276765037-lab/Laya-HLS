# E003本轮结果

executor_stream_host_01编译FAIL保留；_02实际C++ consumer/program/port/FSM/adapter受控peer范围PASS。actor_host_10原45F17/两请求8退休兼容PASS。executor_hls_host_01原18FIFO六独立process、_02新21FIFO七独立process均PASS_SCOPED_HOST，旧身份不回写。_02完整GRANTED owner echo前零LGP，合法foreign echo保持旧commit1 ABORT且后续正确echo不能解隔离；90/90 frozen声明pair已核。build20.976673s、峰286008KiB、105owned RSS采样；短host各实际功能marker通过，部分无child采样峰null，资源完整性不能泛称全部实测。软件stream无depth限制，shell/physical fence仍受控。新owned program/真实控制transport在准备，HLS生成、同runtimeLN/Q、资源联合/时序NOT_RUN。managed LPV原355冻结与有限PASS引用先前交付，不追认为新整链证据。

executor_hls_01为COST_STOP：120.081628s未观察到认可语义/产物进展，elapsed280.460530s、peak1477768KiB/1401RSS样本，Compile/Link266124/Unroll-Inline pending、0生成top。并非DUT动态FAIL或已证不可综合；根因待有界定位。新control_transport_rtl_01实际有限RTL PASS，真实shell+三depth2 FIFO、完整16拍实际写读及accepted全帧validator；actual executor端仍为TB byte-oracle，fence/终态受控，不代签同runtime硬件链。graph_program_owned_host_01静态链接FAIL（缺真实model binding助手），未执行DUT；已补实际compute_client/full_memory依赖为14源，_02运行中，原_01不回写。

已核graph_program_owned_host_02 PASS_SCOPED_HOST：14源、9独立process，完整GRANTED安装/echo、原command/LAP与实际LAC receipt及成功/取消/错绑定/旧完成。tail2/tail1各12次软件调用，部分短run无child RSS，仍不签depth2或实际LN service。graph_program_owned_hls_01复用_02精确host闭包，仅HLS运行，无host重跑。A005只读定位已交：最后成功gdce后进入LTO reflow，宽端口disaggregate末事件；inclusive调用计数不相加，未证明auto-inline爆炸。选取已支持NORM的专用descriptor/BEGIN作为最小结构修复假设，需完整wire+泛型对比和受影响host。

NORM专用metadata双模式12process PASS：2538完整1024B独立gold/泛型Check与seq/输出前缀对照，S1/S16原拒绝、物理presence/capacity/序号边界保持；norm_host01 354/354 frozen及声明pair。executor_host03七process PASS，91/91冻结配对；其候选同时包含NORM与完整byte-loop修复。executor_hls02仍COST_STOP：285.493267s、peak1476484KiB、语义stall/child-9、0生成top，Compile/Link226981 vs旧266124为联合变化，仅中间编译计数；不签硬件资源/周期收益。

owned_hls03 HLS child0、345.905041s、peak4832216KiB，确有top但receipt FAIL_PORTS：program_pending生成input/dangling/read0，必须output8192；memcmp错误已消失，不把此生成当可用PASS。HLS top估计BRAM18=18/DSP1/FF64225/LUT203729/URAM0，仅失败候选综合估计，不计联合资源、不签P&R。399/399冻结配对已核。A004只读IR定位：gdce仍实际非null key及bound_command，a.g.0丢key/变null取消语义、WRITE_ACTION直接隔离；旧legacy在gdce已DCE，名字碰撞/同TU根因未证。A002以explicit has_issued_key＋完整Key内部调用替代综合可达nullable指针，旧软件pointer overload兼容；owned_host05九独立process PASS；复用其稳定闭包启动owned_hls04，实际guard运行，尚无终态。

owned_hls04复用host05，actual tool child0/442.930003s/peak5421624KiB，8FIFO/24signal(3x8192+5x512)端口完整PASS_SCOPED_GENERATION。HLS top估计BRAM18=24/DSP1/FF69372/LUT254536/URAM0，仅本候选，不签资源联合/物理/周期。owned_rtl01因审核副本与实际top路径不同误拒绝，字节/SHA相同且无工具启动；runner保留两对象各自验证及相等hash后修复，新rtl02 actual static运行。admission_transport_rtl01实际FAIL，TB drive cancel后立即检查组合gate，root仅补结算采样，DUT未变，待新attempt验证。

admission_transport_rtl02 PASS：只改TB pre-first cancel drive后组合结算采样，DUT相同；旧01真实FAIL保留。两个实际depth2 FIFO、16拍LAD收集/原包echo、真实portal全记录安装与受控physical域拒绝/取消通过，上游executor peer仍TB。guard39.502949s/peak1645560KiB/197captures。LPV_owner_sidecar_rtl01 PASS_SCOPED_RTL_SIDECAR：guard26.295958s/peak1341036KiB/131captures，旧LTX A/route→16LPV→8返回→实际LTC末pop归属保持；generated-adapter peer受控，未代签actual生成adapter。owned_program_rtl02静态PASS，success在84555ns归属安装阶段isolated动态FAIL；正在核完整输入/握手与生成逻辑，未接纳行为。executor_host04三残留memcmp完整byte-loop修复七process PASS，五宽口有界诊断正在准备，尚未生成或运行。

source_guard_v2_rtl02六case/3214cycles PASS_SCOPED_RTL_SOURCE_GUARD：actual shell+control transport完整K/B/GRANTED，持久取消/旧AR-R债与F9-LAC真实尾消费；query/fence/producer等peer受控，有限AR非完整tensor。guard35.037231s/peak1651728KiB/175captures。旧01 TB string ternary触发simulator kernel异常；02仅if/else literal等价刺激，DUT相同且六case/全部assert保持。owned RTL02实际binding重验拒绝尚未修复；sidecar旧END首LTX cancel gate缺口已向主控请求具体owner合同，正常C与五宽口准备独立继续。


五宽口executor_wide_fifo_diagnostic01 PASS_SCOPED_GENERATION：actual五8192方向/15信号、真实读写、完整byte oracle；HLS38.071846s/peak2372468KiB/189samples。仅排除五宽口组合本身足以必然stall；无actor/归属/退休，generated RTL反压NOT_RUN。owned RTL02只读诊断确认嵌套bootstrap purpose误读Message.kind；gdce正确，a.g.0及RTL取[15:0]而应[207:192]。canonical equality先前未执行，不追认已比较。live修复用真实purpose标量跨完整validator体，其他校验逐字保留；host06九processPASS，当前host07增加直接/嵌套invalid purpose/物理span/model负例。旧04/rtl02冻结不改。旧LTX cleanup主控合同已收到：真实FSM完整pending、单候选24拍收集、END/INVALIDATE唯一hub核定、普通未外发由实际adapter本地LTC拒绝；实施未验。

owned_host07实际十process PASS_SCOPED_HOST；新HLS05复用其精确冻结闭包，未重复主机运行。purpose标量修复与新增负例纳入本候选；HLS05当前运行，生成/行为尚待实际出口。

owned_hls05 actual生成PASS_SCOPED_GENERATION：HLS460.284951s/peak5422052KiB/2299RSS captures，child0/trigger null；新program有限rtl03已启动。中间IR已核purpose正确[207:192]→16bit标量→eq1；完整运行往返仍待真实RTL。旧rtl02 FAIL保留。

owned_rtl03 static PASS（107.679985s），success在84645ns/phase1实际isolated FAIL，未运行余case。诊断03克隆编译snapshot仅只读观察：实际purpose1，nested validate_fields仍非OK7。A004定位第二错误：d.content比较错取Message RAM9低8bit target_region0，正确content在[199:192]且为F32=1；width[191:176]1024正确。state10因此短路，模型canonical及外层完整equality仍未执行，不能把后继initial0/1视为比较事实。继续原合同内最小字段边界修复，旧FAIL及frozen不改。source_guard02另有runner增强kernel/FATAL_ERROR失败识别变更，补记此前只描述TB string变化的遗漏；DUT和六case/assert保持。

# Program完整validator联合修复与actual adapter有限出口

回复 executor-program-content-mapping-review-20261013；M003/SM003/E003/R003，A002整合，C先于D。

## 新定位及修复

A004把HLS05完整validate_fields的416项model copy逐项追到原Message输入：409正确，j={0,64,128,192,256,320,384}七项错误读Message byte128+j，正确应152+j；它们是尚未动态进入路径中的静态错误。diagnostic03的原Message 416/416与独立owner输入一致，不能改fixture。purpose/content已观察错误与此未执行缺陷分开。A004对handoff→checkpoint→bootstrap binding_packet/put_owner补做有界只读核查：真实encode的content取RAM9[199:192]、模型动态152+i→wire160+i、purpose取RAM0[207:192]均静态正确；外层canonical/模型验证仍未动态测得，不扩大为PASS。

A002联合修复仅改内部完整validator：purpose已有实际scalar；新增实际r.source.content scalar，原d.content条件用该值；整对象identity复制改完整416次动态byte loop（unroll off）。保持公开接口、所有拒绝条件、独立region、完整canonical及416B/1024B比较，未传常量或改wire。新host bootstrap-purpose过程增加content0/2/255 direct/nested、correct F32+region1 direct/nested、七copy块首分别single-byte模型破坏拒绝。

`graph_program_owned_host_08`十独立process PASS_SCOPED_HOST，14源；build8.886544s、peak266988KiB、44owned RSS捕获。各短case peak/policy实际null不由配置补造；软件stream无depth限制。399/399 frozen与声明pair、当前live均核一致。新`graph_program_owned_hls_06`复用其精确冻结host闭包已实际启动（exec session32841），当前仅RUNNING；没有新executor RTL或硬件收益。A004准备同一生成物nested双512RAM validator的purpose/content/region/七copy边界输入，保留unknown padding mask；它不代签owner安装无副作用。

## Actual adapter有限RTL

`executor_adapter_lpv_generated_rtl_01`四复位分隔case PASS_SCOPED_RTL_ACTUAL_GENERATED_ADAPTER_PORTAL，总343711cycles；每次真实24 LTX/16 LPV/8 LPA/16 LTC消费，末LTC实际caller pop才释放事务，完整字节与独立literal相同。static126.760678s、peak4532732KiB；四sim35.396836/23.395227/11.573670/17.655366s、最大856988KiB，各child0/trigger null。369/369 frozen与声明pair/current均一致；两attempt共1326条nonoriginal递归SHA/bytes引用匹配。

范围是实际生成adapter、F10、sidecar、唯一实际portal/transport/monitor/hub；LTX/准入/AXI producer/fence peers受控。BEGIN声明rows16×4096B，实际writer仅64B，matching END为实际issued64的错误终态，因此签error transport/drain，不签完整LN正常数值。cancel在旧END首LTX pop及两raw LPV之后；CLAIM返回反压撤销与正常CLAIM-only INVALIDATE覆盖。撤销后新的cleanup首LTX仍被冻结sidecar阻断，case显式观察排队前2拍；post-revoke cleanup NOT_RUN，不伪称已闭合D-M003-EXECUTOR-OLD-LTX-CLEANUP-01。旧adapter HLS03 broad checker FAIL保持，使用已冻结实际top端口和旧RTL03身份，不回写旧receipt。

## 当前关键路径

唯一重工具为program HLS06。A006独立准备managed adapter真实pre-dispatch LOCAL_REJECT/END+INVALIDATE精确白名单，未运行；A005只读核FSM持久pending完整导出，A002随后整合collector/旧A路由门。稳定shared bootstrap后fresh executor host→有实质变化的新生成，不原样重启旧stall；C完整NORM与周期仍NOT_RUN。D/Q及完整CLOSED/rearm后置，旧债务/必要cleanup不后置。原单重工具/全部资源帽/G仅OOC余额2338.224019s/5172s不重启保持，M003/M004未完成。

证据：本目录executor_program_validator_adapter_verification_20261013.json、graph_program_owned_host_08/receipt.json、executor_adapter_lpv_generated_rtl_01/receipt.json；agent/A004/result.md保存IR具体位置。


---
Published: 2026-10-13T03:57:17.996417+00:00
Publication: Pd7b9461578864cf7a257f0177ba51a34
