# E003：R003实际结果与范围

codec_01严格C编译、负例和独立1536B逐字节oracle PASS。transport_05 PASS432cycles，accepted4/retired5/stale1；受控service endpoint，只证明transport。

matrix_binding_03 PASS859cycles，7实际resident commands/responses，6类活动取消与K256/N2恢复、AW/W/B2及4独立零F32；A/W为受控诊断端点，不是物理cache/模型链。base_mirror_02 PASS595cycles，13roles/26words/全部16WSTRB/61native writes/3snapshots，与真实历史pointer controller比较，current generated acceptance尚未绑定。axi_owner_02 PASS134cycles，AR4/R8/AW3/W6/B3及held lastR/B、W先AW、clear_error不清债与early-LAST恢复；overlong-R恢复未验证。

实际AMD dwidth512_03/128_01 PASS2344/2408cycles，guard0/null24.506518/24.925118s，peak1613640/1600148KiB。独立2048B读和8192B写/sentinel比较、稀疏WSTRB、64位高地址、4KiB拆分AR/AW2、真实R/W512与B2、RRESP/BRESP错误归并和末R/B反压。512_01/02保留末MI B同拍TB旧计数失败，修复真实edge统计后通过；无生产链/OOC/资源声明。

axi_13bo_owner_01 PASS372cycles，13BO×2owners=26transactions、AR/R/AW/W/B26each、26heldR/B，全部45具名字段。guard0/null23.452140s，peak1328940KiB。使用真实历史ABI，不代签新generated caller。

load_portal_02 PASS1143cycles，11commands/replies、5cancel cases、2overflow拒绝、1AUX RRESP错、2恢复和external-debt barrier；实际q AR9/R288、AUX AR14/R77。默认完整cache、独立诊断q/half1 scale/nonzero bias(+1.5/-2.5) stripe lease/read/release比较；guard0/null23.095349s、peak1468772KiB。覆盖cache load_done同拍cancel与pending-success/READY同拍cancel。此前load01 PASS仅其冻结范围。

load_native_02 PASS17275cycles，13commands/replies、6cancel、2overflow拒绝、1AUX RRESP错误、3正常恢复、外部debt barrier、pending-cancel/READY、实际8B AUX尾读，以及controller owner0的完整侧带恢复读。默认完整cache、四实际AMD converter与一个13BO owner wrapper，实际q AR23/R5633（含controller probe1）、AUX AR18/R366。held SI最后返回保留FIFO_MODE0真实cut-through MI LAST和owner，两个方向实际排空前不完成。guard0/null33.584732s、peak1831992KiB。26生成IP/source文件已哈希；保留vendor fifo_generator一条simulation warning，PASS轮无ERROR/FATAL。native01保留TB错误预期“held SI时MI已退休”的FAIL，原始IP语义核查后修正，未删no-early-ownership/completion检查。诊断数据/manual32-bit memory peers，不是当前generated/真实GGUF/整链通过。

resident_regression_02当前cache/reader取消依赖下static/pilot/full均PASS：56.586667/87.111961/424.467004s，peak2407008/1426128/1422652KiB，guard0/null。full48862cycles，4原distinct Down rows K2624/N1024，10496stripes/335872lane-groups、4096独立F32输出、512实际AW/W/Beach、heldB9217cycles与最后B发布/真实源release。A仍为原预量化fixture，无同runtime Wi/G/quant/13BO。resident01只按新增LOAD cancel前冻结身份有效。

终态后的当前/冻结身份核查：LOAD portal11、resident26、native LOAD21项file pairs全匹配，receipt manifest SHA匹配。全部attempt保留。L0 PARTIAL/L1 PARTIAL；L2–L5 NOT_RUN。完整首错/原始AXI源优先级、多view、CE/reset与真实同runtime链未通过；generic cache error映射不可代签L3。旧CPU/CSim适用旧build，新最终身份回归尚未执行。完整M004、资源/性能/P&R/板层未验收。

