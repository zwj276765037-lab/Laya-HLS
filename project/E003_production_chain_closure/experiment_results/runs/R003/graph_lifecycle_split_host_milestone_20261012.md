# Graph lifecycle split 主机里程碑

回复：`graph-sequencer-structural-answer-20261012`  
范围：M003/SM003/E003/R003；按 `D-M003-GRAPH-LIFECYCLE-SPLIT-01` 实施，不改13BO/control ABI、LTX1/LTC1、数值、typed任务或预算。

## 结论

`graph_lifecycle_split_host_02` 取得 **PASS_SCOPED_HOST**。已建立并登记 LAX1 512B/8拍请求与 LAC1 256B/4拍完成、17类action映射、program/executor持久状态和两个独立source闭包。当前只实现完整 B×S 的 NORM/LayerNorm executor子集；本次实际运行 B1/S64 四个rows16窗口。其余16类action均在Task/Ref预约、owner变化和协议副作用前明确拒绝。

本次没有生成 `laya_graph_program_sequencer` 或 `laya_task_lifecycle_executor` RTL，不声明action FIFO真实depth2反压、取消/部分提交/旧返回恢复、同runtime真实LayerNorm master→monitor/hub、完整17类graph或最终13BO请求完成。

## 实现与受控运行

- program独占PC、下一action、slot handle/version和单调action ordinal；完整绑定、可信、安全、drained且typed已退休的成功LAC1才提交slot并推进PC。错ordinal保留pending action。
- executor独占身份、Task/Ref/epoch预约、高水位、owner/lease、BEGIN/producer/END/fence和唯一typed退休。当前B1/S64运行逐窗口执行CLAIM→BEGIN→producer→END，最后PUBLISH。
- source slot/version在当前子集按source Ref epoch核验；旧版本拒绝。没有活动generated tracker时失败路径才尝试INVALIDATE/本地失效；活动tracker保留。
- Python独立构造完整512B LAX1并与C++ encoder逐字比较；LAC1 roundtrip和坏magic清旧completion通过。
- 实际host组合产生4个producer request、10个provenance request、4次唯一typed退休、4个source窗口关闭并发布完整owner。

## 证据身份

`graph_lifecycle_split_host_02` 三条命令均exit0：oracle 0.066818s、build 12.494814s、run 0.067266s。launcher为CPU0–3、nice19、idle I/O、MemAvailable 420038212KiB，门限201326592KiB。55/55 current、55/55 frozen、55/55声明pair一致；program/lifecycle闭包分别为3/14源，约定禁入项为空。

- receipt：`d3a4ca31e56691975c3e60d50a9aef8e9fdbb794c7ab2b70bcd0a0a7afeeb73e`
- manifest：`b580be22f4d29ca6aac48a3f3d0a9102a8be49a6154c593e4a3498d559f8830b`
- run.log：`7ee5f1e797b9a099bf3528e1db87cedbd537e25117c01dac8dafc81261b8349a`
- independent oracle：`6ccf07108e931dc5074b4195d84a1d175d32eb3477a813d9e6cd214a8cd914c0`
- verification：`f6ccf3e3270e82f20eb893ea4b010f00c193e2e62713be9698c0fa3100f589a9`

`source_provenance_06`另作当前软件ledger回归：PASS，2.184783s/83212KiB，14/14 current/frozen/pair一致；覆盖B1/B2 attention、ordinary、QKV atomic pair、RoPE inherited V及scorer LN→FC1→GELU epoch链。receipt=`64061933359de321e6ce7f7e94b2469e19bb5ba93490b3f3fbb128f44ffaf63f2`，manifest=`a3ed779be3fd3df916e2dd3f3894a3cce0a265ffa202e256e171892c6b77f11b`，run.log=`5cd396763b1b94dc75f5ca230215b1e6232dcb7e4764e5cbe638f12c94232cd8`。该旧runner只记录24GiB子进程RLIMIT_AS及每命令120s timeout，不扩为外层launcher策略证据。

## 下一步

实现真实program/executor HLS top和program bootstrap/accepted-request握手，分别保持闭包隔离；补action层真实consumer末拍门控，与F10的24/16拍事务门控分开验证。先连接真实program→executor→F10 shell/adapter→LayerNorm master/monitor/hub，从真实completion构造END并唯一退休，再复用既有source lease→Q/fullA gold。错误路径补末1/2拍停读、后继action已排队、两层depth2背压、活动cancel、partial producer failure、非终态END及错旧返回后的保留与恢复。

C009仍为部分实施，C008/C010整体待验证；既有F6–F10及LayerNorm→Q限定结论不扩大。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成。当前无本项目重工具；不重跑旧graph top、不加帽、不新增OOC/P&R/上板、agent或预算，G OOC余2338.224019s不变。用户允许持续卡住时采用5.6-sol，本轮未切换。
