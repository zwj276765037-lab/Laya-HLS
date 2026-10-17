# executor生成入口验证与runner：结果交付

## 最新交付：复用已验证host只执行新HLS

2026-10-13再续轮；执行状态 DELIVERED_STATIC_HOST_REUSE。唯一代码修改为 `vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_hls.py`，最新SHA256 `8223c613b942c5c804e452cae6309cab4e80b20d293c1ff477174ffea4ab9f4b`。冻结top test保持 `cc31caf779ae73b85a8bb4ae5ed64993d37f434dc09dfacf1c751549f5d0322b`，本轮没有修改它或任何共享实现/配置。

父A002实际 [executor_hls_host_02 receipt](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_hls_host_02/receipt.json) 已为PASS_SCOPED_HOST。本次只读调用新增身份核验函数确认：12个operation均PASS/runner_exit=0/child_exit=0/trigger=null，七个case真实driver log各有且仅有一个对应PASS marker，实际guard_result与receipt一致；25源、defines、top、七case、完整闭包声明一致；90组manifest original/frozen bytes+SHA均匹配，当前所有source/include的-MM依赖身份一致。tool路径/SHA、compiler、两个外部HLS头、工具版本log、fixture、host binary和launcher也已核。仅新runner身份变化获明确例外并记录，当前没有catalog metadata漂移。

新增CLI `--reuse-host-attempt <verified attempt>`。新--attempt先做上述严格核验，复制完整旧frozen树并逐项检查SHA；保留原已测host runner，另将当前HLS driver冻结为 `frozen/external/current_hls_reuse_runner.py`，记录该新driver original/frozen身份。新cfg只替换旧frozen路径前缀，25个syn.file顺序、U55C/150MHz和所有编译选项保持，其他字节不改。

新input manifest保存引用的host receipt/manifest SHA、逐项host original/host frozen/current original SHA及变化解释；新receipt显式 `host_reused=true`、`host_run.started=false` / REUSED_PASS_SCOPED_HOST，不把旧测量写成本attempt新host测试。仅三份既有catalog JSON和新HLS driver允许披露漂移，source/test/include/模型/合同/guard等身份变化直接FAIL_REUSE_IDENTITY；**没有自动重跑host或自动换源的路径**。--host-only与reuse互斥；reuse可与--prepare-only组合，只验证复制与生成cfg，不启动HLS。

完整复用入口只启动一段production_guard HLS，仍24GiB/1800s/120s语义停滞、CPU0–3/nice19/idle/MemAvailable>192GiB及全项目单重工具；生成后复用原21FIFO/63信号/IO-AUX/scalar核验与逐模块资源解析。未增加HLS/OOC/P&R预算。已做Python AST/CLI、实际host_02只读身份正例、伪造critical header SHA的内存拒绝反例和cfg只改frozen前缀的静态检查；没有创建新attempt、运行编译/HLS/RTL或重工具。

父下一步只需执行下列命令（executor_hls_01必须仍为新目录）；该模式复用host_02，不重复host编译/测试。生成结果、整链、数值/周期、CLOSE/rearm及物理层级仍待对应证据。

```bash
/usr/bin/nice -n 19 /usr/bin/ionice -c 3 /usr/bin/taskset -c 0-3 python3 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_hls.py --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_hls_01 --reuse-host-attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_hls_host_02
```

## 最新交付：21FIFO program owner 绑定版

2026-10-13续轮；执行状态 DELIVERED_STATIC_ONLY_21FIFO。父A002实际完成的 [executor_hls_host_01 receipt](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_hls_host_01/receipt.json) 为 **PASS_SCOPED_HOST**，其25源、六进程范围已只读核对；该尝试是下面保留的18FIFO冻结版本。最新共享top/stream与本次测试发生受影响修改，旧PASS不适用于21FIFO版本。本子任务本轮仍没有编译、执行DUT、HLS、RTL、OOC或spawn。

最新文件身份：`tests/executor_hls_top_test.cpp` SHA256 `cc31caf779ae73b85a8bb4ae5ed64993d37f434dc09dfacf1c751549f5d0322b`；`vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_hls.py` SHA256 `95c206a845127b4b298854c2970972de66e649fb4407b7d6e6f8da98770326f8`。

按当前共享header精确末尾顺序新增8192位FIFO：program_owner输出、program_owner_receipt输入、program_pending输入。原18FIFO和scalar保持原签名，合计 **21FIFO＝16×512位＋5×8192位，63根FIFO信号**，源数仍25。本次不改共享top/header/stream/source list/catalog；已重读research-agent与工程参考，保留其他执行者改动。

success在真实GRANTED accepted receipt之后完整读取program_owner，要求逐字等于独立GRANTED literal并完整handoff::decode；输出等待12calls、读完后再等待12calls均必须零LGP/dispatch，随后原包8192位echo消费才允许原4拍LGP。宽软件队列的write/read仍不能代签真实shell硬件full_n消费。

新增第七个独立process `bad-program-owner-echo`：合法完整GRANTED改accepted_request=2，实际输入owner echo，12calls内要求零LGP/dispatch；完整消费/解码真实ABORT，要求与独立ABORT literal（commit=1）逐字一致、旧GRANTED相同完整key并保留local_committed。再输入正确旧owner echo，32calls保持原1 word未读、零LGP、新owner/A为空且零第二FIRST握手。**不要求EntryPhase::REJECTED**；真实旧ABORT cleanup仍可推进，不能用停止整个入口封死旧债务。成功与错误echo不共享/reset static top，不靠正确echo解隔离。program_pending LAP1端口只核接口，本测试未驱动活动LAP1取消/恢复，整链及CLOSE/rearm仍NOT_RUN。

runner更新七process、21FIFO及scope；端口核验要求两个新增wide输入也为8192位，仍检查实际IO/AUX两master和全部scalar。冻结/guard/预算/host失败不启动HLS/原attempt不可覆盖逻辑保持。已做Python AST和CLI帮助、25source/21FIFO/七case静态核对；纯内存端口解析63信号正例和program_owner_receipt_dout错误512位反例检查通过；共享header参数顺序和错误后禁止继续读owner echo的实现分支已只读核对。

最新尚未执行的入口如下；交付时两个目录均不存在。父A002继续负责项目单重工具串行调度。默认完整入口仍先执行host，任一失败阻止HLS。

```bash
/usr/bin/nice -n 19 /usr/bin/ionice -c 3 /usr/bin/taskset -c 0-3 python3 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_hls.py --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_hls_host_02 --host-only

/usr/bin/nice -n 19 /usr/bin/ionice -c 3 /usr/bin/taskset -c 0-3 python3 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_hls.py --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_hls_01
```

## 以下保留18FIFO首次交付记录

以下SHA、接口及host_01入口描述仅属历史冻结身份；host_01已经执行，不重用/覆盖原attempt。本续轮最新身份和命令以上节为准。

2026-10-13；A006，parent A002；M003/SM003/E003/R003；决定 D-M003-FIRST-HARDWARE-BASELINE-01。执行状态：DELIVERED_STATIC_ONLY。模型请求 gpt-6.1-sol/xhigh，actual 未核实。仅准备有界 host/top 生成入口，本子任务未执行 C++ 编译、host DUT、HLS、RTL 或 OOC；没有新增 DUT PASS。

唯一写入两个实现文件和本结果；共享 header、top、stream、配置、catalog 和三摘要均由父任务维护。继承 research-agent 工程/硬件参考、项目 AGENTS 和单重工具预算。没有后代 agent、没有管理其他进程，也没有回退其他执行者的修改。

## 已交付与冻结身份

实现根 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment`：

| 文件 | SHA256 |
| --- | --- |
| `tests/executor_hls_top_test.cpp` | `51ce6c369c6eb468f81ba09160b53f4cee79e1b9e5bc77cfa0ef20b806c477d3` |
| `vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_hls.py` | `c28ce639ef14b984466c7a873724342f12664f25b88e7a5c01ea9ecf2322a475` |

当前顶层是 `laya_task_lifecycle_executor`，嵌套 `config/executor_hls_sources.cmake` → `executor_actor_sources.cmake`，生产闭包 **25 源＝24 actor 源＋executor_hls.cpp**，host 另加一个 test TU。所有依赖提取、host 编译与 HLS 配置统一使用 PARTITIONED_PRODUCTION_CALLER、CONTROLLER_TRANSACTION_SEQUENCER、TRANSACTION_SEQUENCER_CODEC、LAYA_EXECUTOR_FIRST_REQUEST 和 AP_INT_MAX_W=8192。

接口已按父稳定版核对：16 条 512 位 FIFO（含 action_completion_receipt）＋两条 8192 位 FIFO control_response_receipt/control_response_rejection，共18条；调用顺序与 `include/laya_executor_hls.h` 一致。没有旧 response receipt bool/scalar 或 action completion consumed bool 参数。已修去 host stream 检查函数的 const 限定，适配 Vitis stream.empty() 非 const。

## Host 测试范围

runner 以六个独立进程执行 success、bad-owner-echo、io-address-mismatch、aux-address-mismatch、bad-request、bad-model；每例保留进程内唯一 static top，不能靠 reset 拼通。

success 用真实 LYRQ 和已校验 LYMP fixture；IO/AUX 均实际分配、64 字节对齐，地址与 physical_config 一致。LAD1 期望值独立重建13个 role 的 epoch/address/capacity，identity/model 字段复用独立 literal，session=29、accepted_request=1；不把原 STATE0-only admission_owner.bin 当成全13BO期望。其余11个 adapter BO 地址是受控元数据，未做算术访问。

测试要求 FIRST ready/valid 仅握手一次；A输出完整16拍→真实 admission_owner::decode→原包完整16拍 echo 后才产生 HOLD/query 权限。覆盖 A输出消费和echo末两拍、HOLD/IMPORT_OK真实consumer与echo、HELD/GRANTED返回、LBR2输入的尾2/尾1各12步延迟。早到HELD/GRANTED保留直到对应控制请求完整echo，真实 checkpoint helper产生 IMPORT_OK，匹配GRANTED后才发布并完整decode LGP1。最后改变实际 LYRQ request_id/generation，再持续提交 FIRST 候选，要求零第二次握手及零新 A/HOLD/query/command。

foreign A echo 使用合法但 accepted_request=2 的完整LAD1，要求拒绝和持续隔离；之后合法旧A echo留在FIFO，不清流、不重开。两项实际IO/AUX地址不一致和实际请求/模型损坏分别拒绝。只测试初始 FIRST 门的 cancel/safety 条件；不宣称已覆盖准入后的全动态取消链。

宽 accepted/rejection FIFO 使用完整8192位回执，success 检查 accepted 路原包和 rejection 路为空。软件 hls::stream 为无界队列，host read 不能代签生产硬件中唯一shell直接 full_n/完整验证consumer。

## Runner 与证据范围

CLI 提供 `--attempt`、互斥 `--prepare-only`/`--host-only`；默认执行冻结→独立oracle→host build→六进程host→HLS。新 attempt 必须不存在，不能覆盖旧尝试。prepare-only 会执行受guard约束的 -MM 与工具版本核验，但不编译host或启动HLS；host-only在host出口结束。

冻结 model header/manifest/完整aux.bin、七份外部合同、两级配置、25源/test/runner/oracle链、guard/helpers、RTL协议布局及 -MM 找到的全部工程依赖。原文件与冻结文件逐项记录路径/bytes/SHA；依赖提取后漂移或复制时漂移会失败。记录编译器、v++、ap_int.h/hls_stream.h及受guard工具版本日志、派生配置、命令、launcher、guard和原始输出身份。

所有 -MM、per-TU host 编译/链接、host case 和HLS串行通过 production_guard，24GiB/1800s/120s语义停滞；轻oracle/工具版本8GiB/120s。launcher必须CPU0–3、nice19、idle I/O、MemAvailable>192GiB。全项目跨runner的单重工具安排仍由父A002负责。任一oracle/build/host失败立即退出，receipt中的HLS保持NOT_RUN/started=false。

HLS继承U55C `xcu55c-fsvh2892-2L-e` /150MHz、pipeline_loops=0、throughput_driven=off、complete_threshold=0。source排除adapter、外部service codecs、完整forward controller。成功生成后检查实际18FIFO共54信号及数据宽度、完整物理配置2496位、全部scalar/IO-AUX直接地址输入、只存在IO/AUX两个AXI读master、clock/reset及无ap_start/done/idle/ready。资源从实际csynth.xml逐模块记录估计，不相加冒充联合资源或物理时序。

## 已做与未做检查

- 已做：Python AST语法与 `--help`；嵌套25source/18FIFO清单与固定输入路径；七份合同路径；当前header参数顺序；纯内存合成声明的端口解析器正例及8192误成512的拒绝检查；上述两文件SHA。
- 未做：实际guarded -MM闭包、真实冻结attempt、C++编译/链接、六项host DUT、HLS生成/真实端口报告、模块资源、RTL FIFO反压、LN/Q数值/周期、生产wrapper整链、LAP1 bound取消、CLOSE/rearm、OOC/P&R/上板。上述静态检查不替代任何未做项。

父报告的 executor_stream_host_02 与 actor_host_10 PASS 属于父对应冻结身份，不能移作本top测试或HLS生成的PASS。

## 父任务执行命令

下列是两个独立新attempt入口；默认HLS命令自身先执行host并在失败时阻止HLS，不要求先另跑host-only。若目录已存在，选新的attempt名称，保留原目录。

```bash
/usr/bin/nice -n 19 /usr/bin/ionice -c 3 /usr/bin/taskset -c 0-3 python3 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_hls.py --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_hls_host_01 --host-only

/usr/bin/nice -n 19 /usr/bin/ionice -c 3 /usr/bin/taskset -c 0-3 python3 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_hls.py --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_hls_01
```

父维护关联三摘要：[experiment_source](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_source/summary.md)、[experiment_results](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/summary.md)、[experiment_status](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_status/summary.md)。下一步由父在单重工具规则内实际冻结/编译/运行，根据原始receipt判断host与生成；本交付不关闭M003/M004。

## 阶段 C 只读交付：首个完整 NORM 计算链的最小真实接线

2026-10-13；A006 `/root/executor_hls_runner`，parent A002。执行状态 **DELIVERED_READ_ONLY_WIRING_AUDIT**。本轮唯一写入本文件；未修改实现/runner/配置/摘要，未编译、执行 HLS/RTL/OOC、管理进程或创建后代。以下是当前源码及指定冻结收据的静态接线盘点，**不是新增 DUT PASS**。研究/工程/hardware 技能、项目 AGENTS、单重工具和原资源帽保持；未探索阶段 D 的 Q 方案。

路径缩写仅用于下文定位：`E=project/E002_Laya_HLS/experiment`；`M=E/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512`；`R=project/E003_production_chain_closure/experiment_results/runs/R003`。三者均相对本项目根 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS`。

**结论：生成 adapter/F10 与 LN 核可按冻结身份复用，但现成两个 portal wrapper 不能直接串接。** 最小生产 wrapper 必须在一个实例内保留完整 A/K 及旧 route，连接实际 program consumer、executor、F10、F9/源 AR guard，并且只有一个 managed LPV transport、一个 hub、一个 store monitor。需要补的不是 CLOSE/rearm，而是实际 owned program consumer、真实 adapter 旧帧/pending、v2 handoff 对源区间/目标写路的保护，以及同 runtime 的四个 rows16 正常 NORM 窗口。

### 1. 实际生成与冻结身份；旧 PASS 的边界