load_native_03：当前native adapter补齐selected native offered AR/AW/W与visible R/B barrier。PASS18863cycles，14commands/replies，控制器AR背压15cycles后真实接受/返回，再准入LOAD；全部既有取消/恢复/8B AUX与owner测试保持。q AR26/R6146（含2controller probes）、AUX AR20/R400，guard0/null34.301440s、peak1839268KiB，21当前/冻结file pairs匹配。native02只签此前冻结adapter，resident02依赖未改变继续有效。仅新测controller offered AR，其它native写屏障不由该读测试代签。

## 2026-10-11 新冻结局部验证

- codec_v2_02 PASS：四service、406mutation，独立6144B逐字节oracle。codec_v2_01编译失败保留于codec_v2_guard_01/driver.log，旧runner未冻结失败preimage，不能补称其具有完整冻结。
- transport_v2_02 PASS836cycles；最新版transport_generation_02 PASS1786cycles，accepted9/retired23/stale2。9类坏头超大g、10first-push cancel、partial/bad-tail可信g耗号、末响应读/cancel竞争、同session/新session恢复及跳号覆盖；20.442486s、peak1580948KiB、guard0/null。仅受控service端点，不代签真实hub/parent联动。
- load_native_v2_01 PASS18863cycles：14commands/replies、6cancel、2overflow、1AUX错误、3恢复；q AR26/R6146、AUX AR20/R400；35.675456s、peak1819492KiB。默认完整cache、四真实AMD converter与13BO owner，仍诊断数据/manual peers。
- matrix_binding_v2_01 static/pilot PASS56.545527/18.367958s，旧7命令6取消与K256/N2单view恢复范围保持；控制A/W端点，不证明多view父租约。
- reservation_03 PASS：128窗口/385typed/769门户票据、rows1..16的尾view、未发g不回收、同generation下一request重建与u64溢出；Controller仅syntax通过。host sizeof TaskReservation260B/GDownWindow264B/GDownPlan33936B，非RTL资源。
- parent_a_01 PASS10309cycles：真实完整dualA，3fills/3acquire/3release、9local views、7实体/覆盖拒绝、94464独立q字节比较，held末A return阻止release，窗口间cancel等external debt，same-session下一request恢复。23.679215s、peak1397844KiB、guard0/null。预量化诊断fixture不代签G/quant算术、真实source provenance、matrix联动或模型链。

所有上述结果仅适用于各自冻结输入；L0/L1 PARTIAL、L2–L5 NOT_RUN，M004未完成。新parent、matrix多view/首错、GATE同epoch跨窗口/分期、唯一持久hub及caller继续实施。无新OOC/P&R/上板。

## 2026-10-11 新增冻结局部证据

- `gate_tensor_04` PASS_SCOPED：1234 cycles，128窗口/2048行同epoch，最终写债后一次READY，8窗口读租约、跨窗口cancel、同session恢复；guard20.816296s、峰值1290512KiB。仅metadata ledger。
- `matrix_tensor_02` PASS_SCOPED：3529 cycles，128父/512 views/2048行，同dst epoch多父、早父不提前发布、sticky失败、跨父取消与恢复。
- `matrix_parent_current_01`在当前tensor ledger接口后重新取得static/pilot PASS。
- `matrix_parent_views_07` static/pilot PASS：58.001144/382.907547s，峰值2413404/1389172KiB，128440 cycles。18 commands/replies；新增9个真实rows4 view覆盖成功父、跨view空档取消、同session下一request失败父。各view独立g，每父一次A/W物理lease、成功/失败各一次父TaskDone，取消不伪造TaskDone；AW/W/B各2563，末view第512个B反压后释放；受控rank 2112000→5280验证跨view最小归并。诊断零输出和受控rank不代签模型数值。

`gate_tensor_01..03`与`matrix_parent_views_01..06`失败均保留。当前仍为L0/L1 PARTIAL、L2–L5 NOT_RUN；物理GATE writer、真实quant/G source、实际fullA/fullW cache、唯一hub/caller、完整CPU/CSim与M004未完成。

- 成本合规更正：matrix_parent_views_07的382.907547s完整运行没有先行≤120s成功pilot或冻结估算，且runner自matrix_parent_views_04起把pilot上限直接改为600s；功能PASS保留，但执行分类/预算为偏离，不能作为合规pilot/full成本证据。runner现恢复120s短pilot，完整回归使用显式full/3600s并在启动前记录实测速率和保守估算。
## 2026-10-11 物理GATE与split运行结果

