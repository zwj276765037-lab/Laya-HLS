# E003：R003当前结果

F8在限定C++主机范围闭合。`controller_transaction_adapter_11`、`graph_sequencer_host_05`、`controller_transaction_lifecycle_04`、`producer_engine_controller_12`均PASS_SCOPED_HOST；聚合222/222 current、222/222 frozen、222/222 pair一致，64条编译/链接/执行命令exit0。生命周期负例证明合法非终态END后遇坏头或错绑定时无第三次END，旧tracker/scope保留，typed不退休，原合法非终态→终态与同session恢复仍通过。四项manifest/receipt分别为：

- adapter `de9cdf7bed1cd6df68070633855a195810e13d713513d5f839ae6288a6aec815` / `aa4a23c03d6e5817abb7467cc7ff29c0b527e05d974743523a219c55a4d760ed`；
- sequencer `e9f864ad6f9c555e082bf53ba34c36f041003f14081caab4bbeeac0b532ba495` / `76d15b21d390188bf3207ab9508ec5c90a61f15269a9dd4928e5843bb3a5f597`；
- lifecycle `ca62a56abdb7ec75cd275fdf81efa343167a1c754933ce59dad1cf36735a6b2b` / `5a5e8ecbedcd9e48214bf87bc97d29d539ea39fc12095d48ec456388a6fb482e`；
- producer `4f322bed32bc4c7ff79d6699dfe4a542107215386d56d0511d5678dc774ef8c5` / `c12539cde3cfc3a2c1c07ab3580513cbacdc2136fc6b96b8f5f6735abc183a5c`。

`controller_transaction_lifecycle_03`保留FAIL/-11：编译链接全过，测试把大型FullRuntime放栈上导致执行崩溃；`_04`改为静态测试对象后PASS，没有改DUT语义或覆盖失败记录。

`controller_transaction_adapter_hls_02`相对`_01`的Compile/Link指令46,048→34,864（-24.29%），Unroll step4 117,368→80,707（-31.24%），Loop/function optimization 192.44s→81.96s（-57.41%）。32/32 current/frozen/pair一致，host build/run exit0。新attempt仍在后续硬件构建阶段触发120s semantic_stall，585.645036s停止，峰值owned RSS 5,963,856KiB；无RTL candidate或端口证据。manifest=`25818dfddab7bdc838f275378ecb60576401fbf34bf560937baa4b9b4dc66858`，receipt=`1ab76fe110a1385c3092b9aabb032cdd76beff78f3bdc53ffc442620d36351f2`。聚合核查SHA256=`f816875f23294032a331adf887ef9445f506047f3e6e0cd00532ca64ce9597b6`。


---
Published: 2026-10-12T05:36:42.909927+00:00
Publication: Pa5307cd552bc49e4bdf0f7bd68148e92
