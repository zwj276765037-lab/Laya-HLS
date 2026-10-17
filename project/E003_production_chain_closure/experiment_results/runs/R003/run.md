# R003 — M003/L1 生产门户实现与受影响验证

execution_state: running
verdict: unassessed

范围：合同§3.9固定cmd16/rsp8的C/SV编码、两个private FIFO、整包接收与一次单服务调用、completion与债务排空。该入口将连接真实物理resident/cache/quant服务；门户自身验证不能代签13BO/整链。

实现仅写E002/experiment；证据写本R003。独立逐位编码/响应身份/反压、cancel和晚响应检查使用断言，不改gold或模型；CPU/静态/RTL保护按协议。最终身份与完整CPU/CSim留待L1–L3稳定后执行。


本轮新增终态：dwidth512_03/128_01、axi_13bo_owner_01、load_portal_02、load_native_02及resident_regression_02均在各自冻结局部范围PASS。LOAD native实例化一个默认完整cache、四真实AMD converter与一13BO owner封装，但controller0是manual peer，A/W数值或真实generated/全模型不能由这些范围代签。load_native_01保留实际IP cut-through行为与TB错误预期导致的FAIL，已修复测试预期并保持退休/owner标准。所有原始attempt和SHA保留。

当前无重工具运行。L0/L1 PARTIAL；quant/G需要主控集中定义多个Context/future Ref/预约规则，问题未送达（无发送工具），见interface_question_to_controller.md。M003 L2–L5和M004后续完整目标未完成。

2026-10-11接续：主控答复quant-g-answer-20261011已真实送达，D-M003-QUANT-G-V2合同SHA已核验。此前未送达/待定义语句为历史状态；定义阻塞已解除，v2实现与验证开始，无新增PASS或成本授权。

## 2026-10-11 v2及门户代号实施进展

权威为D-M003-QUANT-G-V2与D-M003-PORTAL-GENERATION-01。当前quant/G合同SHA256为5b23da9216c588aea04b10314fbd733e938c98c3d6674f8ac6c9e66e5b3c3123；生命周期补充SHA256为6c3017999c056fd6ba8e6e7566381f4bc790765c8d1e4adf3bbd27c44e62bc5e。234f0f…是修订前历史身份，不能代表当前合同。

C/SV显式VERSION=2，cmd1024B/rsp512B及13BO不变；P/Q/L与future-dst扩展、LOAD/非使用字段零约束及service/view回显同步。transport真实首拍握手校验固定64B可信头，只有可信fresh g可在失败响应/安全cancel封闭时推进H_closed；软cancel和session切换不清高水位，跨view空闲仍传播cancel。

TaskReservation与PortalReservation分离typed预约和持久H_alloc。Controller预约最大128窗口的385个typed task与769个门户command，G分期保持全部G→LOAD→Q/L；未发送g不回收，typed未激活预约可重建。此处仅控制预约与syntax验证，实际full_run_task仍是旧C路径，generic source provenance和真实portal caller/hub未完成。

新增laya_parent_a_lease_v2，5336bit归一化实体key，1011bit acquire/865bit release handle。实际fullA一次父acquire，后view局部grant，中间不真实release；末view或安全cancel真实release。当前独立真实fullA测试通过，尚未接matrix服务、父首错/TaskDone及全tensor目标账本。

## 2026-10-11 新冻结局部验证

- codec_v2_02 PASS：四service、406mutation，独立6144B逐字节oracle。codec_v2_01编译失败保留于codec_v2_guard_01/driver.log，旧runner未冻结失败preimage，不能补称其具有完整冻结。
- transport_v2_02 PASS836cycles；最新版transport_generation_02 PASS1786cycles，accepted9/retired23/stale2。9类坏头超大g、10first-push cancel、partial/bad-tail可信g耗号、末响应读/cancel竞争、同session/新session恢复及跳号覆盖；20.442486s、peak1580948KiB、guard0/null。仅受控service端点，不代签真实hub/parent联动。
- load_native_v2_01 PASS18863cycles：14commands/replies、6cancel、2overflow、1AUX错误、3恢复；q AR26/R6146、AUX AR20/R400；35.675456s、peak1819492KiB。默认完整cache、四真实AMD converter与13BO owner，仍诊断数据/manual peers。
- matrix_binding_v2_01 static/pilot PASS56.545527/18.367958s，旧7命令6取消与K256/N2单view恢复范围保持；控制A/W端点，不证明多view父租约。
- reservation_03 PASS：128窗口/385typed/769门户票据、rows1..16的尾view、未发g不回收、同generation下一request重建与u64溢出；Controller仅syntax通过。host sizeof TaskReservation260B/GDownWindow264B/GDownPlan33936B，非RTL资源。
- parent_a_01 PASS10309cycles：真实完整dualA，3fills/3acquire/3release、9local views、7实体/覆盖拒绝、94464独立q字节比较，held末A return阻止release，窗口间cancel等external debt，same-session下一request恢复。23.679215s、peak1397844KiB、guard0/null。预量化诊断fixture不代签G/quant算术、真实source provenance、matrix联动或模型链。

