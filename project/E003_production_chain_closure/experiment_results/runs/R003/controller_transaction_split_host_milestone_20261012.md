# Controller normalized transaction / graph sequencer 主机里程碑

回复 `controller-internal-split-answer-20261012`。工程已按 **D-M003-CONTROLLER-INTERNAL-SPLIT-01** 实施当前主机闭包，未改变13BO/control ABI、wire v2、typed任务、数值、模型、shape或预算。

## 实现映射

- 新生产 top `laya_typed_q8_forward_graph_sequencer` 只持有 `transaction_request`/`transaction_completion` 两条512-bit FIFO，共6根生成信号。完整PC、层/shape/task/view展开、NumericIdentity、Task/Ref预约、高水位、BEGIN/END、owner事件和唯一typed退休仍在sequencer。
- `laya_command_provenance_adapter` 持有compute/provenance/producer三对既有协议FIFO共18根信号，每次只执行一笔COMPUTE、PROVENANCE或PRODUCER事务。
- 内部LTX1/LTC1为固定小端schema，请求1536B/24拍、完成1024B/16拍、单inflight。`config/graph_sequencer_sources.cmake`含20个生产源，明确排除三套外部协议codec和三套HLS exchange。
- LayerNorm路径由sequencer展开为BEGIN→PRODUCER→END三笔事务。BEGIN后producer若因cancel被adapter本地拒绝，sequencer生成零提交失败TaskDone并继续匹配END收束旧scope。END/RELEASE/INVALIDATE自动带`CANCEL_CLEANUP`。
- normalized completion的任何语法或binding拒绝会清空整份completion，防止失败后保留可信flags或binding字段；合法、完整绑定但未排空的provenance错误仍作为非终态返回。

已更新 `config/production_hls_partitions.json`、`config/full_module_registry.json` 和模块 `source/design.md` / `source/results.md`。graph sequencer当前登记为`host_validated_hls_generation_pending`。

## 冻结运行

### graph_sequencer_host_02 — PASS_SCOPED_HOST

- CPU0–3、nice19、idle I/O；launcher MemAvailable通过192GiB门。
- 冻结20个生产源与递归include，共55项文件；55/55 original/frozen、current/original和内容SHA一致。
- `forbidden_sources=[]`；三套外部codec/exchange均未进入闭包。
- build+run 14.241875s，覆盖compute成功、stale completion flags清零、cleanup flag、未排空非终态、producer local reject及graph top链接。
- manifest SHA256：`7821638bb603945bb122c0f0977721df3136397ef27092e7571ed784f5e183b7`
- receipt SHA256：`783ba3f6d1a81d1e14d1be45169da293d219447eddc2dcb50efff38391d1b385`

### controller_transaction_adapter_09 — PASS_SCOPED_HOST

- 49/49 original/frozen、current/original和内容SHA一致；7条命令全部exit0，总用时10.174794s。
- C++ codec、独立Python byte oracle、adapter及sequencer-only codec均PASS。
- adapter marker核三类事务、18根外部协议信号、partial response cancel、cancel local reject、cleanup END和4类rejected completion全部清零。
- manifest SHA256：`17d5adf55c2e7e1f55efc6d47fb73743d0f59aa5a5cb6ef4cee17196ae06054d`
- receipt SHA256：`6002a91c477960097a0462591f256eb8a0d979784e68db3bdb2593fec4c3cfc5`

`controller_transaction_adapter_07`保留FAIL：原adapter测试仍要求normalized decoder拒绝后的错误raw key可见，与新增completion整份清零安全规则冲突，adapter test进程exit -6；codec/oracle/sequencer codec当时均已通过。测试随后改为核所有可信flags和binding字段归零，不改变协议、成功路径或工作量。`_08`与`graph_sequencer_host_01`是登记映射更新前的修复后PASS，也保留原身份。

## 范围与下一步

本里程碑只证明C++主机闭包、normalized transaction语义和sequencer不静态引用外部codec/exchange。未证明HLS RTL、真实depth2并发反压、production AXI/store提交、adapter pending/fence、完整请求、联合资源、时序或性能。

工程继续原授权串行执行：先完成受影响`generated_store_monitor_08`，再运行`controller_transaction_adapter_hls_01`，随后建立并运行graph sequencer HLS入口；通过后连接当前LayerNorm engine与真实master→monitor/hub→source lease→Q/fullA。无新增OOC/P&R/上板，5172s组合profile不重启。

L0/L1保持PARTIAL，L2–L5 NOT_RUN，组合full保持NOT_RUN_COST，M003/M004未完成，G OOC余2338.224019s不变。
