# E003当前结果：2026-10-12 Graph lifecycle split host

## 当前PASS_SCOPED_HOST

`graph_lifecycle_split_host_02`三条命令均exit0：独立Python oracle 0.066818s、C++ build 12.494814s、测试执行0.067266s。launcher记录CPU0–3、nice19、idle I/O、MemAvailable 420038212KiB；55/55 current、55/55 frozen、55/55声明pair一致。LAX1完整512B与独立oracle逐字一致，LAC1 roundtrip、坏magic清旧completion、错action ordinal保留pending、旧source slot version拒绝及16类未实现action无副作用拒绝均通过。

实际host组合在同一 `FullRuntime` 执行B1/S64 LayerNorm action的四个rows16窗口：4个producer request、10个provenance request、CLAIM→BEGIN→producer→END→PUBLISH、4次唯一typed退休、4个source窗口关闭并发布完整owner。program/lifecycle source闭包为3/14源，约定禁入项为空。

receipt=`d3a4ca31e56691975c3e60d50a9aef8e9fdbb794c7ab2b70bcd0a0a7afeeb73e`；manifest=`b580be22f4d29ca6aac48a3f3d0a9102a8be49a6154c593e4a3498d559f8830b`；run.log=`7ee5f1e797b9a099bf3528e1db87cedbd537e25117c01dac8dafc81261b8349a`；oracle=`6ccf07108e931dc5074b4195d84a1d175d32eb3477a813d9e6cd214a8cd914c0`；verification=`f6ccf3e3270e82f20eb893ea4b010f00c193e2e62713be9698c0fa3100f589a9`。

## 独立current回归

`source_provenance_06`为PASS，2.184783s/83212KiB，14/14 current/frozen/pair一致；覆盖B1/B2 attention、ordinary、QKV atomic pair、RoPE inherited V及scorer LN→FC1→GELU epoch链。receipt=`64061933359de321e6ce7f7e94b2469e19bb5ba93490b3f3fbb128f44ffaf63f2`，manifest=`a3ed779be3fd3df916e2dd3f3894a3cce0a265ffa202e256e171892c6b77f11b`，run.log=`5cd396763b1b94dc75f5ca230215b1e6232dcb7e4764e5cbe638f12c94232cd8`。该旧runner只记录24GiB子进程RLIMIT_AS及每命令120s timeout，不代签外层CPU/nice/I/O/MemAvailable。

## 证据边界

本轮没有program/executor HLS top或RTL、action FIFO真实depth2反压与consumer末拍互锁、真实cancel/partial failure/旧返回恢复、same-runtime generated LayerNorm AXI master→monitor/hub、完整17类action、最终13BO请求、联合资源/性能、OOC/P&R或上板证据。C009仍为部分实施，C008/C010整体待验证；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成。

---
Published: 2026-10-12T11:32:27.657617+00:00
Publication: P62d1df46ced0401da3a7b7a58a4679e7