| 冻结对象 | 已核 SHA256 / 实际证据 | 可复用范围 |
| --- | --- | --- |
| `R/controller_transaction_adapter_hls_03/laya_command_provenance_adapter.v`，2088112 bytes | `42f9056ad25de017d756f333de407925ae9f555c87f68c4b74db75a01471b558`；`adapter_rtl_03` manifest 的 frozen/external/adapter_rtl 同 SHA，实际文件匹配 | 实际生成 adapter；8 个 FIFO、24 根 FIFO 信号。HLS 原 receipt **FAIL 保留**；后续 `controller_transaction_adapter_rtl_03` 是 **PASS_SCOPED_RTL_INDEPENDENT_PROTOCOL_CASES**，8 个独立 reset 用例，不是同 runtime graph |
| 当前及 `R/controller_transaction_adapter_rtl_03/frozen/.../rtl/laya_controller_transaction_adapter_shell_v1.sv` | `e9a420cb984911e13e2d56b5bf956ddf3c1be341d94bb14987d6d5373ae2ed5e`；frozen/current 一致 | F10 等实际第 16 个 LTC1 consumer pop，包含 14/15 拍停顿测试；未提供生产 pending owner/full LPV packet |
| 当前 adapter C++ 及上述 RTL attempt 的冻结源 | `f22569b4bf84be99a3d586976db5a9e6b813a2f7af8da11383b93b9fb56bece5`；frozen/current 一致 | 单 inflight 24→外部16/8→16 的状态机逻辑 |
| `R/layernorm_producer_hls_01/laya_layernorm_producer_engine.v`，109897 bytes | `b0971fb5569ca6601061d18e04262a4004b493918a48ac3d54db6a22d8610798`；`guarded_source_05`、`quant_source_03` frozen/external/layernorm_producer_rtl 顶层实际均匹配 | gamma0、D1024、LN_ATTN/LN_FFN 的生成核；独立 request/completion FIFO、source/destination AXI512、实际 AXI-lite 基址配置 |
| 当前及 `R/layernorm_guarded_source_05/frozen/.../rtl/laya_bootstrap_source_guard_v1.sv` | `a2da74885564369fb882e14b3b2d49d16aca741c01805636374209d0c86d0e34`；frozen/current 一致 | v1 LBR1 真实 snapshot/action/LPC1/LAC1 consumer 与源 AR/R 区间保护；没有 v2 LBR2 初始化路径 |
| 当前及 `R/executor_managed_lpv_rtl_04/frozen/.../rtl/laya_generated_provenance_v1.sv` | `3bb3117f317e4fc6724c3ddd560b20369c0ca52e1b412efd520dbfb322c4455f`；frozen/current 一致 | 已测七个有限 managed LPV 用例，真实16/8 framing/唯一 hub cleanup；pending/owner 输入仍为受控 TB 驱动 |
| 当前及同 attempt 的 `laya_generated_provenance_axi_portal_v1.sv` | `095a98cdfd100e267580dc8ecbcbc73f7f62d7b3dac3795dc36775326145d332`；frozen/current 一致 | 持久 A、两 route、一个 hub/monitor；不是 generated adapter 真实 pending 的证据 |
| `R/graph_program_hls_01/laya_graph_program_sequencer.v`，1397992 bytes | `0373c9a75c51081f95b68e2ee2e41fa3ff4a57c98f397991aa5be5ea39db4882`；`graph_program_rtl_01` manifest 引用该 frozen top | 旧四 FIFO finite NORM program；不含 program_owner、LAP1、LAC1 codec receipt 接口 |

adapter HLS 收据的 `forbidden_control` 四项 true 不能直接用来断言顶层具有 ap_ctrl_hs：实际 [生成顶层:12](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_adapter_hls_03/laya_command_provenance_adapter.v:12) 的完整 module header 到40行只有 clk/rst/cancel 与8 FIFO；2107–2133 的 port declarations也一致。3540–3543 行存在内部子模块 `grp_external_request_word_*_ap_start/done/idle/ready`，与整文件搜索造成误报的解释相符。后续 RTL receipt 明确复用同 SHA；**不回写或改判原 FAIL**。

当前 LN wrapper SHA `406c02d56f76c0bcca4129d8956ffc9fbc4957a905f497e5bb5146e74a4b307d`，与 `guarded_source_05` 的 `95410a25963d6b562c43caf4db81c6190aa021ec325fc584342bcdc2168da0e3`、`quant_source_03` 的 `ce35636345b6125e7f33d5828960a3999d7622264248ecb5e4f891ff8aa645d2` 均不同。对 `_05` 的差异已读：当前518行之后增加 managed LPV/checkpoint 新端口的零连接。旧 LN 两批次 transport SHA 为 `d418752b00080b04e474f92b75d0adeda641116ab032395a748a06603fada90a`，portal `_05` 为 `a00e121a0edde8a22cd096ca90005bb31180ab94084c92f39c3893580f88100d`、`_03` 为 `a8c2295c5d10327c1ee857437f37ff7417ad147cf879598195b5fdb074be92b9`。因此旧 LN PASS 不能签当前 managed wrapper 组合。本轮核了表中命名模块和其冻结配对，没有声称重新核了全部生成子模块闭包。

审计读取时，`R/executor_hls_01/receipt.json` 已从运行中变为 **COST_STOP**：`generated_candidates=[]`、`port_evidence=null`，guard trigger=`semantic_stall`，elapsed=280.460530s、child_exit=-9、peak RSS=1477768 KiB；没有实际 executor RTL。其接口只能称 **expected 21 FIFO＝16×512+5×8192，63信号**，来源 [executor header:11](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/include/laya_executor_hls.h:11)。父已收到该变化；不得据 host_02 代签硬件。

同一读取时点，`R/graph_program_owned_host_01/receipt.json` 为 **FAIL**、HLS NOT_RUN。旧 program RTL 可作为算术任务生成核心来源，但旧 [program shell:3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_graph_program_shell_v1.sv:3) 只有四 FIFO 与 result consumer gate。当前 [owned program:26](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/hls/control/graph_program_owned.cpp:26) 的真实 GRANTED 安装/原包 echo、完整 LGP1 比较、从唯一 allocator 取得 LAP1、完整 LAC1 验证后 receipt 尚不能由旧生成核代签；需实际生成或等价真实 wrapper consumer 的新证据。

### 2. 最小单实例结构与字段接线表

建议以当前 managed portal 为唯一 hub/monitor，保留 handoff/control/checkpoint transport；把 LN wrapper 中143–432行的基址配置、F9、真实债务，与480–509/585–650行的源 AR/生成核连接接到该 portal。也可扩展 LN wrapper 内的现有 portal 来承担这些职责。无论选择哪一种，不能再串一个独立 handoff portal，避免复制发布/退休权威。

| 生产边界/字段 | 唯一真实 producer → consumer；必要接受条件 | 当前文件定位/缺口 |
| --- | --- | --- |
| `physical_config[2495:0]`、session、BO base/epoch/capacity | wrapper 的实际锁定13BO配置 → executor；IO/AUX直接地址必须一致。FIRST/运行中 mutation 必须拒绝/撤销，不能从 LYRQ proof flags 产生配置 | `E/include/laya_executor_hls.h:8–17`、`E/hls/control/executor_hls.cpp:157–176`；host 的11个 adapter BO地址受控事实不等于完整物理 wiring |
| LAD1 `admission_owner` 16×512 与 `admission_owner_receipt` 16×512 | executor → 全帧 consumer → 唯一 portal 的 `lpv_admission_valid/record`；只在实际 `lpv_admission_accepted` 后 echo同一完整8192位 A | `M/rtl/laya_generated_provenance_axi_portal_v1.sv:186–195` 有结构/role/base/epoch/capacity及真实静止核验；两个旧 wrapper 均未接 admission consumer。`lpv_admission_ready` 单独不证明合法 A 被安装 |
| LHC1 request 16×512、原包 request receipt；response16×512、accepted/rejection8192 | executor ↔ `laya_executor_control_transport_v1` ↔ 唯一 handoff shell。实际 shell whole-record消费才产生 request echo；完整 response16pop及8192位 accepted原包 handshake 才 pop shell response | [control transport:64](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_control_transport_v1.sv:64)，96–106；wide receipt不能接常1 full_n或普通无条件FIFO冒充 shell接受 |
| HOLD / predecessor_done / HELD；完整 K | 停止 predecessor 新业务，保留旧 LPV/写/B/返回进展；实际 predecessor finite producer以同 K报告完成，并结合真实旧 adapter/所有 FIFO排空，shell 才持锁并返回 HELD | [handoff shell:229](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_handoff_shell_v1.sv:229)–238；当前 wrapper148–152只合入portal/checkpoint队列与入口，没有F10半帧/返回/LPV sidecar。`stop_predecessor` 是给实际producer的停止请求，不能以固定延时换 done |
| LBS2/LBR2 checkpoint16/16，IMPORT_OK/GRANTED | executor真实 helper ↔ checkpoint transport ↔ 同一 hub；全16拍 LBR2实际consumer、full key绑定及真实IMPORT_OK消费，随后实际accepted GRANTED receipt才建立 dispatch | `M/rtl/laya_executor_checkpoint_transport_v2.sv:61–82,102–104,133–138`；`M/rtl/laya_executor_handoff_shell_v1.sv:255–264,290–296`。query/base history来自实际 predecessor LPV首拍238–253，不能旁路预置 READY |
| `checkpoint_valid/predecessor_held/source_held/target_held/handoff_epoch/source_epoch` | wrapper保留的同 K/H、源Ref及实际互斥锁/区间配置 → executor | `E/hls/control/executor_hls.cpp:170–177`；当前handoff wrapper `protection_valid(locks_owned)`仅表示逻辑持锁，尚无源AR与所有source-write/base mutation控制，不能单独代签source_held/target_held |
| `program_owner`8192 → `program_owner_receipt`8192；LGP1 4×512；LAP1 8192 | actual GRANTED accepted → 实际 owned program consumer；完整GRANTED合法/commit及原包echo之后才允许 LGP1；program唯一allocator完整pending action生成LAP1并送executor | `E/hls/control/graph_program_owned.cpp:38–77`，`E/hls/control/executor_hls.cpp:197–239`；旧program generated top不具这些端口，不能TB提前echo owner或从action首拍造LAP1 |
| LAX1 action8×512；LAC1 completion4×512及receipt4×512；LGR1/program result4×512 | program ↔ executor；真实全部action捕获同时绑定AR guard；program完整校验/commit LAC1后echo原4拍给executor。LGR1实际consumer通知只约束该finite program | `E/hls/control/graph_program_owned.cpp:80–106`；`E/hls/control/graph_program_sequencer.cpp:71–109`；不能使用控制TB产生成功LAC1或 `program_result_consumed` 常量来释放源保护/请求 |
| LTX1 request24×512；LTC1 normalized completion16×512 | executor ↔ 实际8 FIFO generated adapter/F10；24拍来源/16拍实际caller消费，所有 depth2 FIFO有真实占用/末拍观察 | `M/rtl/laya_controller_transaction_adapter_shell_v1.sv:49–81`；其observational completion读信号必须来自executor侧实际LTC1 FIFO consumer，而非generated adapter completion_write |
| generated LPV1 16×512、LPA1 8×512；`candidate/pending/response`完整 A+route、pending完整8192位packet | adapter → 保留旧归属的有界全帧 collector → 单一managed portal；返回按实际frame A/route送回同adapter，直到真实8拍消费，所有外部队列/normalization/LTC消费继续保留旧归属 | `M/rtl/laya_generated_provenance_axi_portal_v1.sv:214–223,259–267,309–328`；`M/rtl/laya_generated_provenance_v1.sv:58–62,114–121,134–154`；当前F10没有这些输出/sidecar |
| LPE1 producer16×512、LPC1 completion8×512；accepted BEGIN | generated adapter ↔ F9 ↔ generated LN；同一hub accepted BEGIN完整packet绑定LPE1，actual8拍BEGIN LPA1 consumer之后才发LPE1到engine；completion全512 bytes绑定原请求后交caller | `M/rtl/laya_layernorm_producer_portal_shell_v1.sv:229–275,302–337,344–360`。F9的LPC1 final consumer必须观察adapter实际read && empty_n；不能用F9写完第8拍代替 |
| source ARVALID/ARREADY、R debt、RRESP/RLAST | 基于实际v2锁/源Ref+base+bound LAX1/LPE1，双向gate真实AR；一次读取只在完整请求允许区间，R debt计实际握手，错误/未退清债务保持保护 | 当前 `M/rtl/laya_layernorm_producer_portal_shell_v1.sv:480–509` 双向gate可复用；`M/rtl/laya_bootstrap_source_guard_v1.sv:59–64` 只认v1，必须补真实v2绑定入口，不能造一张v1响应/设置proof_valid |
| destination AW/W/B及 bootstrap predecessor writer | 固定一个写选择者，旧writer/END/B先排空，GRANTED后仅实际LN的已绑定区间可进入同一monitor；选择不能在活动scope/债务期间改变 | LN wrapper451–478；handoff wrapper137–145。B返回也归实际旧writer。NORM source HIDDEN与destination NORM同STATE0基址但区间不重叠，需保护源区同时允许目标区 |
| `adapter_pending_zero`、`old_channels_drained`、physical_safe | 由下节列出的实际队列/状态/AXI债务计算；逐用途区分producer物理安全与旧adapter整个事务排空 | LN wrapper424–432已有producer局部事实；当前managed TB输入受控，真实聚合缺失；不能由固定等待或admission bool替代 |

单一 [portal:338](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_generated_provenance_axi_portal_v1.sv:338)–405已经包含一个hub和一个monitor，BEGIN/END commit只随真实hub response handshake。当前 [LN wrapper:518](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_layernorm_producer_portal_shell_v1.sv:518)的managed及checkpoint输入为零；当前 [handoff wrapper:174](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_handoff_portal_shell_v1.sv:174)默认未启用MANAGED_LPV_OWNER，完整字段也为零，并在第5行明确不实现source AR。两者均不能按现状签阶段C。

### 3. 真实 pending 与旧帧的最小补法；避免 BEGIN/END 环等待

generated adapter 的C++私有状态是 READ_INTERNAL/PREPARE/SEND_EXTERNAL/RECEIVE_EXTERNAL/NORMALIZE_RESPONSE/WRITE_INTERNAL，参见 [adapter source:420](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/hls/platform/controller_transaction_adapter.cpp:420)–504；实际generated顶层2144–2145行有私有 `state`、`beat`，但没有公开idle/pending/full-frame元数据端口。末16拍LTC1是写入FIFO即回READ_INTERNAL，故F10实际caller fence仍必要。不要把内部HLS FSM某个周期/私有寄存器名当成公开生产协议。

最小可实现的wrapper sidecar是：在actual LTX1首个pop锁存完整A/route并记录旧事务归属；在generated adapter的LPV输出和portal入口间，用真实write/full_n握手收集完整16拍LPV。收集完以前不能向portal发第一拍；收集完形成真实 `pending_valid/owner/route/packet` 并从该immutable frame发16拍。这样无需改变生成核，也不需要自行复制LTX1→LPV的byte mapping。若选择从完整LTX1重建LPV，则必须严格使用 `E/hls/platform/controller_transaction_adapter.cpp:369–391` 的mapping及unused owner/geometry抑零规则，**不是固定切片**。撤销发生于半LTX/半sidecar帧时必须继续收集旧帧/消费旧返回，新的首拍不准混入；`pending_valid`不能提前由一拍头或TB常量产生。

portal ingress实际第1拍后transport保留frame A/route；如果以preowned普通帧进入撤销路径，第16拍检查整个packet等于expected。返回只有匹配frame A/route的实际consumer可pop，第8拍后才清frame_owned。sidecar/F10的旧事务归属继续保留到实际normalized LTC1第16拍消费，不能在LPV最后一拍write时清掉。transport撤销下仅允许旧帧收集/明确cleanup，并不授予普通旧业务新的hub reservation；不可把preowned解释成撤销后的成功新CLAIM。

**必须区分两个真实排空量：**

- `producer_physical_pending_zero` 接唯一monitor的 `adapter_pending_zero`：LN真实AXI-lite配置完成无错；F9无半/整待交请求、无job/未完LPC1 consumer、无半completion/engine beat cursors；source AR/R debt及rawAR为零；无engine异常source写/destination读；无destination AW/W/engine completion挂起。现有LN wrapper424–432可作起点；monitor自己的bus_idle补足实际AW/W/B退休。不要把同一portal里的LPV transport忙塞进这个量。
- `predecessor_adapter_drained` 及上游队列真实静止，加入shell的 `old_channels_drained`/FIRST及HOLD移交安全门：F10 request count=0且awaiting_completion_consumption=0；LTX/LTC及外部compute/provenance/producer实际FIFO occupancy=0；没有partial/ready LPV sidecar、无旧A/route挂起返回、没有normalization/未消费LTC。实际未连接业务端口也需证明无待事务，不能无条件返回成功。与portal transport/hub/monitor/checkpoint真实静止共同决定可转移旧route。

原因见 [store monitor:228](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_generated_store_monitor_v1.sv:228)–231：BEGIN ready与physical_drained均要求adapter_pending_zero，而generated adapter在BEGIN/END正处于RECEIVE_EXTERNAL等待LPA1。如果把整个F10 busy/awaiting直接AND到monitor input，BEGIN/END等自己的返回，形成环等待。physical_safe也不应要求locks_owned=0；当前portal331–336已经刻意排除锁以免释放循环。

`executor_managed_lpv_rtl_04` 不能补这条实际来源证据：[managed TB:12](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_managed_lpv_tb_v1.sv:12)初始化pending_zero=1，344–345手动给preowned完整packet，353/368手动切pending_zero。其七用例/1441cycles证明有限framing、受控pending路径和真实monitor B fence，明确不证明生产adapter pending、HOLD转route、source AR/F9/lease或generated executor。

### 4. v2源锁移交与完整B1/S64 NORM的必要检查

