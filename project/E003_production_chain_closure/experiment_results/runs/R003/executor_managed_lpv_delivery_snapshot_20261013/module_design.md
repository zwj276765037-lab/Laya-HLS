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
