# TM1/TN8/GS32、512-bit Q8联合原型

## 2026-10-14 FFN3 直接xsim接点定位

AT059冻结DUT/TB/guard/数据不变，FFN3仅将已编译snapshot的launcher运行依赖按脚本/ELF分类并在隔离目录直接启动。AT062 full暴露冻结TB的共享BO描述符接线冲突：Wi reader的region固定DDR_BASE+4096，但其`cfg_bo_base/span`接共享`cfg_bo_base[0]/cfg_bo_span[0]`，G接入前这组值被重绑STATE1供后续Down；reader合法性要求region≥BO base，于是Wi reader cfg被拒。后继应把Wi DDR与Down STATE1描述符分别接入，并核完整身份/边界；FFN3无DUT/TB修复授权。证据见[E005 FFN3报告](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/reports/FFN3_typed_runtime_semantic_failure_20261014.md)。

## 2026-10-14 FFN1 被动进展封装

AT057功能DUT、生成RTL、模型/数值输入及正常响应策略保持原SHA；本轮仅在联合TB从LN来源、两次Q、W q0/q1/scale三端口、矩阵、G及末残差实际握手/算术退休累计35分项，严格schema守卫只接受每分项不回退的真实增加。LN生成游标的阻塞赋值在negedge取差、下一posedge入账，避免同边沿仿真次序竞态。被动目的接线断言核适配器固定HIDDEN Ref与残差wrapper实际cfg端口；独立短TB覆盖适配器退休门控和当前wrapper真实目的描述符拒绝。代码与运行闭包见[E005 FFN1报告](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/reports/FFN1_bounded_prefix_preparation_stop_20261014.md)。本轮真实联合前缀未启动xsim，不能将静态接线或短测扩为同runtime结果。

## 2026-10-11 实际生产调用连接（源码已接入，新增构建/CSim/HLS/RTL待验证）

`activation_quantizer_compute.cpp`在原合法任务/已发布F32源检查和唯一A claim之后，实际调用`laya_quant_blackbox_smoke → laya_quant_group_service`，显式传入672bit NumericIdentity、96bit TaskContext与两个64bit Ref（含region），每次核完整896bit echo。目标A在完整rows×K/32覆盖且全部调用退休以前保持FILL；任何失败令A INVALID，不能发布已成功group前缀。服务SV实际使用quant16_stream_row；普通CPU编译仅其C模型，`LAYA_EXTERNAL_RTL_MODELS`的Vitis配置由JSON `c_files`唯一提供模型并连接SV。新增调用尚没有PASS结论。 首个生产连接按Group32阻塞调用，量化服务每次cfg_groups=1、TM4每次等待全部Q35/D4退休；这建立真实调用正确性基线，尚未保持既有流式group连续服务或跨tile在途重叠，不宣称吞吐改善。

`q8_linear_compute.cpp`与`full_tasks.cpp`的正常trace-off生产调用改为`q8_linear_owned_window_arithmetic → laya_tm4_blackbox_smoke → laya_tm4_group_service`。完整1024bit owner包括NumericIdentity、TaskContext与A/W/PS/dst四Ref，逐调用核全echo/返回status/bad_mask/phase；同group四row原子输入，PS在controller中按group升序保持，数值坏lane poison及原最低bad_element优先规则保持，final bias独立F32操作。原trace-enabled隔离诊断继续原trace算术API；它不是新的RTL trace服务证据。full controller的W/A只读lease、PS完整覆盖、write retirement和目标发布逻辑仍为生产语义边界。

全部真实unique K/N形状为256/2、1024/3072、1024/1024、1024/5248、2624/1024、1024/4096、4096/1024。当前TM4 working RTL whitelist已补Wo/Decision FC1/FC2；G总数、next_group和progress为u8可表示128（4×656项progress当前逻辑20992bit，相对旧u7增2624bit；物理映射仍待测），外部group index/tag仍u7表示0..127。ACT06证据与待OOC仅使用原27输入冻结闭包，不将本次working RTL改动追写为旧RTL06通过。

新增真实blackbox CSim/HLS/RTL入口在同模块`tb/quant_blackbox_*`、`tb/tm4_blackbox_*`，实际官方JSON及SV在`source/blackbox/`；其资源/latency/II元数据仅HLS调度注释，实际面积/周期仍须报告。当前新接口与七shape的生成实例/握手证据待取得；不得由C等价循环和独立RTL叶子PASS拼成生产RTL PASS。


## 2026-10-11 当前生产交接实现

权威规格为[当前mission](../../../../../mission/compute_throughput_optimization.md)、[联合设计§0.2/§3.5/§9](../../../../../results/compute_throughput_optimization_20261010/source/design.md)。当前新增 `rtl/laya_act_production_v1.sv` 将真实F32 ACT输入、quant16、默认完整容量双W cache、TM4、bias与AXI512 writer连成一个实际时钟链，保持完整3328bit模型身份、672bitNumericIdentity、96bitTaskContext及64bit显式BufferRef。TM4内部96bit路由key仅定位已持有完整owner的算术返回，不代替请求身份校验。

源F32必须已经完整发布并有完整覆盖；量化目标先FILLING，16个q半组、8个scale及全部实际FP返回退休后才READY。Q8取得A/W只读lease后消费，完整PS/final bias及实际输出最后B后才释放并done。晚列失败可退休并写入FILLING存储的先前有效前缀，但不得据此前缀发布A或启动消费者。GEGLU接入同样先保留目标F32无效，整行成功和实际输出/写债务零后发布源，再执行量化与Down读取；reset/晚错误均取消旧owner。

当前ACT wrapper只接受K256/N2/rows1合法context，完整模型还有7种K/N及10种family组合；通用化必须使用8bit group总数/进度以表示G128，7bit group索引仍覆盖0..127，Wi T656使用10bit tile。仅C四row循环不证明32lane物理并行。后续HLS RTL blackbox使用真实C模型/JSON/SV握手并检查生成实例，现有13-BO ABI及生产owner、lease、首次错误和物理完成规则保留。

状态：实现中；本文件登记当前实现映射，不另定义接口或数值合同。2026-10-10核对以下来源。

| 权威来源 | 本原型采用的位置 |
| --- | --- |
| [本阶段执行合同](../../../../../results/cpu_embedding_q8_validation_20261010/contract/design.md) | §6“Task2固定原型边界”、§6.1–§6.3.1的数值/接口/退休规则及§6.6–§6.8的Q35、整tile pack/TX和同权连续RUN：原型形状、状态、缓存、输出、性能与测试要求 |
| [现行Q8模块设计](../../source/design.md) | “命令、端口与状态”“算术、bank与流水落实”：WeightKey/BO布局、128-word描述符除新magic外的字段、生产数值与会话规则 |
| [阶段计划](../../../../../mission/next_stage_plan.md) | “Task2”：TM1/TN8/GS32、实际signed乘法、恢复/PS和512-bit联合路径的目标与证据边界 |
| [本轮算力合同](../../../../../results/compute_throughput_optimization_20261010/source/design.md) | §3.1–§3.5：原接口/六级延迟、独立LUT树与signed packing候选、精确范围及真实数据边界 |

目标：只支持ACT K256/N2/rows1，以及Encoder layer0 QKV K1024/N3072/rows1或4。完整LOAD_W、输入加载/两遍量化、按row→g→tile发射、八lane整数树、逐group FP恢复及PS、bias、512-bit外部写入与B响应退休均由同一原型完成。缓存只覆盖合同§6.1的最大需求；首版外部fixture准入固定request3/generation1/B1/S128、新包四tag及ACT/QKV独立来源ref/注册epoch1/row切片，具体边界按合同§6.0。这里的epoch1是隔离fixture注册版本，并非读取生产owner后的epoch验证。错误时先排空已接受工作，按生产rank选首错，不发布不完整对象。

本原型[ABI头](q8_tm1tn8_abi.h)保留现行128-word字段和观察布局，descriptor magic改为合同规定的`0x31543851`（Q8T1）；后续解析必须先检查原始窄字段再转换。首个自维护RTL叶为[八lane整数树](../rtl/tm1tn8_integer_tree.sv)：每个请求含同一32项A8及8列各32项W8，按六个真实寄存边界完成256个signed乘法和每lane相邻归约；tag、oldPS逐拍随数据传递。这只证明局部dot结构，不代表恢复/PS/访存路径、DSP映射、全路径II或原型完成。旧C1树仅提供六级边界与符号扩展参考，不接入其顶层或旧测试脚本。

当前活动HLS前端为[joint DMA](q8_tm1tn8_joint_dma.cpp)：它沿生产BO布局串行LOAD q0/q1/scale/bias，缓存至合同大小的W bank，加载activation并两遍量化A8；量化成功后发送真实A/W/scale group请求及bias tile，不计算dot、oldPS或最终输出。旧[顺序计算候选](q8_tm1tn8_engine.cpp)保留作诊断，不能用于联合原型结果。HLS前端及配置由[联合配置生成器](../tb/make_hls_config.py)的`--joint`模式构建；[联合CSim](../tb/tm1tn8_joint_csim.cpp)检查真实量化与group/scale/bias stream，物理B由RTL范围检查。

trace-off时descriptor `flags=0`且trace row/column字段为0：HLS仍在内部生成A8 q/half并把q及half转F32 scale放入每个group packet，供相同算术链使用；它不向observed BO的q/half区域写调试副本，group的选中trace位也为0。完成header的trace row/column取0，trace bias/final字段在本前端未赋非零值，trace group count来自RTL完成反馈且无选中group时为0。[一/四行QKV性能TB](../tb/tm1tn8_joint_dma_qkv_perf_body.svh)与[ACT性能TB](../tb/tm1tn8_joint_dma_act_perf_body.svh)在实际group握手比较独立q/F32 scale，在trace-off时检查header words58–63、observed q/half/trace区sentinel及物理trace AW/W/B为0；其它有效lane数值、满宽scatter或ACT 8B输出和首次done零债务检查继续执行。

性能TB的命令计时以wrapper `command_start && command_ready`的下一个posedge为接受点，并在驱动任务等待到首次wrapper `command_done`脉冲时取完成点、同点检查HLS/bridge/各物理AXI适配器零债务。该间隔包含AXI-Lite参数配置、HLS启动/轮询和输出排空；它不是HLS内部`ap_start→ap_done`。相邻完成间隔与wrapper控制空档仅用于本固定fixture、同进程重复RUN的服务观测，不外推跨请求吞吐。

时钟算术路径为[Q35/D4预留及顺序提交](../rtl/tm1tn8_reserved_store.sv)→[六级整数树](../rtl/tm1tn8_integer_tree.sv)→[八lane FP恢复](../rtl/tm1tn8_fp_restore.sv)→[PS控制器](../rtl/tm1tn8_ps_controller.sv)→[bias输出](../rtl/tm1tn8_bias_output.sv)。Q35的slot为6bit、合法0..34，发射/提交指针显式34→0；tag使用`{tag[63],tag[4:0]}`编码slot，私有顺序号位为`[62:36]`。返回先检查slot边界再索引35项结果/metadata；FP FADD顺序FIFO仍为32项，只把元素slot扩为6bit。Q35不增加算术级数或同tile旁路，D4仍按完整160bit tag及第八真实trace B退休。PS旧值只来自当前实际PS bank：同tile从issue占用到commit写入后的c+2才可再发，不用oracle回填。bias_kind=1只对未坏有效lane发单独F32加法，并收齐各lane返回；数值首错由PS/bias按生产tile/row/lane/g顺序比较。FP IP使用真实时钟及低有效复位；本次生成配置的sitofp、fmul、fadd分别为6、6、11拍，元数据移位与实际结果valid对齐。IP输出直接驱动256bit总线切片，避免仅连接局部wire而使总线悬空。旧Q32身份的ACT/QKV真实BO数值通过不能外推到Q35；新身份的回归结果见结果记录。

PS 的 `compute_done` 只表示组运算已完成，不表示最后 tile 已穿过 bias 并进入物理 writer。[bias 输出](../rtl/tm1tn8_bias_output.sv)提供仅供桥内使用的 `drain_empty = !tile_tvalid && !add_busy && !pending`：三项分别对应等待 bias 接受的 PS tile、尚在 bias 加法中的 tile、尚未被 writer 握手接受的输出 packet。[联合桥](../rtl/tm1tn8_joint_bridge.sv)先锁存 PS 完成，再仅于 `flush_pending && drain_empty` 向[writer 桥](../rtl/tm1tn8_writer_bridge.sv)发 finish；只有该 finish 真正握手才清除待冲刷状态。writer 此后拒收新 tile 并冲刷 pack，待两路实际 AW/W/B 债务及 pack 清零、observed trace 也退休后才给出首个完成条件。该顺序防止 QKV 末尾半满 pack 在最后 32B tile 到达前被提前冲刷。

输出使用[双路512-bit writer桥](../rtl/tm1tn8_writer_bridge.sv)做生产scatter和WSTRB。每口[物理writer](../rtl/tm1tn8_axi512_writer.sv)在一个更新事件并行合并已接受tile同一64B beat的全部有效lane；4B对齐基址跨beat时保留剩余lane，下拍合并第二beat。单个填充pack与独立TX寄存器分开；TX地址/data/strb保持到真实B，AW与W各自握手，TX等待B期间pack可继续填充，同拍B退休/pack转TX/尾片合并不清除新数据。首版一笔AWLEN0、64B对齐、不跨4KiB；flush完成等待暂存tile、pack和TX全空。错误B阻止成功完成，但已接受事务仍经真实B排债。writer在`flush_done`后保持本次请求已报告状态，直到`flush_req`下降；因此桥接下一命令不会被旧flush重新锁住。选中group的256bit trace由[独立32-bit AXI writer](../rtl/tm1tn8_trace_axi32_writer.sv)逐字写入同一observed BO的word17664+8g区域。第八个真实B后才携完整160bit owner tag、slot和OK结果向D4存储终结；错误B计故障、不算成功group。joint完成等待PS、双输出writer、trace与D4债务排空，再由HLS写observed header。writer桥的`all_writer_debt_zero`表示两个物理输出writer已无债务且不在drain，即使完成信号有效也必须保持为真，供首次完成断言检查。[HLS控制器](../rtl/tm1tn8_hls_control.sv)在start锁存并校验单一observed base/span，把同一64bit base写入HLS指针参数（包括高32位），初始化trace writer后才启动HLS；[联合wrapper生成器](../tb/make_joint_dma_wrapper.py)从实际生成端口与AXI-Lite寄存器偏移绑定，并将HLS参数化端口位宽解析成wrapper自身的固定位宽，拒绝缺少64bit半字或非512bit读口。wrapper对七个HLS AXI master各自按AR至末R、AW至B追踪债务，新命令及top done均要求这些债务与三路RTL writer债务为零；生成RTL进入独立运行目录。

[真实GGUF/冻结输入参考生成器](../tb/make_real_fixtures.py)和[逐组向量生成器](../tb/make_arithmetic_vectors.py)提供独立参考；[ACT桥接测试](../tb/tm1tn8_joint_act_tb.sv)、[QKV一/四行桥接测试](../tb/tm1tn8_joint_qkv_tb.sv)使用实际PS commit、FP及物理AXI响应。[整体OOC入口](../tb/synth_joint_ooc.tcl)纳入生成HLS、control、算术、PS、bias及三路writer并检查blackbox。joint DMA CSim、HLS生成、完整ACT与一/四行QKV真实BO路径及旧RTL无黑盒整体OOC已有实测；当前RTL修复后未重测整体OOC/时序，原6.667ns时序仍FAIL。桥接TB从已量化packet驱动，只证明局部算术链；真实BO覆盖以完整joint DMA测试为准。对应动态状态见[结果记录](results.md)和[阶段结果表](../../../../../results/cpu_embedding_q8_validation_20261010/stage_results.md)。

## T2 独立整数映射候选（2026-10-10）

本轮候选不接入上述joint DMA顶层。[LUT树](../rtl/tm1tn8_integer_tree_lut.sv)保留基线8×32个独立signed8乘法及product寄存器的`use_dsp=yes`意图，将五层相邻加法寄存数组标记`use_dsp=no`，意在LUT/carry归约。[packed树](../rtl/tm1tn8_integer_tree_packed.sv)只替换product形成方式，原五层树不同时改变；每个k的列(0,1)、(2,3)、(4,5)、(6,7)分别共用一个A。两个候选均保留原160bit tag、256bit oldPS、八个signed21结果、`req_ready=rst_n`和product/16/8/4/2/1六个寄存边界，不解释tag内的group/tile位。

[pair primitive](../rtl/tm1tn8_signed_pack_pair.sv)显式形成signed27 `X=(signed(w1)<<17)+signed(w0)`、signed18 `Y=signed(a)`和signed45 `P=X*Y`；取`signed16(P[15:0])`为p0，p1取`(P>>>17)+(p0<0)`的signed16低位。X先符号扩展再移位相加；P保持45bit，不以int32中间值截断。`use_dsp=yes`是映射意图，乘法是否落在单个DSP及修正逻辑的LUT/FF/布线成本只能由后续结构报告确认。候选B的独立验证不依赖候选A。

第三个[组合树](../rtl/tm1tn8_integer_tree_pack_lut.sv)把已验证的shared-A signed packing product与五层`use_dsp=no`相邻加法树合在同一六级接口。它不改变tag、oldPS、dot返回、`req_ready=rst_n`及复位清valid的合同。[组合短/真实整数TB](../tb/tm1tn8_integer_combined_tb.sv)与[ACT R0 TB](../tb/tm1tn8_arithmetic_real_pack_lut_tb.sv)分别用独立int64 dot和原ACT数值gold核对；实际结果见[results.md](results.md)。组合后的乘法DSP数量、LUT代价和物理时序仍待映射，不能把A/B各自的潜在资源收益直接相加。

[穷举CPU检查](../tb/verify_signed_pack.py)对所有256³ signed8三元组比较独立`a*w0/a*w1`；[lockstep TB](../tb/tm1tn8_integer_candidates_tb.sv)与[真实group TB](../tb/tm1tn8_integer_real_replay_tb.sv)均同时实例化旧基线、候选A/B并以独立signed dot核对，后者还核实际fixture有效lane的dot。短整数结果只覆盖树、tag、oldPS和reset/II1接口，不涵盖原R0的INT→F32、两FMUL、PS FADD、HBM、动态量化或整矩阵服务。

Wi/Down已取得§3.6要求的当前输入及独立gold，实际证据见[结果](results.md)。[producer观测准备器](../tb/prepare_widown_capture.py)在独立编译副本的Encoder layer0 QKV RoPE提交后、`LN_FFN`/`GEGLU`完成后增加只读V plane2/head0及MLP输入checkpoint，并保留原v4持久CPU/CSim的47点比较；原controller和原TB不改。[四行fixture生成器](../tb/make_widown_v4_fixtures.py)仅接受request3/generation1/B1/S128当前producer BO，逐项绑定v4 manifest/实际GGUF/BO权重，再用`tests/full_reference.py`独立重算完整Wi K1024/N5248和Down K2624/N1024的四行group与输出。V捕获仅为后续AV外部oracle输入，不证明AV硬件。当前TM1 joint DMA仅有6bit group、9bit tile且硬限K≤1024/N≤3072；Wi需656 tiles、Down需82 groups，不能借旧接口声称全K/N通过。

