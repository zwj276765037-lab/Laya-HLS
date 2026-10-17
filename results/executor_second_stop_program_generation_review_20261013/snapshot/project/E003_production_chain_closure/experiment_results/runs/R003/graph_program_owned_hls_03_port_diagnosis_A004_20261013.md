# graph_program_owned_hls_03：LAP输出裁剪诊断

日期2026-10-13；负责人A004 `/root/executor_entry_audit`；父A002授权只读冻结源码/有限HLS日志/XML/优化产物，仅写本报告与agent/A004/result.md。请求模型gpt-6.1-sol/xhigh，actual未核；无子agent。没有编译、HLS、RTL、进程管理、修改共享源码或任何attempt；父当前持有单重工具NORM host_01。research-agent工程/hardware证据边界及原资源帽不变。

**结论：实际生成保留FAIL_PORTS。** LAP的8192位write_nb路径在接口生成之前已经被裁剪。现有bitcode给出直接失活条件：原本传实际完整key的program_hls::step，在 `a.g.0.bc` 中已变成**无key、无bound_command/持久key状态、READ_COMMAND采用null-key取消语义**；owned step遇WRITE_ACTION/phase3直接设置isolated，根本到不了LAP write。主要待测修复是假设：用明确的has_issued_key布尔及完整Key值/引用代替综合可达路径中的nullable pointer判断，以保留绑定条件和四个64位key字段。此处没有签修复有效或新HLS通过。

## 实际运行及端口证据

冻结attempt：`project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_hls_03`（以下称AT）。receipt原status=FAIL_PORTS；HLS child_exit_code0、runner_exit_code0、345.905041s、peak_owned_rss4832216KiB、guard trigger=null。host为明确复用 `graph_program_owned_host_04`，host_measured_in_this_attempt=false；不把复用HOST计为本次实测。

- `AT/work/hls/syn/verilog/laya_graph_program_owned_sequencer.v:59–61`：program_pending为8192位dout输入、empty_n输入、read输出；`:245` 明确 `assign program_pending_read = 1'b0;`。应为实际LAP output的din/full_n/write。
- `AT/guard_hls/driver.log:2939–2945`：三program_pending信号no fanin/fanout、left dangling，并把read置0。其余7个FIFO的21个方向/宽度信号通过原checker；program_pending的3个要求信号不存在，port_evidence.pass=false。
- 同日志`:419`有stream访问非顺序警告，但警告本身不能证明裁剪原因。top XML核为实际 `laya_graph_program_owned_sequencer`、U55C part与6.67ns目标；这只能证明工具生成该top，不能使错误接口成为硬件PASS。

## 冻结源码中的真实路径

`AT/frozen/hls/control/graph_program_owned.cpp:95–99` 从保留的实际GRANTED owner取完整session、accepted_request、source.sequence、handoff_epoch，构造local `Key key`并明确向step传 `&key`。

`AT/frozen/hls/control/graph_program_hls.cpp:73–83`：

```cpp
if (cancel && beat == 0 && !issued_command_key) return;
if (issued_command_key && (!issued_command_key->session ||
    !issued_command_key->accepted_request || !issued_command_key->sequence ||
    !issued_command_key->handoff)) return;
// 接受实际command首拍后
owner.bound_command = issued_command_key != nullptr;
owner.key = issued_command_key ? *issued_command_key : Key{};
```

`observe_pending(const State&)`在`:197–205`依次核bound_command、graph.action_active及允许phase，复制**同一持久State**的key/command/graph.pending，完整program_pending::validate通过后编码完整LAP。该函数没有从action前缀猜pending，也不另分配ordinal。owned`:69–79`在WRITE_ACTION、尚未sent时先observe再write_nb；只有成功实际写出才pending_sent=true，期间不推进LAX。

本诊断未发现源码恒false常量：完整非零key、已接受首拍、成功prepare_norm→WRITE_ACTION/active是源码可行路径。完整HOST测试的复用证据属于原身份；不能用源码可行性或HOST通过推断生成路径亦可行。

## 直接优化产物证据

