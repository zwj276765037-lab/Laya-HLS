# Controller F8主机闭合与adapter HLS成本结果

回复`controller-transaction-f6-f7-review-20261012`；范围M003/SM003/E003/R003，沿用D-M003-CONTROLLER-INTERNAL-SPLIT-01及原预算。

## F8受影响主机回归

F8已按审核要求修复：Controller每轮END重试都单独取得本轮completion flags，只有同时含`FRAME_COMPLETE|BINDING_OK`且不含`LOCAL_REJECT`的远端END才读取response；坏头、错绑定或缺可信标志立即退出，保留tracker/scope，不发送第三次END，不退休typed task。

四项当前冻结结果均为PASS_SCOPED_HOST：

- `controller_transaction_adapter_11`：49/49 current/frozen/pair，7条命令exit0；manifest=`de9cdf7bed1cd6df68070633855a195810e13d713513d5f839ae6288a6aec815`，receipt=`aa4a23c03d6e5817abb7467cc7ff29c0b527e05d974743523a219c55a4d760ed`。
- `graph_sequencer_host_05`：55/55，2条命令exit0；manifest=`e9f864ad6f9c555e082bf53ba34c36f041003f14081caab4bbeeac0b532ba495`，receipt=`76d15b21d390188bf3207ab9508ec5c90a61f15269a9dd4928e5843bb3a5f597`。
- `controller_transaction_lifecycle_04`：59/59，27条命令exit0；marker含`end_bad_header_abort=1 end_wrong_binding_abort=1 no_third_end=2 tracker_preserved=2`。两个真实Controller负例均为合法非终态END后第二次分别收到坏头/错binding，核立即返回、无第三次END、tracker/scope保留、source readers仍为0、destination未发布、typed不退休；原合法非终态→终态和同session恢复继续通过。manifest=`ca62a56abdb7ec75cd275fdf81efa343167a1c754933ce59dad1cf36735a6b2b`，receipt=`5a5e8ecbedcd9e48214bf87bc97d29d539ea39fc12095d48ec456388a6fb482e`。
- `producer_engine_controller_12`：59/59，28条命令exit0；manifest=`4f322bed32bc4c7ff79d6699dfe4a542107215386d56d0511d5678dc774ef8c5`，receipt=`c12539cde3cfc3a2c1c07ab3580513cbacdc2136fc6b96b8f5f6735abc183a5c`。

聚合为222/222 current、222/222 frozen、222/222 pair和64条命令exit0。`controller_transaction_lifecycle_03`原FAIL/-11保留：编译/链接均通过，执行因测试把两个大型FullRuntime放栈上崩溃；`_04`只把负例runtime移到静态存储，未改DUT语义、工作量或断言。

## adapter HLS编译成本

normalized request decoder现直接调用三套既有codec公开的字段语义校验，移除内部COMPUTE/PROVENANCE/PRODUCER各一次完整wire encode→decode往返；外部wire framing/reserved检查不变。受影响host结果均在上述当前身份通过。

`controller_transaction_adapter_hls_02`为FAIL/semantic_stall：32/32 current/frozen/pair，host build/run均exit0；manifest=`25818dfddab7bdc838f275378ecb60576401fbf34bf560937baa4b9b4dc66858`，receipt=`1ab76fe110a1385c3092b9aabb032cdd76beff78f3bdc53ffc442620d36351f2`。相对`_01`：

- Compile/Link 46,048→34,864，-24.29%；
- Unroll step1 257,068→180,667，-29.72%；
- Unroll step4 117,368→80,707，-31.24%；
- expression balance 4,753→3,716，-21.82%；
- Loop/function optimization 192.44s→81.96s，-57.41%。

新attempt有实质成本下降，但仍在后续硬件构建阶段连续120s无可观察语义进展；585.645036s停止，child=-9，peak owned RSS 5,963,856KiB，无RTL candidate/端口证据。该profile不原样重试，不把停止解释为永久编译死锁或硬件不可实现。

聚合核查：`project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_f8_adapter_hls_verification_20261012.json`，SHA256=`f816875f23294032a331adf887ef9445f506047f3e6e0cd00532ca64ce9597b6`。模块design/results已同步，三摘要原生publication=`Pa5307cd552bc49e4bdf0f7bd68148e92`，A002状态已报告。

F8请按本次冻结C++主机组合范围审核；adapter HLS仍未生成RTL，不代签真实depth2背压、production AXI/store helper、末B/adapter fence、完整请求、资源、时序或性能。C009继续部分实施；C008/C010整体集成未闭合，C012既往限定关闭不扩大。下一步继续更强的流式/逐拍adapter切分，或推进依赖独立的production master/store提交→monitor/hub→source lease→Q/fullA。

L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成；5172s组合profile不重启，无新OOC/P&R/上板，G余2338.224019s不变。
