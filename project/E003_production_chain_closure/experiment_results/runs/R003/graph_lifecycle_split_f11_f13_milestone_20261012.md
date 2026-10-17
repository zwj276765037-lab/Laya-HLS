# Graph lifecycle F11–F13 主机修复里程碑（2026-10-12）

范围：M003/SM003/E003/R003，沿用 D-M003-GRAPH-LIFECYCLE-SPLIT-01；唯一实现根仍为 E002/experiment。

## 结论

`graph_lifecycle_split_host_03` 为 **PASS_SCOPED_HOST**。F11、F12、F13 在当前冻结 C++ program/lifecycle/transaction-adapter 组合及其有界负例范围具备修复证据；原 `graph_lifecycle_split_host_02` 成功路径和 `source_provenance_06` 独立软件 ledger PASS 保持原身份。

这不代签 program/executor HLS top、action FIFO consumer 末拍门控、真实 generated LayerNorm/hub 同 runtime 连接、硬件错误恢复、完整 graph、最终 13BO 请求或资源/时序。

## F11：action 清理状态

`FullRuntime` 现保存完整活动 action 键、source/output、首错、CLAIM/PUBLISH、BEGIN scope、source lease 及 INVALIDATE 的远端/本地清理状态。安全终态不再由 `!generated_store.active` 推导。

动态负例执行四个真实 host LayerNorm 窗口及四次 typed 退休后，让 PUBLISH 返回匹配终态 E_BUFFER，再让首次 INVALIDATE 返回匹配非 OK 且未排空。首次 completion 不含 SAFE_TERMINAL/REMOTE_DRAINED，action 与 cleanup 状态保留，program pending 不释放。相同 action 重试只发送一笔 INVALIDATE；其匹配 OK、drained、terminal 后才完成本地 invalidate并报告安全错误终态。PUBLISH 首错不被 cleanup 状态覆盖，typed 退休保持四次且不重复。

另有两个独立负例：

- BEGIN 返回完整绑定但非 OK、未排空：source reader、generated tracker、BEGIN/action 状态保留，completion 不安全。
- BEGIN 返回完整绑定终态错误，但测试在响应前破坏本地 reader 状态使 source release 失败：source lease 与 tracker 仍保留，completion 不安全。

这两例证明保留和阻止后继，不外推为其后的完整硬件恢复。

## F12：LAC1 与成功 geometry

LAC1 completion 现在拒绝 Status 超出 OK..E_INTERNAL、拒绝 LOCAL_REJECT+OK。decode 使用临时对象，头或语义校验失败均保持调用者输出为默认无可信 flags/binding/slot。

program 的 NORM 成功准入新增 owner batch=255、row0=0，以及精确退休数 `B*ceil(S/16)`。动态负例覆盖 LOCAL_REJECT+OK、非法 Status、非法 slot 后输出清零、错 batch、错 row0 和自洽但不足的退休数；均不提交 PC/slot。原正确 B1/S64 四窗口完成仍通过。

## F13：失败 request 锁存

program 在 `first_error != OK` 时拒绝普通 `prepare_norm`。安全错误 LAC1 被完整绑定消费后，当前 request 再次 prepare 不增加 ordinal、不生成 action、不改变 slot。新的 accepted-request `begin` 清除 request 错误态并保留 action 高水位，下一 action ordinal 严格递增。

## 运行与身份

launcher：CPU0–3、nice19、idle I/O、MemAvailable 420411544KiB（门槛 201326592KiB），PASS。每个子进程保持 24GiB RLIMIT_AS 与 1800s timeout；本 runner 没有 owned-RSS 采样或 120s 语义进展 guard，不把它描述成 HLS/RTL guard。

五条命令均 exit0：

- Python byte oracle：0.066243s
- 成功路径 build/run：12.753270s / 0.067232s
- F11–F13 build/run：12.453885s / 0.066087s

成功 marker 已收窄为动态1类 unsupported 与静态 registry16类；新错误回归实际枚举其余16种 kind，全部在协议/编号/owner副作用前 LOCAL_REJECT。

独立核查：56/56 current、56/56 frozen、56/56 pair；128/128 manifest/receipt SHA 引用匹配，五条命令及两个 PASS marker匹配。

交付 SHA256：

- input manifest：`914777b50062afa1711a8cabc9040017923a4f0f3bc6d6d69fca5129f32519e9`
- receipt：`dcb798795109e8fdbd97479f5458cb3bbe95e8c312358955ee7dac0fa5d9a72b`
- success run.log：`8a385909950b98d20ce3b3b5780effa7d3ef5392d318da2e9b7c3d5322a7ea76`
- error run.log：`c3cf55552cf4cf4f10f0c7420ed1093e844d2d058652a01b70e0e6f6f47337d0`
- verification：`ab446e35f693279694713c17c3785fe5ea2c5fed51fefd3fabc3829a52753c0c`

## 后续

工程继续 accepted-request bootstrap、program/executor top 与 action completion consumer 门控。相关 top 生成只使用本修复后的身份；旧 graph HLS 失败和所有旧 attempt 保持。真实 program→executor→F10 adapter→LayerNorm master/monitor/hub→source lease→Q/fullA 及完整错误恢复仍待。

C009 仍为部分实施，C008/C010 整体待验证；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合 full NOT_RUN_COST、M003/M004 未完成。无新 OOC/P&R/上板、agent 或预算，G OOC 余 2338.224019s。