按已发布的[TM4合同§3.5–§3.6](../../../../../results/compute_throughput_optimization_20261010/source/design.md)准备独立微基准：在[192bit标签编码](../rtl/tm4tn8_tag_v1.sv)中保持旧160bit字段位置，bit160/161分别补group[6]/tile[9]，bit[167:164]=版本1；[标签TB](../tb/tm4tn8_tag_v1_tb.sv)覆盖G63/64/81及T511/512/655边界。[TM4行算术](../rtl/tm4tn8_row_pipeline_v1.sv)各自复用六级整数树与既有FP IP数值顺序，具有独立的[Q35/D4](../rtl/tm4tn8_reserved_store_v1.sv)和[192bit FP恢复](../rtl/tm4tn8_fp_restore_v1.sv)；[四行stripe/PS微基准](../rtl/tm4tn8_microbench_v1.sv)按四行原子接受、共享W、四份A/SA与32lane PS编址准备。逐stripe `issue_identity[95:0]`核对配置身份高96bits、`issue_version[3:0]`核1、`issue_sequence[26:0]`核下一期望值；拒绝事件不预约算术，非法tile先拒绝再访问PS/progress/poison数组。标签、候选A/B独立ACT R0短测、TM4 LUT合成pilot及ACT/QKV/Wi/Down四个真实矩阵微基准已通过，证据在[结果](results.md)；packed TM4及资源/时序仍未验证。

PS逻辑容量按4×8×656×32bit=671744bit=83968B规划，但当前RTL为`always_comb`异步读加时钟写的32个逻辑bank。PS及poison数据不做整片reset/config清零；group0以progress有效性固定从+0开始，commit重建有效lane的PS/poison，group>0只在前一group的实际commit后读取。因此复位后旧数据留在数组中不等于新任务可见。progress 18368bit、pending 2624bit、poison 20992bit及其清零/多写控制另计；每行reserved store还各有656项busy和35项result owner/tag、4项trace owner/tag，FP恢复另有每行35项meta_tag/mask/phase/trace共67200bit及32项slot FIFO共768bit。这些与Q35/D4返回payload、FP移位寄存/输出寄存都不能计入83968B PS数据容量。实际可能映射为LUTRAM/FF与读mux，**BRAM/URAM实现、复制/端口开销及Q35/D4总资源均UNKNOWN**，短功能仿真不作为物理存储结论。

同tile反馈按真实握手计：PS commit边沿c清pending/busy并写PS，但reserved store的`just_valid/prior_valid`继续挡住c+1、c+2两个issue观察拍，最早c+3才可能接受同tile新group；其它credit、trace或row阻塞还可延后。ACT只有T1，必须用实际accept/commit周期统计其服务率，不能把“commit后下一拍必发”代入吞吐预算。本轮不为推定RAM类型而改变PS读延迟或现有保护拍数。

[真实流转换器](../tb/make_tm4_real_streams.py)仅把已核SHA的独立ACT/QKV及当前B1 Wi/Down fixture改写为每stripe A/SA/W/SW和dot、dotf、scale product、term、PS、所选trace十条mem流；不从DUT生成gold。[完整矩阵TB](../tb/tm4tn8_real_matrix_tb.sv)和[受控入口](../tb/run_tm4_real_attempt.sh)按group外层、tile内层发四行原子stripe，逐row/lane核每个中间值与commit PS、身份/顺序、Q35/D4守恒和终态，ACT仅一行且尾mask为2。ACT LUT真实回放七次commit→下一同tile issue均为3拍；QKV四行全矩阵也通过，12288个stripe连续接受无issue stall。QKV pilot的已编译snapshot由[独立guard复用入口](../tb/run_tm4_compiled_replay.sh)在新attempt拷贝并校验源/流身份，以免仅改变shape/输入仍反复编译。Wi/Down仍需各自全矩阵结果，输入流准备本身不作为RTL PASS。

## T3 Q8S2 v2 会话 DMA 局部映射（2026-10-11）

联合合同以[§4.1–4.5](../../../../../results/compute_throughput_optimization_20261010/source/design.md)为准。新前端[HLS 源](q8_tm1tn8_session_dma_v2.cpp)使用固定256字 descriptor、18个实际 binding 拍及独立 descriptor/q0/q1/scale/AUX/activation/observed AXI 口，按 REGISTER→LOAD→RUN→REVOKE 管理会话与模型缓存。STRICT 对 LOAD 的全部 padded scale 逐项检查；VALIDATED_STATIC_MODEL_V1 依赖已验证静态包，绕过这一重复扫描，其余 ACT 动态量化、bias 与输出数值路径相同。[时钟控制器](../rtl/tm1tn8_hls_control_v2.sv)从真实外部 BO base/size/cookie 锁存 binding，生成 wrapper 的指针寄存器与会话流共用该快照，首次 done 等待 HLS、算术桥、输出/trace writer 与 AXI 读写债务归零。

[真实 ACT 输入生成器](../tb/make_session_dma_act_inputs_v2.py)从冻结 r2 包及独立 GGUF fixture 提取 q0 2048B、scale 128B、AUX header 128B、bias 8B、activation 1024B；[wrapper 生成器](../tb/make_session_dma_wrapper_v2.py)与[RTL TB 生成器](../tb/make_session_dma_act_tb_v2.py)将同一 HLS RTL 接入真实 XSim AXI 端点。TB 每次 LOAD 后的 RUN 从缓存发射流核对全部 q 字节、64个 scale 值和2个 bias 值，再核独立量化、R0/FP/PS、全部有效 F32 输出、物理 trace/output B 与 observed sentinel。负例实际更改控制器输入的 BO base/cookie，避免只改 descriptor 自述字段。有限末 R/B hold 和首次 done 零债务共同约束完成边界；具体 PASS/FAIL 身份及测量范围见[结果](results.md)。

增量 TB 对拒绝逐项比较 first-error owner、session reject/state、last task、W state/epoch/max/load计数、generation high-water与W绑定身份。descriptor-only错误恢复原descriptor后直接合法LOAD，实际base/cookie变化恢复输入后仍拒绝旧slot。坏AUX REGISTER只读128B header，保持generation高水位并要求更大generation重建；STRICT的padded-scale与两profile的bias数值LOAD失败消费task/W max，清live W epoch并撤销slot，同代REGISTER拒绝后以generation2注册及重新LOAD恢复。FAST不注入坏scale。动态activation坏值读完整1024B后归quant task失败，保留ACTIVE/W READY和W epoch，仅消费A8 epoch；随后quant task3/run task4完成独立数值、observed sentinel与物理输出检查。reset后的首拒绝使用空设备状态作对照，不把清空BO的sentinel当作先前回执。

专用`CLOSURE_ONLY`短分支从真实REGISTER/LOAD形成W READY后分别改变wrapper的q0 BO base与cookie，核session/W立即失效、恢复指针仍拒绝旧RUN/LOAD与同代REGISTER；每次均以generation2 REGISTER/LOAD/RUN重新建立并核完整ACT数值。另在W READY整域reset后拒绝旧LOAD，再用generation2完成同样重建。此分支不重跑前述23/21项增量套件；FAST复用STRICT已编译XSim snapshot，入口先逐SHA比对生成TB及输入身份。具体日志和失败尝试见[结果](results.md)。

### Synchronous PS and resident complete matrix integration (2026-10-11, joint §3.8)

New `tm4tn8_sync_bank_v2`/`tm4tn8_sync_ps_front_v2` use 32 depth656×32 PS and 4 depth656×16 metadata 1R1W synchronous banks with no payload/q reset. Two finite complete stripe entries carry generation/full tag/old PS/poison; E0 reserves logical Q35/D4 credits and RAM read, E1 copies q, E2 earliest transfers preclaim to physical row slot. Full192-bit tag snapshot validates commit and writes PS/progress/poison on the same physical retirement edge; all-poison skip arbitrates metadata with real commit. Old async microbench_v1 is preserved. Pilot/realDown scope and measured stalls are in results.

`tm4tn8_matrix_resident_v2` and local `tm4tn8_matrix_owner_ledger_v2` are new uncompiled candidates. Controller owns complete G×T group-major iteration, full A/W lease+sync returned identity, resident one-group A reuse, finalPS copy/native bias/two actual AXI512 writers/finalB before owner retirement. Parent identity and row_block_base remain explicit. The local producer ledger only owns PS/dst FILL/INVALID/view coverage; it cannot sign or replace the full persistent 13BO runtime ledger. Production `full_tasks.cpp` n0 boundary is unchanged while Astra defines the feasible actual binding.

Actual current binding is scalar `laya_tm4_group_service.{h,cpp,sv,json}` through `laya_tm4_blackbox_smoke.cpp`, generated HLS02 enclosing `.../attempts/t2_tm4_blackbox_hls_02/work/hls/hls/syn/verilog/laya_tm4_blackbox_smoke.v`. Scalar chain/valid and lower-bound scheduling1/1 are supported; arbitrary JSON m_axi/FIFO or variable-latency RAM mapping has not been probed. The actual SV `sequence` reserved pin failure was repaired to RTL `issue_sequence`, C parameter unchanged. No unbound extra RTL port may be claimed as a BO connection.

Minimum resident endpoint binding: fullA acquire/read/held-return/release with NumericIdentity672, Context96, Ref64 and slot epoch; Wcache lease/read/held-return/release with model3328/numeric672/context96; strict W LOAD has three AXI512 read channels for q0/q1/scale and aux AXI128 read for header/bias; output has two independent AXI512 AW/W/B channels. Original `hls/platform/full_kernel_wrapper.cpp` retains all13 uint8_t BO pointers (embedding/io/w_q0/w_q1/w_scale/aux/state0/state1/qkv0/qkv1/ff0/ff1/att_out), max_widen512/outstanding1; actual generated bundle widths, finite request/response backpressure and physical lastB must be measured. A bounded FIFO/HLS DATAFLOW memory service is being evaluated centrally; C write-return is not a lastB proof.

### Stage-close resident physical-cache bounded test implementation

`tb/tm4tn8_matrix_resident_tb_v2.sv` instantiates the actual v2 resident controller, local PS/dst owner ledger, physical complete dualA and default full dualW cache/strict three-stream AXI loader plus AUX header endpoint. Four original distinct prequantized Down A fixture rows enter only through the actual complete-A fill/half/group/row/finish ports. This is a declared fixture supply boundary: G-to-quant is covered separately and is not inside this TB. Cache q0/q1/scale hex is byte-identical to the immutable original binary Down matrix. Actual A and W held-return data, all PS group commits and final enabled output words compare to independent frozen original gold. Output endpoint separately stalls AW/W and delays each actual B, tracks physical word coverage and rejects owner retirement/publication before all accepted transactions retire. The local ledger does not represent the full runtime 13BO ledger. A <=120s pilot initially targets 256 actual stripes/1024 row-PS packets after real full W LOAD; full Down/output/final-B scope is admitted only if measured pilot cost supports existing formal caps.


### E003/R003 production portal implementation (2026-10-11)

Authority: current copied-project M003/SM003 and joint design §3.9. This resumes implementation in E002/experiment; historical stage-close receipts remain immutable. The fixed private packet is explicitly LE serialized by `include/laya_compute_portal.h` and `hls/platform/compute_portal_codec.cpp`, with matching `rtl/laya_compute_portal_layout_v1.sv`. Command16×512 and response8×512, two depth2 FIFOs plus one command/response assembly slot retain the prescribed1792B payload capacity. Packet identity/context/ref echo, reserved zeros and generation rejection are checked before admission/publication.

`laya_compute_portal_v1` holds one complete command through the physical service lifetime and complete response consumption. Stale completions are consumed separately; cancellation clears only private transport after physical retirement, and never drives physical service reset. `laya_matrix_portal_binding_v1` is generated from actual resident ports, instantiates one real resident and one producer ledger, validates role/BO span/region/u65 sums/alignment, and exposes native A/W lease/read/return and AXI writer endpoints. It remains to be connected to the shared physical service hub and original13BO arbitration.

Resident cancellation inhibits new work, retains accepted acquire/lease transactions until genuine completion, and drains accepted A/W reads, native FP and final writer work before release/owner retirement. `w_pending_reads` explicitly counts accepted W reads before ret_valid exists and removes genuine returns or accepted-read rejection callbacks. This prevents transitioning out of DRAIN while a delayed accepted cache return is still outstanding. Cold rst_n is separate from cancel; active reset/new epoch must use cancellation/quarantine rather than erasing physical debts.

Actual historical generated top/control/control_r RTL from `vivado/project/build/20261008T022231Z-2961016/stage/rtl_verilog` establishes two AXI-Lite interfaces: control32/addr4 and pointer control_r32/addr8, plus13 actual32-bit AXI data masters with64-bit addresses. Pointer low offsets are10/1c/28/34/40/4c/58/64/70/7c/88/94/a0 hex; high words+4. `freeze_13bo_abi.py` extracts actual declarations and outputs a hashed ABI reference and `laya_13bo_abi_v1.sv`; a future current generated controller must be compared against this reference. `laya_13bo_base_mirror_v1` passively follows actual pointer AW/W handshakes with WSTRB and freezes all13 bases at actual request acceptance. At a concurrent pointer write/accept edge it captures the same pre-write value as the generated controller. The request-accept signal must be bound to the verified generated FSM transition, not inferred from ap_idle alone.

Current L1 remains incomplete: no generated production caller FIFO connection, physical LOAD/quant/G hub, actual13BO arbitration/width conversion or same-runtime Wi→Down proof yet. Diagnostic test endpoints never authorize a production/whole-model completion claim.


The native-service width conversion uses actual AMD `axi_dwidth_converter`2.1 sources, created by `rtl/create_laya_axi_dwidth.tcl` with AXI4,64-bit address,SI128/512,MI derived from generated BO width (historical reference32),SI_ID_WIDTH0,FIFO_MODE0,synchronous clock. No OOC is launched. Conversion reset is cold fabric reset only; active cancel must preserve accepted upstream and downstream transactions. Joint resource accounting must include each converter's actual finite buffers and control; no resource/Fmax result is available yet. An owner grant must cover the complete upstream transaction and downstream sub-beat debt, including offered requests and held converter responses, until safe service retirement.

A contract mapping gap remains for non-matrix service commands: the current explicit packet has one Context and five Ref fields, while actual quant/G binding requires separate producer/quant/future-linear Contexts and GATE/future output references. These values cannot be guessed from task_id increments or hidden in reserved bytes. Their explicit shared C/SV versioned mapping and authoritative task reservation need a concentrated interface definition before enabling those production operations. Current matrix/LOAD address and native-AXI work continues independently; no diagnostic completion substitutes for missing production operations.

### E003/R003 actual converters, native BO wrapper and LOAD cancellation (2026-10-11)

The current binding adds `rtl/laya_load_portal_binding_v1.sv`, generated by `tb/make_load_portal_binding.py`, around one default full-capacity physical `t4_dual_w_cache_v1`. Command admission checks actual latched q0/q1/scale roles2/3/4 and AUX5, unsigned65-bit BO/range/address additions, alignment, shape, model/numeric tags, W ref/slot/epoch and bias size. Entire BO span overflow is rejected before cache claims or reads. The actual cache/reader completion determines the response; C READY echo is never used. The command remains held by the enclosing portal. The LOAD binding exposes the existing lease/read/release endpoints for the single shared cache; the eventual service hub must serialize LOAD and matrix ownership.

The existing readers and cache now have LOAD-only cancel inputs. Accepted bursts and previously offered AR survive cancellation; all actual LAST returns and FIFO commits drain before load_done. No active-cancel reset clears AXI debt or epoch high-water. Cancel also invalidates the latest completed READY slot while its response is pending. The binding masks completion for the first cancellation edge, so simultaneous completion READY cannot consume an old success before cache invalidation and the error status are registered. This cancellation sideband supersedes a pending service response; stable response backpressure is checked after cancellation settles. Cancellation at a completed service is therefore not an ordinary AXI-stream transfer guarantee. Complete first-error/AXI-origin precedence remains pending L3 validation; the current generic cache error mapping does not certify that contract.

`rtl/laya_axi_13bo_owner_v1.sv` preserves all45 named native AXI fields from the actual historical generated13BO declaration (ID/USER1, LOCK2, address64/data32, WID, REGION and QOS included). All26 owner/BO transactions are separately checked. `rtl/laya_load_axi_native_v1.sv`, generated by `tb/make_load_axi_native.py`, connects existing LOAD q0/q1/scale AXI512 and AUX AXI128 through four actual AMD converters to the corresponding native service owners. Original controller owner0 fields remain available on all13BO; unused service read/write fields are explicitly zero. The adapter is read-only for LOAD and assumes the existing readers' one accepted SI read per BO. Native service AR requires the real arbiter grant. Ownership remains desired while there is an accepted SI read, offered SI/MI AR or held SI/MI R; physical_debt_zero includes both SI and MI state, not just the narrow arbiter ledger. Adapter validation in `tb/laya_load_native_tb_v1.sv` passed as load_native_02 with manual native32 memory peers. Actual FIFO_MODE0 final read is cut-through: holding SI final R also holds the true MI LAST, and both debts survive cancellation. All cycles with accepted SI debt, including native split-burst gaps, check that service ownership stays selected. The original controller-side native read is separately exercised after cancellation/recovery; current generated caller integration remains pending.

This is implementation under the existing native endpoint/13BO contract. Current generated caller connection, the combined LOAD/quant/G/matrix persistent hub, quant/G future identities and full model behavior remain incomplete. No new resource, frequency, OOC, P&R or board claim follows from these simulations. Converter finite buffers/control remain included-but-unmeasured resource entries.


LOAD native admission additionally accounts all selected native offered AR/AW/W and visible R/B, not only accepted arbiter debts. This prevents claiming physical_debt_zero while an old controller request is still offered under backpressure. The actual owner arbiter still preserves selected-owner offers until real acceptance and drainage before switching. `load_native_03` tests an old controller AR held15cycles alongside a pending LOAD, then real AR/R retirement and successful cache fill. Inactive owners' unaccepted queued offers do not count as the currently selected physical transaction. Native AW/W admission cases are not newly exercised by this read-only adapter test.

## 2026-10-11 v2及门户代号实施进展

权威为D-M003-QUANT-G-V2与D-M003-PORTAL-GENERATION-01。当前quant/G合同SHA256为5b23da9216c588aea04b10314fbd733e938c98c3d6674f8ac6c9e66e5b3c3123；生命周期补充SHA256为6c3017999c056fd6ba8e6e7566381f4bc790765c8d1e4adf3bbd27c44e62bc5e。234f0f…是修订前历史身份，不能代表当前合同。

C/SV显式VERSION=2，cmd1024B/rsp512B及13BO不变；P/Q/L与future-dst扩展、LOAD/非使用字段零约束及service/view回显同步。transport真实首拍握手校验固定64B可信头，只有可信fresh g可在失败响应/安全cancel封闭时推进H_closed；软cancel和session切换不清高水位，跨view空闲仍传播cancel。

TaskReservation与PortalReservation分离typed预约和持久H_alloc。Controller预约最大128窗口的385个typed task与769个门户command，G分期保持全部G→LOAD→Q/L；未发送g不回收，typed未激活预约可重建。此处仅控制预约与syntax验证，实际full_run_task仍是旧C路径，generic source provenance和真实portal caller/hub未完成。

新增laya_parent_a_lease_v2，5336bit归一化实体key，1011bit acquire/865bit release handle。实际fullA一次父acquire，后view局部grant，中间不真实release；末view或安全cancel真实release。当前独立真实fullA测试通过，尚未接matrix服务、父首错/TaskDone及全tensor目标账本。
## 2026-10-11 rows16父任务、W pin与tensor覆盖

`laya_matrix_portal_binding_v1`现以`laya_parent_a_lease_v2`和`laya_parent_w_lease_v2`包住实际resident的局部acquire/release。第一个合法rows4 view取得完整rows16的真实A/W物理租约；中间view只获得匹配完整NumericIdentity、P/Q/L、Ref/region、shape和slot epoch的局部grant，局部release不清物理cache；最后view或安全跨view取消在读/FP/AXI债务为零后各只物理release一次。每条view保留自己的portal generation，父实体与origin generation不被后继g覆盖。