HOLD之后必须真的停止新的predecessor source写/业务，旧半帧和old END/B保持；在真实全排空及匹配predecessor_done key之后取得source/target/base锁。实际16拍LBR2 helper消费、IMPORT_OK、accepted GRANTED形成同一完整K/B/S/H的source保护事实。guard需从该真实v2链安装完整源owner/Ref、immutable base和source interval；不能伪造v1 LBR1再让旧guard通过。当前v1 guard仅在真实snapshot接受及完整bound response消费后建立proof，149–164；其区间/F9完成/debt代码可以复用，初始化协议必须补齐。

source保护应覆盖整个action四窗，绑定实际完整LAX1及每窗LPE1，不仅第一窗。当前v1 guard的safe_completion99–124已要求成功full-owner rows=S且task_count=B*ceil(S/16)，真实LAC1四拍caller消费及物理债务为零才允许解除action源保护（182–208）。v2接入必须保留这个含义。解除action guard不等于释放request锁；阶段C成功后可保留最后完整A/K、source/target配置及HOLD锁并禁止第二请求，CLOSE/rearm后置。

当前生成LN支持gamma0、D1024、rows1–16，source HIDDEN、destination NORM；actual地址规则见 [LN engine:40](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/hls/operators/layernorm_producer_engine.cpp:40)–57：`source=(batch*1024+row0)*4096`、`destination=8MiB+source`，实际AR读/目标store在93–121。可以复用该生成核完成下列四窗，但必须有新整链测量：

| B1/S64窗口 | rows / elements / bytes | STATE0 source offset | STATE0 NORM destination offset |
| --- | --- | --- | --- |
| row0=0 | 16 / 16384 / 65536 | 0 | 8388608 |
| row0=16 | 16 / 16384 / 65536 | 65536 | 8454144 |
| row0=32 | 16 / 16384 / 65536 | 131072 | 8519680 |
| row0=48 | 16 / 16384 / 65536 | 196608 | 8585216 |

真实lifecycle已有 [four-window loop:506](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/hls/control/task_lifecycle_executor.cpp:506)–535：claim全S owner→逐batch/row+=16→每task实际BEGIN/producer/END→最后PUBLISH全owner。266–405以actual producer completion形成END，等真实terminal/drained返回后唯一retire task。完整program验LAC1还要求whole-owner rows=S、四个连续唯一typed task且task数量一致，`E/hls/control/graph_program_sequencer.cpp:85–109`；不能拿一窗成功代替整S64 slot commit。

首轮C同runtime最低可审查输出：四份actual LPE1/LPC1全包与task/context/source/target/ref；每窗实际8个LPC1 consumer pops；四个正常BEGIN及四个唯一terminal END（早END重试另计，不能多退休）；最后whole-owner PUBLISH；LAC1四拍真实program consumer与四拍codec receipt。每窗16384 F32独立gold，合计65536元素/262144B；按当前generated64beat-row burst形态，合计source_AR64/R4096、destination_AW64/W4096/B64，实际统计有差异时解释burst形态，不以预填计数代替握手。四task IDs必须从真实imported floor继续分配；若import floor=4，则为5–8，不能硬编码floor来证明唯一退休。锁定实际周期开始/结束事件，分别记录handoff、首BEGIN→最后physicalB/END、四窗总action消费周期与等待；这只是NORM计算基线，不是完整模型请求延迟。

旧数值证据严格分开：`layernorm_guarded_source_05` **PASS**，一row、1024 independent F32、cycles57201、prelude64AW/4096W/64B、LN1AR/64R/1AW/64W/1B、18actual LPV capture、controlled LAC1 safe-error释放；明确no executor/program、no full tensor成功。`layernorm_quant_source_03/full` **PASS**，单rows16、16384F32、cycles659334、elapsed753.504079s，16AR/1024R/16AW/1024W/16B及65536store bytes，随后Q混合时间，**不能四倍外推作新四窗LN周期**。`layernorm_quant_source_04/full` 为NOT_PLANNED_COMPATIBILITY_PILOT_ONLY，不是full rows16证据。旧rows16 input/gold可复用精确匹配子区间；不能作为其余48行未比较值的成功证明，整64行输入/gold及身份须齐全。

### 5. 首次计算前的具体缺口与停点

1. 实际executor生成证据仍缺：本轮指定`executor_hls_01` COST_STOP，不改预算重启；21 FIFO是expected。实际owned program consumer也不能由旧四FIFO top/软件echo替代。
2. 只保留一个portal/hub/monitor；真实A安装echo、LHC accepted/rejection、v2checkpoint及program宽owner/LAP1/LAC1 receipt均接到真正consumer；两旧wrapper零连接必须由owner整合。
3. 实际generated adapter旧事务A/route与完整LPV pending sidecar、全部FIFO真实occupancy/F10末拍排空；producer physical fence与HOLD整体排空分开计算。
4. 实际v2 handoff持锁对STATE0 source/base及NORM目标writer生效；全action四窗AR双向gate/debt和真实LPC1/LAC1最后消费者保持；不得造v1证明或source_held常量。
5. 同runtime真实program→executor→adapter/F10→LN/F9→唯一hub/monitor完成四窗，full64独立gold、实际AXI/LPV/typed退休/周期捕获齐全。成功后可以保持旧请求和锁；不要求第二请求、CLOSED/rearm、Q、联合OOC/P&R/板端才能交阶段C，但不能报完整请求PASS。

阶段C接线审计已完成并通过实际消息交父；只交静态最小缺口与复用边界，停止本子任务，不签M003/M004或新增硬件PASS。

## 阶段 C 后续授权交付：必要 LPV owner sidecar 已准备，RTL NOT_RUN

2026-10-13；父A002在上述审计结束后明确授权A006实施一个有界内部sidecar。执行状态 **PREPARED_STATIC_ONLY**。本次仅写新 `M/rtl/laya_executor_adapter_lpv_owner_v1.sv`、新 `M/tb/laya_executor_adapter_lpv_owner_tb_v1.sv`、新 `M/tb/run_executor_adapter_lpv_owner.py` 及本结果；不改共享wrapper、generated核、catalog、attempt、状态/三摘要。已经重读research-agent工程规范与D-M003-EXECUTOR-MANAGED-LPV-OWNER-01；保留其他工作者修改。未编译、运行RTL/HLS/OOC、调用新runner、建立attempt、管理进程或创建子agent；父继续持有唯一重工具。

| 新准备文件 | SHA256 |
| --- | --- |
| `rtl/laya_executor_adapter_lpv_owner_v1.sv` | `8151a340a19cb40911880694455546095c47e6f3a6804390a2294f5f604e1eee` |
| `tb/laya_executor_adapter_lpv_owner_tb_v1.sv` | `db9b9c554c77d4ec7eef653a16fb6f5f8c4362d9a9cbe1879e344330897d322e` |
| `tb/run_executor_adapter_lpv_owner.py` | `1dc73b4493a606876f4e0a03290863841dd95686c2528cefd885c264fc6bb427` |

### Sidecar接口与真实事实

[新RTL](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_adapter_lpv_owner_v1.sv) 提供以下有限接口：

- `installed_owner_valid/installed_owner/owner_revoked` 表示外部唯一已安装的完整LAD1域；`txn_start/txn_start_ready/txn_owner/txn_route`必须与真实LTX1首个pop对应。ready只在本地无旧事务、无error/revoke/cancel、完整LAD1 codec合法、候选等于actual installed A、返回FIFO/入口静止时开放。**外部必须用该ready门控首pop**，不能先pop再报告一个被拒绝的start。
- `adapter_cmd_din/write/full_n`接受实际generated adapter LPV原始16拍；完整16拍寄存器收齐以前 `portal_cmd_write=0`。收齐后送 `portal_cmd_din/write/full_n`，从完整raw packet输出，不复制LTX→LPV mapping，不改任何字段。16拍发送完仍保留完整pending packet。
- `portal_rsp_dout/empty_n/read`→内部真实depth2 FIFO→`adapter_rsp_dout/empty_n/read`；分别计8个真实portal返回pop及8个真实adapter consumer pop。内置FIFO只随chip reset初始化、随真实push/pop推进；cancel/txn_done不复位它。
- `lpv_candidate_valid/owner/route`、`lpv_pending_valid/owner/route/packet`、`lpv_response_owner/route`都从actual start锁存的完整A/route产生。pending_valid仅在16拍收齐后成立，并保持至合法txn_done；candidate_valid表示本地旧事务仍存在，不是hub成功或业务准入。
- `txn_done`仅接真实normalized LTC1第16拍caller消费。完整LPV要求16拍已送、8拍已接且8拍caller已消费、FIFO真的空；无LPV的compute/producer或adapter本地拒绝可在实际done及本地LPV通道全空时收束。第8个LPA1 pop不能替代txn_done。合法done只关闭本地事务，外部installed A与request锁生命周期不改变；保留旧A/route/packet供诊断直到下一个合法start。
- `txn_owned/txn_revoked/txn_drained/protocol_error`及拍数/started/released/invalid_done统计可观察。早到done或无owner的done记录sticky protocol_error/invalid_done，不丢旧frame/return、不清拍数；旧收帧/发送/返读继续。cancel、owner_revoked或已安装A消失/变化锁存txn_revoked；当前txn_owner/route候选输入变化不重绑旧对象。error/revoke保持隔离并阻止新start，当前有限模块没有请求rearm入口。

`txn_drained`仅是**本地旧adapter transport**事实，须与F10半LTX/等LTC、其他外部FIFO占用及唯一portal真实排空合并给HOLD。它不能直接接monitor.adapter_pending_zero；上述BEGIN/END环等待风险保持。sidecar不验证LPV语义/cleanup许可，不代签LPA1完成可信性，不安装/释放外部A，不分配LPV/task/Ref，不发布或退休，不产生CLOSED。

### 有限独立测试与运行器范围

[新TB](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_executor_adapter_lpv_owner_tb_v1.sv) 使用四条实际depth2 peer边界（generated-command peer、portal command consumer、portal-response peer、mock normalized-LTC caller）及DUT内部depth2返回FIFO。mock LTC的每第16个实际pop组合产生txn_done，TB不直接赋值它；其byte pattern只是本地传输peer，不声称actual generated LTC/codec验证。四case之间reset，任何活动case内均不靠reset清债。

1. 外部owner未安装、cancel、owner_revoked、损坏LAD1、不同accepted-request候选的五组12cycle拒绝；随后同runtime两个正常无LPV事务分别模拟compute/producer，实际消费32个LTC peer beats才各关闭本地事务。
2. 完整正常raw claim：16拍collect/send、8拍返回；collect尾2/尾1、portal command尾2/尾1、adapter response尾2/尾1、LTC尾2/尾1均12cycle反压，全部raw bytes逐字比独立literal。返回读完后再持有12cycle确认旧A/pending仍在，actual LTC final pop才释放。
3. 仅收2拍后持续cancel/owner_revoked，并改变live installed A/候选A/route；新start阻止、旧A/route保持。过早完整mock LTC消费被记错，半帧未丢；继续实际16拍、独立preowned_claim负返回8拍、最后真实LTC清本地事务；外部A仍持久、cancel仍在，不能声称CLOSED。
4. 正常16拍送完，在8拍返回的尾2处提前送一次完整mock LTC消费，要求记错但保持旧返回；随后剩余8拍全部实际消费及正确LTC末拍关闭，sticky error继续阻止新事务。

literal来源是已有 `R/executor_managed_lpv_rtl_04` **PASS** 的 `admission.hex`、`claim.hex/claim_gold.hex`、`preowned_claim.hex/preowned_claim_gold.hex`。新runner严格核源receipt的PASS/guard退出/trigger、receipt所指manifest身份、五文件bytes/SHA/16或8行各512位格式；从该manifest的frozen admission_host核actual_admission_owner.bin与独立admission_owner.bin，并要求两binary和hex全部1024bytes相等。只是复用既有独立bytes做运输oracle，正/负返回由受控peer驱动，不能推出sidecar/hub业务成功。

[新runner](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_adapter_lpv_owner.py) 自包含，只接受全新attempt；冻结新RTL/TB/runner、三个协议package、private FIFO、guard/helpers、LPV合同、原literal receipt/manifest/五hex及两A binary。Tcl由runner的冻结字符串生成并记录SHA，使用一个Vivado behavioral运行；不执行DUT host/HLS、fixture重建或任何OOC。保留CPU0–3/nice19/idle I/O/MemAvailable>192GiB，8GiB/120s pilot/120s语义停滞与4000cycles帽，父串行运行。

receipt单列PREPARED_NOT_RUN/PASS_SCOPED_RTL_SIDECAR/FAIL/COST_STOP；PASS要求真实guard exit0/无trigger、唯一总marker及四个case各唯一marker、无Fatal/ERROR，原始日志、工具/派生Tcl/完整冻结身份均保存。`--prepare-only`只冻结准备，若先用该选项创建一个attempt，实际运行须另选新attempt，不能覆盖/复用已存在目录。

已做仅Python AST parse及只读identity检查：五个literal文件和引用manifest匹配、actual A=独立binary=hex、四个共享协议/FIFO依赖与旧literal run冻结身份相同。未调用SV parser/compiler、未执行DUT/TB或runner；各case结果 **NOT_RUN**，无新硬件PASS。module端口/计数/同拍末response与txn_done、取消旧进展及TB驱动采样已逐段静态核对。

父实际串行命令（新attempt须不存在）：

```bash
/usr/bin/nice -n 19 /usr/bin/ionice -c 3 /usr/bin/taskset -c 0-3 python3 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_adapter_lpv_owner.py --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_adapter_lpv_owner_rtl_01 --managed-lpv-attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_managed_lpv_rtl_04
```

本准备交父串行验证和共享wrapper整合；不签完整C链、实际generated adapter因果、v2源AR持锁/四窗LN、CLOSE/rearm或M003/M004。


## Source guard v2：完整旧 shell K/B + actual GRANTED 准备交付（2026-10-13）

- 执行状态：`PREPARED_NOT_RUN`。仅新增指定 RTL/TB/runner，并追加本 result；**没有编译、RTL/HLS/OOC、runner 执行、attempt 创建、进程管理或新 agent**。父任务持有项目唯一重工具时隙；原 v1、wrapper、HLS candidate、catalog、共享摘要/登记均未改。
- 任务范围：C 优先的原 NORM/旧 HLS 下游保护；没有增加 D、逻辑版本修正、QUANT、恢复、CLOSED/rearm 或 Host/service wire。FIRST/A 仍由唯一 wrapper 的 installed immutable owner 建立，完整 downstream K 由该唯一上下文映射；本模块只缓存实际 shell 的旧 K，不建立第二份 READY、lease、publication 或 owner 表。

### 新文件身份

| 文件 | 字节数 | SHA256 |
|---|---:|---|
| `project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_source_guard_v2.sv` | 18168 | `5c65572ac0f8dd042ea70d9e6ec24871cbc22f3d50fc45f9d15d40bf1604b4dc` |
| `project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_executor_source_guard_v2_tb.sv` | 34159 | `939e6a483f58e07db7d4f39e560f071e7fe6d2c9ec826b5ab29a07fcee5c35ed` |
| `project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_source_guard_v2.py` | 21542 | `30e6688e25c6b7dbb9d3e7bfcc6d77f02f000d1baa77655a7b1d314256e7b5f4` |

### 接口事实与保护语义

