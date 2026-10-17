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