`tm4tn8_matrix_owner_ledger_v2`保留父PS/dst状态，并为六类目标、双bank保存最多2048行的tensor checked/covered位图。同dst epoch可依次接纳多个父L；只有完整B×S覆盖才发布tensor，任何父失败对tensor保持sticky INVALID。父层保存跨view状态与最小u64 rank；数值失败继续后续必要view，协议/AXI失败则安全排空终止。binding在真实owner-retire握手锁存`view_published`，避免writer清除局部coverage后响应误报未发布。每view响应仍只描述本view范围；`ledger_parent_complete`只在全部view/末B/租约结束后脉冲一次。

当前生产binding仍使用受控cache端点，尚未连接统一13BO hub、真实quant producer provenance或generated caller。受控rank注入只验证父层最小rank归并，不代签实际数值错误生成。

## 2026-10-12 generated producer provenance 基础生产闭包

按D-M003-GENERATED-PROVENANCE-CHANNEL-01，生产Controller内部现有四条私有`ap_fifo<ap_uint<512>>`：原`compute_cmd/rsp`及Host不可见的`provenance_cmd/rsp`，深度均为2；外部13BO、控制寄存器及四个compute service的wire v2不变。LPV1请求仍为16拍/1024B，LPA1响应为8拍/512B。`generated_provenance_codec.cpp`、`generated_provenance_client.cpp`、`generated_provenance_hls.cpp`、`generated_provenance_events.cpp`和`generated_provenance_ledger.cpp`已进入生产源码闭包；`full_forward_controller.cpp`在BEGIN成功响应后才执行对应typed producer，并在END响应后只退休一次原typed task。

固定32-owner ledger按完整NumericIdentity、L13M、owner/Ref/epoch及最多两个descriptor保存CLAIM/BEGIN/END/PUBLISH/RELEASE/INVALIDATE状态。event sequence与每身份typed task high-water持久递增；坏END保留活动scope，失败END只封闭一次并使owner无效，QKV pair先原子预检再提交。同一真实task对象产生BEGIN并驱动算子；store helper在实际`full_write`提交入口累计真实入队字节，END携该计量，不能用期望字节数代替。

生产RTL registry现显式列出L13M、compute portal layout、LPV1/LPA1 layout、private FIFO、provenance transport、持久hub及portal wrapper，受控RTL入口从该registry核闭包。当前RTL hub的`physical_observation_*`仍由测试台驱动；尚未接实际generated AXI AW/W/B interposer，因而没有逐WSTRB字节唯一覆盖、重复/越界/W-before-AW、真实BRESP/RRESP首错、rejected-store debt或posted-write adapter fence结论。普通QUANT的来源发布与读lease也尚未由该持久hub直接驱动。下一实现入口是把真实写观测和内部待发债务接入同一hub，再以查询/lease替换普通QUANT的受控`q_ordinary_source_published`边界。

## 2026-10-12 generated provenance错误终态与首个真实store monitor

主控审核F1/F2/F3已在当前生产闭包修复。Controller只有在END响应完整匹配且`DRAINED=1/SCOPE_ACTIVE=0`时才清generated store tracker并退休原typed task；合法的scope-active错误响应保留tracker、issued bytes与typed计数，继续等待取消/fence收束。CPU ledger与持久RTL hub在`physical_drained=0`时均保留END及首次物理错误，后续真实排空观察到达后才产生终态响应。32个typed身份槽只在较新request的合法CLAIM且旧scope、owner、lease和队列全部排空时回收；event/owner高水位保持，旧请求迟到仍拒绝。

新增`laya_generated_store_monitor_v1`与`laya_generated_provenance_axi_portal_v1`，把一个普通contiguous rows16、role6、单descriptor的generated AXI512写口直接接持久hub。BEGIN从真实候选包核role/geometry并在写前准入；BEGIN请求和响应之间由`begin_reserved/begin_block`阻止匿名写穿越。monitor可独立锁存AW/W并容纳W-before-AW，单拍事务只有在地址、AXI属性、WSTRB范围与未覆盖字节全部合法后才向下游发出。越界、重复或不支持的事务在转发前本地拒绝，实际WSTRB字节仍计入失败排空账。

当前边界不转发burst；非法多拍burst会保留首拍AW/W，按AWLEN完整吸收余下W拍后才返回本地DECERR。`local_drain_active`期间禁止重复分类同一首拍事务，避免重复拒绝、重复计字节或重装drain计数。成功END同时依赖唯一覆盖、真实末B退休以及外部`adapter_pending_zero`；后者是显式生产接线点，当前受控TB的8拍延迟只验证门控语义，尚未证明generated HLS adapter内部待发事务与该信号的真实因果。

该monitor和AXI portal已进入`config/full_module_registry.json`的generated provenance RTL闭包。当前只支持role6、一个descriptor和连续rows16，尚未覆盖多role/QKV、宽度转换、production top真实master、普通QUANT source lease或完整数值链。
## 2026-10-12 generated provenance活动取消与fence修订

在上一版monitor基础上，所有hub/transport拒绝响应现显式携带真实`DRAINED`。错origin END及PUBLISH/RELEASE/INVALIDATE若物理未排空，保持原scope/owner和pending physical状态；pending期间每个已接受observation参与首错sticky，最终真实fence才生成一次终态。cancel只禁止新producer；已有活动scope的匹配END仍可进入，monitor继续接受旧绑定的已入队AW/W并等待真实末B和`adapter_pending_zero`，避免通过清scope或阻断END造成死锁。

`adapter_pending_zero`仍是production接线点，当前动态证据来自TB控制的posted-store/fence序列。后续必须从generated HLS master真实store提交入口及适配器待发/held状态产生该因果；固定延迟或Controller布尔不可替代。普通QUANT还需以persistent hub的完整身份source query及原子读lease替换`q_ordinary_source_published`。

## 2026-10-12 普通source逐窗口P、整tensor发布和原子读lease

依据`results/ordinary_linear_provenance_contract_20261012.md`与`results/generated_provenance_channel_contract_20261012.md`，`laya_generated_provenance_hub_v1`现为受支持的B/S普通F32 owner保存最多128个rows16窗口的覆盖位与真实成功producer Context。每个成功END只闭合对应窗口；PUBLISH逐窗口核完整覆盖，不能由单个窗口或最后task提前发布整tensor。owner仍以完整NumericIdentity、L13M、归一化Ref/region与descriptor绑定，失败使owner保持不可消费。

新增Host不可见的source query/release sideband贯穿hub、portal与AXI portal。query核command frame、QUANT service、完整模型和身份、P/Q/L、source及A/W/PS/dst/future-dst Ref、role、K、rows、source offset/span/stride、row/batch stride和该窗口保存的P；同一owner只允许一个活动source lease，portal generation必须大于该owner上次成功query。release必须逐字段匹配已冻结的query，并等待consumer真实读债`source_release_drained`。活动lease禁止owner RELEASE/INVALIDATE；软cancel保留旧绑定直到安全排空。

`laya_gate_quant_portal_binding_v1`已删除普通Q的`q_ordinary_source_published`布尔准入。普通命令先完成decode和source query，grant后锁存整条command为lease绑定，再驱动共享`geglu_gate_quant_split_v2`中的唯一quant/fullA实例；普通源的AXI读地址来自锁存的source role/region/stride。服务终态在实际读债清零后请求release，并保持lease跨服务response反压直至response退休。GATE专用owner/lease路径保持独立，普通Q不借GATE READY状态。

当前实现与运行只闭合role6、B1/S64、stage2/K1024的连续普通owner和窗口0消费。producer写的物理观察仍来自受控TB，`adapter_pending_zero`尚未连接真实generated HLS adapter；多role/QKV、跨batch、其它K/row-space及普通/GATE无复位切换仍待实现或回归。

## 2026-10-12 标准窗口、adapter fence与来源切换实现

`laya_generated_provenance_hub_v1`的单全宽producer窗口关闭条件现为`context_rows == min(16, owner_end-row0)`。一次成功END不再代表整个标准窗口；非尾rows1及其它短贡献保持窗口未闭合，只有标准窗口实际全部行完成才保存P Context并允许后续整tensor发布检查。该规则不改变LPV1/LPA1字节布局、typed任务数或发布op。

`laya_generated_provenance_axi_portal_v1`把END的`issued_store_bytes`与monitor实际接收的有效WSTRB字节共同作为终态条件。END早于首个AW/W时保持旧scope、binding和债务；实际AW/W/B与adapter fence完成后才给终态应答。取消仍允许旧scope的匹配写和END收束，同时阻止新BEGIN。

共享`laya_gate_quant_portal_binding_v1`的来源切换bench保持一个`geglu_gate_quant_split_v2`、一个quant实例和一个dual-A实例。真实G命令完成后不复位，partial GATE owner继续resident；后继普通Q由source query grant取得独立lease，`q_gate_source=0`，共享AXI读口按命令锁存的物理SOURCE_ROLE和逻辑source Ref访问普通F32 BO。当前实现已覆盖stage6/row-space2/K256及B2 batch1 row48的stage2/row-space0/K1024 rows16；A使用与G预约不同的slot/bank身份，物理epoch仍按该slot的真实下一epoch递增。

production Controller HLS入口已递归冻结include并检查四条512bit depth2 ap_fifo的12根生成信号与八个可写m_axi bundle。当前完整单体Compile/Link规模为13,223,459 instructions，产物增长停止后连续120s无进展；重复inline/noinline提示不改变规模或停滞点。临时pragma已撤回。下一结构方向须保持13BO、四FIFO、portal wire v2、typed任务与数值合同，再决定是否将caller/shell和service模块拆成独立生成边界。
## 2026-10-12 row-space1 MARKER 来源切换与生产分区边界

当前共享 QUANT/full-A 实例新增受控无复位切换入口：一条真实 GEGLU/GATE 行完成后，在同一运行中读取 B2/S128、batch1 的 stage5 `MARKER` 普通来源。物理来源为 `STATE1`（role7），逻辑对象为 `HEAD_WORK` ref10/region0，`K=1024`、`rows=16`。地址从 `0x311010000` 开始；该入口用于核对 row-space1、batch、role、Ref/region 与共享实例切换，不改变原普通来源、GATE 专用来源或 owner/lease 合同。

该入口的 source-query grant 仍由 TB 驱动，不能作为唯一持久 hub 已完成全身份准入的证据。生产实现继续按 [D-M003-PRODUCTION-HLS-PARTITION-01](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/production_hls_partition_contract_20261012.md) 分层：Controller caller 保留完整任务图、BEGIN/END 和唯一 typed 退休；实际非门户 producer 独立生成并以真实 master/store 计量接 monitor/hub；LOAD、QUANT、MATRIX、GEGLU 仍使用现四项持久 service。外部 13BO/control ABI、四条 512-bit/depth2 私有 FIFO 和原数值合同不变。

## 2026-10-12 Controller 内部 sequencer/adapter 实现

按同一合同 §7，当前生产 Controller 职责域进一步拆为 `laya_typed_q8_forward_graph_sequencer` 与 `laya_command_provenance_adapter`。sequencer 保留完整 graph PC、层/shape/task/view 展开、NumericIdentity、预约与高水位、BEGIN/END/owner 事件以及唯一 typed 退休，只持有 `transaction_request` 和 `transaction_completion` 两条 512-bit FIFO（共6根生成信号）。adapter 持有 compute/provenance/producer 三对既有协议 FIFO（共18根信号），每次只执行一笔 normalized COMPUTE、PROVENANCE 或 PRODUCER 事务，不选择下一任务或拥有物理发布权威。

内部 schema 为固定 little-endian LTX1/LTC1：请求1536B/24拍，完成1024B/16拍，单 inflight。`graph_sequencer_sources.cmake`冻结20个图控制源并排除三套外部协议 codec 和三套 HLS exchange；sequencer completion 使用内部完整 binding 比较。任何语法或 binding 拒绝在 normalized decode 后清空整份 completion，避免失败路径残留可信标志或绑定字段；合法未排空 provenance 错误仍保留为匹配的非终态结果。cancel 时 sequencer 停止新任务，但匹配 END/RELEASE/INVALIDATE 继续带 `CANCEL_CLEANUP` 收束旧 scope。LayerNorm 当前展开为 BEGIN→PRODUCER→END 三笔事务；producer 在 BEGIN 后因 cancel 被 adapter 本地拒绝时，sequencer 构造零提交失败 TaskDone，并继续发送匹配 END 关闭旧 scope。

当前仅取得主机闭包和事务语义证据。真实 HLS RTL、depth2 并发反压、LayerNorm master/store 提交到 monitor/hub 的物理因果、末B/adapter fence、完整请求及资源/性能仍待验证。

## 2026-10-12 Controller 本地拒绝租约收束与 completion 安全解码

主控审核提出的 F6/F7 已按既定 LTX1/LTC1 和 producer provenance 合同在主机实现中修复。`decode(CompletionPacket, Completion&)` 现在进入函数即把输出复位为默认对象，再检查 magic、version、beat 数、kind、status、unit、flags 和保留字段；因此调用者复用旧的可信 completion 时，任一坏头都不会残留 flags、binding、seq 或 Context。合法、完整绑定的非 OK 且未排空 completion 仍保留其状态，供 sequencer 继续收束活动 scope；`LOCAL_REJECT` 必须携非 OK status。

LayerNorm producer 在 BEGIN 已成功而 producer transaction 返回完整绑定的 `LOCAL_REJECT` 时，统一调用 `accept_layernorm_local_reject`：只有确认外部 producer 请求尚未发出、`issued_store_bytes=0` 且没有既存 tracker 首错，才释放已取得的 source read lease、使 destination 保持 INVALID/未发布，并构造零提交失败 TaskDone。source tracker 标志仅在 `full_release_read_owner` 实际成功后清除，避免漏释放或重复释放。

旧 BEGIN scope 不因本地拒绝直接消失。sequencer 对身份匹配但 `!drained || scope_active` 的 END 使用相同 END 身份串行重试；错绑定或坏返回保留 tracker 并退出。仅在完整绑定、`drained` 且 `!scope_active` 的安全终态后清 generated-store tracker并执行唯一 typed retirement。新增有界生命周期入口实际运行 Controller 与单帧 adapter：BEGIN 成功、cancel 导致 producer 本地拒绝、首个 END 非终态、第二个同身份 END 终态，然后在同一 `FullRuntime` 以更高 request/generation 恢复。

该实现不改变外部13BO/control ABI、内部 LTX1/LTC1 大小、typed任务定义或数值合同。当前证据仍为 C++ 主机组合；没有生成修复后 RTL，也没有证明真实 depth2 并发、AXI master/store helper、adapter fence、完整请求或联合资源/性能。

## 2026-10-12 Controller END 重试可信性与 adapter 编译闭包缩减

F8 按既定 LTX1/LTC1 合同修复。sequencer 每次发送 END 都为本轮事务单独取得 `completion_flags`，并在读取 `end_response` 前同时要求 `FRAME_COMPLETE` 与 `BINDING_OK`，且拒绝 `LOCAL_REJECT`。坏帧、错绑定或缺少可信标志会立即返回并保留原 generated-store tracker、issued bytes 与活动 BEGIN scope；它们不能复用上一轮合法非终态 END 的 response，也不会发送第三次 END 或退休 typed task。仅本轮完整绑定的远端 END 才能按 `drained`/`scope_active` 决定继续 fence 或进入原安全终态。

有界负例在各自独立的静态 `FullRuntime` 上执行同一真实 Controller 分支：合法同身份非终态 END 后分别注入坏 header 或错 binding，检查事务在第二次返回处终止、source readers 保持已经完成零提交收束后的0、destination 不发布、tracker/scope 保留且 typed 计数不动。原同身份非终态→终态与同 session 更高身份恢复继续由同一入口覆盖。此前把两个大型 runtime 放在测试栈上的 `_03` 以 `-11` 失败，作为测试实现错误保留；DUT语义不因改用静态测试对象改变。

adapter 的 normalized request 解码不再为 COMPUTE、PROVENANCE、PRODUCER 各执行一次完整外部 wire encode→decode 往返。三套已有 codec 公开其原语义检查为 `command_fields_valid` / `request_fields_valid`，内部 LTX1 decoder 直接调用这些检查；外部 framing、magic/version、保留字段和 wire decode 合同保持原实现。该改动只缩减 HLS 编译闭包，不改变请求字段、协议状态、任务或数值行为。



## 2026-10-12 LayerNorm generated master 与持久 provenance portal

依据 [生产分区合同](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/production_hls_partition_contract_20261012.md)及 [provenance 双向通道合同](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/generated_provenance_channel_contract_20261012.md)，新增 `laya_layernorm_producer_portal_shell_v1`。它直接实例化 `layernorm_producer_hls_01` 的实际生成 engine、五个原浮点 IP，以及现有唯一 monitor/hub portal；本入口仅连接 STATE0 上 HIDDEN→NORM 的 gamma0 LN_ATTN、D1024。

shell 在冷初始化时通过生成 engine 的 AXI-Lite 0x10/0x14 与 0x1c/0x20 锁存相同实际 BO base；运行中基址变化进入协议错误。producer 首拍只有在完整成功 BEGIN 响应的八拍全部消费后才能进入 engine，origin 与 BEGIN event_seq 相等。source AR/R 按实际接受的 burst/beat 计债，destination AW/W/WSTRB/B 全经过持久 monitor，禁止匿名或不在绑定范围的写。首次 producer 请求后 `job_active` 保持至八拍真实 completion 完整交付，且 source 债务、引脚 held 请求和 completion 输出均为空，才允许 `adapter_pending_zero`。END 还需 monitor 的完整唯一字节覆盖与真实末 B。

当前模型包输入为实际所选 `build/model-current-production-v2-20261011/laya_model_layout_generated.h`。运行器要求该头与生成 engine 当时冻结的头逐字节相同，并要求 SV canonical 包等于既有生成器对该头的输出；旧 SV 包的不同 build tag 不再混接。每个生成 ROM DAT 从冻结目录复制到实际 xsim 工作目录，启动前逐个核 SHA；冻结源码、脚本、DAT 和原 generation receipt 均保留。

当前自检入口使用真实 checkpoint 的前16行及独立 Python binary32 adjacent-tree LayerNorm gold。单行 pilot 只签 producer 算术、WSTRB/末 B、completion/END fence和一个诚实单行诊断 owner，不执行 stage2 QUANT source query。完整16行保留全部16384项 bitwise gold、真实 AXI 计数、诚实 rows16 owner 的发布及全身份 source-query lease/释放。测试台的提前 END 是带冻结成功提交量的受控时序输入，最终须与真实 engine completion 的 issued/consumed 字节量一致；实际生产 caller 从 completion 构造 END 仍待集成。

pilot 与 full 使用同一冻结 RTL、IP 和 no-wave profile。当前 pilot cycles/s、冻结16行工作量、按行参考周期和1.5保守系数在 full 启动前形成成本决定；无有效 pilot 或超原帽时 `COST_STOP/started:false`。参考周期/投影不作为已证明的上界、实测时长或硬件性能。full 保留3600s/8GiB/120s进展保护与更严格的5Mcycle自检帽。

该 shell 不扩为最终13BO top，不拥有 graph 预约或 typed 退休权威。仅 provenance 的 depth2 FIFO 是此入口真实实例；producer 接口由 TB 逐拍驱动并背压，不能据此声称 sequencer/adapter 的真实 depth2 整链。完整 S64/S128 发布、多 owner/role/QKV、普通/GATE切换、LOAD/MATRIX、故障/活动取消恢复和完整请求仍待验证。


## 2026-10-12 F9跨协议绑定与真实LayerNorm→QUANT/fullA