1. `shell_hold_fire` / `shell_hold_record` 接**真实控制 transport 到 shell 的 complete HOLD consumer edge/8192-bit record**。该边沿组合关闭 source/base 修改，尚未被 shell 接受的字段不授予能力。`shell_hold_active` 接实际 `stop_predecessor`；`shell_pending_key` 接真实完整 `pending_key`；`shell_locks_owned`、`shell_authority_valid`、`shell_revoked` 直接接同一个 handoff shell 的实际输出。没有 LBR1 构造或自签 proof bool。
2. guard 捕获 shell 实际 retained HOLD（包含 shell 分配的非零 H），验证完整旧 K/B：控制头、kind/status/commit、全部保留区、session/accepted request/sequence、canonical 416-byte L13M 与完整 numeric tags、HIDDEN owner/ref/stage/rows/width/role/extent、STATE0 base epoch/address/capacity、NORM target buffer/base/offset/extent/stride。`guard_key` 是 8192-bit 原记录缓存，保持原字节。
3. `grant_receipt_fire` 接 `control_response_receipt_write && control_response_receipt_full_n` 的真实 accepted whole-record 边沿，`grant_receipt_record` 接同次实际 8192-bit receipt 数据。v2 再独立检查完整 GRANTED record，要求它与旧 retained HOLD **全字节相等**，仅 kind=GRANTED、commit=1；status=OK、detail=0、bad=UINT64_MAX、所有保留字节均合法。真实 control transport 已要求 16 actual response writes、16 actual pops、深度2 return FIFO 清空、shell presented record 稳定且 receipt 全字节匹配。普通 response 最后一写/一读不会打开 action/producer/AR。
4. `action_valid/ready` 和 `producer_valid/ready` 是完整实际 LAX/LPE admission edges，需接消费者真实 whole-frame 握手；沿用 v1 原 NORM LAX 的完整 identity/source owner 与 safe LAC 规则，没有借机改 source slot logical-version 与 physical ref 的旧候选约定。producer 额外验证完整 reserved/header、source/target ref/role/capacity、原 epsilon、每行4096-byte source/destination 窗口；target Buffer/region/bank 来自旧 K。
5. `source_ar_allowed` 用于真实 raw source ARVALID/ARREADY 的门限；实际握手才增加 `read_debt`。合法 VALID 在 READY=0 时被缓存为旧 K 的 AR offer，addr/len/size/burst 保持约束；cancel、live base/source change 或错误不会删掉已呈现的旧 offer。该旧 offer仍可真实握手，之后禁止新 AR。全部已接受 R 在 cancel/error 后继续消费，按 actual pop 递减 debt；RRESP、RLAST 与多余 R 的异常粘住 protocol_error/revoke，不伪造 drain。
6. `producer_completion_*` 必须接**F9 对完整 LPC1 校验之后**的 8 个 actual caller pops，最后一 pop 才结束 producer；不是 raw engine done。`action_completion_*` 收集 actual 4 个 LAC pops，完整 bound safe terminal 才产生 local release proof；success 必须是全 S64 owner、B*ceil(S/16) 个 typed retired task，wrong ordinal、one-window owner、nonterminal 无 release。terminal 最后一 pop 和 persistent producer VALID 碰撞会阻止下一 producer。
7. `source_change_ready/base_change_ready` 在 actual HOLD edge、shell old request 活跃、local guard/producer/AR offer/R debt 未结束时均关闭。`source_still_matches` 及 live base 属于真实唯一 shell/hub/monitor 的保护事实，有限 TB 中明确是 controlled peers。source/base 错配后 sticky revoke；恢复 live 输入不能重新授权。
8. `state0_write_allowed` 是**新 AW 的物理区间 gate**，源 HIDDEN `[base+0, base+262144)` 与 NORM target `[base+8MiB, base+8MiB+262144)` 共享 STATE0 base。源区间修改一律关闭；普通 ingress 也不能写 held target；实际已接受的 NORM producer route 可在自己绑定的目标 window 内写入，包括 revoke 后 old stores。不同 STATE0 非冲突区间仍可允许，未 blanket-block 整个 base。`state0_write_is_norm_target` 必须接实际绑定 producer 的内部 route，不能来自 Host 参数。已接受 AW 的 old W/B 不受此新 AW gate 阻挡；其真实 debt/scope/drain 由 `physical_safe` 综合监控输入负责。
9. local guard 只能在 safe LAC 已真实消费、producer/AR offer/read debt 结束、physical_safe、无新 AR 时结束。它不释放 shell old K/request locks，保留 K/grant_seen/revoke/diagnostic facts；无 CLOSE、rearm 或新请求授权。R protocol error 保留隔离态，仍允许旧 R/F9/LAC actual consumption。

### 有限 TB 与来源

- 实例化原 `laya_executor_control_transport_v1` + `laya_executor_handoff_shell_v1`（MANAGED_REQUEST_CLOSE=1），沿真实 HOLD→HELD→controlled actual query16 pops→IMPORT_OK→GRANTED response16 pops→独立 whole-record oracle acceptance→真实 accepted receipt→shell dispatch 路径。控制、request echo、response、F9 peer、LAC peer 均用 actual depth2 FIFO，tail2/tail1 各保持12cycles。
- 独立控制金样及 offline actual C++ helper bytes 来自已完成 PASS `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_control_transport_rtl_01`，包括 prior actual_success_grant。独立原 LAX/LPE/safe-error LAC 与源 B 来自已完成 PASS `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/bootstrap_source_guard_rtl_09`。runner 会冻结双方 receipt、input_manifest、对应实际/独立 binary 与 hex，验证身份与全字节相等，不重新编译 helper。
- 读取事实已确认旧 `snapshot.bin[40:664] == actual hold[40:664]`，完整 identity/model/source owner 匹配；actual_success_grant == independent grant_gold == real HOLD 只改 H=1/kind=4/commit=1。B1/S64、HIDDEN source extent262144、NORM offset8MiB/extent262144、相同 epoch7/address0x1200000000/capacity16920576 均保留。
- 原 controlled producer 的 destination offset262144 与实际旧 K 的 NORM offset8MiB 不同。runner **独立离线**将 producer 的 physical destination offset 改为旧 K target offset；保持完整 S64 identity/source/model、原 NORM LAX slot/version、target BufferRef。controlled success LAC 和四个匹配窗口的 F9 post-validation-peer completion literals 用明确 wire offset 独立构造，冻结二进制与 hex 双份身份；不是从 guard RTL 生成 gold，也不声称 F9 codec 或 generated producer 已执行。
- 六个 reset-separated 场景：①实际全 GRANTED 与 wrong/stale session/request/sequence/H、bad commit/reserved/status/source/base receipt、无 grant 的零 AR、四个 rows16 windows、source/target interval gate、foreign/one-window LAC 拒绝和 controlled S64 success；②持续 cancel+live base change 下旧 VALID AR 保持，old AR handshake/R final beat/F9/LAC tails 完整消费；③source mismatch sticky revoke 与 old cleanup；④RRESP错误；⑤RLAST错误；⑥真实 shell 接受而完整 B codec 不合法的旧 K reserved byte，v2 直接拒绝能力。
- 有限 source memory peer：正常四窗口共 AR4/R16（每窗口只4beats）；这是 protocol interval/debt 验证，不是262144-byte source全读，也没有65536 F32 numeric gold/实际 LN。F9 validator、LAX/LPE execution、LAC result、query、source-match、physical fences 都是明确 controlled peers。无 generated executor/program/adapter/LN same-runtime、unique hub/monitor retirement 或整个 C 的达标结论。
- 不在 producer/R/F9/LAC FIFO debt 存在时 reset；独立场景可从 reset 重新建立 shell。最后 malformed K 场景结束在保持隔离/old response 的诊断状态，不以 reset 伪造安全释放。

### 已完成静态检查与 NOT_RUN 边界

- Python AST parse：PASS；未 import/invoke runner，也未产生 `__pycache__` 或 attempt。
- RTL/TB 只做文本结构核查：module/function/task/begin/end/fork/join 成对；没有 HDL 编译或 lint，因此 SV elaboration、finite assertions 与资源/时延**未验证**。
- 只读冻结身份检查：双方 PASS receipt 的 input_manifest SHA/bytes 完整匹配；选用控制8份 hex、bootstrap8份 bin/hex 身份匹配，bin/hex 全字节一致。full old K/B/source/target/reserved/canonical model/actual GRANTED 的离线字段检查 PASS。
- 共享 control dependencies 当前文件与 control_transport_rtl_01 的 frozen bytes 相同：handoff_layout `9a83d5956d8c092833a9221aec55f304e10a78fc74447c5ac4e0c425923f95c5`、private_fifo2 `de2c1dd5916286f70b0876ee471c65add51ce3198a3585cbde50f162771ed071`、control_transport `a76ada88e673d249335021bf8ef94a73bf6c45c09ca1839fc59c7ff71c5c51af`、handoff_shell `63708dae5d78a856767cae1793621f16b6933eaafc14ef4bed9ae3333741c88b`。
- runner 计划一个有限 RTL pilot：CPU0–3 / nice19 / idle I/O / MemAvailable>192GiB，RSS≤8GiB，120s wall/120s semantic-stall，8000-cycle cap；冻结源码、外部输入、contracts、production_guard/hls_guard_helpers、derived Tcl、launcher、工具身份及 actual control captures。完整6 case markers 与唯一 overall marker 才记 `PASS_SCOPED_RTL_SOURCE_GUARD`；tool error为 FAIL，资源保护触发为 COST_STOP；`--prepare-only` 仅生成新冻结尝试并标 PREPARED_NOT_RUN，不启动 RTL。

父任务在现有重工具结束后可串行运行（**本 agent 未执行**）：

```bash
/usr/bin/nice -n 19 /usr/bin/ionice -c 3 /usr/bin/taskset -c 0-3 python3 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_source_guard_v2.py --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_source_guard_v2_rtl_01 --control-attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_control_transport_rtl_01 --bootstrap-guard-attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/bootstrap_source_guard_rtl_09
```

若只准备冻结材料，给同命令增加 `--prepare-only`，但正式运行应使用另一个新 attempt；已有尝试不可覆盖。接入前须将上述所有实际 shell/transport/AR/AW/F9/LAC/monitor 事实接到唯一生产 wrapper，不能用本 TB controlled peers 填常量。v2 完成只代表该局部保护事实，C 仍需要真实 executor→F10→LN/monitor/one hub→actual END/unique retirement 的完整同-runtime证据。

本节追加前 result 48285-byte 原文 SHA256 为 `3dc2db8d733b55a0e94e80b10c5c81d066df1d6f52a87a3b277a6e4b0fe2552d`；此前 Stage C audit 与 LPV sidecar 全部保留。


## v2 实际 pilot 的 XSim 内部异常：只读定位与最小 TB 修复（2026-10-13）

父任务运行 `R003/executor_source_guard_v2_rtl_01`：旧收据保留 FAIL。实际日志已有 case0/1/2 PASS markers（normal AR4/R16/F9_32/LAC12；persistent cancel AR1/R4/F9_8/LAC4；source mutation AR1/R4/F9_8/LAC4），在25651ns `Initial482_28` 出现 `FATAL_ERROR: Vivado Simulator kernel ... exceptional condition`，未形成case3 marker/overall PASS。不是 current DUT `$fatal`；不能据前三case关闭整次验证。

只读 `xsimcrash.log` PC `0x5b4b80` 经 `addr2line` 归属 `execute_91`，`objdump` 该点为 `incl -0x4(%rbp)` 的 string refcount；前面读取 rodata `0x612470`/`0x6124b0`，两份 packed ASCII 常量正是 `RRESP_error_old_debt_drained` / `RLAST_error_old_debt_drained`。对应 frozen TB line568 的 `case_pass(fault==0?"RRESP_error_old_debt_drained":"RLAST_error_old_debt_drained")`。case3 actual HELD/GRANTED captures 已存在；该异常定位在 RRESP 场景末标签实参构造，而非新grant或R error断言。

只改指定 v2 TB：将该一个字符串三元实参替换成 `if(fault==0) case_pass("RRESP_error_old_debt_drained"); else case_pass("RLAST_error_old_debt_drained");`。fault循环、刺激、顺序、6case、cyclecap和所有断言均保留；RTL DUT不改。runner独立记录 `simulator_exception_lines`、`failure_kind=SIMULATOR_INTERNAL_EXCEPTION`，内部异常不能记PASS。Python AST PASS。新工具执行、attempt创建、重跑均 NOT_RUN，由父用新attempt串行验证。

修复后身份：
- `project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_executor_source_guard_v2_tb.sv`：34337 bytes；SHA256 `5afdaad065f15687977dffe8c04f862fbc91a870d7e95903d8da69323aebeb57`。
- `project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_source_guard_v2.py`：22061 bytes；SHA256 `51c05de9d64d7d39c3f44c0e6d01a4055668d19c7dccc64e065ba28c675e3aef`。

旧 attempt、其 frozen files、收据、原始日志及本 result 前文均未重写。实际 generated-adapter准备暂后置，继续按新的授权范围推进。


## Actual generated adapter + frozen sidecar + unique portal：有限准备交付（2026-10-13）

状态 **PREPARED_NOT_RUN**。本轮仅新增指定 TB/runner，并追加本 result；没有创建 attempt、执行 runner、编译、RTL/HLS/OOC、管理进程或创建 agent。原 v2 异常修复及其所有刺激/断言不再修改，冻结 adapter/sidecar/portal、共享 RTL/HLS/wrapper、catalog、登记和其他 agent 文件均未改。父 A002 持有实际串行工具队列；交付后停止，等待新的明确文件所有权。

### 新文件身份

| 文件 | Bytes | SHA256 |
|---|---:|---|
| `project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_executor_adapter_lpv_generated_tb_v1.sv` | 31456 | `9e809e763f2b5e221a2761051650c23cbbfb6929420a7d761c1a27839d9418fe` |
| `project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_adapter_lpv_generated.py` | 35765 | `e47192841b88a7bd6959cebb3cf11701a0b8f674e02d6693ff5e5ec0eca1d366` |

### 实际冻结依赖与独立静态事实

- 实际生成物来源为 `R003/controller_transaction_adapter_hls_03`，top `laya_command_provenance_adapter.v`：2088112 bytes，SHA256 `42f9056ad25de017d756f333de407925ae9f555c87f68c4b74db75a01471b558`。**原 HLS03 receipt 仍是 FAIL**：工具实际完成、guard child_exit=0/trigger=null，但 whole-file forbidden ap_ctrl 检查把内部 helper 的 ap_start/done/idle/ready 当成 top 端口。新 runner 原样保存旧 receipt，不重写 HLS 总结为 PASS。
- 独立只读 top header/declarations 核对：27 ports，8 FIFO × 3=24 signals，加 ap_clk/ap_rst/cancel；8 data 宽度均 512。真实 top 没有 ap_start/ap_done/ap_idle/ap_ready。内部 helper ap_ctrl 名称另记数量与有限 examples，不能用整个文件的关键词判 top。实际 `state[2:0]`、`beat[31:0]`、`cancel_at_accept[0:0]` 与冻结 C++ READ_INTERNAL=0 映射核过；TB 同时要求实际 F10 caller 最后第16个 LTC pop，HLS state0 不替代 caller drain。
- 旧已通过 `R003/controller_transaction_adapter_rtl_03` 的全部 generated closure 与 HLS03 当前保留生成目录逐项 SHA 相同：**248 .v + 16 .dat = 264 items**。旧 eight independently reset protocol cases 的 PASS 范围保留，不冒充本轮同-runtime portal 联合证据。
- 实際 sidecar 来源 `R003/executor_adapter_lpv_owner_rtl_01`（PASS_SCOPED_RTL_SIDECAR），SHA256 `8151a340a19cb40911880694455546095c47e6f3a6804390a2294f5f604e1eee`。实际 managed portal/dependencies 来源 `R003/executor_managed_lpv_rtl_04`（PASS），portal SHA256 `095a98cdfd100e267580dc8ecbcbc73f7f62d7b3dac3795dc36775326145d332`。新 runner 使用它们 passed frozen 文件；不以当前修改中的共享 source 偷换身份。
- 本轮只读核过 287 项 runtime frozen identity（包含重复共享依赖一致性），全部12个必须的共享 RTL 模块存在。sidecar44 / F10 shell29 个 named ports 词法闭包匹配；portal45 explicit +95 implicit ports 无缺名，TB 只有一个 portal/hub 实例。没有执行 SV parser/compiler，此检查不是编译 PASS。
- 实际 C++ captured A、独立 `admission_owner.bin` 与16-beat admission.hex 全1024 bytes 相同，binary SHA256 `40df536794b2377bb4955c106ce1a3eef8ded0a4b5c92d57c7f4eac218c56d0f`。安装仍是 controlled whole-record admission handshake；TB 执行真实完整 SV A codec，sidecar installed_owner/valid/revoked 直接取唯一 portal 真实输出。
- LTX1/LTC1 独立 wire-offset 算式逐字匹配旧 actual C++ BEGIN/END：1536-byte LTX 与1024-byte LTC 都全字节相同；描述符 region 在 LPV ref+6 与 LTX descriptor+16/+17 的位置变化显式处理，保留区仍零。七个 selected LPV literals 的 controlled LTX→raw LPV 独立反算也全1024 bytes 相同。没有编译 C++ helper，也未运行新 runner 的转换函数。

### 实际接线与四个场景