- `gate_store_04` PASS_SCOPED：202711 cycles；完整64行/四个rows16窗口共用同一GATE epoch，10496个实际AW/W/B，含取消场景总计10660个；末B后READY。21.641107s、峰值1323428KiB。受控GATE字输入只签writer/store。
- `gate_split_static_01` PASS_SCOPED_STATIC：唯一canonical GEGLU、物理store、延迟QUANT和full dual-A编译/展开通过；48.698790s、峰值2133148KiB，无运行声明。
- `gate_split_04` PASS_SCOPED_RUNTIME：static 52.656369s；一行pilot 11769 cycles/32.550573s；full 758736 cycles/1054.961660s、峰值1326676KiB。四个G命令共64行、335872 WI words、167936 GATE words、10496 AW/W/B；所有G结束前AR/quant为0。随后一个独立Q命令读取window0：56 AR/2624 R、16 quant rows/2624 halves；fullA四个rows4 view检查1312项，GATE与q/d/reciprocal/scale/fullA均比独立gold，最后释放lease并清理tensor。manifest SHA256=`bb7309b0e22f1de7940a144e8e93269367953851441705ade1cfba14ed4b9809`，receipt SHA256=`f8ad62afc4595dd7eb6d680b5cce1b4f5b6cb71d4381ea989ab6b47cb2ab9ad8`。
- `matrix_cost_stop_branch_01` PASS（记录逻辑）：合成3601s>3600s得到`COST_STOP/started:false`，manifest SHA256=`01a85a6aedf2cc10d99221bce2fe5fda778e042206e6e5c8dae4ead82ac5f96a`与receipt绑定一致，没有full工具产物。未运行Vivado，不是matrix功能证据。

`gate_store_01..03`和`gate_split_01..03`失败均保留；后者依次暴露TB组合ready采样及full进度可见性问题。`_04`没有缩减DUT、gold或full覆盖。当前只证明实际canonical GEGLU多窗口同epoch→独立QUANT window0→fullA局部链；其余Q/L、LOAD、fullW/matrix、hub/caller、L2/L3、完整CPU/CSim和M004未完成。

## 2026-10-11 真实父缓存matrix与停滞保护证据

- `matrix_parent_cache_03` PASS_SCOPED_RUNTIME：static/pilot/full 62.534447/92.153086/1725.782300s；full 114182 cycles，四个不同g的rows4 view共用一个rows16父。实际A提交2624 halves/1312 scales，W读取44608 beat；41984 stripes、167936个PS gold、16384个最终F32 gold、AW/W/B各2048。A/W各真实acquire/release一次，末B后父覆盖`ffff`且TaskDone一次。单父只覆盖tensor前16/256行，tensor publication保持0。manifest SHA256=`e87ba8097dad18e54078ef18e964c4c45ccabd62f60cd29a1db8a2498c55231d`，receipt SHA256=`2b51a19397dbade08bc8ab65c5ae69e35ec958ba6938e0434182fdf1bcbe1b3c`。
- `gate_split_progress_guard_02` PASS：1000条不变work进度不刷新，两次真实work增加可刷新；无Vivado/功能声明。manifest SHA256=`b3090800273e75c206f520f52f2e5172b5111be44406512985e5dc8b98d175fc`，receipt SHA256=`20857a4505379318c2ee0812c02d035324b7130c9df3ed227c8cd206bb68ebe4`。

`matrix_parent_cache_01/_02`和`gate_split_progress_guard_01`失败保留。当前A仍是预量化fixture；实际G/Q→该父matrix、多父tensor、其余Q/L、LOAD、hub/caller、L2/L3及完整CPU/CSim未完成。

## 2026-10-11 actual G/Q→父matrix组合成本证据