按主控R-SM003-LAYERNORM-PRODUCER-PORTAL-20261012修复当前shell的准入。provenance AXI portal向shell只读提供已成功BEGIN的不可变1024B快照；发布/READY权威仍归同一hub。shell先收完整producer请求，再核共同NumericIdentity/Context、416B L13M、origin、目标Ref/epoch/region、role、D/rows、expected unit/elements、BO span及实际连续写geometry，才逐拍交给真实生成engine。完整completion也先收齐并核原请求seq/origin、identity/Context、两Ref/region、role、D/gamma/eps、offset/stride及提交/消费字节约束，之后才交caller。拒绝保持旧请求/BEGIN/物理scope和fence，不用清scope/复位制造drained。

新增绑定payload快照/槽为BEGIN1024B、请求1024B、completion512B，共2560B；另有计数/状态及已有portal/control/depth2 FIFO，尚无联合综合资源结论。这些均为层级内部metadata，不新增Host ABI或service。

`laya_layernorm_quant_source_shell_v1`在同runtime连接真实producer、持久monitor/hub的source query/原子lease与唯一共享QUANT/fullA。Q的物理读从TB真实接收的producer W字取值；不将gold预填为源。END的status/unit/elements/detail/bad/issued从实际完整completion构造。独立量化oracle读冻结LN gold，逐组执行binary32 amax/127、reciprocal、multiply、roundf ties-away，scale FP16 RNE；全量核16384个INT8与512个half scale。

当前入口仍是一份诚实rows16诊断owner，未宣称完整S64 tensor或真实sequencer/adapter生成。F9四个请求突变与两项completion边界注入核无提前AXI/发布与旧scope隔离；一般失败部分提交、活动cancel、坏返回后的硬件恢复、多窗口/角色/QKV与完整13BO top继续待验。

## 2026-10-12 adapter逐拍构造实施

沿D-M003-CONTROLLER-INTERNAL-SPLIT-01/LTX1/LTC1既有边界：完整24拍内部请求先由独立有限语义校验phase核验，随后使用现wire字段的不可变byte mapping逐个512bit字构造所选外部帧，不再建立1024B整帧external_request副本或调用三份整帧外部encode。接收完整8拍应答后，独立NORMALIZE_RESPONSE phase保留原全绑定/语法/真实drained/scope校验和原LTC1编码。顶层不再II1跨phase整体展开；byte搬运/组帧helper有限顺序执行。合法cancel cleanup和未消费completion单inflight保持，编号/owner/READY/typed退休仍由原职责域拥有。

当前不可变三份1024项int16映射的源码表示6144B，是控制映射元数据；不把删除1024B帧副本称为净资源节省。实际ROM/逻辑/数据存储及联合资源由生成/综合证据另核。语义decoder与completion encoder仍保留完整帧内扫描，不宣称全部codec已改为每字即时校验或达到1字/cycle。

controller_transaction_adapter_12当前host PASS：原四个测试入口保持，新增56个patterned映射帧全1024B比对既有独立semantic encode。patterned映射探针不声明语义准入成功。下一步HLS_03为有区分力生成尝试；不加帽、不重试旧_02。

## adapter当前生成状态登记

HLS_03工具370.877336s/exit0已生成，原runner FAIL为内部handshake误分类，原记录保留；顶层独立审计24/18信号通过。RTL_01仅static和compute/depth2 pilot51308cycles通过，八case组合COST_STOP未启动；真实sequencer/LayerNorm接线仍待。分区registry现为generated_top_verified_rtl_compute_subset，所有声明限定到此范围。

## 2026-10-12 adapter completion真实消费互锁

`laya_controller_transaction_adapter_shell_v1`在实际生成adapter与内部transaction depth2 FIFO之间实现单inflight的消费边界。shell以adapter真实request `read && empty_n`计数24拍；第24拍后阻止下一descriptor越过request FIFO出端。completion的16拍退休只采用sequencer侧FIFO真实`read && empty_n`，不采用adapter的最后一次`write`或FIFO非满。第16拍实际消费后的下一周期才重新开放request。

互锁不修改HLS生成top、LTX1/LTC1字节、三对外部协议FIFO或Host ABI。当前shell的consumer握手端口是最终sequencer/adapter连接点；真实sequencer集成必须直接接其completion FIFO读握手，不能以completion写入、FIFO有空间或软件状态替代。活动请求的剩余拍、远端response及cleanup继续由adapter正常推进，门控只阻止下一帧首拍。

有界RTL入口把后继descriptor前两拍预先排入depth2 FIFO，并在旧completion仅剩两拍和一拍时各停读12周期，要求下一请求零读、下一外部事务零拍和旧输出稳定；最后一拍真实消费后才放行。八类协议事务在独立复位运行中覆盖该边界；它们不等于真实graph sequencer同runtime整链。

## 2026-10-12 Graph program / task lifecycle 有限拆分

按[生产HLS分区合同§8](../../../../../../../../results/production_hls_partition_contract_20261012.md)的 `D-M003-GRAPH-LIFECYCLE-SPLIT-01`，原 graph sequencer 职责进一步拆成 program sequencer 与 task lifecycle executor。program 唯一拥有完整模型 PC、下一 `GraphActionKind`、逻辑 slot 句柄/版本和单调 action ordinal；executor 唯一拥有请求/模型准入、NumericIdentity、Task/Ref/epoch 预约、高水位、owner/lease、BEGIN→producer→END/fence、首错和唯一 typed 退休。adapter 继续只执行单笔 LTX1/LTC1 事务，唯一持久 hub 继续拥有物理覆盖、债务、发布和 source lease 权威。

内部 action schema 为 little-endian LAX1/LAC1、512bit/depth2、单 inflight。LAX1 请求为 512B/8拍，LAC1 完成为 256B/4拍；请求键包含完整 NumericIdentity、action ordinal、PC/action、shape/batch、源 slot 版本和目标参数，完成返回原键、真实 Check、可信/安全终态、drained、typed 退休结果及有限 slot 增量。只有完整绑定、可信、安全、drained 且 typed 已退休的成功完成才能提交 slot 并推进 PC；坏头、旧 ordinal、错源版本和非终态完成保留 pending action。

当前实现映射为 [laya_graph_action_protocol.h](../../../../include/laya_graph_action_protocol.h)、[graph_action_protocol.cpp](../../../../hls/control/graph_action_protocol.cpp)、[laya_graph_program_sequencer.h](../../../../include/laya_graph_program_sequencer.h)、[graph_program_sequencer.cpp](../../../../hls/control/graph_program_sequencer.cpp)、[laya_task_lifecycle_executor.h](../../../../include/laya_task_lifecycle_executor.h) 与 [task_lifecycle_executor.cpp](../../../../hls/control/task_lifecycle_executor.cpp)。共享C/SV布局还登记在 [graph_action_registry.json](../../../../config/graph_action_registry.json) 和 [laya_graph_action_layout_v1.sv](../rtl/laya_graph_action_layout_v1.sv)。program 的三源闭包排除 executor、旧 Controller 和 adapter；executor 的14源闭包排除旧 Controller、adapter实现及compute/provenance/producer三套外部协议codec。

首个 executor 子集只实现完整 B×S 的 NORM/LayerNorm；当前受控主机运行是 B1/S64 四个 rows16 窗口，逐窗口执行 CLAIM→BEGIN→producer→END，最后 PUBLISH，并产生四次唯一 typed 退休。其余16类 action 在 Task/Ref 预约、owner变化和协议序列之前明确拒绝。source slot 版本在本子集按 source Ref epoch 核验。失败且没有活动 generated tracker 时才允许物理 INVALIDATE/本地失效；活动 tracker 保留，不能伪报安全终态。

当前只是主机组合实现。program/executor 的 HLS top、action FIFO 实际 depth2 背压与末拍消费互锁、真实 cancel/部分提交/旧返回恢复、同runtime generated LayerNorm AXI master→monitor/hub 及最终13BO shell仍待实现和验证。


## 2026-10-12 Graph lifecycle F11–F13 清理状态

LAC1 completion 采用临时对象解码，完整头部、Status、flags、slot及owner语义通过后才提交输出。Status限定为OK..E_INTERNAL；LOCAL_REJECT与OK不允许组合。NORM成功完成由program另核owner batch255、row0=0和精确的B×ceil(S/16) typed退休数。

program把first_error作为request失败锁存。安全错误action完成后停止普通PC派发；新accepted-request begin重置request局部状态，同时保留action ordinal高水位。

lifecycle在FullRuntime中保存活动action完整键、source/output、首错，以及CLAIM/PUBLISH、BEGIN scope、source lease和INVALIDATE远端/本地状态。generated_store为空只说明没有活动producer scope，不能证明owner物理清理完成。错误action只有在匹配远端INVALIDATE成功、drained且terminal，并且本地owner invalidate成功后才报告SAFE_TERMINAL/REMOTE_DRAINED。坏绑定、未排空、source release失败均保留原状态和后继阻塞；cleanup结果不覆盖首个业务错误。

## 2026-10-12 Graph program accepted-request bootstrap

program分区新增固定little-endian LGP1/LGR1边界：accepted command为256B/4拍，request result为256B/4拍，均使用512bit/depth2内部FIFO。命令携完整NumericIdentity、一个由唯一executor/shell确认READY的source slot句柄和有限entrypoint；结果返回原身份、实际Check、action ordinal、PC及有限slot增量。共享字段、保留区和flags分别冻结在 [laya_graph_program_protocol.h](../../../../include/laya_graph_program_protocol.h)、[graph_program_protocol.cpp](../../../../hls/control/graph_program_protocol.cpp) 和 [laya_graph_program_layout_v1.sv](../rtl/laya_graph_program_layout_v1.sv)。

当前 [graph_program_hls.cpp](../../../../hls/control/graph_program_hls.cpp) 只实现 `NORM_LAYER1_ATTN` 的单action有界入口。它从accepted command产生一份LAX1，消费完整LAC1后形成LGR1；正常成功才提交slot并推进PC，安全错误返回request失败。坏command在分配action前返回零ordinal、无binding的安全`LOCAL_REJECT`。LGR1末拍写入FIFO不等于请求已退休：top保持`WAIT_RESULT_CONSUMED`，只有executor/shell对同一result FIFO最后一拍的真实消费信号到达后，下一周期才允许读取后继LGP1。action ordinal跨合法新request保持单调。

唯一请求/模型准入权威仍归executor/shell；program不自行把任意LGP1视为Host请求。当前host测试直接驱动已接受命令和抽象`result_consumed`信号，只验证program内部状态机与schema。后续RTL shell必须从真实result FIFO consumer握手产生该信号，并与LAX1/LAC1末拍门控、F10的LTX1/LTC1门控分别验证。

## 2026-10-12 Program末拍相邻通知保持

program在LGR1末拍成功写入时锁存同次调用result_consumed，在WAIT消费并清除；更早通知不释放未来command。真实shell仍需保持由当前result FIFO真实四次消费握手形成的通知，直到本请求明确消费；host pulse回归不代签RTL接线。

## 2026-10-12 真实program结果消费shell与有限生成

新增laya_graph_program_shell_v1及固定长度consumption gate。唯一pending请求在4拍accepted command实际读完后保持准入关闭；LGR1消费端4次真实read/empty_n握手后下一周期开放。通知保持到下一command首拍实际读取，跨HLS多周期调度不依赖pulse，cancel不清边界。当前shell尚未运行；复用共同clock/reset/depth2 FIFO。新生成只含program六源，排除原execute_graph_action调用树与executor/adapter，PC/完整family仍待。采用原static24GiB/1800s、120s可观察进度保护，无改帽。

## 2026-10-12 executor共享有限步骤实施

新增task_lifecycle_fsm.cpp和12源闭包。每次step执行有限Phase，持久保存完整action、B/row游标与当前事务绑定；BEGIN→producer实际完成→END/fence→唯一typed退休→下一窗口。owner清理在原action内部续行，非终态END重发同一END键，坏帧/错键隔离保留tracker和lease。完成槽在消费确认前不开放下一action。当前helper测试seed准入，bootstrap及HLS top尚未实现。program实际shell/depth2结果消费另有有限RTL证据，不代签executor事务/物理hub。

## Executor请求准入与只读snapshot实现（2026-10-12）

权威补充：[D-M003-EXECUTOR-BOOTSTRAP-SOURCE-01](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/executor_bootstrap_source_contract_20261012.md) §§1–5；沿用生产分区合同§8、原任务/数值及所有预算。当前来源限定HIDDEN bank0/region0、stage2/layer0、batch255、完整B×S TOKEN/D1024/F32、old_ref NONE；其他来源明确未支持。encoder_00_out检查点不是CPU RAW，也不是16行诊断owner。

LBS1/LBR1 v1上下行均768B/12拍，小端。header字段：magic0/4B、version4/2B、beats6/2B、purpose8/2B、status10/2B、flags12/4B、独立snapshot seq16/8B、detail24/4B、bad32/8B、BO base epoch40/8B、实际base address48/8B、capacity56/8B；完整NumericIdentity从64开始84B，416B L13M在160，原128B OwnerDescriptor在576。其余字段为零保留区。请求status/flags/detail/bad全零；成功响应flags63表示FRAME_COMPLETE/BINDING_OK/SOURCE_MATCH/PUBLISHED/COMPLETE/QUIESCENT，合法错误只flags3且无source资格。任何帧头、语义或binding拒绝先清输出；合法非OK完整绑定响应保留实际状态。seq独立于typed/portal/event/producer，跨软取消保持，溢出拒绝。

`executor_bootstrap.cpp`的新请求入口先核本地port/machine/action/tracker/reader安全及唯一shell物理/结果消费确认，随后使用原full_begin_request→full_decode_validate_request（真实LYRQ/AUX LYMP）→full_admit_request。checkpoint prepare_snapshot不重复begin/admit，保留原预约/退休/协议高水位。只有完整绑定响应和同一live base、source protection保持且未cancel才返回LGP1；logical source镜像直接缓存唯一hub事实，不调用物理CLAIM/cover/PUBLISH，不虚增任务或owner统计。当前这些shell/guard输入在host由fixture提供，生产top尚未接好。

`task_lifecycle_port.cpp`围绕原共享FSM逐拍收LAX1 8拍、出LAC1 4拍。旧action内部继续所有cleanup，完成生成后等待其consumer确认；较早消费信号不释放action。无可信key的坏头/语义帧隔离且不产生安全完成；完全语法合法的旧ordinal/源version或未实现family在副作用前本地拒绝。真实8/4消费shell及独立executor top仍待实现，当前C++ port不是新的跨分区FullRuntime接口。

唯一hub增加默认禁用的ENABLE_BOOTSTRAP_SNAPSHOT可选只读接口，响应保存至consumer握手。查询读取原owner数组并核完整身份/model/descriptor、published/完整window状态以及真实物理quiescent和shell base。scope/pending END/未消费LPV响应/冲突lease阻止准入；不要求active_owners为0。查询不改owner、window完成、typed或生产event状态。当前RTL证明来自普通LPV CLAIM、实际AXI monitor写、四窗口END、PUBLISH的受控前序producer，没有层级写owner。

snapshot查询只证明时点事实；响应消费后的source失效或base/epoch变化不能因此被禁止。下一阶段须在唯一shell封住所有source变更/旁路写，重核producer启动绑定/cancel并保持保护至真实读债/完成/fence及action消费边界，或使用同一hub显式通用原子lease。没有该保护证据时不能生成/报告生产source读取闭合。


## F14 snapshot与旧任务清理仲裁修复（2026-10-12）

LPV/旧action cleanup优先于未接受snapshot：request_ready不依赖snapshot_request_valid，已接受snapshot_response_valid仍保持排他。snapshot等待旧scope、END/LPV返回、lease及cancel收束；不会用撤请求或清返回制造进展。QUANT query相对snapshot保持原仲裁。来源保护仍待实现。


## F14主控审核及后续排他门准备（2026-10-12）

主控R-SM003-BOOTSTRAP-SNAPSHOT-F14-20261012在有限持续valid的LPV/END/INVALIDATE取消范围关闭F14。三项合计51组（20+13+18）/214引用；相对snapshot_02共同闭包实际变化五项：hub/TB/runner及此前登记的两catalog。lease释放drained由TB受控，不是实际消费者读债。原handoff/attempt不回写。

开始source guard原型：shell缓存完整LBS1键、唯一hub实时比较原owner数组，排斥冲突source修改/重叠alias/新identity。cancel保持被保护source，直至本action安全完成实际消费后才收束。读债由实际AR/R握手计，producer/action完成consumer来自各自depth2 FIFO；宽action/producer准入及完成内容当前仍受控fixture，尚未接生成executor/producer和唯一完整写仲裁，不签完整source保护或生产整链。


## Source guard原型当前连接义务

现原型通过唯一hub全绑定source重核、同role冲突排斥、cancel保留，真实AR/R债务及两个depth2完成consumer的末拍释放。action/producer帧和安全错误LAC1仍受控，producer FIFO为传输probe；生产必须接F9已核完成同consumer。AR allowed须同时门控实际memory VALID与producer READY；同STATE0 monitor之外的全部写/跨role/base alias/覆盖/release入口及13BO生命周期未封口。生产LN shell已在工作源码接入默认禁用guard，实际通过范围按下面新入口单独记录。宽action/producer输入只能来自已核完整帧槽，不允许Host或SOURCE_READY_PROOF直接置guard。

本guard只缓存排他键，不复制hub owner发布权威，不分配typed，实际安全状态仍由真实executor/monitor/adapter/hub证明。尚不得以原型生成生产executor或宣称source保护闭合；先完成实际入口接线和受影响host/RTL范围。当前没有HLS/OOC/P&R/实板资源或性能数据。


## F15与真实LN来源门接线（2026-10-12，当前实施）

沿生产分区合同§8及bootstrap source合同§3/5。guard的producer准入同时检查已锁存安全action消费及当前第4次真实LAC1消费的完整安全候选，终态当拍起不接新producer；旧producer/读债继续正常排空，release也检查当拍握手。_07原型动态核同拍持续valid、物理安全延迟、完成尾拍/残余R债与prestart cancel，不用清producer_active掩盖已接受工作。

启用保护的hub将source修改冲突变为完整绑定的E_BUFFER/drained=false响应，保持原owner/旧scope/typed状态并消耗一次请求，避免门户head永久阻塞旧END。scope标志按原codec只用于本请求的BEGIN/END，不为INVALIDATE回传全局scope；全局旧scope保存在hub。单STATE0 base之外的role无法证明物理不重叠，当前保守拒绝，不宣称完整13BO alias表。

真实LN shell新增默认禁用guard和默认禁用的有限前序writer选择：一个共享物理writer/同monitor/同hub；正常前序CLAIM/BEGIN/实际store/END/PUBLISH用于受控checkpoint，读开始前关闭前序writer。选择在旧scope、transport/BEGIN grant、job/request或guard活动时保持；保护期不开放前序AW/W。固定base/address/epoch/capacity由初始化锁存并持续比较，变化锁存配置错误；本有限top不支持无reset重新配置base，不签完整Host BO生命周期。

F9请求完整槽通过BEGIN比较后再进入guard完整来源/当前action比较，成功才发实际engine请求。来源AR的memory VALID与engine READY使用同一guard allowed。已核LPC1仍经F9完整槽和反向比较；guard与job/fence观察同一个depth2 FIFO的真实consumer读，guard启用时末拍入队不清job/消费债，最后一次caller消费才清。物理safe由实际portal framing/scope/monitor/adapter/read/completion债联合形成，排除保留中的guard/cancel ownership以避免循环等待。LAC1仍是外部当前action consumer接口，下一步须接真实executor/program，不能由Host proof位代替。

layernorm_guarded_source有限入口只拟运行一行真实LN及1024独立F32 gold。source全B1/S64 owner经四个正常监测窗口建立，后48行重复冻结前16行，是受控前序checkpoint，不是encoder实际计算。actual LPC1逐字段构造END；完整64行target owner的一行成功不能发布为完整窗口，预期得到诚实短窗口拒绝/唯一task5退休并INVALIDATE清理。LAC1 safe-error仍受控byte oracle，不签生产action退休和完整数值成功。当前_01 static PASS/pilot FAIL是scope回复映射问题，已修且待受影响重跑；历史保留。