1. 真实首个 F10 LTX FIFO pop（24拍计数第0拍）只在 frozen sidecar txn_start_ready 允许时发生，直接产生 txn_start；后23拍继续原 txn。实际 LTC FIFO caller 最后第16个 pop 唯一产生 txn_done。八个 generated FIFO ports 真正连接：LPV raw command 进入冻结 sidecar collector，LPV return 经过其真实 private FIFO2；LTX/LTC 真实 FIFO2，另外四个 compute/producer 接口为真实空 controlled FIFO2，任何 traffic 均 fatal。
2. 实际 generated 16 LPV pushes 全收齐后才呈现 portal 首拍。candidate/pending/response 的完整 A、route、packet **全部来自 sidecar 实际 handshakes**，没有 TB 重造 LPV request 或绕过它的 ready。portal 唯一 hub 保持 owner/scope/退休权威。受控 link gate 成对门控双方 VALID/READY，计数实际同一次 handshake；旧 return 还须与 portal.transport.rsp_pop 精确相等。
3. 四个独立 XSim case，case 内不复位：case0 active CLAIM→BEGIN→wrong-origin bad END→matching reported-error END→INVALIDATE；case1 active CLAIM→BEGIN→END 在实际首 LTX pop及两个 actual raw LPV pushes后 cancel；case2 已呈现的 successful CLAIM return 后 cancel；case3 CLAIM-only→INVALIDATE，无 BEGIN/AXI/typed task。计划合计11个实际 adapter transactions，各自全24/16/8/16 bytes/write/pop比较，LTC tail2/tail1各12cycles保持；case0将下一笔 INVALIDATE 首两 LTX words 真正排入 FIFO2，最后 LTC caller pop之前禁止实际读取。
4. case0/1 的 controlled AXI producer 实际1 AW/1 W/1 B。producer-local finish obligation 由**实际 upstream AW**创建；实际 final B caller pop结束 B债，再经明确 controlled valid/ready finish edge清 local obligation。monitor.adapter_pending_zero=`!producer_owed`，绝不接 sidecar.txn_drained。held final B12cycles 与 B后producer finish fence12cycles分开要求 hub pending END保持、terminal0；finish真正握手后 END才可形成终态。不是 generated LN/F9 completion 或完整生产 fence 验证。
5. case1 同时保持 cancel、live base epoch8/current txn_route1：actual raw partial2、actual portal partial2各12cycles，sidecar retained A/route0与whole pending固定；真实 private return FIFO2满保持12cycles，portal LPA剩2/1拍各12cycles，真实 adapter消费全部8拍，LTC尾拍后才释放local txn。唯一 hub实际 terminal_tasks要求恰1，old owner仍1，不把取消后的新 cleanup 视为已执行。
6. case2 已呈现 actual successful CLAIM response 在 cancel下保留，零虚构 AW/W/B、scope或typed retirement；case3实际 CLAIM-only cleanup由hub核定，typed0。两种 CLAIΜ路径保留外部installed A，不自清 request/revoke，不声称 CLOSE/rearm。

**物理/数值范围核对：** frozen managed BEGIN 的 geometry 是 row16 ×4096-byte（total65536），expected F32 elements16384，numeric identity仍完整B1/S64。这些字段不改。有限 controlled writer仅实际写64 bytes，matching END本来报告 status7/detail0x07100007/bad19、issued64；独立 gold要求 observed64与一次错误终态。该场景证明有界 transport/physical causal drain，**不是完整 rows16 正常计算、LN数值或C首请求计算 PASS**；前摘要中“one64-byte geometry”不能用于解释当前冻结 BEGIN。

### 新 runner 的证据、资源与停止规则

- 必须同时提供原 HLS03、旧 actual adapter RTL03、passed sidecar01、managed LPV04 的明确路径；校验 receipt→input_manifest身份及实际 top SHA/端口。冻结旧 receipt/manifests、264 generated .v/.dat、shared DUT与source closure、actual A/独立binary/hex、原literal请求/独立gold、旧 C++ codec cross-check inputs、当前TB/runner、三个合同、tool身份和派生 Tcl。
- selected literals 只来自 passed managed attempt；离线独立构建 LTX/LTC 的 binary+hex 双份并保存源/派生身份。实际运行捕获 actual LTX、actual raw generated LPV、actual portal LPA、actual caller LTC；每个case退出后runner再次对串接全capture做独立 whole-byte核对。三个不同意义的事实分别记账：原HLS FAIL、top-only8FIFO事实、本轮 actual adapter+portal有限RTL结果。
- 父最新资源分类澄清已采用：**compile/elaboration=现有 static24GiB/1800s、120s真实停滞；四个独立有限RTL pilot各8GiB/120s、120s真实停滞、500k cycles cap**。CPU0–3、nice19、idle I/O、MemAvailable>192GiB，工具严格串行。旧 adapter static112.12s是旧身份成本证据，不当作新成本承诺。此分类不增加项目预算；触帽COST_STOP保留，不自动扩大或重启。
- 编译/展开一个snapshot，.dat逐项身份确认后放到实际XSim cwd；四个case顺序运行，独立120s帽。无wave大文件。工具退出0/guard child_exit0且无trigger、static marker唯一、每个case marker/transaction数量/实际capture完整匹配才可记 `PASS_SCOPED_RTL_ACTUAL_GENERATED_ADAPTER_PORTAL`。FATAL_ERROR/internal exceptional condition记录 `SIMULATOR_INTERNAL_EXCEPTION`，不能PASS；失败/partial captures不能把COST_STOP或内部异常抹掉。
- `--prepare-only` 创建一个独立准备attempt后即返回 PREPARED_NOT_RUN；同一路径不可再覆写/复用。**本子agent没有调用该选项或任何 runner**。本轮仅 Python AST和上述只读 identity/wire/port词法检查。

父实际串行命令（attempt须不存在，执行人父A002）：

```bash
/usr/bin/nice -n 19 /usr/bin/ionice -c 3 /usr/bin/taskset -c 0-3 python3 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_adapter_lpv_generated.py --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_adapter_lpv_generated_rtl_01 --generation /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_adapter_hls_03 --adapter-rtl-attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_adapter_rtl_03 --sidecar-attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_adapter_lpv_owner_rtl_01 --managed-lpv-attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_managed_lpv_rtl_04
```

### 冻结接口缺口与下一次文件所有权建议（未实施）

当前 frozen sidecar 一旦 txn_revoked/owner_revoked粘住，就无条件关闭所有后续first LTX，包括旧BEGIN后新END与CLAIM-only新INVALIDATE。cancelled case1/2将cleanup首两words真正排入FIFO2，恢复live cancel/base/route后仍12cycles阻断并输出known-gap；这是**缺口观测**，不能拿它签cleanup收束。父已核定 `D-M003-EXECUTOR-OLD-LTX-CLEANUP-01`；当前TB仍锁旧frozen实例，取消发生在实际END first pop之后。新合同不在本交付中实施。

后续建议分工由父另发明确授权：
- **父唯一executor/FSM owner** 增加真实Machine pending出口：持久完整LTX1536-byte或硬件可核的immutable record、完整旧A及适用K关联、真实旧route、完整action键/阶段、已交adapter/已对外呈现等实际状态；来自实际TX_WRITE/TX_READ/after_transaction与scope/CLAIM/producer完成，不从sidecar/live输入或TB重建。尚未首pop也必须已有真实pending，解决“先pop才知可pop”的循环。
- **单一新collector/sidecar/wrapper owner** 在唯一事务边界接受上述完整pending，收最多一份24拍候选，全字节/保留位/完整owner-route匹配，collector首pop和F10 actual首pop分别计数，直到同笔真实16拍LTC caller pop才释放。正常原txn_start_ready路径保留；持续撤销下仅匹配旧pending候选可以收集，完整核验后END/INVALIDATE可尝试原adapter/hub。不能补裸cleanup bool或从短seq/hash/当前A推断许可，也不能在txn_done清撤销以重开业务。建议新版本文件或父明确升级文件，当前frozen v1与此诊断TB保持可复用。
- **父另定 managed adapter source owner** 实施其提出的 `LAYA_MANAGED_TRANSACTION_ADAPTER` 受控宏：top/signature/wire保持，managed whitelist仅END/INVALIDATE，legacy RELEASE默认范围保留；READ/PREPARE保存同A持续cancel、外部首呈现前实际pre-dispatch LOCAL_REJECT路径；一旦外部write已尝试/VALID已呈现就持帧继续，accepted_beats0不充当“从未呈现”。ordinary真实旧pending完整合法且未外发，只能经实际adapter原reject_internal→make_local_reject→encode产生16拍负完成，不由collector/sidecar伪造。父负责shared executor接口；实现/受影响host/HLS/新冻结验证属于另一次明确分配。
- hub/monitor继续唯一核定scope/物理安全/最终END或INVALIDATE；真实executor仍经原完成消费与after_transaction唯一退休。producer fence与F10 transport drain分离。不修改Host/LTX/LTC/LPV协议、不建第二owner/发布/退休表，不扩D/逻辑版本/QUANT/CLOSE/rearm。

本次没有actual simulation结果，不签同-runtime C链、normal LN/full tensor、Q、accepted-request recovery、M003/M004或新资源/时序结论。追加前 result 62637-byte prefix SHA256为 `94722389f7ffe590752d2908855b32fa7e68bd56e2465c2fdccb0e92c9a7b040`；此前全部记录原样保留。


## Managed actual adapter 宏：pre-presentation LOCAL_REJECT 独立准备（2026-10-13）

父任务新授权严格限于实际 `hls/platform/controller_transaction_adapter.cpp`、新 `tests/controller_transaction_adapter_managed_test.cpp`、新 host-only runner `tb/run_controller_transaction_adapter_managed.py` 与本 result。状态 **PREPARED_NOT_RUN**。仅上述文件修改/新增，未动旧 TB/runner/sidecar/header/FSM/catalog、任何冻结 attempt 或其他 agent 文件；未运行 runner、编译、HLS/RTL/OOC、创建 attempt、管理进程或创建 agent。父正持有工具时隙，当前新 adapter 不纳入其正在冻结的 executor/program 闭包。父所报旧冻结 actual adapter/sidecar/portal片段01四case343711cycles PASS属于原f225 source/42f9056 generated RTL；不是下述新宏验证。

### 文件身份与最小实现

| 文件 | Bytes | SHA256 |
|---|---:|---|
| `project/E002_Laya_HLS/experiment/hls/platform/controller_transaction_adapter.cpp` | 23563 | `31ae50be63eb4ec2ffdb7945172f390010ac11d1344bf858ac8035ea0927b090` |
| `project/E002_Laya_HLS/experiment/tests/controller_transaction_adapter_managed_test.cpp` | 15020 | `67dbf2b15c457b34772e05d6bbaab4cc22810279599cd4ffe1c9fcd2fd38758f` |
| `project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_controller_transaction_adapter_managed.py` | 18939 | `f660d1514e6002bb95dbbc004af3e64294632ade4d9174446196ebca284e6e33` |

依据 `D-M003-EXECUTOR-OLD-LTX-CLEANUP-01`，macro=`LAYA_MANAGED_TRANSACTION_ADAPTER=1` 时生效：

1. managed cleanup_allowed仅 `Kind::PROVENANCE_TRANSACTION` +原 `CANCEL_CLEANUP` + `END/INVALIDATE`。完整 LTX decode先拒绝未知flags/坏帧；合法bit不替代旧A/pending/完整BEGIN或owner匹配。RELEASE只在默认legacy宏分支保留；CLAIM/BEGIN/PUBLISH/COMPUTE/PRODUCER不能借该bit在撤销下外发。
2. managed增加两个**transaction-local transport**事实 `transaction_cancelled`、`external_presented`。first actual LTX read建立它们；后续partial READ、READ空等待以及PREPARE/SEND/response/write阶段看到cancel时保持sticky。PREPARE在实际完整parse后再次取cancel；SEND在word准备之后、首次write_nb尝试之前再次取cancel。wrapper必须提供**同旧A持久撤销**，完整A/K/route/pending由父唯一wrapper/FSM负责，本源不造A验证/owner表。
3. 完整合法普通帧在首次外部呈现/尝试之前撤销，直接复用实际 `reject_internal(request, Check{E_PROTOCOL, detail(7,0,14)})` → `make_local_reject` →原 LTC1 encode，进入 WRITE_INTERNAL；16实际write及caller16 pop的原通道不改。结果仅 FRAME_COMPLETE|LOCAL_REJECT，非OK、原binding字段完整，无 BINDING_OK、REMOTE_DRAINED/SCOPE_ACTIVE/TERMINAL/PUBLISHED。
4. SEND在**write_nb调用之前**置sticky external_presented，和written返回/beat递增独立。即使这次没有accept也不能改成本地“从未呈现”负完成；之后旧beat/packet保持原transport，完整帧与真实8拍return继续，normalize既有返回不变，不删FIFO、不reset、不双发。真正首次尝试而未accept的动态证据仍需要bounded RTL。
5. 两个managed局部事实只在原最后第16个 LTC **write**后清掉，回 READ_INTERNAL；外部同A revoke不能因此清掉，F10/sidecar依原规则持续到实际第16个caller pop，后续collector根据信任旧pending择路。当前top/signature/8FIFO/外部wire不变，没有额外端口或绕过原F10。

默认macro未定义/0时无新状态或cancel采样行为，仍只使用原cancel_at_accept与原END/RELEASE/INVALIDATE cleanup范围。静态文本核对：去掉managed条件区、折叠唯一等价cancel局部alias和first-pop if braces后，**全文件文字逐字等于原冻结 adapter CPP**（原SHA256 `f22569b4bf84be99a3d586976db5a9e6b813a2f7af8da11383b93b9fb56bece5`）。这不是默认C++新编译结果；父runner仍安排一次原默认test build/run做实际兼容验证。

### 新独立host测试

- 消费已通过 `controller_transaction_adapter_rtl_03` 的原24/16/8/16完整 C++ fixture literals，不重编原fixture generator。compute/producer/begin/end LTX经过真实codec完整decode与encode逐字回环；非task LPV CLAIM/PUBLISH/RELEASE/INVALIDATE保留该原model/identity/descriptor，显式zero_context/zero report/geometry，仅改原action和seq。所有输入合法、完整，不以坏/未知归属帧制造可信local binding。
- 88个顺序独立host transaction，全部旧输入/返回流排空后再开始下一笔：8种frame ×6个撤销时点=48本地拒绝；COMPUTE/PRODUCER/CLAIM/BEGIN/PUBLISH/RELEASE带伪cleanup许可bit、half-read和SEND前两时点=12本地拒绝；END/INVALIDATE携带原flag ×6时点=12受控remote返回；8种已首write后撤销与8种正常无撤销=16受控remote返回。合计 **60 LOCAL_REJECT +28 remote =88**。六个外发前时点为first pop、首pop后READ空等待、half read、最后input pop、PREPARE、SEND首次write之前；撤销脉冲恢复后仍检验sticky。
- LOCAL_REJECT expected LTC由**独立固定wire offsets**构造，禁止用DUT的make_local_reject/normalizer生成gold：原common seq/origin/full84-byte numeric identity/Context、COMPUTE全部6Ref/3Context/regions/epochs/rows/futureRef/default rank、PROVENANCE count/全部target+old refs/regions、PRODUCER source/destination/D/gamma/roles/regions/eps/rowbytes/offset/strides均显式映射，固定status7/detail0x0700000e/badUINT64_MAX/flags0x41及reserved0。每次实际完整1024-byte LTC全字节比较。
- 每个LOCAL_REJECT再独立改expected seq、numeric request_id、Context.task、primaryRef epoch、region、kind及一项family完整字段（COMPUTE quant Context、LPV oldRef、PRODUCER eps）；7种全binding错配均要求实际codec撤销FRAME/BINDING/TERMINAL信任。正确本地返回仍无任何remote事实，不将localReject当typed终态。
- 正常/已呈现旧帧核对全部16 actual external words；controlled response first1后四次持续cancel call不得出现LTC，剩7个真实response reads后继续原remote normalized16 LTC，不双发。COMPUTE/PRODUCER remote gold直接来自原fixture；LPV remote gold为独立LPA→LTC fixed-offset映射。普通non-task LPV受控返回status E_BUFFER=5/detail0x04000008，避免把尝试cleanup说成hub已成功。这些不是实际hub服务结果。
- 所有实际caller LTC pop16，tail2/tail1各保留12个host call，结果不消失/重发；实际8条host streams最后都为空。输入、expected-LTC、actual-LTC和remote时actual-command/controlled-response全部保存为完整hex，父runner再次逐文件比较actual16beats与独立gold。
- vendor `hls_stream.h` 的当前 host `full() const { return false; }` 已只读核对。**host无界**：first attempt但未accept、VALID在READY0下保持、深度2/F10 caller最后pop interlock仍 **NOT_RUN**，不能由write_nb成功后的host场景扩展为这些RTL证据。所有A/pending/cancel来源是明确controlled peers；actual同A wrapper/collector与HLS/RTL新行为也 **NOT_RUN**。

### Host-only runner与资源