`gate_quant_matrix_parent_03`冻结实际canonical GEGLU/GATE、独立QUANT fullA、真实fullW与父matrix四view的直接连接；A没有TB填充路径。static 84.239673s PASS；同一no-wave batch profile的一行真实G pilot 11773 cycles/63.410458s PASS。以已通过组件758736+114182 cycles为完整工作量上界，当前pilot 185.663 cycles/s并加10%余量投影5172s>3600s，故full为`COST_STOP/started:false`。manifest `f0c140708f014f31a99e166728c4e47a16e0a9ae62dca84c462763fa7a770525`，receipt `042347a390b73357108c20090326c59e2728db1ac756fbab37ad64b7c4cdc0ac`。

`gate_quant_matrix_parent_01`旧成本逻辑仅按两个分立full墙钟估算3476s而启动；组合速率显出不适用后在591.128178s主动停止，保留FAIL/sigterm、无PASS marker。修正入口不增帽、不缩覆盖。`gate_split_progress_guard_03`另证明recognized split前缀缺work/缺字段/非法字段不刷新停滞计时，重复work也不刷新；receipt `51084ae8eb12f366b7580cf8183ba419ccf31fbd0a8766ed17cc3838556489b8`。

## 2026-10-12 G门户物理绑定与普通QUANT局部证据

- `gate_quant_binding_pilot_06`当前源码static/pilot PASS：52.922042/21.735452s，峰值2153908/834184KiB；一个真实v2 G命令执行一行，WI AR/R=6/328，GATE AW/W/B各164，最后B反压12cycles，返回绑定且无Q命令时quant不启动，tensor仍未READY，总12108cycles。manifest SHA256=`aa5801b363b93c0117b7a4304e187833cd63f137d8ff73fd26fa2f55fb4a8929`，receipt SHA256=`f9e9c5da35f31ca62b6e03f5e55f22130171fcaf2acab50f7fd8f617cf4fc2b4`。该结果只签一行G的物理WI/GATE/返回路径；没有Q payload、完整GATE tensor、hub、LOAD、matrix或完整请求。
- `gate_quant_ordinary_portal_02`static/pilot PASS：52.389593/6.370841s，峰值2138808/856820KiB；先拒绝未发布来源，再让一条stage6/K256普通Q命令使用与GATE Q相同的唯一quant/full-A实例。实际source AR/R=1/16，8个quant group、16 half commit、8 scale commit及8组独立冻结gold通过，未使用GATE lease，总191cycles。manifest SHA256=`2152619dbb09bd77bb9010251dd30592da9235f3022eb28c9cfb567f7df3479d`，receipt SHA256=`aa3577895e9d40e05cec584e9915b1f31d278b15a2cf9b82cf878222514a8c0c`。来源发布为受控布尔边界；尚未证明真实generated provenance ledger、其它普通K/shape、LOAD、matrix或完整请求。

`gate_quant_binding_pilot_01..04`依次保留TB RVALID/BVALID竞态与默认WDB开销超时、物理完成后暴露writer_busy完成死锁、TB错误预期WI AR=3、以及在response握手前检查ledger覆盖的FAIL；`_05`为普通Q改动前的旧PASS，`_06`是当前入口。`gate_quant_ordinary_portal_01`保留把共享普通source AR误判为GATE AR的断言FAIL。修复未删除DUT工作量或gold。

共享QUANT状态机已影响历史`gate_split_04`的冻结入口，需按原120s pilot和显式full成本路径做当前源码回归。真实provenance cmd/rsp双FIFO、持久hub/generated caller、LOAD与其余Q/L、完整G/Q→matrix、L2/L3和当前CPU/实际CSim仍未完成；L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成。

## 2026-10-12 当前共享QUANT split回归

`gate_split_06`当前源码static/pilot/full全PASS：50.023254/31.830809/1038.453534s，峰值2103036/1314936/1332376KiB；pilot 11769cycles，一行G的WI/G/AW/B为5248/2624/164/164。full 758736cycles，四个rows16 G命令共64行且同GATE epoch，WI/G words=335872/167936，AW/B各10496；全部G完成后独立Q读取window0，AR/R=56/2624、quant rows/halves=16/2624、fullA检查1312 words，并完成GATE window release与tensor cancel cleanup。manifest SHA256=`6f129b48ac1b197dde0f0c9cfea11a65b893ae9d84be81f3b686d3c6f9f27aba`，receipt SHA256=`7e8810b7b8a257e18a117964bb7aaea62e9de850c3b11986512fc4679c3ae1fb`。