## 2026-10-12 F16与有限真实guarded LN阶段补充

# F16实际返回语义与有限真实guarded LayerNorm接线

M003/SM003/E003/R003，沿生产分区§8与D-M003-EXECUTOR-BOOTSTRAP-SOURCE-01；回复bootstrap-source-guard-f15-review-20261012。F15已由主控在_07受控原型范围关闭，本轮_08保留同一guard并修正hub非END冲突返回scope映射，申请F16按实际decoder/adapter及有限RTL范围核验。C009和完整生产source保护仍未关闭。

实际hub来源通过正常CLAIM、四个BEGIN→真实monitor AW/W/B→END、PUBLISH建立B1/S64完整HIDDEN checkpoint，64AW/4096W/64B、262144B。memory初始未知，仅实际W写入，冻结16行数值输入重复到64行；这是受控encoder_00_out前序，不是实际encoder计算。唯一固定STATE0内的前序writer与实际生成LN writer共用同一monitor/hub/物理写口，guard期间前序writer无AW/W准入；LN真实AR的memory VALID与engine READY使用同一allowed门控。base/epoch/capacity捕获并持续比较，证明只限已接入的两个writer和单base，全部13BO生命周期及旁路未闭合。

LN_05实际使用既有layernorm_producer_hls_01相同生成RTL/7DAT，完整F9请求/完成验证、同一真实depth2 LPC1 consumer末2/末1拍各停12周期；producer job/fence保持到真实最后消费。1AR/64R、4096B，1024 F32 gold逐字比较。真实LPC1字段构造END；完整64行target只提交1行，诚实返回短窗口E_PROTOCOL，hub task5终态恰一次并INVALIDATE。LAC1安全错误来自受控byte fixture，其真实depth2 consumer末2/末1拍门控后释放guard，不是生成executor报告或完整action成功。

F16修复保持原codec/layout：非END冲突返回E_BUFFER、drained0、scope0，内部旧scope仍保持；错误END可报告scope1。LN_05实际采集18份完整LPV request/response（36文件）。host_01读取其中idle冲突、活动scope非END冲突、错误END及匹配短窗口终态END四对，现C++ provenance decoder逐字roundtrip，真实C++ transaction adapter逐字外发并核LTC1绑定/终态。错END为drained1/scope1，保持非终态；短窗口END为drained1/scope0、安全错误。原F16非END scope1变体在decoder/adapter均隔离，零可信后继完成。没有放宽codec或清旧scope迎合测试。

默认guard禁用兼容：monitor_13保持旧部分失败/末B/cancel/恢复fixture；snapshot_05保持F14持续valid仲裁；LN portal_08为单行pilot；LN→Q_04为单行pilot及全部六F9拒绝case，rows16 full未启动，旧_03完整LN→Q/fullA gold仍只按原冻结身份复用。

## 2026-10-13：有限诊断v2检查点的主机实现

权威细化：[D-M003-EXECUTOR-CHECKPOINT-HIGH-WATER-01](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/executor_checkpoint_high_water_contract_20261012.md) §1–5。沿用生产分区§8及来源保护合同，只支持同一已准入request中的NORM_LAYER1_ATTN诊断。前序派发/旧END/末B/返回排空后才交接；真实hub/transport读出、锁定来源与目标域以及硬件consumer仍待实施，本节不是RTL完成声明。

工作实现为include/laya_executor_checkpoint.h、hls/control/executor_checkpoint_protocol.cpp及executor_checkpoint.cpp，生产闭包config/executor_checkpoint_sources.cmake。LBS2/LBR2是version2、1024B/16拍；v1仍为768B/12拍且语义不变。共享SV常量位于rtl/laya_executor_checkpoint_layout_v2.sv。0–663字节沿用原source绑定映射，664–671保留；扩展只属于v2，不能把原128B owner descriptor后部直接解释为扩展字段。

| 字节offset | 字段 |
| --- | --- |
| 672 | mode u16，当前1 |
| 674–677 | target Buffer/bank/region/role各u8 |
| 678 | response TargetState；request必须0 |
| 680 | handoff_epoch u64 |
| 688–736 | target base_epoch/address/capacity/offset/extent/row_stride/batch_stride各u64 |
| 744/748 | KNOWN/COMPLETE mask各u32，TASK/LPV/SOURCE/TARGET=1/2/4/8 |
| 752/756/760 | task/source epoch/target epoch floor各u32 |
| 768 | LPV transport floor u64 |

成功flags=255，包含原source flags63、FRONTIER_COMPLETE64和DISPATCH_HELD128；负响应flags3，保留可信绑定但下界字段清零，无source能力。请求所有下界/占用字段必须零，完整帧的保留位全部验证。decode在临时对象完成全部检查后提交，拒绝输出为默认对象。目标固定当前STATE0的NORM分配域（offset8MiB）；该限定不覆盖任意13BO/base alias。

原子导入先核绑定、真实shell fence输入、已准入identity、KNOWN/COMPLETE/FRONTIER、源/目标映射、局部空洞、表容量与task/Ref/LPV/producer/action/compute溢出。只复制小TaskReservation进行容量预检。全部检查后一次提交：只读source镜像、无READY的目标epoch历史缓存、预约下界、退休比较前驱及checkpoint来源记录。现CLAIM同时核owner max epoch，故仅提高预约cursor不足；历史缓存不调用CLAIM/PUBLISH，不增owner/task统计。局部更大Ref/LPV下界保留；producer/compute和program action权威不从hub导入。

FullRuntime保存完整identity/source/model/base/seq/handoff及task基线；full_begin_request清理该request内记录，checkpoint续行不调用begin/admit。导入不构造TaskDone、不调用retire、不增tasks_retired/op_calls/owner_claims/owner_leases。FSM和旧同步reference均用实际tasks_retired增量形成LAC1数量，编号区间仅作连续一致性检查。任何基线已应用、未知局部预约空洞或不兼容旧状态均拒绝，不重放旧任务。


## 2026-10-13：真实v2诊断下界与16拍派发权交接

沿D-M003-EXECUTOR-CHECKPOINT-HIGH-WATER-01。可选ENABLE_EXECUTOR_CHECKPOINT默认关闭，新增内部transport，不改变Host/LPV/LPA接口布局。hub从原typed/owner数组读下界；每个typed identity的连续前序witness只由正常BEGIN及真实成功END形成，观察到跳号或错误终态便清除。LPV下界由axi portal直接接原transport.last_event_seq，查询不增加任何生产事件或typed终态。

v2 source descriptor只复制0–87字节并清128B后部，不将672字节后的扩展带入find_exact。对STATE0固定base的source/target历史全表扫描保守取max；活动目标/重叠alias、其他role、容量或历史base不明拒绝。portal从首次真实前序ingress保存base生命周期键，之后变化使该诊断历史不完整；它不是另一owner/发布表。此有限shell仍不覆盖全部13BO。

laya_executor_checkpoint_transport_v2使用两个实际depth2 FIFO。旧LPV半帧/END/末B/返回先经原入口正常排空，且获取交接的同拍不能再接受前序命令。hub返回保持到真实第16拍消费，FIFO已写满或末拍入队均不能释放。成功末拍消费只产生一次handoff_pulse并将原派发口永久封住，后继executor口接同一个真实LPV transport；无效绑定/错误返回不能取得派发权。取消/base变化使稳定成功字节失去实际authority，不能恢复普通派发。

当前实现是每次真实复位一次的有限诊断交接，没有新accepted-request phase复位入口，也未与生成executor导入确认绑定。连续请求高水位、完整source/action保护、全部写入口、实际executor的8/4消费及F10的24/16消费继续待实现；不得把handoff_complete当作完整请求成功或永久SOURCE_READY。

当前准入还直接比较真实monitored_bo_base与锁存的snapshot地址，并把历史base完整性接入transport的configuration_ok。即使snapshot配置副本不变，真实监测base改变也立即撤销authority并锁存revoked；不能因软件副本仍匹配而放行旧proof。对应executor_checkpoint_rtl_06单独增加第五个复位分隔负例；_05原冻结PASS保留，不能外推到该新增边界。


## 2026-10-13：查询前保持和导入授权的主机准备

权威为[查询前保持与导入确认合同](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/executor_checkpoint_import_handshake_contract_20261013.md)§2–7。生产路径必须HOLD→HELD→LBS2/LBR2完整消费→实际helper提交→IMPORT_OK→GRANTED，再外发LGP1。旧_rtl_06末拍直接handoff仅保留原诊断范围，不能作为该生产路径的授权。

新增LHC1为独立内部1024B/16拍、version1控制帧。完整B的identity/model/source/target字段沿原位置编码；header magic为0x3143484c，kind byte8、status u16 byte10、S u64 byte16、reason u32 byte24、bad u64 byte32、H u64 byte680、hardware session u64 byte776、accepted-request实例u64 byte784、local_committed byte792，所有其余保留字节为0。HOLD的H为0且commit=0；HELD回显完整B并给非零H；IMPORT_OK/GRANTED要求commit=1；ABORT为错误状态且明确commit与否；ABORT_CLOSED/REJECT要求commit=0。控制返回不会隐含READY、退休或生产authority。

reserve_hold从唯一已准入runtime建立B并一次消耗S，不依赖held。prepare_held核唯一pending、完整B和真实Fence，使用同一S；匹配H在撤销时也保留为已观察下界，hold_reserved继续阻止误用accept。旧prepare兼容包装及LBS2/LBR2布局保持。

持久actor独占一份FullRuntime、port/shared FSM、checkpoint和控制pending。实际helper成功才形成IMPORT_OK；command内部暂存到匹配GRANTED。同事务撤销持久锁存，已提交事实不回滚；未提交错误只接受匹配ABORT_CLOSED及安全fence后允许新S尝试。已提交撤销仍为隔离/错误收束待生产shell连接，不谎报未提交。已有action在原port继续推进，不在新请求或普通action上重做清理。

当前只实现并验证C++ actor/core/schema及SV常量；HELD/GRANTED/ABORT_CLOSED/session/fence均为受控host输入，control ready/valid尚未接实际RTL。尚无独立C HLS entrypoint及生成executor；硬件rearm、持续通知跨多周期调度和完整13BO/source保护仍待。


## 2026-10-13：F17持续撤销与旧action收束

按主控[actor主机审核](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/executor_handoff_actor_host_reply_20261013.md)修复F17。actor准入时锁存base，整个绑定寿命持续核base/session/accepted-request/cancel。RUN_ACTION的READ_ACTION/VALIDATE_ACTION启动窗口另核live fence；活动EXECUTE不把正常债务或保护移交当撤销。撤销只禁止新首拍/新正常工作，部分帧和旧事务保持原port/FSM完成/END/cleanup路径。当前物理same-edge gate、完整错误收束及硬件rearm仍待。


## 2026-10-13：有限HOLD/IMPORT shell与managed portal

实现按查询前保持/导入确认合同§2–7。新增8192bit完整LHC1 ready/valid shell，单pending持久H、完整B/S及session/request；DRAIN用显式匹配前序结束键和独立排空，HELD后才能query，第16次实际read只IMPORT_PENDING，GRANTED真实消费才有启动authority。新工作撤销与旧owner route分离；活动债务不撤销不可变绑定。未提交ABORT安全关闭后同request重试保持S/H；已提交ABORT仅保留锁/归属隔离，结果/释放和accepted-request rearm待实现。portal默认关闭MANAGED_EXECUTOR_HANDOFF；managed抑制旧末拍authority/pulse、后续route保留旧cleanup并允许正确来源Q query，但合法lease未测。当前shell/portal接线是有界TB装配，未接production top或全部13BO/source保护。


### 2026-10-13 F18仲裁与未准入action取消consumer

沿 `results/executor_checkpoint_import_handshake_contract_20261013.md` 和
`results/executor_revoke_unaccepted_action_contract_20261013.md`（D-M003-EXECUTOR-REVOKE-UNACCEPTED-ACTION-01）。
LHC1 shell的DRAIN自主取得保持与控制接收互斥：当拍控制握手抑制HELD发布。
已经实际接受的查询优先于同时等待的控制；QUERY期间控制ready保持0，旧16拍响应正常消费，之后持续ABORT被接受。
所有已呈现响应保持至实际消费；撤销不覆盖返回字节，授权仍在实际GRANTED消费后重核。

内部LAP1 pending记录固定1024B/16拍/version1：magic0x3150414c，kind1；session/accepted-request/S/H位于16/24/32/40，48–255及9–15全零；完整LGP1位于256–511，完整已分配LAX1位于512–1023。
K引用shell保留的完整B；command/action全字节语法及本entrypoint语义均校验，不从错误帧前缀造完成。
`program_pending_protocol.cpp`为共享C++ codec；SV仅冻结布局常量，尚无SV执行证据。
`program_hls::State/step`是原program实现的显式持久状态；原extern C入口继续调用相同逻辑并保留原接口。
受控bound调用在旧command首拍消费时锁存K；取消后仍消费已经发出的command半帧，PREPARE不再分配action。
只有实际program已完全接收command并分配唯一pending时，observe_pending才输出完整LAP1。
未来生产wrapper必须真实传递该归属与消费通知；本轮C++同runtime结构不等于已生成硬件接线。

actor在RUN_ACTION持续撤销、普通port仍为READ_ACTION/beat0且无活动tracker/源租约时，校验旧LAP1并选择唯一取消consumer。
正常port首拍已接受则保持原port/FSM路径；不能转交新consumer。取消consumer逐拍收齐原LAX1，完整codec与pending逐字匹配后才推进共享action接收high-water。
它不调用lifecycle start、任务/Ref预约或retire；生成flags79的原键非OK LAC1，退休及first/last均0，slot_delta为空。
该4拍由原program completion consumer校验后生成原ordinal的非LOCAL_REJECT错误LGR1，PC及slot不推进。
匹配完成反压时保持接收事实，不再接收第二份action；坏语法、语义、K或重放隔离且不推进可信下界。

撤销结果的实际Host末拍消费事实锁存；在绑定CLOSE/真实安全释放尚未实现时保持WAIT_RESULT_CONSUMED，不重装请求。
成功的旧主机fixture继续原受控result/fence路径；生产统一CLOSE、committed ABORT结果、transport rearm及全入口source保护仍待实现。
本轮软件队列无深度限制，停调用/延迟消费只签host通知和旧状态保持，不声称真实depth2或RTL同拍证明。

## 2026-10-13 managed query wrapper 实施中

沿 D-M003-EXECUTOR-CHECKPOINT-IMPORT-HANDSHAKE-01，新增 laya_executor_handoff_portal_shell_v1，将前序LPV、executor LPV、共享STATE0 writer、snapshot/source-query的保持门与真实portal/monitor/双depth2 transport放入模块。managed query首拍实际入FIFO后锁定完整旧K/B，剩余拍在持续cancel下继续；完整LBS2与旧K生成的期望帧逐字匹配后才交唯一hub，撤销仅允许实际hub完整校验的负LBR2。末拍消费只等待IMPORT/关闭，不能自动重开。ABORT_CLOSED完整键实际消费只收束未提交query phase；撤销shell仍隔离。默认模式保持原诊断行为。

验证范围：先原7终态真实前序+actual-helper离线确认兼容，再旧查询半帧/返回尾拍持续取消与字节gold；RTL 8GiB/120s/120s、100000cycle及原资源配置，单重工具。此阶段不含真实executor/helper同硬件runtime、source AR、LAP1 RTL、CLOSE/accepted-request rearm、合法Q lease或13BO。新增CLOSE合同 results/executor_close_rearm_contract_20261013.md 后续按原字段实施，不从本阶段代签。

上述query实现已按五个有限RTL路径及受影响兼容/实际C++捕获完成本轮验证；详见 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_managed_query_verification_20261013.json。活动LPV `transport_abort` 的旧半帧保持义务另待managed模式修复，当前query测试前该路径真实已排空。CLOSE/CLOSED及重新准入按 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/executor_close_rearm_contract_20261013.md 继续；本次不是整个请求关闭/恢复。

## 2026-10-13 CLOSE/CLOSED有限端点实施

依据 [D-M003-EXECUTOR-CLOSE-REARM-01](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/executor_close_rearm_contract_20261013.md)§1–3、6。LHC1保持version1/1024B/16拍/全部旧字段，新增内部kind8 CLOSE、kind9 CLOSED；旧七种literal字节不改，其他未知kind继续拒绝。code/detail/bad为原请求封存终态，commit0/1均只回显事实，不是关闭成功码。

actor的managed_close只在实际LYRQ/LYMP准入时锁存；完整真实program结果发完并由Host完整codec/逐字绑定消费后才发CLOSE，成功和撤销错误同路。仅无tag result_consumed不授权。实际完整CLOSED经codec、完整K、原终态和commit匹配，且CLOSE已实际消费后进入WAIT_NEW_ADMISSION；本阶段此状态不开放新入口。旧默认host fixture保持原路径，生成production top尚未接managed模式。没有新增未发LGP的本地请求错误出口或rearm权威。

shell MANAGED_REQUEST_CLOSE默认0；新有限TB显式1。terminal_seal、request_work_done、host_result_consumed和closed_consumer均8192bit完整LHC1归属记录，没有短hash；前三项引用锁存的完整终态CLOSE，最后项完整匹配呈现的CLOSED。旧query返回必须先正常消费，CLOSE不是排空证明。CLOSE_WAIT还核原old_channels_drained与physical_safe；反压保持旧锁/route，实际完整CLOSED消费后清旧route/锁，保留最后关闭记录/次数及S/H，进入WAIT_ADMISSION而非IDLE。当前输入cancel/base/session改变不替换旧关闭K。

本批验证范围：独立八组终态/commit literal及未知kind/保留位拒绝；真实C++ program/action/结果consumer成功、cancel-drain及部分command无action分支；shell受控旧结果/Host/work/物理安全延迟、匹配消费与稳定反压。shell安全/结果记录由TB提供，不代签生产wrapper实际物理事实；8192bit整体握手不是16拍CLOSED FIFO证明。actor软件队列无深度限制。无复位下一真实请求、无HOLD admission_closed、活动LPV持久cancel旧半帧及source全部入口/13BO继续待验。单重工具、host24GiB/1800s/120s、RTL8GiB/120s/120s、6000cycle及原CPU/优先级/MemAvailable帽不变。

本有限端点当前验证身份为request_close_shell_rtl_03和request_close_host_05；terminal_seal_fire与control_fire仲裁，合法终态封存同拍移除新query/HELD/启动authority，既有旧归属/返回继续。CLOSED原子整体消费的完整记录必须等于实际呈现帧；不是仅ready或发送末拍。生产wrapper参数仍默认0且输入tie0，需要实际旧consumer/物理安全接入后才能开启。当前WAIT_NEW_ADMISSION/WAIT_ADMISSION不提供新候选准入，不能调用原begin/recycle假装保留持续分配下界。


## 2026-10-13 F19/F20关闭边界修复实现

依据主控R-SM003-EXECUTOR-REQUEST-CLOSE-20261013，原有限端点证据保留；F19/F20为本轮新增受影响候选。actor `managed_result_consumed`独立于legacy `result_consumed_pending`，仅完整codec及逐字匹配本结果建立；WRITE_RESULT末拍及WAIT消费过渡都采样匹配record，无键bool不进入managed事实。原默认结果路径保持。

shell完整terminal的ready/accepted不受control_fire抑制；原旧K/commit/终态匹配才封存并立即抑制authority/query。`observed_committed`仅来自已保存commit或本拍实际完整、匹配、状态合法的IMPORT/commit1 ABORT消费，terminal自报不能提交；实际consumer复用同一判定。CLOSE可匹配本拍新终态，work/Host完整记录同拍可保存。GRANTED/ABORT_CLOSED已呈现时保持原字节；终态不释放route、锁或旧query余拍，且不回到会重开前序的IDLE。