- 仅build/run一次原默认 `controller_transaction_adapter_test.cpp` 与一次新managed binary，明确-DLAYA_MANAGED_TRANSACTION_ADAPTER=1；不执行full/HLS、原fixture generator或无关回归。父现有源list7项被完整冻结，递归project literal include闭包先保存；实际guarded static中对每个TU/宏运行compiler `-M`，确认每个project依赖已冻结，同时记录所有actual system/SDK headers身份及前后变化，缺冻结依赖即FAIL。tool compiler/version/flags、SDK hls_stream身份、contracts、旧receipt/manifests/原literals、原/新tests、runner、guard/helper与binary身份全留。
- 真实启动由父以CPU0–3/nice19/idle I/O/MemAvailable>192GiB，单重工具串行：**static build/dependency discovery 24GiB/1800s/120s真实停滞；各有限host run8GiB/120s/120s停滞**。默认/managed分别保存guard/raw logs；无guard触帽且退出0、独立marker完整、88唯一case IDs、60local以及全部88实际16拍captures匹配才能记 `PASS_SCOPED_HOST_MANAGED_ADAPTER`；触帽COST_STOP，不重启/加帽。
- runner的PREPARED_NOT_RUN是可选新attempt冻结准备；已经存在的目录不能覆盖。**本child未调用runner任何mode，没有attempt**。仅轻量Python AST、C++source文字/宏分支比较、静态时点/case数量/字段映射核对；C++编译与所有88例仍NOT_RUN。

父串行命令（新attempt须不存在）：

```bash
/usr/bin/nice -n 19 /usr/bin/ionice -c 3 /usr/bin/taskset -c 0-3 python3 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_controller_transaction_adapter_managed.py --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_adapter_managed_host_01 --adapter-rtl-attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_adapter_rtl_03
```

本任务只处理实际adapter的拒绝与已呈现旧帧保持；完整validated pending collector、executor出口、immutable A/K/route、永久owner revoke、BEGIN/CLAIM事实、producer物理END与唯一hub核定仍由父另行整合。新宏须进入新的受影响host/HLS/RTL冻结，旧42f9056 generated RTL不能冒充已实现新行为。默认legacy/新managed host均待父执行；C/D/完整LN/Q、CLOSE/rearm、M003/M004及新资源/时序结论不签。交付后停止写入，等待父实际结果或新明确文件授权。

追加前本result76147-byte prefix SHA256 `1e64491ee6635d063c974de30dbf2186e5b6d0d8f4f7a739bf2c1336bcf83c16`，全部旧记录保留。


## Executor03 Inputs copy 假设：只读读写/生命周期与gdce核查（2026-10-13）

本轮授权为**只读共享实现和既有03 BC**，仅本result追加。未修改任何implementation/header/config/runner/attempt，未编译/HLS/RTL/执行测试/创建agent/管理重工具进程。使用现成Vitis `llvm-dis`将03已终态BC只读反汇编到stdout；未安装软件、未生成IR文件。root唯一整合，此结论只是单变量结构修复准备，不证明aggregate copy造成三轮semantic stall。

### 当前身份与03稳定IR事实

下列current与`R003/executor_hls_03/frozen`逐项完全相同：

| 文件 | SHA256 |
|---|---|
| `hls/control/executor_stream.cpp` | `fc9d0c8450888565d976ea14db23c4abd9229d959f4e466e62301d3a5a4bd826` |
| `hls/control/executor_hls.cpp` | `21c0ae26bd0b74a648c5a76cf4922bad9b2d8b946939be5e14090981c0e4d1da` |
| `hls/control/executor_actor.cpp` | `5cc361807fff8387de3793fb97042832024c7e7d444408f9942f061c68c04fbd` |
| `include/laya_executor_stream.h` | `4137d042cfa5f625e67b47e1e72c73be9287ce2847e49094d3097325a94bd3ec` |
| `include/laya_executor_actor.h` | `674447592cbee1089b346125d9d1366561f91241f4fd8b2f8d2b32d365776ef2` |

- 实际03 receipt为COST_STOP，hls.guard elapsed285.634333204478s、peak1474268KiB、semantic_stall、child_exit=-9，0top。Compile/Link227441是编译诊断量，不是计算周期/资源/吞吐收益，不按inclusive函数数字相加。
- `R003/executor_hls_03/work/hls/.autopilot/db/a.g.ld.5.gdce.bc`：1212144 bytes，SHA256 `fdd8fc69ca9b6936b84f80fd83b947706ea063503d6a29ca65b9bc118c733dca`。decoder为Vitis `lnx64/tools/clang-3.9-csynth/bin/llvm-dis`，2090112 bytes，SHA256 `880acc2948de595512d36d9cd996b64e2e213e9ac3fb8e13db55d62c326ae4b6`；需要仅该进程的Vitis/Vivado lib/lnx64.o loader路径。只读decode exit0。
- 按真实`call/invoke`指令建立direct top可达图：450个defined函数可达，17个undefined external declarations全是LLVM intrinsics；未发现普通未定义libc/C++外部call或间接call。17种为dbg.declare、lifetime start/end、memcpy/memset、sideeffect，512/8192 FIFO的nb push/pop/not.empty，2496/512/8192 part.select及512/8192 part.set。**整个该gdce中memcmp函数definition/declaration及top可达call均为0**；字节比较修复已确实移除memcmp，仍不能解释03为何stall。保留的LLVM memory intrinsics不能说成普通外部memcpy/memset未映射。
- Inputs的03 ABI `dereferenceable(2464)` 和 `llvm.lifetime.start/end(i64 2464)`都明确存在，不是本轮重新sizeof编译推测。stream entry真正保留一个2464-byte Inputs对象alloca；另有`Inputs*`参数地址alloca，不能错计成第二个完整对象。
- source53的`Inputs in=live`在gdce的实际形式是**整aggregate load/store**，并非2464-byte memcpy call：

```llvm
%1 = load %"struct.laya::executor::Inputs"*, %"struct.laya::executor::Inputs"** %live.addr
%2 = load %"struct.laya::executor::Inputs", %"struct.laya::executor::Inputs"* %1
store %"struct.laya::executor::Inputs" %2, %"struct.laya::executor::Inputs"* %in
```

这证明该duplicate snapshot在最后已完成gdce阶段尚未消掉，仅是可区分结构候选。FIRST top自身还调用Inputs default ctor；该ctor的host_result256/cancel_drain_record1024 memset和AdmissionFence/BufferRef/PhysicalMap/Fence/Message子constructor均保留。仅消除stream copy不会自动消除这些初始化、条件whole-record赋值、actor内部physicalMap/fence副本或巨大static State/Entry初始化；本建议不将它们捆绑修改。

### executor_stream::step全部live/in读写

`executor_stream.cpp:39–207`：`live`仅在参数声明40和**53的完整一次复制**读取，没有其字段的独立读写、没有const_cast、`&live`保存、move、callback或后续复读。下表覆盖Inputs全部20个声明字段：

| 字段 | stream局部in写入/保留 | 后续读取与意义 |
|---|---|---|
| request_valid | 67仅first_admitted时false，否则继承live | actor193/207，真实首次准入后不能从old IDLE重入 |
| checkpoint_valid | 无写，继承live | actor251，实际checkpoint入口 |
| cancel | 68 transport_error及111坏response时true，不清已有cancel | actor活动各phase撤销；保留旧清理 |
| session | 无写，继承live | actor200/210/226等，旧session绑定 |
| accepted_request | 无写，继承live | actor201/210/226等，完整请求高水位 |
| admission | 无写，继承live | actor准入/物理安全/错误关闭读取 |
| source | 无写，继承live | actor254→reserve_hold，source按值 |
| physical_map | 无写，继承live | actor231按值本地复制后capture A |
| fence | 无写，继承live | actorlive/base保护/HELD/import；actor273另按值副本 |
| action_completion_consumed | 60清false；145只由完整bound LAC echo消费置true | actor371/375，取消consumer/正常port推进 |
| control_request_consumed | 56清false；82仅完整原control receipt验证后true | actor WAIT_HELD/IMPORT/ABORT/CLOSE读；不可由caller抽象bool代签 |
| control_response_valid | 57清false；106完整decoded response可交actor时true | actor响应phase读 |
| control_response | 106复制decoded完整Message；未offered时保留原值但valid=false | actor完整键/HELD/GRANT/CLOSED；stream163、179 kind及180 same_key在actor返回后仍读取 |
| result_consumed | 59始终清false，不置true | actor legacy path读；managed必须完整host result receipt |
| program_owner_confirmed | 63仅require_program_owner=true时覆写真实t值，否则保留live | actor346，真实program whole-record确认才能发首LGP |
| managed_close | 61强制true | actor243按值latched，完整CLOSE/Host消费路径 |
| host_result_valid | 58清false；126完整bound host result receipt时true | actorobserve_host_result门限 |
| host_result | 126复制完整256-byte t.host_receipt.packet | actor104/105同步decode+全packet等于actor result |
| cancel_drain_valid | 64仅require_program_owner=true时覆写真实program_pending_valid，否则保留live | actor366，唯一旧cancel consumer选择 |
| cancel_drain_record | 65仅require_program_owner=true时复制完整1024-byte t.program_pending，否则保留live | actor113完整decode+key/action/cmd匹配；不能改成无键许可 |

共13字段有局部写、7字段原样转交。stream调用154的`executor::step(..., in,...)`是actor对完整Inputs的主要读取；stream自身除该传参以外，只有control_response的post-actor读取。**不能只提取pre-actor事件然后丢掉in**：GRANT安装和revoked GRANT fallback依163/179/180的同一次完整decoded Message，需保留到stream函数结束。

### Alias与保存生命周期

- Inputs成员都是值（scalar、struct、std::array），没有引用/裸指针/span/动态owner。State/Transport里也没有Inputs指针或引用。stream赋值decoded/control/host/pending都是值复制，不保留decoder局部地址。anonymous `const auto& expected`只借用actor正常/cancel completion_packet作本次pre-actor比较，不指向Inputs、不越过调用保存。
- actor及`live(const Inputs&)`/`observe_host_result`/`begin_cancel_consumer`同步借用const Inputs；未发现把Inputs或其字段地址存入State/Transport。持久状态是值：session/accepted_request、admitted_base、managed_close、closed_record等；cancel_drain解码到本地Record再值赋给cancel_consumer.owner。physicalMap/fence及下游checkpoint/owner record也按值保存完整字段，不依赖该temporary返回后的生命。
- 当前const API的**caller不变与snapshot**是可观察语义。`tests/executor_stream_test.cpp:42`的Harness.in是跨call持久成员；71调用后，80还用`in.cancel`驱动adapter；127/128故意把caller消费bool置true，393/394还写caller.control_response。就地改动这些调用会改变caller状态及后续测试/调用，不可把existing step简单改为`Inputs&`，不可const_cast，也不可加同名nonconst overload让原mutable caller自动选新路径。
- 仓库hls/include/tests中step的真实call sites只有两处：此Harness71与FIRST top242。actor其他caller直接调用executor::step const API，与本stream copy假设无关。
- FIRST top `executor_hls.cpp:165` 每次函数调用创建新automatic Inputs；166–179只填入当次锁定session/map/revoke/source/fence；ADMIT/RUN242借给stream后，246–252只读s.actor/s.revoked作Entry phase决策并立即return，**未再次读/写in**。其他非FIRST entry phases虽也建立Inputs，却不调用stream且不再使用它。FIRST本身149–158提前return，未建立该对象。该top temporary不与actor/Transport嵌套payload alias，未保存其地址/跨调用复用，适合明确的borrowed mutable内部入口。
- top构造in之后，program owner/pending接收可能设置t.transport_error/s.revoked；当前stream恰在68把该实际t错误覆盖到临时in.cancel。新就地入口必须保留原事件覆盖顺序，不能只在top构造时采样cancel，也不移动Inputs构造来改变其它采样时点。

### 最小具体结构建议（仅建议，未实施）

1. `include/laya_executor_stream.h`新增名字明确且独立的内部声明，例如`executor_stream::detail::step_in_place(..., executor::Inputs& in, bool receipt_ready, 原全部FIFO refs...)`。它仅允许caller持有的fresh独占scratch，在调用后允许13个派生字段改变，不在任何持久state保存引用。`namespace detail`跨两个cpp可见，不能放匿名namespace后让top链接不到。
2. `executor_stream.cpp`把当前body（保留#pragma HLS pipeline off、全部实际consumer验证/actor调用/post-actor fallback/control发送次序）搬到该内部函数，唯一删除body里的`Inputs in=live`，参数直接命名in；actor::step仍收const Inputs，不改actor/FullRuntime/协议/事件金样。
3. 原公开`executor_stream::step(...const Inputs& live...)`签名和行为保留：仅`Inputs in=live; detail::step_in_place(...in,...);`。于是legacy Harness仍得到原snapshot/caller不变语义，共用同一个真实consumer body，避免两个事件派生实现漂移。
4. FIRST top的242只将call目标改为该`detail::step_in_place`，把165原fresh mutable in传入。不改变任何top端口、Inputs字段、宏/初始化、s/Transport保存、A/pending/cleanup/physical语义；不新增协议/allocator/第二owner表，也不顺带消除large payload初始值或改变loop/unroll。

### 必须受影响验证与区分出口

- **const兼容和caller隔离**：重跑受影响`executor_stream_test.cpp`现有完整consumer/反压尾拍/拒绝/GRANT fallback/CLOSE及first_admitted测试；加一项显式20个值字段输入前后比较，确认const wrapper未修改caller（不比较未定义padding）。require_program_owner true/false两种条件覆盖，以及live中抽象消费bool/data的恶意输入仍不能代签真实receipt。
- **新旧入口差分**：相同canonical事件/physical map/memory，独立State/Transport/FIFO，旧const step用持久live、内部step用每次fresh scratch；逐调用比较全部外发packets、actual pops/receipt accepted或rejected、actor/Transport phase/counters、A/GRANT/pending、sticky revoke和高水位。覆盖request receipt与response先后、连续accepted/rejected response ready、Host/LAC尾2/尾1、坏frame/error、revoked IMPORT GRANT fallback且CLOSED禁止fallback，保证post-actor读同一Message仍正确。
- **FIRST host闭包**：重跑受影响`executor_hls_top_test.cpp`/当前实际FIRST host runner。保持完整A16写/16真实安装receipt、owned program全GRANT receipt/LAP消费、cancel/base/session变化、零提前command/作用、phase/rearm隔离以及原不同process的FIRST初始化金样。actor实现不改，其独立未变已通过测试可引用原身份，不能把它要求成额外无关full回归。
- **新有限HLS单变量对照由root执行**：新冻结只含上述copy入口结构差异，与稳定03配对同source/model/ports/原分类资源/单工具预算。先看actual gdce top可达是否不再经过const-wrapper copy、无第二Inputs对象alloca及2464 aggregate load/store；即使legacy wrapper未被module删掉，也应按**top reachability**而非全文件关键词判断。要求无普通external/memcmp重新引入、actual stream/actor consumer路径仍可达。
- 编译指令量/阶段进展/guard触发、是否生成top、真实端口与后续有限RTL行为分别记录。新HLS若仍同停点cost stop，只说明消除此copy不足以解除当前阻塞；若有前进也不能单凭一次关联断言该copy是唯一原因。Inputs ctor、1024 pending赋值、其他aggregate/state构造另做独立假设，不合在此对照里；没有actual generated RTL、同runtime真实LN/C周期/联合资源，不能签硬件收益。

本报告没有实现上述结构、没有测试/新candidate/新工具实验；仅确定当前copy仍存在且fresh top lifetime允许保留const API的独立就地入口。03 memcmp已消失与ordinary external0是现有IR事实，绝不当作stall根因关闭。本result追加前prefix长度与SHA在本次实际回执记录，旧交付与managed adapter冻结继续保留。


补充时间边界：上述五项current/frozen03 identity比对与行号均在root最新三文件 `step_in_place` patch之前完成，适用于保留的03冻结源码/BC。本报告追加后root通知其patch现已存在、未验证，计划fresh executor host07/HLS04串行；本child未修改或代签该patch，当前live source不应再拿上表旧SHA作最新身份。下一gdce区分检查仅需确认FIRST top到in-place core、原const wrapper不可达（或无该copy可达）、无2464 aggregate load/store副本、同consumer/actor/post-actor GRANT/CLOSED语义仍在，ordinary external/memcmp仍0；caller默认Inputs ctor等本来保留的成本须单列。该结构建议不把stall根因登记为已证，未运行新candidate。


## Executor04 step_in_place：实际 gdce 只读区分与终态（2026-10-13）

本节继续由 root 授权只读既有04源/BC/guard证据，仅追加本result。未改共享实现、header、配置、runner、04 work/frozen/receipt或任何原工具证据；未启动compiler、LLVM pass、HLS/RTL、新agent或管理任何重工具进程。root明确允许沿既有 `llvm-dis → stdout/内存` 方法完成有界解码；这不是新综合实验。root反馈fresh executor host07七process PASS；04 receipt实际记录精确复用该host身份、`source_identity_exact=true`、`PASS_SCOPED_HOST`，本child没有运行这些测试。

### 冻结差异及源行为边界

