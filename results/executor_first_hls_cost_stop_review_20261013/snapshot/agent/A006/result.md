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