terminal_seal_ready表示完整当前record可接受，terminal_seal_accepted是valid&&ready的本拍事实；封存后的相同record幂等不再次接受，异记录拒绝。新接口内部有界，不改LHC1 wire/Host13BO ABI。唯一生产portal wrapper仍默认关闭request-close，输入tie0、两输出空接；不是生产关闭完成。

本轮有界用例及源码身份见R003/executor_close_f19_f20_plan_20261013.md和新shell_04/host_06。旧F15–F18关闭不扩大；真实wrapper/旧A-K结果归属、no-LGP请求错误、committed ABORT、LPV持久撤销、无复位新准入/持续allocator及source/Q整链继续待实现。

## Managed LPV持久完整A（2026-10-13）

依据项目results/executor_managed_lpv_owner_contract_20261013.md。LAD1内部1024B/v1含hardware session/accepted-request、完整84B NumericIdentity、416B L13M和13项已知物理映射；不含S/H，不改Host/LPV ABI。MANAGED_LPV_OWNER默认0，有限启用时唯一portal安装不可替换A，首拍保存A/route至16/8完整实际消费；唯一hub成功CLAIM/BEGIN附该稳定对象引用，完整A/model/descriptor核定END/INVALIDATE。撤销关闭新业务而保持旧FIFO/返回/owner及物理债务，INVALIDATE覆盖CLAIM-only；source新query同拍撤销关门，独立release保留。

当前生产wrapper新hook仍tie0，真实ingress/adapter pending/关闭/rearm及全13BO/source域未接；不可用有限case代签。具体字段、来源和未验边界见E003/R003/executor_managed_lpv_milestone_20261013.md。


## 2026-10-13 首请求executor与owned program归属接线

依据results/executor_minimum_hardware_chain_reply_20261013.md及executor_revoke_unaccepted_action_contract_20261013.md，FIRST入口使用actual LYMP/LYRQ和13-role locked mapping建立完整LAD1。executor_hls的真实GRANTED全包在shell accepted response receipt消费后输出给owned program；program完整codec/commit/kind核验后原包echo，executor逐字比较及旧输出实际读空才开启4拍LGP。错echo持久撤销并保留旧ABORT通路；不采用Entry拒绝屏蔽旧cleanup。内部LHC1/LAP1原字节不变，新增的是partition之间的完整记录FIFO。

新laya_graph_program_owned_sequencer保留整个GRANTED K/B，完整command在调用program::begin之前核其identity/source。实际program graph.pending分配ordinal后完整LAP1外发，先于action首拍；持续cancel仍让原command的全部4拍及已分配action的8拍完成。完整真实LAC1 codec/semantic接受后原包4拍receipt传回executor，再生成原归属LGR1。FIRST-only末结果消费后停止，不重收command、不做CLOSED/rearm。旧四FIFO program顶层保留兼容实现，新顶层单独冻结和生成。

内部program结果消费暂由唯一executor actual完整LGR1校验输出连接；该FIRST-only路径只有唯一稳定完整command/K，禁止第二request/command，因此不将外部Host bool用作消费资格。生产16拍depth2 CLOSED、全13BO物理对照、后继Q和完整恢复仍须另取真实证据。

## 2026-10-13 首请求生成修复与有限传输接线

生成可达program调用使用显式has_issued_key和完整Key；软件nullable重载只作兼容。完整packet相等采用固定逐byte XOR/OR，不使用std::array equality进入memcmp；原codec/reserved/完整归属与validate-before-commit保持。executor源码三残留比较已修复，尚无executor可用RTL。

FIRST admission transport从exclusive actual executor A producer的首实际write锁定完整frame；真实portal全帧accepted后原包echo，第二A入口关闭。LPV sidecar从actual LTX首pop保存不可替换A/route，收齐16LPV才外送、8返回经depth2保持到LTC末pop；其txn_start在撤销后禁止旧未开始END的缺口仍需核定，不以有限PASS签关闭。producer局部物理fence与全F10排空分别接线。source guard v2以actual shell HOLD/GRANT完整K/B保护旧source，持久撤销禁止新启动但保留已呈现AR及已接受R/F9/LAC旧消费；source写与已核NORM目标窗口分门。

合同引用继续使用results/executor_minimum_hardware_chain_reply_20261013.md、executor_managed_lpv_owner_contract_20261013.md及生产分区合同；所有新有限测试的受控peer与未覆盖范围在各receipt中列明。


### 首请求purpose边界修复与旧LTX清理（2026-10-13）

owned RTL02首次GRANTED安装失败已定位为嵌套bootstrap purpose映射错误：gdce保留正确对象字段，而a.g.0/RTL读取Message低16bit，真实字段位于[207:192]。bootstrap公开validate签名保持，完整校验体移到inline-off validate_fields，以caller实际r.purpose为独立16bit参数；全部其它物理/source/model校验与完整canonical byte比较保留。新HLS05中间a.g.0已观察load m[0]→lshr192→trunc16→参数→eq1，尚待完整生成及真实RTL；不把中间IR视作行为PASS。

撤销后的旧END首LTX路径采用[旧cleanup合同](../../../../../../../../results/executor_old_ltx_cleanup_contract_20261013.md)：唯一真实FSM持久transaction/request_packet、action及A/K/route提供完整pending；单候选有界24拍收集与实际adapter首pop分别记账。managed精确END/INVALIDATE尝试沿唯一hub核定；普通未外发事务由实际adapter产生原格式LOCAL_REJECT LTC1，实际16拍消费才收束传输。source lease release仍独立，不扩用legacy LPV RELEASE。当前sidecar冻结只覆盖已经开始的事务，新cleanup首pop仍未实现/未验；首请求所需旧债保护保持，完整CLOSED/rearm后置。


## 2026-10-13完整validator联合修复/actual adapter有限出口

# Program完整validator联合修复与actual adapter有限出口

回复 executor-program-content-mapping-review-20261013；M003/SM003/E003/R003，A002整合，C先于D。

## 新定位及修复

A004把HLS05完整validate_fields的416项model copy逐项追到原Message输入：409正确，j={0,64,128,192,256,320,384}七项错误读Message byte128+j，正确应152+j；它们是尚未动态进入路径中的静态错误。diagnostic03的原Message 416/416与独立owner输入一致，不能改fixture。purpose/content已观察错误与此未执行缺陷分开。A004对handoff→checkpoint→bootstrap binding_packet/put_owner补做有界只读核查：真实encode的content取RAM9[199:192]、模型动态152+i→wire160+i、purpose取RAM0[207:192]均静态正确；外层canonical/模型验证仍未动态测得，不扩大为PASS。

A002联合修复仅改内部完整validator：purpose已有实际scalar；新增实际r.source.content scalar，原d.content条件用该值；整对象identity复制改完整416次动态byte loop（unroll off）。保持公开接口、所有拒绝条件、独立region、完整canonical及416B/1024B比较，未传常量或改wire。新host bootstrap-purpose过程增加content0/2/255 direct/nested、correct F32+region1 direct/nested、七copy块首分别single-byte模型破坏拒绝。

`graph_program_owned_host_08`十独立process PASS_SCOPED_HOST，14源；build8.886544s、peak266988KiB、44owned RSS捕获。各短case peak/policy实际null不由配置补造；软件stream无depth限制。399/399 frozen与声明pair、当前live均核一致。新`graph_program_owned_hls_06`复用其精确冻结host闭包已实际启动（exec session32841），当前仅RUNNING；没有新executor RTL或硬件收益。A004准备同一生成物nested双512RAM validator的purpose/content/region/七copy边界输入，保留unknown padding mask；它不代签owner安装无副作用。

## Actual adapter有限RTL

`executor_adapter_lpv_generated_rtl_01`四复位分隔case PASS_SCOPED_RTL_ACTUAL_GENERATED_ADAPTER_PORTAL，总343711cycles；每次真实24 LTX/16 LPV/8 LPA/16 LTC消费，末LTC实际caller pop才释放事务，完整字节与独立literal相同。static126.760678s、peak4532732KiB；四sim35.396836/23.395227/11.573670/17.655366s、最大856988KiB，各child0/trigger null。369/369 frozen与声明pair/current均一致；两attempt共1326条nonoriginal递归SHA/bytes引用匹配。

范围是实际生成adapter、F10、sidecar、唯一实际portal/transport/monitor/hub；LTX/准入/AXI producer/fence peers受控。BEGIN声明rows16×4096B，实际writer仅64B，matching END为实际issued64的错误终态，因此签error transport/drain，不签完整LN正常数值。cancel在旧END首LTX pop及两raw LPV之后；CLAIM返回反压撤销与正常CLAIM-only INVALIDATE覆盖。撤销后新的cleanup首LTX仍被冻结sidecar阻断，case显式观察排队前2拍；post-revoke cleanup NOT_RUN，不伪称已闭合D-M003-EXECUTOR-OLD-LTX-CLEANUP-01。旧adapter HLS03 broad checker FAIL保持，使用已冻结实际top端口和旧RTL03身份，不回写旧receipt。


新HLS06运行，完整C/D与撤销后首cleanup仍待验；历史冻结尝试不改。


## 2026-10-13：FIRST Inputs临时入口与program实际执行

沿既定首请求/旧LTX合同，FIRST的Inputs仍是每调用独占临时值；stream内部派生事件直接覆写该scratch，actor仍const借用，调用后不保存Inputs引用。旧const stream API保留完整copy wrapper及原事件顺序，FIRST只改调用step_in_place，不改端口、初始化、A/K/consumer/旧帧债务或持久FullRuntime。此结构用于区分gdce已证2464B aggregate副本，不宣称根因或性能收益。

Program联合purpose/content真实标量＋动态416B copy修复保持全部原完整validator、canonical及1024B相等。新owned RTL05执行见证要求真实start而后终结state454完成，保留原四case/独立gold/尾拍反压；原idle done误触发的RTL04失败保留。LTP1完整pending编码与managed adapter host仅是旧cleanup准备，真实exporter/collector、撤销后首END/INVALIDATE尚未接线。权威依据仍results/executor_old_ltx_cleanup_contract_20261013.md及首请求合同；记录见R003/executor_program_rtl_inputs_structure_progress_20261013.md。


## 2026-10-13：executor分区内有界冷初始化候选

沿D-M003-EXECUTOR-COLD-INIT-STRUCTURE-01，在原FIRST前加入INIT，保留同一executor top、一个FullRuntime及原全部wire。仅原大型owner/source/window/GDown表和三个row-map推迟建立；其余metadata、allocator、Check和host-only缓存由原类型默认语义建立。ColdTable每cell使用typed union与placement construction建立真实C++生命周期，正常构造和完整活跃cell复制保留；未初始化cell禁止读、迭代或复制。没有裸内存清零、类型别名、缩表或READY/lease复制权威。

每cold_init_step建立一个typed cell或一个uint32 row-map word：32 owner、34 source metadata、4352 source windows、6144 QKV words、4096 rope words、1024 attention words及128 GDown windows，合计15810次调用；最后一次才置done。此为调用上界，不能当RTL启动周期。完成后的调用不重启或改下界，request/cancel/CLOSE/rearm未接INIT。FIRST的actor使用tag ctor，因此不先展开原完整大表constructor再补赋值；实际生成IR效果仍待核。

INIT分支在任何actor/transport业务读取之前，四个输出使用确定启动值，FIRST ready=0；不采session/config/A，不pop任何FIFO，不写控制/业务、预约、退休或AXI。FIRST持续有效、live字段变化和cancel均不重置cursor；完成后才进入原FIRST锁存。新增受影响host拟核全部定义默认值和表项覆盖，原FIRST七case增加15810次真实调用、11类输入FIFO占用检查及变化输入/取消后原单次握手。软件调用不证明RTL同拍、读master无AR或初始化真实cycles。

旧const/in_place入口和软件构造API继续；未验证的transaction exporter未加入本候选，避免把额外pending端口与冷初始化假设混合。C完整NORM先于D/Q；首cleanup必要旧债路径继续独立准备。


## 2026-10-13用户立即调转工作重心

user-work-focus-switch-immediate-20261013覆盖此前executor首生成排程：停止启动HLS05及冷INIT/collector/exporter/managed cleanup/CLOSE/rearm后继，保存现状，不回退/删除或覆盖冻结。最后已启动collector RTL01按原guard完成：19.891915s/peak1371000KiB/99RSS、child0/null，限定受控pending/旧绑定传输PASS；实际FSM、adapter/F10/sidecar、LTC codec、hub cleanup/retirement与same-runtime C仍NOT_RUN。FIRST冷INIT host09七process通过；全定义默认值新test/runner仅保存准备，未编译/运行；HLS05未创建。

managed HLS01真实工具462.750790s/peak6140864KiB/2312RSS、child0/null并产出top；原脚本因postcheck live full_runtime/task_reservation变化FAIL保持。另有只读immutable generation audit核809冻结配对/8676文件引用、精确27端口通过，HLS估计BRAM18=51/DSP29/FF53175/LUT196031/URAM0；仅冻结生成和接口，不签RTL或新生产兼容。无重跑，当前无在跑重工具。

当前第一优先为独立真实算术kernel/冻结gold/有限RTL的baseline与瓶颈盘点；受控driver可用于有限算术测量，不代表production控制链/完整请求。FullRuntime/executor/program/CLOSED不再是算术实验的前置。详细新合同前不启动新重工具，原数值/shape、单重工具/资源帽/G仅OOC余额/5172s不重启保持。M003未完成，M004完整加速器目标保持。


## 2026-10-13 SM005局部Down KB0/KB1

依据D-M004-MEASUREMENT-FIRST-01，局部算术测量先于恢复executor。KB0采用E003/R003/resident_regression_02原26 frozen闭包与12独立fixture；新增tm4tn8_down_measurement_tb_v1.sv只加观察/真实done消费，保持4distinct预量化A、K2624/N1024、bias0/冷reset、PS及4096F32独立gold、AXI末B/局部owner、原7cycle done hold。计量边界cfg接受→first done pre-NBA采样及实际consume，加载在cfg之前另记。非互斥stall不加成总延迟。

KB1普通缓冲候选为rtl/tm4tn8_axi512_writer_rowpack_kb1.sv；与原writer同module名，只通过新AT frozen source override编译，不能同一compile加原文件。保留完整config/packet/address校验、一个held packet与一个不可变tx；单pack改4个row-keyed pack。相邻两TN8 tile同row/同64B地址合并，full或同row地址变化/flush时选一个sealed pack转原tx，只有tx空或实际B消费才能替换tx。所有pack、held、旧tx均空才debt_zero，flush/owner发布仍等实际末B。四row流不改算术/PS反馈/归约，只改存储合并。

预期4096F32 useful bytes仍16384，AXI512单beat数512→256、physical bytes32768→16384；原响应策略AW cycle%7/W cycle%11及B延迟17+(实际beat序号%3)、done7hold原样保持。不是减少测试台等待来求收益。额外pack字段3×(512data+64addr+64strobe+1valid)=1923bits，约240.375B逻辑存储；无新增算术IP/DSP，具体LUT/FF/RAM映射、联合资源/时序UNKNOWN，本轮无OOC/P&R/上板。

同口径AT001 KB0/AT002 KB1现已实际full通过：4096F32及全部PS gold不变，512TN8 packet、256实际AW/W/B，末B/一次consume保持。cfg→first done21100→16183，cfg→consume21107→16190，全TB48864→43947；加载不变，详细证据见results.md及E005/R001集中比较。保留KB1为有限normal候选；LUT/FF/RAM/物理时序仍UNKNOWN。

有限normal测试不能签通用fault恢复；原坏packet握手同沿可能transfer一旧sealed pack的窗口、stray B无tx只置fault不清held/pack的窗口继承不变，两者未动态测。本优化不改错误语义，实验内fault即停样本。生产控制/cleanup/全请求未完成项保留，当前不恢复控制工具。

## 2026-10-13 GQD0有限真实输入接链

依据`mission/g_quant_down_integration_stage_20261013.md`，新`tb/gqd0_chain_tb_v1.sv`把原bridge04的真实GATE AXI→量化→桥内唯一dualA与KB1冻结Down的A acquire/read/return/release逐字段直连，TB移除预量化A填入。完整数字身份、96bit linear context、slot/epoch、A/W/dst ref、row block/group保留；GATE AXI仅在真实AW/W后存储，量化经AR/R读回。外部Wi四行F32及Down W/metadata为声明输入，独立gold仅用于断言。由`tb/build_gqd0_tb.py`从原Down观察TB派生；实际受验源码固定在E005/R001/AT025冻结清单，不能把当前live源当作原样实验身份。GATE与Down的两个输出端口分别计债，原末B/局部publication/lease和done消费保持。字段表及本轮未覆盖范围见E005/R001/reports/GQD0_connection_map_20261013.md。

## 2026-10-13 WIGQD0单引擎有限接线

沿`mission/wi_g_quant_down_integration_stage_20261013.md`，诊断接线用唯一resident、dualW和dualA：外部原四行LN_FFN预量化A填入epoch1，Wi resident输出由实际AXI写同一字节DDR；原Wi AXI reader拟以真实AR/R供G，GATE写/读与量化复用dualA epoch2，Down复用同resident与dualW epoch2。无链间reset，完整B1/S128/batch0/row0身份及Wi/GATE/Down独立地址区见E005/R001/reports/WIGQD0_connection_map_20261013.md。gold只作比较，不预填Wi中间数据。AT031完整仿真实际只到Wi有效区读回和G命令接受，后续真实reader/G/Down连接行为尚未证实；不能把此实现映射写成整链功能通过。

## 2026-10-14 LNF0四行LN_FFN诊断回放

按`mission/ln_ffn_four_row_rtl_stage_20261014.md`复用AT014 baseline LN生成核83项及原provenance/store/quant/fullA叶子。派生fixture将原request3/generation1、B1/S128、LN_FFN stage2/layer0/rows4、STATE0容量16920576B、HIDDEN offset0/NORM offset8MiB统一写入P/Q及owner descriptor；独立AT038 residual作为声明外部源。TB只通过实际AXI WSTRB写目的区，Q经真实AR/R读取同一写入数组，gold只在端点比较。四行有效区与本地邻接保护区终扫、末B后END/发布/Q准入及响应消费后lease释放均断言；本诊断未接QAR0长链。当前受验代码以E005/R001/AT040冻结副本为准，原AT014及AT039失败副本不改。

## 2026-10-14 M005代表top提取（候选，未验）

依据`mission/M005_代表通路与整模性能可行性评估/contract.md`阶段A/B，新增`tb/m005_top_extract_inventory.py`与`tb/m005_build_representative_top_v1.py`，从AT065同一链的十个真实硬件实例生成`rtl/laya_ffn_representative_top_v1.sv`候选。其唯一LN shell、quant/dualA、dualW、resident/PS、G桥、Wi reader、Down handoff和原residual在同一层；外部DDR响应、fixture/gold、测试台阶段sequencer不应进入综合网表。当前生成文件仍有`ln_physical_r_debt_zero`外部输入，尚不足以作为最终物理边界；需把量化内部债和实际Q AXI未归还R握手合成硬件判据，受影响接口问题已直接发主控。候选top未编译、未接回TB、未综合，不得称资源代表性已成立。

## 2026-10-14 M005最终full后代表top与综合边界

AT070/AT073的功能top已将LN准入读债改为内部Q AXI ARLEN/R握手及量化任务债判据，并按合同把G的固定K=2624接入handoff。AT073仅TB W/AUX组合响应相位在negedge稳定，硬件top和算术与AT070同SHA。最后full到达Down成功写入/消费，但handoff保留ticket的复合检查失败；具体子条件未在冻结日志逐项打印，末残差未实际准入。此为当前硬件行为缺口，不从旧局部残差PASS补签。