使用安装自带llvm-dis仅解析既有bitcode，输出保留在本次进程内存，不创建反汇编文件，不重编译：

```text
Vitis/lnx64/tools/clang-3.9-csynth/bin/llvm-dis EXISTING.bc -o -
LD_LIBRARY_PATH增加原Vitis/lib/lnx64.o（满足同安装libsqlite依赖）
```

以下行号为该llvm-dis标准输出中的可复现行号；原始证据仍是对应bc文件，未把stdout说成attempt原文件。工具会对部分高层HLS bc提示invalid debug version；所引IR运算及结构解析成功，未依赖失效debug字段推导控制语义。

### 裁剪前：a.g.ld.5.gdce.bc

该阶段仍保留正确的源码结构，而且**已没有legacy externC top**（完整module中define `laya_graph_program_sequencer`计数0；唯一program_hls::step调用在owned函数）。

- IR stdout`:775`：owned调用带local `%key`，不是null。
- `:2510–2512`：取消保护以真实pointer的icmp-ne-null为条件。
- `:2520–2549`：pointer存在时核四个完整64位session/request/sequence/handoff值。
- `:2574–2578`：`%cmp37 = icmp ne ... %53, null`，再 `store i1 %cmp37` 到bound_command。
- `:2582–2605`：真实Key在cond.true拷贝，并写入持久State.key。
- `:2099–2101`：observe从传入State的field7读取bound_command；后续仍有active/phase/validate/encode分支，没有常量false替代整个函数。

因此在最后一个已检查的链接/DCE阶段，真实top的key传递和observer关系仍存在。

### 裁剪后：a.g.0.bc（也对应同SHA的a.g.bc/a.pp.bc等）

owned函数已无program_pending参数（IR stdout`:388`），program_hls::step已无issued key参数（`:6072`）。整个module中持久bound_command、s.program.key及pending_sent globals均不存在。observe函数和调用均已消失。

实际owned控制流（stdout`:705–712`）：

```llvm
if.end51:
  %29 = phi i8 ...                   ; 实际持久program.phase
  %cmp53 = icmp eq i8 %29, 3         ; WRITE_ACTION
  br i1 %cmp53, label %if.then54, label %if.end66
if.then54:
  store i1 true, i1* @"...::s.isolated"
  br label %cleanup127
```

这不是write_nb暂时遇满导致等待：phase3在此直接永久隔离，write_nb调用已不存在，pending_sent也不再参与条件。

同阶段program_hls::step的READ_COMMAND取消条件（stdout`:6228–6236`）：

```llvm
%7 = load i32, i32* @"...::s.program.beat"
%cmp18 = icmp eq i32 %7, 0
%or.cond = and i1 %cmp18, %cancel
br i1 %or.cond, label %cleanup.cont, label %if.end32
```

源条件是 `cancel && beat==0 && !issued_command_key`；拥有实际 `&key` 的owned路径本应允许在撤销后消费唯一已发旧command。优化产物采用的恰是unbound/null-key语义；同时完整key验证/锁存全部被去掉。这一独立控制条件证明绑定表达在转换中丢失，不只是const observer或LAP编码函数返回false后产生的一般死码。

后续 `a.o.3.bc`已同样无实际program_pending FIFO写操作；`step.verbose.rpt:870–874`仍保留phase3比较并使其余工作predicate依赖 `!icmp_ln69`。最终RTGEN只见无用FIFO，生成dangling input和read=0。

**已定位的边界**是 `a.g.ld.5.gdce.bc` → `a.g.0.bc` 的HLS编译/转换区间。没有逐pass中间IR，所以不指定某个AMD优化pass为已证根因，也不把此观测升级成一般化工具缺陷结论。可核事实是：同一真实top的nullable绑定表达已变成null-key语义，导致observe/LAP不可达。

## 两个疑点的证据边界

