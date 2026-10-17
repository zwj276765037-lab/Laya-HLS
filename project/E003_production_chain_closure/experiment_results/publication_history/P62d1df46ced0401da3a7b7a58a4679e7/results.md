# E003当前结果：2026-10-12

## 真实LayerNorm→QUANT/fullA与F9

`layernorm_quant_source_03`保持PASS_SCOPED_RTL：static77.547525s，rows1 pilot47308cycles/57.410899s，同runtime rows16 LN→持久hub→实际共享Q/fullA为659334cycles/753.504079s。真实LN AXI为AR/R=16/1024、AW/W/B=16/1024/16、有效WSTRB65536B；全量16384 F32 LayerNorm、16384 INT8及512 FP16 scale独立gold通过。F9四个错请求绑定与两个错completion隔离通过；owner只有rows16，caller仍由TB构帧。

## 流式adapter生成与F10

`controller_transaction_adapter_hls_03`工具exit0，370.877336s/5987504KiB，实际生成248份Verilog/16份DAT。独立top审计确认24/24 FIFO信号、其中18/18外部协议，顶层无ap_ctrl_hs；原runner误把内部helper握手当顶层端口的FAIL保留。HLS估算BRAM18K49/DSP29/FF53762/LUT190633/URAM0，不是OOC/P&R或联合资源。

`controller_transaction_adapter_rtl_03`编译一次并独立复位运行八个case：compute51338、begin52102、producer55242、wait_end62469、wrong_end62183、bad_producer54499、cancel_producer44862、end62475cycles，全部PASS。每项在旧completion消费14拍和15拍后各停读12周期，后继descriptor和外部协议均不前进；第16拍真实消费后才继续并最终清空八FIFO。F10在实际shell/HLS_03 adapter及八个独立协议用例范围关闭；原八case combined full仍COST_STOP/started:false。

## graph sequencer HLS_01冻结失败

host build/run均exit0，原transaction dispatch marker通过。HLS guard终态为FAIL/semantic_stall，child -9；运行1336.192305s，峰值owned RSS7005432KiB，最低MemAvailable392270164KiB。完成synthesizability及Loop/function optimization后，连续120s没有新的driver/artifact高水位，按冻结策略停止；未触发24GiB或1800s上限。产物高水位479文件/147825110B，无RTL candidate及端口证据。

设计规模为Compile/Link 2223180、Unroll step1 1415243、step4 1193741、Array/Struct final 1167991、Performance final 1164510、HW Transforms final 1122623条指令。`graph_partitioned`与`execute_graph_action`在Compile/Link分别为2145023与2144057条，说明当前阻塞来自全部action family的控制、owner和lifecycle逻辑集中在单一HLS top；现证据不支持归因为adapter codec或算术闭包回流。

receipt SHA=`fa1e3f7446a82ff0c36d6d23b8c5fa373ac4fa9cd20e9716a13b6e95041354da`；manifest SHA=`528f2f1e62c00bc423f9c7c8fd16fa3879451ba6a9a1d5506bb4baca666db899`；guard SHA=`18a9fb74d169fe07fc13e8623083db07b63be77cac1bed624a55bc4cbd91cadb`；design-size report SHA=`3f43a7d35d8de0b688777a6881f0ab34170415d3871ba3546465032992909c3c`。本attempt冻结保留，不加帽、不原样重跑，也不把工具停止解释为永久编译死锁或硬件不可实现。

## 边界

F10只在实际shell与八个独立协议事务范围具备证据，不能把独立运行拼成same-runtime graph。graph sequencer没有生成RTL。真实sequencer、BEGIN→producer→completion→END、typed唯一退休、LayerNorm master/monitor/hub/source lease整链、完整tensor/多窗口、部分提交/故障取消恢复、多role/QKV、LOAD/MATRIX、普通↔GATE双向切换、当前完整CPU/实际CSim、13BO完整请求和联合资源/性能仍待。C009部分实施，C008/C010整体未关闭；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成。无新OOC/P&R/上板/agent或预算，G余2338.224019s。


---
Published: 2026-10-12T10:49:48.142007+00:00
Publication: P5750021ca54740cab296773340eacfe3