联合综合AT074首先发现Vivado在`default_nettype none`下要求top的输入端口显式网络类型。工作`rtl/laya_ffn_representative_top_v1.sv`现将156个`input logic`机械写为`input wire logic`，删除新增`wire`后与AT070冻结top逐字相同。AT075由此越过端口展开。随后通用`laya_generated_provenance_hub_v1.geometry_within`的运行时循环不能综合；工作RTL将合法上限32项改为固定32步，保持原`rows*repeats<=32`的逐区间检查，AT076同SHA portal短测通过。AT077又暴露该hub的`geometries_disjoint`五层动态相交循环不可综合；该处直接固定展开约需2016组64bit区间对比较，多周期化则改变hub时序职责。当前未静默选择新资源架构，已向主控提交受影响判断。AT074/075/077原失败输入身份保留，物理候选与AT073功能样本SHA不同，不能称已完成联合网表或Fmax。

AT065冻结联合TB另发现`.gate_k(g_cfg_K)`唯一出现且无声明/驱动，handoff要求13'd2624；这与动态`static_ok=x`一致。后续在工作源码修G实际descriptor K并补四态受理边沿，原AT065冻结不修改。外部sequencer与平台shell仍按合同单列成本。

## 2026-10-15 SM004修订9：单行真实LN→Q→完整Wi

权威接口与验证范围见 `project/missions/SM004.md`“真实单行LN→Q→完整Wi（修订9）”；同输入绑定见 `source/fixed_graph_support_20261014/lnq_matrix_binding_20261015.json`。本模块的 `rtl/laya_lnq_wi_row_v1.sv` 以固定单命令FSM连接现行 `laya_lnq_row_v1`、`t4_dual_w_cache_v1` 和 `tm4tn8_sync_ps_front_v2`。冷命令先真实AXI LOAD，暖命令沿原READY槽匹配lease；每个LNQ group同步读一次A/scale并保持656个tile，W每tile真实read/return，前端按32group×656tile提交PS。g31的656个tile写隐藏8×656 F32结果bank；完整覆盖、真实债务及W/LNQ释放后才发布同步单响应读口。保存的LN/Q/PS/final只用于TB比较，不进入DUT数据端口。

PS front新增 `abort_valid/abort_ready`：RUN/DRAIN握手优先于同拍issue及队首launch，预留项按真实同步读返回后丢弃，已发FP照常退休；`external_abort`独立锁存并参加同拍最终done_error。顶层仅在真实W读错误或返回标签不符时驱动该入口，停止新A/W请求，等待前端、W缓存和LNQ真实排空/释放后返回错误且不发布行。旧前端调用者显式接abort=0。该设计保持既有Q35与浮点顺序，不引入通用portal/owner。

当前仍是单行Wi连接，matrix内部四行物理容量与W cache双槽没有缩减。上游/下游完整图、外部搬运、联合面积、布线Fmax与整模吞吐不由此局部模块推断；实测范围见同目录`results.md`与E004/R001的SM004同一阶段报告。

2026-10-15 数值错误映射普通修复准备：工作顶层在真实末组commit的tile地址/重复提交异常，或`(commit_mask|commit_bad)!=8'hff`时仍置`local_fault`；后者只拒绝不能由坏数值/先前poison解释的缺失lane。前端可把已poison lane从`commit_mask`删去，同时经`commit_bad_mask=bad_row|snapshot_poison`解释；这类有效tile虽不写隐藏final bank，仍记录commit覆盖及计数，因此后续重复提交仍归协议。前端保持`first_bad_element`并在真实债务排空后返回数值状态6。DRAIN先处理真正协议/传输错误，再处理前端数值错误，最后才对无错误行要求656tile完整覆盖；全部poison走front原`final_skip`。AT147/148冻结顶层仍是修复前版本。受影响TB应分别核末组真实bad、前组poison传至末组造成mask<ff、无bad解释的缺失lane、重复/非法tile以及all-poison skip；核状态6/原位置或真实协议7、零发布和真实排空，不通过force done或清债制造完成。该工作源码修复尚未仿真，需下一有限RTL额度验证。

## 2026-10-14 M005 R3诊断物理候选映射

代表top的诊断综合仍采用AT070冻结的算术、存储容量和端口边界。原hub `geometries_disjoint` 运行时嵌套循环在工作RTL中改为最多两descriptor×各32项的组合端点/无序对判定；不增周期、不移检查到TB。原generated store monitor的两处最多32项几何扫描在工作RTL中固定循环，保留65bit地址和逐字节索引规则。AT035冻结matrix resident的half→F32原`while`在`experiment/physical_diagnostics/M005/tm4tn8_matrix_resident_v2.sv`派生版中改为最多10步；该诊断派生文件不替换E002主RTL中历史不同版本。AT087清单是此物理候选的精确输入；这些变换的有限差分和短测见E006 AT079/080/082/085，不能代签完整通路功能。联合综合于24GiB内存帽停止，尚无网表或物理资源/频率结论；生产接口及其它任务控制保持原开放状态。

## 2026-10-15 SM004修订10：真实LN→Q→Wi→G→Q→Down

权威合同是 `project/missions/SM004.md` 修订10；同输入绑定是 `source/fixed_graph_support_20261014/wi_gqdown_binding_20261015.json`。`rtl/laya_lnq_wi_gqdown_row_v1.sv` 固定单行FSM复用一套LN、一套可选LN1024或直接G2624输入的Q、一套matrix/front、一套双槽W cache及原`geglu_canonical_core`。cold真实依序装入Wi和Down两套W/AUX，warm分别匹配原槽lease；每时刻只持有一个W读响应。Wi 32group×656tile提交到原8bank×656 F32 bank；其成功屏障及真实债务/释放完成后，G按328个双tile读取Wi的x/gate并顺序发射2624元素。gate地址在**操作数扩宽后**用10bit的`{1'b0,g_tile}+10'd328`，覆盖328..655，避免旧AT163在512回绕。G返回原位覆盖bank前328tile，Q直接模式读2624个F32形成82组，再由同一front提交82group×128tile Down；最终只发布1024个Down F32和成功done，不包含末残差。

Down slot1的cache返回数据是单tile响应pair0；RTL使用`ret_q[0]/ret_scale[0]`并单独核`ret_slot`身份。旧AT165用slot号索引数据pair导致slot1首返回错，AT166已对完整真实冷暖链逐位闭合。Wi/Down数值bad及poison仅允许由`commit_bad_mask`解释缺失lane，不能归类为协议7；真正tag、覆盖或无bad解释的mask错误仍按协议优先。该映射在本版正常数据路径已运行，**受控坏返回及恢复未由AT166证明**。当前模块未进行联合OOC、P&R或板端测量；复位探针及更多限定结果见同目录`results.md`与E004/R001阶段报告。

## 2026-10-15 SM004修订11：真实末残差连接

现行顶层在外部前LN的1024次`x_valid && x_ready`握手上顺序保存原始F32到1024×32bit同步skip bank。Down的全部128个结果tile、front/W/LNQ释放及真实债务完成后，固定FSM按元素序号同步读取skip和现有`final_bank`中的Down值，把两个32bit操作数保持到原`laya_vector_add_stream_v1`接受，再消费有序返回并原位覆盖同一bank。该实现一次仅有一个ADD请求在途，保证同址读写分离；32credit叶子保持原样，未以等待拍数代替握手债务。1024项均接受、返回、写回后才进入原ROW发布；数值非有限报状态6/最低序号，计数及协议错误报7，残差错误相位为新4bit值8。旧相位0..7不变。

AT050的skip、Down和末残差row0仅作局部或完整链checker；工作bank从真实输入和真实Down运算生成。当前没有本顶层联合OOC、P&R或实际频率结果。受控局部入口及真实完整链的冻结身份与验证范围见同目录`results.md`和E004/R001既有SM004阶段报告。

## 2026-10-15 SM004修订12：Embedding LN→Q→QKV单行接入

接口与验收真源为[SM004修订12](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/missions/SM004.md)及[实施决定](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/m004_simplified_start_20261014/embedding_qkv_connection_decision.md)；原始输入关联见`source/fixed_graph_support_20261014/embedding_qkv_binding_20261015.json`。当前工作顶层新增`cmd_mode/cmd_row`和锁存的`result_mode/result_row`。mode0保持原FFN，非零row在启动服务前返回协议7；mode1核task context中的rows=1、row0与端口行号一致，固定gamma1、K1024/N3072、slot0权重key`16'h0001`。Down参数在QKV分支不用，原FFN分支仍要求Wi/Down两套有效epoch。

`laya_lnq_row_v1`的`norm_valid/index/bits`只观察非direct LN输出被Q接受的握手，原背压不变。QKV模式把1024个真实消费值依序写入原`final_bank` tile384..511，计数与index核对；matrix用同一前端把384tile×32group的最终PS写入tile0..383。组A与W、FP16恢复、front首错及真实W/Q释放仍沿原叶子。QKV成功时跳过G/Down/ADD，结果同步读范围0..511；FFN读范围仍0..127。QKV norm与矩阵写入在不同FSM阶段，bank中没有新增整行副本。该接口仍由外部raw/gamma流供数，不代表生产Host gamma DMA已实现。工作实现的数值与长例状态以本次新冻结证据为准，旧FFN PASS不自动迁移。

修订12测试后的逐槽epoch边界：QKV cold把slot0从0装到1，row1 warm只lease；切回FFN时slot0下一次cold合法epoch为2，而此前未使用的slot1首次cold合法epoch仍为1。旧cache按各槽分别要求`new_epoch=slot_epoch+1`；AT193的slot1 epoch3即时被拒绝属TB命令配置错误，AT195用2/1分别真实LOAD成功。AT193完成两行QKV六字段与错身份FFN warm拒绝，AT195完成真实QKV READY后FFN Wi/G及Down前缀；本版尚未取得同runtime FFN末残差消费者done，不能据此宣称整个Encoder0块闭合。精确受验范围和预算见同目录`results.md`及E004/R001阶段报告。

## 2026-10-15 SM004修订13：QKV/norm scratch包装层

按[修订13合同](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/m004_simplified_start_20261014/qkv_scratch_connection_decision.md)，新增`laya_qkv_scratch_row_v1`，内部仅一份原`laya_lnq_wi_gqdown_row_v1`和一份`tm1tn8_axi512_writer`。FFN命令透传原读/响应/释放，scratch三口VALID均为0；QKV命令由包装层顺序读取core结果bank的384个QKV tile及128个norm tile，按48个head段及一个norm段向QKV0、QKV1、STATE1 HIDDEN三个独立BO域写回。每段保持路由和base/span直至flush成功且真实写债零；一个同步读预约和core原响应保持寄存器承担背压，没有复制整行计算或另设结果RAM。目的地址用扩宽算术核对完整64B beat、描述符范围及页界；已展示的AW/W受阻期间保持字段，B按锁定目的路由。

writer新增`rearm_valid/rearm_ready`：只在复位释放且真实写债零、无held tile和flush时接受，清每行计数/故障；既有ACT及writer bridge caller均显式接0。包装层锁存命令与tensor身份/epoch/三目的描述符，以128bit行覆盖和sticky失败管理pre-RoPE RAW；只有128行全部写回且最后outer done消费后发布`tensor_raw_valid`。局部读/写错误为状态7、phase12，保留core数值6的原phase/首错；已握手读和已展示TX需真实排空，成功行等末B、49次flush、core release/done及零债。tensor释放优先同拍行命令，未发布的partial/failed只能显式discard。共同reset清控制有效性；外存旧字节不因此回滚。raw和gamma输入仍是外部流，真实设备源reader及Host BO绑定尚未实现。受检RTL身份、数值和故障范围以同目录`results.md`及E004/R001阶段报告为准。

修订13受影响普通修复：原core在FFN `ROW` 收到非法`rd_tile`时可直接转`DONE(7/7)`而不握手release；包装层现在在`F_ROW`识别该终态，用真实读预约和响应握手排空后转`F_DONE`消费原core错误，避免等待不存在的release。首次暴露core行前比较已锁存的`result_mode/result_row`与core回显；FFN不匹配拒绝读/发布，真实release与core done后给外层7/7，且不修改已有tensor；QKV不匹配禁止新读写，排空writer/读债、真实release/core done后给7/12，并将已接纳tensor标为failed。FFN有效读的预约在真实rsp消费沿消债，done/结果字段继续保持至外层握手。差异仅在wrapper状态、身份/债务门控，原计算core、writer、地址算术和gold未变；新冻结身份及受影响局部验证见结果记录。


修订13 flush错误出口受影响实现：在首段真实flush完成与core回显错误同拍时，writer的一次性`flush_done`可能已消费。包装层`ERR_FLUSH`继续保持flush请求以提交已接受的pack，消费已接受的同步rsp，并以`!read_pending && !core_rsp_valid && writer_debt_zero`屏障进入真实release；不依赖第二次flush脉冲。新增控制差异不改core、writer、段地址和正常数据路径；AT212旧版复现、AT213局部peer回归及AT214真实core/IP静态展开见同目录`results.md`与E004阶段报告。

## 2026-10-15 SM004修订14：QKV RAW scratch→原full-Check RoPE

按`project/missions/SM004.md`修订14，`rtl/laya_qkv_scratch_row_v1.sv`在同一原计算core与writer之后，RAW写成功且core release/done退休后，分时复用AUX端口加载当前行cos/sin full表，用一套scratch reader从真实Q/K BO读每head256B，调用原`rope_head.v`完整128bit Check叶子，原址写回并等真实B/flush后才置row_final。每行32个调用按head0 Q,K→head15 Q,K；V/norm不变。启用RoPE时RAW来源epoch=e，Q/K FINAL预留e+1，norm仍e，完整128行且末outer done消费后才可发布FINAL；RAW-only沿原单epoch路径。新done诊断保留Check/head/plane和数值bad映射，phase13标识RoPE错误。没有新增整行或整tensor RAM；reader FIFO、head/table局部存储和writer原保持payload分别按合同记载，不宣称综合面积。

AT225旧wrapper `b1315262…`已经真实两行完整数值/传输局部PASS。主控发现旧遍历先全部Q后全部K，且AUX旧sticky error可使新load被接受却误拒绝；当前wrapper `0d3e340e…`同步修正顺序、route/地址/Check诊断，并在load地址合法时先记真实接受、当前load_done才判错误。reader load_valid也受地址检查门控。原core `54fe628f…`、writer `ee1121c5…`、adapter `a80564de…`及HLS算术叶子未改；AT232新wrapper真实core/IP展开PASS，受影响局部证据见同目录`results.md`。新SHA没有重跑AT225长例，旧正常链不迁移成新身份完整数值PASS。

原raw/gamma仍为外部流，本地scratch三域只是接口边界；生产设备BO、Attention读取FINAL与norm、全请求RoPE首错顺序、完整Encoder/模型、联合面积和物理Fmax均待后续接线与验证。当前行内head优先调度不能冒称与旧全请求head优先首错同序。
## 2026-10-15 SM004修订15：STATE0/gamma预装与固定S128调度（实施中）

按SM004修订15合同，`rtl/laya_lnq_wi_gqdown_row_v1.sv`在原`final_bank`的tile0..255增加顺序预装：1024个raw字占tile0..127，1024个gamma字占tile128..255。begin锁定cmd id/row/source epoch，严格索引0..2047的写握手累计后才允许commit；匹配token被一次真实QKV core命令消费。LN启动后经同步bank单字预约、保持寄存与原LN valid/ready回放，raw再gamma；外部x/gamma在prepared模式保持ready0。原norm tile384..511及后续matrix tile0..383的生命周期保持互斥，未新增整行RAM。新增协议状态14仅供prepared输入路径，算术规则仍由原LN和矩阵叶子执行。

`rtl/laya_qkv_scratch_row_v1.sv`新增独立STATE0 AXI512读域，复用原512bit scratch reader装载每行4096B raw，并在core占用AUX前复用原128bit table reader从完整模型AUX+128装载4096B gamma。reader出数以一个512bit holding拆成顺序32bit bank写；各load接受、offset/epoch/字节、真实load_done及FIFO排空决定推进。命令接受时锁存全部延迟core字段及source描述符，完成预装后再发core命令；输入读错取消未展示的新请求，保持已展示AR与实际R债，排空后abort token、一次7/phase14行完成和tensor sticky failed。旧外部x/gamma与FFN入口的新mode固定为0；新增模式仅QKV。source e与W槽epoch分别保留，source/AUX描述符在同tensor后续行精确匹配。

`rtl/laya_qkv_s128_request_v1.sv`只有一份上述row wrapper实例。请求接受后锁存模型、数值、W、目标、STATE0和AUX字段，生成row0..127的id、task context、cold/begin及warm命令；8bit退休计数可表示128。每行wrapper outer done真消费后才进入下一行，最后还须128位RAW/FINAL覆盖及tensor_final_valid，才保持一次请求done至消费。输入范围/id溢出先于行命令拒绝；成功请求完成后继续等待消费者合法release，不能用请求done代替tensor释放。该模块不连接Attention、Host或HBM平台；真实全128算术与完整模型仍待后续证据。

修订15最终工作wrapper `d4856aee1f59c07e3af7b9427e50d0cd4d177f859cee4ee905637128f0c60209`对输入错误出口只在source/table reader的load_done、FIFO/out holding以及本地holding真实排空后展示一次`prep_abort_valid`；abort握手后才报7/phase14，避免core清除准备态后等待第二次ready。source模式的RAW-only续行也比较已锁存完整AUX base/span，旧外部流RAW-only不增加无用匹配。AT259用合法prepared-core peer在raw第7个R时产生fault，证实abort晚于该已接受burst的64个R；AT256用真实core核RAW-only的两类错AUX描述符零新AR及合法恢复。原算术core、reader、writer和叶子未因这两处控制修复改变。

本修订请求接口字段锁存与调度的128行覆盖由AT252模拟row完成peer核验；AT250仅旧wrapper身份同runtime真实row0/1前缀，AT264当前wrapper身份仅真实row0完整RAW→RoPE及逻辑邻行哨兵。固定S128生产端口没有两行成功开关，AT250结束时生产sequencer仍有row2..127。完整请求的旧全QKV先于RoPE、head→16row窗口的异常首错次序与此逐行服务不同，仍为后继集成接口缺口；正常数值局部PASS不能消除该差别。


## 修订17 LN128 阶段与 Q16 bank 入口（2026-10-15，工程实现映射）

权威合同为 [D-M004-STAGED-LNQ-01](../../../../../../../../results/m004_simplified_start_20261014/staged_lnq_frontend_rev17_decision.md) 的“采用范围和阶段出口”“固定接口与存储”“真实LN写回和错误结算”。当前同一计算 core、scratch wrapper、固定 sequencer 的 RTL SHA256 依次为 `39b3bf4b6ec32e0210b105171d176d11fdc8602ed8cf5b60c774b5f1d2ebaac0`、`5c88716f2a9c60f065dab6358c7d9b1d336ab1eaba689f04ae37e31b74158e26`、`a4c999e5e7e5ea63c95dd7abf9d70d0eb4362b06b36e080b2670807c9500bca4`。LNQ leaf `laya_lnq_row_v1.sv` SHA256 为 `52cd1070e57d896c1ec828dc1b985b6b01b5c99a6e8b395e4b1dce3f00ad2df8`。旧外部流和 FFN 入口仍译码为 legacy；其 leaf mode00/direct2624 受影响短回归见 AT300。