只读比对03与04冻结的三项改动：
- stream原body改名独立 `step_in_place`，参数从const live改为mutable in，仅移除 `Inputs in=live`；其余完整consumer验证、actor调用、post-actor GRANT安装/撤销回退与control发送顺序文字保留。
- 旧const `step` 新建 `Inputs scratch=live` 后委托同一core，保持legacy调用者snapshot/不变语义。
- FIRST top唯一call目标从step改为step_in_place，传入同一次fresh automatic Inputs；header新增独立名称及不alias持久状态/不在调用后再读scratch的约束。没有同名mutable overload或const_cast。

| 04冻结文件 | bytes | SHA256 |
|---|---:|---|
| hls/control/executor_stream.cpp | 10164 | `65cb75d68218989600742c684e80508ca376eacc67674a4521d13719bdb1e98d` |
| hls/control/executor_hls.cpp | 13403 | `36f198627c33d6ab8a73fcdb0d0ecefc2a6ea765e3091a181d12aa2ce1dd2166` |
| include/laya_executor_stream.h | 4390 | `ed75c49970dc92de4d5feff8d64932c33aa1f2a48a174fced8268407501476bc` |

本项是copy入口结构区分；未将原20字段含义、完整A/pending/owner/Host/LAC消费规则或post-actor Message生命周期改成其他协议。文字/IR可达性不单独代替差分host或实际RTL行为证据。

### 实际BC与解码身份

- 产物：`R003/executor_hls_04/work/hls/.autopilot/db/a.g.ld.5.gdce.bc`，**1212028 bytes**，SHA256 **`19c12c3b6108d7cb8e626a423e2fad528ee9db3a3610fd1f29b9e7c951a52aa5`**。第一次读取及严格复核前后全部相同；没有修改或新建.ll。
- decoder：`/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/lnx64/tools/clang-3.9-csynth/bin/llvm-dis`，SHA256 `880acc2948de595512d36d9cd996b64e2e213e9ac3fb8e13db55d62c326ae4b6`。
- 实际argv为 `[decoder, "-o", "-", BC绝对路径]`；仅该解码子进程的LD_LIBRARY_PATH设为 `/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/lib/lnx64.o:/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/lib/lnx64.o`。严格复核记录时间 `2026-10-13T04:43:06.179042+00:00`，timeout30s，实耗 **0.14804621413350105s**，exit0，stderr空。
- 解码到内存的IR为6952920 bytes，SHA256 `943150e17b5f929c3bb1c13f625fa2715e26232882dcf44274aeef65f69e8c34`。这是stdout身份，不是存在于work的新文件。

### 真实可达图、copy与callee核验

严格只匹配实际instruction opcode `call/invoke`（允许SSA赋值及tail/musttail/notail前缀），不是搜索任意单词call。第一版宽匹配误将SSA变量 `%call` 的br/ret/load/store等使用列为indirect候选；这些候选输出又被截断，所以未据该列表签0。经root确认沿已授权只读方法，第二版完成严格复核，结论如下；direct可达图与copy观察不受第一版候选错误影响。

- root为真实 `laya_task_lifecycle_executor`。该gdce定义450个函数，**450个全部top可达**；真实call/invoke指令5599条，**actual indirect=0**。
- top实际直接调用 `laya::executor_stream::step_in_place(... Inputs& ...)`；原const-wrapper的函数定义在该gdce中已为**0**，因此top没有经过旧wrapper。不是以全文件step关键词或新源码call目标替代IR。
- core实际直接调用原 `laya::executor::step(... const Inputs& ...)`；actor返回后，Inputs.control_response（field12）仍有**3条GEP**，分别对应原完整Message的GRANT安装与revoked-GRANT fallback读取。不能把新core当成仅pre-actor事件抽取。
- 整个该IR的Inputs aggregate操作仅有top的 **1个 `%in=alloca Inputs`**。**Inputs aggregate load=0、store=0；core内Inputs对象alloca=0**。保留Inputs*参数地址alloca不能算作完整2464-byte对象。top仍有1对2464-byte lifetime start/end。
- Inputs ABI仍 `dereferenceable(2464)`；其default ctor仍top可达，调用AdmissionFence、BufferRef、PhysicalMap、Fence、Message各1个子constructor，保留256-byte host_result和1024-byte cancel_drain_record两个memset。copy移除没有消除这些构造或条件whole-record赋值。
- top可达未定义符号共17种，均LLVM intrinsics：dbg.declare，lifetime start/end，memcpy/memset，sideeffect，512/8192 FIFO nb push/pop/not.empty，2496/512/8192 part.select及512/8192 part.set。**ordinary external=0**，不是把LLVM memory intrinsics误记成普通libc函数。
- **memcmp definition=0、declaration=0、actual call=0**（整个该gdce）；本次未重新引入该普通外部路径。

因此此次实际干预确实移除了03所见的2464-byte duplicate snapshot，而不是仅改名或隐藏源码复制。该事实不证明原复制导致stall，也不代表任何硬件资源/周期收益。

### 终态与进程观测边界

04实际receipt为 **COST_STOP**：
- guard elapsed **280.4685273785144s**，peak_owned_rss_kb **1454096**，RSS sample/capture均1401，minimum_mem_available_kb426972800；
- trigger **semantic_stall**，child_exit_code **-9**，runner_exit_code1；finished_at `2026-10-13T04:38:22.251483+00:00`；
- `work/hls/syn/verilog` 实际.v列表空（0top），whole production chain和CLOSE/rearm仍NOT_RUN。
- receipt身份288159 bytes，SHA256 `5a8416789372318ad7eea09ba0d35a40b728c772e4871c17032dadc918e133f5`；04 input_manifest身份171418 bytes，SHA256 `1715d8aa268692ce3719c6587a3499a81be6b2ffbe257c59955cfcaeca7c90a6`。

实际Compile/Link诊断03为227441、04为227434，差**7**，分别从各自原hls_compile.log读到。这只是同阶段编译诊断差，未以它证明动态copy数量、吞吐、面积或下一pass耗时。也未通过相加inclusive函数设计量解释差值。

root要求在停滞区间有限读取本次owned HLS descendants的真实/proc命令/wchan。本child实际探测时间为 `2026-10-13T04:39:37.531152+00:00`，已晚于guard finished_at：
- ownership来自04 guard_hls/launch.json：leader_pid453841，start_time_ticks897858144，pgrp/session453841，launch_at `2026-10-13T04:33:41.784345+00:00`。
- 遍历仅从该leader的/proc/453841/task/453841/children开始，读前核定session/pgrp/starttime，最多128个节点；leader已 `exited_before_read`，所以没有live descendants cmdline/wchan观测。未扫描其他项目、未探测任意/proc、未管理/触碰guard或写“进展”。
- policy_checks.json保留的是guard已核定的owned pid/command名等策略记录；它没有实际opt完整argv，因此不能用这些command名或gdce文件后缀猜当时执行的具体transform/pass。**当前没有live command/pass参数或wchan证据，不能据此声称死锁或定位停点函数。**

**结果边界：消除此copy不是解除当前停点的充分条件。** 单次03/04配对没有证明copy完全无影响，亦未定位另一个根因；仍需真实transform/分区观测区分下述结构区域。没有新top与实际RTL，不能签硬件收益、C/LN或完整链关闭。

### 可解释的两个后续结构诊断区域（不是固定micro-HLS实验清单）

下列量全部来自04已存在的450个top可达函数IR，都是**静态操作/call site计数**，不是每周期执行量或复制总字节，也不累加inclusive函数量。仅提出区分对象，未修改它们。

1. **static Entry → executor::State → full::FullRuntime的初始化/构造区域。** `(anonymous namespace)::Entry::Entry` 实际ABI304640 bytes，直接调用State constructor1处、Transport constructor1处，另有ap_uint2496/PhysicalMap/Frame1024子构造和1条1024 memset。State ABI293888 bytes，直接调用FullRuntime constructor1处及Port/bootstrap/checkpoint/Command/Result/Record/CancelConsumer等子构造；State ctor本体保留2条1024 memset和2条256 memset。FullRuntime ABI275808 bytes，其ctor本体没有直接memcpy/memset，仍有FullInputs、FullOwners、FullCache、TaskReservation、PortalReservation、GeneratedStoreTracker、LifecycleActionTracker、CheckpointBaseline等子构造call site。**三个大小是嵌套对象，不能相加**；抽取未发现整Entry/State/FullRuntime直接aggregate load/store，不能把275808-byte对象大小冒充一条整对象copy。该区域的诊断理由是实际可达初始化图广，而不是已证明大对象必然致stall；应区分初始化降低/子构造内联或对象分区是否归属实际停滞transform。

2. **executor_stream::step_in_place的完整packet/metadata aggregate区域。** 原Inputs复制移除后，该函数本体仍保留1024-byte std::array对象**3个alloca、5条aggregate load及5条store**；handoff::Message对象**2个alloca、2条load及2条store**（实际Message ABI768 bytes）；256-byte std::array有**1条load及1条store**。其余FullMessage、完整Host receipt和pending来源仍受原真实consumer验证约束。这里可观察的问题是完整packet/Message在同一条件控制函数中的对象提升/复制降低，不是要求删除完整wire校验或绑定。5对静态1024操作不等于一次调用复制5120 bytes，更不是硬件内存带宽证据；不同分支、sret/临时生命周期及后续transform可改变实际代价。

这两区域的存在本身还不能区分当前停点。需要的最小真实信息是：**gdce之后实际正在执行的transform/pass完整argv及入口/退出，或同一pipeline对具体function/object的分区/归属或变换前后量**，从而判断时间是否落在初始化/构造图、完整packet对象降低，或二者以外。没有这种观测时，不应再据大小/关键词/7条诊断差固定一串micro-HLS候选或认定根因。

本result追加前保留完整100034-byte prefix，SHA256 `6f79193a5cf07503d3a18d220e327db47b5e81db5fa4c867869e8b722f189432`。本轮只读核查至此交付；03报告、managed adapter旧交付及其他前序记录继续完整保留。


## Managed adapter 坏帧隔离修复与 fresh host02 准备（2026-10-13）

本轮根据root新任务修复A004只读发现的PREPARE缺口，所有权仅为adapter实现、managed测试、managed host runner及本result。已重读research-agent技能及engineering/hardware参考、hardware-agent、适用AGENTS与当前OLD-LTX合同。不是唯一执行者，保留其他人的共享改动；未改其他实现/接口/旧attempt，未创建agent、执行compiler/测试/AMD或LLVM工具、管理进程或启动新实验。下列为**准备完成与静态核查**，C++编译、host02、HLS、RTL全部NOT_RUN，由root统一串行。

### 合同与普通修复边界

真实依据：`results/executor_old_ltx_cleanup_contract_20261013.md`（D-M003-EXECUTOR-OLD-LTX-CLEANUP-01）§4要求：“坏帧/错归属不能用部分字段制造可信LOCAL_REJECT。”普通本地拒绝必须先有完整合法、可核绑定的同一pending原帧以及确实未对外呈现的事实。合同11280 bytes，SHA256 `f66376b95a75edc03d99ae1a528e7ca2c5f2d0b871fdd7fce5402f4a4f9979a2`；配套managed LPV合同13693 bytes，SHA256 `9d1079b0ecdff817952ff4fba91a2c16965a578f2ebc1a744e5bb6ba10cbc59c`。

修复前managed PREPARE沿用 `if (!parsed || cancelled...)`，将full codec失败与已解析合法帧的撤销合并交给reject_internal，可能从default/partial Request制造LTC。此次只在managed宏有效时：
- State枚举末尾增加内部ISOLATED，不增加对外协议、端口、reset或许可。
- PREPARE full parse失败直接置ISOLATED并return，早于reject_internal及SEND_EXTERNAL。
- 静态完整bad internal_request保持；ISOLATED在READ/PREPARE/SEND和末尾无条件WRITE分支之前早退，所以既不再pop下一帧，也不对外派发或制造任何LTC。连续cancel、cancel恢复为false或反复变化均不改变该内部占用。
- full parse成功的普通撤销/真实cleanup白名单、external_presented的首attempt时点、已呈现旧帧及真实返回保持原路径。未增加owner/A/pending许可校验权威，完整collector归属仍由root整合。

### 本次三文件身份

| 当前文件 | bytes | SHA256 |
|---|---:|---|
| hls/platform/controller_transaction_adapter.cpp | 24019 | `de8d64c760b638ea6b41c5cad98c099ac84b1fbf02d90eec68019d473d7d4ac0` |
| tests/controller_transaction_adapter_managed_test.cpp | 18808 | `0f3175577bd548d9e794a0101f6650b244f77a14806a75b7b80ecea545aba831` |
| vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_controller_transaction_adapter_managed.py | 25493 | `f5cfce2875c711eeec556cdacd360383a12c3c322bd296b56f1c608d3f338fea` |

修改前原文件分别23563/15020/18939 bytes，SHA为前序交付的31ae50be...、67dbf2b1...、f660d151...；实际读取完整preimage后在内存保留，并以它做差分。仅把明确managed条件块取宏关闭分支，原/新adapter的非managed文字投影**21878字符逐字相同**；不是用重新实现legacy或删断言规避兼容。此静态投影不替代真实default build/run。

原managed测试从 `std::vector<Request> q=...` 起的88例main主体逐字相同，原perform/gold等函数保留。88例的60 local/28 controlled remote及7种binding mutation、尾2/尾1等仍要求完整执行，不拿新增坏帧无输出来替代合法帧拒绝/远端结果。

runner Python AST parse通过（STATIC_ONLY），没有执行runner/prepare/internal-build/helper，也没有生成attempt或compiler输出。C++编译与全部新旧用例仍由父后续实际执行。

### 两个独立process坏帧用例（计划验证，不是已PASS）

复用同一个managed test binary新增第四个argv模式；无第四个argv时仍走原88例。每种坏帧模式都由runner启动**fresh OS process**，没有静态adapter reset，也没有caller FIFO清空/末尾pop queued-next来复用同process。

| mode / phase | 固定独立输入损坏 | 计划的有限断言 |
|---|---|---|
| bad_magic / isolation_bad_magic | 原独立compute_request完整1536B，byte0 xor1；不从默认Request生成输入 | 首pop cancel=false，后续真实pop维持cancel；坏帧收齐后隔离 |
| bad_tail / isolation_bad_tail | 原独立end_request完整1536B，固定flags偏移32写1，最后reserved byte1535由0改1 | CANCEL_CLEANUP及END类别不能修复full codec语法；首pop起持续cancel仍隔离 |

每process代码安排24次一次一拍实际write/adapter call，直接从输入FIFO before/after size计算actual request reads并要求每次1，总24。之后把完整独立producer_request的下一24拍全部排入原输入FIFO；同时三个peer response输入各放1个sentinel。PREPARE一次后，继续256次有限call：64次cancel=true、64次false恢复、64次交替、64次true。

每次都直接记录实际FIFO大小和本次输入pop差值；要求completion与三个external输出一直0，下一frame一直24拍，三个peer response一直各1，不能消耗或清除它们。**24 READ + 1 PREPARE + 256 ISOLATED = 281条实际观测**是本次待执行断言数量，不是本child取得的运行数据。调用后仍保留queued-next与peer FIFO，不为测试继续运行而清空它们。

独立gold不是make_local_reject/normalizer：
- 输入gold来自保留的实际独立fixture与固定字节偏移损坏，由父runner再次逐字复算。
- expected LTC为**0拍空文件**，不是1024-byte全0“完成”；actual文件仅在输出确实空且全部断言完成后写空。任何生成LTC或external拍都会使断言/CSV比对失败。
- CSV的预期是合同固定的pop数和FIFO占用；runner独立构造281行期望，并与actual记录完整逐行比较，不从DUT输出反推gold。
- `transaction::decode(malformed,...)` 只用于断言测试输入确实codec失败，其partial/default结果不用于构造任何期望LTC或授权。

这只证明所选未知输入的隔离行为；**不签全部坏帧恢复、不签错A/route/pending collector隔离、不签请求安全闭合或hub退休**。

### fresh host02 runner / HLS复用接口