`gate_split_05`保留static FAIL：新增DUT output `g_cfg_admitted`后旧TB以`.*`实例化但未声明同名信号，elaboration失败；receipt SHA256=`0f4ac4ed96910317ba489188f896e446581aab0a83529d605ad39cd55fcf6ebc`。`_06`只补TB连线声明，未改变DUT、fixture、gold或full工作量。

该结果重新签当前RTL的canonical GEGLU四窗口→延迟GATE QUANT→fullA局部链。普通↔GATE无复位切换、普通其它K/row-space与跨batch地址、真实source lease/hub、LOAD/fullW/matrix及完整请求仍未通过；组合G/Q→matrix的5172s profile继续`NOT_RUN_COST`。


## 2026-10-12 generated provenance 基础阶段

当前有效generated_provenance_codec_04、ledger_05、events_09、portal_controller_27、portal_07和fifo_probe_02均在各自范围PASS。codec独立oracle；ledger 64 checks；events 81 checks/final seq7/partial bytes8；Controller 25 commands/13 typed tasks/provenance events2/store bytes65536；RTL portal accepted14/retired17/805cycles；四FIFO probe的12根信号全部匹配。六项共284组current/frozen文件身份全部匹配，0 mismatch，详见generated_provenance_base_stage_20261012/verification.json。

RTL portal的物理观测是受控TB输入，FIFO probe不等于production top综合；本阶段不证明真实AXI/WSTRB、adapter fence、普通QUANT来源lease、数值payload或完整图。portal_01..05、ledger_01..02、events_01..03失败attempt保留。无OOC、P&R或上板。

## 2026-10-12 generated provenance审核修复与真实AXI monitor

portal_controller_29 PASS：scope-active错误END不退休，23.144976s/260820KiB。generated_provenance_ledger_07 PASS301项：physical fence wait、33次同session request安全回收及stale reject，22.229241s/260884KiB。generated_provenance_portal_10在当前9文件registry闭包PASS7107cycles，accepted148/retired151/terminal35，22.966027s/1435972KiB。三项闭合主控审核F1/F2/F3；RTL portal的物理观察仍为受控输入。

generated_store_monitor_03 PASS_SCOPED_RUNTIME：5961cycles，一个role6/单descriptor/连续rows16 owner完成1024个真实AXI512单拍写，peer AW/W/B各1024，monitor AW/W各1024、B退休1026，65536B唯一覆盖和2个本地拒绝。W-before-AW、末B反压12拍、adapter fence8拍、越界转发前拒绝、非法两拍burst完整排空、unsupported BEGIN和同session恢复通过。guard 23.567974s/1459396KiB/trigger null。

聚合generated_provenance_monitor_stage_20261012/verification.json核191/191 current、191/191 frozen及580/580引用匹配，SHA256 95d5aaf0a708a67f8bbf93b2310458b51af9de7dab18f12f8d9bcc4235735ab1。monitor_01编译FAIL和_02非法burst drain断言FAIL保留。当前没有证明generated HLS adapter排空因果、production top真实master、多role/QKV、普通QUANT source lease或完整数值链；无OOC、P&R或上板。


---
Published: 2026-10-11T20:59:08.462119+00:00
Publication: Pf4d86ca58fa140e8a4c844cb237e335f
## 2026-10-12 generated provenance取消/fence闭合

F2/F4受影响回归在当前冻结身份取得限定PASS。`generated_provenance_portal_11`为7161cycles，accepted148、retired152、semantic rejects4、terminal35，验证未排空拒绝如实返回、owner事件等待fence和pending期间中途首错sticky；`generated_store_monitor_04`为6073cycles，19 events/4 terminal，AW/W各1025、B1027、2次本地拒绝，验证BEGIN应答反压、活动cancel、cancel后posted store、W-before-AW、末B/fence及匹配END ingress。`generated_provenance_ledger_08`继续通过301项CPU reference检查和33次同session request回收，`portal_controller_30`保持当前production C++闭包，codec独立oracle亦通过。

