# Controller adapter F10 completion 消费门控里程碑

范围：M003/SM003/E003/R003，沿用 `D-M003-CONTROLLER-INTERNAL-SPLIT-01`、LTX1/LTC1、三对外部协议 FIFO 和原资源帽。结论为 **PASS_SCOPED_RTL_INDEPENDENT_PROTOCOL_CASES**；建议主控仅在本次真实 shell/独立协议用例范围关闭 F10。它不证明真实 graph sequencer、LayerNorm/hub 同 runtime 整链或完整请求。

## 实现

新增 `laya_controller_transaction_adapter_shell_v1.sv`，直接包住 HLS_03 实际生成的 `laya_command_provenance_adapter`。shell 在真实 request FIFO 出端握手上计24拍；当前请求收齐后关闭 adapter 的 request `empty_n/read`。只有 completion FIFO 的真实 consumer `read && empty_n` 累计16拍，才在下一周期重新开放后继请求。adapter 写入最后一个 completion 字不再作为事务退休依据。原 adapter、24拍/16拍 schema、八个 depth2 FIFO及Host ABI均未改变。

测试在后继descriptor前两拍已经占满输入FIFO时，分别消费旧completion的前14拍和前15拍并持续停读12周期；两处都要求 `tx_reads` 停在当前24拍、后继外部协议零拍、输入FIFO保持两拍、旧completion头稳定。真实最后一拍消费后才允许后继两拍越过出端，随后继续原cancel cleanup或本地拒绝并核全部FIFO清空。

## 运行结果

`controller_transaction_adapter_rtl_02`在任何重工具启动前因launcher未满足CPU affinity/nice/ionice而拒绝，只有 `launcher.json`；该失败记录保留。`controller_transaction_adapter_rtl_03`使用CPU0–3、nice19、idle I/O和MemAvailable门，复用HLS_03的248份Verilog/16份DAT，编译一次后对每个case独立复位运行：

| case | cycles | wall time (s) | verdict |
| --- | ---: | ---: | --- |
| compute | 51,338 | 16.895465 | PASS |
| begin | 52,102 | 16.384725 | PASS |
| producer | 55,242 | 16.977797 | PASS |
| wait_end | 62,469 | 17.380377 | PASS |
| wrong_end | 62,183 | 17.190927 | PASS |
| bad_producer | 54,499 | 16.832927 | PASS |
| cancel_producer | 44,862 | 15.987420 | PASS |
| end | 62,475 | 17.779543 | PASS |

static为112.119966s、峰值4,550,912KiB；八项case峰值856,644–856,908KiB。九个guard均child0/trigger null；全部子进程policy为CPU0–3、nice19、idle I/O，墙钟、RSS、MemAvailable和每case 1Mcycle帽均满足。每项独立120s运行不是重启原 `RTL_01` 被1M总周期帽拒绝的八case组合，也不把独立运行拼成同runtime graph。

## 身份与边界

独立核查在目录登记前确认305/305 current/frozen/pair和43项manifest/receipt引用全部匹配，16份DAT落位逐SHA一致；八case receipt、tail14/tail15断言、launcher政策及运行后无本项目重工具均通过。F10在该shell与八个独立协议事务范围具备实现和动态证据。

仍未连接真实 graph sequencer；producer/completion/远端回复仍由TB fixture驱动。本结果不签生产caller的BEGIN→producer→实际completion→END、typed唯一退休、真实LayerNorm master/monitor/hub/source lease、完整tensor、多窗口、部分提交/故障恢复、完整CPU/实际CSim、13BO完整请求、联合资源、时序、P&R或上板。C009继续部分实施，C008/C010整体不关闭；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成，G余量与原预算不变。

## 交付SHA

- `controller_transaction_adapter_rtl_03/input_manifest.json`: `1e0a3baa17545ddd86bcb999d6175a423540c57cea8a64a862eafafd62406d32`
- `controller_transaction_adapter_rtl_03/receipt.json`: `7a0281acdf386f8ec8ff499f64308c4a196cb53492c0a3bd8ef73b62712bc096`
- `controller_transaction_adapter_f10_verification_20261012.json`: `05a22919e8f7e46fc695fcee36324f83cbd313df1ba609a8bc69ad00eeb2ab8d`
- `controller_transaction_adapter_rtl_02/launcher.json`: `a1c0cff78e1fbbc4caca6a96dab54d4c94d20d934660fb0352f493c4534512bf`

## 分区登记

运行证据冻结后，`config/production_hls_partitions.json`把adapter状态更新为`generated_top_verified_rtl_bounded_protocol_subsets`，登记F10 shell、RTL_03和独立核查路径；没有修改冻结attempt。当前registry SHA256=`69bbb69d8718214dc1132b95575a1d05e7faf9bec9a8e4be3ec483ac1b505fd6`。登记后核查仍为305/305 pair一致，registry不在该attempt闭包内；`controller_transaction_adapter_f10_catalog_verification_20261012.json` SHA256=`968ee114332370d5dc499235ca6eb6100499f11d54a3af6ce08dfcd76b2bc34e`。