父runner保持原build/default/managed phase、default/managed两build variants、7源TU list及实际compiler -M全部project/system/SDK依赖身份格式；未增加第三binary或TU。原88例capture/marker完整校验继续。新增：
- receipt.phases：`isolation_bad_magic`、`isolation_bad_tail`；
- 两phase各独立guard/log，marker前缀均 `FULL_CURRENT_CONTROLLER_TRANSACTION_ADAPTER_MANAGED_ISOLATION_PASS`，字段mode区分；
- 原binary argv为 `[managed_adapter_test, fixture绝对路径, capture/isolation_<mode>, mode]`，mode为bad_magic或bad_tail；不经同一test process复用静态状态；
- manifest新增managed_isolation_processes两行，含phase/mode/independent_os_process、actual_LTX_reads24、observed_calls281、isolated_calls256、queued_next_frame_beats24、expected_LTC_beats0、expected_external_beats0、caller_fifo_clears0、static_reset0；all_malformed_recovery=NOT_RUN；
- 每phase新增independent_isolation_capture_checks，要求passed、independent_bad_frame_match、independent_next_frame_match、zero_expected_and_actual_LTC、independent_FIFO_observations_match、marker_fields_match全部true，actual_observation_count281，capture_files五文件身份完整（输入bad帧、输入next帧、expected/actual空LTC、CSV）。
- marker字段另外核actual_LTX_reads=24、observed_calls=281、isolated_calls=256、no_external/no_LTC/next_frame_not_consumed=1、next_frame_beats=24、caller_fifo_clears/static_reset=0、host_unbounded/unknown_only/recovery_NOT_RUN=1。不能只看到总marker就PASS。
- 任何guard触帽仍COST_STOP，exit/marker/capture任一不完整仍FAIL；只有build及四个host process（default、原managed88例、两个isolation）全部真实通过，才沿原状态名签PASS_SCOPED_HOST_MANAGED_ADAPTER。

root实际single heavy tool调度不变：CPU0–3/nice19/idle I/O/MemAvailable>192GiB；build 24GiB/1800s、各host 8GiB/120s，120s真实stall保护。此两坏帧process不证明host无限FIFO之外的READY0、write_nb尝试未接受、depth2/F10实际末pop反压、HLS/RTL或完整LN/C数值/周期。

父可用现runner在**不存在的新attempt** `R003/controller_transaction_adapter_managed_host_02` 冻结/执行，沿旧受核fixture来源 `controller_transaction_adapter_rtl_03`。旧host01/旧生成RTL保持原身份，不能预签新live源码或新ISOLATED行为；fresh host02 source closure及所有phase真实通过后，才能给A005的新managed HLS runner复用。

### 实际交付与并行边界

已先向root发送三文件完成SHA与STATIC_ONLY/NOT_RUN边界，然后按root顺序实际消息通知A005（`/root/executor_stream_tests`）managed源码已变、host01不可绑定live、必须fresh host02及两新增phase完整gate。A005拥有另一个new managed HLS runner，只读本host格式；本child没有写它或其他共享文件。文件写入与消息送达分开记录，未声称已启动host02/HLS或已PASS。

本result追加前完整110390-byte prefix，SHA256 `5eb8c6fd61fe9e6a489dc15bc71d04b925b0413d975fb271fc9675dea2d53b0f`。前序03/04只读区分、managed旧交付及所有历史证据保留。C继续先行；D/QUANT、完整恢复/CLOSE/rearm和M003/M004关闭不在本次交付内。


## 冷初始化只读结论保存与最新重心切换（2026-10-13）

根据root转达的最新用户决定 `user-work-focus-switch-immediate-20261013`，立即停止executor HLS05/coldINIT、collector/exporter、cleanup/CLOSE后继。只保存已经取得的静态结论，不继续旧方向、不修改root共享头或启动任何新工具/attempt/agent。

已经完成的只读核查：当前ColdTable用真实typed union Cell<T>存储，Cell数组/union对象本身已构造；取inactive value地址后 `::new(static_cast<void*>(&cell.value)) T()` 或T(ColdInitTag)开始成员生命周期，不依靠inactive字段赋值或裸字节。trivial copy/destruction约束及隐式union/table值复制在全部初始化完成后保留active value；source先tagged构造metadata和window cell壳、再逐window构造，正常default ctor仍完整构造各值。range iterator用table+index，不跨不同Cell里的T成员做T*指针算术。源码tag链Entry→State→FullRuntime→FullOwners/GDownPlan→ColdTable已接通；top INIT早退位于actor读取、FIRST锁存、FIFO/AXI/业务调用之前。

源码容量算术32+34+4352+6144+4096+1024+128=**15810初始化调用上界**，不是RTL cycles；QKV/rope/att的mixed-radix映射覆盖原全容量。现工具自带gcc4.6.3/new:103、gcc9.3.0/new:173及host13/new:174的placement overload均inline、只return传入指针，不作动态分配。可解释其通常可降低为地址+T ctor，但**没有cold候选实际编译/gdce/HLS证据，不签可综合或实际构造图已降低**；FullInputs/其他metadata普通构造与静态全局zero-initialization成本也没有被证据排除。本child没有编译、执行测试、LLVM pass/HLS或改任何冷实现。

已有managed结果分开保存：本child只读到fresh host02 receipt `PASS_SCOPED_HOST_MANAGED_ADAPTER`，build/default/managed/isolation_bad_magic/isolation_bad_tail五phase均PASS、guard exit0/无trigger，两个独立坏帧process各281观测与capture checks真实通过；这仅按host02冻结身份覆盖前节原88例及两个未知坏帧隔离。root随后报告managed HLS01 real guard PASS、script receipt `FAIL_post_live`（其冻结后root修改共享header引起live drift），另做immutable/top出口audit PASS并保留原FAIL；本child没有复写旧receipt或将它说成当前live HLS PASS。

本轮保存前result119680 bytes，SHA256 `19d6519363a05e27cb0640d20f5c6c794e5e887716f7ddc9b6a7649d47451598`。转向仅只读有界盘点真实Q8 matrix/G/Down独立算术生成物、冻结输入/gold、runner和既有周期/AXI/资源证据；不启动新重工具/attempt，不追加旧executor方案。




## SM005/E005/R001：KB0 resident Down测量入口交付（2026-10-13，NOT_RUN）

依据 `mission/hardware_measurement_replan_20261013.md` / D-M004-MEASUREMENT-FIRST-01及root明确授权，本child仅完成两份新入口；root独占重工具。没有恢复executor/coldINIT/collector/cleanup，没有启动新agent、compiler、AMD工具、TB测试或runner的prepare执行。P0有界盘点结束，下一出口为真实KB0或具体失败。

### 已核旧闭包与范围

可信历史闭包 `project/E003_production_chain_closure/experiment_results/runs/R003/resident_regression_02`：26份frozen RTL/TB/Tcl来源、12份独立真实fixture/gold合计13897751 bytes均已核身份。六个当前live文件漂移（sync_ps_front/final_ps_adapter/axi512_writer/owner_ledger/matrix_resident/原resident_TB）全部排除KB0；新runner只从历史frozen复制26闭包，覆盖其中原TB路径为观察派生版，其余25份在KB0中按同hash复制。历史attempt与Laya-baseline只读，不回写。

- manifest SHA256 `2a8d23b82ce961f0b878b47b88823a3578d4afe43eefec468410b3db7ab6697d`；receipt SHA256 `8c09b951475a542f96789d3068282c77e7713c12781ae04e356af3cd6fa72f95`；full raw SHA256 `0afa90cc4808ee83339efd7eaa78b03e3fcb2ea1bfdb2ec1c00dd0db87c8bbf4`。runner启动前再次强制匹配三个可信身份和26/12数量。
- 原static/pilot/full真实PASS成本56.586666528s/87.111960530s/424.467004355s；peak2407008/1426128/1422652KiB；child0/无trigger。原full四distinct行，K2624/N1024、10496stripes、41984PS commits、335872 lane-groups、512final packets、4096独立F32 gold、512真实AW/W/B，最后B才publication。
- 原A_publish689、W_publish27755、旧结束48862cycles；旧结束是done held7cycles后，**原TB没有done消费**。新的消费/结束数据尚无。真实A为预量化输入、bias kind0、初始reset，不签seamless Wi→G→quant→Down、13BO/fullrequest、稳态或上板频率。
- 原物理output有16384 useful/32768 physical bytes，strobe利用率50%；heldB9217是原TB每个真实negedge对17+(beat%3)响应延迟计数的总数，重叠state/tx/PS等待，不能按可消除关键路径全额扣除。

其余有界盘点已有证据保持：direct Down `t2_tm4_sync_real_down_01` PASS_SCOPED377.579143s/全10496读-copy-launch及41984row commit，外部预量化stripe，不含物理cache/output；G→quant→A `t2_geglu_gate_quant_bridge_rtl_04` PASS_SCOPED94.854549s/59975cycles、Wi20992→G10496、656真实AXI读写/328quant groups，非上下游seamless。G canonical DCP 164ports/51exactFP/blackboxes0、95754LUT/42834FF/48DSP/RAM0，DCP SHA `23ed542ce9c26641e9cffbb1e4b4724c19da0de7c1c5805e0ac180d0252f6207`；新三bank parent COST_STOP164.187886s，不能继承旧全register资源。dualW assembled mapped OOC32banks、22008LUT/15469FF/18DSP/192RAMB36/64RAMB18/384URAM，诊断WNS−3.043ns@6.667ns，无P&R/board。generated RTL02是STATIC_PORT_ASSOCIATION_FAIL（sequence escaped pin），非数值PASS。上述只列既有证据，没有本轮新运行。

### 两份新owned文件

1. `project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/tm4tn8_down_measurement_tb_v1.sv`，49347 bytes，SHA256 `3d72a4d8d7890032d1743113654c64be5a9589b5c8f6d5d753a6b67a5d80e438`。
2. 同目录 `run_down_measurement_baseline.py`，19834 bytes，SHA256 `9d0e78fe9643959081d5adcbe47679b43a2c6208a75fb42ec5737b8fb18d0766`。

TB保留原模块名方便复用frozen Tcl，静态diff原行删除0、原28个fatal全部保留，新增9fatal；新增观察计数与真实done consume。原独立PS/F32/输入cache/AR边界/债务/末B/故障断言不删，不改fixture/gold。保持repeat(7) held done检查，再negedge置done_ready，观测一次实际done_valid&&done_ready；消费后核done deassert/stateIDLE/ledger publication/debt，再一次tick核无重复done。

计数起止：同一endpoint_monitor在posedge先cycle++，所有handshake和DUT state为pre-NBA采样；互斥13state bins覆盖 `[cfg_accept_edge,first_sampled_done_valid_edge)`，其sum必须等于差值。原A/W publication断言点为post-NBA，报告明示混合观察边界。另报告TB从cycle0至finish、reset/idle→Aaccept、Afill、A→Wgap、Wload、W→cfggap、cfg→done-valid、cfg→真实consume、最后PS→最后B、最后B→done；pilot仅 unfinished prefix，done/output-final-B不能签。

非互斥观察逐项标明：A request/WAIT无return/return反压；W request/pending无return/return反压；front admission、native dependency/credit/space/launch/commit；configured&&!front_done活动跨度（不是逐lane busy证据）；PS commit edges/反压；writer packet_valid&&!ready、tx_valid、已AW/W送完&&!Bvalid；AXI valid&&!ready；真实WSTRB useful与physical bytes；TB periodic AW/W gate及原held_b delay decrement。首末issue/launch/PS/AW/W/B与done均来自真实边沿，不周期heartbeat；原MATRIX_PROGRESS仅真实publication及每128真实row0 PS commit继续，未增加虚假进展刷新。

runner在新evidence目录先验证基线，再冻结26来源、12fixture、current guard及helper、tool及runner身份；fixture复制到本新work，无历史目录写操作。static Tcl只派生declared EXPECTED_OUTPUT_BEATS plusarg，provenance单列；sim Tcl原样复用。每phase执行前后重核冻结输入、runner/tool，guard/raw/measurement JSON/nativeXCI均写身份。先static24GiB/1800s，再pilot8GiB/120s，再full8GiB/3600s；semantic stall120s/40Mcycles/CPU0–3/nice19/idleIO/MemAvailable>192GiB原帽不提高。实际pilot结束后按新pilot墙钟×同frozen旧full/pilot墙钟比值×1.5保守估算full；含旧full最终output/numeric compare drain，不用含Wload的pilot总cycles线性外推。估算>3600时写COST_STOP_NOT_LAUNCHED，禁止full启动；full另测实际末PS/B/done边界。

预留root后续candidate选项 `--label KB1 --writer-source <E002/experiment候选文件> --expected-output-beats 256`；仅替换冻结writer，记录候选original/selected/frozen身份。KB0明确禁止writer覆盖或非512beat。TB的beat声明只控制actual AW/W/B及physical bytes覆盖；4096 F32、41984 PS、512final packets、末B和7hold义务不变。root启动KB0后本child不继续改该runner/TB，候选使用同冻结测量身份。

root可执行入口（已有AT根目录允许，measurement目录必须未存在）：

```bash
python3 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_down_measurement_baseline.py --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT001_KB0_resident_Down_measurement/evidence/measurement
```

最小前置：root的single heavy slot空闲、CPU0–3可用、MemAvailable>192GiB、新measurement路径不存在。`--prepare-only`仅准备且NOT_RUN，child未执行它。已执行验证只有Python AST parse和源码静态diff；**hierarchy binding、static、pilot、full、KB0 measurement全部NOT_RUN**。最终SHA与命令已发root；运行后以新guard/raw/receipt为唯一新实测依据，不预签旧48862为新结果。

本节追加前result prefix 122342 bytes，SHA256 `7572850ee6fe166dcd07cdca551d6851f4a7902482cf20161cb1eff0565c2604`；前文全部保留。

### root实际启动后的只读确认

root随后报告AT001/measurement在2026-10-13T05:45:13.784UTC真实启动（root exec session71206/guard static leader524955），两入口从launch起不再改。本child只读其input_manifest/receipt/guard_plan/guard_result：KB0、26frozen/12fixture、expected512、live numeric False、runner/TB最终SHA全部匹配；static实际PASS，57.309920778s、peak2412168KiB、minMemAvailable399719220KiB、child0/trigger null、CPU[0,1,2,3]。三个新nativeFP XCI SHA分别与旧baseline完全相同。此时receipt IN_PROGRESS，pilot/full尚无本child读取的完成证据；以上实际static supersede入口交付时的static NOT_RUN，未预签full。root负责候选新DUT，本child保留只读静态审核任务，不恢复control实现、不启动工具。

### root-owned KB1四row pack候选：有界只读静态审核

root在KB0 static/pilot实际PASS、full唯一guard运行期间授权本child只读审核新 `E002/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_axi512_writer_rowpack_kb1.sv`；该文件root所有，子agent未改任何DUT、runner或TB，未运行compiler/测试/AMD，也未新增agent。审核时文件14944 bytes，SHA256 `5fad1da7479aeb4227da5744a857503b82b3690b1d10aec5231f96f7dd5bc691`。同原module名只能作为runner writer-source覆盖，不能与原writer同编译。

与resident_regression_02/frozen writer作源码diff及有界文本区域比较：shape/config/packet/address验证整体5355 bytes逐字相同（SHA `03ce63d5838b401facb3f24312ee035cfc544594c8418f2b12502e330fed5d66`）；configuration identity/owner_tag锁存1101 bytes、AXI信号等式383 bytes、command_retire216 bytes也逐字相同。只增加四组pack_valid/addr/strb/data，不复制owner/config/retirement。相对原单pack新增3×(1+64+64+512)=1923 bits逻辑存储字段；这不是LUT/BRAM或物理资源结果。

正常四行cold Down静态路径未发现候选新增安全bug：lines164–175按sealed row最低索引选封拍；176–179只有selected==held_row才允许清本row旧cache后接新地址。226–235先把旧selected cache抓入原单tx，再局部clear所选p/strb/data，同rowmerge据清空p重建nextbeat；异rowmerge只写held_row，其他cache保留。held_pending按beat_mask清除，清完才允许接受下一packet，同边沿replacement仍用旧held_row完成merge。AW/W输出等式不含fault门控，tx只在无旧tx或真实b_fire后替换；READY0、只送AW或只送W时旧VALID/data/address/strobe保持。故障清全部未发p/h而不清已有tx，最后B债务仍保留。flushing时逐个封4cache；debt_zero要求held空、pack_valid全部0、tx空；flush_done的局部h/p/t条件同样要求全空，不能在最后B前完成。固定优先级在heldrow因地址变化被阻塞时停止接新packet，有限其他sealedrow逐个排空，不见新增死锁。

向root指出了原writer已有、候选逐字继承的限制并得到范围决定：packet_valid&&packet_ready&&!packet_ok与transfer_pack同沿时，transfer没有用新packet_ok屏蔽，可将之前sealed未呈现cache变成新tx，再fault清p却保留新t；以及strayB&&!tx_valid分支只置fault、不清h/p。root明确本轮保留原fault策略，不顺手修改；声明normal四行cold arithmetic及原READY反压，实验错误即停止，不签通用fault恢复。后续生产接入仍需受影响错误回归，该限制不能由局部KB关闭。

上述static结论已发root；没有预签numeric/gold、256真实AW/W/B、周期收益或mapping。正式KB1仍待KB0 full数值/计数出口，以相同12fixture、同AXI响应策略/7hold/profile运行。root负责实现及工具排队，本child保留只读审核责任，未恢复control工作。