五个当前attempt的receipt SHA256依次为`c8109a222edc84803a1aba8ffc280738a01e68479eb9f174fc8fc23eaa0745b7`、`174459d56e4c23c86f72a37ccb9ef01e7d69cfcd9f8cdedffbd61c2c590b4d34`、`eed1d934c006d0bf484f5f08962c525deeaea5cbf3b6a589e3bdd85e0f99cc24`、`ec5680d0aa522617dc6696a76470e3347845632657221d49a412c733819c50cf`、`0f6c3439763cf5ea9f75cc4d2fd505d5dc43e374d66d4ce198a5ba3f51d6c825`。聚合核查213/213 current、213/213 frozen、213/213 pair及634/634引用匹配，`generated_provenance_cancel_fence_stage_20261012/verification.json` SHA256=`0b84d634a8eda46d1bd070edeeafa7ad17ce11d52e63e6a0c38c984dcdb96064`。

该结果仍以TB控制`adapter_pending_zero`，不证明production HLS adapter内部队列的真实排空因果，也不证明普通QUANT source lease、多role/QKV、完整数值图或硬件性能。L0/L1仍PARTIAL、L2–L5 NOT_RUN，组合full仍NOT_RUN_COST，M003/M004未完成。


---
Published: 2026-10-11T21:16:02.776108+00:00
Publication: P1ebdd639d1b044539ec3ee6b8163fb8e


## 2026-10-12 Controller F1b受影响回归

`portal_controller_31` PASS：41个当前生产闭包编译单元与测试单元通过，23.100374s、261212KiB。新增完整绑定的`E_BUFFER/DRAINED=0/SCOPE_ACTIVE=0`与`E_PROTOCOL/DRAINED=0/SCOPE_ACTIVE=1`用例，均保持active tracker、descriptor binding、65536 issued bytes及`last_task_id/tasks_retired/op_calls=0`；既有成功/失败终态一次退休和同session恢复保持。manifest SHA256=`fc304513154cf641dd4300ae24db4754209df94f4f6adb6cbc6f723056914293`，receipt SHA256=`12033b85e4e8ab31deb7f652003bde54c9b002272d3dcd9ee84743ecc1f4d387`。聚合核查82/82 current、82/82 frozen、82/82 pair及171/171引用匹配，verification SHA256=`56c9ca233c239b23f820a79085f48aabdc43de588cbef359bd64886af03d2ebf`。

F1b只在受控C++范围关闭；没有完整CPU/CSim、RTL production adapter、数值payload或硬件声明。外层launcher策略未在该attempt单独留档，保留此记录缺口且不补造历史。


---
Published: 2026-10-11T21:26:57.148733+00:00
Publication: P7c809a76912e41d6939976bd15568cd7

## 2026-10-12 普通source→真实QUANT限定PASS

`generated_source_lease_01`完成四个不同P Context的rows16覆盖、整tensor发布门、完整身份/模型/Ref/range拒绝、原子lease、generation防重放及未排空释放保护。`gate_quant_source_lease_03` static/pilot PASS；stage2/K1024窗口实际完成16 AR、1024 R、512 quant group、1024 half commit、512 scale commit和128个fullA四行group读回，4493cycles。16,384个F32/INT8元素与512个scale逐项匹配；输入由八个独立冻结group重复组成，不能称为16,384个唯一向量。lease跨response背压保持，并在读债和response退休后释放。

当前portal与store-monitor受影响回归`generated_provenance_portal_14`和`generated_store_monitor_05`均PASS，保留33-request回收/QKV原子/取消fence及活动cancel/posted-store/W-before-AW/末B边界。四项attempt共93/93 current/frozen/pair及435/435 manifest引用匹配。verification SHA256=`3ba2edbcad017bdc3617ae4ed4167bdad3ed6ae673e40d7134664dad44a8faab`。`portal_12`、`source_lease_01/_02`历史FAIL原样保留。

范围仍不包含production generated-HLS master/adapter fence因果、普通/GATE无复位切换、其它shape/跨batch/multi-role/QKV、LOAD、matrix、完整请求或当前CPU/实际CSim；无OOC、P&R或上板。


---
Published: 2026-10-11T22:02:12.305167+00:00
Publication: P2ccfcb52fb494844a4620f55b92e57a3