1. **observe_pending(const State&)**：原函数明确读同一持久状态，裁剪前仍保留正确field访问；裁剪后整个observer随绑定状态一起消失。仅凭const限定无法认定其为主因。最小修复先保持observer/完整validate不变，直接修正key存在表达；如果新生成仍裁剪，再在新实际IR范围检查observer传参/状态读写，不现在盲改const或删验证。
2. **同TU legacy externC的nullptr调用**：冻结源码`:224`确有legacy路径，但该legacy定义在gdce阶段已不存在，且这个阶段的唯一真实调用明确传%key。现有证据不支持把名字碰撞或legacy nullptr作为已证原因。移动legacy wrapper到另TU最多是后续区分实验；先改明确的nullable内部接口更直接，也不靠删除旧行为取得通过。

## 最小可检验修复与验证出口

父已选择的候选（尚未测试）：保留旧C++pointer overload兼容；新增综合核心overload `bool has_issued_key, const Key& issued_key`。owned与legacy externC分别**直接**调用 `true, complete_owner_key` 与 `false, Key{}`，不经nullable overload进入实际综合调用图。若引用再次有工具问题，可保持相同完整语义改成四个64位值；不可缩成hash、ordinal或无键bool。

READ_COMMAND仍必须：has=false时才有取消/beat0早返；has=true时核四字段非零；只在实际接受首拍、beat0时锁存bound_command和完整Key；其后旧command prefix/read与结果末拍保持原顺序。observe继续核真实graph.pending及完整command/action/Key，write_nb成功才sent；不加dummy FIFO write，不直接把bound_command常量true，不删validate，不改checker接受dout。

受影响HOST先重新核原9个owned case（含cancel-before-command、cancel-command-prefix、cancel-allocated、完整literal LAP以及safe错误/receipt顺序），并保持legacy原无key行为；在新独立attempt再生成。新生成至少应同时看到：

- bound READ_COMMAND的撤销首拍消费路径及完整key的存储/使用仍可达；phase3应进入observer/validate及LAP write/full等待，不直接isolated。
- 原checker严格核LAP的8192位din/full_n/write，其他7FIFO、3标量及no-AXI合同保持。
- 若生成通过，再做真实LAP消费/反压后的LAX发起验证；仅恢复正确端口也不能代签真实有限RTL/计算链。

修复候选的HOST/新HLS/RTL均NOT_RUN；旧AT保留FAIL_PORTS。完整program、LN/Q生产链、depth2/rearm、M003/M004未通过状态不变。原单重工具和资源帽不变，本报告不启动任何后续执行。

## 核查身份

| 原始证据（AT下相对路径） | bytes | SHA256 |
| --- | ---: | --- |
| frozen/hls/control/graph_program_owned.cpp | 5610 | 466cf7cf9b652932abbb28950329427dfd2b679ca9e14902ded86c80b2affaf4 |
| frozen/hls/control/graph_program_hls.cpp | 7695 | 135ac7abca28c6eacac3e4acd34954cdcc18141aa5f3e6c40b1bd5a1ba60cd15 |
| frozen/include/laya_graph_program_state.h | 1351 | 7a850329b19679baffdaa97548f0f10cfee90ab0a1f0608481660bb929b77231 |
| work/hls/.autopilot/db/a.g.ld.5.gdce.bc | 347220 | 542cca8ee6702926f0198850ea5b3981e9db37dbd81c1c4661290ee50e966648 |
| work/hls/.autopilot/db/a.g.0.bc | 867944 | c354e7be9f8af97701d3cce2447f0e55ac5cdc2ef3db2b4916fae3d94f757039 |
| work/hls/syn/verilog/laya_graph_program_owned_sequencer.v | 8739 | bf3d49b6c7f630a0057ab82ba836702b36be720cf008a659d3bdae3b63e9ed49 |
| work/hls/syn/report/laya_graph_program_owned_sequencer_csynth.xml | 9262 | e79d41294d5db0d229693d27af30c3cb018091bdbe23da25bce400c8e18afdc7 |
| guard_hls/driver.log（receipt已有身份） | 322199 | 0ad060caa008d4d2a594f18419f89849aa049b4606fb521c0350c4a67100d2e6 |

A004已通过实际collaboration消息将关键失活IR及待测修复建议送达父；此报告为有界诊断交付，不新增审批文档或阶段验收。
