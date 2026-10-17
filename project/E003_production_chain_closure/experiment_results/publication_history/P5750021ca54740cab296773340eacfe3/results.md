# E003当前结果：2026-10-12

## 真实LayerNorm→QUANT/fullA与F9

`layernorm_quant_source_03`保持PASS_SCOPED_RTL：static77.547525s，rows1 pilot47308cycles/57.410899s，同runtime rows16 LN→持久hub→实际共享Q/fullA为659334cycles/753.504079s。真实LN AXI为AR/R=16/1024、AW/W/B=16/1024/16、有效WSTRB65536B；全量16384 F32 LayerNorm、16384 INT8及512 FP16 scale独立gold通过。F9四个错请求绑定与两个错completion隔离通过；owner只有rows16，caller仍由TB构帧。

## 流式adapter生成

`controller_transaction_adapter_hls_03`工具exit0，370.877336s/5987504KiB，实际生成248份Verilog/16份DAT。独立top审计确认24/24 FIFO信号、其中18/18外部协议，顶层无ap_ctrl_hs；原runner误把内部helper握手当顶层端口的FAIL保留。HLS估算BRAM18K49/DSP29/FF53762/LUT190633/URAM0，不是OOC/P&R或联合资源。旧`controller_transaction_adapter_rtl_01` compute pilot51308cycles PASS，八case combined full因1M周期帽COST_STOP/started:false。

## F10 completion真实消费门控

新增`laya_controller_transaction_adapter_shell_v1`：请求24拍收齐后关闭后继request，直到completion FIFO真实consumer `read && empty_n`累计16拍才重新开放。`controller_transaction_adapter_rtl_03`编译一次并独立复位运行八个case：compute51338、begin52102、producer55242、wait_end62469、wrong_end62183、bad_producer54499、cancel_producer44862、end62475cycles，全部PASS。每项在旧completion消费14拍和15拍后各停读12周期，后继descriptor和外部协议均不前进；第16拍真实消费后才继续并最终清空八FIFO。static112.119966s/4550912KiB；case 15.987420–17.779543s/峰值856644–856908KiB。

独立核查确认305/305 current/frozen/pair、43项引用、16份DAT落位及九个guard/policy全部通过。manifest=`1e0a3baa17545ddd86bcb999d6175a423540c57cea8a64a862eafafd62406d32`，receipt=`7a0281acdf386f8ec8ff499f64308c4a196cb53492c0a3bd8ef73b62712bc096`，verification=`05a22919e8f7e46fc695fcee36324f83cbd313df1ba609a8bc69ad00eeb2ab8d`。未满足外层launcher的`rtl_02`在工具启动前拒绝并保留。分区registry更新为`generated_top_verified_rtl_bounded_protocol_subsets`，SHA=`69bbb69d8718214dc1132b95575a1d05e7faf9bec9a8e4be3ec483ac1b505fd6`。

## 边界

F10只在实际shell与八个独立协议事务范围具备证据，不能把独立运行拼成same-runtime graph。真实sequencer、BEGIN→producer→completion→END、typed唯一退休、LayerNorm master/monitor/hub/source lease整链、完整tensor/多窗口、部分提交/故障取消恢复、多role/QKV、LOAD/MATRIX、普通↔GATE双向切换、当前完整CPU/实际CSim、13BO完整请求和联合资源/性能仍待。C009部分实施，C008/C010整体未关闭；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成。无新OOC/P&R/上板/agent或预算，G余2338.224019s。

---
Published: 2026-10-12T10:20:27.089132+00:00
Publication: Pe3df6816249a4421b4196a75bed1f01b
