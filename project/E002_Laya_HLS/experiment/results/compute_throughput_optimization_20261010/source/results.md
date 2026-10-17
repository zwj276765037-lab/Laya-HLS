# 算力与吞吐优化证据入口

`design_source: mission/compute_throughput_optimization.md`

用户已批准本mission。跨模块执行合同见[design.md](design.md)，唯一动态状态见[stage_results.md](../stage_results.md)；原始输入、日志和保护记录位于本阶段`attempts/`。本文件只作入口，不维护第二份状态表。

**2026-10-11目标修订，优先于下文历史目标口径：** 当前优先完成同gold、同冻结模型的正确完整Laya推理，取得同模型/shape/输入与计时起止口径下的实测相对性能改善，并闭合可部署资源预算。50ms首延迟/20完整请求每秒保留为远期参考；历史`REJECTED_BUDGET`只对应旧目标，四tanh条件77.366613ms不再单独淘汰当前路线。真实2ULP `NUMERIC_FAIL`及未接通的完整producer仍是功能阻塞，T6/T7仍为`NOT_RUN_DEPENDENCY`；完整producer成本帽、分段RTL＋当前身份完整CPU/CSim替代覆盖、各类未测标签与整体OOC/P&R暂停均保持。本轮只有文档方向修订，没有新增运行或性能PASS，既有接受与FAIL均保留原身份。下一阶段按[design §0.2](design.md#02-下一段有界功能与性能路线)先定义一个同gold候选，再按依赖推进完整功能及有界性能改进；首延迟、完成间隔、供数/停顿与资源代价分别报告，不以局部结果宣称完整高性能或超越GPU。

既有基线：[CPU Embedding/Q8阶段结果](../../cpu_embedding_q8_validation_20261010/stage_results.md)、[联合服务预算](../../cpu_embedding_q8_validation_20261010/pipeline_budget.md)。旧结果按其原始实现/输入身份复用，不能作新原型通过证据。

T1实现及模块证据复用`vivado/module_design/layernorm_engine/source/rtl/tb`；T2复用`vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/source/rtl/tb`并按新候选分别记录。各模块结果入口须回链本阶段的唯一动态表，不复制设计真源。

T0执行基线现含：design §2前端四配置、§3精确整数/packing及新192bit标签的TM4算术/PS微基准、§4 CPU静态模型预检/离线会话及独立Q8会话候选ABI、§5联合资源/服务条件账。设计发布与实际实现、HBM/量化/输出整链、真实板端完整性分别说明；该设计发布不登记任何新实现PASS。

后续有界合同见design §7–§8：公共三路LOAD/双W与A/quant16供数，C3/C4仅比较同head的3/4个AV context；softmax及vector明确计入归约、非线性和端口成本。先用最小真实反馈/完整row算术与有限调度模型淘汰条件，未默认扩大F256或整阵列。§3.5已补显式逐stripe identity/version/sequence及外部拒绝测试；本入口不对尚未合并交付的T1/T2结果提前作正式验收。

恢复核查已确认§7–§8原条件设计完整。新增design §8.6是可直接派发的单FMUL/单FADD/单partial bank反馈实验：两配置各4096个完整key递推贡献，明确F从RAM读请求到下一合法读请求计量，不能以已有FADD IP的11cycle配置替代。2026-10-10轻量按实际v4 manifest重算122张Q8矩阵，串行payload7214120cycles、三流并发下限2885664cycles（150MHz条件19.237760ms），与§7.2一致；F=11的C3按读接受跨度为4477cycles/head，原4480为整frame近似，最终fill/drain须由事件另计且不重复。本次只发布/复核设计，当时新增RTL、资源和性能结果均未运行；本轮实际结果见下方唯一集中验收章及阶段表。

T1适配器事实及最小观测补充见design §2.5：两版顶层活跃方向的CH0与global outstanding实参均为1，模块缺省2未生效；用户请求FIFO容量7/4与外部在途事务不同。现有硬编码峰值打印只可按真实endpoint握手约束推导，内部债务须由用户/AXI双边界守恒或足够直接探针证明。旧运行缺少内部观测时保留`NOT_OBSERVED`，不影响已记录数值/物理结果，也不据纯打印错误重跑全部配置。

TM4轻量存储预读已并入design §3.5，不构成正式验收：当前PS/poison及Q35/D4 payload不整片reset，有效性由group0、progress、state及返回身份保证；PS实际为组合读/时钟写，83968B只是逻辑容量，BRAM/URAM/LUTRAM/FF映射UNKNOWN。资源账须另付多端口owner/state、重复busy/pending及FP恢复侧67200bit元数据，不能按一个无额外端口的RAM估算整个PS/Q35/D4。现有四shape功能运行继续，所需有效性观察优先复用或补短例；整体OOC/P&R仍暂停。

T6/T7成本边界与两种有界替代已并入design §9及mission §6.7–§6.8。成本校准使用真实QKV四行12288 stripes完整仿真403s/guard408.346s；完整层/图的小时或天数均是当前实现投影，未冒充长例实测。固定几何下单TM4全图及单TM16/TN16至少8请求的Q8服务量均超40M硬帽；只对实际采用的具体配置作运行前成本排除，尚未落实的T6/T7保留依赖状态。此处不提前发布阶段验收或改写唯一阶段表。

T3实际ABI阻塞的设计解已原位冻结于design §4：新`Q8S2` v2 descriptor1024B，REGISTER/REVOKE与strict/fast LOAD/RUN显式编码；18拍绑定流的q0/q1/scale/aux base取wrapper真正使用的锁存指针，BO size/allocation及上传读回关联由受控Host提供，不能声称防恶意Host。新layout/build必须由实际实现生成并重验整包，现v4 CPU记录不自动升级。最小正式范围为真实ACT每profile两次LOAD/RUN及短会话负例；旧严格入口不变，13-BO完整图仍`NOT_RUN_DEPENDENCY`，真实板端读回仍按实际证据登记。该补充没有运行实现、重工具或新增审核门。

## 集中验收记录（持续更新，非mission完成）

2026-10-10–11，Astra/xhigh按实际制品集中核对T1–T5的当前独立出口；下文是证据审核及缺口归属，动态任务状态仍只由[阶段表](../stage_results.md)维护，不增加逐小步放行门。既有审核仅轻量读证据、核独立参考与重算哈希，不占重工具窗口。Q8S2最后生命周期短例与双W完整供数增量已纳入，既有独立出口按各自范围收口；当前推进正确完整推理与同基线性能改善，旧50ms/20请求每秒参考差距单列。依赖失败数值producer的T6/T7仍未执行，本轮方向修订不改变该证据状态。

### T1：四配置数值/访存、RTL早错与活跃传输reset恢复限定范围接受

主证据为同一`static_04`的[normal adapter收据](../attempts/t1_formal_four_02/normal_adapter_receipt.json)和[pressure收据](../attempts/t1_formal_four_02/pressure_receipt.json)。本次重新计算其中104个唯一文件的SHA256，全部匹配；完整IO/STATE0/raw gold/norm gold/AUX五份fixture身份匹配。四次实际输出各65536B与独立norm gold前16行逐字节相同，每个输出byte覆盖恰好一次，64个observed words逐项匹配，CRC32C=`d5c15b0f`。TB数值断言本身采用原LN容差，本次额外核对捕获二进制得到16384个F32**逐位一致**；参考来自原独立CPU生产路径，非本DUT输出。输入只读方向、地址范围、输出尾部sentinel和全部读写覆盖有实际DPI/端点断言。

| 同`static_04`配置 | top启动到首次done周期 | guard墙时 / 峰值owned RSS |
| --- | ---: | ---: |
| byte normal | 2126573 | 304.618s / 768472KiB |
| wide normal | 1433020 | 277.669s / 793072KiB |
| byte pressure | 2126578 | 302.990s / 859380KiB |
| wide pressure | 1433025 | 278.055s / 859584KiB |

起点是冻结AXI-Lite AW/W和top状态机严格推得的TB计数7，**不是旧日志直接采样的start事件**；原raw done计数分别再加7。normal与pressure的宽版均少693553cycles、约1.484×；pressure各比本版normal多5cycles。最终LN输入R和最终norm输出B各命中一次、计数hold各4cycles，不能把4+4直接相加当总延迟。算术日志17个done上升沿中有1个生成IP初始idle done，实际16次start/16行完成；首末算术事件跨度还包含行间访存，不能当纯算术服务。

两版有相同有效工作：STATE0读131072B（导入与LN各65536B）、gamma4096B、norm写65536B，另诊断256B。宽版实际STATE0/AUX/STATE1为512bit、诊断32bit；STATE0物理R beats由32768减到2048，norm W beats由16384减到1024，norm AW/B由256减到16。活跃方向物理峰值1由端点单活动门控和实际非零握手共同推得；HLS用户请求队列的未返回元素峰值不等同AXI在途事务。首次done同边沿实际观测到各口`ΣI_LEN−I_R=0`、`I_AW−I_B=0`、`ΣI_AWLEN−I_W=0`、RFIFONUM=0及所有相关pending valid=0，同时四口物理债务0。本次独立重核收据中的这些守恒式；旧`static_02`仍为adapter `NOT_OBSERVED`，不被新运行追认。

[endpoint short03正例](../../../vivado/module_design/layernorm_engine/rtl/front16_axi_short_03/positive.log)及[负例](../../../vivado/module_design/layernorm_engine/rtl/front16_axi_short_03/negative.log)支持独立AW/W、W先于AW、AW受首事务W/B阻塞以及**端点**未完成写reset恢复。BAD_WLAST在预期债务/LAST断言实际fatal；XSim的`-onerror quit`仍返回0，runner用精确fatal文本、未到达逃逸/成功标记判断，不能单看进程exit0。short03 guard exit0/15.093s、无触发；四长运行亦exit0、无触发，CPU0–3/nice19/idle配置有记录。这些RSS是仿真进程成本，不是FPGA资源。

当前[byte功能HLS报告](../../../vivado/module_design/layernorm_engine/rtl/front16_byte/hls/syn/report/laya_front16_byte_csynth.xml)估算LUT8804/FF6007/DSP5/BRAM18 16/URAM0，[wide报告](../../../vivado/module_design/layernorm_engine/rtl/front16_wide/hls/syn/report/laya_front16_wide_csynth.xml)估算LUT13640/FF13120/DSP5/BRAM18 37/URAM0；共享LN叶子两版均DSP5。它们只支持当前功能实现的HLS估算，未证明物理映射、整图fit或时序；报告中无界循环形成的夸大latency上界不作实际性能。

前次集中预读区分了[CSim负例](../attempts/t1_csim_01/run.log)、独立endpoint short03和真实LN DUT的覆盖，所提缺口现由[fault03收据](../attempts/t1_fault_03/receipt.json)补齐。收据SHA256=`d1ce1902616c34dcbceda02a75152be98e0b610bdd3c8ec7b1680f305d9dc5e1`；本次重核其122个唯一源/fixture/制品/日志文件（33075104B），size/SHA全部一致。沿原生成HLS DUT，5个仿真guard均exit0、无触发，原日志完整通过：

| RTL短例 | 实际启动→首次done cycles | guard墙时 | 实际拒绝/恢复范围 |
| --- | ---: | ---: | --- |
| [byte raw[0]=NaN](../attempts/t1_fault_03/byte_raw_guard/driver.log) | 412 | 6.040s | raw有效/物理读4/4B，未读gamma |
| [wide raw[0]=NaN](../attempts/t1_fault_03/wide_raw_guard/driver.log) | 404 | 5.639s | raw有效/物理读4/64B，未读gamma |
| [byte gamma[0]=NaN](../attempts/t1_fault_03/byte_gamma_guard/driver.log) | 1016197 | 40.405s | 合法raw完整65536B，gamma有效/物理读4/4B |
| [wide gamma[0]=NaN](../attempts/t1_fault_03/wide_gamma_guard/driver.log) | 700810 | 28.502s | 合法raw完整65536B，gamma有效/物理读4/64B |
| [wide活跃reset后重发raw拒绝](../attempts/t1_fault_03/wide_reset_guard/driver.log) | 重发404 | 5.631s | 首命令真实raw R已返回64B且该口仍有债务时同域reset，随后重新启动并完整退休 |

本次核了冻结TB/DPI：四早错的status、first row/col、已读raw CRC及全部64个observed word逐项比较；norm区和输出尾部sentinel不变。5例均0次LN启动/0次有效LN完成、0B norm写、完整256B observed写；首次done时四口物理债务全0，随后同边沿稳定采样的HLS adapter读元素/写元素/写响应债务、RFIFONUM及相关pending valid全0。gamma例确实做完整合法raw扫描，宽口取回64B不等于消费了16个坏值。reset日志`raw_physical=64 debt=1110`及TB条件证实不是空闲reset，reset同时覆盖DUT、HLS adapter与endpoint，旧状态清除后早错命令可退休；**未声称覆盖LN算术在途reset或reset后的正常16行数值重跑**。最初[fault01失败日志](../attempts/t1_fault_01/byte_raw_run/xsim.log)保留：TB把生成算术IP的idle ap_done算作完成，03以真实start未配对债务过滤伪done，同时保留0 start和0有效done断言。该修复不改DUT，也不重跑已有效的四个长例。

### T3：读回窗口修复、小例与真实03整包正常恢复范围接受

[真实02报告](../attempts/t3_real_session_02/work/report.json)SHA256=`59db2a0568dabd0ac30cd865b22540e72a0352d5b0666538200017165f49847c`，与guard输出一致；frozen/source hash清单逐项重核全部匹配。报告关联的两份validated record及两份ACTIVE session文件hash、manifest、四tag、五BO上传事件/完整size/读回hash相互匹配。输入固定§1 v4包，完整五BO共448923648B，绝非新v2 kernel身份；session里的`kernel_sha256`实际上填v4 build-preimage SHA256，不能据字段名宣称它是可执行kernel/xclbin hash。

[首份整包记录](../attempts/t3_real_session_02/work/validated_model.json)支持153个源tensor检查、124目录/122张Q8矩阵、11542592 half/23085184B完整scale覆盖，其中ACT padding48项。独立NumPy half解码与位谓词比较65536位型，31745接受/33791拒绝，−0接受；真实包有10个正subnormal、48个+0 padding，未发现负非零/Inf/NaN。`positive_subnormal`是`positive_finite_nonzero`的子集，类别不可重复求和。源码逐矩阵按padded n/g报告首错，并把排序地址与完整连续half区间比较、检查矩阵跨度不重叠和总数。完整包校验确实逆恢复Q8并核GGUF/目录/header/preimage/BO，不是只扫描少量scale或只信manifest计数。

[首会话](../attempts/t3_real_session_02/work/active_session.json)和[reset后会话](../attempts/t3_real_session_02/work/active_session_after_reset.json)支持当前正常顺序的完整上传/读回、warm scan保持1、旧generation拒绝、reset后新allocation及generation1→2、全流程重建总scan2。[guard](../attempts/t3_real_session_02/guard/guard_result.json) exit0/29.493s、RSS峰值1363504KiB、无触发；首轮prepare/upload/readback分别10.674/1.536/2.466s，纯scale扫描约0.218s，其余含整包/身份hash和snapshot。它们全部是CPU/离线内存端点成本，不是PCIe/HBM或FPGA LOAD时间。[attempt01](../attempts/t3_real_session_01/guard/driver.log)保留导入路径`ModuleNotFoundError`失败；不追认成通过。原13单测由工具观察OK但未留持久日志，记`TOOL_OBSERVED_LOG_NOT_PERSISTED`，不另造原始收据；5个scale/8个离线会话测试源码可核范围，不能据数量声称全部目录/恶意包负例已有持久执行证据。

**集中预读发现真实生命周期错误，正常包通过不能覆盖它。** 对02冻结的`t3_offline_session.py`路径使用小内存夹具，顺序`prepare→upload→verify_readback→endpoint.upload_and_sync(w_scale, 同长度坏字节)→activate→authorize_load`可得到ACTIVE且授权True，而当前端点bytes已不等于验证snapshot：记录upload event仍4，端点最新event已6。原因是端点到activate才seal，activate只查源文件变化，authorize只核allocation，读回之后的同allocation重传未撤销旧读回结果；这是公开受支持API的普通生命周期缺口，不依赖恶意篡改内部dict。

已交唯一数据owner按原不可变合同修复读回→激活窗口的mutation/event/allocation绑定，并补公开API负例及受影响真实整包/正常恢复回归；Root协调自然重工具窗口，不停T2。02预读发现错误时的结论为`NORMAL_PACKAGE_PASS / LIFECYCLE_FAIL_UNTIL_FIX`，02原证据保留，不能以新源码修复追认02覆盖此分支。

修复预核：新会话源码SHA256=`783ef4e59a02d09e0aebf4e839c760ec37b04078585ae64cd93448bf3ac9585a`在完整readback成功后立即seal，再进入READBACK_VERIFIED；activate与authorize均核sealed及allocation/上传事件。上传时保存事件总数和五BO事件快照，readback结尾核对，连同字节的未记录重传亦拒绝。[持久15项回归原日志](../attempts/t3_lifecycle_regression_02/run.log)明确15个命名测试ok、`Ran 15 tests in 0.173s / OK`，run.json exit0；本次重核[source hash清单](../attempts/t3_lifecycle_regression_02/source_sha256.json)五项全部匹配。新增窗口测试实际调用reupload/write/reallocate/reset，断言INVALID、generation增加、activate拒绝及旧generation不能authorize；另有readback前同字节重传event拒绝。对已发现窗口，修复语义与小例证据相符，该时点为`FIX_UNIT_PASS / REAL_PACKAGE_REGRESSION_PENDING`。这15项是新修复身份的持久运行，不补造旧13项日志；后续真实03结论见下。

**真实03已完成受影响正常路径回归，CPU/离线范围收口。** [03收据](../attempts/t3_real_session_03/receipt.json)SHA256=`b0b897d183e812b71097b37ab237601b5f3677f5b4a280fc89694270786fd0ff`，14个直接引用文件以及source/frozen两组各8项哈希均重核匹配，冻结会话源码正是上述修复身份。[03持久单测日志](../attempts/t3_real_session_03/unit.log)有同15项逐项ok、`Ran 15 tests in 0.148s / OK`；[整包原日志](../attempts/t3_real_session_03/guard/driver.log)有源码前后核对和精确report SHA通过终态。guard exit0/29.800s、峰值RSS1402608KiB、无触发。

[03报告](../attempts/t3_real_session_03/work/report.json)SHA256=`317913334af433e79d3ca40f93aa4292a327fd26c382c0f1d8415710efc078c0`及其两份validated record、两份ACTIVE session的hash相互一致。固定v4五BO仍为448923648B，两个generation分别完整校验122矩阵/11542592half/48padding、全量上传并全量读回；每份record的五BO size/hash与对应session的readback hash、上传完成事件绑定一致。第一次prepare→upload→readback各未ACTIVE时authorize均拒绝，activate后才可授权；warm reuse保持scan1，旧generation/错allocation拒绝，reset后generation1→2且五个allocation由1..5变为6..10，完整重新准备/上传/读回后scan2并正常授权。本次将已发现窗口的结论更新为`FIX_UNIT_PASS / REAL_PACKAGE_REGRESSION_PASS`，限定于此受控CPU/离线内存端点及已执行负例；02原窗口失败不被追认成新分支通过。

上述真实03只支持旧v4 CPU/离线会话；新Q8S2 v2 r2的实际包与局部RTL证据另见下节，不能由旧记录自动升级。真实XRT读回、13-BO全图接入仍未通过。

### T3：Q8S2 v2 r2真实ACT strict/fast及会话拒绝增量限定接受

**结论为 `PASS_SCOPED`：当前Q8S2独立ACT数值/会话出口完成，生产Host设备桥和完整性能合同尚未完成。** 本次只读既有产物，未运行重工具。实际[r2包manifest](../../../build/model-q8-session-v2-actual-r2-20261010/manifest.json) SHA256=`46bbd5abeeadc2d4305419d3129fd871aaeb04e962821ac4c6a6da957698018c`，[build preimage](../../../build/model-q8-session-v2-actual-r2-20261010/build_preimage.json) SHA256=`7209eb09c3f265363cfb274f7790a73336e1570f5081bc9bbb2538c1ba5a50d5`，layout SHA256=`2d848b5fb78236c795cb1d442f088393a3fd6cbd7f8ecf3cf9f984c59b5e0991`；build所列31个实际源文件hash全部匹配。新HLS源码SHA256=`3286c92ada43f25a4d8c274ae51a6d14a8fe2431287e5a0bab4eb0833628480e`，生成RTL顶层SHA256=`8daf93db5a4d84dee60be409dd5bc2de0e762527592f6cb3801bb12292c2e79c`。正式strict/fast的输入清单各389项、3500640/3500702B逐项size/SHA匹配；两profile共用同一生成HLS、wrapper和计算/writer RTL。另核两份fixture、wrapper及当轮两份TB manifest共63条直接引用全部匹配。

[CPU生命周期报告](../attempts/t3_q8s2_package_r2_01/lifecycle/report.json)及其两代record/ACTIVE关联文件已核：五BO共448923648B，本次重新hash全部BO与记录相符；generation1/2分别完整验证122矩阵、11542592half/23085184B scale、48个ACT padding，65536 half位型分类31745接受/33791拒绝。两代完整上传事件与完整读回size/hash逐BO匹配，allocation从1..5更换为6..10，总scan2；首/次纯scale扫描0.214229/0.216547s，整次生命周期28.861018s。沿用已接受的只读seal/event生命周期实现；这些是CPU离线内存端点的ACTIVE，报告明确`device_register=NOT_RUN`和`xrt_pcie_hbm_readback=NOT_MEASURED`，不能当真实设备注册或PCIe/HBM读回。RTL fixture用首份验证record关联新包，独立构造测试context/五个allocation cookie；它不是该CPU内存allocation自动直通XRT的生产桥。

| 实际运行 | 原始结果与范围 | guard墙时 / 峰值owned RSS |
| --- | --- | --- |
| [CSim r2 03](../attempts/t3_q8s2_csim_r2_03/guard/driver.log) | 两profile各REGISTER→两次LOAD/RUN→REVOKE→旧LOAD拒绝；严格64/快速0扫描，q流及strict trace half与独立fixture一致 | exit0 / 5.370s / 282780KiB |
| [HLS r2 01](../attempts/t3_q8s2_hls_r2_01/guard/driver.log) | 实际新包include/build；生成成功，估计period21.308ns/Fmax46.93MHz，未满足150MHz目标 | exit0 / 58.877s / 1639812KiB |
| [RTL strict05](../attempts/t3_q8s2_act_rtl_strict_05/guard/driver.log) | profile0、两LOAD/RUN、trace-on及下述14拒绝 | exit0 / 149.892s / 2681288KiB |
| [RTL fast_trace02](../attempts/t3_q8s2_act_rtl_fast_trace_02/guard/driver.log) | profile1、两LOAD/RUN、trace-on及相同14拒绝 | exit0 / 148.596s / 2564852KiB |

四guard无资源触发。CSim手工注入completion，仅检查HLS流/状态及量化q，fast关闭trace而未独立比half/F32输出；不能据CSim声称物理writer/FP计算完成。正式RTL独立参考复用已验收的真实ACT request3/generation1/B1/S128 oracle：Q8从GGUF独立恢复并核包内窗口，量化及每group六字段来自独立F32参考，最终output与全参考交叉核对；新输入生成器只读取和打包这些参考，不用DUT结果生成gold。

[公平descriptor比较](../attempts/t3_q8s2_act_r2_02/descriptor_comparison.json)已亲自逐word复算：REGISTER/LOAD1/RUN1/LOAD2/RUN2/REVOKE六帧各仅word64为0/1；q0/scale/bias/activation/a8q/a8half/output/trace/binding/AUX header十份payload逐字节一致。两侧trace均开启。LOAD1/LOAD2周期strict为4447/4449，fast为4111/4113，**各减少336cycles**；两侧两次RUN均5681cycles。周期为TB从launch前窗口到首次done后negedge的统一口径，不能冒称已逐事件分离所有cache/scan/末R/末B区间；末R/末B有限hold配置及done债务断言成立。旧fast01 trace-off只保留功能范围，不用于收益对照。仿真时钟6.666ns是激励，HLS当前估计46.93MHz及未做P&R的事实不变；336cycles不能兑现全图约307.8ms收益。

每profile两次LOAD真实搬运q0=2048B、scale128B、AUX header128B及bias8B；STRICT扫描64scale含48padding，FAST为0，bias检查和动态quant保留。每次RUN在真实group握手检查全部2048B缓存q、64个恢复F32权重scale（含padding）、两bias、8组量化q/scale，所有有效lane的dot/dotf/product/term/PS，以及一个物理output beat内两个F32结果和64个物理trace word；observed其余区域sentinel不变。q1/out1不得访问。最后输出B、全部HLS adapter、物理端口、compute/writer债务为0才允许首次done。

实际绑定并非descriptor自证：[控制器](../../../vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm1tn8_hls_control_v2.sv)将外部q0/q1/scale/aux指针锁存到同一pointer数组，一份用于真实HLS AXI-Lite寄存器，一份用于18beat绑定；各命令核恰好18次消费。TB实际改变q0指针或保持base而改变allocation cookie，均在新model读前拒绝。HLS先判断live binding变化并撤销旧slot，再做descriptor准入；仅descriptor错误且真实绑定不变时不应破坏活session。REGISTER消费新generation后先置INVALID，AUX128B核通过才ACTIVE，REVOKE保留高水位，reset清硬件高水位后的旧REGISTER防重放依赖受控Host。以上后半段状态语义来自源码审查，逐分支RTL覆盖界限见下。

原14负例为REVOKE后旧LOAD（独立断言）、旧RUN、reset旧LOAD、ACTIVE重复REGISTER，加old_magic、reserved_flags、wrong_profile、wrong_generation、wrong_context、wrong_tag、wrong_build_digest、wrong_bo_allocation_size、actual_bo_base_changed、actual_bo_cookie_changed十例。旧日志有13条REJECT_PASS和最终reject14；旧通用断言只核非零status、done_task0/admission0、binding及无访问/排空，不能追认它已核完整状态。以下新运行补齐其实际断言与恢复范围。

| 新增实际运行 | 身份 / guard | 新覆盖 |
| --- | --- | --- |
| [contract strict02](../attempts/t3_q8s2_act_rtl_contract_strict_02/input_manifest.json) | manifest `215fc45554395df76f7e5bab605cef143aa34d3f131f6191e139ebe0352da148`；exit0 / 225.361571s / 2761320KiB | 23拒绝；8次descriptor-only修正后合法LOAD；坏REGISTER header、padding scale、bias、activation及相应恢复 |
| [contract fast_trace01](../attempts/t3_q8s2_act_rtl_contract_fast_trace_01/input_manifest.json) | manifest `5407bd5ba5c5dc755abecc6c95c7479f3a0f9a77d5122ac946c6a9ff31d1ea30`；exit0 / 206.097202s / 2741504KiB | 21拒绝；同8次重试；坏REGISTER header、bias、activation及恢复，FAST scale扫描仍0 |

两guard均无保护触发；[strict原日志](../attempts/t3_q8s2_act_rtl_contract_strict_02/work/vivado/tm1tn8_session_dma_act_v2.sim/sim_1/behav/xsim/simulate.log) SHA256=`30ba18f7eb8ecfeb1e26239e377ce6dc56609a1c921cca439d54d8aa43dbf7a3`、[fast原日志](../attempts/t3_q8s2_act_rtl_contract_fast_trace_01/work/vivado/tm1tn8_session_dma_act_v2.sim/sim_1/behav/xsim/simulate.log) SHA256=`120a6609ad94ab47eaca331e529fdb04067872fe288a89892e51b69351ac8591`均完整PASS且无Fatal/ERROR。新manifest各仅5项直接引用，本次全部核对，但**不把5项当完整输入闭包**：原strict05/fast_trace02各389项再次逐文件size/hash匹配；新旧实际编译prj各242源文件按attempt目录归一后，仅生成TB不同，其余包括生成IP源码全部同hash。新[r2_06 strict TB manifest](../attempts/t3_q8s2_act_r2_06/tb_strict/manifest.json)及[fast TB manifest](../attempts/t3_q8s2_act_r2_06/tb_fast_trace/manifest.json)各8引用也全部匹配，绑定现维护body、生成器及新TB。由此复用原硬件、配置、fixture和独立gold身份，新增测试覆盖单列；原两LOAD/RUN在新运行仍为strict4447/4449、fast4111/4113及RUN5681cycles。

新通用拒绝断言逐项核精确status/reject/first-error owner、session/ACTIVE generation、last_task/done_task、W epoch/state/max/loadcount/provenance和generation高水位，无新model/activation/output/trace访问；每次命令仍核18次真实binding消费，以及首次done的全部物理、HLS adapter、compute/writer债务0。8个descriptor-only错误修正后，同session合法LOAD得到W epoch1；真实base/cookie变化则使ACTIVE槽INVALID，恢复旧绑定后旧LOAD仍拒绝。**这些注入发生在REGISTER后、尚无READY W**，因此只证明该前置状态下slot撤销与旧LOAD拒绝，不冒称已实测READY权重及其关联cache的失效。

REGISTER坏AUX header只读32个u32=128B，返回E_MODEL/owner2，无算子task；generation高水位已消费1，同gen REGISTER拒绝，descriptor与真实binding共同改gen2后REGISTER恢复。STRICT坏padding scale注入padded n2/g0，首坏element16、实际检查17；两profile坏bias首坏0、STRICT/FAST检查64/0。已接受数值LOAD均消费task1/Wmax1，活W epoch清0、W INVALID/session INVALID、高水位保持1；同gen拒绝，更大gen2 REGISTER→LOAD恢复W1。动态activation +Inf在两profile均读16个512bit beat，消费quant task2/A8epoch1、owner3并保留session ACTIVE/W READY epoch1；无linear、output或trace发布。恢复输入后quant3/linear4、A8epoch2完整RUN再次核8组独立数值、缓存q2048B/scale64/bias2、真实输出及trace/sentinel。

contract strict01原FAIL保留：reset后observed已回sentinel，旧TB错误地把它保存为待比较的设备prior state；r2_05→r2_06差异只有EMPTY初态期望归零/W INVALID及错误打印，硬件/gold未变。该轮尚缺的READY W失效和reset新代完整设备恢复由以下专用短增量补齐，未重跑整个23/21套件。模型首末R、cache READY、scale scan及末observed B的全部细分事件周期仍`NOT_OBSERVED`，不从总周期反推分项。

**最后生命周期闭合增量通过。** [closure strict04输入](../attempts/t3_q8s2_act_rtl_closure_strict_04/input_manifest.json) SHA256=`dc3db5850513082d9592799321249d493d911219eaf9b5c4dc7cc0ded7cf37cf`的5直接引用/1368443B匹配；实际编译prj仍242源，和前次contract strict02归一后仅TB不同，复用前述完整硬件/gold闭包。r2_09的两份生成TB各8引用均匹配，strict/fast生成TB逐字节相同、trace均开。[strict原日志](../attempts/t3_q8s2_act_rtl_closure_strict_04/work/vivado/tm1tn8_session_dma_act_v2.sim/sim_1/behav/xsim/simulate.log) SHA256=`749b95ff68c436b34efc60616b4178415d1611e7e183cb45a7fc1fa539ed7ee7`，guard exit0/146.864236s/2654276KiB；[fast复用输入](../attempts/t3_q8s2_act_rtl_closure_fast_trace_01/input_manifest.json) SHA256=`f386504c4263b54f8805f5b340560976273f03ee943b383b9d62d383020091d8`，[fast原日志](../attempts/t3_q8s2_act_rtl_closure_fast_trace_01/work/simulate.log) SHA256=`3fb2f64fb72d62e8d540d5da53bb05af2a9ffc2c6ba95d85e52dc9dd2b7f6a0f`，guard exit0/67.884753s/860344KiB。两guard无触发，两日志均`CLOSURE_PASS reject=9 invalidated_ready=2 rebuild_runs=3`且无Fatal/ERROR。fast清单500项中499仍匹配，唯一变化为XSim运行输出`xsimkernel.log`；357个不可变snapshot文件与strict编译逐字节一致，实际命令只换fast fixture并启用CLOSURE_ONLY，不能把运行日志算成未变源码。

每profile分别完成两次真实合法LOAD，断言W READY/epoch1/provenance1、last_task/Wmax/loadcount1及generation高水位1，然后在下一RUN保持descriptor不变、真实q0 base加4096或同base改allocation cookie。拒绝为E_PROTOCOL/owner2/reason4、binding0、session INVALID，W epoch/provenance清0且状态INVALID；已消费task/Wmax/loadcount和generation高水位仍1，零新增model/activation/output/trace访问。还原绑定后旧RUN、旧LOAD及同gen REGISTER分别拒绝；descriptor与实际binding共同改gen2，REGISTER→LOAD→RUN完整恢复。第三个序列先建立READY W，再整域reset，旧LOAD在EMPTY/高水位0拒绝，然后gen2 REGISTER→LOAD→RUN重建；硬件reset清高水位的既定语义不改，不声称硬件持久防重放。

三次gen2 RUN每次均核quant2/linear3、W/A8/PS epoch1、ACTIVE generation2、独立q/scale和全部8组dot/dotf/product/term/PS，真实缓存q2048B/scale64/bias2、两个F32输出、trace64及observed sentinel；每命令18beat绑定与首次done全债务0。closure strict01/02的native XSim字符串三元任务调用崩溃、strict03的TB trace-off与trace-on fixture不一致均保留原失败，最终仅普通TB修正、DUT/gold未改。此闭合支持设备RTL内的人工gen2重建；不把合成context/allocation升级为下述真实CPU ACTIVE记录到设备的生产桥。

[r2 Host短测收据](../attempts/t3_q8s2_package_r2_01/host_encoder_short_r2_receipt.json) SHA256=`a1182e158f908dcb29fae2c7d2436ff0797c8d445be53aa066e0cbc3d81f08c1`及5个引用hash匹配，C++断言检查实际r2 header的build完整32B/source32B/tag16B、合成generation2字段和18beat中的五BO尺寸，以及descriptor1023B/observed131071B拒绝，exit0。其record/manifest/context、base/cookie为合成值，generation2硬编码；虽收据引用active_after_reset.json，测试代码未读取它。因此接受纯序列化/短BO边界，不称真实reset后session记录已桥接设备；旧header smoke不追认为r2。

strict03/04原FAIL保留：TB曾对错误generation/context/BO大小等一律期待`binding_match=1`，与实际descriptor和live binding不一致；最终r2_04 TB按例期待0/1，未改硬件或gold。后续增量不追认旧失败；真实XRT/PCIe/HBM、13-BO完整图、Wi/Down/QKV长A-B、最终资源fit及物理150MHz均未由本次证明。

### T2：单A的四shape真实算术/PS重放接受，单B与A+B分别记账

本轮接受的是`PACKED=0`的TM4/TN8候选A：整数product仍有DSP实现意图，整数加法树使用`use_dsp=no`，四row各自恢复浮点并维护PS。四次完整运行的`input_manifest.json`所列输入、编译snapshot身份和输出共120个唯一文件已重算size/SHA256，全部匹配（134.69MiB）；原始日志均出现精确shape的`TM4TN8_REAL_MATRIX_PASS ... candidate=0`、无Fatal/ERROR，guard均exit0且无资源触发。

| 实际attempt及身份入口 | rows / K / N | accepted stripes | 有效逐group数值记录 | guard墙时 / 峰值owned RSS |
| --- | --- | ---: | ---: | ---: |
| [ACT](../attempts/t2_tm4_real_act_lut_01/input_manifest.json) | 1 / 256 / 2 | 8 | 16 | 58.759s / 2361412KiB |
| [QKV](../attempts/t2_tm4_real_qkv_lut_full_01/input_manifest.json) | 4 / 1024 / 3072 | 12288 | 393216 | 408.346s / 911996KiB |
| [Wi](../attempts/t2_tm4_real_wi_lut_full_01/input_manifest.json) | 4 / 1024 / 5248 | 20992 | 671744 | 668.561s / 920676KiB |
| [Down](../attempts/t2_tm4_real_down_lut_full_01/input_manifest.json) | 4 / 2624 / 1024 | 10496 | 335872 | 320.065s / 910176KiB |

原始通过终态分别见[ACT日志](../attempts/t2_tm4_real_act_lut_01/work/vivado/tm4tn8_real_matrix.sim/sim_1/behav/xsim/simulate.log)、[QKV日志](../attempts/t2_tm4_real_qkv_lut_full_01/work/sim/simulate.log)、[Wi日志](../attempts/t2_tm4_real_wi_lut_full_01/work/sim/simulate.log)、[Down日志](../attempts/t2_tm4_real_down_lut_full_01/work/sim/simulate.log)。后三次复用QKV pilot已编译的同一LUT snapshot，runner先核shape、10份stream及其source manifest、源/TB/IP Tcl和编译制品身份，再复制snapshot执行并检查精确PASS和错误文本。本次四份清单的哈希核对包含这些被复用制品。QKV/Wi/Down的120秒pilot均由timeout停止，最后仅到2048/12288、3584/20992、3584/10496；它们只作成本采样，不能代替上表的完整功能运行。

**参考独立性及真实输入。** ACT/QKV取[原独立fixture](../../cpu_embedding_q8_validation_20261010/attempts/task2_real_fixture_20/work/fixtures/manifest.json)；Wi/Down取[本阶段fixture](../attempts/t2_widown_av_fixtures_01/work/fixtures/manifest.json)，来自固定v4、request3/generation1/B1/S128的真实enc0 LN_FFN和GEGLU producer各128行捕获，截取首4行。[capture原日志](../attempts/t2_widown_av_capture_run_01/guard/driver.log)有4请求、3正常、141独立检查点及一次故障恢复终态，guard exit0/139.551s。两份fixture清单内59个唯一引用文件本次另核size/SHA256全部匹配，共54583281B。权重按GGUF独立Q8块逐列逐group核对BO布局；`make_real_fixtures.oracle`调用独立动态量化参考，使用int32精确dot和显式F32的`sa*sw→dot_f32*product→PS+term`生成每group六字段，最终值再与`full_reference.q8_linear_full`逐字节交叉核对。`make_tm4_real_streams.py`只按group外、tile内重新打包，gold不来自TM4输出。

**实际检查范围。** TB对所有活跃row、所有有效lane、所有group检查整数dot、F32转换、scale product、term及commit PS逐位一致；每row commit sequence严格递增，192bit tag中的identity/version/localrow/group/tile与mask/bad_mask逐项核对。Wi完整656个tile覆盖511→512→655的高tile位，Down完整82个group覆盖63→64→81的高group位。trace仅在每group的tile0、每活跃row选`lane=group%valid_lanes`核完整256bit payload并经真实ack归还D4，不能称每lane都有trace；逐lane数值覆盖来自独立FP/PS monitor。每周期检查各row的Q35 `free+reserved+returned=35`；终态必须done无error/protocol_failure、first_error/first_bad均全1，各活跃row的converted/terms/commits均等于总stripes、trace数等于G，inactive row相应计数均0，所有row最终Q35为35/0/0且trace_free=4。

ACT实测7个同tile上一PS commit→下一issue间隔均为3cycles，总和21；252次issue stall体现反馈等待。QKV/Wi/Down在既有预量化stream条件下stall均0，row0最后commit的TB进度计数分别12324/21028/10532；它们不是未经推导即可使用的start-to-done周期，也不证明动态量化/HBM供数能持续满速。

**候选证据分开。** [packing穷举](../attempts/t2_pack_exhaustive_01/work/result.json)覆盖全部16777216个signed8三元组，独立int64验证两product提取，结论仅数学正确。[整数候选03](../attempts/t2_integer_candidates_03/work/xsim.log)为924接受=919返回+5 reset清除、22056 lane/1040 pair；[真实整数短重放](../attempts/t2_real_replay_01/work/xsim.log)为ACT全部8group及QKV首末各64group、136issues/3264lane，非完整QKV。两者guard分别exit0/10.222s与exit0/9.822s。[单A真实ACT R0](../attempts/t2_r0_lut_act_02/work/vivado/tm1tn8_arithmetic_real.sim/sim_1/behav/xsim/simulate.log)和[单B真实ACT R0](../attempts/t2_r0_packed_act_01/work/vivado/tm1tn8_arithmetic_real.sim/sim_1/behav/xsim/simulate.log)均8issues/252bubbles，guard exit0/43.713s与44.260s；单A旧01的Q32断言失败保留，由Q35修复后的02支撑新结论。单独A、B通过不能合并成A+B通过；组合的新证据和一次输入覆盖修复如下，旧候选范围不变。

**A+B组合限定接受。** 实际`tm1tn8_integer_tree_pack_lut.sv`在相同六级管线中复用signed pair packing并对五级17→21bit加法显式符号扩展和`use_dsp=no`；源码属性仅说明实现意图。[组合短整数01](../attempts/t2_integer_combined_01/work/xsim_short.log)guard exit0/19.018s/859844KiB（该guard包含当时的真实重放），原短TB完整覆盖924接受=919返回+5 reset清除、29408 lane比较和1040 pair；四实现逐拍tag/oldPS/valid/dot一致，包含连续发射、bubble及在途reset。

旧01的真实重放另记`FAIL_COVERAGE`：实际`VEC_DIR`只有8条ACT，而TB按136条迭代并硬打印QKV128；未加载项的未知值没有被主动拒绝，因此其PASS字样不构成QKV证据。本次发现已由owner按原合同修复，并仅对受影响真实短例运行[组合真实02](../attempts/t2_integer_combined_real_02/input_manifest.json)（manifest SHA256=`d5fd29e44484cec3dd4c6024df69c42c3ffd9a40680f2e121a59f158de6d7b9a`）：21唯一输入/输出文件159219B全部size/hash匹配，上游10项ACT/QKV源引用7956092B另核匹配，组合四hex逐项确与ACT0..7及QKV0..63/12224..12287的选择一致。入口核manifest/条数/位宽/mask，TB先将数组置X并对全部136项显式`$isunknown`拒绝，再以实际接受数报告ACT8/QKV128；guard exit0/10.225s/859896KiB、无保护触发，原XSim完整136issues/4352 lane比较PASS。旧01缺口不被追认，02也不是完整QKV矩阵。另发现两个组合runner把`rg -Eq`误写为ripgrep的encoding选项，原02末尾错误扫描未生效；本次直接复核原完整XSim无Fatal/ERROR且136项完成，owner已将扫描改为`rg -q`并用原日志及注入Fatal短文本验证拒绝。此为运行后等价脚本检测修复，未重跑RTL、未改02冻结身份或追认旧01。

[组合真实ACT R0](../attempts/t2_r0_pack_lut_act_01/input_manifest.json)的27个直接记录165302B已核匹配；guard exit0/44.050s/1990900KiB、无保护触发，8issues/252bubbles，所有16有效group-lane的dot/dotf/scale product/term/PS逐位通过，前4group选lane0的trace payload及真实ack归还D4、最终Q35=35/0/0、trace_free=4和无protocol_error通过。此局部TB没有生产BO身份桥，不含动态量化、bias或writer。组合接受范围是上述短整数与ACT R0，不继承单A的四shape完整重放，也不宣称A+B已取得DSP节省。

上述四shape总计1400848个有效逐group记录，支持当前单A的真实预量化算术/PS范围。它们不含动态quant、HBM LOAD、bias、最终writer或完整128行producer链，也不覆盖全部122张矩阵；最终PS不是完整Q8输出接口。既有TM4 pilot03的身份拒绝/反压/reset短例按原输入身份复用，不追认为四shape分别做过这些异常。DSP节省、DSP48E2 packing映射、PS/Q35/D4物理存储、整图fit和时序均`UNKNOWN/NOT_RUN`；源码属性和数学packing不能作为物理证据。

### T4：STRICT双W完整供数与lease限定接受

**当前独立reader/双W出口记`PASS_SCOPED`，消费者为被动bank checker。** [正式收据](../attempts/t4_dual_w_full_05/receipt.json) SHA256=`9fecef607f2fb1acbc73922849fedcbe92d650f31f367a3e214d0ddc48808aae`；[冻结fixture](../attempts/t4_dual_w_fixture_01/work/fixture_manifest.json) SHA256=`2b8843727b32f46467ce262c38faeb94ef75de736f4d8421da254421d35000f0`，23个文件/19524933B逐项size/hash匹配。本次重新读取其16个q0/q1/scale/bias包区间并解hex，全部与已接受r2 manifest `46bbd5ab…698018c`的实际BO字节相同；生成器hash和原AUX128B header亦匹配。model identity来自同r2 STRICT descriptor，输入为真实权重字节；本地task/lease上下文由TB构造，没有真实Host REGISTER或MAC生产者。

| 完整fixture / shape | q0 / q1 / scale / bias字节（不含另读AUX header） | 本次全部bank返回 |
| --- | ---: | ---: |
| Wi K1024/N5248，G32/T656 | 2686976 / 2686976 / 335872 / 0 | 10496个相邻双TN8 |
| Down K2624/N1024，G82/T128 | 1343488 / 1343488 / 167936 / 0 | 5248个相邻双TN8 |
| Scorer K1024/N1024，G32/T128 | 524288 / 524288 / 65536 / 4096 | 2048个相邻双TN8 |
| ACT K256/N2，G8/T1 | 2048 / 0 / 128 / 8 | reset后8个单TN8 |

[pilot07输入](../attempts/t4_dual_w_pilot_07/input_manifest.json) SHA256=`e3b25185b9678db3b62647c47391d3074df5e11c255da75cdc7a737a1053c84f`，5份实际编译源/50563B全部匹配；guard exit0/17.192327s/860164KiB，无保护触发。该pilot完整装Wi，仅扫描4096个Wi双TN8返回并与Down填充重叠，Down q0覆盖237376B时主动停止；不称完整Down通过。[full05输入](../attempts/t4_dual_w_full_05/input_manifest.json) SHA256=`828f0a15ab329bb85d88f93e9a50d33b0df65d875a1849eab45142207dc76120`，复用同编译snapshot；5源及19个不可变snapshot文件逐hash匹配且后者与pilot逐字节一致。清单另列的`xsimkernel.log`与`xsim_script.tcl`是XSim运行产物，运行后变化；脚本唯一差异为去掉PILOT plusarg以执行完整例，不声称全部26项运行后零变化。正式guard exit0/6.818310s/852652KiB，无保护触发；[原始日志](../attempts/t4_dual_w_full_05/work/simulate.log) SHA256=`32ff1e06a769a6fee5d1e77952559dcceafea8ef684eafc66f919eefc3f292a1`全部扫描及终态PASS、无Fatal/ERROR。

实际RTL为每槽奇偶tile×8列q/scale/bias bank，保持两槽各5730816B逻辑容量，双槽11461632B，另计FIFO/metadata/物理打包。三路512bit reader各outstanding1、AR前预留完整至多64beat FIFO、按4KiB拆分；q0/q1各64B提交，scale每返回拆四个16B提交；独立128bit AUX reader先核header，再传bias，末8B用窄beat。STRICT检查所有padded half有限且非负，bias仅检查F32有限性、允许负数；错误按本地load_error/坏元素报告，不伪装Q8算子完成。完整q/scale/bias覆盖、实际bank写和全部reader R/FIFO退休才READY。lease/read/release带epoch、完整保存身份及上下文核对，最后实际ret握手后才释放，另一slot可并行填充。源码数组和`ram_style`仍不证明物理RAM端口、容量fit或512B/clk可达时序。

TB逐返回按独立manifest地址公式核全部256bit q、half scale、F32 bias、有效mask和返回身份/顺序；Wi全部10496次双TN8 ret发生在Down slot FILLING期间，证明本例“当前只读lease＋另一槽填充”重叠。端点逐AR检查真实基址/长度/4KiB/64beat，逐R核对应退休，四口commit和返回均有有限反压。wrong首LOAD epoch拒绝且零DMA，IN_USE槽不接覆写，wrong read/release epoch、错完整model identity lease及INVALID槽lease均拒绝。ACT q0首RRESP错误使目标slot1 INVALID，当前Wi slot0仍IN_USE/readers1；下一epoch Scorer首bias +Inf使目标INVALID、bad_element0且完整32768个scale检查，Wi lease仍保留。Scorer再下一epoch4完整LOAD、4096B AUX bias跨4KiB分段与2048返回全部通过。两lease释放后，ACT LOAD在实际AXI响应在途时整域reset（含仿真端点取消域）；两slot身份清空，再epoch1完整ACT LOAD/8组读回、无效bias归零和合法释放通过。

**周期口径保留原事件坐标。** 日志Wi READY=54128、Wi扫描末=66383、Down READY=81200、Down扫描末=87329、Scorer扫描末=110908，均为TB自reset释放累计cycle，包含前置配置/拒绝/lease动作，未单独观测各LOAD接受→done精确窗口。第二次reset后ACT READY=48、扫描末=61，最终`cycles=63 loads=6 overlap=10496`；63不是整例总周期，loads6为六次完成的do_load（含两次预期失败），另有一次在途ACT被reset取消。TB10ns是激励；这些事件既不能直接计作物理HBM带宽，也不能兑现全122矩阵19.237760ms或生产MAC性能。

保留原失败：pilot01的AR burst位宽连接、pilot02的同negedge ready采样，full02实际暴露的ACT无效列bias返回旧/未写RAM值，以及full04的TB Scorer scale期望误写8192。最终RTL将无效列bias归零，TB按128×32×8=32768核scale，原fixture/gold未变，full05已覆盖修复路径。接受范围止于此STRICT供数/lease；T3注册fast profile信任链、真实MAC、完整Q8算术输入链、物理RAM/综合/P&R/Fmax、XRT/板端HBM均未集成或未测，不将相邻模块的独立PASS相乘为完整生产链通过。

### T4：quant16软件功能接受，串行HLS入口尚未落实吞吐结构

[quant16源码/配置清单](../../../vivado/module_design/activation_quantizer/rtl/quant16_hls_preflight_01/source_manifest.json)SHA256=`5fddfa05d4a6b525390980990a2caec501b99666f70480e7e0e9640abc9be591`的29项107636B，以及[真实fixture清单](../../../vivado/module_design/activation_quantizer/rtl/quant16_fixture_01/manifest.json)的19个上游/产品引用1983360B已重核size/hash全部匹配；两个F32输入逐byte等于既有实际LN_FFN/GEGLU完整capture的row0。它们是独立外部fixture，tanh RTL失败不改变这些CPU producer输入的来源，也不能由量化通过解除GEGLU RTL数值依赖。

[CSim01原日志](../attempts/quant16_hls_csim_01/work/hls/csim/report/laya_quant16_functional_csim.log)SHA256=`5f4a3487be80b4a3eb09e45ecd68b42365cd43f446befa05dbe57d59b086a358`，guard exit0/11.091s/1251344KiB、无触发，`CSim done with 0 errors`。当前`csim.stdmath=true`的主机C++执行核K1024一行/32group、K2624一行/82group，3648个q字节、114个half及各组d_full/reciprocal全部逐位通过；TB另拒绝一个错误16lane mask和未发布源。每个真实case新建AStore，仅slot0 READY、slot1未认领；不能把另一CPU预检的双A结果写成本次CSim同一存储上的双槽执行。fixture有amax参考，但这个TB不单独观测DUT amax。task数值身份四tag使用1/2/3/4的合成字节，故不声称实际BO身份桥通过；这次只接受`CSIM_FUNCTIONAL_PASS_SCOPED`，软件每组scalar issue/return各一次不是物理两次除法事件。

[功能HLS syn03 top报告](../attempts/quant16_hls_syn_03/work/quant16_project/solution1/syn/report/laya_quant16_functional_csynth.rpt)SHA256=`b185389337fda71bc6005844decd35728a46778927db3686bc8a99a473d534c2`、[run报告](../attempts/quant16_hls_syn_03/work/quant16_project/solution1/syn/report/run_csynth.rpt)SHA256=`40f8bb96804a2657147ba937b4246a77f8bd226a5ff5478383e3339be1ff89e1`；guard exit0/33.844s/1194552KiB、无触发，RTL生成成功。top HLS估算为DSP3、LUT52762、FF19787、BRAM18K2，目标6.667ns/估计4.767ns；这是该串行功能top的HLS报告，不是物理fit/Fmax。最大latency1294563648cycles是宽字段/循环上界推断，不能用它报告这两个合法shape的实测服务。syn01 CLI退出2、syn02未csynth就export退出1均保留，syn03用正确Tcl完成普通入口修复。

**结构判界为`IMPLEMENTATION_GAP`，不是16lane架构`REJECTED_BUDGET`。** syn03实际[配置](../../../vivado/module_design/activation_quantizer/tb/quant16_hls_synth.tcl)显式`pipeline_loops=0`并关闭自动partition；报告中仅1FMUL/1fdiv，`slots_x`为单bank1024×32bit，q输出为单8bit ap_memory，主循环及16lane循环全部未pipeline，capture内循环每次3cycles、replay内循环3–8cycles。32slot/returns数组只是C++函数调度状态被串行综合，尚未形成§7.3的16M、16bank两扫、真实SCALE/RECIP请求返回或128bit q半组写服务。fdiv原IP c_latency6/c_rate1是配置，其HLS wrapper valid绑1/ce门控且忽略返回valid，不能据此宣布真实divider II1。

实现owner按现有授权继续落实上述原定结构，不改数值、旧ABI、lane/divider/slot数量或资源帽；joint design §7.3.1已补具体bank地址、两扫仲裁、分相位token/预约、真实返回推进、16lane返回/q写、首错及无reset IP排空规则，无新增人工审批门。既有串行top至多执行一次有合理成本依据的局部数值RTL，结果与后续吞吐实现分开；不继续重复串行top来累积性能证据。上述CSim/syn03不产生量化数值RTL、真实IP服务/并行度、生产LN/GEGLU→quant→TM4或20/s通过结论；后续真实16lane局部服务与新数值失败见下节。

### T4：quant16精确适配实际服务限定接受，裸FP失败历史保留

[real03输入清单](../attempts/quant16_stream_real_03/input_manifest.json)25项/127974B在前次集中复核时逐项size/hash匹配；[stream fixture02](../../../vivado/module_design/activation_quantizer/rtl/quant16_stream_fixture_02/manifest.json)22项/76950B引用均匹配，转换器只把前节冻结的真实两行source/q/half/amax/d_full/reciprocal转成mem，不从DUT生成gold。real02与real03硬件保持同一身份，后者将已有其它短例排在tiny之前，使失败不能遮住其结果；real02清单的旧TB hash与后来TB不符，旧记录/原日志保留。精确适配实施后real03原引用中的divider、row、TB及Tcl四个活文件已变化，本次改核[real03保留preimage](../attempts/quant16_stream_adapter_01/preimage_real03/manifest.json)7份源码hash与旧输入清单逐项相符，不用当前源码追认旧运行身份。

[real03原始日志](../attempts/quant16_stream_real_03/work/vivado/quant16_stream_real.sim/sim_1/behav/xsim/simulate.log)记录Wi32组、1024B q、141cycles和Down82组、2624B q、341cycles局部PASS；TB逐半组核全部q、half、d_full/reciprocal和divider操作数，固定每5cycle一次输出反压，终态核全部输入/输出接受、两扫各2拍/group、SCALE/RECIP实际请求返回和16lane乘法半组计数。源码真实16个同步bank和16个FMUL、唯一c_latency6/c_rate1 divider及32slot，不能再用先前串行syn03的1M/单bank描述这一新服务。141/341是TB从start后进入驱动循环到done的局部窗口，不是生产端到端周期，也未单独证明稳态恰为group/4clk、双A发布或物理150MHz。

同一日志还通过零/round混合2group，bad_second_mask协议拒绝，half overflow、单Inf、较晚group先出错而应保留早group错误、两slot分别nonfinite共4项数值短例，以及divider/乘法两种实际在途reset后新合法2group恢复。该service仅有合成task/source epoch/row配置和外部fixture输入；完整NumericIdentity/BufferRef准入、双A实际存储/lease及生产LN/GEGLU→quant→TM4尚未由它证明。原协议/数值断言和成功发布要求继续有效。

**裸FP real03整次FAIL保留。** [real03 guard](../attempts/quant16_stream_real_03/guard/guard_result.json) exit1/40.061545s/峰值1904936KiB，无资源触发；[real02原日志](../attempts/quant16_stream_real_02/work/vivado/quant16_stream_real.sim/sim_1/behav/xsim/simulate.log)同首差。tiny输入`amax_bits=006ce3ee`（F32 1e−38）得到`d_bits=00000000, reciprocal_bits=00000000, status=0, col=65535`，SCALE1/1、RECIP0/0，错误完成两次replay/FMUL并返回成功q。按独立有理数最近可表示值复算，`7136238/127`个2^-149单位RNE为`0000db7f`；其倒数超过F32溢出中点，应+Inf并在原RECIP相位拒绝、首错col0、无q发布。不能将这次FAIL汇总成quant16全部通过，也不能删tiny或改gold接受FTZ。

[实际fdiv XCI](../attempts/quant16_stream_real_03/work/vivado/quant16_stream_real.srcs/sources_1/ip/laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip/laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.xci)及原生成Tcl为floating_point7.1 revision21、Single Divide、NonBlocking、c_latency6/c_rate1、无reset；service直接把amax/127送该IP，按真实result_valid把原结果写d_full，位域d==0后跳过RECIP。当前tiny同时有subnormal输入/结果，单例不能分别测出DAZ和输出FTZ各自贡献；但错误确定位于裸FP服务的次正规数语义，不是gold、half转换或输出采样。历史[119项实际FP审核](../../attention_rtl_repair_20261008/reviewer_q8_actual_fp_boundary_119_characterization_acceptance.json)已有normal输入`037e0000/42fe0000`期望`00400000`却得0，以及subnormal倒数期望finite却得Inf；33/119不同的历史结论不变。本次不另开广泛IP表征。

已有[有限适配实际验收](../../attention_rtl_repair_20261008/reviewer_q8_r0_finite_adapter_actual_numerical_acceptance.json)支持65group/14scalar/18restore及7个normal smoke字段，独立gold2721语义字段、实际raw3067条无差异。本次重核source packet、gold table、raw log、audit和XSim五个关联hash，且位helper源码SHA256=`0ea0cc71b3b6045a7f1d255f2a1e86b6dd6bf57b9328a2b87009a081ffc568fe`与原source packet一致。旧helper的数学边界可复用，原局部65组并未证明新32slot持续服务、ready/valid、原子A写、reset隔离或资源；历史模块design/results的早期“source-only”文字不应遮住后来的有限验收，也不应把有限验收升级到生产集成。

**精确适配候选现为`PASS_SCOPED`，局部数值阻塞解除。** design §7.3.2的共享6级、每级5bit restoring tiny /127、同32项divider预约环、subnormal RECIP归一化/指数恢复，以及原16M活动缩放/q0旁路metadata已实际连入服务；仍只有一个原F32 divider、16M、32group及16bank。tiny每语义请求真实发一笔dummy FP和一笔helper，原完整token与预约index随流水，head只在两返回均到后退休一次；normal返回不得越过较早tiny。FMUL旁路同样等待原half的实际16lane返回，活动route比较真实product，dummy不冒称原乘积。未改独立gold、精度或资源配额；双A仍只是合同容量，当前服务没有证明生产双A存储/lease。

[adapter01正式收据](../attempts/quant16_stream_adapter_01/receipt.json) SHA256=`9733dca3e1a288a485b5827f811808e49e3484b77a3b84a27596859940a7fd75`；[输入清单](../attempts/quant16_stream_adapter_01/input_manifest.json) SHA256=`88c12d344bac5a20bc543779df6429b39af1e9679ea23e8e161f753779db9014`，257项/406043B逐项size/hash全部匹配。收据所引fixture、real03源码preimage、原日志及guard共5个hash一致。[实际XSim](../attempts/quant16_stream_adapter_01/work/vivado/quant16_stream_real.sim/sim_1/behav/xsim/simulate.log) SHA256=`ebe8f253e8799a49648dd9687c8319ccf5c2ba3caddaba4cbbe89674255e8e8c`无Fatal/ERROR，各终态标记齐全；guard exit0/42.981153s/1903516KiB，无保护触发。原real02/03失败与匹配preimage仍保留。

| 本次新运行的真实行 | Wi / K1024 | Down / K2624 |
| --- | ---: | ---: |
| groups / 全部q字节 | 32 / 1024 | 82 / 2624 |
| 局部start驱动循环→done周期 | 141 | 341 |
| SCALE issue/return；RECIP issue/return | 32/32；32/32 | 82/82；82/82 |
| SCALE首末issue→return | 12/109→19/116 | 12/309→19/316 |
| RECIP首末issue→return | 20/117→27/124 | 20/317→27/324 |
| SCALE间隔min/max；slot峰值；divider预约峰值 | 1/4；24；7 | 1/4；32；7 |
| 第一/第二扫读拍；FMUL半组issue/return | 64/64；64/64 | 164/164；164/164 |
| 真实FP issue/return；dummy；helper issue/return；语义return | 64/64；0；0/0；64 | 164/164；0；0/0；164 |
| input/div/output stall周期 | 0/3/14 | 68/3/34 |

上述141/341是**精确适配后本次重新执行**所得，数值相同不表示借用裸服务周期。逐半组核全部q/half/d_full/reciprocal、SCALE原始amax与完整tag；所有组accepted/covered相等。间隔1..4是实际事件统计，包含12cycle隔离、填充、有限输出反压和尾排空的全行窗口不能直接称持续group/4clk或整图吞吐。首次done核独立请求顺序scoreboard清零、SCALE/RECIP语义与真实FP守恒、helper=dummy、无bank/max/div/mul返回及输出债务。

原tiny `006ce3ee`现得到`d=0000db7f, reciprocal=7f800000`，正确numeric INVALID/col0/零输出；SCALE1/1、RECIP1/1、真实FP2/2、dummy1、helper1/1、semantic2。27个受影响独立R0边界为17 READY/10数值拒绝，含零与最小subnormal、63/64、normal边界、倒数溢出邻点、tiny/normal接缝、signed半整数、half0/首个subnormal/overflow。原oracle的E_NUMERICAL编码6映射此row-service的done_status1，两者接口编码不同。本次轻量重新执行原精确有理数reference，仅核所选27例与mixed6：source/scalar/q/活动product/route全部与冻结表及新mem一致；有效17例实际活动FP lane30、旁路514，mixed活动22、旁路170。旁路只要求q/status等价，未把其dummy product当原gold。

mixed6组192qB在48cycles完成，SCALE6/RECIP5、真实FP11/11、dummy4/helper4/4、semantic11、slot峰值6/预约峰值5，正常/tiny/zero交错且保持有限输出反压。原4数值首错、1协议、2在途reset短例全部在新服务重跑；另在helper、归一化RECIP、带q0旁路metadata的FMUL各实际pending时reset，三次均隔离旧返回并用新task/source epoch合法短组恢复。reset后结果仍按独立gold比较，未用软件队列提供DUT算术返回。至此接受外部冻结fixture单row服务及所列有限边界/恢复；完整NumericIdentity/BufferRef、生产双A容量/lease、LN或GEGLU→quant→TM4/Q8真实链、综合资源/fit、P&R/150MHz/上板仍`NOT_RUN/UNKNOWN`。该PASS不解除tanh/GEGLU依赖，不启动新libm图或整体物理验证。

### T5：单bank AV C3/C4数值与反馈限定接受

[QKV只读capture](../attempts/t2_av_feedback_qkv_capture_run_01/input_manifest.json)guard exit0/138.279s/630380KiB、无保护触发，原日志核141检查点/18094384值及故障恢复；真实request3/generation1/B1/S128的enc0/head0 Q/K/V已捕获，V与原同点checkpoint逐位一致。[gold manifest](../attempts/t2_av_feedback_gold_01/work/gold/manifest.json)SHA256=`6ef6594bf516abad6c04aef290743d7223547997b5dc1b715efbf718ecc6e3d5`绑定原请求72个有效mask位置及完整672bit数值身份；独立reference从真实Q/K生成外部prob，再对row0,4,…,124的feature0按128key升序逐次F32乘/加生成4096个product/partial，并与独立av_row终值交叉。prob是外部oracle输入，不是QK/softmax RTL输出。

本轮对AV capture/gold/C3/C4与组合01/ACT R0六份attempt共305唯一文件629554788B重核size/hash全匹配；AV上游gold/编译manifest的98项引用877140B及capture生成/原来源6项hash另核匹配。C4复用C3的同一编译snapshot，其input manifest逐文件绑定xsim.dir、配置和gold；没有悄悄更换DUT/IP/队列。两例使用一个真实FMUL、一个真实FADD、同步1cycle读的16×F32 partial bank和product/commit各Q32；物理RAM映射尚未证明。

| 正式范围 | guard（exit0、无保护触发） | 原始实际事件 | 接受结论 |
| --- | --- | --- | --- |
| [短诊断](../attempts/t2_av_feedback_c3_full_01/work/av_feedback_short_simulate.log)，包含在C3编译运行 | 与C3同guard | 单地址本征F=13；16地址连续256次接受II1；两Q32都填满后阻塞并保持诊断payload；错epoch/row/key三拒绝无写回；FMUL及FADD在途reset后新epoch完整128key恢复 | 局部功能/credit/reset限定PASS |
| [C3真实投影](../attempts/t2_av_feedback_c3_full_01/work/vivado/av_feedback_real.sim/sim_1/behav/xsim/simulate.log) | 66.437s / 1937292KiB | 4096贡献；4064同址反馈均13，sum52832；stalls793；全例5089cycles；product/commit峰值32/12 | 数值PASS；12slot满批无反馈泡假设失败 |
| [C4真实投影](../attempts/t2_av_feedback_c4_full_01/work/sim/simulate.log) | 6.957s / 857508KiB（复用编译） | 4096贡献；4064同址重访均16，sum65024；stalls0；全例4176cycles；product/commit峰值7/13 | 数值PASS；本例局部无泡，16是轮转窗口而非本征F |

真实TB逐贡献检查product/old partial/new partial与完整tag、数值身份及refs回传；mul接受/返回、partial读接受/返回、add接受/返回、实际写回和diagnostic退休各4096。同址下一读严格在前次写回之后；每批末必须已接受/诊断/读计数=n×128、done成功、全部Q/busy债务0，批间才重绑。refs是TB合成的局部标记，不能声称生产BO owner已打通；也没有完整64feature或256bank实物通过。C3接受间隔4095样本min1/max63/sum5008，C4为min1/max41/sum4135，含批间停顿，不用min1替代全例服务。

**服务按测量窗口复算。** 以F=13代入`(128−1)*max(n,F)+n`，C3两批n12读跨度各1663、尾批n8为1659，共4985cycles/head；C4两批n16各2048，共4096，均与原batch日志相符。C3/C4末读→最后写均12、最后写→done均3；这些tail已包含在全例周期，不重复加。按480head条件外推AV读跨度为2392800/1966080cycles，加仍未实测的理想QK1966080后为29.059200/26.214400ms@150MHz；若按本TB全例5089/4176收费，则对应29.392000/26.470400ms。全例计时从reset释放起，含配置、绑定、初始化、批间及尾部，不能改称严格command start→done。TB时钟为10ns，150MHz只用于条件预算换算；这些外推都依赖F256端口/复制与QK服务成立，不构成完整Attention或20/s验收。

### 尚未闭合的性能预算

T1宽版是当前串行CRC/同一LN算术实现的16行服务改善。1433020cycles在150MHz条件下为9.553467ms；机械乘8甚至为76.427733ms，但它只是算术比例例子，**既不是完整128行测量，也不能代表全图50ms/20请求每秒已经达到**。全图还需真实vector池对LN两棵相邻树、标量sqrt/div、GEGLU/U-G配对、残差/RoPE及模式切换供数；T4动态quant仍依赖每次真实激活的两扫、max/div/round/half返回，不能因CPU静态scale验证而删掉。T1宽口不证明这些向量/量化lane已实现。

沿design §7–§8的同一条件账：未来同数值II1的共享vector主体至少46.018560ms，尚未含树反馈/标量非线性/搬运/切换，当前选定历史tanh配置的硬排除见下；quant16两扫18.555093ms、三口LOAD payload19.237760ms、TM16/TN16 A+B的Q8 38.379573ms均有未证实现条件。不能取它们的max当完整延迟；单请求串行Q8+QK/AV已64.593973ms，合法跨模块/跨请求重叠、活跃缓冲/owner、真实R0/PS反馈和shell资源均未闭合。33个既有基本FP边界差异亦不能由本次真实LN输入恰好逐位一致而抹去。整体OOC/P&R/专项时序仍暂停，T1/T3局部结果不构成50ms或20/s验收。

最后新增局部事实是双W完整Wi/Down供数与被动读lease可重叠、精确quant16外部两行141/341cycles，以及Q8S2同硬件ACT每LOAD少336cycles/会话恢复闭合。它们没有共同真实producer、共同全图调度或物理端口证据，故联合账的19.237760/18.555093/38.379573ms条件值不升级为实测，也不以双TN8逻辑ret宽度声称物理512B/clk。

**所选历史tanh四实例的共享vector配置在旧50ms/20请求每秒口径下为`REJECTED_BUDGET`；该参考差距不再构成当前自动淘汰条件。** 此前清单`ed5954a53da8bbcc05b2fda20233ca7163dfc2f6d0512febc055c31460150fda`的42项size/hash匹配，但此前“工程引用闭合”的判断不充分：static01实际编译暴露带attribute的sparsemux依赖漏列，原FAIL保留。修复闭包解析后[static02冻结manifest](../attempts/tanh_service_static_02/work/frozen_source/source_manifest.json)SHA256=`e9907f18a0b7a5cc386f5814b6f0822597c5fc5d5933442edf26c18a86cddea7`列18个叶子Verilog、3ROM、7FP IP，另编wrapper/TB；guard exit0/28.472s/592660KiB，实际厂商库绑定编译成功。FSM本身未改，其下界仍成立。所选叶子SHA256=`5631ababc86c12ca1f244de14d820d2f288077742ae2c9664ad58c34d80020d6`的最短接受环为state1→2→43→1；只有state1接受，活动done/ready只在43，43不能同时接下一调用。由结构得任意相邻成功接受≥3cycles，非样本平均，idle done和被reset清除的调用不算完成。四实例GEGLU稳态服务至少7053312cycles，连同其它既有理想项共11604992cycles=77.366613ms@150MHz，尚未加入树反馈/标量/搬运/切换，足以排除这一具体20/s配置。旧46.018560ms只保留为未来同数值II1候选的条件主体账；此排除既不是实测完整请求延迟，也不是tanh数值已通过/失败，更不覆盖v4未来kernel或所有可重流水实现。

**唯一真实tanh基线已`NUMERIC_FAIL`，本mission该向量数值架构登记`NUMERIC_ARCHITECTURE_BLOCKED`。** [正式收据](../attempts/tanh_service_real_01/receipt.json)SHA256=`d2cd9daf0a0665256f7114b079c19cf305375444aeb8f68b87e2c036e715fccc`及所引gold/源码闭包共66唯一引用hash全部匹配；[原始XSim](../attempts/tanh_service_static_02/work/run_continuous/xsim.log)在ordinal23报`z=bf6cd458, got=bf3a7268, gold=bf3a726a`，相差2ULP，0..22已比较相等。guard child exit1/5.888s/859476KiB、无保护触发；XSim自身虽打印exit0，外层依Fatal和缺PASS正确判失败。首差异后停止，未证明余下2600项、分支服务统计或吞吐。

Wi来自[唯一只读capture](../attempts/vector_wi_capture_run_01/guard/driver.log)：guard exit0/140.122s/633944KiB，真实request3/generation1/B1/S128 enc0的LIN_WI成功后、释放normalized前，仅通过checkpoint观察实际WI BO的row0完整5248F32；其20992B SHA256=`64ada464630ef94ee07385a723dc3786bbaf105673f45603f12b77ad5b0a26a1`。原141检查点/18094384值及故障恢复仍通过；该观察不修改producer数值。独立[参考manifest](../attempts/vector_wi_reference_01/reference/manifest.json)绑定各次F32基本运算与实际libm；本次轻量独立复算全部2624个z及`libm.tanhf(z)`，均与已知8hex的mem/binary逐位一致。ordinal23的Wi=`bf8ccb3a`确实生成上述z。wrapper在接受边沿锁存输入和tag，busy期间保持输入，仅活动leaf_ready且done时捕获结果；TB按tag/顺序以四态case inequality比较，未见支持“未知值、闲置done或采样错位”的证据。

失败来自所选叶子相对独立参考的实际结果差异；目前没有已证实的原合同内连接/调用修复原因，不启动“保持旧位结果”的两轮流水优化，也不更换gold/容差。静态检查已冻结glibc2.39 libm的tanhf/expm1f显示其F32范围缩减、有理修正和两层除法与旧F64 exp/定点ROM图不同；移植该同gold函数属于新数值实现图，不能冒充原图重流水。具体资源必要条件和未来必须修改的合同见design §8.4.6；目前不能证明在312DSP非线性余额及未闭合LUT/FF/RAM账内可实现，亦不声称所有未来精确实现物理不可能。quant16、Q8S2 v2及reader/双W的当前独立出口已按上文范围收口；GEGLU成功发布所依赖的完整Encoder/全图真实producer T6/T7为`NOT_RUN_DEPENDENCY`。当前完整硬件推理仍受所选数值架构FAIL与完整producer未接通阻塞，尚未完成；50ms/20完整请求每秒差距只作远期参考。后续按design §0.2先集中定义一个同gold修复或替代图候选，尚未定义时不直接实现；本回合不启动重工具，也不扩大整体OOC/P&R授权。

### 实质合同变更与普通修复的区分

本轮实质接口变更为design §4的新`Q8S2` v2：新长度/命令/observed/实际BO绑定流及新layout/build身份，旧入口保留。新量化数值失败后，design §7.3.2另集中定义一个复用已证精确位适配的服务集成候选；原F32数学、gold与资源配额不变，允许owner连续落实内部流水/返回选择，不增加逐步审核门。T1 RTL短负例/同域reset补证与T3读回后mutation失效是原合同内的覆盖/实现修复，Sol按授权继续；修复的新源码/实际运行身份单独记录，不覆盖原attempt证据。

### 第1轮综合后评判（2026-10-11，Astra/xhigh）

按用户当时轮次分工，本节在GPT-6.1 Sol/xhigh取得实际模块综合结果后集中审核；原人工轮次停点现已取消，当前由Root在实际技术评判后直接推进，见本节后续更新。当前轮内普通实现修正与下一轮性能候选仍分身份记录。旧tanh叶子的2ULP失败保持原身份，新单实例候选也不由外部fixture通过升级为真实GEGLU/全图通过。

**首次综合身份：`TANH_PASS_SCOPED / HELPER_RNE_FAIL / OOC_COMPLETE / COMPLIANCE_GAP`。** [原收据](../attempts/tanh_libm_round1_01/receipt.json)SHA256=`c227bdf0f4239df5a704fbc962da1762716970d742fd5532f5cc681b07b9216a`；[最终证据manifest](../attempts/tanh_libm_round1_01/evidence_manifest.json)SHA256=`61bec095f1f9296d5960b2484de2615aac05158b9494860a5a2094d20f8cbef6`的103个唯一文件/4048139B本次重核size/hash全匹配，输入与gold前2624项分别与原冻结`z_f32.bin/tanh_f32.bin`逐字节一致。实际OOC脚本/XDC以此最终清单为准；准备期`rtl_manifest`所记的早期OOC脚本与失败`hls.cfg`不冒充成功运行配置，不据可变日志作跨运行零stale声明。

冻结源码按原tanh/expm1分支、常量位型与独立add/sub/mul/div步骤展开，无FMA、重结合或模型输入查表；范围缩减、原指数重建及非有限status1/result0职责可核。独立CPU日志确实支持3270项、另200000有限tanh和600000原生基本运算样本通过；RTL两profile各3270项，含ordinal23=`bf3a726a`、非有限拒绝、完整tag/四态数值、背压稳定与single-slot债务，以及两种reset取消后恢复，均按已运行范围接受。该证据解除原真实2624项在新叶子上的输出差异，不能证明全部有限binary32输入或通用基本运算语义已穷举合格。

**后置源码审核发现明确的RNE实现缺口，不能将上述样本PASS写成基本运算全部正确。** [首次冻结源码](../attempts/tanh_libm_round1_01/frozen_source/tanh_libm_bits.cpp)中`fp_add_bits`对非零异号等幅输入把`lhs-rhs=0`送入`pack(sa,...)`，而`pack`在尾数为0时直接返回`sa`。因此`fp_add_bits(bf800000,3f800000)`按该源码返回`80000000`（−0），独立binary32 RNE应为`00000000`（+0）；−0与−0相加仍应保留−0，不能用一律清零替代。600000个随机基本op样本未覆盖该确定性抵消边界。当前未发现它导致已通过tanh样本最终输出错误，也未证明它在整个tanh可达图中无影响；“每一步均RNE”的声明因此不能接受。Root已将该原合同内实现错误交Sol在第1轮修复并回归受影响CPU/RTL/实际OOC，新身份结果另记，原证据不改写；本节不设置修复编译前审核门。

原身份[实际OOC层级](../attempts/tanh_libm_round1_01/ooc/utilization_hierarchical.rpt)为leaf＋wrapper共10054LUT/7090FF/2DSP，BRAM/URAM0、blackbox0；add2541LUT/1161FF、div2315LUT/1031FF、mul1859LUT/788FF/2DSP各一实例。这是实际模块综合，区别于HLS27334LUT估算；不代表整卡或完整模型fit。6.667ns约束下综合态setup WNS=+2.918ns/TNS=0，但67输入/67输出无delay、HD.CLK_SRC缺失、无布局布线/hold/skew证明，不验收150MHz物理频率。实际日志6条WARNING均已核：unused seen寄存器2、时钟舍入2、空blackbox选择1、HD.CLK_SRC1；非错误终态不能替代这些限定。

原[OOC guard](../attempts/tanh_libm_round1_01/guard_ooc_01/guard_result.json)exit0/381.606920s/4564500KiB，最低MemAvailable398239816KiB，RSS/墙时未触发；但约00:56:06–00:58:16 UTC的130s无可见新语义日志超过120s停止阈值，执行者未及时停下，保留`COMPLIANCE_GAP`。该偏差不抹去实际数值与综合制品，也不能因最终exit0改成完全合规或提高后续额度。

**同轮修正身份当时结论：`PASS_SCOPED / MODULE_OOC_COMPLETE / PERFORMANCE_NOT_IMPROVED / USER_ROUND_REVIEW_PENDING`。** 人工轮次停点现已由用户最新连续授权取消；此标识只保留当时状态，不阻止后续执行。 [02最终收据](../attempts/tanh_libm_round1_02/receipt.json)SHA256=`4a44b0ca1f9f5e84b27b9ae2c567acfdba0fe9d28625f7703ba45d6bb8a73cb0`；[02最终证据manifest](../attempts/tanh_libm_round1_02/evidence_manifest.json)SHA256=`6bb6f8749452491d1eebfda52d9253a915f66618e6388695be3d2980d51254f0`的106个唯一引用文件/4014843B本次重核size/hash全部匹配，包含实际最终源码、TB、配置、制品与guard记录。初始准备清单不代替最终执行身份；原01收据及冻结失败源码、RTL和DCP保持原身份。新源码SHA256=`0bcf7bf377ca191c4aa4612439e39bae2c03e6eb842acc0dadfe8b9e1ba5aab1`的算术变更仅为异号等幅非零抵消显式返回+0，保留原零输入分支的−0＋−0规则；原tanh/expm1运算图、常量、gold、容差和单实例配置未改变。此修正属于第1轮普通实现修复，不是第2轮优化。

[独立定向夹具](../attempts/tanh_libm_round1_02/directed_add_manifest.json)的52项由CPU TB在`FE_TONEAREST`下用`volatile`原生binary32加法生成期望，覆盖4种有符号零组合，以及12个幅值的双序精确抵消/相邻非零结果，含subnormal/normal边界与`bf800000+3f800000→00000000`。CPU逐位比较通过；[实际RTL日志](../attempts/tanh_libm_round1_02/rtl_run/xsim.log)另有同次HLS生成`fp_add_bits`子模块的52项四态逐位PASS，直接触达新支路，不依赖tanh是否触达该支路。CPU另重跑原3270项、200000有限tanh及600000基本op样本；同一冻结3270项的正常/反压两profile、status/tag/单slot债务、背压保持、在途和待返回reset后恢复均通过，完整RTL4037232cycles，guard exit0/40.511643s/859948KiB，无保护触发。原2624项与ordinal23的输出差异在该新叶子实测范围内解除，已发现的helper零符号缺口也已修复；全有限域仍是算法支持声明，不能由这些有限样本升级为穷举证明。

| 02实际计量 | 正常输入/消费 | 相同输入、既定输出反压 |
| --- | ---: | ---: |
| 3270项首accept→末retire，cycles | 2011256 | 2020873 |
| 实际相邻accept间隔，cycles | min4 / max796 | min4 / max805 |
| 真实2178项`abs(z)<1`首次out_valid延迟 | 517..770；sum1417206 | 相同 |
| 真实446项`1<=abs(z)<22`首次out_valid延迟 | 772..795；sum344381 | 相同 |

真实2624项首次out_valid平均671.336509cycles；无真实饱和分支样本，表中min4来自快速边界/错误分支，不能称普通tanh的持续II。按150MHz条件换算，3270项完整混合profile为13.408373/13.472487ms，包含该profile填充/排空；不是完整Laya请求或板端时间。压力额外9617cycles，仅0.478159%，而普通真实服务517–795cycles，当前主要问题是单请求内串行基本运算与单slot逐项执行。新HLS add为1..22cycles、mul13、div1..40，叶子未流水；01的add固定17cycles且存在已知语义缺口，不能把回退该错误当性能优化。02服务较慢，接受为后续同口径正确基线，不写提速PASS。

[02实际OOC层级](../attempts/tanh_libm_round1_02/ooc/utilization_hierarchical.rpt)为10410LUT/7132FF/2DSP、BRAM/URAM0、blackbox0；add2720LUT/1203FF、div2184LUT/1032FF、mul2067LUT/788FF/2DSP，各一实例。实际[DCP](../attempts/tanh_libm_round1_02/ooc/tanh_libm_wrapper_synth.dcp)SHA256=`1e200ec38d347da1debf0af1f3b2f6c1f1481c430165a1ebbee898201213ace7`。该数值区别于HLS27415LUT估算；02采用`RuntimeOptimized / resource_sharing off`，与01默认综合不同，资源差异不能只归因零符号修复或用作公平优化A/B。6.667ns下综合态setup WNS=+2.486ns/TNS=0；仍有67输入/67输出未设delay、HD.CLK_SRC未设、hold未验，无P&R/Fmax结论。原日志实际6WARNING、无ERROR/CRITICAL均核对，含与01相同的四类警告，不能只引用成功终态宣传150MHz物理通过。

[02 OOC guard](../attempts/tanh_libm_round1_02/guard_ooc_01/guard_result.json)exit0/228.657233s/4335924KiB，最低MemAvailable432061292KiB，无语义/RSS/墙时触发。修正guard按真实工具进度行自动执行120s停滞停止，每60s留[语义观察](../attempts/tanh_libm_round1_02/guard_ooc_01/semantic_timeline.jsonl)，不靠人为heartbeat续期；[静默自检](../attempts/tanh_libm_round1_02/guard_stop_selfcheck/guard_result.json)采用测试阈值1s，在1.236050s触发`semantic_stall`并结束owned进程，生产120s阈值保持。02的保护修复接受，01的历史`COMPLIANCE_GAP`不被追认消除。

**第1轮综合后提出、随后已按连续授权执行的第2轮建议：保持同gold与各一份add/mul/div，重构F32 add的归一化、舍入及调用调度，先降低普通输入服务延迟。** 具体候选将逐级条件左移的归一化链改为有界前导零计数/移位结构，并明确保留guard/round/sticky、RNE ties-to-even、subnormal、有符号零及精确抵消；只改变加法实现调度，不重排libm数学步骤，也不同时扩副本或加入多请求调度。优先此项的依据是加法多次处于函数依赖链，当前普通add最坏22cycles，而现有输出压力只增加约0.48%；仅扩队列不能缩短这条已测算术链，直接复制大量叶子亦没有整卡资源依据。流水结构/周期目标以该候选实际综合与RTL为准，不预报未经验证的倍数或强制II1。

按用户取消人工轮次门的最新要求，Sol连续完成该候选的一整轮实现、受影响数值/协议回归及模块OOC，再由Astra集中评判；实际第2轮结果见下。对照固定02输入/gold、52定向及受归一化改动影响的有限RNE边界、原两profile/reset与计时起止；正常3270项span和真实分支延迟必须实际改善，资源/首延迟/接受间隔分别列出，不能只拿快速分支min或仿真墙时作提速。OOC固定02器件/时钟/指令/共享设置，若必须改变配置则明确不可公平归因；报告相对10410LUT/7132FF/2DSP的资源代价，维持原成本帽与单重工具，不恢复整体OOC/P&R。若该候选无改善或数值失败，如实记录具体限制；后续按综合后技术判断推进完整生产链及已定义的有界吞吐方案，不恢复人工轮次门。

第1轮技术出口按上述局部范围收口。用户后续已取消人工轮次停点，主控据实际技术结果直接推进；第2轮实际出口见下，不能把此前等待文字作为当前停止条件。完整GEGLU基本算术与真实供数、Wi→GEGLU→Down、完整Encoder/全图、当前完整硬件身份的CPU/CSim与分段集成、P&R/上板/端到端性能仍未由本轮证明，T6/T7生产链依赖状态不自动改成PASS。旧原型的错误不能继续代表新叶子的已测结果，新局部PASS也不能代替完整Laya加速器交付或GPU比较。

### 第2轮实际综合后评判与完整生产路线更新（2026-10-11，Astra/xhigh）

**`PASS_SCOPED / LOCAL_PERFORMANCE_AND_RESOURCE_IMPROVED / MODULE_OOC_COMPLETE`。** 本结论在实际综合完成后给出，不预先接受随后真实GEGLU或空间流水结果。[第2轮收据](../attempts/tanh_libm_round2_01/receipt.json)SHA256=`6e2c6792c9ca7ac0f95e1a844d0f256bd9f96dc83b414d08c6bfeb8850954312`；[最终manifest](../attempts/tanh_libm_round2_01/evidence_manifest.json)SHA256=`4b996bd8ccc7411402fed8a0cf3e07275eda6701874935aecafe33cd94f9b512`的97个唯一引用/4194729B重核size/hash全匹配。原4份tanh输入/gold文件与round1_02逐字节一致，345项定向前52项不变；wrapper、OOC Tcl/XDC也逐字节相同，因此本次可作同配置局部对照，不沿用01与02综合配置不同的比较。

源码只为add引入五层有界前导零/移位及32bit jam/pack，非零输入才进入其归一化，先保留精确抵消/±0分支；最大28bit扩展尾数加减适合32bit，RNE、subnormal、sticky与进位舍入规则保持。mul/div及tanh/expm1数学步骤未改。独立原生`FE_TONEAREST`期望扩展到345项，覆盖各归一化深度、ties-even/odd、sticky、大移位、subnormal与溢出边界；CPU及同次生成add RTL逐位PASS。CPU原3270项、200000有限tanh与600000基本op样本重跑通过；[实际RTL](../attempts/tanh_libm_round2_01/rtl_run/xsim.log)的3270正常/反压、tag/status/债务/背压与两reset恢复均通过，总2511522cycles，guard exit0/31.178417s/859808KiB、无保护触发。有限样本及已核实现范围接受，不写全有限域穷举证明。

| 同口径局部指标 | 第1轮02正确基线 | 第2轮实际结果 |
| --- | ---: | ---: |
| 正常3270项首accept→末消费，cycles | 2011256 | 1249315，减少37.883840% |
| 同输入/同反压profile，cycles | 2020873 | 1256248，减少37.836371% |
| 真实2624项首次out_valid延迟 | 517..795；sum1761587 | 348..473；sum1091811 |
| 正常/反压最大接受间隔 | 796 / 805 | 474 / 477；min4仍是快速分支 |
| 实际模块LUT / FF / DSP | 10410 / 7132 / 2 | 9073 / 6510 / 2 |

正常模块服务率约为基线1.609887倍，LUT少1337、FF少622；这是相同数值输入、边界和综合配置下成立的局部改善。[实际OOC层级](../attempts/tanh_libm_round2_01/ooc/utilization_hierarchical.rpt)确认add1365LUT/491FF、div2280/1030、mul1872/788/2DSP各一实例，BRAM/URAM0、blackbox0；HLS add最大6cycles（原22）、mul13/div40不变，leaf最大478，仍是单slot非流水服务。[OOC guard](../attempts/tanh_libm_round2_01/guard_ooc_01/guard_result.json)exit0/179.395135s/4343764KiB、最低MemAvailable418773580KiB，无触发。6.667ns内部综合setup WNS+2.486ns/TNS0、实际6WARNING（unused观测标志2/时钟舍入2/空blackbox选择1/HD.CLK_SRC1），无ERROR；I/O delay、hold、P&R/Fmax及整卡fit仍未验。DCP SHA256=`bb703675b0714b3d54ff355e51bf73c63cf288aa03873e443f3d10033f2f1a9f`；实际综合资源不与HLS21909LUT估算混同。

**局部改善仍未解除完整模型的标量tanh吞吐瓶颈。** 真实工作量为28×128×2624=`9404416`次。第2轮已测row的首次valid合计1091811cycles，当前单slot正常消费后再接受还需1cycle；只在重复这一行分布的假设下，均值417.086509cycles/结果，对全模型投影为单叶26.149700s、理想四份6.537425s（150MHz条件）。第1轮同口径42.152881s已由此更新；二者都不是完整模型实测或全有限输入下界。旧77.366613ms来自数值失败的旧FSM，不能代表新正确叶子。工作量、条件及新的单流服务账已原位写入[design §5.1](design.md#51-正确libm叶子的全模型服务影响第1轮实际综合后更新)。

当前直接推进[design §0.2](design.md#02-下一段有界功能与性能路线)的ACT真实F32→quant16→完整A发布/lease→双W→TM4/PS/bias→writer末物理响应，以及正确bits/quant16/四row Q8真正绑定的新身份完整CPU/CSim。vector侧先完成Wi5248→所有真实GELU基本运算/tanh/gate2624，再接quant/Down与实际Wi producer，外部z/gold不作链内供数。第2轮add尝试至此收口，不再无止境改串行叶子来代替完整加速器推进。

下一项高吞吐实现已集中定义为[design §8.4.7单流同图空间流水](design.md#847-单流同图tanh空间流水实现合同)：保留全部有限分支和逐步F32，两个精确divider分别用于内部expm1及外层tanh，单流有界24 add/sub、18 mul、2 div图节点及512总credit；算术、寄存/FIFO/标签全部由既有预算付款。首个出口为原128项pilot、完整3270双profile与345 add及受改动乘/除边界、credit满/混分支/reset，再取得模块OOC；II1需真实持续服务验证。若单流II1成立，tanh条件主体62.696107ms；与其它历史理想vector项相加为93.040640ms＋真实tail/标量/供数，仍不是完整请求性能。50ms继续仅作远期参考，不据此扩数百叶子或恢复整体P&R。

用户已明确只看最终完整加速器，取消人工轮次审核。以上实际技术评判后由Root直接协调已授权后续；没有新增预审或逐步放行门。完整CPU/CSim、真实分段RTL、同runtime整层/整网、模块OOC、P&R及上板各自登记；本轮只关闭所列局部出口，完整GEGLU/生产链及当前全图尚未取得的结果不提前验收。

### GEGLU完整行重放实际综合后评判（2026-10-11，Astra/xhigh）

**`PASS_SCOPED / CHECKPOINT_REPLAY / MODULE_OOC_COMPLETE`。** 本次接受冻结v4/request3/generation1/enc0的Wi row0完整5248项输入，经生产GEGLU算术得到2624项输出的检查点重放。[正式收据](../attempts/geglu_libm_producer_01/receipt.json)SHA256=`7152332cb9f42ae9e51f973617f345fd628ba89422aba4627820a1f62bc68f90`；[最终证据清单](../attempts/geglu_libm_producer_01/evidence_manifest.json)SHA256=`a23e0bacb1f291f65fab29ce950a657a4f8b5dcd8ac3a5d391836bf771b7fa30`。收据和清单递归合并101个唯一引用文件/4725639B，size/SHA全部匹配。它不证明同runtime Q8 Wi producer→GEGLU→quant→Down、完整controller/owner/AXI或整图已经通过。

**输入、gold及实际生产源码身份。** [冻结源码清单](../attempts/geglu_libm_producer_01/source_manifest.json)绑定实际生产依赖；其中`tanh_libm_bits.cpp`与已接受第2轮逐字节相同，SHA256=`c470b4c566ec714388ef84c4b68057c1802be650973b876390dbb6deb066350a`。本次`wi.bin`与[原独立参考清单](../attempts/vector_wi_reference_01/reference/manifest.json)引用的真实Wi捕获逐字节相同，`steps.bin`与原`gelu_steps_u32x10.bin`逐字节相同，两个RTL `.mem`逐词与对应binary匹配。GELU常量a=`3d372713`、c=`3f4c422a`；完整顺序为`u=a*x; v=u*x; w=1+v; t=c*x; z=t*w; h=tanh(z); r=1+h; s=0.5*x; y=s*r; gate=y*G`，保留独立binary32 RNE、subnormal、有符号零及逐步finite检查，无FMA、FTZ、重结合或近似倒数。leaf先检查G有限，算术失败返回status1/result0。

CPU TB实际调用生产`laya::full::geglu_row`计算整行，另将leaf的全部10步与上述独立steps gold核对，原终态`GEGLU_PRODUCTION_CPU_PASS wi=5248 outputs=2624 independent_step_comparisons=26240`；[CPU guard](../attempts/geglu_libm_producer_01/guard_cpu_01/guard_result.json)exit0/1.072045s/68984KiB，无触发。这只关闭生产算术行入口，不替代正在推进的新身份完整CPU/CSim。收据列明的7份生产依赖为`vector_full_compute.cpp`、`vector_libm_bits.cpp`、`full_tasks_vector.cpp`、`gelu_libm_bits.cpp/.h`、`tanh_libm_bits.cpp/.h`；实际任务源码可见完整Wi读取、GEGLU行计算、输出写入及成功cover/error invalidate owner，但源码存在不升级为这些生产控制路径已取得RTL验证。

**实际RTL数值和局部协议覆盖。** [原始XSim日志](../attempts/geglu_libm_producer_01/rtl_run/xsim.log)中正常及反压两profile各装载5248输入、消费2624输出、比较26240个独立步骤；合计5248输出/52480步。10步trace来自实际HLS写口，各列覆盖位图禁止遗漏或重复。wrapper完整装载两份2624×32bit U/G RAM后，使用单算术leaf和单返回slot逐列计算；本地32bit tag及index/last/status在反压时保持，正常末列index2623置last。TB分别在装载31词、column23算术在途20拍、待返回反压20拍时reset，随后800拍无旧输出/trace，并完成整行恢复；首输入index1触发status2、U[0]注入NaN触发status1均通过。终态`GEGLU_ROW_RTL_PASS ... reset_loading=1 reset_inflight=1 reset_pending=1 malformed_index=1 numerical_reject=1 cycles=2933173`，[RTL guard](../attempts/geglu_libm_producer_01/guard_rtl_01/guard_result.json)exit0/36.407013s/860060KiB，无触发。变tag拒绝、晚列数值失败、完整NumericIdentity/BufferRef、下游A原子发布/lease及物理AXI债务均不在本次实际测试覆盖内。

| 完整行实测指标，cycles | 正常 | 反压 |
| --- | ---: | ---: |
| first input accept | 36004 | 1488718 |
| first out_valid | 47093 | 1499807 |
| last output retire | 1476803 | 2933173 |
| 首input accept→末output retire | 1440799 | 1444455 |
| leaf start→消费 min / max | 475 / 600 | 475 / 610 |
| leaf start→消费合计 | 1425057 | 1428713 |

两profile输入到首valid均11089cycles；row span包括完整Wi装载、TB逐词供数、计算和返回消费，150MHz条件下为9.605327/9.629700ms。`start→消费`在压力下含等待，不能改称首次valid算术延迟。该工作量及起止不同于第2轮3270项混合tanh，不能据两者span计算提速，也不能称同runtime整层/请求性能。

**实际综合资源和时序边界。** Vivado2025.2、`xcu55c-fsvh2892-2L-e`、`RuntimeOptimized / resource_sharing off / flatten_hierarchy none`下，[实际OOC层级](../attempts/geglu_libm_producer_01/ooc/utilization_hierarchical.rpt)为**9347 LUT / 6689 FF / 2 DSP / 8 RAMB36 / 0 URAM / 0 blackbox**。wrapper自身136LUT/173FF及8RAMB36，leaf9211LUT/6516FF/2DSP；add1367LUT/491FF、div2280/1030、mul1872/788/2DSP各一实例。HLS的22617LUT/6653FF/2DSP/BRAM0是leaf估算，不能漏计实际wrapper存储；HLS leaf最大latency606/interval607，add6/mul13/div40。实际[DCP](../attempts/geglu_libm_producer_01/ooc/geglu_row_wrapper_synth.dcp)SHA256=`65beb672b67ca8d8c8cd5b6d089def187e676e4bbefaeded1ea889434645d63f`。

[OOC guard](../attempts/geglu_libm_producer_01/guard_ooc_01/guard_result.json)exit0/197.245760s/4354560KiB，最低MemAvailable414921688KiB，无保护触发。6.667ns约束下综合网表setup WNS+2.486ns/TNS0；本模块80输入/162输出未设delay，HD.CLK_SRC未设，hold/P&R/达到的Fmax未验。no_clock、内部unconstrained endpoints和loops均0。原日志6条WARNING分别为unused观测标志2、时钟舍入2、空blackbox选择1及HD.CLK_SRC1，无ERROR，成功终态为`TANH_LIBM_GEGLU_VIVADO_OOC_PASS blackboxes=0`；因此只接受模块综合网表资源与内部setup估计，不宣称接口或物理150MHz通过。

**后续直接沿现合同接生产链。** 当前wrapper按列交付，完整row成功前可能已有成功前缀。接quant/Down时必须暂存该前缀或保持目标无效，只有整行成功且真实返回/写债务清零后才发布A READY；晚列失败或reset必须撤销前缀，并按实际任务完成条件释放输出及源lease。生产owner沿现有完整身份合同实现该交接，新增集成例覆盖晚列失败和变tag拒绝，不能由本地32bit tag通过代替。新完整CPU/CSim应绑定上述7份实际依赖重新生成身份、保持独立gold，再以实际完成结果记账。已定义的空间流水候选由Root复用Sol连续执行CPU/RTL/OOC；当前候选尚无实际运行结果，本次不预审或验收，不重跑已通过旧测试、不新增正式审核文件或人工停点。


### 单流tanh实际RTL与综合成本出口集中评判（2026-10-11，Astra/xhigh）

**`PASS_SCOPED / CHECKPOINT_REPLAY / OOC_COST_ABORTED_SEMANTIC_STALL`。** [stream02收据](../attempts/tanh_libm_stream_02/receipt.json)SHA256=`22ad69a6dbdf9d621932a4c7cd4102da594a559d3846d09f0e1296f4b37a3d32`，source manifest=`a089612c3cbd55421c8e8ccc8dee408444495e022e28ef1b1d789db233c3ade9`，evidence manifest=`6fb4220f98f89638b4c64dc0f7485c45b97c4fda1410f418d0c2a53df1915825`。本次读取receipt/source/evidence合并283个唯一引用，共11083086B，size/SHA全部匹配；核对实际HLS RTL/源码、helper/main原始XSim终态和OOC Tcl/日志/guard。没有运行重工具，没有更换gold或已冻结源码。

完整原fixture2624真实z＋640有限补例＋6非有限项，两profile各3270输出逐位/tag/status通过；CPU同原规则另有200000有限tanh/600000基本op通过。1159项实际主图child helper定向（345 add、409 mul、405 div）使用独立native volatile F32 RNE期望，保留原52项add前缀；选取的是具有完整32bit输入端口的实际add0/mul14/div0，包含真正输入捕获级，after-NBA延迟5/13/11、捕获边6/14/12。其它专用节点由完整图覆盖，1159不是逐个42节点全端口穷举。早先TB literal解析和漏计helper输入捕获失败均保留；修正未改算术/参考。

| stream02真实RTL范围 | 正常profile | 有限反压profile |
| --- | ---: | ---: |
| 输入/输出数 | 3270 / 3270 | 3270 / 3270 |
| first accept / first valid / last retire | 6589 / 6965 / 10234 | 10236 / 10612 / 16684 |
| 接受→末消费跨度，cycles | 3645 | 6448 |
| core固定延迟，cycles | 375 | 375 |
| 实际accept gap min/max | 1 / 1 | 1 / 16 |
| 峰值总credit / credit停止拍 | 376 / 0 | 512 / 2230 |
| Dexp issue/return；Dtanh issue/return | 各3270 / 3270 | 各3270 / 3270 |

正常profile证明该fixture连续II1；压力下按真实credit停顿，不能宣称无条件II1。首次可见out_valid与accept差376包含wrapper观测边界，core375与之分别报告。另640项混分支fill/drain实际填满512、停止376拍后恢复；算术在途及待消费reset通过，旧返回不污染新credit。divider计数取实际父有效调用阶段250/357及捕获262/369，未把ap_ce高电平当token握手。主RTL guard exit0/24.769652s/859924KiB，helper最终exit0/5.623237s/859988KiB，无保护触发。相同3270正常fixture相对第2轮标量span减少99.708240%，这是局部服务比较；没有把外部z重放当真实Wi→GEGLU完整链。

当前源图24 add/sub、17 mul、2 div位置；add23常量折叠成`3f800000`，生成实例23/17/2，未超过本合同。512总slot的data/tag/status声明6144B，另有大量流水data/valid/mux/metadata；没有实际RAM映射。HLS latency375/interval1，估算187314LUT/73660FF/48DSP/0BRAM/0URAM，**全部只是HLS估算**，不能代替物理资源或用48DSP证明预算闭合。串行第2轮9073LUT/6510FF/2DSP以及串行GEGLU9347LUT/6689FF/2DSP/8RAMB36的实际OOC继续作为不同实现基线，不给本stream免费继承。

[实际OOC01](../attempts/tanh_libm_stream_02/guard_ooc_01/driver.log)已用`flatten_hierarchy none / RuntimeOptimized / resource_sharing off`，进入Cross Boundary/Area Optimization后连续120.087438s无新工具语义输出。guard child−9、220.478544s、owned峰值11218356KiB、最低MemAvailable431619204KiB；这是已配置semantic保护触发，未触及内存/墙钟硬帽，无证据说明数值失败或Vivado内部死锁。actual utilization/timing/DCP/blackbox结论均**未生成/UNKNOWN**。

后继只采用[design §8.4.8](design.md#848-stream02成本中止后的唯一有界综合修复)定义的42个实际child逐节点DCP及父wrapper回填；所有节点/父层/装配共享一次累计3600s、24GiB、120s真实语义保护和唯一重工具锁，最终blackbox0才算完整模块综合完成。不原样加帽，不把局部DCP加和当最终模块。RTL/gold未变则复用上述功能PASS，仅重做综合装配影响范围；正确串行GEGLU生产连接并行推进。

完整tanh工作量已改正为Encoder9404416＋Scorer16384＋ACT256=`9421056`，Decision4096为ReLU。逐GEGLU行排空时Encoder须收费3584×375cycle tail，150MHz条件71.656107ms；Scorer16row和ACT1row也逐次排空则全部tanh为71.809540ms。62.696107ms只是Encoder主体量；这些数仍未含前后7M/2A、供数/输出、其它算子和实测Fmax，不能宣布完整请求速度。

### 生产接口与同期真实出口的集中更新（2026-10-11，Astra/xhigh）

**七shape physical bias/writer缺口已形成可执行合同，尚无新接口RTL PASS。** [design §3.7](design.md#37-七种真实q8形状的物理bias输出合同2026-10-11集中修订)以原production `write_linear_output/full_f32_address/qkv_address`为地址真源，覆盖全部七种K/N：G总数u8、索引/tag u7、tile/T u10、n0u13；保留完整u64首错rank。新增416bit内部包、完整owner驻留、同步bias读/返回容量、四row有序汇合、真实行/批步长、QKV固定physical stride、末B/所有债务、尾mask、错误恢复及reset取消域已一次定义。旧ACT06冻结接口/数值证据保留，13BO Host ABI不改。生产owner已确认新包和完整owner表可接当前生产路径，按原授权直接实现受影响范围，无局部人工门。

**当前冻结完整Vitis CSim已完成。** [CSim02收据](../attempts/current_production_full_vitis_csim_02/receipt.json)SHA256=`79632084106bc17c4ab31f1dac482b7d75074dd8cf00fa8d2d720ff827b805b7`，build=`23c62cd4778f54e3cc7508f5d05558de`，实际终态`PERSISTENT_CPU_FULL_CSIM_PASS requests=4 normal=3 checkpoints=141 values=18094384 recovered_fault=1`；guard exit0/317.125676s/1789276KiB、无触发。主控已核原日志/guard，本轮读取对应收据与实际依赖记录；与原g++全生产CPU证据分开登记。这是13BO wrapper下生产dispatcher的C模型执行，不是13BO真实AXI/生成RTL或新七shape packet、新Attention blackbox已经接通的证据。

**ACT06实际OOC01为工具展开失败。** [收据](../attempts/t2_act_production_ooc_01/receipt.json)SHA256=`93bbf9fba5942ff4019506089d2d34431d1b6fe6a4f3f5aee97a9e405c5b770e`保留同ACT06的27项冻结输入。真实`Synth 8-4556`指出dual-W `qmem`为85983232bit、超过工具默认var_size_limit1000000bit；guard child1/32.235356s/3667340KiB、无触发，utilization/timing/DCP均未生成。该失败不是数值失败、物理内存超卡或资源保护停止。允许同27冻结RTL仅修Tcl变量解析容量，服务器24GiB/3600s/120s帽不变；actual映射结果取得后再判断资源，不将parser设置当物理能力。

实际[`t4_dual_w_cache_v1`](../../../vivado/module_design/hbm_loader_and_cache/rtl/t4_dual_w_cache_v1.sv:99)双槽各有2个tile奇偶×8列bank：q为32×10496×256=`85983232bit`，scale为32×10496×16=`5373952bit`，bias为32×328×32=`335872bit`，合计91693056bit=`11461632B`（每槽5730816B）。q的ultra和scale/bias的block只是映射意图。读返回为每slot奇偶×8lane的同步注册值，双TN8读一次合计16×256bit q=512B及16scale/16bias；W当前只读lease及另一slot填充的端口/容量全部计费，不凭ACT N2裁成小缓存，也不重复扣成单槽。真实URAM/BRAM、宽深打包/碎片、mux/metadata、端口持续服务和时序在OOC完成前都UNKNOWN；若顶层常量剪除了通用容量，报告仅该专用ACT网络，不能代签全shape双W。

**Attention chain+ap_ce处于功能候选。** 同期[CPU04 guard](../attempts/t5_attention_cpu_04/guard/guard_result.json)exit0/1.553109s/88620KiB，owner报告完整128query和中间值、stale scratch拒绝通过；[HLS05 guard](../attempts/t5_attention_service_hls_05/guard/guard_result.json)exit0/23.180782s/1196172KiB，真实chain/ap_ce端口与单MUL/ADD/DIV已生成，HLS估算21504LUT/7939FF/22DSP/69BRAM18K仍不是物理结果。§8.1.1已集中限定完整55字身份读回、QK→SM→AV屏障、真实claim核对、variable-latency调用退休、FP/RAM共同CE暂停及reset语义；仅K/V/SCORE/PROB源码容量已有5242880bit，69BRAM估算不足作部署账。当前owner在跑真实RTL pilot，尚无本轮完整RTL/OOC接受结论，不以CPU/HLS或候选JSON替代。

本次集中评判收口后由Root复用原Sol实施者继续；仅联合design/results由本轮更新。整体OOC/P&R/专项时序仍暂停，无U55C。当前完整CPU/CSim、ACT局部RTL、stream局部RTL各有各自范围；同runtime整层/整图RTL、全资源/实际频率和完整高性能加速器未完成。


### ACT OOC02存储成本停点与同容量修复（2026-10-11，Astra/xhigh）

**`COST_ABORTED_SEMANTIC_STALL / MEMORY_MAPPING_UNKNOWN`；已形成可直接实施的存储修复。** [OOC02收据](../attempts/t2_act_production_ooc_02/receipt.json)SHA256=`bc3d034dd345183d7a2bf8ba677a688825a5b9a1e30c1c51db9f86e0148dded6`，本次亲核27项冻结输入列表与OOC01完全相同且各文件size/hash匹配；源码/gold未改。Tcl仅增加`var_size_limit=100000000`解析容量设置，越过原Synth8-4556。新[日志370行](../attempts/t2_act_production_ooc_02/guard/driver.log:370)开始报告qmem未推断为RAM、ram_style被忽略；[821–823行](../attempts/t2_act_production_ooc_02/guard/driver.log:821)报告q/s/b多维对象各85983232/5373952/335872个register的3D-RAM运行成本警告。随后连续120s无工具语义进展触发保护，child−9、205.106654s、owned峰值9776424KiB、最低MemAvailable434836632KiB。没有utilization/timing/DCP；不是物理fit失败、数值失败或内存硬帽触发，也不能把中途register字样当作最终FF映射。

源码明确每个slot×parity×lane实际只有独立q/s/b单写口、单同步读、停读输出保持，全部payload无reset；32个逻辑bank却声明为三个大多维对象并由多个生成时钟过程访问。该结构及上述工具警告支持拆成32个独立1D bank，单纯继续增parser大小无法解决已观察到的推断/成本问题。[design §7.2.1](design.md#721-act-ooc02后双w的同容量1d-bank修复2026-10-11)已固定最小修复：每bank q256×10496、scale16×10496、bias32×328，父层全部地址/使能/metadata/lease状态保持，接受read后的同edge数据/ret身份仍对齐，无额外延迟。总额仍11461632B、每槽5730816B；全32bank中当前slot16bank可以一次返回512B，另一slot16bank接受LOAD，不降低读宽或按ACT小形状裁容量。

物理闭合先取得一个完整动态地址bank的真实RAM DCP，再按同body/参数/端口hash复用32次装配通用cache并接ACT；父reader/FIFO/身份/控制和ACT实际算术/输出全部纳入最终报告，bank/cache/ACT最终blackbox0才登记完整模块OOC。单bankq仍大于默认parser阈值，可保留100000000设置；整个综合闭合累计3600s/24GiB/120s语义保护/唯一锁不变，不给每bank或每层新增额度。尚未实施/完成的新bank资源保持UNKNOWN，不预报URAM/BRAM实际数量、fit或Fmax。

Root已明确将旧cache工作源、新`t4_w_cache_bank_v1.sv`及受影响TB/脚本/模块文档独占交给生产Sol。新RTL必须重跑全深度独立地址pattern读写、原dual-W完整Wi/Down/Scorer/ACT及缺少三shape的真实完整LOAD/读回、G128/末地址/奇偶/pair/反压、LOAD与读重叠、lease/epoch/失败隔离/reset，并重跑原ACT06受影响完整片段。原gold与未改模块证据复用，旧ACT06/dual-W功能PASS只保留原身份，不代签新RAM；不要求重跑未变整图CPU。该修复授权不是功能或资源PASS，普通实现/修复连续推进，无用户或逐步源码审核门。


### 三类canonical同图流水与完整GEGLU量化桥的集中收口（2026-10-11，Astra/xhigh）

**实际成本不支持继续42专用节点路线；新父图已一次定义，尚未执行或通过。** 本轮亲核[bottomup01收据](../attempts/tanh_libm_stream_bottomup_01/receipt.json)SHA256=`79d87dbc2972f52fc75243b64619cb3e0923aa346f3cdfc69eb7a3754855f221`。add0 child得到1436LUT（1368logic＋68SRL）/595FF/0DSP、blackbox0及DCP，guard100.629917s；mul14在120.343482s timeout，虽已完成synth阶段，脚本先跑timing导致未持久化DCP，不能登记mul物理通过。共220.973399s，剩3379.026601s。原同class总成本预测/乐观byte敏感性均不是严格墙时下界，但已没有足够证据支持继续42节点及父装配的可完成假设。只做module名归一化仍42种；本轮只读词法alpha侦察候选36类（add0/11/13/14/15、mul13/16、mul14/15可疑同类），未形成严格连接/常量/寄存/CE/依赖等价证书，不用于DCP替换。

[design §8.4.9](design.md#849-逐节点成本实测后的三类canonical流水子核与新父图)取代该成本假设：精确add0/mul14/div0完整输入子核各综合一次，新父RTL按原23A/17M/2D位置显式复制相同模块，源图、分支、RNE/次正规/±0不变。静态edge表及operand/谓词/token对齐已确定，候选输入E0到返回FIFO提交E384，最早E385消费；新L384不继承旧RTL375cycle通过。原累计成本保留，余帽支付helper/父/完整装配/一次final timing，脚本先存DCP和resource、后timing；最终blackbox0才登记完整OOC，失败不追加另一生成候选。现有stream02数值/II1/512credit与串行GEGLU通过均仍限旧身份，新父图需原受影响实际RTL/独立gold/满credit/reset，再接实际GEGLU。

**完整生产桥已定义，ACT小容量不能代签。** [design §7.3.3](design.md#733-完整geglu来源通用双a与down交接合同)核对原`full_tasks_vector/geglu_row/activation_quantizer_compute`：WI5248整行捕获→原G优先及逐步GELU/gate检查→整行2624成功才物理写GATE→整task各行真实末B/债务清零后发布合法来源覆盖→真实读lease/完整row捕获→quant每row单start、G82连续两half→完整A task覆盖/债务清零READY→Down读lease→K2624/N1024完整输出。K256/1024/2624/4096及原stage/region白名单、全NumericIdentity/三个Context/Ref驻留、GEGLU返回/quant512bit/128bit半q/half1 scale/done/读lease端口、原首错编码及晚错/reset禁止前缀READY均已固定。

容量账明确为Wi/gate完整row31488B、双F32供数row32768B、quant原32group4096B及双A139264B，metadata/返回另计；双A是每slot16个rowbank，每bank128×256bit q和128×16bit scale，当前ACT两槽各8组共544B不具此范围。首个真实片段允许冻结WI输入checkpoint，但GATE/q/scale/PS/Down输出由实际链产生；新一行PASS不扩大为16row或含Wi Q8 producer。vector独占GEGLU完整行及其stream/row adapter，production独占GATE writer/ledger、通用feeder、quant/双A和Down；联合文档仅本次Astra更新，没有额外人工放行门。

**生产函数绑定与持续服务已分开。** [design §7.3.4](design.md#734-生产量化与q8调用粒度完整rowtask和完整group循环)保留当前Group32函数/C模型作为功能连接证据。quant HLS05的latency156/interval157可能使32个同步调用串行收费，不能继承独立row32group141cycle或82group341cycle；新调用粒度固定一次task owner绑定、每row一次start、内部32slot连续供数。Q8则至少一个TN8 tile/1或4row块的全部G组驻留，在真实PS/Q35/端口反馈下推进，不每组重做同步函数绑定。新的生成controller必须实测真实实例数、group接受/返回、尾部/身份/PS停顿，功能PASS或仅min II不登记吞吐改善；当前production TM4也不能使用未来TM16/TN16几何的理论服务代账。

**完整动态地址单bank已实际映射。** 本轮亲核[bank OOC01](../attempts/t4_w_cache_bank_ooc_01/receipt.json)SHA256=`df7ff7093122903a677111f61c2fa1471b9d7ee942e7bb890b1e9283ed354109`，exit0/67.471913s/4199828KiB、无guard触发；12URAM288、6RAMB36＋2RAMB18=7 BRAM tiles（8 RAMB primitives）、blackbox0，完整payload2865408bit。32份同bank条件投影为384URAM＋224 BRAM tiles，尚不含父层控制/metadata/ACT；parent32-DCP装配及新七shape/ACT受影响回归由production按原合同继续，不能由单bank物理PASS声明完整cache/ACT fit。旧双W容量11461632B不缩小。

**Attention实际模块资源和8query功能可限定接受，全服务尚未闭合。** [formal01结果](../attempts/t5_attention_service_rtl_formal_01/numeric_result.json)SHA256=`d6ae6f4d6f7f0d80394a4db06ed9964af1621a7cd7026f82a399538aa961198e`，真实query0..7各完整K128/D64及QK(all8)→SM(all8)→AV(all8)、协议/CE/reset通过；856061cycle、205.234928s、2083400KiB。其QK/SM/AV/load累计分别278562/80824/66384/132309cycle，不能拿总cycle当纯8row算术或直接抹掉任务/初始化成本。本次未将仍在跑的full128登记PASS。

[Attention OOC01](../attempts/t5_attention_service_ooc_01/ooc_result.json)SHA256=`71d81088ceadee7d321562309284974dc25943a6213c732a0edc0b01f8391801`，exit0/247.965558s/5694292KiB、无guard触发、blackbox0；10399LUT/6282FF/22DSP、145RAMB36＋7RAMB18=148.5BRAM tiles（297 BRAM18等效）/0URAM。综合WNS+2.807ns/TNS0、内部unconstrained endpoint0，但132输入/39输出缺IO delay，无P&R/实测Fmax。实际层级K/V各58RAMB36、共116tile，exp_bits为6424LUT/2933FF/16DSP/2RAMB18；运行S128仍支付生产支持的max-S1024容量。简单复制16份完整service单RAM就需2376tile，超过器件2016且未计其它，排除该简单复制提速方案；下一候选须在原shape支持范围内共同评判共享KV/bank、FP池与真实端口，不静默缩小容量。

下一集中性能判断等待当前完整head及生产controller真实结果，继续按原全部工作量收费：Attention480head、LN7824row、全部Q8和向量/量化/搬运。T1现有16row 1433020cycle是实际串行LN基线，尚无32M/16A共享池的actual service PASS；Attention单1M/1A/1D正确服务也不等于高吞吐。单TM4完整图理想接受已46055432cycle，不能用未来更宽阵列的5756936cycle条件值代替。旧tanh Encoder主体62.696107ms及含L375逐row tail的71.809540ms都不是完整模型。最终高性能加速器、连续全图RTL、整网资源/部署频率与板端仍未完成，本次合同收口后Sol按已授权工作继续。


### 完整Attention head与可变时延caller的集中更新（2026-10-11，Astra/xhigh）

**完整单head数值已通过，当前服务率明确不足以代签全图高性能。** 亲核[head128结果](../attempts/t5_attention_service_rtl_head128_01/numeric_result.json)SHA256=`428020bd5a97b8265e0ff98c73d5b659169ac6469c291d08f71fbebee568c52d`及[blackbox交接](../attempts/t5_attention_service_rtl_head128_01/blackbox_handoff.json)。enc0/head0/B1/S128真实query0..127的八个16row allQK→allSM→allAV批通过，16384score/128max/16384exp/128sum/16384prob/8192输出按独立参考核查，原CE/reset/末值拒绝及恢复仍开。guard exit0/1721.066682s/951152KiB、无触发；TB总8380004cycle含定向/负例/重载/读回，不当生产延迟。

原phase累计QK4456856cycle包含24cycle已知拒绝/CE干预；正常QK为4456832，SM1295224、AV1064192，非重叠正常计算命令共6816248cycle/head。条件150MHz下45.441653ms/head、480同服务head为21.8119936s，未含生产caller、搬运/输出及实际频率差异；不是全模型实测。原148.5BRAM tile模块OOC及K/V各58tile保持，16份整service的2376tile已超过器件2016，简单复制方向排除。官方JSON的1/1仍是调度元数据，生产实际唯一实例/调用退休尚须generated caller证据。

**quant generated02是实际调用握手失败，修复不改gold。** [失败收据](../attempts/t2_quant_generated_rtl_02/failure_receipt.json)记录leaf cycle42 issue/80 return，parent按latency128到state145等待时，continue绑1已消费done，512cycle超时；guard child1/35.983317s，无保护触发。已核真实生成FSM及工作leaf：IDLE可接start，ready只在REPORT&&continue出现，所以不能先等ready才启动。当前1/1 metadata修复只前移等待点，尚不写PASS。[design §8.1.2](design.md#812-quanttm4attention共同的可变时延调用与完成登记)已统一quant/TM4/Attention的实际launch、逐字段valid采集、一次done登记、continue/响应槽、输出RAM末写及CE/reset语义；最快/最长/错误分支须在新generated parent实际验证。若工具仍不能安全捕获，按唯一有界cmd/response adapter让实际FIFO响应驱动返回，不猜latency、不插人工延迟/假done。quant的CE目前是caller/返回保持、内部继续推进，与Attention已测全域暂停分别登记；opaque owner echo的合法性仍由实际caller ledger承担。

**下一候选已冻结并可直接实施。** [design §8.3.1](design.md#831-完整head实测后唯一attention候选精确m16a16d4与四个原exp)选一个Attention内部共享M16/A16/D4池：只读复用已冻结完整输入canonical精确mul14/add0/div0，capture14/6/12，实际新lane连接/资源重新验证；4exp保留现正确F64图、每份单call，HLS非pipeline1..103只作成本先验，真实占用收费，不继承旧80cycles/row或F256服务。一个满S1024的共享KV、完整16row score/prob/Q/Y、16个dot槽、8个softmax scratch、固定Q32返回与D预约均已给出容量/bank/调度；主体payload741840B，mask/binding/metadata及exp内部另计。QK相邻树、softmax完整max/exp/sum/直接div和AV逐feature升key均不改，模式间排空；新tile命令18..21在原内部接口扩展，13BO及B2旧支持路径保持。

Attention Sol随后先同head完整4query真实pilot，再同snapshot16row、能落原帽则完整128query；同阶段接受→真实done对照已有baseline，另列供数/输出、资源和停顿。只生成这一池及受影响模块OOC，不复制整service、不新增exp架构、不扩大服务器或整网物理授权。LN的真实16row1433020cycle与Q8当前TM4理想46055432cycle仍是待改善的独立瓶颈；本次不同时扩LN工程，不用未实现TM16/TN16数字替换当前Q8。vector canonical、生产完整双A/feeder/writer及普通修复持续推进，局部通过不结束完整加速器mission。


### 同步PS、完整matrix生产边界与GEGLU行存储的集中更新（2026-10-11，Astra/xhigh）

**ACT父层仍为成本中止，完整cache/PS/算术装配资源UNKNOWN。** 已核[full-cache父OOC01失败收据](../attempts/t2_act_full_cache_assembled_ooc_01/failure_receipt.json)SHA256=`b7efa8f87cf54a65cbf4433d560fff0ffd10d6598acfa83e2bc3e9dd374cc4f4`：child−9、144.346425s、峰值RSS5789944KiB、最低MemAvailable428879792KiB，触发120s无工具语义进展。日志在PS671744bit、progress18368bit、poison20992bit多维数组寄存器展开阶段停止，尚未连接完整cache EDIF；这是父层存储表达的实际成本失败，不是双W容量或数值失败。已得cache384URAM/224BRAM tiles继续照付，不能据此声明父层fit。该ACT/cache/PS累计耗时649.804541s，原3600s内余2950.195459s。

[design §3.8](design.md#38-实际ps展开失败后的同步bank与完整matrix驻留生产控制器)已给出唯一直接实施路线：32个656×32同步PS bank＋4个656×16同步metadata bank，PS83968B、metadata5248B、有效/busy图及两个整stripe entry另计；E0合法header与读请求、E1返回复制、E2最早原子算术launch。Q35/D4在读前预扣、发射时转换实体预约，实际PS/meta commit C后同址下一读最早C+1；g0 lazy初始化、G128进度、poison skip、commit写口仲裁及reset generation均已固定。主生产顺序group外tile内，tag.sequence=`g*T+tile`，保留final adapter末组检查。完整matrix/1或4row view只发一次命令，调用实际上移原n0循环；真实服务持有全G/T调度与A/W/PS/bias/writer，父rows>4按原tile/parent_row/lane/group/phase合并首错。该合同不是新同步RTL或生产集成PASS；实现、受影响RTL、实际完整Down和同生产入口generated caller由production连续推进。

**完整GEGLU row数值和51个FP位置OOC已限定通过，但31488B行数据实际RAM0。** [G51收据](../attempts/geglu_canonical_row_01/receipt.json)SHA256=`e7281e13670ceadcd619be41cb858c5a1ca21764e903c7954180fd8a7c942d71`的状态为`LOCAL_ROW_RTL_AND_51_FP_OOC_PASS_PRODUCTION_BRIDGE_PENDING`；六完整row共31488 WI words、15744 GATE输出及157440个独立逐步比较，134755cycles，包含压力、G先于U、来源屏障、owner/旧ref拒绝、晚错有序排空、load/inflight/pending reset和输出保持。实际core commit506cycle、峰值506/512 credits；正常单row first issue62515、last commit65644、first output65645、last output68268，因此issue→末commit3129cycle、issue→末输出5753cycle，仍须另收费5248字捕获与物理writer。其本地row_write_ack为诊断确认，不能单独代替真实AW/W/B。

G51完整装配176828LUT/299253FF/48DSP、SRL9416、BRAM/URAM/LUTRAM0、blackbox0/IO0；51位置为25add/24mul/2div，算术子树95754LUT/42834FF/48DSP，row/metadata/control另81074LUT/256419FF。综合WNS+0.538ns仅属未布局布线结果。canonical tanh已包含在G51内，资源不可再重复相加；单列helper路线与G51累计预算也不能合并转移。[design §8.4.10](design.md#8410-g51完整row实际ram0后的同容量三bank修复)限定vector只将U/G/gate改成三个2624×32同步独立bank，保留tanh E384/E385、实际core506、全行成功屏障与真实writer债务；算术图和完整fixture不改。该G51路线已耗923.575406s，余2676.424594s支付bank、新父层及复用51子核的完整装配；新RAM实际类型/数量与新资源尚未取得，不预报fit。六完整row与真实桥的受影响范围必须在新身份回归。

**真实G→GATE写回→量化→完整双A的一行桥已通过。** [bridge RTL01收据](../attempts/t2_geglu_gate_quant_bridge_rtl_01/receipt.json)SHA256=`d38ebd70eedd36171c61e23ff7456f284eac6ede7a88738f86b5bda84e29ab79`，guard exit0、39.908101s、RSS1325344KiB、无保护触发。真实路径从外部冻结完整Wi checkpoint的5248字，经canonical GEGLU产生2624字，实际GATE writer/ledger完成164个AXI写beat与最后B，成功发布后取得完整identity读lease，feeder再实际读164beat，由一次row command完成82个quant group并填完整物理dual-A，再acquire/逐组核全部82个同步读/release。原日志`GEGLU_GATE_QUANT_BRIDGE_PASS`记录no_preloaded_gate_q_ps=1、owner_reject_zero_issue=1、final_B_publication=1、source_read_debt=1、held_b=2951、quant_cycles=954、cycles=20980。实际owner拒绝、源读债务及AW/W/B反压均已覆盖。

此桥尚未包含上游Wi Q8 producer及下游驻留Down，只有初始reset，活跃全链reset、晚数值/来源/AXI错误恢复及完整域CE仍未由该收据证明；后续production正在扩充必要范围，不能把本行成功外推16row或完整13BO图。G51旧收据中的bridge pending是当时本地结论，后来的bridge01只关闭上述实际一行范围，原收据不改写。

当前依赖次序是先完成同步PS/真实驻留Down、原13BO生产调用粒度及GEGLU三bank修复，并取得正在实现的Attention M16/A16/D4＋4exp实际服务/资源；随后以同一物理账选择LN确定调度作为已知慢项的下一集中合同。LN现有16row1433020cycle、全请求7824row；Q8当前TM4理想46055432cycle在150MHz已为307.036213ms，且未含PS/供数/输出。更宽Q8几何须依据新PS反馈/credit、真实TM4资源与Attention/cache/G51占用后再选，不能先用TM16/TN16条件数字冲销现账。两份合同已直接交付实现角色，普通编译/修复/回归无额外用户或逐步审核门；完整加速器、同runtime整图RTL、整体物理闭合和上板仍未完成。


### 阶段封存前的生产接口、首错与存储停点（2026-10-11，Astra/xhigh）

**最新用户要求改为当前阶段结束后完整复制工程并交新对话继续。** 本轮仅闭合已着手合同和实际证据，原工程保留；复制至`Workspace/Laya/Laya-HLS`及research-agent登记由Root负责。本节后续生产壳与G分层OOC均为交接方案，当前NOT_RUN，不为完整加速器目标继续延长本阶段，不新开LN、更宽Q8或整图工程。正在执行的模块验证由原owner封存其真实终态，不能把本节描述当运行或通过。

| 当前范围 | 集中结论 | 剩余边界 |
| --- | --- | --- |
| 同步PS bank及E0/E1/E2前端pilot | PASS_SCOPED；32PS＋4metadata全656地址、47232读核查、两entry/Q35守恒、256个四row合成stripe、ACT四row完整8group、reject/压力/active reset通过 | 非真实Wi/Down/fullcache链；G128仅metadata进度128存储，all-poison仲裁/read-reject mutation未覆盖；持续II1未证 |
| 完整matrix resident源 | 实际STATIC_PASS，50.629490s/2340204KiB/exit0 | 外cache端点及local producer ledger仅编译/elaboration，数值、实际cache/上游owner和13BO功能NOT_RUN |
| GEGLU三同步bank＋六完整row | 实际RTL PASS；完整容量、157440逐步核查、原算术hash/core506/tanh384/385不变 | local writer ack仍诊断；production受影响物理桥由原owner另封存，不能继承旧身份PASS |
| G新父OOC | COST_STOP_SEMANTIC_STALL；exact arithmetic export PASS | 新parent DCP、RAM primitive实账、完整装配/新时序均NOT_CLOSED；不是功能FAIL或内存帽耗尽 |
| matrix生产门户、Attention延迟Q首错 | 可执行合同已直接交owner | matrix绑定/生产壳NOT_RUN；Attention当前受影响新模块验证以owner后继冻结receipt为准，本节不预写PASS |

已亲核[同步PS pilot收据](../attempts/t2_tm4_sync_ps_pilot_01/receipt.json)SHA256=`1207672e5d54d011fae433b93d747cd7cc46ab07d446e816d07c5e2f3a3397a2`，RTL exit0/23.510522s/RSS1375392KiB、无保护触发；真实ACT `F_PS_min=37`，大T接受gap1..3，front2、Q35=35。这些是已测反馈与间隔，不能用最小gap1宣称持续II1。原精确signed-dot/scale1为该pilot参考，非完整真实模型矩阵。[matrix static收据](../attempts/t2_tm4_matrix_resident_static_01/receipt.json)SHA256=`0c8b3ca0558d47c830d9a9efc55f67197b758f3e46405ac2ba939cfb4740e8b5`仅证明nativeFP resident、syncPS/finalPS/native8bias/两个writer编译闭包，功能范围没有扩大。

**生产绑定缺口已找到实际工具依据并选择一条可实现接口。** 现C/JSON仅验证scalar Group32输入/输出、chain/CE，生产仍n0循环；工具没有在该接口中凭空绑定fullA/cache/AXI。本轮只读核Vitis2025.2安装的RTL-blackbox界面源，确认正式hls::stream FIFO字段及固定RAM接口；没有假称已试验m_axi JSON失败。[design §3.9](design.md#39-真实matrix生产接入显式hls命令流与原13bo外层)固定两个显式C命令/完成FIFO、一次完整view阻塞命令、单份持久物理fullA/cache/PS/writer和保持原13BO/AXI-Lite布局的RTL外层，真实AXI owner/debt切换及RRESP/BRESP/末B返回。新接口可直接HLS生成，不依赖未知JSON存储机制；同时必须改同生产调用闭包/上游LOAD和quant，而非仅附加standalone TB。常规HLS burst API的void write_response不提供原始错误返回，因此没有用它缩小现故障域。工具源支持不等于本项目generated RTL或外壳已通过。

**Attention全tile Q捕获曾改变原首错，现已定义保留方法。** 原逐row是先64个Q finite，再该row完整QK；旧新接口cmd18即时返回row_local×64+d会让晚row坏Q抢早row算术overflow。仅对result取%64不能修正顺序，还会破坏数学阶段原key×64+d/树/scale索引。[design §8.3.2](design.md#832-全tile捕获q时保留原逐row数值首错)规定cmd18记录待决坏Q但完成合法捕获，cmd19先真实处理所有较早row并排空，较早算术错优先，否则报原d；坏row及以后不发新QK，整task不发布。owner已接受并完成live RTL/C及六个竞争定向准备，旧cmd3诊断保持。新受影响数值/CE/reset终态仍须实际receipt，不由静态实现签PASS。Attention为全域CE闭包派生的本地`attention_tile_ce_`helper与原canonical字节不同，旧DCP不可直接复用；实际新资源必须重新计费，不能修改GEGLU冻结子核或把其通过扩大到Attention。

**新G功能通过，父层物理闭合仍未取得。** 亲核[row_bank_v1终态收据](../attempts/geglu_canonical_row_01/row_bank_v1/receipt_terminal_01.json)SHA256=`88529ff76bc4df5cbe1831aa82447ef3ec7311a8100bcc94de2d6915bfc3254e`。三bank各2624字，15744写、23616读、7872非同址并发和214保持检查；六完整row31488 WI字/15744 GATE字/157440逐步核查通过，RTL exit0/98.359854s/RSS846596KiB。同步边沿、17个operand暂停周期、generation reset保持；normal first issue62533、last commit65662、first output65663、last output68286，issue→末输出仍5753cycle，没有增加行服务尾延迟。算术164port bits/51FP位置实际精确导出为95754LUT/42834FF/48DSP、blackbox0，只属于旧不变算术子树。

新父在Cross Boundary and Area Optimization连续120.090394s无语义进展，guard child−9/164.187886s/峰值3793524KiB、最低MemAvailable404980300KiB。中途RTL“3×2624×32 RAM”尚不是RAM primitive；最终parent DCP/资源/完整装配/时序未产生。原G累计1261.775981s，余2338.224019s，取代上一节历史余2676.424594s。[design §8.4.11](design.md#8411-三bank父ooc再次成本中止后的单bank加四stub闭合)留下单bank一次DCP→父四stub→exact算术＋三bank完整EDIF装配这一条有界路线，RTL/容量/edge不变，同一余帽/锁/120s保护；当前NOT_RUN。若仍同停点则物理UNKNOWN收口，不原样加帽或另试数值架构。联合资源尚未齐全，因此本阶段不扩LN或Q8阵列；完整加速器、全图RTL/物理闭合及板端仍未完成。


### 复制前本阶段最终集中结论（2026-10-11，Astra/xhigh）

**当前模块实际终态已全部取得，本阶段按用户最新要求结束并交Root复制。** 本次只审核新增收据及其明确范围，未重跑旧验证、未重审未变源码或全量引用，未新开OOC/LN/宽Q8/13BO工程。以下更新覆盖上一节同项目的等待状态；历史失败/中止和各冻结身份保持。

| 最终范围 | 判定 | 不可扩大的边界 |
| --- | --- | --- |
| Attention v10完整head128正常数值 | PASS；单进程query0..127，正常604317cycles，较旧6816248改善11.279259倍 | 原head0/B1/S128；不是全图速度、实际频率、生产BO写出或其它shape/B2通过 |
| 同v10 tile16_03首错/CE/reset | PASS；六类Q与算术错误竞争及M/A/D/EXP真实在途暂停/复位、重载 | 完整head进程PROTOCOL=0，协议证据明确复用同hash tile16；不扩大为全13BO reset |
| Attention v10模块OOC01 | NOT_COMPLETE / COST_STOP_SEMANTIC_STALL | 无最终资源/DCP/blackbox/timing，未证明fit；没有原样重跑 |
| 新三bank GEGLU→GATE→quant/fullA四distinct row | PASS_SCOPED | 不含上游Wi Q8或下游Down；晚错/active-chain reset/two-A重叠未验证 |
| resident full_down_01四distinct row、完整K2624/N1024 | PASS_SCOPED；全PS/输出/512次末B债务、本地owner退休及A/W release | A为预量化fixture，bias_kind0；非同runtime G→Down，不是生产13BO入口 |
| G三bank新父物理闭合、matrix生产门户/外层、整图 | G父保留COST_STOP；其余NOT_RUN/未完成 | 无新整网综合/P&R、板端或完整高性能加速器结论 |

**Attention：实际性能与协议范围可限定接受。** [head128_01结果](../attempts/t5_attention_tile_v1_01/head128_01/numeric_result.json)SHA256=`31c8c3698617ae1511cad614a6c1d39822185232d5e5e7d18b43864a9a718652`和[tile16_03结果](../attempts/t5_attention_tile_v1_01/tile16_03/numeric_result.json)SHA256=`08b3c58711b41cb3056ea9033eb31040bc740a5f71988a740490667c0a0d3e63`均绑定source_manifest_v10 SHA256=`34145bda45ba482150a8be37876288771e01b3952bbb5de6ba892340d5f8b0b2`。head guard exit0/471.004332s/RSS1108700KiB，TB总1608896cycle含加载/读回等；正常命令QK250888、SM287173、AV66256，和为604317。其计数包含每命令接受edge，剔除人为CE/拒绝/reset工作；同口径旧6816248除以新值为11.279259倍。条件150MHz为4.02878ms/head，480head为1.9338144s，未含生产搬运/末B/其它算子，不是全模型实测或50ms达标。

tile16 guard exit0/182.683258s/RSS954704KiB；正常31361/35896/8282共75539cycle。六类首错实际bad_element依次323/63/63/7/63/4095，证明晚row坏Q不再抢早rowoverflow，末row/d63及key63/d63的原编码保留；真实M/A/D/EXP在途CE/reset、reset抢占CE、旧epoch拒绝/合法重载、chain保持/ledger及pending-Q暂停/取消通过。head自身未再跑这些协议例，明确以同v10 tile16支持。完整head EXP实测gap分布为1×7168、78×128、89×1、97×9087，共16384次；不能沿用早pilot只有1/78/97的表述。反馈定向自然填满M Q32，A/D满队列尚未证明。184304个F32字/737216B只是纯RAM payload，全部父控制/queue/metadata及实际RAM碎片另计。

[Attention OOC01](../attempts/t5_attention_tile_v1_01/ooc_01/ooc_result.json)SHA256=`5b359c0289f0a2bd1b5ec9cab1ba2ff2622da5ee0931ec922d8ce53834b8c1de`，child−9/244.410645s/RSS11295456KiB、最低MemAvailable410445816KiB，最后配置语义进展后120.015934s触发保护。无最终utilization、DCP、blackbox数量或timing；该停止不证明工具内部死锁、物理不fit或数值失败。CE闭包已是Attention本地不同字节实现，不能用原canonical/旧scalar资源填未知值。原3600s阶段帽本次已耗244.410645s，余3355.589355s只作交接账，不构成立刻重试授权；现阶段不另选或启动综合路线。

**新G桥：三bank改动的四个不同真实行受影响回归已关闭。** [bridge RTL04](../attempts/t2_geglu_gate_quant_bridge_rtl_04/receipt.json)SHA256=`f4b7e2729f3f74bf69629f5f8c77fb4a0d0782bee5587cb37bbbfe8d89e751cb`，exit0/94.854549s/RSS1328936KiB、无保护触发；四个原enc0 WI行20992字，经实际三bank canonical G得到10496字，656 AW/W/B及末B后再实际656 R、四次完整row quant/328group、dualA全部328次完整identity held reads及release通过。输出/gate和quant d/reciprocal/q/saved-half均对原独立gold，无预载GATE/q/PS，59975 TBcycle、held_B11807、quant_cycles2714。outer owner零issue拒绝、来源读债务、AW/W反压及最终B发布实际覆盖；仅初始reset，晚source/numerical/AXI故障、active-chain reset和two-A overlap仍未测。G父OOC的成本中止未被本次功能PASS改变。

**resident Down：完整输出及退休已由实际链闭合。** [pilot03](../attempts/t2_tm4_matrix_resident_pilot_03/receipt.json)SHA256=`8d173068071ef0eb56a4f2dc9ad99c5563ccf8e2f5ff497b03220f0bbe4e59ed`先在288个stripe/1024个row PS packet前缀主动停止，仍只保留pilot范围；后续[full_down_01](../attempts/t2_tm4_matrix_resident_full_down_01/receipt.json)SHA256=`f0d8d0682f97c28852143c8f4fb2c809cbc85f5778ae916f792bf40779cfe791`实际exit0/421.880748s/RSS1424044KiB、无保护触发。四不同真实enc0 Down行K2624/N1024，预量化A经正常fullA端口656half/328scale commit；strict W LOAD经三个读口20992＋20992＋2624=44608 R beat，并核83968scale。完整82 A group held reads、10496 group-major W stripe、41984 row PS/335872有效lane-group逐项原gold、512 final packet及4096原F32输出全部通过；512真实AW/W/B及held_B9217后全部债务清零，实际A/W lease释放、本地PS/dst ledger一次READY发布。TB共48862cycle，不能当不含装载/反压的生产服务时间。该resident测试核PS/输出gold；dot/dotf/product/term逐步证明仍明确引用独立sync_real_down_01，未冒称本TB也采集。

Down采用bias_kind0，真实bias输出模块走旁路；native8非零bias FADD没有发射，相关数值/首错/reset quarantine继续NOT_RUN。四row按tile交错，每512bit写beat只使能8个F32，物理32768B/有效16384B，不宣称全宽packing吞吐或持续II1。测试只有初始reset及正常A/W/held-return、AW/W背压/延迟B；resident active reset/CE/晚数值或source/AXI故障恢复、16row多view首错、双A/双W重叠仍未覆盖。该A来自预量化fixture，与bridge04是独立运行；二者不能拼成同runtime GEGLU→Down或13BO生产集成PASS。matrix门户/真实BO仲裁仍依design §3.9作为新工程待实现合同。

**集中结论与复制前写入边界。** 已测局部数值/协议与真实存储/输出链按上述范围接受；Attention及G的物理成本停点继续阻止联合资源/频率闭合，生成生产调用与整图链仍未完成。当前不扩后继设计或执行，保留design §3.9、§8.3.2、§8.4.11及全部冻结证据给新工程。两实现owner已报告当前工具终态/锁释放并封存各自记录；Root在所有owner最终写入结束后执行完整副本、SHA核对及原生research-agent搭建，原工程不删除、不搬移。本集中记录写入完成后本角色亦结束写入，不再修改原工程。
