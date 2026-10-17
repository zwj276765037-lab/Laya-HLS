# TM1/TN8/GS32、512-bit Q8联合原型

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