所有上述结果仅适用于各自冻结输入；L0/L1 PARTIAL、L2–L5 NOT_RUN，M004未完成。新parent、matrix多view/首错、GATE同epoch跨窗口/分期、唯一持久hub及caller继续实施。无新OOC/P&R/上板。

## 2026-10-11 GATE tensor与真实matrix父view里程碑

`gate_tensor_04`取得局部PASS：128窗口/2048行同一GATE epoch，窗口写债、tensor READY、逐窗口读租约、跨窗口cancel及同session恢复闭合。它只覆盖metadata ledger；物理GATE writer/reader和GEGLU数值尚未接入该ledger。

`matrix_tensor_02`与重新冻结的`matrix_parent_current_01`通过后，`matrix_parent_views_07`取得当前真实resident/static/pilot PASS。9条新增rows4命令覆盖成功父、跨view空闲取消和同session下一request失败父；每view独立g，一次父A/W lease与一次父TaskDone，末view最后B后释放，失败父继续四view并以受控rank检查跨view最小值。累计2563个真实AW/W/B。中间view响应成功位已改为owner-retire握手锁存，避免writer退休清coverage后的误报。

成本分类更正：`matrix_parent_views_07/guard_pilot`在运行前没有取得≤120s的成功短pilot，也没有冻结速率或预计墙钟依据；`matrix_parent_views_04`起将`run_matrix_portal_binding.py`的pilot上限由120s直接改为600s，`_07`仍以pilot参数运行完整128440-cycle用例并耗时382.907547s。因此该次功能结果保留为冻结输入下的局部PASS，但执行分类/预算不合规，不能作为合规pilot或full成本证据。无需补跑历史。当前runner已恢复120s短pilot，并把完整用例改为显式full/3600s；full前写入pilot实测周期、秒/周期和保守墙钟估算，估算超帽即停止。

该批仍是基础接口与真实matrix父路径的局部证据。实际fullA/fullW cache、GATE payload接线、G分期、QUANT到父A、唯一持久hub/generated caller、L2/L3和当前完整CPU/实际CSim未闭合；L0/L1继续PARTIAL，L2–L5 NOT_RUN，M004继续。`gate_tensor_01..03`与`matrix_parent_views_01..06`失败证据保留。无新OOC/P&R/上板。

## 2026-10-11 物理GATE与G/QUANT分期里程碑

`gate_store_04`取得局部运行PASS：物理writer接tensor ledger，四个rows16窗口/64行共用一个GATE epoch，完整tensor执行10496个AW/W/B；末B后才READY。另含活动取消安全排空、错误binding/重复消费/读债及同session更大request恢复。202711 cycles、21.641107s、峰值1323428KiB。受控GATE字输入只签writer/store，不签真实GEGLU算术。

`gate_split_static_01`完成当前唯一canonical GEGLU、物理store、延迟QUANT和full dual-A的静态编译/展开；不作运行声明。`gate_split_04`进一步取得局部同runtime PASS：static 52.656369s，真实一行pilot 11769 cycles/32.550573s；full 758736 cycles/1054.961660s、峰值1326676KiB。四个G命令先完成64行与10496个AW/W/B，G阶段无AR/quant，完整tensor才READY；随后独立Q命令读取window0的2624个beats，完成16行/2624 half量化和fullA四个rows4 view的1312项检查，再释放GATE/A lease并取消清理。真实canonical GATE以及q/d/reciprocal/scale/fullA均与独立fixture gold比较。manifest SHA=`bb7309b0e22f1de7940a144e8e93269367953851441705ade1cfba14ed4b9809`，receipt SHA=`f8ad62afc4595dd7eb6d680b5cce1b4f5b6cb71d4381ea989ab6b47cb2ab9ad8`。

`gate_split_01..03`失败保留：前两项为TB组合ready同拍采样死锁；`_03`的static/pilot已过，但full进度打印间隔过大触发120s semantic-stall。`_04`只修复TB握手与guard进度可见性，没有改变DUT、gold或full覆盖。

