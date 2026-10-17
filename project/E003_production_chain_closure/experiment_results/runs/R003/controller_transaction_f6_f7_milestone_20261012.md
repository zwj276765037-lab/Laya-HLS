# Controller transaction F6/F7 受影响主机里程碑

回复 `controller-transaction-split-host-review-20261012`。沿用 `D-M003-CONTROLLER-INTERNAL-SPLIT-01`，未改ABI、LTX1/LTC1大小、typed任务、数值、shape或预算；本轮未启动HLS/Vivado。

## F7：坏completion头先清旧输出

`controller_transaction_codec.cpp` 的completion decode现在在任何头检查前执行默认对象复位。普通codec与 `LAYA_TRANSACTION_SEQUENCER_CODEC` 两种构建都以预置可信成功/LOCAL_REJECT completion覆盖坏magic、version、beat数、kind、status、unit、flags和保留字；所有拒绝均清flags、binding、seq与Context。合法完整绑定、非OK且未排空的completion继续保留为非终态；另拒绝 `LOCAL_REJECT + Status::OK`。

`controller_transaction_adapter_10` PASS_SCOPED_HOST：49/49 current、frozen、pair一致，7条命令exit0。manifest SHA256=`fcf206a5d2a09a19b245a05c19803e7a5a092eb39c44375e1f6e7183accffc7c`，receipt SHA256=`bcf94858dab63762d2e6fde355e70b017e03260b15f4b447bdc8842ff512a5ca`。

## F6：producer本地拒绝统一收束source lease

新增 `accept_layernorm_local_reject`。只有完整绑定、外部producer请求未发出、`issued_store_bytes=0` 且tracker无既存首错时接受本地拒绝；真实 `full_release_read_owner` 成功后才清source lease标志，destination保持INVALID/未发布。Controller把本地拒绝和正常completion统一进入lease收束，并比较内部收束结果与transaction result的status/detail/bad。

旧BEGIN scope继续由匹配END关闭。sequencer对完整绑定但 `!drained || scope_active` 的END用相同END身份串行重试；错绑定/坏返回保留tracker并退出。只有完整绑定、drained且无scope的安全终态才清tracker并唯一typed退休。

`controller_transaction_lifecycle_01` PASS_SCOPED_HOST：实际Controller与 `laya_command_provenance_adapter` 逐拍组合运行。BEGIN成功后cancel触发producer LOCAL_REJECT，外部producer FIFO零beat、issued0、source readers归零、destination未发布；首个END未排空/scope-active，第二个同身份END终态。typed恰退休一次；同一 `FullRuntime` 以request_id602/generation32/epoch2恢复。59/59 current、frozen、pair一致，27条命令exit0。manifest SHA256=`72348971d0220d72fbc0471b714fd1e392638576518b04c90d27876c24015e03`，receipt SHA256=`e960e25a8029bb7647ca6ba69759a70bc2d8a057f16a22c459d7da7dc52d9e88`。

## 受影响回归与身份

- `graph_sequencer_host_03` PASS_SCOPED_HOST：55/55匹配；保持20源闭包、两条transaction FIFO/6信号及外部协议codec排除。manifest=`ac4050ab5590a11fc08dea9b073e214006b2b6a0bb340def825c48f00ecb3e15`，receipt=`4f832597c642753ef8c69a9f3e657d1ee28e549e68b852b8cbbb3a53dbd6800b`。
- `producer_engine_controller_11` PASS_SCOPED_HOST：59/59匹配；保持正常成功、部分失败、source lease与retirement回归。manifest=`0eb95d7ee8c5ec3359f3a62865562b10a92760a00762d244fd7e94c4e6674d65`，receipt=`b236e6626d2fd577793ef150ab351cbc298835733b976aa7b6f779bd985569a9`。
- 聚合 `controller_transaction_f6_f7_verification_20261012.json` SHA256=`25eba1c92d28d047b6f1c0283472110c77d6b89d062ddc6fd9a05c306f66e203`：222/222 current、222/222 frozen、222/222 pair，64条命令exit0。四个launcher均记录CPU0–3、nice19、idle I/O和MemAvailable门通过。

模块 `source/design.md`/`results.md`已同步；E003三摘要已原生发布为 `P78369405568248c681babf5ee355a95c`，A002阶段状态已更新。

## 证据边界与继续项

F6/F7仅在当前冻结C++主机组合、实际Controller分支和受影响codec/producer回归范围闭合。既有 `controller_transaction_adapter_hls_01` 保持FAIL/semantic_stall，receipt SHA256=`04a4ff30002a55d98746afa4551a6f43c0fa752fd5f074206f0563993d4969b8`，本轮未原样重试。

当前没有修复后sequencer/adapter RTL、真实depth2并发反压、production AXI/store helper、末B/adapter fence、完整请求、联合资源、时序或性能结论。C009继续部分实施，C008/C010整体集成仍待；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成。

工程继续寻找有实质编译成本改善的分区生成入口，并推进独立production master/store提交与adapter fence因果，再接LayerNorm engine→monitor/hub→source lease→Q/fullA。不重启未改善的旧HLS profile。\n