leaf `source_mode` 00/01 分别为原 LNQ1024/direct2624，10 为 LN_ONLY1024，11 为 DIRECT_NORM1024。LN_ONLY 只送阻塞式 `ln_only_valid/ready/last`，不发 Q row；DIRECT_NORM 将保存的1024个 norm 送原 Q。core `cmd_exec` 000/001/010 分别为 legacy、LN_ONLY_ROW、Q16_FILL_ROW；其它编码本段拒绝。`prep_kind` 00/01/10/11 分别绑定旧2048字、staged raw1024、staged norm1024、gamma1024。准备 token 绑定 id/row/source epoch、模型与数值身份及 gamma AUX 描述符；真实 bank 写入、reader load_done 与握手完成后才准入对应 core 命令。每 bank 656 个32bit字，LN raw w0..1023、gamma w1024..2047、norm w3072..4095；Q16第 r 行紧密占 w=272r..272r+271，前256字Q、后16字scale pair。scale pair 在奇数组独立写拍提交；结果读维持同步请求/返回与 release 桥，未加第二套计算 core 或整行 RAM。

固定 staged 请求在真实 AUX gamma 预检后逐行 STATE0 raw→LN_ONLY→STATE1 norm writer，等待实际64笔 OKAY B、flush、读写债及 core done 消费后才置该行 `norm_written`；全部128位才持有 `NORM_STAGE_READY`，期间 request done、RAW/FINAL 均不发布。Q16_FILL_ROW 目前是同一 core 的局部入口：合法 peer 可在已有保存 norm 上测试16行 bank 生命周期；固定生产 sequencer 尚不从 NORM_STAGE_READY 接 Q16，也未启 W_PREP_ONLY、MATRIX16/STEP16 或 RoPE。正常真实128行目前未跑到阶段完成。

若窗口内 norm store B 错，wrapper 先锁存 `stage_store_fault` 并真实排债；sequencer 以 `drain_store_window` 驱动 `cmd_stage_discard_norm`，只继续该16行窗口所需 LN 算术。后续正常 norm 经受控 discard 释放 bank，不计成功写回；窗口内后续数值错覆盖已锁存 store 错，否则窗口末报告原 store 错。该优先级当前由合法 row-wrapper peer 核查，真实数据链只到 row0 末B错误、row1真实LN后 discard/无reset恢复；完整16行真实错误序列仍未执行。共同 reset 的新持有状态只在模拟 row-wrapper 的阶段就绪点作510拍隔离，active source/写债触发未新增实测。


## 修订18 Q16 部分窗口占有修复与成本诊断

生产 core `laya_lnq_wi_gqdown_row_v1.sv` 当前 SHA256 为 `a73632b8a85fae646b36c0355065b19a5f91b4067440c5f96f14726726197e54`。`q16_next_row` 为1..15且 `a_window_ready=0` 时，该部分窗口继续拥有已导出的 A bank：`cmd_ready` 只给 `cmd_exec=010`，`prep_begin_ready` 只给 `prep_kind=10`；已有身份/顺序校验继续约束下一合法行。无握手的不兼容预装和命令不能写 bank。临时准备 abort 不释放 A；仅原 `a_window_release/discard` 在债零时释放。core 的量化叶子、bank 布局、满窗口路径未改；wrapper 和 sequencer SHA 仍为 `5c88716f…` / `a4c999e5…`。AT302 的旧版 index0 覆盖、AT303 修复版局部逐位和拒绝/继续/abort/discard 证据见 E004 [修订18报告](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev18_q16_owner_ln128_cost_engineering_handoff_20261015.md)。

LN128 成本 A/B 不更改生产 RTL、时钟/CE、算术、gold 或实例数。当前完整父 top 在相同30000cycle前缀下以默认和本机接受的 `xelab --O3` 构建比较；两臂全部观察事件/逐位输出一致。`--O3` 的小幅运行成本改善未使120秒真实16行pilot完成，故本修订不启128行长例。未来结构候选仅是把现有唯一活跃 LNQ/bank/prep/真实source及norm服务抽成共享验证层并保持父top唯一实例；尚未实施或证明性能。

主控D-M004-REV18-REVIEW-01确认上述部分Q16窗口占有漏洞在AT303所测局部闭合；其余Q16父图和真实16行生产入口仍待后续合同。修订18成本出口封账，不在该版实施共享服务抽取。

## 修订19共享生产服务（2026-10-15，实施中）

权威合同：[D-M004-LN-SHARED-SERVICE-01](../../../../../../../../results/m004_simplified_start_20261014/ln_shared_service_rev19_decision.md)，固定切口和每种bank端口见[原架构“LN128实际生产服务抽取：固定切口与端口”](../../../../../../../../source/fixed_graph_architecture_20261014.md#ln128实际生产服务抽取固定切口与端口2026-10-15)。本段使用同一生产实例完成独立LN阶段和完整父top调用；未完成RTL及实测以前，下表只是实施归属，不是验证结论。

|状态和端口|单一写入者|旧客户端和时序|
|---|---|---|
|唯一`laya_lnq_row_v1`、8×656×32bit `final_bank`、prep/token/gamma身份、FEED回放、LN norm计数和视图、Q16覆盖与窗口占有、result同步pending/rsp|下层`laya_lnq_bank_service_v1`|legacy通过固定LNQ命令/读/释放端口；staged exec001/010由下层负责。bank读E0请求、E1采样、阻塞rsp保持。|
|matrix最终PS八lane写、G的x/gate八lane同步读与标量返回写、QD同步逐字读、ADD bank操作数同步读与标量写|下层bank固定端口，父重FSM决定合法发射|G可在同拍不同地址读写同bank；G/ADD/矩阵返回无ready，发射前须保证接收条件，不能把返回改成可暂停。|
|W cache、matrix/front、G/ADD叶子、skip_bank、矩阵覆盖/错误和legacy整行完成|原计算core的重执行器|legacy命令必须父重FSM和下层同时准入；相位切换以W/front/G/ADD及下层pending/rsp真债零为门槛。|
|STATE0/AUX读口、单writer、预装和norm同步读写债、128行循环/16行store故障屏障、staged描述符锁存|上层`laya_source_norm_service_v1`|reader在最终load_done及FIFO/holding退休后切路；writer直到真实B/debt_zero及flush撤下后切路。|
|RoPE算术和RAW/FINAL tensor发布、legacy QKV/FFN行编排|原wrapper/原sequencer的legacy路径|共享上层固定客户端复用同两reader与单writer；staged分支只代理上层请求/结果，不另保留循环或位图。|

修订20 AT339 实际落地进度：上层已接管 staged 与 legacy STATE0/AUX 预装、唯一512bit输入holding、1024字finite/commit/load_done排空；wrapper原IN_*入口和重复holding已移除。staged norm 的128个同步组读、4096B writer/flush/末B/debt_zero与release控制也由上层固定FSM驱动；wrapper只转接下层result读/释放信号并保留尚未迁移的行完成映射。128行循环、16行store错屏障及描述符锁存仍在原sequencer/wrapper，故上表这些项目目前是目标归属，尚未全部完成。AT336漏接writer.flush_done导致原120s失败，AT339恢复原端口后row0真实短例重新通过；细节见E004的AT339阶段报告。

原bank容量20992B不因抽取增减。原skip_bank4096B、LNQ内部银行、reader FIFO和writer160B仍实际存在；新增保持字节须在RTL冻结后逐项统计。MATRIX16/STEP16/W_PREP_ONLY、整RoPE与Attention联合不在本段实现。真实LN128、父top同runtime成本及联合资源/Fmax均待本修订原始guard验证。

### AT325 当前落地与尚待迁移的归属

上表的目标归属目前只在下层完成：SHA `63da9112…` 的下层拥有唯一LNQ/final_bank、staged LN_ONLY的命令至回放、1024项norm视图、同步响应、受控release/done，以及Q16部分窗口保护与覆盖。父core SHA `8c799f91…` 在staged exec001入口代理此生命周期；保留的LN_CMD/LN_WAIT是legacy重FSM访问同一下层的路径。下层固定PS/G/QD/ADD端口仍按原同步采样沿，G八lane读和不同地址标量返回写可同拍发生。AT325局部客户只验证端口映射/时序，不代表父matrix/G/ADD全算术。

上层 SHA `c6ca8ca7…` 已封装唯一原source reader、AUX reader、writer及路由和norm覆盖寄存器，但阶段位图更新仍收外部 `stage_clear/row_retire/store_fault/ready_commit`；128行循环和16行store错误屏障仍由sequencer/wrapper驱动。迁移前不能由独立TB模拟这些脉冲声称上层已成为独立LN128生产服务。当前父top AT323只完成真实row0固定160µs前缀；完整16行pilot和LN128未启动。[AT325阶段报告](../../../../../../../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev19_AT325_shared_service_engineering_stage_20261016.md)记录冻结身份、账与下一最小接口边界。

### 修订20 AT327 后的实际写入归属

AT326 下层在LN_ONLY接受沿锁存id/row/epoch，直接导出result_exec及完整Check；父core只核身份并代理，原局部Q16和bank客户回归通过。AT327 上层根据实际staged行接受、writer真实flush/B债和done消费写`norm_written`、`stage_store_fault`及`norm_stage_ready`，旧wrapper不再写这些判定位。AT327同版父请求top重新展开并完成真实row0的1024norm/64B/gamma256R/source64R前缀；原始数据见[局部里程碑](../../../../../../../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev20_AT326_AT327_partial_milestone_20261016.md)。

阶段控制仍未迁移：sequencer仍是`base_id/retired_rows/S_SEND/S_ROW/S_STAGE_READY/drain_store_window/store_error_*`写入者；wrapper仍是`IN_*`、`input_hold`及norm`SEG_PREP/READ_REQ/RSP/FLUSH/UNFLUSH/RELEASE/Q_DONE`写入者。故当前上层只拥有运输与覆盖位，不是可独立接受一次S128请求的完整生产stage。后续迁移须让上层在一次请求握手锁存全部staged描述符、内部逐行调用下层；父sequencer/wrapper只代理固定入口及legacy客户端。独立stage TB只接AXI peer和空闲legacy客户端，不注入逐行成功位或强制债零。此段为状态表，不视作单一owner已通过。

AT328继续移动**唯一物理实例的位置**：`laya_lnq_bank_service_v1`仍拥有一份LNQ与8×656×32bit bank，其实例现在位于上层`laya_source_norm_service_v1`；重core内部改为固定类型`laya_lnq_bank_link_v1`的151根信号透传和`laya_lnq_wi_gqdown_row_engine_v1`执行器。原名`laya_lnq_wi_gqdown_row_v1`仅作旧独立模块测试的兼容壳，完整父top直接例化engine并由上层持有bank，因而父top无第二个bank实例。该link只有固定连线，无仲裁、FIFO或新存储；后续上层stage控制与legacy客户仍须在同一bank输入上作固定相位选择。AT328同SHA父top重新展开且row0前缀再次通过（static136.91756376065314s、RTL49.00890666805208s），但尚未证明独立stage、16行/128行或父图其它客户端。接口语义尚需后继局部恢复回归。

### 修订20 AT343–351：当前生产控制单一归属

AT343冻结身份取代上文AT339“尚待迁移”时点：`laya_source_norm_service_v1` SHA `58086436…` 在一次 staged 请求握手锁存描述符、模型/数值/epoch及源/目的范围，独占128行计数、16行store错误窗口、gamma/STATE0预装、norm同步读取/单writer写回、行成功覆盖、故障完成与`NORM_STAGE_READY`保持。内部事件驱动下层LN_ONLY、result同步读/rsp、flush与真实release/done，TB不提供逐行命令或覆盖位。`laya_lnq_bank_service_v1` SHA `f63e25e2…` 独占一份LNQ/8×656 final_bank、prep/gamma token、命令回放、1024norm视图、Q16覆盖/占有及bank pending/rsp。父core `452deb9c…` 固定link代理legacy bank客户和本次真实委托来源Check；wrapper `b1b73970…`、sequencer `8b9261e0…` 仅代理staged请求和保留的legacy分支，不能再写stage行位图。两reader与单writer仍只在上层各一份；reader的load_done/错误排空、writer的末B/flush/debt_zero是换相位和正常退休的实际屏障。外部tensor/epoch仅作父层请求与发布代理，`NORM_STAGE_READY`不等于request_done、RAW或FINAL。

AT343独立TB直接实例化这同一生产上层（内部唯一下层），父请求top真实例化同版两层。当前阶段的错误和交接覆盖按[AT351工程报告](../../../../../../../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev20_AT351_engineering_stage_handoff_20261016.md)限定；尤其部分bank pending/rsp到legacy换路、完整父top 128行同runtime和数值优先级尚未实测。AT346只修正gamma错误TB的abort时点假设，AT349/350增加描述符拒绝及prep在途共同reset的独立短例；本段生产RTL和数值未变。

## 修订21：LN128继续到唯一W与首A16窗口（实现中）

`SL_HELD`保留AT343的128位norm覆盖、source epoch、模型/数值身份及STATE1目的范围。新增`stage_continue_valid/ready`只在成功`SL_HELD`、128位全1、writer末B和读写债归零、下层`service_quiescent`且gamma token可真实退休时接受；请求/代际、norm epoch、后继17个命令ID、独立A epoch和W描述符在接受沿检查并锁存。接受沿的`gamma_retire`只清下层gamma有效位，不调用prep_abort或释放norm。LN caller不发continue仍保持原`SL_HELD`行为。

|阶段|唯一控制owner|进入和退出屏障|
|---|---|---|
|LN128→`SL_HELD`|上层原128行FSM|真实norm覆盖、writer成功B/debt_zero、下层LN done消费；本版长链需新SHA重验。|
|`SL_HELD`→`SL_W_SEND/WAIT`|上层固定继续FSM|完整身份和quiescent握手；W完成前禁止STATE1 AR和Q16命令。|
|W冷载|`laya_w_prep_service_v1`|唯一原`t4_dual_w_cache_v1`位于该模块，legacy LOAD/lease/read/release与固定W_PREP互斥；协议/传输与scale数值错独立锁存，固定回执保持到消费。完整载荷、header、98304次scale检查须实测。|
|`SL_Q_PREP_SEND/WAIT`|上层复用原SP预装FSM|现单scratch reader锁住物理STATE1路由；从保留norm目的逐行64R、1024个写入后提交kind10 token，不再要求已退休gamma。|
|`SL_Q_CMD/WAIT`→`SL_A_HELD`|上层16行循环、下层唯一QF/Q叶子及bank|独立A epoch绑定窗口；每行真实QF done消费后才退休一次覆盖。末行完整窗口保持，后继matrix尚未连接。|

下层`service_quiescent`要求ST/QF/Q16空闲、LNQ可收命令且无row/rsp/done、无prep token/fault和同步pending/rsp、无A占有；gamma token单独通过`gamma_retire`处理。Q窗口在首行捕获准备源epoch，后15行同时核A epoch和该源epoch。reader route在load握手锁存为STATE0/STATE1/QKV0/QKV1，下一次合法load前不变。父wrapper只代理W命令及回执，父请求在真实NORM_STAGE_READY后自动提出一次continue，仍不发布request_done/RAW/FINAL。当前这张表是生产连接定义；真实串联、数值、错误与复位端点须以本修订冻结TB/guard结果判定，不沿用AT343 PASS。

### 修订21 AT372受影响实现映射

当前父core engine保持AT367构建所用字节；`laya_lnq_wi_gqdown_row_v1`兼容壳在AT369实测暴露新增`wprep_result_*`的`.*`缺线，仅补同名固定输出代理，当前整文件SHA为`920d804f37cca1a3e5696a97b8c7d73938e734889e4914927ef4a5e4560a8192`。父完整top直接例化engine，原唯一W服务/cache、上/下层及leaf不因该壳修正复制。AT372局部core从本地exec001拒绝done消费到exec100 W冷载/回执，再到错epoch拒绝；父生产请求从LN128到W/Q/A16仍无同runtime证据。AT368只改真实串联TB监视器：实际叶子Q入口与独立norm逐字比较，从同步叶子响应构造bank期望，r4..15只据此签传输/布局，算术独立gold限r0..3。详见[E004阶段报告](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT372_observer_wprep_engineering_stage_20261016.md)。
## 修订21 AT373–377受影响验证映射（2026-10-16）

现上层/下层/W服务/cache生产接口未改。`laya_ln128_wprep_q16_chain_tb.sv`的冻结AT375、AT376、AT377分别从真实LN128后检查W末RRESP错误、末B阻塞下的continue准入、STATE1最后R阻塞下的r15回放与A16保持。新增模式仅改变AXI peer的响应时机或响应码，继续使用原真实计算、保存gold只作checker；AT373/374复用下层合法接口核部分A显式discard与Q在途共同reset。具体终点与成本见[E004 AT377阶段报告](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT377_error_barrier_engineering_stage_20261016.md)。后继A16→MATRIX16接口按主控D-M004-A16-MATRIX16-INTERFACE-01单独立项；本轮没有增加矩阵生产实例。
## 修订21 AT378错误恢复验证映射（2026-10-16）

同版独立串联TB经真实W末q0 RRESP错误到生产`stage_follow_error_valid`，再由合法caller脉冲现有`stage_release_fire`并以新id/epoch重启真实source/gamma/LN row0。TB gamma AXI peer的读取索引按256 beat回绕以支持第二epoch，并不改DUT或gold。此用例只检独立stage接口恢复，父层tensor_release策略仍由生产父top另验。[E004原证据](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT378_w_error_recovery_engineering_stage_20261016.md)。

## 修订21 AT379–383阶段握手与父层继续接线（2026-10-16）

AT379同版上/下层/W服务/cache不变，只以合法外部阶段done ready保持三拍核继续准入。父固定生产接线已在工作源码落到 sequencer `9abc446e…`、wrapper `3a11446a…`、core `920d804f…`：sequencer在128行完成后提出一次continue，wrapper把保存的W描述符、上层W_PREP命令/真实core回执及STATE1物理端口连通，仍只使用原上层 `e2be4e1e…`、下层 `30816465…`、W服务 `519a2ccb…`、cache `6d13fae4…`。AT382同版完整父top展开与row0数值前缀通过；AT383父图120秒pilot只到行1退休，W/Q/A16父请求动态通路未到达，不能以静态接线代签。冻结闭包、失败修正和适用范围见[E004阶段交付](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT383_parent_continue_cost_handoff_20261016.md)。

### 修订21父TB范围与成本出口勘误（2026-10-16）

主控D-M004-REV21-CLOSEOUT-01补核：AT382/383父TB的W arready/rvalid固定零，STATE1 ready/valid绑零，W AR被STAGED_LN_FORBIDDEN_SERVICE判错，LN128正常终点立即finish；它只证明LN阶段前缀。父sequencer/wrapper/TB与AT367同SHA，core文件与AT372同SHA，本轮是匹配依赖后的重展开和前缀，不是新增生产接线或动态W/Q证据。修订21剩static605.50865154154599468s/RTL323.3846215400844935s已由主控封存；修订22新预算独立。

## 修订22 AT404 当前实现映射（2026-10-16）

当前工作版 `tm4tn8_sync_ps_front_v2` 增加 rows16/STEP16 固定调度，`laya_lnq_bank_service_v1` 增加真实 A16 claim 与固定 matrix bank-link，`laya_matrix_service_v1` 在完整 rows16/K1024/N3072 描述符下保留 A claim、W lease/read/ret、同步 A 和首 TN8 四 block/32 group 的真实 front 执行。`laya_source_norm_service_v1` 增加 `SL_MATRIX`、PS 同步读与唯一 writer 的16行 segment FSM。AT398/402 仅验证 matrix/front 局部边界，AT404 将这些组件放进独立组合层静态展开但没有运行到 matrix；父engine尚保留原 front/W 实例，唯一父层共享抽取仍待完成。具体证据和成本见[E004 AT404阶段报告](../../../../../../../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev22_AT404_matrix_local_and_chain_cost_milestone_20261016.md)。