matrix runner的超帽拒绝路径已由`matrix_cost_stop_branch_01`有界检查：合成3601s>3600s时写`COST_STOP/started:false`，最终manifest与receipt SHA一致且没有full工具产物。此项不运行Vivado、不代签matrix功能；`matrix_parent_views_07`预算DEVIATION继续保留。

本里程碑只证明实际canonical GEGLU多窗口同epoch→独立QUANT window0→fullA的局部链。其余Q/L窗口、LOAD→Q/L调度、真实fullW/matrix同runtime、唯一持久hub/generated caller、L2/L3及当前完整CPU/实际CSim仍待完成；L0/L1保持PARTIAL、L2–L5 NOT_RUN，M003/M004未完成。无新OOC/P&R/上板。

## 2026-10-11 真实父缓存matrix里程碑与停滞保护修复

`matrix_parent_cache_03`取得限定运行PASS：v2 matrix binding连接实际fullA/fullW cache，一个rows16父任务用四个独立generation的rows4 view执行。full 114182 cycles/1725.782300s、峰值1428584KiB；41984 stripes、167936个独立PS gold、16384个最终F32 gold，AW/W/B各2048，末B反压后才响应。中间view不真实release A/W，末view后A/W各真实释放一次；父覆盖`ffff`、TaskDone一次。单父只覆盖tensor前16/256行，tensor保持PARTIAL且publication0。manifest SHA=`e87ba8097dad18e54078ef18e964c4c45ccabd62f60cd29a1db8a2498c55231d`，receipt SHA=`2b51a19397dbade08bc8ab65c5ae69e35ec958ba6938e0434182fdf1bcbe1b3c`。

运行前按两次同数据通路单view实测较慢454.920886s×4×1.5得到2730s，低于3600s才启动full；static/pilot均在原帽内PASS。`matrix_parent_cache_01`和`_02`分别保留旧QUANT op与首父row0错误的拒绝证据，未进入目标matrix执行。

split进度日志与guard已修为按单调实际work推进；`gate_split_progress_guard_02`有界核1000条重复work不刷新、两次实际work增加可刷新，PASS，receipt SHA=`20857a4505379318c2ee0812c02d035324b7130c9df3ed227c8cd206bb68ebe4`。未重跑历史split full。

当前仍未把同runtime实际QUANT输出接到该父matrix；多父tensor覆盖/失败、其余Q/L、LOAD调度、hub/caller、L2/L3及完整CPU/CSim继续。L0/L1为PARTIAL，L2–L5 NOT_RUN，M003/M004未完成；无新OOC/P&R/上板。

## 2026-10-11 actual G/Q→父matrix组合入口与COST_STOP

`gate_quant_matrix_parent_03`冻结当前组合TB/RTL/IP/fixture：真实canonical GEGLU先执行四个rows16 G窗口，独立Q0生产真实fullA，随后计划接真实fullW和父matrix四view；A没有TB填充路径，并增加A/W acquire/release真实握手计量。当前static PASS（84.239673s、2741104KiB），同一batch no-wave profile的一行G pilot PASS（11773 cycles、63.410458s、975140KiB）。

完整工作量以上述已通过组件的758736+114182 cycles为冻结上界，pilot速率185.663 cycles/s，加10%余量得5172s，超过3600s。runner因此写`COST_STOP/started:false`，full未启动；manifest SHA=`f0c140708f014f31a99e166728c4e47a16e0a9ae62dca84c462763fa7a770525`，receipt SHA=`042347a390b73357108c20090326c59e2728db1ac756fbab37ad64b7c4cdc0ac`。`_01`旧成本逻辑误用分立墙钟3476s并启动full，工程在组合速率明确后于591.128178s主动停止，保留FAIL/sigterm原始证据；`_02`和`_03`修正后均不启动full。没有增加预算，也没有把static/pilot写成同runtime完整功能PASS。

`gate_split_progress_guard_03`有界PASS：重复work和三类recognized-prefix坏格式都不刷新120s停滞计时；真实work增长及其它合法阶段日志仍刷新。无Vivado功能声明。manifest SHA=`63bf56dfcb9a003a6487fed5cd6ecb6a22f984672a6a85e5c743baac58e6004b`，receipt SHA=`51084ae8eb12f366b7580cf8183ba419ccf31fbd0a8766ed17cc3838556489b8`。

当前同runtime实际G/Q→父matrix完整运行因原RTL墙钟帽为NOT_RUN_COST，实际连接只有static和G pilot证据。独立`gate_split_04`及`matrix_parent_cache_03`各自限定PASS继续有效，但不能拼接代签。L0/L1保持PARTIAL、L2–L5 NOT_RUN；多父、其余Q/L、LOAD调度、唯一hub/generated caller、L2/L3和完整CPU/实际CSim继续。
