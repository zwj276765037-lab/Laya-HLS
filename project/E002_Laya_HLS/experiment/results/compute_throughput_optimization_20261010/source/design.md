# 算力与吞吐优化执行合同

## 2026-10-11连续长任务（最新授权，取消逐轮用户审核）

用户最新要求：**“这种级别的审核不需要我，我只想看最终完整加速器的实现结果。”** 因此取消先前“每轮交用户审核、未通过不得开始下一轮”的停点。GPT-6.1 Sol/xhigh按mission连续完成优化、工程集成、编译、仿真、普通修复及受影响回归；GPT-6 Astra/xhigh只在取得实际综合结果后评判结果并改进后续方案。主控在集中技术评判后直接推进后续已授权工作，不再申请每轮或小步骤确认。只向用户报告实质阻塞或最终完整实现结果。

流程：Sol选择有界优化/生产连接范围并复用合同→实现与真实模型独立参考验证→计量服务与性能→受影响模块OOC→Astra综合后集中评判→继续完整生产链集成与验证。第1轮已接受为正确但未提速的局部基线；第2轮按其单实例F32 add优化建议直接执行，随后优先接通真实producer与完整推理，避免无限局部优化。内部集中评判不等于完整加速器交付。

保持原模型、完整层数/shape、独立gold、数值与CPU/FPGA职责。不做模型输入查表，不放宽容差，不拿旧v4结果代签新实现。完整CPU/CSim、真实分段RTL、同runtime整层/整图RTL、资源综合与物理实现分别报告；超过既定长仿真成本时执行§9的有界替代覆盖并保留未覆盖项，不无限准备或原样加帽。

当前综合授权仍为受影响模块与必要封装OOC，不恢复整网综合/P&R/专项时序。全树单重工具/共享锁，CPU0–3、nice19、idle I/O、MemAvailable>192GiB，模块OOC owned RSS≤24GiB/3600s，其余功能工具原帽及自动真实语义120s停滞保护不变；只管理本任务进程。无U55C，板端实测保持未验证。



状态：**AUTHORIZED / HIGH_PERFORMANCE_LAYA_DIRECTION_UPDATED**。更新日期：2026-10-11。架构：Astra / xhigh。

`design_source: mission/compute_throughput_optimization.md`，用户批准记录为2026-10-10T11:57:43.794489+00:00。上级依据：[已批准mission](../../../mission/compute_throughput_optimization.md)。本文件是跨模块联合合同；模块实现/RTL/TB仍在既有模块目录。唯一动态状态由[阶段表](../stage_results.md)维护，不修改旧阶段合同/结果。

**2026-10-11目标修订优先：** 用户要求先做出性能较高的Laya加速器，不以50ms为唯一目标。当前以数值正确、完整推理、同基线实测离线性能改善和可部署资源预算推进；50ms首延迟/20完整请求每秒保留为远期参考。本文历史预算数值不重算，历史REJECTED_BUDGET中仅由旧50ms目标造成的排除不再是当前淘汰门槛；2ULP数值FAIL、真实资源冲突、服务器成本帽及整体物理验证暂停仍有效。当前行动与标准见§0.1–0.2，本轮只修订方向/计划，不启动重工具。

## 0. 分段执行授权与资源

**当前执行说明（第1轮实际综合后的更新）：** 此前§2–§4、§7的独立出口及§8.6 AV实验按results范围复用；正确libm叶子已完成第1轮CPU/RTL及实际模块OOC，零符号修正身份为`round1_02`。旧“本轮只修计划/新图待预审”是此前方向修订时的边界，已由顶部最新连续授权和本节取代。Sol继续有界实现、真实生产连接、编译及受影响修复，Astra在实际综合后集中评判并改进方案，无源码/编译/运行或人工轮次门。下文历史错误叶子证据保持原身份；当前正确叶子服务按§5.1，后续同图空间流水按§8.4.7。完整128行前端、生产HBM供数、全图及T3生产切换仍须真实集成证据，局部微基准不自动继承通过。

CPU0–3、nice19、idle I/O；全树最多一重工具，MemAvailable严格>192GiB，owned aggregate RSS每0.2s采样。轻量4GiB/120s，CPU/CSim16GiB/1800s，功能HLS24GiB/3600s，静态编译24GiB/1800s，有限RTL8GiB/3600s且40M cycles；pilot≤120s。原完整冷前端4300s仅原固定范围可继承，本轮微基准不用该加帽。整体OOC/P&R/专项时序暂停。

每60s记录实际算术/事务/任务进度、RSS、剩余工作和ETA；连续120s无语义进展，或两个间隔≥60s的有效样本预测超现有墙钟/周期帽，停止留证。普通修复有新可检验原因则同帽连续执行，不按次数回审批门；同因无进展不原样重跑。候选/性能假设探索遵守mission有限配置数。

### 0.1 2026-10-11当前目标与性能选择准则

优先完成同冻结模型B1/S128的正确完整Laya推理，逐步取得可解释的实际服务改善及资源预算。模型、层数、shape、独立gold/逐位或原LN容差、CPU/FPGA职责与静态模型信任边界均保持。正确性阻塞优先于吞吐扩宽；正确但服务较慢的实现可作为功能基线，不能把旧错误tanh的输出当等价gold。完整CPU/CSim、真实分段RTL、同runtime完整producer RTL与上板分别验收，阶段替代覆盖不等于最后两项已完成。

| 当前判据 | 可接受证据与选择方式 |
| --- | --- |
| 相同功能与身份 | 同模型/shape/输入、算术规则、输出范围、错误恢复和真实实现hash；改变内部实现后生成新身份，旧未变范围按身份复用 |
| 同口径服务改善 | 与已核基线使用相同接受→完成/末响应起止、冷暖/缓存和反压条件；记录总周期、有效bytes或MAC/周期、填充/排空、供数/反馈/credit/输出停顿。只得到reset-relative事件则照原口径记录，不补造命令耗时 |
| 首延迟与流水吞吐 | 冷/暖完整首请求延迟与完整请求完成间隔并列；仅模块测量时明确模块单位。有限序列遵守原N/成本帽，不以min II代替持续吞吐，不为当前未知项发明新的ms/reqs门槛 |
| 性能与资源取舍 | 相同资源下改善服务，或相同服务下降低资源/搬运可形成局部性能收益；收益须作用于已测瓶颈。首延迟/完成间隔/资源彼此有损益时分别列值并说明选型依据，不把局部收益称全图高性能或GPU超越 |
| 可部署预算 | 同一账列DSP/LUT/FF/BRAM/URAM、端口、buffer/身份metadata及shell余量；实际超容量/端口冲突仍淘汰或整改，UNKNOWN不当0。功能仿真与条件估计不证明物理fit/Fmax，整体OOC/P&R未恢复 |
| 远期参考差距 | 50ms/20请求每秒及10/20/40敏感性继续报告，超过参考不再单独淘汰。77.366613ms及2ULP属于旧错误叶子；新正确叶子的已测范围与全模型条件投影按§5.1，不能沿用旧服务率 |

基线复用优先：T1相同16行byte/wide A/B、T3相同ACT strict/fast及真实周期、T2 TM4既有完整shape局部算术、T4已核单row量化与双W供数分别作为各自范围基线。不同实现/不同工作量结果不能直接相除；新的共同producer边界须先取得自身正确运行和完整计时，再比较受影响改动。由实际服务参数形成的全请求调度模型单列为预测，板端性能未测保持未测。

### 0.2 下一段有界功能与性能路线

沿原T4/T5→T6→T7连续推进，不新建阶段项目或审核包。第1轮正确叶子与实际OOC已接受；第2轮add尝试现已取得实际OOC并按独立gold/RTL限定范围验收，正常模块服务周期减少37.883840%，实例仍单份。现在接完整真实GEGLU与当前完整推理，不追加无尽的标量微优化；并行生产连接使用同一工具锁。完整加速器路线如下，按owner和依赖直接执行。

| 次序 / 原任务 | 下一项具体工作与最小出口 | 必须保持的范围 |
| --- | --- | --- |
| 1 / T5正确服务到真实GEGLU | 复用`round1_02`同gold位级tanh，完成第2轮有界add尝试后，用完整Wi5248实际计算`u,v,w,t,z,h,r,s,y,gate`及2624输出；随后按§8.4.7实现一个单流同图空间流水，解决§5.1的标量服务瓶颈 | 保留每步F32、完整分支与原首错顺序；完整Wi入口可使用已冻结真实检查点，但z/tanh/GEGLU gold只作独立比较，不作DUT中间供数。先正确基线连通，空间流水不得阻断其生产功能集成 |
| 2 / T4–T5真实交接 | ACT K256/N2从实际F32流入口，经精确quant16、完整A发布/lease、真实双W LOAD、TM4合法row0 mask、PS/bias及512bit writer末响应退休。再把GEGLU2624实际输出送quant、Down读取，最终接上真实Wi Q8 writer | 按下文生产交接约束连续落实，不force READY或预置链内q/scale/PS/输出。ACT局部入口不代表前序Decision真实producer；Wi入口片段与包含Q8 Wi的片段分别登记 |
| 3 / T6–T7当前身份功能 | 将新bits tanh、quant16软件实现、Q8四row调度实际连入`laya_forward_full`/`full_tasks_*`当前路径，生成包含真实依赖的新build/布局身份，复用完整28 Encoder＋2 Decision＋scorer/ACT的持久四请求、141checkpoint及错误恢复；独立gold不改 | 新函数只存在于仓库但未由当前入口调用不算集成。CPU/CSim的DUT不能仍用宿主libm代替新bits实现；独立oracle继续用冻结libm。CPU/CSim不替代RTL或板端证据 |
| 4 / T6真实producer与性能 | 按§9先核实际候选成本；能落原帽的最小真实producer链才运行，超成本用既定分段RTL＋当前身份完整CPU/CSim及有容量约束的事件模型。对已接通范围建立首延迟/持续服务基线，按最大已测瓶颈选择一个有界改动，再核收益/代价 | 保留NOT_RUN_DEPENDENCY/NOT_RUN_COST和连续整层/整图未测范围；不扩服务器帽，不用理想FP替身或删检查制造提速 |
| 5 / 联合预算与后续部署 | 合并正确功能链及真实服务，比较现有最多两种几何/服务配置；允许较小、较慢但资源可解释的候选作为完整功能落点，再按瓶颈改善。把物理RAM/端口、FP和shell未知项列成部署验证清单 | 未获相应授权不恢复整体OOC/P&R/专项时序/上板，不拿源码属性当映射；50ms差距本身不阻断资源可行候选继续 |

阶段完成须说明功能覆盖、相对性能和部署剩余项；数值/接口失败按原合同修复，资源超限或无可检验改善时停止该具体假设。仅未达远期参考不视为整体工作失败，也不成为无限扩阵列/增加诊断的理由。以上新方向不追认旧失败、不改变已通过独立出口的范围。

**当前生产交接约束。** ACT owner在既有Q8模块维护`rtl/laya_act_production_v1.sv`及相应TB/Tcl，完整控制身份含`NumericIdentity/TaskContext/BufferRef`、源epoch和实际地址/长度；三口W/AUX LOAD不得由TB偷置READY。F32流按K256完整row顺序进入quant16，全部q/scale覆盖、数值合法且量化返回退休才发布目标A；Q8握手取得对应A/W只读lease，最后实际读/返回完成才释放，不能因控制发射结束提前复用。N2只接受合法lane mask，TM4其余row不得产生伪结果。bias与writer沿原数值/地址规则，完成必须等待最后物理B响应和全部语义债务0。受影响联合短例至少覆盖末F32错误导致A不发布、输出反压、活跃reset取消旧owner后的合法恢复；已有独立错误覆盖按原身份复用，不重跑全库。

GEGLU入口Wi5248拆成同row的U/G两个2624 plane。按[独立原参考](../../../tests/full_reference.py)的`gelu_scalar/geglu_row`顺序做7次FMUL/2次FADD及tanh：`u=a*U,v=u*U,w=1+v,t=c*U,z=t*w,h=tanh(z),r=1+h,s=0.5*U,y=s*r,gate=y*G`，常量位型与各次finite检查保持。全部2624成功、返回退休和实际目标写完成后，才能发布该row给quant；失败按原row/col/步骤优先级报告，未提交的目标A/输出保持无效，已接受流水排空，不将完成顺序当首错顺序。连接时只把检查点作为片段外部输入，内部值须由实际DUT产生。当前完整CPU/CSim由生产owner维护入口/build/Host依赖；vector owner独占`vector_full_compute.cpp/full_tasks_vector.cpp`及新bits依赖，冻结接口后由实际文件生成build preimage，不手填旧v4身份。

## 1. 固定数值与输入身份

固定真实GGUF SHA256 `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`；[v4 manifest](../../../build/model-cpu-embedding-ln-v4-20261010/manifest.json) SHA256 `093bd662096f8c539529072d09d33f3b5a7f666125e21adaaf7ece20348c5915`、build `147c8e8554927239ed5981bdde25861c`，B1/S128、request3/generation1为首个fixture来源。新微基准自身源码/接口独立hash，不冒充旧v4生产top的实现身份。

模型/shape/32元素Q8 group/相邻二叉归约、独立F32运算及R0顺序不变；LN沿原`layernorm_row_arithmetic`数学函数和原误差判据，禁止FMA/重结合/FTZ/近似倒数。119个FP边界中33个不符保留；真实输入触发基本运算差异即FAIL，不用LN最终容差覆盖。独立gold不来自DUT。

CPU raw来源复用[旧冷前端输入manifest](../../cpu_embedding_q8_validation_20261010/attempts/cpu_front_rtl_03/input_manifest.json)中真实CPU生产的STATE0/IO、当前包AUX以及独立`embedding_raw.f32.bin`/`embedding_norm.f32.bin`；准备脚本从该清单解析实际路径并逐项hash，禁止另猜同名文件。T2真实ACT/QKV参考复用[原独立生成器](../../../vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/make_real_fixtures.py)和其已通过fixture manifest；Wi/Down参考按同一独立`tests/full_reference.py`路径由实际GGUF与冻结全图输入检查点生成，不读新DUT输出作gold。

## 2. T1立即执行：16行raw/LN字节访问与宽块访问A/B

### 2.1 模块位置与边界

实现owner为Root指定的数据通路Sol。复用`vivado/module_design/layernorm_engine/`的`source/rtl/tb`，新增命名带`front16`的微基准源码/脚本；在该模块既有`source/design.md`/`source/results.md`链接本节和实际结果。不得修改旧阶段TB/生成RTL或生产全图入口来把S改成16，不复制整个原型工程到结果目录。

首个范围固定原B1/S128请求的row0..15，D=1024，真实raw 65536B、norm 65536B，gamma1024个F32。它是完整行访问/LN微基准，不创建FullRuntime、不设置生产owner READY、不生成LYRS成功帧，也不把局部CRC当全128行raw准入。TB仅提供真实CPU raw和只读gamma，norm必须由DUT实际生成。完整128行准入/owner链后续单独接回生产。

### 2.2 两个top与一致计算顺序

允许两个独立HLS top：`laya_front16_byte`和`laya_front16_wide`。两者具有STATE0只读、AUX只读、STATE1只写及OBSERVED只写四个独立BO角色；指针宽度/控制地址从实际生成RTL自动解析。微基准固定row0=0、rows16、D1024，STATE0/STATE1有效起点0，AUX gamma取当前manifest中的`emb_norm_w`真实offset（当前128B）；不提供改变生产B/S的控制参数。

byte版本以`uint8_t*`逐byte读取/写入LE F32，沿现有`full_read/full_write`的STATE0/STATE1语义，端口最大widen限制32bit；允许封装同语义固定端口helper，避免把完整controller综合进微基准，必须记录与生产helper的对应。wide版本对STATE0/AUX/STATE1使用`ap_uint<512>`显式64B打包/解包；OBSERVED仍32bit。两版均read/write outstanding=1，wide候选max burst=64 beats、不得跨4KiB；本轮不同时改变outstanding数量，以便解释A/B结果。实际位宽、burst、在途必须从生成端口与握手确认，pragma不算性能证据。

两版执行相同次序，首轮只改变访问实现，不改变CRC/LN算法或生产顺序：

1. 顺序读取全部16行raw，按LE byte顺序更新CRC32C并检查每个F32有限性；CRC参数沿原导入规则。CRC字节处理顺序/算法两版相同，不顺手引入并行CRC优化。raw不有限则停止进入LN，不发布成功。
2. 导入通过后读取完整1024 gamma F32并检查；gold来源是同一AUX。局部CRC只供独立TB比较，top不接受伪造的“已验证”输入标志。
3. 对每行再次从STATE0读完整1024 F32到片内row buffer，调用同一生产`layernorm_row_arithmetic(Op::LN_EMB, ...)`，保留eps、gamma、两棵归约树及独立算术。生成的LN算术配置两版相同；若工具实际调度不同，记录而不能全部归因访存。
4. 按row/col顺序写STATE1实际norm；byte写字节，wide将每16个F32打包为一个64B beat。写完所有结果后发诊断，完成必须等待全部输出/诊断真实B与适配器债务退休。

raw导入与LN消费各一次逻辑读，分别65536B，gamma4096B，输出65536B；不通过取消第二次raw读或融合导入与LN给wide版额外收益。wide每行可先burst读64个beat到有限局部buffer再做CRC/解包；行内缓存是候选真实资源，必须计入。第一轮不做多行计算并发、不改LN数值路径。

### 2.3 normal/pressure的精确定义

两种endpoint均使用相同字节内存映像、只读保护、实际ARSIZE/AWSIZE/len地址解释、R/B债务及每字节scoreboard；适配32/512bit而不改变有效数据。支持INCR burst，地址对齐、WLAST/RLAST、4KiB、AW/W/R/B稳定性必须自检。

| profile | 行为 |
| --- | --- |
| normal | 无人为hold；接收端一次一个读burst和一个写burst/B事务，已有事务结束后接受下一笔；保留真实ready/valid握手及最小事务切换空隙，不伪造零拍B |
| pressure | 继承旧前端的**最终LN输入R、最终norm输出B各一次hold**，用原`hold_count<=4`触发/递减语义；其它服务同normal。它不是QKV的每笔B_HOLD9 profile |

pressure的R目标是LN消费阶段包含row15/col1023最后F32的物理读beat，不能命中前面的raw导入扫描；B目标是实际包含最终有效输出byte65535的写事务。宽beat按覆盖地址区间匹配，而非照抄旧32bit末字地址；必须计数证明R/B hold各准确命中一次、实际等待长度及最终退休。原counter4的触发拍和计数拍按真实RTL记录，不只用参数值代替实测hold长度。两版遵守相同语义目标，最终首次done均检查全部物理及adapter债务零。

AW与W独立停顿/协议错误、非有限raw、坏gamma及reset恢复用短定向自检覆盖，不增加长A/B配置。错误例只定义此微基准错误与未成功输出范围，不声称覆盖FullRuntime生产owner恢复。

### 2.4 可直接实施的观测与验收

OBSERVED采用固定64个u32（256B），不足部分填0，不复用生产观测header含义：word0 magic=`0x31423146`（LE `F1B1`），1 version=1，2 status（0成功、1 raw非有限、2 gamma非有限、3 LN算术失败），3 failed row，4 failed col，5 local raw CRC32C，6 rows=16，7 D=1024；8/9 raw_import useful bytes u64，10/11 LN_read useful bytes，12/13 gamma useful bytes，14/15 output useful bytes；16..63保留0。首错row/col成功时为`0xffffffff`。LN返回的原错误详情保存在TB日志/额外内部探针，不能仅以status覆盖定位。

cycle统计由被动TB完成，不加入每元素AXI诊断：实际top启动接受→首次done；raw导入首/末R、gamma首/末R、每行LN输入首/末R、算术start/done、输出首W/末B、diagnostic末B。算术事件从生成RTL解析或稳定的只读探针捕获，不以长时间无AXI当算术挂起。报告各阶段区间与可重叠部分，重叠停顿不能求和冒充总周期。

逐口记录AR/AW事务数、R/W beat、len分布、最大在途、R/B hold、stall，区分`bus_lane_bytes`、按SIZE的传输字节和独立地址scoreboard的有效唯一字节，避免32bit总线上的byte操作被计成4B有效吞吐。比较同profile的完整command周期与读写有效B/cycle，条件MHz换算单列。

正式配置恰为byte-normal、byte-pressure、wide-normal、wide-pressure；两个top各生成一次所需功能RTL，normal/pressure复用同一制品。旧前端03仅作行为/压力/数值和成本来源，不是这两个新微基准的A/B周期基线。先CSim完整16行，再每种新RTL≤120s pilot核算正式成本；有实际预算后可在8GiB/3600s/40M帽内连续完成四配置，无逐次审核。

通过必须同时满足：全部16384个raw/F32与独立生产值一致；全部16384个norm按原LN判据；局部CRC独立一致；输入只读、输出有效覆盖每byte一次、其它区域sentinel；OBSERVED全字段；真实hold命中与首次done零债务；guard exit0无ERROR/FATAL。宽版功能通过但正常profile有效访存服务未改善，记功能PASS/性能未改善并依据探针定位，不宣称提速完成。只使用本例实际资源/服务，不从16行外推完整128/全图已通过。

### 2.5 生成适配器配置与最小债务观测澄清

2026-10-10核查两版`layernorm_engine/rtl/front16_{byte,wide}/hls/syn/verilog/laya_front16_{byte,wide}.v`的四个实际m_axi实例：STATE0/AUX均显式`CH0_NUM_READ_OUTSTANDING=1, NUM_READ_OUTSTANDING=1, NUM_WRITE_OUTSTANDING=0`；STATE1/OBSERVED均显式`CH0_NUM_WRITE_OUTSTANDING=1, NUM_WRITE_OUTSTANDING=1, NUM_READ_OUTSTANDING=0`。各m_axi模块声明中的CH0缺省值2已被上述实例覆盖，未启用方向的CH0值16也不构成活动通路。两版沿`load_unit_0/store_unit_0`和`bus_read/bus_write`传递这些参数，当前不存在由该缺省值导致的两版outstanding不一致，无需改DUT或重生成HLS。实际attempt必须绑定所编译文件及override，不只grep模块声明。

须分别报告四种量：**配置的总线事务上限、HLS用户请求队列容量、物理握手实测峰值、首次done未退休债务**。两版读侧`USER_MAXREQS=7`、写侧为4，表示适配器可以缓存用户请求，不等于7/4笔已在AXI总线上接受的burst；它不把本例总线outstanding目标从1改成7/4。`front16_axi_memory.sv`的`ARREADY=!rd_active`及`AWREADY=!wr_active&&!b_valid`、相应末R/B退休状态，结合实际绑定的源码和非零合法事务计数，可推导活动方向物理峰值恰为1，未活动方向为0。这是**端点约束加握手计数推导**，不能把原日志硬编码的两个`max_*_outstanding=1`称为计数器实测，更不能由它推出adapter内部债务清零。纯打印或配置解释修正不要求重跑长例。

最小被动探针只绑定每个`dut.gmem_<role>_m_axi_U`的`I_CH0_*`用户边界及已有外部AXI边界，不改生成RTL，也不要求逐个扫描所有内部FIFO。此处`I_CH0_ARLEN/AWLEN`是正的**用户元素数**，不是外部AXI LEN的beats减1；当前byte的STATE0/AUX/STATE1用户宽8bit，wide对应512bit，OBSERVED两版均32bit，沿实际端口解析而不硬套总线字节数。

| 边界/检查 | 最小充分记录与首次done条件 |
| --- | --- |
| STATE0/AUX读 | 每次`I_CH0_ARVALID&&ARREADY`累加用户LEN，每次`I_CH0_RVALID&&RREADY`减1；保存请求/返回数和最大未返回元素数，全部LEN必须合法且读债务不得下溢。首次done此差为0、`I_CH0_RFIFONUM=0`，并且`I_CH0_ARVALID/I_CH0_RVALID`及外部ARVALID均为0 |
| STATE1/OBSERVED写 | 分别计用户AW请求数、AWLEN总和、W握手数、用户B握手数。首次done要求`AW请求数−用户B数=0`及`AWLEN总和−W数=0`，`I_CH0_AWVALID/I_CH0_WVALID/I_CH0_BVALID`及外部AWVALID/WVALID为0。AW/W独立，W可先接受，不能以中途有符号AWLEN−W差为负错误拒绝合法时序；B不可凭空返回 |
| 外部物理债务 | 复用现有AR→全部R、AW→全部W/B的真实scoreboard、read/write活动状态、hold与首次done物理`debt_zero`。可另用AR−RLAST及AW−B记录事务峰值；同拍加减须合并更新，不能两个NBA覆盖 |
| 守恒推断依据 | 同一生成adapter只由已接受用户请求产生外部动作，读返回对应请求长度；对合法正长度写请求，`store_unit_0`的用户B仅能由`in_AXI_BVALID`进入`fifo_ursp`后产生，实际bus_write对拆分burst完成响应聚合。由实际源码绑定该映射，加上述双边界守恒、无pending valid和物理零债务，可证明无尚需消费/发出的事务；不要求缓存旧数据、指针或静态credit寄存值全为0 |

所有终态在首次观察到ap_done的**同一采样边界**保存，统一处理该拍握手并在稳定时相检查；不得额外等一拍/下一次done才取得零值。若生成路径、LEN语义、返回聚合或边界信号无法核定，则该推断不成立，改用对应实际FIFO valid/请求状态的直接探针并保留未观测项。探针采样/打印/后处理修复属于原合同内工作，Sol可连续处理。

已完成配置若保存了足以覆盖上述用户/物理边界的完整握手或波形，可离线复算并绑定原run身份，无需重跑；若只有当前外部总数/数值PASS，则保留该数值和物理范围，adapter首次done标`NOT_OBSERVED`，不能追补成PASS。优先将被动探针用于尚未执行的pressure配置；已完成normal仅在确实缺少该验收证据时补跑受影响配置，不因硬编码峰值打印本身重复四个长例。新探针配置的通过不自动追认旧运行已观测内部债务。

## 3. T2立即执行：精确整数树和signed packing

**§3.1–§3.4现在可执行，不需等待TM4集成设计。** 计算Sol独占`vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/`受影响源码/RTL/TB及该模块design/results章节；新候选用独立module/file名称，旧基线文件及冻结attempt不改。Root协调静态编译/仿真token；T1重工具在跑时，先轻量RTL/脚本实现及受控短CPU穷举，不启动第二个HLS/静态/RTL运行。

### 3.1 不变的八通道整数树接口

以现有`rtl/tm1tn8_integer_tree.sv`为基线：`clk/rst_n`；输入`req_valid/req_ready`、`req_tag[TAG_W-1:0]`（默认160）、`req_old_ps[255:0]`、`req_a[255:0]`、`req_w[2047:0]`；输出`ret_valid`、同宽`ret_tag/ret_old_ps`及`ret_dot21[167:0]`。A包含32个signed INT8，向8个W列广播；W按`lane*256+k*8`取元素，dot按`lane*21`放置signed21结果。

保持6个寄存边界：product、16/8/4/2/1相邻加法。寄存宽度分别signed16/17/18/19/20/21，正负号扩展明确。接受/返回时刻完全沿现有integer_tree_tb的边沿口径，与原模块lockstep比较；不能因NBA观察差异手改期望延迟。`req_ready=rst_n`，每拍可接受一请求，无`ret_ready`；调用方必须事前保留结果容量。本轮候选不得新增组合反压、改变六级返回延迟或丢弃bubble/tag/old_ps。

同步低有效reset清除全部valid，reset时接受被禁止；pipeline旧数据可不清，但reset后不允许有效返回旧tag。连续流、随机bubble、reset清空、tag高低位变化、每lane不同W都必须覆盖。可组合`VALID`随机流但不能只以固定16次示例宣称稳定II1，短例连续至少256次接受并逐项scoreboard核对。

整数范围验证涵盖全部signed INT8 [-128,127]（比当前合法Q8 payload的[-127,127]更宽）；32项最坏正和524288，signed21可精确容纳。扩大整数测试域不改变生产Q8对-128的原合法性规则。

### 3.2 候选A：product保持DSP意图，树加法使用LUT

新增`tm1tn8_integer_tree_lut`，端口/六级延迟与§3.1完全一致。product仍为独立8×32个signed8乘法，保留DSP映射意图；五层相邻树加法显式采用LUT/carry逻辑映射意图，不能让工具把加法再合进DSP的PCIN路径。允许局部子模块/`use_dsp="no"`属性，但必须审计作用范围，不能误把乘法也赶到LUT。

功能通过只证明精确等价和接口服务，结构审计只证明意图/生成结构。旧320DSP由256乘法+64树加法构成；候选理想可移除64个树DSP，**未取得实际新映射报告前不写“已省64DSP”**，更不能把LUT/布线代价记0。本轮不因确认资源而启动OOC/P&R；先保留结构证据与资源条件。

### 3.3 候选B：shared-A的两列signed packing，独立验证

先实现独立pair primitive/CPU参考，再形成与§3.1同接口的`tm1tn8_integer_tree_packed`候选。每个k把列(0,1)、(2,3)、(4,5)、(6,7)配对，共用同一个activation a；这不是把任意两个不同activation的乘法塞入一个DSP。

冻结数学构造，使用**2^17间隔**：对signed8 `a,w0,w1`，形成signed27 `X=(sign_extend(w1)<<17)+sign_extend(w0)`，signed18 `Y=sign_extend(a)`，精确signed45 `P=X*Y`。令`p0=sign_extend_16(P[15:0])`，`h=P>>>17`（算术右移），`p1=h+(p0<0 ? 1 : 0)`；在证实范围后将p1取signed16。必须先进行有符号扩展和加法，禁止用未经证明的位拼接替换X，或用逻辑右移提取负的高乘积。

理由：`P=(w1*a)*2^17+(w0*a)`，`p0=w0*a`位于signed16且绝对值<2^17；p0为负时算术右移对高项借1，因此补1恢复`w1*a`。实现须独立验证这个关系，而不是让gold调用相同decode函数。packing构造/修正LUT、寄存与布线也属于候选资源；只有乘法真映射单个27×18 DSP时才可条件按两产品/DSP预算。

先CPU以int64/任意精度独立乘法对全部256³=16,777,216组(a,w0,w1)穷举，按a或w分块控制内存；比较p0/p1与`a*w0/a*w1`，另查X/P/p1范围和符号。该检查在4GiB/120s轻量帽内优先执行；超帽保留进度并改用同等完备的分块/位向量方法，不降为少量随机后称穷举通过。输出精确checked tuple数、首错输入/各中间位型及hash。

RTL pair短例检查边界组合、定种随机、正负跨项、p0=0/负值/最大正值及所有256个a的代表W组合，并与独立乘法scoreboard比较；随后8lane/GS32树lockstep核全部dot。默认维持原六级树和product寄存边界；若packing路径需要额外级才能满足功能/实现结构，先保持为独立primitive证据，在本设计原位明确延迟/tag/credit调整后才接入，不能悄悄改变旧R0接口。

候选B最初不依赖候选A：保留原整数树映射意图，分开记录packing自身效果。两者各自正确且联合资源账需要时，才允许第三个组合候选；不把两项同时改变后的结果写成每项单独都验证。

### 3.4 可连续执行的测试、数据与R0边界

按顺序执行：独立CPU packing穷举/整数范围检查→候选A短整数RTL→候选B pair及整树RTL→必要的真实ACT/QKV group重放。已有integer_tree_tb、arithmetic_real_tb及独立fixture生成器可按原脚本/内容引用并派生新候选TB，不改冻结结果。候选模块均与原integer_tree及独立int64 dot同时比较，不能只做两个可能共错RTL的A/B。

真实ACT保留K256/N2/1行，8组并检查tail mask；QKV保留K1024/N3072，先1行再既有4行独立量化/中间gold。直接group重放必须显式标“已量化真实fixture”，不称HBM LOAD/FPGA量化/完整RUN通过。R0接入时复用原每通道1转换、2独立FMUL、1PS FADD和group顺序，比较有效lane的dot、dotf、scale product、term、每次PS commit及最终输出；33个已知FP边界失败不能隐去。

每种映射固定一套短算术配置，正常/bubble/reset作为同一自检序列；必要修复在原帽内连续进行，不设两次修复门。资源/性能假设最多两轮，未改变假设的TB/实现修复不计新候选。局部PASS的范围是精确整数与接口/R0 group服务，完整QKV/Wi/Down HBM链及多行阵列仍分别记覆盖。

### 3.5 TM4算术/PS微基准：四行广播与新标签

TM4先做独立`tm4tn8_*_v1`算术/PS模块，仍由计算owner维护。范围为4行×8列×GS32，4个A组独立、同8列W广播，32个独立INT/F32/R0服务；不以串行8lane冒充32lane。旧joint DMA仅支持ACT/QKV、K≤1024/N≤3072；旧tag group6bit、tile9bit以及384项busy数组不能容纳Down G82或Wi T656。因此本微基准直接接**明确外部重放的已量化fixture**，不直接扩旧DMA的shape白名单，也不声称FPGA量化、HBM LOAD、bias/writer或完整RUN通过。

| 配置字段 | 冻结含义 |
| --- | --- |
| K/N/G/T | K、N用u16；G=K/32的**总数/完成进度用u8**（必须能表示128），group索引及tag仍u7（0..127），T=ceil(N/8)用u10；原四shape微基准证据保留，当前完整七shape及输出接口见§3.7 |
| rows/rowmask | rows为1或4；有效rowmask分别0001/1111，local row是0..3；首例用原请求row0..3，ACT单行；全局row0作为配置身份记录，不藏在2bit local row里 |
| 接受粒度 | 一个stripe包含同一tile/group的全部活跃行；ready/valid原子握手，不允许只接受其中几行后重发整stripe |
| issue数据 | `a8[1023:0]`按row×256+k×8；`sa[127:0]`按row×32；共享`w8[2047:0]`按lane×256+k×8、`sw[255:0]`按lane×32；group[6:0]、tile[9:0]、lane_mask[7:0] |
| issue身份 | 显式输入`issue_identity[95:0]`、`issue_version[3:0]`、`issue_sequence[26:0]`；identity必须等于已接受`config_identity[159:64]`，version必须1，sequence必须等于从0开始的下一期望值；每次成功stripe接受才增加序列，task结束前禁止回绕；每row由wrapper填local row/预约slot |
| 返回/commit | 每row独立`valid/ready`、tag192、tile10、mask8、bad_mask8、phase24、next_ps256；四行合计32个F32/拍。各row可独立停顿，payload/tag在valid且!ready时稳定 |
| trace | 每row沿用D4物理slot/独立ack；`trace_mask[3:0]`限定活跃行，selected lane每row3bits且必须有效。trace/ack携完整192bit tag，不能只按slot匹配 |

新tag固定192bits，**旧160bits字段位置全部保留**；bit160=group[6]、161=tile[9]、[167:164]=版本1，[163:162]和[191:168]保留0。完整group=`{tag[160],tag[16:11]}`，tile=`{tag[161],tag[25:17]}`；row[27:26]、result slot=`{tag[63],tag[4:0]}`、trace slot[6:5]、trace enable[7]、trace lane[10:8]、effective lane mask[35:28]、sequence[62:36]、原任务/epoch身份[159:64]。所有tree、FP metadata、reserved store、trace、PS及scoreboard全程携192bits并比较完整身份；旧FP restore的固定160bit寄存与6/9bit提取不可不改就复用。只扩元数据/索引，不改现有F32 IP配置、数值路径或六级整数树延迟。trace payload原group word[223:192]改为完整u7零扩展，仍保持256bits。

每stripe身份必须由外部端口实际检查，不能仅从config内部复制后声称已覆盖错身份输入。接受前同时检查上述三字段和shape/order；tag的[159:64]/[62:36]/[167:164]来自通过检查的issue字段。`config_identity[63:0]`不作为外部逐stripe身份，tag低位由本地slot/row/group等重建。valid且!ready期间全部issue字段稳定；拒绝不增加accepted_stripes/sequence、不占任何row算术credit。TB在独立短任务中分别注入identity任一高位改变、version≠1、重复/跳跃sequence，并检查唯一拒绝、零新算术发出、已有债务排空及随后新config恢复；内部返回错tag/trace ack错tag是另外的短故障边界，不能替代外部检查。非法tile先校验再索引PS/busy/poison数组，拒绝路径不得先越界读。

四row各自Q35 result、D4 trace，合计140个result和16个trace credit，资源账按实物支付；FP返回没有ready，所以stripe issue前必须同时预留全部活跃row所需容量。一个row被阻塞时，后续stripe整体等待；已接受stripe的其它row仍可退休。inactive row不占credit、不返回、不写PS。每row各自保持`free+reserved+returned=35`，不能借另一个row的空slot隐藏溢出；trace状态另计。预约到算术返回再到commit/ack的路径以及错误排空按原Q35/D4状态机扩展，slot不因FP out_valid出现就提前归还。

PS采用逻辑`ps[row][lane][tile]`，最大4×8×656×F32=83968B；32个lane bank，每bank1读/1写的服务意图，busy/poison/group进度按row/tile独立。该容量不含Q35 payload、tag、trace、A/W缓存、buffer复制或工具银行开销。每接受一stripe可读32个old_ps并最终写32个next_ps；group0用+0，后续group只能在同(row,tile)上一commit实际写回后读取。baseline不依赖同拍write-through/bypass：同址commit与新issue同拍时推迟issue到下一拍，明确计入反馈间隔。

**TM4存储结构预读（2026-10-10，非阶段验收）。** 当前`tm4tn8_microbench_v1.sv`的PS及poison数据没有reset/config整片清零；reset/config只清每row/tile的progress和pending。group0不读旧PS/poison，old_ps固定+0；每个有效lane的group0 commit写新PS并清poison，数值失败则置poison并禁止该lane后续更新；progress只在commit或已poison的整row跳过时推进。因而新task依靠进度/有效语义隔离旧数据，而不是依靠RAM数据全清零。验证应观察在PS保留旧值或未知值时group0仍用+0、group>0只读取已commit的有效lane，以及reset后旧FP/trace返回不会使新task有效；不能为消除仿真X而添加整片PS同步清零。

实际PS读取在`always_comb`中按issue_tile选择，写入在commit握手的时钟过程，因此目前是**32个逻辑1异步读/1同步写bank**的行为结构。83968B仅为逻辑数据容量；这种读法不能直接声称原生BRAM/URAM同步读已实现，实际LUTRAM、FF/mux或工具变换均为UNKNOWN。单个逻辑bank也不等于单个物理RAM块。当前短算术/四shape功能运行可继续；若后续需要同步RAM候选，应保留显式读返回与整stripe身份/容量预约，重算反馈和II，再在本合同原位定义受影响延迟，不能只加`ram_style`后沿用异步读实测性能。

| 当前声明存储，四row合计 | 逻辑容量/端口事实 | 资源计费边界 |
| --- | --- | --- |
| PS | 671744bit=83968B，32×656×32bit；每bank组合读及独立commit写 | 未复位数据；物理映射UNKNOWN，不能填成已用某数量BRAM/URAM |
| PS进度/有效控制 | progress18368bit、pending2624bit、poison20992bit；每row issue与commit可能写不同tile | progress/pending全表同步清零，poison按有效lane首次commit重建；这些多写端口/复位控制不包含在PS数据容量中 |
| 四份Q35 | result_ps/bad/phase共40320bit；owner tag/tile/mask/trace/trace_slot共29820bit；result_state280bit | payload返回写、commit寄存读；owner在issue写并同时供ret校验与commit读取，部分字段还供trace释放，不能把多读需求算成一个普通1R1W RAM；state为issue/return/commit多地址状态更新 |
| 四份D4及busy | trace_data4096bit、trace_owner_tag3072bit、trace_state32bit；额外busy2624bit | payload/owner不清零；owner供return校验、ack校验和drain读，state/busy复位清零；与wrapper pending是两份实际存储，不能只计一份 |
| FP恢复侧独立暂存 | 每row35项meta_tag/mask/phase/trace，共67200bit；32项slot FIFO共768bit | 这是Q35结果存储之外的另一套在途元数据，组合读、返回时写；有效位/计数器reset，数据不reset。其余FP移位寄存、输出保持寄存和控制另计 |

Q35/D4的实际payload仅由已预约、完整tag匹配的返回写入，并由RD/TY/TW等状态控制可见性；复位清state、valid、credit与busy，保留旧payload符合本合同。各row result payload为一返回写/一commit读的服务意图，真实是否推断RAM仍未知；标签多读与小状态表可以显式用FF/复制RAM实现，但必须如实计费。当前`just_valid/prior_valid`还在commit后保留两个同tile阻塞观察拍；无其它阻塞时，在commit边沿c之后c+1/c+2不能重发同tile，c+3才可能接受，不能按“下一拍必发”代入容量预算。该保护不改变数值顺序，实际反馈以握手事件为准。

本预读不要求打断已准备的四shape仿真、不新增资源综合或逐次放行。计算owner只需在模块design/results把上述逻辑容量、端口与物理UNKNOWN写清，并利用既有短reset/重复config场景记录有效性不依赖PS清零的观察；已绑定且覆盖相同断言的证据可以复用，缺少观察只补短例。若发现真实非法读/旧epoch写回则按普通实现错误连续修复；任何改变PS读延迟/同步银行接口的候选由本合同集中修订后接入。待T1/T2实际结果齐备再统一验收。

issue顺序固定group外层、tile内层、四row并行；每个(row,tile)的group必须0..G−1升序，严格检查mask与tile尾部。输出PS提交按各row的预约顺序，跨row完成先后可以不同。最大T656支持Wi；Down G82必须覆盖group63→64→81，Wi覆盖tile511→512→655。ACT T1会受PS反馈限制，不能用QKV的大tile窗口II1结果替代ACT服务率。短无阻塞例在足够独立tile窗口中连续至少256次stripe接受，检查32lane同时真实计算和返回，bubble/reset/一行commit阻塞/trace ack阻塞另作同一测试内短定向场景。

数值错误phase沿原R0：0 scale输入非法、1 scale product非有限、2 term非有限、3 PS add非有限，4表示无错误。独立first-error次序为(tile,row,lane,group,phase)，u64 rank沿原公式`(((tile*4+row)*8+lane)*(G+1)+group)*5+phase`；不能继续使用旧6bit group拼接。bad_element沿`row*5248*128+(tile*8+lane)*128+group`，现有G≤82仍可容纳。坏lane进入poison后不更新PS、不发布成功final，后续该lane跳过但计清输入/退休；其它lane继续，最终按规定次序选择首错，不能以返回最快的错误代替。bias尚未接入；未来bias错误用group=G、phase=0并与PS统一排序。

配置只在idle且全部旧债务零时握手接受，保持到任务终态。协议错误（错身份/顺序/版本/非法tile等）将该stripe握手归为拒绝事件，禁止发出它的新算术，记录首个协议故障并停止接收后续stripe，排空已接受算术/trace/commit债务后发布失败终态；不能等待被拒绝后再也不会发出的全部预定stripe而死锁。数值错误则继续处理其固定输入范围以保留规定首错次序。数值错误与协议错误分别留证，失败不得发布成功final。reset清全部有效/预约/busy状态，所有内部IP同步reset；新任务不得接受旧tag返回。成功完成条件包括预定stripe数全部接收/处理、全部row的Q/D归还、PS最终commit及所有微基准输出握手完成；失败也须先归还已接受债务。终态保持到显式新配置/清除或reset，无物理AXI的本例不能报告“HBM债务通过”。

### 3.6 TM4真实输入与分步准入

Wi/Down准备**完整K/N**独立四行fixture：Encoder layer0 Wi K1024/N5248来自真实LN_FFN输出，Down K2624/N1024来自真实GEGLU输出；`tests/full_matrix_fixture.py`中的历史检查点别名分别为`enc0_mlp_norm`、`enc0_gated_product`，须用`tests/full_reference.py`核实际内容和v4 B1身份，不能把历史B2例改标签当本次B1 PASS。记录所有q/half scales/中间F32与源检查点hash，FPGA动态quant不在本例覆盖内。

计算owner可先完成接口编码与fixture准备；进入TM4 RTL前须有所选§3.1–§3.4候选的整数与必要R0短例证据。最多选择已通过的两个映射，不跑所有组合。先ACT单行与短四行正常/压力/故障边界，再QKV→Wi→Down完整K/N四行；按每种新范围pilot≤120s判断原8GiB/3600s/40M帽，无逐例审批。任何不满足成本的完整矩阵保留`NOT_RUN_COST`，可继续已授权短边界但不改label为完整通过。

正式数值覆盖每个有效dot、dotf、scale product、term、每group的PS和最终PS；ACT tail lane、QKV四行隔离、Wi高tile、Down高group均必查。bias/最终out以及真实HBM供数在T4单独接入；本例最终PS与完整矩阵输出的区别应出现在结果scope中。已有错误边界无需为每个真实shape重复长跑。

### 3.7 七种真实Q8形状的物理bias/输出合同（2026-10-11集中修订）

**目标为122张Q8矩阵的共同生产输出边界，当前只定义/授权实现，不将ACT06扩成七shape通过。** 核查来源为[`tm1tn8_bias_output.sv`](../../../vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm1tn8_bias_output.sv)、[`tm1tn8_axi512_writer.sv`](../../../vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm1tn8_axi512_writer.sv)、[`laya_act_production_v1.sv`](../../../vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_act_production_v1.sv)及生产[`write_linear_output`](../../../hls/operators/full_tasks.cpp:212)、[`full_f32_address`](../../../hls/common/laya_full_memory.cpp:285)、[`f32_address/qkv_address`](../../../hls/common/laya_memory_map.cpp:35)。旧bias仅384tile、tile9/n0u12、G≤63及23bit rank；旧非QKV writer只有`base+col*4`，没有多行/批步长。保留旧模块及ACT06冻结身份，在同一RTL目录新增`tm4tn8_bias_output_v1`、`tm4tn8_axi512_writer_v1`和必要adapter；不得静默重解旧288/320bit包。13 BO的Host ABI、布局与既有输出位置不改。

| K / N | G总数 / T总数 | 合法末tile / 最后n0 | 尾lane mask |
| --- | --- | --- | --- |
| 1024 / 3072 | 32 / 384 | 383 / 3064 | ff |
| 1024 / 1024 | 32 / 128 | 127 / 1016 | ff |
| 1024 / 5248 | 32 / 656 | 655 / 5240 | ff |
| 1024 / 4096 | 32 / 512 | 511 / 4088 | ff |
| 2624 / 1024 | 82 / 128 | 127 / 1016 | ff |
| 4096 / 1024 | 128 / 128 | 127 / 1016 | ff |
| 256 / 2 | 8 / 1 | 0 / 0 | 03 |

**控制及实际端口。** 单时钟`clk`、同步低有效`rst_n`与TM4/缓存/AXI取消域一致；全配置端口`cfg_valid/ready`锁存一个独占command。`cfg_K/N:u16, rows:u3(仅1或4), row0:u16, batch:u8, op:u8, G_count:u8, T_count:u10`必须与上述白名单、TaskContext及合法行范围一致；G/T由K/N复算，不接受调用方不一致值。当前rows只接受1/4，对应rowmask0001/1111，保持现有TM4调度；本次不增加2/3行配置。group索引/192bit TM4 tag仍u7；G/next_group/完成计数u8以表示128，bias的虚拟group=G不得塞入7bit算术group字段。所有tile及覆盖/加载/完成计数u10可表示656，n0u13可表示5240；地址中间运算至少u64，物理base加法用65bit核溢出。

配置同时带`cfg_numeric_identity[671:0]`、`cfg_linear_context[95:0]`、`cfg_source_ref/cfg_a_ref/cfg_ps_ref/cfg_dst_ref[63:0]`、真实W slot/epoch及其已注册model identity记录；完整BufferRef包含id/bank/region/epoch，不以epoch非0代替合法owner。独占command表驻留这些完整记录及output两路`base/span:u64`、layout模式、`row_stride_bytes/batch_stride_bytes:u64`。表由生产controller的实际FullOwnerRecord/高水位生成并核对：A/W来源READY且身份/shape匹配、PS和dst已合法claim为FILLING或规定的EXCLUSIVE_RW、task递增、epoch为下一合法值而非任意非0。bias/writer不自行伪造claim或提升owner状态。cfg握手后直到两路writer、FP、所有输入/源lease和错误退休全部清零，表和地址映射不得更换。

三个局部stream均为`data[415:0], valid, ready`，同一命令所有包高位`[415:288]=owner_tag[127:0]={dst_epoch:u32,W_epoch:u32,A_epoch:u32,linear_task_id:u32}`，必须与驻留完整表逐字段一致；该tag是独占表的句柄，不是NumericIdentity替代品。不同NumericIdentity不得与旧表债务重叠；复位后按下文取消域处理。包保留位必须0，valid且!ready全payload/tag稳定，错误握手可以消耗用于报告但不得发算术、写缓存或占新返回credit。

| stream / 方向 | 低288bit编码 | 顺序与检查 |
| --- | --- | --- |
| `bias_in`，真实W cache→bias | F32×8 `[255:0]`；tile `[265:256]`；mask `[273:266]`；kind `[274]`（0无bias/1独立FADD）；last `[275]`；`[287:276]=0` | tile严格0..T−1且恰一次；mask按N计算；last等价tile=T−1；有效bias必须有限；无bias及无效lane payload规范置0 |
| `ps_in`，TM4 final-PS adapter→bias | F32×8 `[255:0]`；tile `[265:256]`；localrow `[267:266]`；mask `[275:268]`；badmask `[283:276]`；last `[284]`；`[287:285]=0` | 仅最终group退休后的PS；tile升序、每tile活跃row升序，last仅(T−1,rows−1)；mask精确、bad⊆mask；检查完整TM4 tag及对应PS owner后才能组包 |
| `scatter_out`，bias→writer router | F32×8 `[255:0]`；n0 `[268:256]`；localrow `[270:269]`；mask `[278:271]`；last `[279]`；`[287:280]=0` | n0=8×tile，合法且8对齐；mask精确，n0+有效lane<N；row/task/order须一致；qkv/row0/batch从稳定cfg取，禁止从旧包位段误解 |

TM4四row返回可独立停顿，adapter保存至多一个tile的4份最终PS（4×416=1664bit，另有valid/owner/order），按上述顺序排出；不能假设实际返回有序。next tile不得覆写未消费槽，stall回传到final PS commit；早期group仍按原Q35/PS规则退休。不提前归还尚未复制到本adapter的PS/返回容量。没有bias的列直接透传原位型，存在bias的列执行**一次独立binary32 RNE FADD**并finite检查；不得合并进最后group FADD或改成FMA。现有native FADD只能在已验证的数值域使用，新增数据若触发既知FTZ/subnormal差异必须采用既定精确适配并按同gold修复，不能靠扩大容差接受。

**bias精确适配边界澄清。** 保留8个既有native FADD及每lane真实valid债务；任一输入为zero/subnormal或两者最大biased exponent<25时，走独立精确align-jam/加减/normalize/RNE位适配，native仍接安全dummy并等待实际返回，helper结果/tag必须对齐原独占返回槽。双normal且maxexp≥25时任何非zero差至少为最小normal，可走已验native正常域，overflow仍按原finite错误处理；精确抵消+0另定向检查。maxexp≥24不足：`0c000000 + 8bffffff = 00400000`为subnormal，不能交FTZ路径。短实际RTL用独立gold核该例及交换/两符号、exp24同级邻数、exp25跨级边界、minsub、±0、ties/sticky和RNE进位；不改旧R0pkg/gold、不增加FP/slot，额外逻辑实际计费，150MHz仍待物理证据。

**存储和有限服务。** bias为8×656×32=167936bit=20992B，加656bit kind、覆盖/metadata及端口开销；有效bias无需每次reset清数据，完整按序加载成功后才置`bias_loaded`，缺/重复/非法tile均不发布。可实现8个每lane同步读bank（每bank656×32），在接受合法PS时预约一个完整TN8请求槽，下一拍取bias；不能在合法性判定前组合索引非法tile。一次只允许一组8lane bias add在途，加一份不可变待输出416bit返回槽；每lane launch/return各自计债、只等待活跃且未poison的lane，返回全齐才转输出。没有空结果槽就停止接受PS，不丢不可反压FP返回。不声明II1；配置、同步读、FP延迟与输出stall均实测计费。

每个512bit writer保留原有界结构：一个持有tile、一个组包beat、一个不可变AXI事务，outstanding=1；双QKV shard独立配置base/span，非QKV只使用对应的实际dst BO。任意AW/W/B反压保持事务及tag稳定，AW/W各一次握手，只有匹配B才还债；所有64B AXI beat必须完整位于已分配物理BO内（即使尾WSTRB只写8B），有效4B还须位于逻辑dst区域。提供`cfg_bo_base/span`与`cfg_region_base/span`两层边界或等价经证明的配置；不能把逻辑ACT8B span误作64B物理BO大小。`flush_valid/ready, flush_done, debt_zero`及`fault/status/first_error_rank:u64/first_bad_element:u64`可直接观察，末packet的last只触发flush意图，不代替真实末B完成。单beatAWLEN0/AWSIZE6，WSTRB仅对应mask中的有效F32，未写byte和周围sentinel不变；所有shape的尾处理沿同一公式，ACT只写8B。

**地址须与现有生产布局逐lane一致。** region_base是实际物理BO base加原`span()/full_f32_address`区偏移，禁止增加第二份相同偏移。非QKV为`region_base + batch*batch_stride + (row0+localrow)*row_stride + (n0+lane)*4`：HIDDEN/TMP/ATT_OUT为row_stride4096、batch_stride1024×4096；WI为20992/1024×20992；DEC_FF为16384/1024×16384；SCORER_ACT为4096/16×4096；ACT_LOGITS为8/8且row必须0。shape1024/1024不能单独决定layout，必须结合op/dst region/row_space验证。QKV令n=n0+lane、plane=n/1024、head=(n%1024)/64、d=n%64、shard=head%2，物理relative=`(((((plane*2+batch)*8+head/2)*1024+row0+localrow)*64)+d)*4`；保留固定2批/1024token容量步长，运行B1/S128只限制合法索引，不把physical stride改成B/S。row0+localrow先用扩展位宽求和再验S/16/1边界，禁止10bit溢出回绕。所有有效lane先算64bit地址并核BO/region边界与shard，再进入pack，不凭首lane地址猜整tile。

**首错、owner与失败职责。** 与原TM4 source-order一致，用完整unsigned64运算`rank=(((tile*4+row)*8+lane)*(G+1)+group)*5+phase`，算术group0..G−1/phase0..4，bias为group=G/phase0；bias不得保留旧G≤63门或23bit拼接。原bad_element编码仍为`row*5248*128+(tile*8+lane)*128+group`，用64bit算式保留，G128是数值加128而非字段拼接（可能与下一列编码相同，排序依赖rank，不靠bad_element）。controller合并TM4与bias候选取最小rank，保留原detail/数值错误类别；不得用最早返回覆盖更早源位置。发现数值错误不跳过仍可能更早的未完成检查；坏lane/坏tile不发成功packet，已写成功前缀只是无效目标中的内容。协议/owner/tag错误拒绝且停止新不可信输入，保留首个协议错误；B错误按原IO错误类别，不伪装数值rank。

只有完整rows×N覆盖、TM4所有group/FP/Q35/trace债务退休、bias输入/读/FP/返回槽清零、writer held/pack/AW/W/B债务0且无错误，controller才发布dst READY/coverage和TaskDone成功。A只读lease在最后真实A读取返回后释放，W在最后真实q/scale/bias读取返回且bias已复制到本地后释放；可以更保守地等到命令末，但不能按issue结束提前释放。PS/dst及源owner都由原controller ledger统一管理；错epoch/错误/晚列失败使目标INVALID，不回滚epoch高水位、不把部分coverage当READY。错误时仍收齐已接受FP/AXI响应，已成立AW/W事务必须完成双方和B；writer fault可保持sticky到显式清理，但新command清错只准在debt_zero和目标invalidate后接受，不能要求系统reset才能从普通BRESP失败恢复。

reset必须取消整片段及实际端点的同一事务域；若真实AXI端点不能取消，先阻止新cfg，drain旧事务后再复用owner/tag，不能只清本地B计数吞掉旧响应。同步reset撤销metadata/有效位/lease命令、取消全部未发布目标，不要求清bias/PS/A/W payload RAM；恢复须重新绑定实际owner/epoch、加载/发布合法来源，旧token/FP/B不得写入新命令。该规则不改整图已冻结的Host/reset ABI。

**受影响验证即可。** 复用未改ACT06、TM4算术、quant16、双W及当前完整CPU/CSim的既有身份；对新packet/adapter/writer做七shape全部地址/覆盖/尾mask测试（含四row、Wi tile655/n5247、G128最后group127及bias128、QKV plane/shard边界、SCORER row15、ACT mask03）。用真实独立PS/bias/最终输出gold验证完整Wi一行及ACT/Down/4096输入支路的受影响数值端点；人工地址/协议压力例明确标为局部。须覆盖backpressure末B、错完整tag/高位identity、重复/越界tile拒绝且不索引、乱序返回重排、晚列数值失败、BRESP错误后新epoch恢复、活跃reset及旧响应隔离。未来若接全controller再取得实际producer/owner证据，不将局部七shape writer测试升级为122矩阵同runtime完整链通过。按原锁/成本帽运行，未改数值CPU/RTL不全量重跑。

### 3.8 实际PS展开失败后的同步bank与完整matrix驻留生产控制器

**当前实施以本节覆盖§3.5的异步PS读/旧微基准控制器；旧冻结身份与证据保留。** [ACT/full-cache父OOC01](../attempts/t2_act_full_cache_assembled_ooc_01/failure_receipt.json)在PS/progress/poison展开阶段连续120s无语义进展，144.346425s停止，未到cache EDIF连接；这不是cache容量失败或数值失败。现选择32个独立PS一维同步bank、4个同步metadata bank及有界整stripe前端，实际生产命令采用**完整matrix、1或4row、group外tile内**。不以每Group32同步C函数或单tile连续G循环声称原多tile吞吐。production独占该PS/controller/row-pipeline/Q35适配及最终生产caller接线，既有异步`microbench_v1`可冻结复用比较；新同步身份单独回归。

**物理存储与lazy有效性。** 每(row,lane)一个独立`ps_bank`，32份同body/参数：depth656、width32、独立`wr_en,wr_addr[9:0],wr_data[31:0]`及`rd_en,rd_addr[9:0],rd_data[31:0]`，1R1W同步读、停读保持q，不复位payload或读数据寄存器。每row另一个metadata bank depth656×16bit，低8位progress、高8位poison，同样1R1W、无全表reset。progress总数必须u8以表示128；失败OOC中18368bit是该冻结旧实现的报告，不能据此保留7bit进度。新metadata合计41984bit=5248B，PS仍671744bit=83968B。小型`initialized[row][tile]`和`busy[row][tile]`各2624bit可用FF并在reset/new合法command清有效；metadata/payload保留旧值不构成新任务有效性。

group0强制old_ps全+0、progress0、poison0，完全忽略未初始化RAM内容；各row第一次真实commit将progress写1、poison写本组bad mask并置initialized。group>0只有initialized=1、busy=0及来源/顺序合法才准读，读回再核progress==group。每次commit直接写`progress=group+1`，不在写端组合读旧progress再++；poison旧快照随该row的预约metadata携带，写`old_poison|new_bad`，group0旧poison为0。这样metadata只需一个读口和一个写口，不因issue/commit不同地址重新变成多读多写3D对象。原已poison lane不写PS，全部有效lane已poison的row不发FP，但仍走一次明确的skip退休/metadata进度写；skip不是伪造FP返回。metadata写端仲裁真实commit和skip，后者保留在有限前端槽中直至写完成，不能同拍覆盖另一tile的commit。

**整stripe前端与明确edge。** 固定两个entry保存全部输入数据3456bit（A1024/sa128/W2048/sw256）、完整命令句柄/identity/version/sequence/group/tile/mask/trace/rowmask、每row metadata快照及32个old_ps1024bit；tag/valid/slot generation另计。不新增第三条算术流水或无限返回队列。定义外部合法`issue_valid&&issue_ready`在E0接受header/payload，并在同E0使各PS/metadata bank采样该已验证地址；bank q在E0 NBA后稳定。E1将对应q和已锁存整stripe身份复制到其entry并核metadata，E2最早向全部活跃非skip row实际发算术；新token可在E1/E2依次接受，两个entry允许同edge旧头真实发射后复用，但不得覆盖仍有read/copy/skip债务的entry。read请求→q→copy→arithmetic_launch分别记录，不能在E0拿旧q发算术或在E1使用下一token的q。背压时entry及已提出的row算术payload稳定，bank读只在已预约请求发生，不能让不可反压q覆盖未复制返回。

先做完整header/shape/tile/mask/版本/顺序校验再索引bank；非法输入可握手拒绝，但零RAM读/零新FP/不推进成功序列。正常E0要求所有活跃row的busy=0、必要initialized有效以及有前端和信用，原子置全部busy；group>0进度的同步复核若不符，登记该已接收token的协议故障，停止新输入、禁止该token算术并排空已接受RAM/其它FP。分别报告header接受、前置拒绝、读回拒绝、实际launch和skip，不拿transport接受数当成功算术数。row的有效mask在poison读回后形成，trace所选lane若已poison则按原协议拒绝，不得发无效trace。

**Q35/D4预约不扩容。** E0为每个活跃row先逻辑预扣一个Q35 credit，有trace时亦预扣一个D4；实际物理slot可在E2由唯一row-pipeline分配，但前端预扣必须从其可用free中扣除，禁止另一路占走。对每row始终核`effective_free + pre_read_claims + physical_reserved + physical_returned = 35`，trace同理总4；store现free若含未实体化的preclaim，向外暴露的effective_free须相减，不双重计算。E2原子将preclaim转真实slot/完整192bit tag，不能再次扣一次；skip或已拒绝token只在本token读/metadata债务退休后还其preclaim。FP结果、trace/ack、Q35返回及commit仍按原完整tag验证，不能因同步RAM加入两级而缩短真实FP等待。前端entry含task/epoch和entry generation，reuse/同edgepop+push严格核返回句柄，防止旧读返回释放新entry。

**RMW、commit与反馈。** busy从E0直到该row真实PS写和metadata写的同一commit edge C才清。commit接受条件同时包含正确tag/当前busy/progress、各bank写口可用，以及最终group时final adapter确实有copy credit；PS写、metadata写、final copy（需要时）和Q35退休是同一原子事件，不能先释放slot再等物理写。各row仍可独立退休，下一stripe要求其全部活跃row依赖满足。禁止同地址在C读写/依赖write-through；g+1最早C+1提出bank读、C+2复制、C+3实际launch。旧row store的just/prior保护若保留，其阻塞与本前端合并计时，不额外假定零成本；新身份可由上述busy/真实写与同步read保证替换冗余观察位，但必须受影响同址/压力RTL证明，不静默继承旧F。

反馈`F_PS`定义为同(row,tile)相邻group实际PS read-request接受的最小间隔，另报read→copy→launch→FP return→commit C全过程；在无额外停顿且上述edge下，下一read比C至少晚1拍，实际值从日志取。group-major有T个独立tile可轮转，必要条件是T足够隐藏实测F、每row35个credit足够容纳含两级前端的实际寿命；只满足之一不保证II1。分别测T1、足够tile窗口与真实Down/Wi，记录持续间隔、busy/credit/read/commit/trace stall，不能将大T的II1用于ACT T1，也不能把配置II或INT六级当RMW服务。同步读新增FF/entry/tag、metadata、Q35及所有RAM bank碎片实际收费；单bank映射不代签32bank/controller整体。

**sequence只采用一种主生产顺序。** 本次不新增tile-major调度模式。每个完整matrix/1或4row command固定`g=0..G−1`外层、`tile=0..T−1`内层，逻辑ID=`g*T+tile`，用至少u32中间乘加后验可装入tag的27bit。tag.sequence仍这个逻辑ID；该命令无拒绝的实际外部accepted ordinal从0递增，恰等于逻辑ID，stall不会增加，四row同一个ID。调度ordinal与逻辑坐标虽在本模式相等，分别记录以检测跳组/重复/重发；metadata/FP错误后不复用原ordinal或等待未再发出的剩余数。现final adapter检查`(G−1)*T+tile`、末group/G128、tile/row/mask/full identity继续正确，416bit包按tile再row输出，只有实际copy才返producer credit。

完整G tile函数可以保留历史功能诊断，若实际tile外group内，其accepted ordinal为tile*G+g而逻辑ID仍g*T+tile，**不得把二者互换、改final tag蒙混v1检查或称本主生产顺序通过**。将来真要此模式必须显式order/version和独立服务证据，本次不实现第二候选。父rows>4仍按§7.3.4的合法1/4row view交接，view保存parent task/row_block_base；逻辑ID在每个明确view command重启，不能跨不同view却复用同一活动owner/slot句柄或错误归约。

父rows>4的顺序view执行不能改变原tile优先的数值首错。每个view返回完整错误坐标，父层以`parent_row=row_block_base+local_row`按`(tile,parent_row,lane,group,phase)`合并；可直接采用u64 rank `(((tile*16+parent_row)*8+lane)*(G+1)+group)*5+phase`，其中group=G保留原bias/final检查位置、phase沿原编码，`bad_element`亦使用原parent_row。某view已失败时，后续view仍可能在更早tile存在更优先数值错误，不能仅按view完成先后停查或选错。保持父owner未发布、记录失败并完成所需检查与全部债务排空后，目标置INVALID；成功只在所有view成功和末B之后发布。前后view须等上一view的front/PS/FP/adapter/writer债务全清才切换句柄与重启logical ID，不增加并发view或隐含PS容量，也不因此更改192bit tag/version及final adapter协议。

**实际驻留caller与13BO交接是同一交付的一部分。** 新`matrix_run`命令一次锁存完整NumericIdentity、父LinearTask和1/4row view、A/W/PS/dst Ref、K/N/G/T、地址/stride、W模型身份；真实ledger先claim PS/dst FILL、acquire完整A/W read lease，服务拒绝仅C echo或任意nonzero epoch生成的假READY。服务内部持续发所有G×T个stripe，直接向§7.3.3完整A及实际双W cache发同步请求，用同一(g,tile,row view,epoch)绑定所有返回后进入上述PS前端；每个返回有固定槽和generation，不从TB预置PS或用C结果作FP替身。同一A group可在遍历T时合法驻留并复用，但全部四row q/scale已返回才可发，下一group不覆盖仍被前端/算术引用的view；W slot在最后真实q/scale/bias读返回前不得释放。

生产`full_tasks/q8_linear_compute`的trace-off调用边界须从逐Group32 smoke变成**每个完整matrix/view一次真实matrix_run及一次实际completion**，由§8.1.2的可变时延chain或有界cmd/response实际驱动；函数内参考C实现仅用于CSim数值，不能代替生成RTL中的驻留loop。真实生成caller必须包含一份该服务、全G/T迭代和实际A/W/PS/bias/writer连线，不能仍综合旧TM1/session路径然后附加独立SV TB。沿原13BO top的真实descriptor/owner分派进入新服务，BO地址、输出位置、epoch/任务高水位及CPU只做输入/Embedding职责不改；generated enclosing probe必须由同生产入口/绑定文件生成并接原13BO真实端点中用到的端口，其余端口按真实未使用状态处理，不能手工另写一个理想caller冒充。完整13BO生产kernel尚未实际包含所有新服务时继续明示未完成。

该调用必须实际上移到原`n0`/TN8 tile循环之上；生产父控制只逐合法row view提交完整K/N/G/T命令，tile/group遍历由驻留服务接管。原逐tile边界即使改名`matrix_run`，仍不满足完整matrix驻留，也不能隐藏在C参考分支与生成RTL不同的调用粒度里。父层可以等待view完成后再推进下一view，完整task的错误合并、owner与输出覆盖按上一段维持。

matrix success需要G×T完整接受/launch或合法poison skip、所有front read/copy/preclaim/Q35/D4/FP/PS/meta债务0、final adapter/bias/writer及真实末B0、无错误，controller才发布dst覆盖/成功TaskDone。数值失败继续原首错所需检查并使目标INVALID；协议错误停新工作排旧债务。A/W lease可在最后真实读取后释放，也可保守等matrix末，不能按issue计数结束提前释放。reset取消整域front/slot/initialized/busy/ledger和未发布目标，payload不清；不能取消的AXI按原drain规则，旧generation/R/FP/B不得写新owner。

**必要回归及综合出口。** 先32bank完整地址pattern/不同地址同时读写和同址保护、G0未知旧值/重复config/reset、同步metadata G127→progress128、poison skip与真实commit竞争；再原TM4真实Down/Wi受影响范围及至少256连续不同tile接受，全部原数值gold/trace保持。完整真实G→GATE→quant/fullA已可独立前进，接Down时须由本真实matrix caller驱动完整K2624/N1024并实际写1024F32/末B，链内A/PS不预置。生成caller的owner拒绝/早错/背压/活跃reset/新epoch恢复另核，服务计时从真实command接受到真实completion，不把synthetic full-A或独立TM4 TB改名生产PASS。

ACT/cache/PS这一次OOC闭合继续同原累计3600s；本次停点已耗649.804541s，余2950.195459s（脚本可保守取2950），不因新同步RTL重置额度。先单完整动态PS bank及metadata bank映射，再相同body复用32/4份与真实controller装配，实际cache384URAM/224BRAM tiles照付；最终资源/DCP或精确结构EDIF装配须包括原算术/前端/Q35/metadata/bias/writer且blackbox0。先持久化checkpoint/资源后最终timing一次。24GiB/单重锁/CPU0–3/nice19/idleIO/MemAvailable>192GiB/120s语义保护保持；若新结构仍无法在余帽闭合，记录实际停点，不原样重试或扩整网综合/P&R。

**本阶段最终真实出口。** [resident full_down_01](../attempts/t2_tm4_matrix_resident_full_down_01/receipt.json)已实际通过四不同真实row、K2624/N1024的完整group-major服务：正常fullA端口装入预量化fixture，strict双W经实际44608个R beat装载；82次A group读、10496个W stripe、41984 row PS/335872有效lane-group逐项原gold、512 final packet及4096 F32输出通过，全部512 AW/W/B和末B后实际释放A/W lease、local owner ledger发布一次READY。它关闭此前pilot主动截断的输出/末B/本地owner退休缺口；无PS预置或强置cache READY，A来源明确是预量化fixture。bias_kind0只走无bias旁路，native8非零bias FADD未发射；初始reset和正常背压/延迟B不代签active reset、CE、晚错恢复、16row多view首错或双A/双W重叠。输出每512bit beat只使能8个F32字，物理32768B/有效16384B，不宣称全宽packing或持续II1。此测试与GEGLU→quant bridge04独立，尚无同runtime整链或生成13BO绑定；后续接口仍按§3.9交接，本阶段不再启动工作。

### 3.9 真实matrix生产接入：显式HLS命令流与原13BO外层

**本节为阶段交接后实施的唯一生产绑定方案，当前NOT_RUN；不在本阶段启动新整图工程。** 已核`hls/operators/full_tasks.cpp`的trace-off仍在n0循环调用逐Group32 scalar blackbox，`hls/platform/full_kernel_wrapper.cpp`为13个uint8_t指针的原外入口。新`tm4tn8_matrix_resident_v2`已有物理fullA/cache的lease/read/held-return端点及两路native AXI writer，不能用现scalar JSON自动得到这些连接。Vitis2025.2安装源[stream/array字段生成器](/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/ide/browser-app/lnx64/node_modules/@rigel-hls/rtl-blackbox/src/browser/rtl-blackbox-rtl-config-component.tsx:42)明确提供`hls::stream`的输入`FIFO_empty_flag/FIFO_read_enable/FIFO_data_read_in`、输出`FIFO_full_flag/FIFO_write_enable/FIFO_data_write_out`，并另列固定RAM地址/使能接口；[参数分类器](/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/ide/browser-app/lnx64/node_modules/@rigel-hls/rtl-blackbox/src/browser/wizard-steps/c-arguments-config-step.tsx:212)实际识别stream。这是工具接口依据，尚不是本项目新生成PASS；未找到/验证任意m_axi JSON直透，不能据此假造额外SV口。`hls_burst_maxi.h`的`write_response()`为void，常规C读写亦没有本合同所需原始RRESP/BRESP返回，不选它代替现有物理错误域。

**两个私有FIFO是实际C接口，物理服务只有一份。** 保留外硬件top `laya_typed_q8_forward`、原13BO与原AXI-Lite寄存器/起停/中断ABI，由明确RTL外层实例化改名的内部generated controller和一份持久计算服务。内部C top继续调用同一生产`full_forward_ports`/任务dispatcher，显式增加`hls::stream<ap_uint<512>>& compute_cmd`（输出）及`compute_rsp`（输入），生成`ap_fifo`实际端口；所有层级声明、配置和端口绑定都列入同一生产源闭包。C `matrix_run`实际序列化一次完整view命令、阻塞读取其真实completion；它可直接由HLS生成，无需RTL blackbox。若沿现配置使用代理blackbox，只能用上述正式FIFO键逐端绑定，核生成的`full_n/empty_n`有效极性，不凭名字猜反相。外层完整连通这两个私有FIFO，不能把它们暴露成额外Host BO或在TB外接理想返回。此显式生产封装细化§3.8的generated enclosing边界；旧单HLS顶层和独立SV测试不再独自构成新生产接入证据。

命令固定16个512bit beat（1024B）、completion固定8个512bit beat（512B），其中只需完整声明的字段有效，其余保留位必须0；现matrix所需NumericIdentity672、Context96、五Ref320、W模型身份3328、K/N/row view、epoch/slot/bias/weight key、两输出地址/范围/stride及头部可容于此固定容量。字段偏移由production在同一C/SV定义中固定并独立逐位核，不借保留位静默改变版本。头部携带版本、操作、完整task/epoch和命令generation；beat顺序固定、整包接收校验后才能claim或发RAM/AXI。FIFO各depth2，外层各一个完整cmd/rsp装配槽；基准显式payload容量为1024+512+2×2×64=1792B，若generated controller另有串行化寄存器须实际另计。一次最多一个活动命令，完整response被caller接收前不复用slot；无无限命令队列、每group start或逐cycle同步C轮询。

完整matrix/view调用仍须置于原n0循环以上，所有G×T在物理服务内完成。W LOAD及quant row/task完成必须通过同一物理服务门户关联到持久dual-W/fullA的真实slot/identity/epoch；这些来源由原BO实际读取得到，不能先让C数组变READY再向独立物理缓存回显一个owner。生成controller中的FullRuntime表负责原任务/Buffer命名空间，物理ledger负责真实slot状态、producer覆盖和read lease；C侧只有收到实际LOAD/quant末写及完整成功response才镜像READY，物理matrix仅在二者完整身份一致且来源READY时接受。C侧原claim/cover/publication及错误清理仍须执行，硬件slot拒绝不能被C成功echo覆盖。PS/dst视图覆盖、父rows>4首错和末B归并仍依§3.8；一个view完成不发布整个父task。CSim可调用同语义行为模型，但该分支不能留在生成RTL中代替服务，也不改变CPU部署职责。

**原13BO由外层逐端口真实仲裁，不伪装HLS内存返回。** 控制地址从当前实际生成AXI-Lite/driver映射冻结；必要时对内部top显式指定原offset并逐地址比较。外层可在原AXI-Lite写通路镜像13个64bit BO基址，按WSTRB更新高低字，并在一次请求ap_start时与controller同时锁存，不能在运行中读取半更新基址；不新增寄存器。C命令用合法BO角色＋byte offset/span，外层按同一锁存基址构造现服务的物理地址，先核角色白名单、对齐、u64加法溢出和范围，不依赖C指针强制整数化。输出Ref、region及QKV/FF实际步长仍以§3.7为真源。三个W读512、AUX读128和两个输出512是物理服务侧宽度；原13BO总线实际宽度从新generated接口取得。必要的宽度转换必须保持字节位置/WSTRB、burst/4KiB边界、RRESP/BRESP及全部子beat债务，有限buffer实际收费，不能只按max_widen512宣称已有512bit端口。

每个涉及BO的owner在`generated controller`与`physical service`间转换时，外层实际统计已接受AR至末R、AW至末B、全部W beat/部分burst与adapter持有项；旧owner尚有任何债务或半事务时继续服务原owner，不能按C函数return或ap_idle切换。新owner只在旧owner真实空闲后获得整个事务通道；其它请求可反压但不丢VALID/payload。服务运行中保留同一AXI owner，原生reader/dual-W/fullA/PS/final adapter/bias/writer与真实RRESP/BRESP连通，最终completion仅在所有local债务0、真实末B及物理lease释放/合法保留状态成立后产生。发生AXI错误保留原错误，目标INVALID、停止新工作并排空已接受交易；错误response同样等待安全退休。reset/new epoch取消命令有效性但不抹去不能取消的已接受AXI债务，旧R/B/FP不得命中新generation，完成drain后才能交回端口。正常、拒绝、数值失败和reset恢复均不能由人为delay或假done代替。

交接后首个生成验证复用这份生产门户与外层，配置只选择当前授权有界任务，不另写理想caller：核13BO及全部控制offset不变、两个私有FIFO实际连接、单实例持久存储、完整view只一命令及真实group-major遍历；故意压住输入FIFO、response和最后R/B，验证generated caller不会提前返回，旧owner未排空不切路、错误/active reset后新epoch恢复。再由真实GEGLU→GATE→quant/fullA接完整Down K2624/N1024及1024物理输出，链中不预载A/PS/输出。该入口还须继承父view首错与覆盖；仅portal小例/HLS/CSim通过不扩大为13BO整图完成。原模块OOC及锁/资源帽保持，无新整网OOC/P&R/板授权。

## 4. T3 CPU静态模型预检与Q8会话候选ABI

### 4.1 现在可实施的准备范围

Root按既有ownership派发；数据owner负责CPU validator、Host会话/序列化与测试，计算owner独占Q8入口、wrapper与快速LOAD接入。本节现冻结一个**独立新Q8会话候选ABI**，可连续实现真实ACT strict/fast A/B；不改现有13-BO全图ABI，不借旧保留字节增加含义。Root已明确本轮无需同时接入完整图；13-BO生产Host/全图快速路径保持`NOT_RUN_DEPENDENCY`，局部通过不能删除其旧检查，不能兑现整网约307.8ms的条件收益。

实际兼容边界：`host/laya_host.cpp`当前调用`laya_typed_q8_forward`，模型BO为EMBEDDING/W_Q0/W_Q1/W_SCALE/AUX，仅上传sync而无设备读回；IO为32768B，`LYRQ` v1 header128B、目录起点128B、payload320B，结果起点16384B；`LYRS` v1为384B。AUX `LYMP` v1 header128B，四tag在32/48/64/80B、源GGUF SHA256在96B。它们均保留。现独立`q8_tm1tn8_joint_dma` v1 descriptor512B（magic `0x31543851`、version1、LOAD=0/RUN=1）及其严格执行亦保留。新入口命名`q8_tm1tn8_session_dma_v2`，在原Q8模块目录独立源码/ABI头和wrapper接入；新入口不接受v1 descriptor，新Host编码器不把新帧送旧入口。

输入为实际上传候选的不可变模型包。首个fixture仍绑定§1 v4包；既有包与当下改动后kernel源码身份分开记录，不能伪称v4 build仍覆盖新kernel。复用`tests/full_model_package_test.py`中目录/BO范围/来源校验原则，不因为新源码使旧build不匹配而跳过包内容检查；生产集成须生成实际新build的包/关联记录并重验。

validator必须从manifest解析全部124个weight目录中的122个Q8矩阵（dtype8）及实际scale BO。对每矩阵核K整除32、N、padded N、scale跨度/边界/不重叠及WeightKey唯一性；实际half地址为`scale_base + 2*(((n//8)*G+g)*8+n%8)`，n遍历全部padded列、g遍历0..G−1。总计11542592个half，包括ACT额外48个padding scale；实际读取字节coverage与manifest独立比较，不能只声称循环次数正确。还需验证所有模型BO、manifest和tag preimage的hash，来源为§1真实GGUF；静态scale合法性不能代替包身份与完整性。

half合法谓词为`(h&0x7c00)!=0x7c00 && ((h&0x8000)==0 || (h&0x7fff)==0)`：正有限/正subnormal/±0接受，负非零/Inf/NaN拒绝。CPU实现与独立binary16解码对全部65536位型比较，不让gold调用同一位谓词。实际模型按目录顺序、padded n、g报告首错WeightKey/name/n/g/字节offset/原half；保存全部覆盖数与合法性类别统计。此候选只取消静态scale重复检查，bias、动态activation量化/有限性/范围、LN及其它现行数值检查全部保留。

### 4.2 验证记录与会话状态机

离线记录使用显式schema `laya-validated-static-model-v1`，字段至少包括：profile名、manifest SHA256、源GGUF SHA256、四个tag及完整preimage SHA256、各BO角色/size/SHA256、122项scale检查范围/计数、validator源码hash与版本、检查成功状态。记录是准备证据，单独持有该JSON不构成设备会话已验证；输出路径及实际内容hash自动登记，不手填PASS。

Host会话逻辑状态固定`EMPTY → PACKAGE_CHECKED → UPLOADED → READBACK_VERIFIED → ACTIVE`；任何失败转`INVALID`，重新建立从包检查开始。会话记录追加session_generation(u64，不回绕)、设备/context/BO allocation身份、每BO设备范围与size、实际上传完成事件、读回SHA256和关联验证记录hash。内容基于同一只读snapshot上传；上传前后不得改snapshot来制造hash与被传内容的竞争。全部模型BO上传/同步完成后，读回同一完整字节范围并与snapshot逐BO SHA256核对，才可ACTIVE。离线内存端点证明状态机与字节范围；无板卡时真实XRT/PCIe/HBM读回仍`NOT_MEASURED`。

ACTIVE会话内模型BO不可写；任何内容改变、重传、重分配/地址迁移、模型/tag/包变化、设备reset/context失效均先撤销ACTIVE并增加generation。reset后旧JSON、旧generation或旧BO句柄不得恢复有效；重新上传和读回成功才恢复。请求只引用当前ACTIVE记录，不接受调用者自行设置`validated=true`；验证记录须来自上述成功路径，并与当前kernel候选声明的完整身份关联。该信任模型是受控Host生命周期，无权据此宣称硬件防御任意恶意Host。

### 4.3 新候选descriptor、命令与observed的确定编码

全部整数为LE；不序列化C++ struct。descriptor固定**256个u32=1024B**，要求实际descriptor BO完整容纳该范围；Host提交前核活descriptor/observed BO容量，短BO在Host拒绝且不启动HLS，不声称硬件能从descriptor自报长度推断实际allocation容量。word0 magic=`0x32533851`（LE `Q8S2`），word1 version=2，word2 command：`LOAD_W=0`、`RUN_TILE=1`、`REGISTER_MODEL=2`、`REVOKE_MODEL=3`，其它拒绝。word3 flags仅RUN可用bit0 trace，其它位0。profile固定两个：`STRICT=0`、`VALIDATED_STATIC_MODEL_V1=1`；该profile名沿CPU记录，wire ABI版本另为2。v2 strict与fast均走同一注册和地址绑定，用于公平A/B；旧v1严格入口仍不要求新会话。

| word（byte offset） | 长度 | v2含义 |
| --- | --- | --- |
| 0–3（0） | 16B | 上述magic/version/command/flags |
| 4–7（16） | 16B | request_id u64、**request_generation** u64；不是模型session generation |
| 8–20（32） | 52B | task/op/stage/layer/B/S/batch/row0/rows/K/N/family/weight_layer，顺序与原`q8_tm1tn8_abi.h`完全相同 |
| 21–31（84） | 44B | src四字段、dst四字段、W epoch、PS epoch、quant task，沿原明确索引 |
| 32–47（128） | 64B | model/numeric/layout/build四tag，各16B |
| 48–61（192） | 56B | act/out0/out1 base三个u64、其span三个u64、trace row/column两个u32；沿原索引和相对地址含义 |
| 62（248） | 4B | observed_words=32768 |
| 63（252） | 4B | descriptor_bytes=1024（仅新ABI定义此字，旧v1仍要求0） |
| 64–65（256） | 8B | profile u32；session_flags=0 |
| 66–67（264） | 8B | model_session_generation u64，非0且不回绕 |
| 68–71（272） | 16B | context_cookie；Host对实际device/context建立的非0标识 |
| 72–79（288） | 32B | validation_record_sha256，完整CPU验证记录的实际文件字节SHA256 |
| 80–87（320） | 32B | manifest_sha256，实际新包manifest文件字节SHA256 |
| 88–95（352） | 32B | candidate_build_sha256，§4.5规定的新build preimage完整SHA256 |
| 96–103（384） | 32B | source_gguf_sha256 |
| 104–107（416） | 16B | model_bo_count=5、bo_entry_bytes=32、binding_words=18、zero=0 |
| 108–111（432） | 16B | 保留0 |
| 112–151（448） | 160B | 五条BO记录，每条8 words/32B，见下 |
| 152–255（608） | 416B | 保留0；新增含义须另改ABI版本 |

五条BO记录固定顺序EMBEDDING/W_Q0/W_Q1/W_SCALE/AUX，role为生产BO枚举`0/2/3/4/5`。第i条word=`112+8*i`：`role:u32, flags:u32=1(只读), device_base:u64, bytes:u64, allocation_cookie:u64`。allocation_cookie为Host给本context中真实BO allocation分配的非0、不复用u64，不能由文件路径或设备地址代替；base以设备字节地址计，64B对齐，bytes必须等于本候选编译目录中该模型BO大小，base+bytes不溢出且五范围不重叠。所有命令都重复完整会话字段，REGISTER后逐字匹配；digest是Host已完成验证的关联键，FPGA不声称重算全包SHA256。

REGISTER/REVOKE的word4–31、48–61与flags必须全0，无task/shape/激活/输出数据，保留四tag和完整会话字段。LOAD/RUN沿原task、WeightKey、shape、目录范围、缓存epoch规则；本候选仅保留已有ACT与enc0 QKV容量/白名单，不扩Wi/Down。v2移除原TB专用`request_id==3 && generation==1`硬编码，第一条LOAD接受非0request_id/request_generation并绑定，后续本session内必须完全一致；跨请求复用完整图不在本轮范围。正式fixture仍来自request3/generation1。

observed仍32768 words=131072B，header仍256 words；新magic=`0x324f3851`（LE `Q8O2`）、version=2。word2–121、四tag、各端口useful/total计数及q/scale/group trace地址沿原ABI原索引。新header：122 profile；123 model_session_state（0 EMPTY/1 ACTIVE/2 INVALID）；124–125当前ACTIVE generation（无ACTIVE为0）；126 command admission（0未接受/1会话命令/2算子命令）；127 binding_match（0/1）；128–131 context_cookie；132–139当前注册record digest（无ACTIVE为0）；140–147本候选build完整SHA256；148–149本命令实际scale合法性检查次数u64；150–151本context已消费generation高水位；152–153 W所属session_generation（无有效W为0）；154 W所属profile（无有效W为0）；155首错归属（0无/1描述符/2模型会话/3算子任务）；156会话拒绝原因；157 descriptor_bytes=1024；158 binding_words=18；159–255保留0。拒绝原因0无、1无ACTIVE、2generation、3context、4实际BO绑定、5digest/候选身份、6profile、7注册状态或generation高水位；常规shape/数值错误仍沿旧detail和bad_element，不挪用会话原因。

REGISTER/REVOKE的done_task/output_elements/unit、quant/linear/load_started均0，不能伪装LOAD task退休；报告其会话command admission和状态。常规status值沿现行`Status` 0..8，未知wire字段E_ABI、包/候选身份E_MODEL、范围E_BUFFER、顺序/会话E_PROTOCOL。valid REGISTER实际读AUX header128B核完整四tag与源SHA，数值profile不改变header语义。

### 4.4 实际BO绑定、注册/撤销与退休

现`tm1tn8_hls_control.sv`只锁存七个真实指针，descriptor自报base不足以证明绑定。新wrapper必须增加只读绑定输入：context_cookie128、model_generation64、embedding_base64，以及五个BO的bytes64和allocation_cookie64；q0/q1/scale/aux base**取同一组已锁存、随后写入生成HLS AXI-Lite实际指针寄存器的值**，禁止另读descriptor复制出“actual base”。embedding无此Q8入口的DMA消费者，只作为Host模型包绑定字段保存，不宣称在该端口上做过硬件读回。

新增HLS输入`binding_context`为64bit AXIS；每个command_start原子锁存后、该次HLS调用读取固定18个beat：beat0/1=context_cookie低/高64，beat2=model_generation；对角色i=0..4，beat`3+3*i`=实际锁存base、`4+3*i`=bytes、`5+3*i`=allocation_cookie。wrapper启动HLS后按ready/valid发完18beat，值与所有真实指针在本命令内不变；新命令须等context流清空。具体AXI-Lite物理寄存偏移由本次生成control RTL/driver头解析，按既有wrapper生成器核实，不能把逻辑word offset当控制寄存offset。bytes/cookie/context由受控Host从当前活BO对象传入，FPGA只能核对前后绑定，**不能独立辨别Host谎报allocation/容量或伪造读回证据**。

Host入口接`StaticModelSession`成功状态而不公开`validated=true`旁路：在同一device/context和BO对象上完成§4.2后构造REGISTER及绑定输入，收到成功且drained后才将Host设备会话标为ACTIVE。在离线实现里既有ACTIVE只表示内存端点已准备；新设备桥需单独记录REGISTER完成，不能拿旧JSON直接设置硬件ACTIVE。每次命令重新从同一活BO对象取得base/size/allocation_cookie，命令提交与模型BO写入/释放互斥。内容变、重传、重分配和地址迁移必须先REVOKE完成，再提高Host generation并重新准备/上传/读回；旧allocation_cookie不复用。

硬件只需一个model-session slot和现有单W cache，规则如下：

1. reset后EMPTY、无有效W/请求/epoch，generation高水位0；未REGISTER的fast/strict v2命令都拒绝。Host检测device/context/reset变化后换新context_cookie、提高generation并完整重建。硬件reset不保留防重放计数：旧LOAD必因无ACTIVE失败，旧REGISTER跨reset的阻止由受控Host承担，不能声称具备持久硬件防重放。
2. REGISTER仅在无ACTIVE、全部用户/物理/计算债务0时接受；generation必须大于当前context高水位，context非0且与binding流一致，完整descriptor、四tag/build、BO表/范围和实际binding先通过。准入后消费该generation、状态先INVALID，读取AUX header核对；完全成功才ACTIVE并清空请求task/cache元数据。header失败无算子task，保留已消费高水位，下一次须更大generation重建。ACTIVE期间REGISTER一律拒绝，不悄悄覆盖会话。
3. REVOKE携带当前完整注册字段（generation为当前值），必须先等既有命令退休；成功使会话EMPTY、W/A8/PS/dst及请求元数据失效，高水位保留。Host收到drained再把generation加1用于下一次REGISTER。无ACTIVE或非匹配REVOKE拒绝；u64耗尽不回绕。新context只有reset重建，普通命令不得改变context后把高水位归零。
4. 每次LOAD/RUN先比profile/generation/context、四tag/digest/BO记录与slot，再比binding流和slot。单个错误descriptor在无实际binding变化时不消费task/epoch、不破坏既有slot；**实际锁存BO/context/generation不同**表明当前Host关联已变化，则会话INVALID、W及关联cache失效，未发model/activation DMA，必须重新建立。session generation独立于request_generation和W epoch，三者禁止混用。
5. 第一LOAD task=1/W epoch=1；RUN仍消费下一quant task与再下一linear task，PS/dst/A8沿旧不回绕规则。为测同会话暖LOAD，v2在无reader且债务0时允许再次LOAD同一WeightKey（task和W epoch均严格递增），v1重复同WeightKey限制不改。W provenance记录generation/profile/WeightKey/shape/epoch；RUN逐项匹配，不许fast RUN借旧strict或旧session的W。

快LOAD仍真实搬运q0/q1/scale/bias，逐次AUX header、bias有限性和所有目录/范围检查保留；原half解码和R0不变。**唯一旁路是片内scale逐padded n/g数值扫描**；STRICT每次照扫，FAST实际检查次数必须0。q/scale返回与片内写全部完成、bias通过后W才READY；单bank无reader才准入LOAD，不增加双bank/并发设计。由于每次command_start已要求前命令全排空，REGISTER/REVOKE不与RUN竞态。

首错按实际发生顺序锁存，后续writer/completion错误不覆盖已有错误；描述符/会话拒绝不消费task，已接受LOAD的header/数值错误沿原语义消费task/W epoch并令W INVALID。会话完整性错误撤销slot；STRICT数值坏scale/bias也使当前不可变会话INVALID，需新generation重建；动态activation/算术错误仍归真实quant/linear task且沿旧cache恢复语义，不自动归咎模型包。无论成功或失败，保持原空compute/writer config、finish及completion路径，管理命令也必须排空该次控制token，不遗留下一调用的completion。 数值LOAD失效后的可检查期望区分“活缓存epoch”和“已消费高水位”：W INVALID时活`O_W_EPOCH=0`允许，但`O_LAST_TASK/O_W_MAX_CLAIMED`须保留该已接受LOAD的task/W epoch，模型generation高水位不得回退；重建要求更大generation REGISTER。不能把清活epoch误判为未消费，也不能因DUT清零而删掉消费断言。

wrapper command_ready要求前次context流已清空；command_done要求本次18beat全部消费，两者还要求用户adapter队列/返回、物理R/B、compute/writer债务为0。W READY不代表observed写B已返回；Host只能在最后observed B与wrapper done/drained后接纳状态。AXI transport错误由wrapper锁存first-fault并禁止成功完成，状态判据为observed成功**且**wrapper无fault且全部债务0；该fault封锁后续command_start直到整域reset，不能让HLS内部旧W有效位绕过失败。不能以生成HLS未暴露RRESP/BRESP为由把错误响应记成功。可退休错误先排空；无法退休的总线故障按既有guard/reset恢复，不伪造drained。reset须作用于整个wrapper/HLS/compute/writer及端点取消域；局部清valid但总线仍欠响应不构成恢复。会话内若绕过只读约束破坏scale，FAST不再承诺逐LOAD发现，按信任前提破坏记录。

### 4.5 新候选身份与最小真实ACT A/B

新wire/Host/wrapper/LOAD分支必须进入实际候选身份。模型来源和数值规则未变时model/numeric tag可保留；layout preimage改用显式新schema `laya-layout-q8-session-v2`，保留原BO/tensor/weight目录并纳入§4.3–4.4的descriptor/observed/context流规范内容与SHA256；build preimage用`laya-build-q8-session-v2`，纳入该layout hash、实际新Host序列化/会话桥、ABI/HLS/wrapper/生成器、测试入口及工具配置的逐文件hash。确定性编码沿现有canonical JSON；layout/build tag各取对应完整SHA256前16B。`candidate_build_sha256`为后者完整32B，编译常量与descriptor逐字一致，不是把未来xclbin hash写进自身造成循环。

先冻结实际源文件/ABI和build preimage，再生成新四tag、AUX128B header、manifest和generated header；输出generated header与含tag的AUX/manifest不能反过来进入自身build preimage，实际制品hash在关联记录另列。原q/scale/embedding有效载荷不变也须核对完整BO；更新AUX/manifest后重新执行全部122矩阵验证并生成新记录。Host另把实际kernel/RTL制品hash与本build preimage绑定。既有v4 CPU准备记录、`Candidate.kernel_sha256`任意输入及离线ACTIVE均不能自动升级为新候选；不得仅改record里的tag或补填一个kernel hash即宣称重验完成。

本轮正式A/B固定**同一新候选制品、同一实际ACT矩阵family12/layer255、K256/N2、rows1、B1/S128**，真实act输入/gold沿§1原fixture；生产v1作为保留回归，不再增加第三个性能配置。两配置仅profile=STRICT/FAST不同，各完成REGISTER→LOAD(task1/W1)→RUN(quant2/linear3/PS1/dst1)→同session暖LOAD(task4/W2)→RUN(quant5/linear6/PS2/dst2)→REVOKE。每配置独立合法会话，Host冷准备、上传、完整读回、注册时间分列；实际板端读回缺硬件仍`NOT_MEASURED`，RTL内存端点完整内容/绑定通过不能改写该状态。

每LOAD q/scale/bias片内字节均与独立真实包比较，两profile也逐字节比较；ACT有8个padded输出列、G8，STRICT每次检查64个scale（含48个padding），FAST为0。沿当前真实布局，每LOAD有效q0=2048B、q1=0B、scale=128B、AUX header=128B及bias=8B（2个F32），新包须核这些payload不变，两profile的实际payload及bias检查次数一致。两次RUN的全部有效2个F32输出、q激活、scale与R0/group/PS trace沿原独立gold标准，不以两个DUT互相一致替代gold。逐次记录command_start→首次done、LOAD模型首末R、cache写完/READY、scale_scan区间、最后observed B；REGISTER/REVOKE及1024B descriptor开销真实计入，不从LOAD周期中偷减。一次暖同session重载证明未重复CPU扫描且保留绑定；它不证明跨生产请求/完整图性能。

一组表驱动短负例覆盖CPU已有65536 half位型/122矩阵/ACT padding坏值及准备、上传、读回失效；新增Host短BO拒绝、wire旧magic/保留位、未REGISTER LOAD/RUN、错profile/generation/context/tag/digest/BO size/allocation/base、ACTIVE重复注册、REVOKE后旧LOAD/RUN、reset旧LOAD与完整重建。实际base负例必须改变wrapper真正写HLS指针寄存器的值而只保留descriptor不变；allocation负例用新cookie且可复用同base；不能只改两份自报descriptor。Host短BO例证明未启动硬件；其它FPGA准入拒绝证明无模型/activation读、无task/epoch消费、控制token及observed写排空；REGISTER header错例只允许其128B AUX读，不能声称零model读。STRICT隔离副本坏scale维持E_NUMERICAL顺序，FAST同类破坏按信任前提违规单列；bias和动态activation坏值在两profile均保留检查。增加末model R/末observed B有限hold和一个reset恢复短例，证明READY/done不早发；不再展开QKV长A/B或重跑T1/T2矩阵全套。

实施和真实有限RTL复用§0既有guard、pilot与单重工具安排，不新增审核门或专题报告。对接顺序为数据owner生成新包/验证记录及v2编码/活BO绑定，计算owner接入口/绑定流/strict-fast分支，复用真实ACT端点完成有限RTL。CPU准备、离线Host端点、v2 RTL A/B、真实XRT读回分别在唯一阶段表登记；13-BO Host将来显式引入同一session bridge和新完整图ABI才可能接入，本节不授权用局部证据关闭该依赖。

实际r2已完成新包CPU离线两代完整重验，以及同硬件真实ACT strict/fast两次LOAD/RUN限定数值与周期对照：每LOAD少336cycles，RUN不变。contract strict02/fast_trace01在未改硬件/gold下分别23/21拒绝通过，补核精确首错归属、session/W状态、task/epoch/generation高水位、8次descriptor-only合法重试，以及REGISTER坏AUX、STRICT padding坏scale、两profile坏bias/activation和相应恢复；接受数值LOAD消费task/Wmax但清活W epoch、activation失败保留ACTIVE/W READY的合同均有实际断言。最后closure strict04/fast_trace01各9拒绝/2次READY失效/3次gen2 RUN重建通过，补齐READY W下真实base/cookie变化的slot/cache失效、旧RUN/LOAD及同代注册拒绝、更大代恢复，以及整域reset→旧LOAD拒绝→gen2 REGISTER/LOAD/真实RUN。全部恢复均保留独立数值/trace和首次done排空，现独立ACT数值/会话出口收口。细分性能事件仍未全部观测，真实CPU会话记录至设备的生产桥/XRT未验收，详见results唯一集中验收章。HLS估计21.308ns/46.93MHz，不是物理150MHz通过。

## 5. 联合资源、服务与淘汰账

唯一算术工作量基线仍为[已复核budget JSON](../../cpu_embedding_q8_validation_20261010/pipeline_budget.json)及[解释](../../cpu_embedding_q8_validation_20261010/pipeline_budget.md)；本节只固定候选变更和下一关口，不另造第二套独立总账。全图122矩阵、47160754688 MAC、1473773584个R0 group、695816个动态quant group。以下均为**150MHz条件估计**，新物理DSP/LUT/FF/BRAM/URAM/时序尚未证实。

| 几何 | Q8理想cycle / ms | 现映射DSP | A树LUT条件DSP | B packing条件DSP | A+B条件DSP |
| --- | ---: | ---: | ---: | ---: | ---: |
| TM4/TN8验证台 | 46055432 / 307.036213 | 1536 | 1280 | 1024 | 768 |
| TM16/TN8候选1 | 11513864 / 76.759093 | 6144 | 5120 | 4096 | 3072 |
| TM16/TN16候选2 | 5756936 / 38.379573 | 12288 | 10240 | 8192 | 6144 |

每通道DSP条件系数分别48/40/32/24，均含原R0的8DSP；A/B映射条件必须各自成立才可使用对应列。TM4是验证台；TM16/TN8单独Q8已超过50ms间隔；TM16/TN16现映射与A均超裸9024DSP，不能进入整图。B列8192仅余832，连F256 Attention所需1280都未容纳。A+B列若成立，加F256 Attention1280、vector/quant/LN/非线性规划512、control/bias/conversion规划256，共8192，裸余832；512/256与shell均待实核，不能宣称fit。

| 共享资源/服务 | 保留的基线或条件 | T4/T5要闭合的缺口 |
| --- | --- | --- |
| LOAD | q0+q1 64B/clk为38.475307ms，scale解包16B/clk为9.618827ms；旧重复校验另307.802453ms | T3只移除重复校验；剩余48.094133ms及bias/协议仍付费。单W串行不能直接取max；双W须实际预取和最后读者/epoch证据 |
| W/A/PS存储 | Wq最大约5.374MB/槽，Ws335872B/槽；W双槽自然估计384URAM，沿旧实现系数512，另有bias/复制；旧Ws估计缺口保留 | 裸960URAM、4032BRAM18，shell未知；按银行容量及所需读写端口逐项计，W共享不等于A/PS免费 |
| PS带宽 | TM16/TN8每拍128个F32读+写，各512B；TM16/TN16各1024B/clk | 同址反馈、Q35/D4、输出credit和bank冲突实测；PS/R0不够即停扩INT |
| 动态quant | 8lane两扫理想37.110187ms；32lane组率1/clk需最坏2次F32 div/clk | divider、round/half、暂存与真实A供数共同计，禁止把静态scale优化当量化删除 |
| Attention | QK/AV各503316480乘法；F256纯算术26.2144ms，softmax 8/4/8三扫另26.2144ms | AV1024地址/11拍条件反馈≤93.09贡献/clk；原联合条件QK+受限AV+softmax为75.3664ms，仍不能闭合20/s；额外合法上下文/exp/div均付费 |
| vector | LN 7824行，8lane三扫20.029440ms；GEGLU 9404416输出，4lane15.674027ms | 同实例服务相加；独立引擎逐项计DSP/非线性/端口；LN统计、Wi U/G配对及残差身份不变 |
| 输出/Host | Q8输出158138376B/请求；20/s为3.162768GB/s。旧Host H2D192970752B/请求，20/s为3.859415GB/s | writer实际burst/B退休，Host生存期/部分同步/未初始化读；新raw已在STATE0内，不能多算或默认消失 |

资源台账每候选记录`实例/数量/每拍服务/容量/端口/来源/实测或估计/未知项`，LUT/FF/BRAM/URAM及shell未知写UNKNOWN，禁止用0填空。旧32bit前端、当前TM1局部实测与新条件阵列不可拼成一个“实测端到端”。性能核算每资源的全请求总服务，并列单请求依赖路径及有限多请求完成间隔；不同独立引擎可能重叠只在有合法buffer/owner/调度证据时使用，单实例服务必须相加。

### 5.1 正确libm叶子的全模型服务影响（第1轮实际综合后更新）

[冻结工作量](../../cpu_embedding_q8_validation_20261010/pipeline_budget.json)的GEGLU输出为`28 Encoder×128row×2624=9404416`，即3584个完整row、每输出一次tanh；2个Decision的ReLU不混入该数量。`round1_02`已实测的是request3/enc0/row0的2624项：首次out_valid延迟sum=`1761587cycles`、范围517..795。单slot正常消费后下一拍才可再接受，故重复这份**已测行分布**的稳态服务均值为`(1761587+2624)/2624=672.336509cycles/结果`。末项无需再等下一次准入的1cycle只影响有限序列尾部；实际任务启动、其它GEGLU算术与搬运另计。

| 情景，150MHz仅条件换算 | tanh主体服务 | 证据边界 |
| --- | ---: | --- |
| 第1轮02已测行分布重复3584次，单slot/单叶 | 6322932224cycles，约42.152881s | 输入分布外推，非全模型实测、非全部有限输入的下界；真实全图各层z分布尚未取得 |
| 第1轮02同上分布、理想均分四份正确叶子 | 约10.538220s | 四副本及无冲突调度均未实现；不能沿用旧叶子II≥3替代实际服务 |
| §8.4.7单流空间流水，stream02正常fixture已测II1 | 9404416cycles，62.696107ms | 仅Encoder主体条件投影；实际逐row排空的71.656107ms及完整9421056次收费见§8.4.8，整图未测 |
| 同一单流若只达到II2 | 18808832cycles，125.392213ms | 敏感性情景；按实际服务选型，II1不是数值通过条件 |

第2轮同形状/独立gold、同wrapper/OOC配置的真实row首次out_valid合计已降至`883954+207857=1091811cycles`、范围348..473；其当前单slot重复分布均值为`(1091811+2624)/2624=417.086509cycles/结果`，全模型条件投影降为**26.149700s/单叶，理想四叶6.537425s**。这取代42.152881s作为当前已验收叶子的同分布投影，前表第1轮数字保留比较来源；仍非真实全图分布/完整请求实测。

当前正确单叶不能作为高性能最终落点，仅供数值和真实生产连接建立基线；判断依据是上述有明确假设的秒级服务风险，并非恢复50ms硬门。旧四实例77.366613ms是错误叶子的历史结构预算，**既不是新叶子的代表预算，也不是新叶子全路径下界**。第2轮add尝试只改善依赖链中的一项，不能以局部下降宣称完整瓶颈已解决，也不无限追加标量调度候选。当前完整CSim/真实GEGLU工作中可复用已有trace记录各层z分支与任务边界，取得真实分布后再替换条件投影，不为此另建诊断项目。

历史共享vector其它理想项为`6902784−2351104=4551680cycles=30.344533ms`。若沿同一模式互斥安排，把GEGLU有效服务改为单流1结果/clk，则新的**条件主体**为`4551680+9404416=13956096cycles=93.040640ms`；II2时155.736747ms。这仍遗漏真实LN树/标量、其它FP服务、fill/drain、模式切换与搬运，不能当完整vector实测，更不能与Q8/Attention取max冒称请求性能。原46.018560ms仍只适用于四路正确tanh各II1及所有旧条件同时成立；当前不生成四路空间流水来追该数字。

首请求50ms和20 B1/S128完整请求/s分别保留为远期参考；10/20/40请求/s、100/150/200MHz敏感性沿mission和原budget。当前选型按§0.1同口径性能/资源改善，不以超出参考单独淘汰，不改成固定仿真频率已达标。当前T0释放执行基线，**整体资源/服务尚未闭合**；通过T1/T2不自动触发大阵列、Attention或全图长例。候选仍按mission最多两种最终几何与两轮资源/服务假设，必要条件不满足即记录具体缺口。

## 6. Ownership、证据入口与后续出口

| 范围 | 唯一owner / 本次可执行 | 正式出口与尚未覆盖 |
| --- | --- | --- |
| T0合同/资源/集中验收 | Astra：本design、source/results与mission | Root维护唯一stage_results；不复制模块设计真源 |
| T1 | 数据Sol：layernorm_engine的front16源码/RTL/TB与模块文档 | CSim→两top功能RTL→四配置；之后才接完整128行生产owner/CRC |
| T2 | 计算Sol：q8_linear_and_restore/tm1tn8_gs32_512的新候选/模块文档 | CPU数学、RTL整数、R0、TM4/PS分层；HBM/quant/bias/writer整链为T4依赖 |
| T3 | 数据Sol做CPU/Host预检，计算Sol做Q8接入 | 离线会话可执行；生产ABI、真实上传完整性与快LOAD RTL各自留状态 |
| T4–T7 | Root按已通过依赖分发，Astra在本合同原位落实实质接口变化 | T4供数/预取与阵列；T5 Attention/vector；T6完整layer0 producer链；T7完整图/Host/多请求；不从本基线默认解锁未定接口长跑 |

新attempt保存自动源码/config/输入/gold/tool hash、guard终态、原始自检日志、实际周期/语义进度/RSS与首错，范围注明CPU准备/CSim/RTL/服务/条件资源/物理证据。只有Root更新[唯一阶段表](../stage_results.md)；模块results引用该表和原始attempt。编译成功、中途PASS字符串或数学证明都不替代RTL最终guard exit0与完整断言。

T0本次出口是可直接派发的§2、§3及§4准备合同和一份未闭合项明确的联合账；不是宣称生产全图接口已经实现或吞吐已达。具体实现反馈若只涉及普通修复由owner连续处理；数值/shape/profile信任边界、延迟/credit或跨任务身份的实质变化在本文件原位修订后继续，不额外创造逐次人工审批门。

## 7. T4条件设计：供数、动态量化与双W预取

本节及§8由Root根据T1/T2实际服务与owner空闲情况选择最小实现范围；**现在发布的是条件接口和可证伪出口，不派生新的大阵列、全图或物理实现运行许可**。复用Q8、activation_quantizer、attention_and_fp_engine、vector_and_ffn既有模块目录；各模块唯一owner由Root登记。优先轻量调度核算及已有FP IP/单通道反馈测量，不与当前T1/T2执行抢重工具。生产全图控制器仍按原身份，局部新top不force旧owner READY。

### 7.1 仅保留两套联合候选，公共部分固定

| 配置 | T4公共供数/缓存 | T5唯一差别 | 使用规则 |
| --- | --- | --- | --- |
| C3 | q0/q1/scale独立读口；双W槽；双A槽；16lane两扫量化；Q8最终几何只条件考察TM16/TN16 A+B | 同一head的3个独立16-query AV context，最大48queries | 首个条件候选；128queries分3+3+2个tile，末批损失计入 |
| C4 | 与C3相同，不同时改变AXI outstanding、量化lane或Q8几何 | 4个16-query AV context，最大64queries | 仅在C3反馈/缓冲服务不足或C4明确减少服务缺口时比较；128queries分4+4 |

旧串行LOAD、单AV context及§5预算作为已存在基线，不为凑配置重复运行。C3/C4不是整卡fit承诺；TM16/TN16仅在A+B精确性及实际映射条件成立后才是扩阵列候选，当前微基准沿TM4或更小真实算术。两配置共享一次W/quant验证，Attention只改变context数量，避免所有参数笛卡尔积。若两者均失败，记录原因与本轮条件边界，不静默追加第五个context或更大FP阵列。

全图预算含Decision K4096等其它真实矩阵，不能由四种代表shape自动声明全部122矩阵硬件覆盖。K4096的G=128需要u8的group总数，单group索引仍u7；当前§3.5 TM4的u7 G计数只供其G≤82白名单。完整图接入前还须核真实shape目录、bias末阶段的group=G错误编码及所有计数，不借新7bit数据tag隐去这些边界；这不阻断现有ACT/QKV/Wi/Down微基准。

### 7.2 三路LOAD与W bank的可实现接口

新增独立reader候选由Q8 owner维护，使用q0、q1、scale三个512bit只读master及独立AUX bias读取角色；每口outstanding=1、INCR burst≤64beats、4KiB切分，端点可同时服务不同口但同口仍真实握手。q0/q1各目标64B/clk，scale仍按每拍8个half=16B解包，AUX bias目标16B/clk；两候选不改变这些参数。每个reader至少一完整64beat接收缓冲（4096B）并在发AR前预留整burst空间，R不能反压的内部返回还须预约写队列；只因三个端口同时置valid不算并发服务证明。

包布局沿现manifest：全局TN8 tile t的q来自shard=t%2，shard内地址`q_base[shard]+((t//2)*G+g)*256+lane*32+k`；scale地址沿§4.1。每个W槽完整支持K/N白名单及最大q5373952B、scale335872B、bias20992B，共5730816B，双槽11461632B，另计reader/FIFO/metadata/物理bank开销。不得用ACT或QKV较小数组的映射代替Wi最大容量。

W读侧分tile奇偶bank和8个列bank，每列一完整GS32的256bit读宽；TM4/TN8一次读取一个tile的256B并跨4行广播，条件TM16/TN16同时读取相邻两个TN8 tile、共512B/clk并跨16行广播。Ws对应一次8或16个half，精确half→F32解码的复制/端口计入；不把16bit存储带宽记成同数F32。写入只去非活跃W槽，其奇偶/列bank须分别容纳q0/q1同时各64B的写入；若工具把它们合为一个写口，服务按实际仲裁下调。

每槽状态固定`EMPTY/FILLING/READY/IN_USE/INVALID`，附完整包/会话身份、WeightKey、K/N/G/T、槽epoch、有效byte coverage和reader数。LOAD接受时增加槽epoch并清覆盖；q0/q1/scale/bias全部收到、实际片内写入和R债务退休、所选profile全部准入完成才READY。严格profile仍完成原scale检查；T3快速profile未集成通过时，不能把预检fixture当生产信任链来省略它。RUN获得只读lease，最后一次实际W/Ws/bias读取后归还；lease或DMA债务未归零不得覆写。预取失败只令目标槽INVALID，不污染当前IN_USE槽；reset清有效身份并排空/复位对应通路，禁止旧epoch返回命中新槽。

第一槽冷LOAD、最后排空、下一矩阵被当前槽使用者阻塞的时间都计入。当前矩阵全部合法RUN可复用该槽，预取下一WeightKey在另一槽进行；矩阵切换只改明确slot引用，不通过修改全局“当前W”指针影响已接受任务。Wi与Down可分别常驻两个槽，但不因此删掉Wi/GATE中间存储或宣称两任务已并行。

从当前manifest逐122矩阵复算：旧q0→q1→scale payload为7214120cycles=48.094133ms；三口及bias真正独立时的容量收费为`Σ_weight max(ceil(q0/64),ceil(q1/64),ceil(scale/16),ceil(bias/16))=2885664cycles=19.237760ms`。这是150MHz、每口满服务条件，不含请求间隙、bank仲裁、准入、冷首装载或依赖停顿；若三口不能独立则仍按实际共享服务相加。4KiB、AR/首R/尾R/片内commit及各口有效byte日志决定实际值，不能用名义128B总宽代替测量。

**当前限定实测。** [dual_w full05](../attempts/t4_dual_w_full_05/receipt.json)落实上述两槽逻辑bank、三口q/scale及独立128bit AUX、完整覆盖后READY和单读lease。完整Wi/Down/Scorer的10496/5248/2048个双TN8返回及reset后ACT8个单TN8均与冻结r2字节逐位一致；Wi全部读返回与Down填充重叠，STRICT scale非负有限/bias有限检查、目标错误隔离和lease/epoch/reset恢复通过。3328bit模型身份、672bit数值身份、96bit任务上下文用于本地保存/比较，仍由受控输入提供，不是新模型鉴权器。实际消费者为被动checker，未连接MAC、T3 REGISTER fast profile或生产Host。Wi READY54128、Down READY81200、Scorer扫描末110908为reset-relative事件坐标；末尾63仅为后一次reset计数，不能作为命令/整例性能。逻辑同步bank读与相邻双TN8宽度尚未经综合/P&R，512B/clk、19.237760ms及资源fit继续为条件，详见results集中章。

#### 7.2.1 ACT OOC02后双W的同容量1D bank修复（2026-10-11）

**实际原因与唯一修复范围。** OOC01的解析大小设置已在OOC02修正；[OOC02日志](../attempts/t2_act_production_ooc_02/guard/driver.log:370)随后明确报告多维qmem的`ram_style=ultra`因incorrect usage未推断为RAM，[821–823行](../attempts/t2_act_production_ooc_02/guard/driver.log:821)又报告qmem/smem/bmem为85983232/5373952/335872个register的3D-RAM运行成本警告，然后触发120s语义保护。无法仅凭警告断言最终映射必为FF，但已有足够依据停止对相同多维数组原样重跑。本次只将[`t4_dual_w_cache_v1.sv`](../../../vivado/module_design/hbm_loader_and_cache/rtl/t4_dual_w_cache_v1.sv:99)的大payload存储拆成**32个独立slot×parity×lane的1D bank模块**；不改变shape、容量、地址布局、数值、reader/DMA参数、owner/lease/epoch/coverage或外部端口。本节是集中架构修复合同，Sol可连续实现/编译/回归，无逐步审核或用户门。

**明确所有权。** 生产Sol独占该工作源的存储接线及新增`vivado/module_design/hbm_loader_and_cache/rtl/t4_w_cache_bank_v1.sv`，同时维护必要TB/Tcl和模块原design/results映射；其他owner不改同一RTL。冻结ACT06及旧dual-W全例均不修改，新的freeze记录旧依赖复用与cache/newbank差异。联合design/results仍由Astra集中维护。七shape bias/writer§3.7可独立推进，但本次新bank ACT回归保持旧ACT计算/输出接口，以分清受影响范围；两项最终合流后再跑组合受影响例。

每个bank只声明以下三个**一维数组**，不再通过顶层多维数组跨多个always_ff写同一大对象，不用合成巨型packed vector/组合读mux替换：

| 单个bank存储 | 深度×位宽 / 地址宽 | 外部写入服务 | 读出服务 |
| --- | --- | --- | --- |
| q | 10496×256=2686976bit；u14地址 | `q_we,q_waddr[13:0],q_wdata[255:0]`，每拍至多一次整256bit写 | `qs_re,qs_raddr[13:0]`，同步`q_rdata[255:0]`，!re保持 |
| scale | 10496×16=167936bit；u14地址 | `s_we,s_waddr[13:0],s_wdata[15:0]`，每拍至多一次16bit写 | 同一个合法qs读接受，独立`s_rdata[15:0]`，!re保持 |
| bias | 328×32=10496bit；u9地址 | `b_we,b_waddr[8:0],b_wdata[31:0]`，每拍至多一次32bit写 | `b_re,b_raddr[8:0]`，同步`b_rdata[31:0]`，!re保持 |

三者独立写口，不将q/s/b合成一个仲裁口；q保持URAM意图，scale/bias保持BRAM意图，使用常规单写单同步读推断模板。bank数据及输出寄存器**没有payload reset/初始化循环**；父层将所有rd/wr enable在`!rst_n`关闭，复位只撤销有效metadata/ret_valid，未读payload可以未知。单bank合法read和LOAD write来自不同slot，正常协议不存在同一bank读写冲突；RTL可保留旧非阻塞赋值的read-first行为，但不得依赖未验证的物理same-address collision语义，新断言必须证明合法父轨迹不同时读写同一slot。禁止为推断RAM增加外部可见的输出寄存级、降低512B并行读宽或取消背压保持。

**地址/使能逐项沿原式，不改布局。** bank实例下标`(s,p,lane)`均生成期常量。q写使能为`rst_n && fill_busy && fill_slot==s && out_valid[p] && out_ready[p] && out_offset[p][7:6]==lane/2`，q地址`out_offset[p]>>8`，256bit来自`out_data[p][(lane%2)*256 +:256]`；两个q口每拍可同时向另一slot的各2个列bank写256bit。scale写使能沿真实scale提交与`scale_tile[0]==p`，地址`scale_tile_base+scale_group`，每次8个lane独立写16bit。bias128bit提交的至多4个F32分别按全局元素`i=aux_out_offset/4+word`分到lane=i%8、parity=(i/8)%2、addr=i/16；四个word必落不同lane，本bank至多一个b_we，未覆盖word不写。宽地址先验证范围、epoch/offset/coverage，再切成u14/u9，禁止靠截断回绕；异常提交沿原fill_error/INVALID/排空处理。

q/s读使能为`rst_n && read_accept && read_slot==s && (read_pair || read_tile[0]==p)`，地址`(read_tile>>1)*G+read_group`；bias地址`read_tile>>1`，仅has_bias且相应tile/lane有效才需要b_re。所有valid/index/owner检查在父层原`read_ok`成立后发生，非法read不得触发RAM使能。相邻双TN8只准偶tile起始且tile+1<T；两个parity同时读，各8lane，共**16×256bit=512B/次**。整个缓存有32个bank，其中一个slot的16bank读，另一slot的16bank可接LOAD，不能误称同一slot有32个活动读bank。无bias/尾部无效lane最终返回+0，mask沿真实N，不把上一slot/旧bank的b_rdata带出。

保持当前同步时序：边E接受read，bank数据和父`ret_valid/ret_slot/ret_epoch/ret_tile/ret_group/完整model+numeric+context`在该edge NBA后同步可见；最早下一edge由ret_ready消费。`ret_valid&&!ret_ready`时不接受新read、不更改已选bank数据或任何返回字段；同拍消费旧ret和接受新read允许，保持最大每拍一次read/ret。b零选择需使用与该返回同一拍锁存的有效性/身份，不能直接受下一个未接受请求改变。旧release_ready等待最后实际ret、IN_USE禁止覆写、prefetch失败只INVALID目标以及整个AXI取消域reset全部沿用，不能因为payload模块无reset而允许旧身份读出。

**容量不变与单一物理闭合路线。** 32个模块各q/s/b全深度，逻辑总额仍91693056bit=11461632B，每槽5730816B；原三口FIFO、AUX、metadata、读返回寄存器另计。单bank q对象仍2686976bit，允许保留已核`var_size_limit=100000000`解析设置（不改变服务器保护帽）；不能退回默认1000000后把同一parser失败误判为新RAM结构失败。先对一个**完整深度、动态全部地址/数据/enable端口**的新bank做实际OOC，核q/s/b均为真实RAM primitive、地址宽/深度/读使能/保持语义及实际URAM/BRAM/LUT/FF，出现同类not inferred警告或数据转巨型FF则停止该尝试并保留具体原因，不原样扩大资源帽。单bank参数/端口/body及依赖相同，允许将这一个真实DCP向32个具名实例复用；必须记录其hash及完整cell映射，slot/parity/lane差别只在父端口接线，不能用不同深度的ACT专用bank代替。

为避免32次重复RAM推断及ACT常量剪小，后续固定采用已映射bank DCP装配：小父cache控制/reader使用精确同名同端口的bank stub综合，32个cell逐一回填同bank DCP得到**通用全容量dual-W DCP**；再在受影响ACT封装的cache cell回填该完整cache DCP，实际native FP依赖正常生成/解析。stub仅中间步骤，最终bank32份、cache与ACT均blackbox0，无缺失/重复/额外placeholder。保留这些具体层级边界，不能DONT_TOUCH全网阻断RAM推断；只在已映射bank/cache装配边界使用必要保留属性，不跨边界重新展开全量优化。父真实reader/FIFO/mux/tag/metadata及ACT算术/输出必须包含在最终资源报告内，不能把32×单bank报告当最终完整资源。此保留全容量的ACT封装是有明确配置的受影响模块OOC，不恢复整网OOC/P&R，也不说明ACT运行已使用全部七shape。

从单bank物理pilot到父cache/32次回填/ACT封装/最终报告视为一次综合闭合，**累计3600s/owned24GiB/任一活动工具120s无语义进展即停**，CPU0–3、nice19、idleIO、MemAvailable>192GiB、全树唯一`control/heavy_tool.lock`保持；不是每个bank或每一级重新领取3600s。单bank实际成本及剩余父阶段用于ETA，不能在已有预算外无限尝试。普通DCP cell路径/端口脚本错误可在同合同修复；如果单bank不推断、回填无法保留相同端口或总成本无法落帽，报告具体未闭合项，不把部分DCP升格为完整fit。无布线时不声称150MHz达到。

**新RTL的必要受影响回归。** 原ACT06/dual-W full05只在其原身份下保留PASS，新bank不能仅继承。先用新bank真实RTL全10496 q/scale地址及328bias地址写入地址相关唯一pattern，再完整读回，核u14高位/末地址、独立q/s/b写并行、同步一拍读和停读保持；该诊断只证明存储，不冒充真实权重。随后复用原r2独立字节fixture/端点做新dual-W完整Wi/Down/Scorer/ACT LOAD/所有读回和既有六load/10496重叠、wrong identity/epoch、IN_USE覆写拒绝、读返回背压、预取RRESP/坏bias目标隔离、在途reset及恢复。对其余三种真实shape1024/3072、1024/4096、4096/1024，按同已验证包选实际矩阵，完整LOAD/覆盖后逐q/scale/bias/mask读回；重点核G128的group127以及非法group128拒绝、Wi最高addr10495/tile655、奇偶/单TN8/双TN8边界。不能只装首尾窗口却force READY。

至少一段连续read/ret显示read_pair=1时真实每拍512B返回及另一slot LOAD提交同时成立，另加有限ret反压保持；这仍是RTL逻辑服务，不是物理Fmax或完整矩阵MAC。最后以新cache+bank和其余未改ACT06依赖冻结新身份，重跑原F32→quant16→完整双A发布/lease→双W→TM4/PS/bias→512writer两profile及晚输入错误/末B/活动reset恢复，保持全部原gold/断言。OOC单bank装配的必要短综合网表读写复验在原pilot帽估成本，未跑清楚记NOT_RUN；不得用HLS估算、源属性或黑盒stub证明RAM物理容量/可用端口。所有功能工具仍各遵守§0既有帽，不为新RAM身份重跑未改整图CPU或其它算术微基准。

**同容量bank实际出口更新。** [bank OOC01](../attempts/t4_w_cache_bank_ooc_01/receipt.json)已得到完整动态地址单bank：12URAM288＋6RAMB36＋2RAMB18（7 BRAM tile，8个RAMB primitive）、blackbox0，67.471913s/4199828KiB。不能把日志“BRAM=8”写成8 tile。按32个精确实例作容量投影为384URAM＋224 BRAM tile，仅属bank部分条件账；通用cache父层/ACT装配、实际存储端口与完整回归完成前，完整cache/ACT fit仍UNKNOWN。原总11461632B不变，当前生产owner继续同帽装配32份bank和原控制。

### 7.3 动态量化及A发布，保留完整两扫与数值

量化候选的逻辑入口为完整`NumericIdentity`、`TaskContext`、源/目的`BufferRef`、region、K及16lane F32流；独立新top接收16lane，**不把旧`QuantTask.input_lanes==8`的生产ABI悄悄改值**。支持K256/1024/2624/4096、1或4行微基准，后续按同接口扩到原16行task。所有输入按row/group/k顺序，末beat valid mask与实际shape匹配；源未全部合法发布时不能接入生产读取。

每组32元素的第一扫检查finite并求原amax；`d_full=amax/127.0f`、非零时`reciprocal=1.0f/d_full`、half RNE保存d_full，第二扫用原F32 `x*reciprocal`及roundf ties-away并查[-127,127]。保持+0/−0、tiny reciprocal溢出、half溢出及首错顺序；不由保存的half反算reciprocal、不近似除法。两扫仍执行，不将GEGLU/LN生产时的扫描收益提前记入本候选。

固定32个group暂存slot，每slot保存32×F32、amax/d_full/reciprocal、完整row/group身份及阶段状态；数据4096B外加metadata/返回队列。16bank的F32局部读侧在amax与quant两扫之间仲裁，容量目标每group4个读周期，即全请求2783264cycles=18.555093ms，除法/half/返回停顿另计。16个乘法通道与一条可流水的F32 divider是独立量化资源；目标group率1/4clk最坏需0.5次div/clk，divider实际II须≤2且有调度余量，延迟由测量决定。两次div有真实依赖，32slot不能被当成使divider免费或必然II1的证明；发出不可反压运算前预约对应slot，完整tag返回后推进。

A槽各保存原最大Aq65536B、As4096B及覆盖/producer身份，双槽数据139264B。一个槽供当前Q8只读，一个槽接受下一独立合法task的量化；row/group全部q32及half写完才置group covered，**全部task组成功且全部返回退休后才发布A READY**。首轮不允许Q8推测消费未完成task的早期group。A读侧按row分bank，TM4每拍4×256bit Aq和4个half As，条件TM16为16倍；同一group可跨输出tile复用，但不跨row/task错误复用。失败清目标A有效状态并保持已接受流水可排空，不影响另一个已发布槽。

首次实现只接完整K1024真实一行、K2624真实一行及零/极小/round边界短例，再由实际producer接TM4四行。局部输入来自外部fixture时明示，不称LN/GEGLU→quant整链通过。生产源epoch与A覆盖完成、Q8最后读者释放必须形成真实事件链。

#### 7.3.1 从功能入口落实16lane的实施细节（同合同内整改）

当前`laya_quant16_functional`的CSim与syn03只形成软件功能和串行RTL生成证据：配置显式关闭自动pipeline/partition，实际仅1FMUL/1fdiv、组数据单bank、q单8bit写口。此为`IMPLEMENTATION_GAP`，既不满足本节16M/16bank架构，也不能据它淘汰该架构的预算。owner可在既有独立模块内连续修改内部调度、banking、位宽/打包及FP服务连接并编译/回归；不改旧8lane生产ABI、16M/单divider/32组slot/双A容量、数值或成本帽，不新增Astra逐步放行门。HLS dataflow或局部RTL wrapper都是现行接口的实现选择，但报告必须显示真实结构，不能继续以C++循环名、软件`step`或人工排队一轮代表一个时钟。

| 接口/状态 | 可直接实现的固定细节 |
| --- | --- |
| 任务与组身份 | 当前独立top一次接受一个完整task；命令表锁存完整NumericIdentity、TaskContext、source/destination BufferRef与region/K/rows，源完整READY和目标A可写检查在首次数据接受前完成。两A槽仍受原lease/epoch约束。内部`task_epoch:u32`为本地命令世代，不能替代完整外部request identity；每组表记录ordinal:u32、row/group:u16、slot_epoch:u32，group总数能表示128。输入16lane beat仅在ready/valid握手时消耗，含task_id/source_epoch/row/group/half及16bit mask；输入row核为row0+row_local，A地址及原错误元素编码使用row_local，不能把全局row直接写入局部A bank。固定shape均为完整GS32，两个half的mask均FFFF |
| 32slot与两扫端口 | 每slot保留32F32，显式16个32bit bank；`bank=i%16, address=2*slot+floor(i/16)`，每bank深64、同步1R1W，4096B数据。CAPTURE用两个16lane beat写入，先完整保存；第一扫用两次本地16lane读完成finite/amax，第二扫用两次本地16lane读供16FMUL。CAPTURE可与其它slot的读重叠，但同址读写无旁路、不读未填half。两扫共用唯一16lane读服务，按两beat一组轮转，在AMAX_READY与REPLAY_READY两类均有工作时交替服务一整组；仅一类ready时可用空闲读拍。两次读的实际同步返回及max归并stage携tag，完成32值后才标AMAX_DONE。max选择保持原fabs、全+0初始化、相等取先前/较低索引；非有限位置取最低原索引，不能跳过两扫把4读周期账改成2 |
| slot状态 | `FREE→FILL→AMAX→SCALE_REQ→SCALE_WAIT→RECIP_REQ→RECIP_WAIT→QUANT_READY→REPLAY→Q_DRAIN→FREE`；d_full为0时从SCALE返回直接到QUANT_READY，reciprocal固定+0且第二扫输出全0。FAILED/POISON只在全部本slot真实在途债务已退休后FREE。首beat预约slot并递增slot_epoch；ordinal/task_epoch/slot_epoch必须随所有读、除法、乘法和写回返回核验。表可用位标志编码，并行返回只能修改自己的字段，不能以同拍最后赋值覆盖另一阶段状态 |
| 单divider请求 | 外侧统一`div_req_valid/ready`、numerator/denominator F32位型和token=`{task_epoch:u32,slot_epoch:u32,slot:u5,ordinal:u32,phase:1}`，phase0为SCALE：amax/127.0f（127=`42fe0000`），phase1为RECIP：1.0f/d_full（1=`3f800000`）。每slot同一时刻至多一笔div在途；RECIP只能由实际SCALE返回并检查finite后置ready，不能在发SCALE时计算两次除法再把结果放进软件return队列。两类候选均ready时轮转相位、相位内按最早ordinal，避免新SCALE淹没RECIP；仅真实握手才推进选择器/计数 |
| divider返回与预约 | 保留一个32项token FIFO，接受前同时预约token和所属slot的结果字段，最多32笔在途；slot未完成前不可复用。同一实际in-order divider的返回valid弹出最早token，逐项核phase/epoch/ordinal并写d_full或reciprocal，非法/无预约返回按协议失败隔离。若外层提供ready，必须保证每次合法返回可无条件落入预留字段，不用下游输出反压阻挡不可反压FP。若IP有两路独立operand ready，wrapper须先锁存成对operand并各握手一次，token以完整事务计；不得A已接受而B被换掉。记录两相位分别issue/return及待返数，成功终态`scale_issue=scale_return=组数`、`recip_issue=recip_return=非零d_full组数`，旧CSim的每组一次scalar计数不等于实际除法次数 |
| 真实IP及复位 | 优先复用有身份的当前F32 divider IP；syn03所含IP配置为Single/NonBlocking、c_latency6/c_rate1、无aresetn，这仅是配置事实。其HLS wrapper把operand valid绑1、以ce推进且不导出result valid，不能直接当ready/valid事务服务。服务wrapper需连接真实两operand valid和result valid、保持IP时钟使能运行；允许按真实配置对齐token但必须由实际返回验证。同步复位取消当前命令及预约；无reset IP在复位释放后先valid=0、clock enable=1排空覆盖实际最大延迟的隔离期，期间不接受新事务/不发布A，旧返回丢弃，隔离结束才复用token/slot；仅清FIFO后立即接新请求会把旧结果错配，禁止。复位可用实测延迟加已列外侧寄存构成固定排空界，不能凭软件延迟常数估计 |
| 16lane量化返回/A写入 | HALF_RNE对真实d_full执行；RECIP finite检查、half溢出检查完成后才允许REPLAY，顺序沿原函数。每次REPLAY读预约该slot对应half的16lane乘法/round返回位置，再发16个独立F32乘法；roundf ties-away和[-127,127]检查逐lane保留，不clip、不FMA、不从half重算reciprocal。每slot预留32B q返回payload和两个half完成位（32slot共1024B另计），最多64个half预约，不增加组context；由tag指定half/slot，返回没有无限FIFO。写侧至少能以128bit q半组加16bit lane使能真实commit，scale独立16bit写；两个half和scale都实际写入对应A槽后才cover该组。若实现导出单byte端口，则把服务降速计入而不能继续声称16lane吞吐已实现 |
| 错误、发布及观测 | first-error按原串行`row→group→finite扫描→d_full→reciprocal→half→每元素product/round/range`顺序选取；较晚组先返回错误，仍完成较早已接受组必要检查，后组可poison但已发返回必须排空。目标A失败时INVALID、不发布部分覆盖；另一已READY/IN_USE A槽不受影响。任务成功须全部有效组covered、全部本地RAM读/FP/token/q-write债务0及最终A写回实际完成，再置READY/done。观测固定为每相位首末issue/return、SCALE/RECIP计数和实际间隔、slot峰值/各类stall、两扫读拍、每lane有效运算、每组/任务写commit及done，附全部q/half/d_full/reciprocal逐位比较 |

16lane max归并和round/half也必须有可见实现/服务：逻辑比较可按保留最低索引的有限并行树与tag流水，不能把16次比较、round循环仍串行而在名字中标16。目标依旧是每组4次局部读服务、一个divider实际II≤2、16M和有限32slot共同支持既定两扫账，真实填充/依赖/返回/写入/尾部另计。单divider只有报告c_rate1而未发生连续接受不算测得II1；有限slot能否隐藏两次依赖除法按真实事件判断。满足原资源/数值的普通实现整改可连续进行；只有真实数值/服务下界或映射仍不能兑现且没有可检验修复原因时，才记录具体候选失败/阻塞，不通过增加divider、lane或slot掩盖它。

既有syn03若有合理成本依据，可在原pilot/正式帽内做一次有界真实数值RTL，范围如实登记；该串行功能结果可帮助验证FP基本数值，不能充当16lane服务通过。此数值基线不设为结构整改前的新审批门，也不反复生成串行top累积报告。首次符合上述结构的候选继续沿§7.3末段K1024/K2624完整一行及既定短边界，只有新的失败/修改才重跑受影响范围；生产LN/GEGLU→quant→TM4仍单列依赖。

#### 7.3.2 裸FP次正规数失败后的精确位适配候选（可连续实施）

`quant16_stream_real_03`已落实16bank/16M/单divider的局部服务，真实Wi32组/Down82组及既定部分短例通过；最终tiny输入`amax=006ce3ee`的实际SCALE返回`00000000`，RECIP未发出，错误发布成功。原F32应`d_full=0000db7f`、reciprocal为+Inf并按原顺序失败，裸IP候选当前为`NUMERIC_ARCHITECTURE_BLOCKED`。这是实际FP次正规数语义缺口，不由真实两行通过消除，也不能改成所有tiny/half0直接失败或全0成功。原日志和65组历史有限适配证明的边界见results集中章。

本节在原授权内冻结**一个精确位适配集成候选**，数据owner可在现有activation_quantizer模块连续实现、编译、修复及受影响短回归，不新增逐步审批门，不动tanh已停止方向。复用[既有位适配设计](../../../vivado/module_design/q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/source/design.md)及[r0_fp_bits_pkg.sv](../../../vivado/module_design/q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv)已证明的域划分；沿同一原F32逐步结果、独立gold、首错和量化q/half规则，不引入近似或新容差。保留16个原FMUL、唯一原F32 divider、32group slot、16bank两扫及双A容量，不修改历史适配器/冻结证据，不新建项目。

| 位适配位置 | 固定数学与实现边界 |
| --- | --- |
| amax/finite | 沿当前原始位域finite检查及非负magnitude整数max；±0归+0，非finite先按原元素顺序报错，全部32元素第一扫完成才允许该组SCALE。不用失败FP comparator识别subnormal或零 |
| SCALE tiny | 对非负finite `amax_bits<=03fe0000`，以2^-149为单位：exp0时U=fraction，exp1..7时U=(800000\|fraction)<<(exp−1)，U为30bit且最大127×2^23。精确q=floor(U/127)、r=U−127q；d raw bits=q+(r>=64)，127为奇数没有半整数tie。包含d=0和上端d=00800000；不能先做normal FP除法再缩小造成双重舍入。其它amax仍走原F32 amax/127，输入/结果均normal |
| tiny服务 | 明确实现一个共享6级、每级处理5个MSB的常数127 restoring除法流水；每一步以8bit `{remainder7,next_U_bit}`比较/减127并推进30bit quotient，末级由7bit余数RNE，II目标1。无需额外FP divider、通用乘法器或group slot；不能以未流水的组合`/127`宣称满足时钟。它是原F32除法的精确位实现，逻辑LUT/FF/延迟照计 |
| 单divider及返回队列 | 保留每组一次语义SCALE请求。tiny请求同时给唯一FP IP安全dummy `0/127`，正常请求给真实操作数；六级helper随请求携原token及预约index。复用现有32项divider预约环，增加route、FP返回有效/数据与helper返回有效/数据字段；issue tail、FP return写指针与semantic retirement head分别推进。只在head的实际FP result_valid已到且tiny helper亦已到时，选择正确结果发出**恰好一次**语义返回；不以预定cycle伪造FP valid，不让正常返回越过较早tiny。dummy实际IP请求/返回单独计数，不能称为数值gold计算。32项pending包含已返回未退休项，full自然反压 |
| RECIP | 位域d==0才直接reciprocal+0；非零normal d沿原1/d。subnormal d=M×2^-149先用纯位`subnormal_up24`精确构造normal D=d×2^24，仍只向同一FP divider发一次1/D，实际返回后以至少9bit指数加24恢复，指数>=255为+Inf。不缩放significand、不再舍入一次。d<=00200000的非零subnormal会溢出，00200001起可能finite；仍由恢复后的真实结果走原finite/half检查与错误phase，不提前跳过归属/返回 |
| 16lane乘法 | 全部原组检查成功才第二扫。使用已证route：d位域0、x位域0或`floorlog2(abs(x))+floorlog2(recip)<=−4`时q必为0；非zero subnormal x的其它route将x精确up24、normal reciprocal精确down24，再用原FMUL，真实乘积相同且结果normal。normal route直接用原x/recip。每half仍发16个原FMUL；q0旁路lane用安全dummy0×1，并携route位与原half/slot/token，等待对应真实FMUL valid后才置该lane q返回，禁止提前写A或归还credit。旁路不声称内部dummy product等于原F32 product；活动FP route逐位核真实product与原gold，全部route核q/status |
| rounding/错误 | 原half RNE、roundf ties-away、[-127,127]拒绝不变。先d finite，再非zero reciprocal finite，再saved half finite，最后逐元素product/round/range；half0不能替代d_is_zero。适配数据不覆盖row/group/phase/element首错rank，后组先失败仍等待可能更早错误。失败无目标A READY，所有已发返回、helper、排队输出与写commit债务排空 |
| reset/计数 | 原token完整包含task_epoch/slot_epoch/slot/ordinal/phase，helper与FP各只写原预约项。无reset FP时继续时钟并沿现12cycle隔离窗口排尽原latency6 IP及6级helper；隔离中不接新请求、不将旧返回写新环，新任务仍须等全部通路reset隔离结束。半组FMUL及q旁路metadata按同域reset/旧返回丢弃，不能只清FIFO立即复用。分别报告SCALE/RECIP语义issue-return、FP实际issue-return/dummy、helper issue-return、queue pending/highwater和所有退休数，守恒不能把一次dummy与一次helper算两次SCALE |

局部新增存储严格来自已有32项token环的有限字段和六级helper寄存、16lane路由元数据，不增加组context/返回无限队列或另一divider。每stage五次常数比较/减法、normalization前端/指数恢复、head选择与新增控制路径均实际计入；6级不自动证明150MHz，LUT/FF/时序/总体fit在未执行物理阶段时仍UNKNOWN。本轮只做原帽内局部编译/RTL服务核查，不解锁整体OOC/P&R/专项时序。实测报告首末请求/返回、填充/尾排空、队列峰值和stall；新的服务若不能维持原group/4读周期目标，按实际延迟收费，不能增加FP实例/slot或沿用裸IP141/341cycles。

**一次有界受影响覆盖**复用已冻结真实Wi/Down两行完整q/half/d_full/reciprocal及原两扫/commit/READY检查；追加到同一service TB的小组包括：本次006ce3ee→0000db7f→Inf失败；amax位型0/1/63/64、00800000、02fdffff与02fe0000..02fe0005（reciprocal溢出相邻边界）、03fdffff/03fe0000/03fe0001（tiny/normal route接缝）；037e0000组的正负001fffff/00200000/00200001半整数相邻值，要求d00400000/recip7f000000及相应q；normal组夹带signed minsub/±0、原half溢出与nonfinite首错例。所有期望由原独立精确R0参考产生/复核，不调用新helper；保留当前失败原始日志，不重跑旧独立65group套件来代替当前集成。

混合正常/tiny/zero组连续接受并施加原输出有限反压，核返回顺序、真实IP/helper计数、slot守恒和唯一commit；在tiny helper、归一化RECIP及FMUL/旁路至少各一个实际在途点整域reset，隔离后用新epoch恢复合法短组。维持原第一扫全finite优先、跨组首错及两扫各2读拍，不以特殊值绕开供数服务。若数学比对失败，按明确位运算/metadata原因原合同内修复；若需要新近似、增加配额或无法在原帽内完成此候选，则带具体冲突停止该方向，reader和Q8S2不等待。通过此候选后仍只接受单row外部fixture局部服务，完整NumericIdentity/双A/生产LN或GEGLU→quant→TM4依赖须另有真实连接证据。

**实际限定验收已完成。** [adapter01收据](../attempts/quant16_stream_adapter_01/receipt.json)及257项输入闭包通过集中复核；原独立有理数gold所选27例与mixed6重新逐字段核对一致。本节精确候选记`PASS_SCOPED`：原tiny正确得到0000db7f/Inf并拒绝；27边界17成功/10拒绝、mixed6及helper/归一化RECIP/FMUL旁路三种实际在途reset恢复通过。精确服务本次真实Wi/Down仍141/341cycles、两扫各64/164beat，SCALE实际间隔1..4、slot峰值24/32、divider预约峰值7/7；真实FP64/64、164/164且这两行无dummy/helper，mixed有真实FP11/11及dummy/helper4/4。首次done实际物理/语义/返回债务0，详细计数与身份见results集中章。这只解除所测单row服务的数值阻塞；裸FP real02/03历史FAIL、完整身份/双A lease/生产连接缺口、LUT/FF/fit与物理频率UNKNOWN继续保留，未把配置II或仿真时钟当150MHz证据。

#### 7.3.3 完整GEGLU来源、通用双A与Down交接合同

本合同补齐ACT K256入口不能覆盖的生产桥。真实来源为[`full_tasks_vector.cpp`](../../../hls/operators/full_tasks_vector.cpp)、[`vector_full_compute.cpp`](../../../hls/operators/vector_full_compute.cpp)和[`activation_quantizer_compute.cpp`](../../../hls/operators/activation_quantizer_compute.cpp)；继续使用原13BO/地址/owner ledger。新桥是内部RTL服务，不新增Host BO或CPU中间计算。K白名单为256/1024/2624/4096，G分别8/32/82/128；K用u13、G总数/进度u8、group索引u7、rows总数u5（1..16）、row_local u4、全局row u16，列u13。接受命令前逐项核对原stage/row_space/source：stage2 TOKEN的K1024只收HIDDEN/NORM/ATT_OUT，K2624只收GATE；stage4 TOKEN的K1024同前、K4096只收DEC_FF；stage5 MARKER的K1024只收HEAD_WORK/SCORER_ACT；stage6 BATCH的K256只收HEAD_WORK/ACT_HIDDEN。原QuantTask.input_lanes=8是生产描述符合同，内部512bit/16lane供数不得擅改该ABI字段。

**先保留原任务发布屏障。** GEGLU每行先按原顺序从真实WI owner完整捕获5248个F32（U2624及G2624，共20992B），源读响应/身份/范围成功后才开始该行算术；不是收到第一对U/G就覆写物理GATE。原每col检查顺序为G有限→gelu_scalar(U)内部原检查次序→gate独立F32乘法及finite；整行2624结果与所有算术返回成功，才允许将该行10496B写到原GATE区域。按row升序处理；数值错误按(row_local,col,原check顺序)选首错，原`bad_element`仍为G失败的2624+col或GELU/gate失败的col，不拿串流failed_step或最快返回替代。全行源读取故障优先于该行算术，保留生产预检查/IO/数值错误类别。

已有完整gate row暂存10496B用于此屏障；Wi及gate数据共31488B，若与另一模式RAM确实复用须用实际映射证明，不能在账上免费抵消。标量串流返回接口为`v_valid/ready,data:u32,status:u32,frame_tag:u32,row:u16,col:u13,last`；tag绑定下述完整命令，col严格0..2623、last仅末col。接收器可在内部存储成功前缀，但row_success必须等全部返回、原首错归约和覆盖完整；迟到错误撤销整行。原只有frame_tag的row wrapper须加完整驻留命令/epoch匹配adapter，不能把裸tag当完整owner。物理writer仅取row_success暂存，按原GATE地址逐byte写并独立计AW/W/B及打包债务；逐行已写内容仍属FILL目标。所有task行覆盖成功、真实末B/所有写债务0后，controller才按原full_cover_owner发布本task的合法GATE覆盖并返回成功。其它任务尚未覆盖的owner行不凭此变READY。随后quant只可acquire本task全部所需已发布行；不在同一失败尚未排空的GEGLU task内发布早期A。该首版保留GATE物理写后再读的成本，跨阶段直通或省略BO写回不在本次合同内。

| 内部边界 | 固定信号、身份及握手职责 |
| --- | --- |
| `bridge_cmd_valid/ready` | 一份驻留命令含NumericIdentity[671:0]、producer/quant/consumer各TaskContext[95:0]、src/A及预期W/dst各BufferRef[63:0]、region/K/rows/row0/batch、A slot及slot_epoch:u32；源producer context来自真实完成owner，后继context只是期望值，不能代替实际claim/acquire。完整Ref含id/bank/region/epoch。预检查、源覆盖及A合法空槽完成后接受；表直到所有读/quant/A写/完成响应债务0保持不变 |
| GEGLU完成到GATE来源 | `producer_done_valid/ready,status:u32,bad_element:u64,producer_task_id:u32,dst_epoch:u32,covered_rows:u16,write_debt_zero`，与稳定表和实际ledger核验；成功不能由TB强置READY。rows bitmap是task-local，source owner原全局覆盖仍独立核对 |
| row到quant16 | `row_start_valid/ready,cfg_task_id:u32,cfg_source_epoch:u32,cfg_row:u16,cfg_groups:u8`；数据`in_valid/ready,data[511:0],task_id:u32,source_epoch:u32,row:u16,group:u7,half:1,mask[15:0]`，一个row只start一次，g递增且half0→1，两个mask均ffff，lane i对应col=32g+16half+i，F32低lane在低bit。valid且!ready时全字段稳定，拒绝错身份/重复/乱序/越界而不索引RAM |
| quant16到A | 保留实际`out_valid/ready,group:u7,half:1,q[127:0],scale[15:0],d_full[31:0],reciprocal[31:0]`；row/task由唯一活动row表绑定。half0的scale=0不写scale；half1的scale在q高128bit写握手时写入同组。诊断d/recip只用于gold/观测，不成为新CPU数据源。新row不得覆盖尚未退休的前row命令 |
| row/task退休 | 原`done_valid/ready,status[1:0],first_bad_col[15:0]`保持，0成功/1数值/2协议；显式导出input/read、slot、SCALE/RECIP、FMUL/helper、返回队列和A物理写debt_zero。done成功只确认该row，外层仍累计所有row；错误元素沿原quant编码`row_local*4096+group*32+col_in_group`，first_bad_col须先验K范围 |
| A到Down读lease | `a_acquire_valid/ready`携同NumericIdentity、真实LinearTask/Ref与K/rows；返回slot/slot_epoch只绑定已发布完整A task。读请求含row_block_base:u4、合法1或4活跃row、group:u7；同一group同步返回最多4×256bit q＋4×16bit scale及完整句柄。最后实际read return之后才释放该lease；发射结束不是释放事件 |

通用F32供数暂存固定两个完整row槽，每槽4096×32=16384B、合计32768B，按16lane各256×32的一维bank实现。源为上述真实BO read服务；完整row的K/16个512bit响应、byte coverage和读债务清零后才标row_buffer_ready，另一个槽可预取下一合法row，不能无界排队。供数槽由最后quant输入接受且本地读返回退休后释放；来源owner的只读lease可更保守保留到quant task结束，不能早于最后真实BO读取返回。GEGLU上游Wi/gate暂存、这两个F32槽、quant16原32group/4096B暂存和下述双A是不同存储，各自收费；两个row槽允许预取，不新增第二quant算术实例。

完整双A固定为每slot 16个独立row bank，每bank `q[0:127]:256bit`（两个128bit半写使能）和`scale[0:127]:16bit`。每slot q65536B＋scale4096B，双slot139264B；不复用ACT当前仅8group的一行544B实现冒充完整容量。fill槽仅写，READY且有lease槽仅同步读；同bank不同half写按实际RAM字节使能或两个128bit物理bank实现并计资源，不能依赖未验证的写合并。q半覆盖与scale覆盖独立：两半实际写完成、half1 scale写完成才置group covered；全部rows×G覆盖、所有row done成功、32slot与FP/helper/返回/A写债务全0，controller才将该A owner由FILL发布READY。所有payload RAM无需reset清零，metadata/coverage/valid/lease须reset取消；G128的done计数不得7bit回绕。

任何晚行/末group数值错误、错完整owner或A写错误使目标A INVALID，已写前缀不成功发布，不影响另一slot合法已有lease；排空已接受返回后才能换命令/epoch。整域reset取消GEGLU、row暂存、quant、A及实际端点的同一取消域，保留quant精确adapter原12cycle恢复隔离；不能取消的外部AXI必须先drain并隔离旧响应，不能只清债务。新命令须重新核真实owner、合法epoch和来源覆盖，不降epoch高水位。

首个有界真实链固定一整行WI5248→实际GEGLU2624→GATE真实写/发布/读lease→quant16完整82group→完整A发布/读lease→真实双W的Down K2624/N1024→1024个物理输出及末B。原Wi checkpoint可作该片段外部输入，但GATE/q/scale/PS/bias输出不得预置；随后补四row边界和其它K的完整覆盖/高group/晚错、读写反压、两A交叠及reset/恢复，再接真实Wi Q8 writer。原K1024/2624 quant数值gold复用，新bridge和生产owner必须实际RTL；CPU/CSim不代签。全16row部署能力按实际完整覆盖验证登记，首个一行PASS不扩称16row或全图PASS。vector负责完整U/G→gate及有界row adapter；production负责真实GATE writer/ledger、通用row feeder、quant命令、双A和Down，双方使用本表，普通连接/修复连续推进。

#### 7.3.4 生产量化与Q8调用粒度：完整row/task和完整group循环

当前生产C路径每Group32调用一次`laya_quant_blackbox_smoke`（输入31×u64、输出23×u64，14字owner），其HLS05报告latency156/interval157仅为该同步函数wrapper估计。若实际controller逐次等待32次调用，K1024会支付约32×该间隔，不能继承独立quant16同一row连续32group实测141cycle；82group的341cycle也不可继承。新的有界服务按§7.3.3**每task绑定一次完整owner、每row start一次**，其间持续两half/group输入、复用原32slot流水，两扫和全部真实divider/helper/写回债务保持。row间尾排空照实收费；不要求先实现跨row量化重叠，也不增加slot/算术。可用ap_ctrl_chain命令头＋真实stream或同等局部RTL controller，必须按实际ready/done/CE采样，固定函数latency元数据不代替可变时延等待。

同理`laya_tm4_blackbox_smoke`的112×u64输入/57×u64输出及16字owner，只证明一个Group32的生产数值绑定。新Q8服务至少把**同TN8输出tile、同1/4row块的全部G组**放入一个已绑定命令；A/W read lease、真实cache读返回、group递增、原TM4算术和PS/Q35反馈均驻留，下一组只受真实PS依赖/credit/端口控制，不经历完整函数重新绑定/复制owner/清PS握手。每row/lane仍严格group0..G−1顺序逐F32累加，bias独立一次，最后group实际返回后才转§3.7输出。全矩阵可由同一controller锁存一次父任务，按tile和row block推进；内部tile命令不是新的Host task或owner claim。更大rows任务保留原完整TaskContext，子view另存row_block_base且不得修改原task高水位；不足四行可分成合法单row view，不向现有writer偷传rows2/3。PS/bias/writer局部row字段加row_block_base后才是父task row，错误归约和bad_element均用原父row，不能每块重置首错。父任务须遵守原逐tile的检查/失败优先级，完成全部所需tile/row及末B才发布整体覆盖。

先用同冻结K1024/2624真实row分别测32/82group量化，以及同TM4完整G tile的接受/读取/PS/最终写回事件；对照独立服务与现同步wrapper，分别报告总cycles、持续组间隔、首尾、owner/配置、RAM/FP/PS stall和真实实例数。新增服务的实际生成controller必须证明单quant/TM4实例、返回不丢/不重、owner不换、有限credit以及G128。首轮可接受数值正确但未提速的完整连接，继续独立cache/数值/controller工作；**函数被调用或C/CSim通过不记性能改善**。多tile/row的重叠收益只有真实端口/lease/有限存储和生成RTL服务成立后才入全请求账，不用人工延迟或理想FIFO投影替代。

### 7.4 T4最小验证与淘汰出口

先复用T1实际端口/切换gap服务参数，做有界reader地址/byte模型；最小RTL reader例覆盖真实Wi/Down的首尾burst、4KiB边界、tile511/512/655及group63/64/81映射。窗口读只能发布窗口诊断，不发布完整W READY。若宽burst/三口并发或奇偶bank写入不成立，即已足以否定19.237760ms条件，不先跑完整Wi计算。

通过后一次完整Wi→Down双槽LOAD验证全q/scale/bias逐byte一致、当前槽被读时下一槽填充、延迟最终R/片内write、wrong epoch、reset、预取失败隔离；消费可用带身份的被动读checker，报告为供数/lease测试，不能冒充真实MAC。量化用上节完整K短例核全部q/half和每组d_full/reciprocal，再接已通过TM4算术。各步骤先pilot，沿§0成本帽；slot扩容、第三套读口/并行度不由普通修复隐式引入。

本轮已完成reader/双W供数及精确quant16两个独立出口的所列有限覆盖；它们尚未连成量化→TM4/Q8生产链。按§8.4.6已测tanh数值FAIL及尚未接通的producer，完整Encoder/全图真实producer T6/T7保持NOT_RUN_DEPENDENCY；旧REJECTED_BUDGET只保留50ms参考口径，不以独立供数/算术通过隐含启动新libm图、全图TB或整体物理验证。

## 8. T5条件设计：Attention反馈与有代价的向量服务

### 8.1 跨模块身份与有限缓存

本轮Attention微基准固定真实B1/S128、单layer/head、D64，query完整0..127；C3/C4只并行同一head的独立16query task，**不把三个request或不同head共用partial来凑反馈窗口**。每context记录完整NumericIdentity（request_id/generation均u64、B/S及四个128bit tag）、原QK/softmax/AV TaskContext、query row0/rows、head、mask_mode、KV/score/prob/partial/dst的BufferRef及epoch。可在本地表保存全记录，流水携slot:u8、slot_epoch:u32、task_id:u32、row:u16、key:u16、lane:u8；必须全字段匹配表且slot不得在任何返回/读取债务存活时复用，不能截断request identity后用短tag“近似匹配”。这是微基准内部接口，不覆盖旧生产QK固定score bank0等限制。

每head K/V为2×128×64×F32=65536B，当前/下一head双KV槽131072B；下一head预取只能写空槽，旧head最后V/K读取退休才可释放。Q双tile各16×64×F32，合计8192B。独立SCORE工作槽2×16×128×F32=16384B；softmax成功PROB按整个16row tile转移到AV context的prob存储，C3/C4分别24576/32768B；AV partial分别12288/16384B。PROB复制目标16F32/clk，全请求7864320个prob F32逐元素计量，即31457280B，满64B/clk为491520cycles=3.276800ms；复制是独立端口服务，不能与读写同bank冲突时仍取免费重叠。

SCORE遵守`EMPTY→QK_FILL→SCORE_READY→SOFTMAX_OWNED→PROB_READY→COPY→EMPTY`；AV context遵守`EMPTY→PROB_COPY→AV_READY/ACTIVE→DRAIN→EMPTY`。每个16row tile的完整score/max/exp/sum/prob合法性成功后才交给AV，不为吞吐将softmax改为在线或跳过掩码key。额外softmax row scratch见§8.3，QK/AV返回队列见下节；上述容量不含metadata/port复制。物理银行数、BRAM/URAM碎片与LUTRAM成本必须列出；微基准S128容量不能自动缩减生产原B2/S1024支持数组。

first-error按原各op的源程序检查次序/元素与树level索引排序，预检查、算术phase和task次序分别保留；并行返回最快者不自动成为首错。任何context出错使本head成功发布失效，不发布成功ATT_OUT。数值错误后仍完成其它row/元素中可能排序更早的检查，已知失败链可poison后续无优先级的运算，不能因较晚row先报错而漏查较早row尚未计算的key；协议/身份错误则拒绝该输入、停止不可信的新算术。两者都排空全部已接受返回/复制/写响应后失败终态。错slot_epoch、错head/row、错KV/prob来源及reset恢复用短例核查，新head不能复用旧债务仍存的槽。

#### 8.1.1 当前生产Attention服务接线（单实例功能候选）

实际来源为[`attention_service.h/.cpp`](../../../vivado/module_design/attention_and_fp_engine/source/attention_service.h)、[`attention_service_hls.tcl`](../../../vivado/module_design/attention_and_fp_engine/tb/attention_service_hls.tcl)、[`attention_make_blackbox.py`](../../../vivado/module_design/attention_and_fp_engine/tb/attention_make_blackbox.py)及生产`hls/operators/full_tasks_attention.cpp`。这是先连通生产的单实例串行命令服务，不将其视作§8.2 F256/C4或§8.3四exp吞吐结构的已实现版本。C接口为`laya_attention_service(command,index,payload,epoch,result,status)`，六字段均32bit；冻结数值QK相邻树→完整softmax→按key顺序AV及原16row阶段屏障保持。

服务端驻留55个u32绑定字：NumericIdentity21、QK/SM/AV各4字Context、KV/SCORE/PROB/AV_PARTIAL/ATT_OUT/QKV0/QKV1各3字Ref及head/mask_mode1；后续读回所有55字与原controller记录核对。局部Ref序列化为id/bank、epoch、reserved0三字，不与Q8§3.7的64bit驻留编码混用。task_id+1/+2及未来partial epoch的预测必须在实际SM/AV claim后逐字段核对，预测自身不构成claim、owner或生产连接PASS；绑定时dst必须来自本层真实FILL owner，完整layer/head/row范围一致。功能B1当前路径与B2旧leaf分别记账；单实例声明仅指此service，若完整top仍包含B2旧leaf，其RAM/FP资源亦须实付，运行时分支不等于综合删除。

RTL实际边界必须为`ap_clk, ap_rst(同步高有效), ap_ce, ap_start, ap_ready, ap_idle, ap_done, ap_continue`和四个32bit输入、`result/status[31:0]`及各自`*_ap_vld`。外层最多一条未完成命令，输入由接受到规定采样边界保持；从真实idle/可启动状态提出ap_start并按该leaf实际协议保持至ap_ready确认，不能先等一个仅在完成时出现的ap_ready再启动；结果按真实ap_done/有效返回捕获一次，再以ap_continue确认退休（统一细则见§8.1.2）；ap_done保持期间不得重复消费或启动重叠修改状态的命令。JSON中的latency/II=1仅候选调度元数据，不能按1cycle合成完成脉冲；必须在实际生成的调用wrapper中证明可变时延退休、唯一service实例、结果稳定和下一命令依赖。若工具无法按该协议正确等待，则在原接口范围修复adapter/调度元数据，再测受影响调用，不能用C模型绕过真实RTL。

`ap_ce=0`必须一致暂停FSM、RAM地址/CE/WE、流水valid及实际native FP的aclken；仅暂停顶层FSM而让内部FP向前运行不合格。持续ap_done/返回必须跨CE暂停保留。ap_rst取消旧命令有效性、bound_epoch/bind_count及全部覆盖/phase，数据RAM无需清零；恢复前完整RESET→BIND→装载，旧epoch请求和旧FP完成不得成功发布。软件RESET/RELEASE命令是已排空边界的状态操作，不能当作活动硬reset覆盖。RAM真实读延迟、相同地址读写语义、CE/WE及活动reset由生成RTL测试确认，不能仅引用HLS pragma。

当前源码K/V各65536F32、SCORE/PROB各16×1024F32，仅这四项就是5242880bit=655360B；另付Q64、exp1024、tree1024(cyclic2)、y64、mask、55字绑定及所有metadata。保留生产支持容量，不为B1/S128功能样例静默缩水；若全部使用18K BRAM，四项原始位数已需至少285块，69块HLS估算不能作为物理容量证据。单口K/V/SCORE/PROB及tree双口、y S2P按实际生成端口/映射收费，整体OOC仍未授权，仅该受影响模块及必要接线封装OOC。

已存在独立CPU数值证据与旧ap_ctrl_hs HLS估算；新chain+ap_ce及scratch query标签必须用新冻结身份取得实际RTL：真实FP oracle、全query/head完整行、错head/ref/旧epoch、跨row scratch拒读、末key非有限不发布、完成保持、FP活动CE暂停/恢复、FP活动reset和完整重载。所有native `*_ip.tcl`、wrapper和`.dat`要由实际外层工程解析/生成，blackbox JSON不是已实现IP；OOC最终未解blackbox必须0，资源/时序仍与功能分开。现行原帽下普通修复连续进行，不增加逐步审核门。

**当前实际限定出口更新。** [formal01](../attempts/t5_attention_service_rtl_formal_01/numeric_result.json)已通过B1/S128 enc0/head0 query0..7、每query完整K128/D64及协议/CE/reset，856061cycle/205.234928s；完整128query正在原帽执行，不能由8query代签。[同CE身份模块OOC01](../attempts/t5_attention_service_ooc_01/ooc_result.json)已完成247.965558s、5694292KiB、blackbox0，10399LUT/6282FF/22DSP、145RAMB36＋7RAMB18=148.5tile（297 BRAM18等效）、0URAM。HLS69 BRAM估算由该实际模块账替代；综合WNS2.807ns且171个外部端口缺IO delay，仅内部端点已约束，不作为部署150MHz证据。1M/1A/1D服务仍需按480head全工作量及实际任务/装载尾部收费，不能由局部正确/OOC通过宣布吞吐目标。

#### 8.1.2 quant/TM4/Attention共同的可变时延调用与完成登记

**实际触发原因。** [quant generated02失败](../attempts/t2_quant_generated_rtl_02/failure_receipt.json)为真实leaf cycle42 issue、80 return，生成parent因JSON latency128直到state145才等待done，而`ap_continue=1`已消费早到完成，512cycle TB超时。数值leaf是否正确与该调用死锁是不同结论。当前JSON改1/1只把parent最早等待点前移，是可连续实施的调度修复，既非实际latency/II测量，也不保证所有更快分支已安全。quant、TM4及Attention都执行本节；HLS C函数返回、固定计数到期或旧C模型不能制造完成。

| 边界事件 | 统一实施规则 |
| --- | --- |
| 请求提出/真正启动 | 外层最多一个未退休call，先锁存完整命令/owner及调用序号。对于现quant/TM4的IDLE接start实现，`!reset && ce && state==IDLE && ap_start`才是实际launch；ap_ready只在REPORT/continue出现，不是启动前门。HLS leaf按其真实初始状态转移同样登记launch；ap_start按实例协议保持到ap_ready确认，不因idle期间ap_done或推定latency登记交易。命令payload在leaf规定采样区间保持，最保守保持至本call完成 |
| 动态等待 | 生成parent必须在最早合法实际done前进入或持续覆盖等待，且任意长路径均由真实done解除阻塞。调度metadata可用经生成RTL核验的最小下限1/1，但不得让工具依据它不检查done就读取结果/启动下一call；不能把1写成硬件II1。普通、zero、tiny数值拒绝和控制拒绝可能长短不同，均检查实际FSM及连续调用 |
| 完成/结果采集 | `call_active && ce && actual_done`才允许登记一次完成；每个输出的实际`*_ap_vld`独立捕获，使用valid bitmap，早于done的结果保存至done，晚于done的必要输出未齐则仍不得发布。owner echo/结果/status/bad element全部必须属于当前序号。得到完整响应后存入一份不可覆盖响应槽，或证明生成parent在该edge直接捕获全部字段；done持续高不得反复提交 |
| continue/下一次调用 | 标准chain由接收方确认已存好完整响应后驱动continue，hold期间数据/valid稳定；生成parent把continue绑1只有在所有合法完成edge均处于实际捕获/等待窗口时才接受该接线。顶层done须晚于响应复制及输出RAM最后真实write commit，不把leaf done当外层已写完。前call尚未被外层接收/写完时不复用owner或响应槽；下一个start必须对应新的唯一launch，不能把保持高的旧start误作新命令 |
| CE和reset | 区分两种已声明模式：Attention现有CE闭包是全域暂停，FSM/RAM/FP/有效位同步暂停；quant现工作源是caller/返回保持，内部quant可继续前进到已有有限输出/完成槽，外层CE=0期间不发生边界握手、结果不得丢失，恢复后只提交一次。后者不能写成全域状态冻结PASS；若采用自由运行核，全部不可反压返回必须有预留且在运行时钟域持续捕获。禁止只停消费者寄存器却让无缓存返回越过。reset优先于CE，取消call/response有效性和epoch，原实际端点/隔离债务要求保持 |
| 身份职责 | Group32 leaf的完整896bit owner回显只是绑定保留，不等于来源/A owner合法性判定；拒绝坏NumericIdentity/Ref/claim和零issue断言放在实际caller ledger/§7.3.3 bridge。TM4同理。Attention55字绑定的既有校验仍执行；短tag/echo成功不能代替producer真实READY/lease |

若1/1生成parent仍无法保证最早完成捕获，停止猜一个更大的latency。采用**一个显式有界请求/响应adapter**作为同一接口修复：1份锁存cmd、1份response，内部`IDLE→LAUNCH→WAIT→RESP`；真实launch一次，WAIT在每个实际运行edge采集所有valid和done，只有完整真实响应进入RESP；RESP按ready/valid保持到caller接收。HLS调用方使用真实阻塞的command写/response读stream（或等价真实FIFO读空阻塞），其返回只由响应握手驱动；外侧仍原C任务/13BO身份，适配不是另一计算模型。若某leaf自身只有脉冲done，adapter在该实际edge登记pending；不得按常数延后/合成done、删掉真实等待或改gold。新adapter所用队列、时钟域、CE/复位和caller生成RTL均纳入同次证据；这条有限修复不扩大并发call数。

受影响生成RTL用相同snapshot完成至少两个连续合法call及最快zero/控制拒绝、正常最长、tiny失败后恢复；quant数值错误实际leaf测，坏owner实际caller测。覆盖CE在launch/结果前/结果保持三处、真实FP活动reset、输出RAM/响应背压及末写；事件必须能核`accepted = retired + active + reset_cancelled`，每call一份完整response、每字段和输出地址恰一次写、父done时全部债务0。没有受影响算术变化则不重跑完整gold库。Attention的standalone head128 PASS、quant独立row PASS、TM4 CSim PASS均不能代签各自新的generated caller；官方JSON/RTL/IP/memory-init/receipt闭包仍须同hash及实际唯一服务实例。

### 8.2 共享QK/AV服务及反馈微基准

**当前执行优先级：** 本节F256/C4仅保留有条件的远期资源/调度论证；当前实际可派发阵列为§8.3.1的精确M16/A16/D4单池，不将下面理想周期登记为已实现服务。

最终条件F256指4个query×完整64feature，而非256个任意partial地址。QK同一key的K64向4个Q64广播，4个独立64乘积相邻树，随后原乘0.125和finite mask合并/相加；AV同一key的V64向4个prob广播，形成256个独立product并各自FADD。4query可来自同一context的连续4row，按context/四row组轮转；对每个(query,d) key必须0..127升序。全mask为有限−10000规则，仍计算全部key；禁止FMA、平衡AV sum或替代QK树。

每拍外侧KV读64F32=256B，QK读4×64F32=1024B；AV读4个prob和256个old_partial，各16B/1024B，并最终写1024B partial。partial按`bank=(row_local%4)*64+d`分256逻辑bank，每bank每拍1读1写，地址含context与row_local/4。QK的252个树FADD与AV的256个FADD是否能共享同一物理池须有实际mux/模式排空结构证据，1280DSP只是按256×(FMUL3+FADD2)的条件系数；QK scale/mask、IP routing及FP tail另计。

AV乘法和累加分离预约：product Q32及FADD commit Q32各容32个256lane stripe（各32768B payload），FMUL发出前预约product slot，product实际返回并且各partial不busy时才读取old_partial并发FADD、预约commit slot。反馈F统一定义为**本次partial读请求接受到同址写回后下一次合法读请求接受的最小周期差**，另外记录读返回、FADD接受/返回及write commit时刻；不能把FMUL+FADD总延迟、单独FADD延迟或借来的11拍常量混称同一个F。返回不可反压；有效/tag必须保留到对应slot退休，背压时输出保持；反馈无已证明bypass时不允许同拍写回再读。若Q32不足以持续II1，计实际credit停顿，不静默扩容。

只为排队模型，满context一轮有4C个stripe；容量受`min(256,16*C*64/F)`约束。F=11条件下C3最后32query批只能发8stripe/round，不能仍按256贡献/clk：按每key轮转slot收费，C3 AV约2150400cycles=14.336ms、QK+AV约27.4432ms；C4 AV1966080cycles=13.1072ms、QK+AV26.2144ms。C3的12拍、C4的16拍只是满批重访窗口，不是已测FP延迟。最后一轮空slot与返回/drain必须在实际事件账合并，禁止同一末尾时间重复加两次。F超过窗口时依法插泡，吞吐条件下调；不会让多context改变浮点加法顺序。

**当前单bank实测替代F=11条件。** §8.6正式C3/C4已取得限定数值通过；本征反馈F=13来自单地址短例，C3真实例每址重访13、C4轮转重访16。C3的12slot满批无反馈泡假设因此淘汰，C3功能实现没有因此失败；C4的16slot在本次投影中stalls=0。按实际读接受跨度，C3三批1663+1663+1659=4985cycles/head，C4两批2048+2048=4096；乘480head并加仍为理想条件的QK1966080cycles后，分别4358880cycles=29.059200ms与3932160cycles=26.214400ms。另用本TB从reset释放起、含配置/绑定/初始化/批间及尾部的全例5089/4176cycles作局部服务参考，分别得到29.392000/26.470400ms；该窗口不是严格command start→done，不能与前一跨度再叠加tail。所有全请求数值均为150MHz、F256复制和端口可成立时的条件投影，不是实测完整head或请求；原F=11数值仅保留为历史条件。证据和覆盖见results集中验收章。

最小硬件证据先用**一个真实FMUL→FADD通道**及实际partial RAM/返回预约测F、II和reset/反压；再以完整64维一个query的QK树核原算术。C3/C4的256bank地址/ready模型可先用明确标为synthetic的返回验证调度、隔离、capacity和尾批，不把模型返回称真实F256算术PASS。只有这些条件成立、T2映射与资源账具备后，Root才按已有授权依赖派发所需宽算术微基准；当前不默认复制256条FP链。

### 8.3 softmax：完整行屏障、相邻树与非线性资源

公共softmax候选固定max8/exp4/normalize4，每行仍完整128score、有限性→稳定max（相等保留最低key，含±0）→F32减max→原exp→原相邻sum树→每元素直接F32除以sum。禁止一倒数乘法代替128次division、在线softmax、跳过负mask或改求和次序。末层length16的softmax仍由后续FP tail单列，不能当S128通过自动覆盖。

明确支付4个exp通道、4个normalize divider、4个减法FADD，以及7层streaming相邻归约：每拍4个exp值，第1层2个FADD，其余6层各1个，共8个FADD。每层只配同row相邻子树，奇偶子树暂存携row/epoch/level，完整128叶后形成唯一sum；这是原树的空间流水，不是顺序sum或任意重关联。exp结果同时写该row的128元素buffer并进入树，两路容量同时预约，sum必须有限且>0才允许normalize。8个row scratch context各保存128score/128exp及状态（纯数据8192B），加上各级FP在途/树pair暂存和返回credit；超长exp/div延迟导致8slot不够时显式反压并计服务。

按所有扫描顺序收费，max16+exp32+normalize32=80cycles/row，全请求4915200cycles=32.768ms。该值成立还要求：每exp通道II1、4个divider合计4/clk，8-FADD树能跟上4exp/clk且延迟被实际8row上下文隐藏、score/prob端口不冲突。相比旧8/4/8的26.2144ms，normalize减到4lane已付出额外6.5536ms，sum树以实际8-FADD实例并行付费；若只用单树累加器或有限row slot造成空泡，不能继续使用32.768ms。任何exp/div实际不符原数值即该候选FAIL，CSim的libm通过不替代生成RTL。

最小例用同一真实head至少8个完整S128 row（含真实mask和末key），逐位比较score、maximum、全部exp、每层sum、prob及首错，测单row首延迟与连续row完成间隔；全负有限mask、极小exp、错误最后元素、reset用短定向例。先只生成所需exp/div/归约微基准，不综合整Attention；成本或精确性不成立足以淘汰容量假设。

#### 8.3.1 完整head实测后唯一Attention候选：精确M16/A16/D4与四个原exp

**依据及选择。** [head128实际结果](../attempts/t5_attention_service_rtl_head128_01/numeric_result.json)覆盖enc0/head0/B1/S128全部query0..127、八个16row allQK→allSM→allAV批和完整独立中间值；正常非重叠计算命令合计6816248cycle/head，条件150MHz为45.441653ms/head，480个同shape/head服务收费21.8119936s，尚不含生产caller/搬运。总TB8380004cycle含多次重载、负例、CE及读回，不作生产延迟。旧1M/1A/1D模块OOC为10399LUT/6282FF/22DSP/148.5BRAM tiles，K/V各58RAMB36；复制16个完整service仅RAM就2376tile>器件2016，故不走该方向。

本次只实现一个较小的**Attention内部共享池M[0..15]、A[0..15]、D[0..3]、EXP[0..3]**，一个head/一个16row任务在途，QK→softmax→AV模式严格排空切换。M/A在三阶段复用，不额外配完整QK树或AV池；不跨head/request混合partial，不启用旧F256阵列或第二KV槽。M16、A16、D4分别精确复用§8.4.9已冻结的完整输入`stream_mul_node_14_s/add_node_0_s/div_node_0_s`及真实依赖，下一消费者capture间隔14/6/12edge、II能力与CE沿对应已测helper；都是独立F32 RNE，含subnormal/±0，所有新lane/路由仍须实际RTL验证。四D对每个exp值执行原直接F32 division，不换倒数乘法；分母在完整sum检查有限且>0后才发，exp输入有限且非负，零结果符号及tiny舍入由精确helper保留。更换为这些基本算子不改运算图/检查顺序，也不声称旧native3/2DSP系数仍适用。

EXP4只复制四份当前已通过真实head的`attention_exp_bits`完整F64位图/ROM/内部基本运算，每份最多一个未退休输入；源自冻结CE闭包，保留全部真实依赖。HLS报告为非pipeline、latency/interval范围1..103，不能当4exp/clk；实际每分支launch→done/再次launch占用由新RTL计量。HLS范围是先验成本依据，不是配置II1或真实最坏服务证明。任何后续exp空间流水是另一明确瓶颈修订，本次不与M/A池实现混在一起。quad exp单纯同核复制的条件资源约4×(6424LUT/2933FF/16DSP/2RAMB18)，仍以新父模块OOC付费；数学源/ROM可共享证据，物理实例不得与tanh或LN重复抵扣。

**完整容量及bank。** 保持现生产支持S∈{64,128,256,512,1024}、head D64、每task rows1..16；当前完整模型验证B1/S128不缩减数组。B2旧生产路径及其既有能力继续明确保留并另计资源，本候选不冒充B2验证或删除fallback。绑定仍完整NumericIdentity和QK/SM/AV三个Context、七个Ref、head/mask及epoch，当前16row task全范围须来自真实owner；只允许合法原请求/任务调度。

| 存储/返回 | 固定容量和端口 |
| --- | --- |
| 单head K/V | 每种65536F32=262144B，合计524288B；每种16个一维bank，bank=d%16、addr=key*4+d/16，每bank4096×32。分别同步1R1W；运行只读、完整装载发布后才能算，下一head不得覆盖仍有lease/读债务的旧head |
| Q与输出partial/Y | 各16×64F32=4096B；16个bank按d%16，addr=row_local*4+d/16。Q只在完整task捕获后供QK；Y在AV真实初始化为+0，1R1W且未证明旁路时写后下一次读另付edge |
| SCORE/PROB | 各16×1024F32=65536B；按key%16分16bank，addr=row_local*64+key/16，各1R1W；物理stride保持1024。沿allQK→allSM→allAV屏障，不把单row成功当整task READY |
| QK dot槽 | 固定16个同head内部(key,row)槽，每槽64个product叶＋63个相邻树节点，共8128B；每level单独bank，bank=node_index%32，低层32operand读和16return写在不同level或合法不同地址，不靠未推断多读口。slot在scale/mask/final score写完或失败排空后才复用；不增加request context |
| softmax scratch | 最多8个row context，EXP和tree各8×1024F32=32768B；score读原SCORE、不再复制一份。EXP按key%16分16bank、每bank深512，tree按index%32分32bank、每bank深256，均同步1R1W；sum树逐level按相邻对，所有本level返回退休后才复用低地址进入下level。保存每row max/sum及有效范围；trace读回绑定实际row/epoch，不能读到另一row scratch |
| 不可反压返回 | product Q32、ADD/commit Q32各32个最大16lane stripe=2048B，合计4096B，按模式复用；另四exp各一份32bit结果/tag保持槽、四div各32个scalar预约（payload合计512B）及其tag/计数。所有M/A/D发射先预约，不能在ready低时丢实际返回或扩无限队列 |

以上主体payload（不含mask1024B、55字binding、各表/tag/queue元数据和exp ROM/内部寄存）为741840B；银行碎片和实际端口逻辑必须由OOC收费，不按byte数直接声称BRAM。原full-depth bank和可独立综合的精确子核可按完全相同RTL/参数/端口hash复用DCP，最终必须包含所有实例/父层、blackbox0，不能用资源相加代签完整候选。

**QK确定调度。** 对16row task按(row,key)词典序分配最多16个dot槽，M16每stripe读取同row Q与同key K的连续16维，4个stripe覆盖D64，逐项finite。A16仲裁选择已有完整operand/返回预约的最老dot的最低未完成level/stripe，按原`(0+1),(2+3),…`六层63次相加，不能改为16个链式sum。为避免低层/高层冲突，每个dot槽先写齐该槽当前level结果再解锁其下一level；不同dot槽可交错，RAM的真实1cycle读和FP返回/tag依赖都付费。输出root后，scale乘0.125、mask浮点减1/乘10000、条件sliding bias加法及最后score加法沿冻结原顺序交给同M/A池，资源仲裁不增加隐藏算子。安全dummy只用于无效lane；有限失败保留原(row,key,product/tree level/parent/scale/mask/final phase)顺序归约，完成前不得发整task SCORE_READY。16槽不足以吃满M/A时照实记dependency/credit停顿，不加槽掩盖。

**softmax确定调度。** 全task QK及score写债务清零后，最多8row进scratch。每row按key扫描完整S作finite/稳定max，最大每拍8score，比较相等保留最低key（含±0）；max完整后才发该row减法/exp。四exp worker各占一个key与tag：先借A池做独立F32 score−max，实际返回后启动对应空闲exp，等真实done，有限结果写入EXP及tree叶，结果bank冲突时保留在worker槽并反压下一key。按最小(row,key)可发工作分配，不假定短/长分支完成有序；每key覆盖仅写一次。整row exp及写债务齐全才允许原相邻sum树，A池按就绪stripe仲裁；减法和sum树不能在同cycle重复使用同一A lane，首次实现每cycle只发一个op类别的至多16lane stripe。sum有限且>0后，D4从EXP读取四个key并各直接除sum，按实际12edge及预约返回写PROB；乱序/bank冲突由固定保持槽解决，不改key归属。完整16row PROB覆盖与所有exp/D/A/存储债务0后才允许AV。原max8/exp4/div4的80cycles/row只是旧II1条件，**本候选四个非流水exp不得使用该值**。

**AV确定调度。** 同task所有row已经PROB_READY，先实际清零活跃Y。外循环key递增，内循环row_local递增、feature stripe0..3，M16用同row/key的prob乘V的16维；product真实返回后才在其预约内请求Y同步读，取得old_partial后借A16做独立加法，真实写回才清地址busy。每个(row,d)的key必须0..S−1严格递增；先计算其它row/feature不能改变这条序列。满16row时同地址自然重访64个stripe，4row时16，1row时4；**旧native F=13不继承到新精确A6**，按真实读→写→可再读事件测新F，不足则busy反压。product与commit Q32满时自然停顿，no-bypass默认。首错按原(row,d,key,product/acc phase)优先级，晚row提前失败不能跳过更早row检查；整task失败使目标INVALID，排空已接受操作。全task Y成功且全部债务0才输出实际ATT_OUT，真实writer末B及owner发布仍另付。

**可执行的新局部命令。** 在`attention_and_fp_engine`新增独立`attention_tile_service_v1`，保留原service及冻结receipt。外侧仍32bit command/index/payload/epoch与result/status及真实chain（或§8.1.2的同义cmd/response adapter），原RESET/BIND/完整55字校验/配置/LOAD_K/LOAD_V/LOAD_MASK语义保持。新增command18为LOAD_Q_TILE：index严格0..rows*64−1、row=index/64/d=index%64；19/20/21依次RUN_QK_TILE/RUN_SM_TILE/RUN_AV_TILE，要求index/payload=0和对应完整phase屏障。配置绑定的row0/rows决定全tile，不能用一个选中query修改运行范围。诊断读取沿原select-query及score/prob/y/max/exp/sum读取的范围/row-tag规则；Y扩为完整tile后只有当前task成功的选中row可读，已复用scratch拒绝。每条RUN一次真实完成而非每key一次C函数调用；外层整task后方可换绑定/head。生产caller后续在原ledger真实claim/lease下使用该tile接口，Host13BO不变，正式集成前旧service继续作为正确基线。

**首个实际出口及成本。** Attention Sol独占本模块新RTL/adapter/TB/生成脚本，canonical算术冻结文件只读复用，不修改vector或production源。先≤120s测同head完整4query的真实D64/K128 QK→SM→AV，逐product/各层树/max/全部exp/sum/prob/每key AV累加和最终Y核独立gold；通过且实测进度可落原帽后同一snapshot完成16row tile，再按成本完成同head128query八tile。长例按原≤8GiB/3600s/40Mcycles/120s语义保护，不因并行lane减少硬件cycle就假定仿真墙时线性下降；超帽保留完整16row范围和具体进度，不拼reset进程称head完成。额外短例覆盖exp长短分支混排/原12定向、四D的±0/normal-subnormal/最小subnormal/ties-sticky（独立精确参考），高row/key地址/末key坏值、队列满及bank冲突、错epoch/row拒绝、A/M/D/exp在途CE/reset与合法重载。最大S1024完整存储pattern和端口/索引覆盖验证容量，非真实fixture明示synthetic，不凭此代签B2或其它head数值。

同一candidate只做受影响模块OOC（含满容量RAM、16M/16A/4D/4EXP与控制），沿24GiB/3600s/唯一锁及语义帽；先保存DCP/resource，再最终timing一次，未P&R不称150MHz成立。已有精确子核DCP可共享hash证据，但Attention和tanh物理复制分别付费。与baseline比较同一非重叠RUN接受→真实done的完整head/16row各阶段周期，并另列加载、readback、输出/末B、mode drain、资源、每类实际lane利用与stall。只实际跑16row时只比相同baseline16row；不把8row/4row缩放称完整实测。数值/协议通过且同口径实际改善即可继续生产连接，无需达50ms才推进；资源或成本不支持则保留已测较小正确范围，不自动翻倍池/复制service/另启exp架构。

LN和Q8保持独立工作：LN7824row的现16row1433020cycle基线尚未被共享vector池实测替代，下一次只基于真实phase/IP服务分解改其确定调度；本次不同时扩LN阵列。Q8当前真实TM4的理想46055432cycle（307.036213ms@条件150MHz）仍是该几何下界，TM16/TN16未实现不可抵账。实际Attention新池资源、完整双W/A与TM4/R0映射到手后，再按同一总账选择已有两种较大Q8几何及合法多请求策略；未知shell/LUT/RAM/布线项不填0，整体OOC/P&R保持暂停。单局部池PASS不结束完整高性能加速器mission。

#### 8.3.2 全tile捕获Q时保留原逐row数值首错

依据[原generic qk_row](../../../hls/operators/attention_full_compute.cpp:21)和[原生产逐row服务调用](../../../hls/operators/full_tasks_attention.cpp:313)，原顺序是每row先检查Q的d0..63，再检查该row全部key的product/相邻树/scale/mask/final，随后下一row。新cmd18把全部Q先捕获，不能立即把较晚row的坏Q报告为最终错误而跳过较早row可能的overflow；真实producer通常finite不构成删去该故障域的依据。原cmd3单row诊断保持即时status1、element=d。

cmd18的合法index顺序仍严格0..rows×64−1，非有限payload同样完成一次捕获并推进覆盖计数，返回status0只表示该载入命令完成；新增有限pending记录保存最早坏Q的row_local及d。数据可原位保留位型或写安全+0，但该行不会算QK，不能把安全值当数值修复。协议错误仍按原即时拒绝，不能用pending数值错掩盖。RESET/新binding清pending valid/覆盖/generation，不清payload。全tile载入完成后cmd19才裁定最终数值结果。

cmd19在无坏Q时正常算完整tile；有首坏Q row=b时，仅真实完成所有row<b的QK并收齐已接受FP/RAM/score写债务，该坏row及其后row不发新QK。若这些早row有任何原顺序数值错，选择其最小rank；否则报告pending坏Q的d，status1/phase6，SCORE整task不可READY。b=0可零FP直接按真实命令握手报告；b>0不能在早row仍有返回时提前done。内部rank可用row×2^21作为base，Q检查为base+d，算术为base+1024+key×1024+原phase（product d0..63、tree64+level×64+node、scale512/mask减513/pad乘514/bias515/final516），全部u64；其范围不跨row。当前不计算坏row时亦可按等价tuple合并，但必须保留原行内顺序。C行为模型同样逐row先检查Q、再算该row，不能照旧在全部cmd18时终止。

最终API仍单result/status：cmd19坏Q返回d；product/tree返回key×64+d或原tree node索引；scale/mask/final返回key。内部row只用于正确选择，原外部bad_element没有增加row高位。**禁止对全部数值result统一取%64**；这会破坏key与tree/scale定位。生产`attention_call`在cmd18遇非有限Q不会提前生成TaskDone，cmd19返回才沿原`task::numerical(op,result)`登记；旧cmd3和KV/mask前置验证语义保持。SM/AV的原row优先首错和allQK→allSM→allAV屏障不改变。

受影响定向至少覆盖：早row真实product或tree overflow＋晚row NaN/Inf Q；早row坏Q＋晚row overflow；同row坏Q与若计算将overflow的其它维度；多个坏Q、d63和末row；pending在CE暂停、active reset与新epoch重载后的保持/取消。独立期望由原逐row参考与显式位型构造，不改旧gold或降低finite检查。新RTL/C/production映射保持同一语义，旧v09正常数值只复用未变算术范围，不代签这次错误协议。

**本阶段封存状态。** 同source_manifest_v10（SHA256 `34145bda45ba482150a8be37876288771e01b3952bbb5de6ba892340d5f8b0b2`）的[完整head128](../attempts/t5_attention_tile_v1_01/head128_01/numeric_result.json)与[tile16_03](../attempts/t5_attention_tile_v1_01/tile16_03/numeric_result.json)已实际PASS。完整head单进程八tile的正常命令周期QK250888/SM287173/AV66256，共604317；同口径旧6816248的局部计算改善11.279259倍。head测试PROTOCOL=0，六类首错323/63/63/7/63/4095、M/A/D/EXP在途CE/reset、reset优先CE及pending-Q取消/重载的协议结论来自同hash的tile16_03，不能写成head进程重复验证。完整head EXP实际launch→done enabled gap分布为1×7168、78×128、89×1、97×9087；旧较小pilot未遇89不能作为固定三类延迟合同。M Q32填满已覆盖，A/D满credit尚未证明；184304个F32存储字=737216B为纯RAM payload，不含全部queue/metadata/逻辑，也不是RAM primitive报告。

同身份[OOC01](../attempts/t5_attention_tile_v1_01/ooc_01/ooc_result.json)在244.410645s触发120s无语义进展保护，状态NOT_COMPLETE；无最终resource/DCP/blackbox/timing，因此新池的实际物理预算与频率仍UNKNOWN，不能继承旧scalar Attention或原canonical DCP。150MHz仅可作604317cycle的条件换算4.02878ms/head，未含真实生产caller/BO输出/末B，不能宣布完整请求性能。production接入、B2/其它shape数值、全图及板端不由这两个局部PASS关闭；本阶段已结束该模块执行，不启动另一OOC或扩池，后续由复制工程接续。

### 8.4 向量与量化实例分开计费

**当前身份优先：** 下文原四tanh池及§8.4.1–§8.4.6保留历史方案/失败原因和仍有效的数值、资源规则；当前已有`round1_02`正确单叶局部PASS及实际OOC，不再处于“尚未定义同gold候选”的状态。当前全请求服务按§5.1；下一项高吞吐实现为§8.4.7的单流空间流水，不是默认复制四份新叶子。完整真实GEGLU与当前完整CPU/CSim按§0.2连续接通；第2轮add实际OOC与局部性能现已验收，完整GEGLU后续未取得的结果不预先验收。

公共vector候选为分时的32个FMUL+16个FADD基础池，按旧系数128DSP，另有4条原tanh、1条sqrt及1条标量divider（实际资源UNKNOWN）；量化§7.3的16FMUL/1divider独立，softmax§8.3的非线性/树独立。vector模式固定LN16lane、GEGLU4lane、residual/type/ReLU8lane、RoPE4pair/8输出lane；模式改变前旧在途清零。LN两棵1024相邻树、三个标量div及sqrt保留，GELU原7次乘法/2次加法（含gate）顺序不变；不能用“共享128DSP”同时计算互斥模式。

LN树使用16FADD的时间复用，至少32个operand读与16个结果写/clk，局部row/tree的bank/寄存须实际提供；树level依赖与sqrt/div停顿另计。GEGLU4对每拍需要4U+4G，Wi两半相隔2624（恰为16的倍数），简单col%16 banking会冲突；候选在输出存储中显式拆U/G两个plane、相同(row,i)分别读，只有两半对应数据都真实发布才能配对。先用外部完整Wi fixture测pair/cache→原GELU→GATE，再接真实Q8 writer；不提前删除HBM往返或把不完整Wi当READY。残差旧hidden保留到最后一次真实读，RoPE按half split配对，不能覆盖另一半尚未读出的旧数据。

以原工作量收费：LN三扫16lane1502208cycles，另两树至少`7824*2*ceil(1023/16)=1001472cycles`；GEGLU4为2351104、residual8为983040、ReLU8为131072、type8为16384；28 Encoder的双Q/K RoPE共3670016pair，4pair/clk为917504cycles。共享vector合计至少6902784cycles=46.018560ms，**还未含树反馈/标量非线性、FP tail、搬运及模式切换**；这明确取代把LN/GEGLU各自最小值取max的错误口径。若实际附加服务超过剩余597216cycles（3.981440ms），该单vector配置不能支撑远期20/s参考；当前记录真实服务并按§0.1判断相对改善与资源代价，不因此自动停止。

最小vector例保持完整维度：两个真实D1024 LN row、一个Wi5248→GEGLU2624 row、一次1024 residual与完整64维RoPE，按同基础池互斥顺序执行，核所有中间基本运算/最终值和U/G/残差读写事件。先提取实际每模式服务系数，再乘全请求工作量；短例不宣称完整Encoder producer链通过。

#### 8.4.1 可直接派发的首个出口：先核真实FP服务，暂不生成宽池

Root按空闲owner派发到既有`vector_and_ffn/rtl/tb`，新增`vector_service_*`局部入口，LN/T2制品只读复用；不改生产top、不生成完整层或32FMUL/16FADD宽池。第一步仅使用各**一个**真实FMUL、FADD、divider、sqrt和原tanh服务实例（可分小snapshot复用），外侧统一ready/valid/tag，全部输入与内部基本运算gold来自独立reference。单实例完整数值重放与下节有限资源事件模型分别交付；前者不能冒充16/32lane硬件吞吐通过，后者不能冒充真实FP返回。

优先次序是`tanh数值/接受服务→LN标量和树反馈→其余完整row数值及共享调度`。现有[生成tanh叶子](../../../vivado/project/build/20261008T022231Z-2961016/stage/rtl_verilog/laya_typed_q8_forward_generic_tanh_float_s.v)为99-state、`ap_ready`仅在state43的非流水FSM，不能从4个实例推定4结果/clk；该历史生成身份不是v4新实现身份。owner须绑定实际选用叶子及其全部子模块/IP/ROM来源，记录真实输入分支的接受/返回间隔。先将真实Wi一行全部2624个GELU `z`输入依序重放原tanh，逐位对独立`libm.tanhf`结果；输入始终可供时记录每次**真正调用接受**与完成，排除HLS idle状态的伪done。数值差异按原合同FAIL；不能改近似、改gold或用CPU函数代替RTL继续算吞吐。

若实际选用的非流水tanh在所有受支持输入路径都可由结构与握手证明最小接受间隔至少2cycles，则四实例仅GEGLU就至少4702208cycles；加其它既有理想项至少9253888cycles=61.692587ms，足以说明该具体共享vector配置未达旧50ms参考；当前不能仅据此排除，也不因重新解释预算就直接生成宽池。单个真实row观测的平均II不能自动当全请求下界：分支相关服务须列最小/最大及样本分布，硬排除用全路径下界，保守预算用已证明的上界；只有样本均值时保留条件结论。若保留原逐步F32数值的流水重排有必要，属于同候选内有依据的实现优化；改变tanh数值或增加实例数须回到架构合同，不能静默替换。

**历史50ms口径下选定叶子曾登记`REJECTED_BUDGET`；2026-10-11起仅保留远期参考差距。** 最初清单`ed5954a53da8bbcc05b2fda20233ca7163dfc2f6d0512febc055c31460150fda`的42项hash匹配，但不构成闭包完整证明；static01实际编译发现attribute后的sparsemux引用漏列，此前“无未列工程依赖”判断撤回。现以[static02冻结闭包](../attempts/tanh_service_static_02/work/frozen_source/source_manifest.json)SHA256=`e9907f18a0b7a5cc386f5814b6f0822597c5fc5d5933442edf26c18a86cddea7`的18份叶子Verilog、3ROM、7FP IP及另编wrapper/TB为实际成功编译身份。普通闭包解析修复没有改叶子FSM。叶子SHA256=`5631ababc86c12ca1f244de14d820d2f288077742ae2c9664ad58c34d80020d6`。实际ap_start只在state1接受新调用，活动分支首状态仅2/53/59，活动done/ready仅state43，state43无条件回state1；最短有向环为`1→2→43→1`，因此无reset的任意相邻成功接受至少3cycles。idle ap_done不是活动结果，reset清除的交易不能充当完成吞吐。

固定四实例的GEGLU稳态资源服务至少`9404416×3/4=7053312cycles`，替换旧2351104后，共享vector至少11604992cycles=77.366613ms/请求（150MHz条件），尚未加LN反馈/标量、FP tail、搬运和切换。该结论针对**此闭包叶子、四实例和既定共享模式**的20/s资源预算，独立于真实row的分支分布；它不是RTL数值FAIL、实测请求延迟或所有未来tanh实现的不可行证明，也不代表v4未来kernel身份。少量边界拍不改变其超过旧50ms参考的结论，但该差距现不再单独淘汰此路线。尚未生成宽池/完整向量组合；§8.4.5必要数值基线已FAIL，当前停止对错误输出做保持位结果的流水化，按§0.2与§8.4.6先定义同gold数值修复/替代合同。

基础FMUL/FADD优先复用§8.6的实际6/11cycle IP。LN divider/sqrt可复用T1生成叶子及其XCI，**必须测wrapper接受→返回**，不能把文件名中的8/7或内部IP的6/5直接当外侧延迟；无reset的内部IP由wrapper清valid/epoch并隔离旧返回。记录各服务实际latency、连续输入II、输出不可反压时的最大在途及reset后旧返回隔离。单实例序列至少覆盖完整真实运算清单；已有相同身份实测可以引用，未测项不填理想1。33个已知边界差异继续保留；真实输入若命中即保存首个基本运算差异。

#### 8.4.2 同一池内的确定调度，不把LN和GEGLU拆成独立引擎

有限事件模型固定资源为`M[0..31]、A[0..15]、TANH[0..3]、DIV0、SQRT0`，每个实例使用上节实际服务或显式UNKNOWN参数。模式依次为LN→GEGLU→RESIDUAL→ROPE，每次切换必须全部FP/tag、返回预约、写回和诊断债务为0；同模式可连续处理同一合法task中的row。所有模式共用M/A编号，任何cycle不得双重预约；ReLU/type沿原8lane接口另列收费。先跑下面唯一确定调度，不为找好看的数字穷举lane/context组合。

| 模式 | 固定映射和发射规则 |
| --- | --- |
| LN | 仅2个row context。每row保持`完整输入finite扫描→mean相邻树→sum/1024→delta及square完整扫描→variance相邻树→sum/1024→+eps→sqrt→1/root→重算delta、norm、可选gamma→退休`。两次delta都保留。A池每拍最多接受一个至多16元素stripe，可来自树、delta或标量eps；M0..15用于square或norm，M16..31用于gamma，DIV0共享三个原division，SQRT0共享root。实际子操作相依，只在相应基本运算返回并commit后启用后继；除法不能换常数乘法或倒数近似 |
| LN树交错 | 每row/每level保持next-parent索引和已commit子节点位。树节点严格为`node[l+1,i]=FADD(node[l,2i],node[l,2i+1])`，每level按i递增；仅已写回的相邻pair可发射，不做写回同拍旁路。每row选择最高level的ready连续stripe，两个row轮转仲裁，不能凑满16而改配对。其它LN阶段也参与相同row轮转；一个stripe未满的空lane照计。允许后一level在其两个孩子已返回时开始，不强加整level全返回屏障；完整树finite检查和原错误次序仍在成功发布前满足 |
| GEGLU4 | lane j固定使用`M[7j+0..6]`完成`u=a*U,v=u*U,t=c*U,z=t*w,s=0.5*U,y=s*r,gate=y*G`，`A[2j]`做`w=1+v`，`A[2j+1]`做`r=1+tanh(z)`，TANH[j]独占该lane。依原检查次序保存最早错误；不合并FMUL/FADD。每个实例按实际II发射，最长分支/返回容量决定真实输入ready，不能强制4pair/clk |
| residual/type8 | A0..7，两个已校验源同(row,col)逐元素FADD，旧hidden最后一次读完成前不释放；其它M/A空闲也不借给另一模式 |
| RoPE4pair | pair j的M[4j..4j+3]分别计算`x[i]*cos[i]、x[i+32]*sin[i]、x[i+32]*cos[i+32]、x[i]*sin[i+32]`，A[2j]作前两项相减，A[2j+1]作后两项相加；每个完整D64有32pair。减法须是独立F32操作（固定Add IP可按精确符号翻转接第二操作数并核±0），不可FMA |

本候选按两row为一批：先用128个16lane扫描拍完成两row输入装载/finite检查，再启动任何树；两row均退休后才接下一批，不能将下一批装载藏入本批树等待。这样原LN三扫与树的相加下界继续适用；两row批内部允许上述依赖就绪交错，树加法及两遍delta仍竞争同一16-FADD池。若以后改变此批边界和重叠，须按实际资源事件重新推导下界，不把旧6902784cycles机械称为新调度的严格下界。

LN只复用已有两个完整row的局部容量：原x共8192B、每row一棵含叶子的2047-node工作树共16376B（mean完成后按相同row复用为variance）、输出8192B、gamma4096B，纯数据合计36856B，metadata/有效位/返回缓存另计。树按level独立、`bank=node_index%32`排列，同一stripe的32个operand只读及16个返回写回须在实际1R1W银行/预约模型中不冲突；每级小数组的物理碎片不能按纯byte数当BRAM估算。原x保留到最后重算delta。读延迟固定候选1cycle，读请求到实际返回、算术接受和写回均单列；同拍写回旁路未证明时禁止。单周期只向A池发一个stripe，不能给每row暗配一组A。

GEGLU保留一整行Wi的U/G两个2624-element plane（20992B）及完整gate（10496B），各plane按`i%4`分bank；相同(row,i)两半都已发布才可读，Q8输出/owner桥仍未覆盖。RoPE完整旧64元素及cos/sin先绑定相同head/row，旧数据复制/最后读之前不得原位覆盖。模型外侧统一最多16F32读和16F32写/clk、读写各一个服务预算；内部已列的tree端口、U/G双plane、RoPE表端口另逐一预约，不能把一个共享端口当多个独立口。所有模式返回预约上限固定128个最大16lane stripe，变长非线性实际需要更多时计credit停顿，不静默扩容；实际payload、tag和bank数进入资源账。

tag以2个context表保存完整NumericIdentity/TaskContext/BufferRef，流水携context/epoch/op/phase/row/level/index/valid_mask；每个token接受前验证来源、范围、递增sequence。错误按原软件的row、phase、level、element检查次序归约，不能以最快返回者为首错；较晚row不能先发布成功。基础运算早执行只影响内部调度，不跳过较早检查，不改变相邻树或最终发布屏障。背压仅停止尚未接受的请求；已接受非阻塞返回均有预约位置，done时预约/在途/写回债务全0。

#### 8.4.3 完整尺寸输入与必要观测

两个真实LN row直接复用T1固定v4 raw前两行及gamma，逐基本运算核两棵完整1024树、mean/variance/shift/root/inverse、两次delta、square/norm/gamma和最终1024输出。两row都带gamma可作为全请求保守收费；无gamma路径复用相同输入作为明确标注的数值/调度诊断，不冒充另一真实producer。Wi5248取同v4/request3的实际enc0 Wi生产输出一行（已捕获或在现CPU producer上加只读观察），独立重算2624项全部GELU步骤及gate；当前`ln_ffn_source`是Wi输入、`geglu_source`是Down输入，**两者都不是完整Wi输入**，不能错用文件名。残差两份完整1024输入取同一合法producer pair，RoPE用同head/row的Q或K完整64维和实际对应表；缺失只读捕获按原CPU路径补齐，不凭另一build的近似同名tensor代替。

必须同时保留三个层次：真实单实例算术重放的逐位结果；使用实测服务的有限32M/16A资源模型及端口事件；尚未生成的宽池RTL/映射UNKNOWN。正常及有限ready停顿各列任务接受、每phase首/末输入、每级树首/末接受与返回、scalar三次div/sqrt、首输出、末写回和done；逐cycle给M/A有效lane数及因dependency/credit/port/mode-drain的停顿。最小短异常仅覆盖错context/epoch或U/G位置拒绝、返回/写回在途reset后合法恢复、末输出反压退休；不扩非关键诊断。沿§0成本帽，先≤120s pilot，正式≤8GiB/3600s/40M cycles；能由实际资源上限、端口冲突或服务器成本排除的具体配置直接记录相应限制，不为得到宽池FAIL再生成大池；仅服务下界超过50ms则记远期参考差距，并按§0.1评估当前用途。

#### 8.4.4 全请求收费与停止线

原工作量固定为LN7824row（gamma256、无gamma7568）、GEGLU3584row×2624、residual7680row×1024、ReLU256row×4096、type128row×1024、RoPE114688个完整D64，即3670016pair。FP tail、EMB_TYPE、外部搬运和实际控制继续另外收费。先报告原6902784cycles主体下界，再用实测服务模型替换相应项；附加时间只加一次，不把树等待或最后返回同时算入phase tail与mode drain。

一个明确不可采用的例子是两row同level锁步、每level全返回后才进入下一level：10层的16lane发射批数之和为`64+32+16+8+4+2+1+1+1+1=130`。FADD延迟11时，每两row一棵树的首接受到根返回至少`130+10*(11−1)=230cycles`；两树相对原128cycles/row理想收费增加至少102cycles/row，因此主体已达7700832cycles=51.338880ms，尚无sqrt/div。这只淘汰该锁步调度，不能据此宣布所有共享池均不可行；上节子树交错仍需实际服务模型核算。

保守可实现时间按同一资源事件表求和：LN先按3912个两row批计（可用含gamma较慢合法日程给无gamma留空槽），GEGLU/residual按完整row，RoPE按现有3584个task各含16row×Q/K两个D64，即每task1024pair。同一task内连续row/plane可在合法slot与端口容量内隐藏填充；task边界有真实owner/响应退休，模式切换必须排空。仅测一个D64后按114688次完整冷启动相加可给悲观上界，但上界超过50ms不能当不可行证明；反过来也不能把全部head当一条无边界stream抹掉填充。原任务顺序/行数/模式切换计数从当前controller或已验证任务trace读取，小算术例不凭空构造整图重叠。

7500000cycles只对应旧50ms远期参考，超过它不再自动排除候选；当前须以实际服务、有限容量、全部原工作量和资源代价解释选择。样本平均乘工作量只算条件投影，缺失nonlinear/端口/tail项则保持预算未闭合。跨模块重叠不能减少本共享池总占用，更不能取LN/GEGLU/RoPE三项的max。若已发现明确数值/资源冲突或无实际改善，停止该具体假设并推进独立生产连接，不自动扩实例或改数值。

#### 8.4.5 历史错误叶子硬排除后的基线与条件两轮优化

**原定只保留一次完整2624项真实数值基线；现已在首差异处FAIL收口，见§8.4.6，以下两轮条件未激活。** 原Wi CPU只读capture只执行一次（沿既有约140s成本估计及§0保护，实际墙时另记）；冻结同v4/request3的完整Wi5248、全部独立GELU基本步骤和2624个z/tanh gold，供旧叶子及未来候选共用。旧叶子仅一个实例、一个编译snapshot、正常供数运行；首个逐位差异立即按原数值FAIL保留ordinal/z/got/gold及接受/返回事件，不为凑全PASS改容差或续跑另一压力配置。全2624项一致才登记该真实输入域的`NUMERIC_BASELINE_PASS`；历史`REJECTED_BUDGET`仅保留旧目标口径，不是当前功能门槛。已准备gold/TB不等于已运行；该基线用于决定原计算图是否可保留，不能作为另一个性能候选或扩整层的理由。

若旧叶子在该真实输入域即不符gold，先停对其做保持位结果的流水化：这种优化只会保留数值错误。只在发现明确的接口采样、调用或基本算术实现错误时按原合同修复受影响点；若差异来自原HLS tanh数值函数本身，则登记该瓶颈的数值依赖，交Root处理原合同内可证明的修复，不自动引入另一近似、多项式/LUT、放宽逐位或更换gold。普通连接/仿真脚本修复不消耗“假设轮次”，没有新原因的重复跑不算新假设。

数值基线通过后，最多两轮只改变**一个tanh实例内部的流水调度**。4个tanh数量、32M/16A共享池、LN两个row context及128stripe预约上限保持，禁止交错多份旧FSM或新增request context掩盖II。所选叶子的内部并非全F32：必须保留其F32运算、F32→F64扩展、F64 exp/加法、F64→F32截断、fixed-point宽度/截位和全部ROM位型及分支选择，不以代数等价重结合或FMA替代。流水寄存和token有效位可以增加，但不是新增独立算术pool，实际代价必须列出。

| 有界轮次与可证伪假设 | 最小实现和出口 |
| --- | --- |
| 第1轮：单交易FSM及函数边界串行是主要II阻塞，原标量计算图可由局部流水生成达到II1 | 仅在tanh局部top内展开原调用边界、保留上述操作图/数值配置，向生成器明确单输入流II1和各基本操作不融合、不重结合；不改生产top或复制四lane。只生成一个候选leaf，报告实际achieved II/控制接口、各分支latency、内部算术/ROM实例和实际增加的寄存/队列。用同2624真实z逐位对独立gold；旧叶子结果只能作额外等价检查，不能充当gold。连续真实输入须实际每拍接受、逐项返回守恒，不只看HLS target II。通过则直接转已有LN/共享调度依赖，不再为了用满两轮启动第2轮 |
| 第2轮，仅第1轮数值成立且有一个明确结构阻塞时：对该阻塞作显式静态流水可解除II限制 | 只替换第1轮报告中阻塞的函数握手、复用运算位置或ROM端口调度，按原有向操作图为不同位置安排流水stage；相同基本IP/ROM/常量/分支运算保持，较短分支以有效位和延迟对齐统一返回，不删分支。需要复制原来分时的内部运算位置时逐个计入单leaf资源，不能把它藏进外部32M/16A或声称免费。只生成这一具体修订、重复受影响数值与连续接受验证；若需要全新数值函数、额外外部tanh实例、更多context或另一个pool，则超出本轮假设，停止并交Root |

每轮都先用单leaf原始报告/事件确定是否仍有全路径服务下界，或实际资源必要条件已超预算；有硬排除即可停止，不先生成四条tanh或宽vector。四份新leaf的内部F64/定点算术、ROM复制及控制资源全部收费；§8.5的312DSP非线性余额还需支付4exp/6divider/1sqrt，不能独占或重复支出，未知映射仍UNKNOWN。第2轮未取得同gold数值、II1及可解释资源预算即关闭该两轮优化假设，保留最早真实差异/具体限制，不追加第3轮、增加容量或动用未分配shell余量。单leaf成功只是必要条件；最终仍需§8.4.2–§8.4.4的共享调度和其它模式服务，不能因此宣称20/s已达。

#### 8.4.6 真实非线性失败后的独立出口与架构阻塞边界

**历史错误叶子实测曾触发该出口；新正确身份见§5.1/§8.4.7及results后综合评判。** `tanh_service_real_01`在ordinal23得到`z=bf6cd458, got=bf3a7268, gold=bf3a726a`，数值基线FAIL，未见支持接口采样错误的证据；所选向量叶子仍为`NUMERIC_ARCHITECTURE_BLOCKED`；旧四实例`REJECTED_BUDGET`仅追溯50ms/20/s参考口径，不再单独阻断当前路线。§8.4.5两轮是“基线通过后保留原图”的条件授权，当前不启动，不能把下述新函数算为一次普通修复或隐含第3轮。原始身份、独立复算与未测范围见results集中章。

若唯一历史tanh真实基线FAIL，先登记首个可定位差异及输入/输出位型；§8.4.5两轮性能优化的数值前提尚不成立，禁止对已错输出做保持位结果的流水化。只有具体证据说明是采样/握手/调用或原基本运算实现错误，才按原数值合同作一次针对性修复并回归受影响基线；无此可检验原因、或差异来自原HLS tanh/内部exp函数与独立参考本身，即登记`NUMERIC_ARCHITECTURE_BLOCKED`，停止该tanh/GEGLU及依赖它的共享vector性能候选。该状态是指定实现路径的阻塞，不推断所有tanh或独立FP模块皆错；若另一路实际共用已失败的非线性实现，也继承对应数值依赖。换近似、换libm/gold、放宽逐位、FMA/重结合或额外实例均不是普通性能修复。

**同libm位结果流水函数的静态判定。** 实际gold绑定`/usr/lib/x86_64-linux-gnu/libm.so.6`，SHA256=`1b87a1a50b496cfead2b0ad134c2ff536705c82608db240c7e8aa48d6c0e4217`（glibc2.39-0ubuntu8.7）。本次只读反汇编其`tanhf`地址0x423a0、`expm1f`地址0x41710：普通有限分支在|x|<1调用F32 `expm1f(-2|x|)`后做`-t/(t+2)`，|x|≥1且<22调用`expm1f(2|x|)`后做`1−2/(t+2)`并恢复符号；小值、零、饱和及非有限分支另有选择。expm1f内部按ln2范围缩减、F32逐次乘加的多项式/有理修正、除法和指数位重建，所见运算为独立标量addss/subss/mulss/divss，无FMA。它不是旧叶子的F64 exp/定点ROM图，不能用旧图等价或2624点对表替代新函数的数值证明。

经过expm1f有理修正的普通路径（包括本次ordinal23所在分支）每结果需要一次expm1f内部F32除法和一次tanh外层F32除法。若保证四叶子对该分支连续输入均每拍接受，则内部必须提供**8次F32除法/clk**的吞吐容量，另加范围缩减、多个顺序乘加、转换/位操作及有限返回存储；这里只是算术容量必要条件，未把它换算成未经验证的DSP数或假定divider必用DSP。原外部6条divider已有softmax4/quant1/LN1用途，不能免费借用仍保持各自预算；312DSP非线性余额还要支付4exp/1sqrt等，LUT/FF/RAM也未闭合。因此当前证据不能建立“该新函数在现有配额内可实现”，也没有足够证据证明所有精确实现必然超额。

此处原定的同gold替代图已由第1轮libm位级实现、零符号修正及第2轮add改进实际落实并取得局部CPU/RTL/模块OOC证据；不再保留“等待Astra定义新图才能执行”的前置门。旧函数FAIL与旧四路II1的8次除法/clk论证仅保留原身份含义。当前按§0.2接真实生产链，并执行§8.4.7基于实际综合结果改进的单流空间流水；不改gold/容差，不用模型z查表，不扩大总资源或整体OOC/P&R授权。

下列已授权小范围具有独立验收出口，按原owner/资源帽继续，不等tanh修复，也不把外部fixture通过改称完整producer链通过：

| 独立后续 | 可继续到的具体出口 | 不由此解除的依赖/停止条件 |
| --- | --- | --- |
| quant16 | §7.3真实K1024/K2624一行及零/极小/round边界，冻结外部输入/独立q、half、d_full、reciprocal；核实际divider接受/返回、32slot债务、A发布和两扫服务。CPU预检只复用功能证据，实际HLS/RTL各按原成本帽执行 | tanh失败不影响这个局部量化问题；不能称GEGLU→quant生产链通过。若实际divider数值/II或有限slot服务淘汰group/4clk，记录该候选自身限制并停止扩宽/扩slot，不借CPU排队延迟证明吞吐 |
| Q8S2 v2 | §4独立新入口的真实ACT strict/fast各两次LOAD/RUN和既定会话负例；由实际新实现生成layout/build并重验，核18拍实际BO绑定和撤销/代际 | 静态模型信任链不证明动态激活/tanh算术。无真实XRT即保留离线范围，不准备13-BO全图替代此出口；旧v4 CPU会话不能改标新kernel |
| 三口reader/双W | §7.4真实Wi/Down首尾、4KiB、高tile/group窗口；端口服务成立后在原帽内完成一次全量双槽LOAD与带身份被动checker、lease/epoch/reset/失败隔离 | 与tanh无算术依赖，但被动reader不冒充MAC。窗口不得置完整W READY；三口/写bank服务已排除预算或成本超帽即停止该配置，不先扩完整Wi计算 |

这些独立出口收口后，Root在现有阶段表记录限定通过与具体阻塞即可；不因50ms/20/s仍未达而无限搭建全图TB、生成更宽阵列或准备完整Encoder。tanh数值或有限共享服务仍阻塞时，依赖GEGLU成功发布的T6/T7真实链保持`NOT_RUN_DEPENDENCY`；现有成本/事件分析可用于说明边界，不能由任意延迟或CPU oracle替代未成立的RTL producer。整体OOC/P&R/专项时序暂停保持。本段不新增放行门，也不重启已经完成且身份未变的T1/T2/T3范围。

#### 8.4.7 单流同图tanh空间流水实现合同

这是基于已取得的第1轮02实际综合/服务结果提出的下一项有界吞吐实现，沿现有vector模块执行，不另开项目或预审门。第2轮add实际综合后已接受局部改善，Sol一方面把该正确叶子接入§0.2完整真实GEGLU/当前完整图，另一方面按本合同实现**一个输入流、一个空间展开的tanh图**；不复制大量串行FSM，不同时生成四路流水。目标是持续II1，以实际接受/返回及有限credit验证；`tanh_libm_stream_02`已取得限定RTL功能/服务PASS，单体OOC成本中止，资源/物理时序仍UNKNOWN，后继综合方法见§8.4.8。

**数值域、分支与图。** 以[02已修正位级源](../attempts/tanh_libm_round1_02/frozen_source/tanh_libm_bits.cpp)和其冻结vendor `s_tanhf.c/s_expm1f.c`为数学图依据，add实现优先复用[第2轮已验收的有界归一化](../attempts/tanh_libm_round2_01/frozen_source/tanh_libm_bits.cpp)，gold仍为原libm及独立参考；支持全部有限binary32，独立基本运算RNE，保留subnormal与有符号零，不模拟主机errno/浮点异常旗标。非有限输入接受后返回原tag、status1/result0；有限成功status0。各分支均存在，短分支只作延迟对齐，不删除或用模型输入查表替代：

| 位域/分支 | 固定运算与选择 |
| --- | --- |
| `abs(x)==0` | 保留输入±0位型 |
| `0<abs(x)<0x24000000` | 原顺序`x*(1+x)`，两次独立F32舍入，不改成直接返回x |
| `0x24000000<=abs(x)<0x3f800000` | `y=−2*abs(x)`，`t=expm1(y)`，`h=−t/(t+2)`，最后恢复输入符号 |
| `0x3f800000<=abs(x)<0x41b00000` | `y=2*abs(x)`，`t=expm1(y)`，`h=1−2/(t+2)`，最后恢复符号 |
| 其余有限输入 | 原`1−tiny`再恢复符号；tiny位型`0da24260`不变 |
| expm1内部可达域 | `−2<y<44`；按原`3eb17218/3f851592/33000000`位界范围缩减、小值选择；F32→k朝零、k→F32独立RNE；保留k=0、−1、+1（含缩减x<−0.25子分支）、k<=−2、2..22、23..56、>56的原重建顺序与指数位操作。未暴露通用域外expm1接口 |

常量ln2_hi=`3f317180`、ln2_lo=`3717f7d1`、invln2=`3fb8aa3b`、Q1..Q5=`bd088889/3ad00d01/b8a670cd/36867e54/b457edbb`及1/2/0.5/3/6均沿冻结位型。Horner各乘法和加法独立舍入；内部有理修正保持`hxs*((r1−t)/(6−x*t))`，随后c修正及重建逐步执行。允许在不同输入间空间流水及不相关节点之间重叠，不允许FMA、重结合、近似倒数、改函数或使用FTZ基本IP。

**空间算术与资源付款。** 设置两个不同的精确F32 divider流水位置：Dexp只处理expm1的`(r1−t)/(6−x*t)`，Dtanh只处理外层`−t/(t+2)`或`2/(t+2)`；对普通分支一个结果两次division，单流II1需合计2次division/clk容量。以现有精确整数归一化、26步商生成、余数sticky和RNE打包为基础，可将商迭代逐级寄存/展开以接受新操作，不能继续复用一个非流水26步循环却宣称II1。原“四路各II1需8次除法/clk”不适用于本单流配置。

本候选当前展开固定为**24个F32 add/sub图位置、17个F32 mul图位置、2个上述divider**（取代最初18个mul的预留上限；实际add23为两个编译期常量，折叠为`3f800000`，生成23 add/17 mul/2 div实例）；包含tiny/范围缩减/多项式/修正/重建/外层分支的节点及分支对齐，所有分支可用谓词选择操作数、结果选择和旁路。该数目是已核源图/HLS RTL节点，仍不是实际Vivado资源报告；实际源码→节点→生成实例必须对应，未用节点可删除，不能借函数内联隐藏超额复制。每个helper逐步保留24×24精确乘积或guard/round/sticky及RNE，沿已修正的抵消/±0规则；不用厂商裸FP的已知边界缺口替换它。转换、指数/符号操作、mux、流水寄存、返回队列均收费。当前单mul为2DSP只是资源估算依据，不能机械当新流水每个节点的实测成本。

上述内部节点记入一项`TANH_STREAM0`，**不免费占用**外部32M/16A，也不从softmax4/quant1/LN1的6条divider借容量；外部GEGLU的7M/2A仍由公共vector池支付。沿§8.5既有总额与312DSP非线性余额扣款，还须为exp/sqrt/其它divider留实际账；未知项不作0，不动裸余832为其重复买单。LUT/FF/RAM和shell同账，02的10410LUT/7132FF/2DSP不是新流水资源承诺。超节点/队列上限、实际器件/预算容量或端口冲突时，停止该具体展开并提交实测限制，不以继续复制流数或加满卡资源补吞吐。

**统一返回与有限credit。** 保持原32bit输入数据/tag及32bit result/status的ready/valid接口；生产完整身份由该tag与不可复用的任务/epoch绑定，不能只有裸元素序号。所有分支对齐为同一固定外侧延迟L，按输入接受顺序、至多一结果/clk返回；未使用的算术位置用安全dummy输入及谓词隔离，不让未选分支改变status。内部不可反压算术在接受输入时预约返回空间。固定总credit上限512，覆盖在途＋已返回未消费，返回FIFO至多512项；数据/tag/status至少6144B，另有valid/pointer/epoch及流水中间数/标签，全部列实际存储/端口。`in_ready`只在非reset且有空credit和完整输入身份时为真；输出反压时front payload/tag/status稳定，只在真实消费后释放credit。不能只给出min gap1：若L或实际服务需要超过512个未退休token，则照实反压和报告持续II，不自动扩credit。

每个流水token携完整可校验tag/epoch或与稳定任务记录关联的唯一slot代号；一个任务仍可在多个元素间流水，不由此提前宣称跨请求调度。同步高有效reset清全部有效位、预约/FIFO/计数并取消全部算术流水有效性，旧数据存储及无valid的算术数据寄存器可不清；生成helper的ap_rst无负载只有在父层valid/预约reset确实隔离旧返回时才允许；reset取消的token不得返回成功或释放新token的credit。上游任务失败仍排空已接受token并按原有序首错/发布规则处理，不跨失败任务复用未退休slot。进入LN等其它vector模式前旧GEGLU算术、返回、存储写及owner债务全部0。

**可立即执行的首个最小出口。** 沿原机器attempt/guard创建该单流候选，先用原fixture前128项做≤120s pilot，再在原帽内重放同2624真实z、640有限补例、6非有限status；独立gold不变，连续输入和原反压两profile均逐位/tag/status自检。保留第2轮345个独立原生RNE add定向（含原52项前缀），针对实际改动的乘/除流水补有限ties/sticky、normal/subnormal、符号/抵消边界，期望来自独立精确参考；原CPU200000有限tanh/600000基本op可复用其生成规则检新源码。短/长分支混排、512credit填满后停止准入/恢复、连续返回、在途与待返回reset均有实际握手/守恒断言；不得删旧断言来适应多在途，改为完整队列scoreboard。记录接受和返回总数、各分支/全例首延迟、持续间隔、credit峰值、内部两divider实际接受/返回计数及模式排空；只有实际持续准入、无错误和足够容量共同成立才记II1。

同轮完成该受影响模块实际OOC、层级资源与限定时序报告后由Astra集中评判，普通编译/修复无需中间放行。若串流方案在原成本帽内不能完成，保留已取得证据和具体资源/成本限制，不原样加帽重跑；正确串行基线仍继续服务真实生产连接。随后在同一入口跑完整Wi5248→真实GELU基本运算/tanh/gate2624，再接quant/Down，所有前后供数/首错/lease都按§0.2；不能用外部z测试代替此出口。该实现支持域声明不等于有限测试穷举证明，模块OOC不等于整网物理fit，完整CSim/分段RTL/连续全图/上板继续分层登记。

#### 8.4.8 stream02成本中止后的唯一有界综合修复

**历史路线现已按实际pilot成本停止，见§8.4.9；下述原合同及stream02功能证据保留，不继续逐个综合42个专用节点。**

实际`stream02`已通过§8.4.7数值/有限credit接口，42个生成算术child为23 add、17 mul、2 div；原[Tcl](../../../vivado/module_design/vector_and_ffn/tb/tanh_libm_stream_ooc.tcl)已经采用`flatten_hierarchy none / RuntimeOptimized / resource_sharing off`。实际[日志](../attempts/tanh_libm_stream_02/guard_ooc_01/driver.log)完成RTL展开/统计后在`Start Cross Boundary and Area Optimization`连续120s无新语义日志，guard在220.478544s终止，峰值11218356KiB，未触及24GiB或MemAvailable下限。此证据只能定位成本停点，不能声称Vivado死锁、内存爆或算术失败。重复添加flatten none、原样增帽、伪造进展日志均无效。

本次只批准一个**保持原HLS RTL/数值的逐节点DCP→父封装装配路线**，不再探索其它算术图或并行流。按receipt中42个实际cell/module清单及RTL真实依赖建立边界：逐child以同part/clock OOC综合并保存DCP；父`leaf`及512credit wrapper使用精确同名/同方向/同位宽/同参数的自动生成端口stub，综合小父网表后，向记录的唯一实际cell用`read_checkpoint -cell`等正常Vivado命令回填对应child DCP，最终连接并导出同一完整wrapper DCP。stub只用于这个中间步骤，不能进入功能RTL替代算术。保留每节点RTL/依赖/工具/参数/约束→DCP hash→父cell映射，若拟复用等价节点DCP，须证明真实端口、参数、module body及依赖hash一致（允许规范化唯一module名），不得仅凭add/mul/div名称猜相同。专用常量节点、不同端口裁剪和内部primitive依赖不得混填。

每个child DCP及最终装配均核blackbox；最终42个边界一一存在、无缺失/重复/额外placeholder，**最终blackbox=0才允许发布完整模块资源/DCP结果**。对子模块保留边界，避免再次展开重做全图跨节点优化；不以DONT_TOUCH全网或删除功能逻辑来制造成功。父真实FF/FIFO/标签/RAM/mux须一并计入最终层级资源，不能只相加child报告；clock及内部setup/check_timing有真实报告才登记，未做P&R仍不声称150MHz达到。若Vivado标准回填要求普通端口/路径修复，Sol可直接修复同一脚本并继续受影响步骤，无人工作业门。

全部child、父综合、回填及必要报告是**同一次闭合，累计墙钟≤3600s、owned RSS≤24GiB、任一活动子进程连续120s无真实工具语义进展则停止**；全程CPU0–3/nice19/idleIO/MemAvailable>192GiB且共同`control/heavy_tool.lock`，串行执行，不给42个child各自重置3600s，不并行绕锁。成功完成一个child/真实工具阶段可作为语义进展，定时打印/文件touch不算。短pilot选择一个完整端口mul/div及一个add子图，观察真实成本后用剩余节点/父阶段重算总预算；预测不能落帽就停止这条路线并保留局部DCP，不把局部映射称完整OOC。

原CPU、helper1159、3270双profile和credit/reset PASS按stream02精确hash复用；仅改综合脚本/装配不重跑全部HLS/RTL。受影响核查为实际DCP映射/全部边界与资源、必要的短装配综合网表数值/控制复验（原128项及有限backpressure/reset，先在原pilot帽估成本；无法运行则明确NOT_RUN，不虚构等价证明）。如改变RTL端口或算术，原不变证据可继续复用，但相应功能例必须重跑。该成本修复不阻断串行正确GEGLU生产连接及其它已授权模块。

**完整工作量和尾部收费。** tanh为Encoder28×128×2624=9404416，另Scorer16×1024=16384及ACT hidden256，共9421056；Decision4096采用ReLU，不另记tanh。150MHz/无供数停顿条件下，Encoder纯结果数/clk=62.696107ms，只是主体量。若每次GEGLU row调用排空，3584个row各收费已测375cycle tail，即`(9404416+3584×375)/150000=71.656107ms`；若Scorer16row及ACT1row也逐次排空，所有tanh合计`(9421056+3601×375)/150000=71.809540ms`。这些均未含GEGLU前后7M/2A、Wi/G供数、其它向量/Attention、写回/发布、排队/模式切换和实际Fmax，不是完整请求性能；跨row尾部重叠只有真实生产身份/容量/接口支持且实测后才可扣除。

#### 8.4.9 逐节点成本实测后的三类canonical流水子核与新父图

**集中选择：停止§8.4.8的42专用child逐一综合；只实施一次三类完整输入子核＋新父图的有界修订。** [bottomup01收据](../attempts/tanh_libm_stream_bottomup_01/receipt.json)中add0实际完成100.629917s；mul14在120.343482s timeout，综合虽已结束但timing在checkpoint前，未留下可接受mul DCP。累计220.973399s。按实际class成本，去掉重复timing也没有支持剩余42节点及父层在3379.026601s内闭合的可靠余量；按源码byte比例缩放只是乐观预测，不是完成依据。只改module名仍42种，进一步仅词法identifier/instance alpha侦察得到36个候选等价类，尚无端口/参数/位宽/常量/连接/寄存/reset/CE/latency与递归依赖的一一证书，亦不足以建立成本可行性；不将其当等价证明或继续扩checker探索。该停止是综合路线成本结论，不是旧stream02数值失败或所有空间流水资源不可能。

新候选固定三种已有完整a/b输入、同clock/CE的精确流水：`tanh_libm_stream_leaf_stream_add_node_0_s`、`...stream_mul_node_14_s`、`...stream_div_node_0_s`，均`ap_clk/ap_rst/ap_ce,a[31:0],b[31:0],ap_return[31:0]`。冻结其精确RTL/真实递归依赖、端口及已测helper身份；add0 DCP只有hash/part/参数/约束/latency完全匹配时可复用。mul/div各综合一次并保存DCP，**在新父RTL中**分别显式实例化23/17/2份相同模块，仍一输入流。不是向旧42个不同specialized child槽任意替换“算法相同”的DCP；父图/延迟/控制已改，必须新build及actual RTL。原C图24个add位置中add23常量`1−tiny`精确折叠3f800000，其余节点数量、位图、RNE/subnormal/±0、原tanh分支和所有常量沿§8.4.7，不FMA/重结合/近似。复制generic节点可能比常量专用节点更贵，完整assembly资源实付，不能用旧parent或class平均代签。

**可直接实现的静态edge合同。** 输入token在上升沿E0握手并寄存。表内C表示该值已稳定、下游可在E_C采样的最早边沿；每个独立bit/mux/转换块寄存一次，C=max(全部数据与谓词C)+1；每个FP节点在所有输入C的最大值发射，完整helper到下一消费者的edge差固定add6/mul14/div12（对应其输出在发射后5/13/11的NBA稳定）。不能把after-NBA latency误作下一同步消费者可提前一拍读取。较早的operand、符号、k/分支/valid/tag/epoch逐拍对齐到同一token的节点发射；静态常量也必须保留原32bit位型。以下为不共享FP位置的冻结可实现日程，表中的具体C不是实际已测新父图性能：

| 图节点 | C（按节点序号依次对应） |
| --- | --- |
| add0..add7 | 36,58,64,71,77,113,133,153 |
| add8..add15 | 173,193,213,219,233,265,286,292 |
| add16..add22 | 300,300,307,329,337,355,9 |
| mul0..mul7 | 16,30,52,52,79,93,107,127 |
| mul8..mul16 | 147,167,187,207,227,259,280,322,23 |
| div0(Dexp),div1(Dtanh) | 245,349 |
| 输入/初始sign-abs-core-low，y分支，k，fk | 1/2，17，37，38 |
| x/c选择，k1neg/forward | 65/78，66（其余仅依赖k的重建常量/谓词不晚于67） |
| mul14 operand mux，add14 operand mux，e | 266，94，293 |
| add16/add17 operand mux，add18 operand mux，mul15 operand mux | 294/294，301，308 |
| scale_input，rebuilt，exp，Dtanh numerator mux | 323，330，331，332 |
| tiny_input，最终result/status选择 | 3，356 |

各命名表达式逐项对应[冻结stream02源图](../attempts/tanh_libm_stream_02/frozen_source/tanh_libm_stream_bits.cpp)，包含`to_int/from_int`、无符号指数重建及tiny选择；若实施发现任一bit块不能按上述边沿满足工具逻辑/依赖，作为该同图调度的明确冲突修复，并重新核全部C与L，不能悄悄错接/引用旧375cycle。初版固定padding至**E384将result/tag/status提交返回FIFO**，out_valid/data最早在E384 NBA后可见，ready已高时最早E385消费；L384是接受→FIFO commit，不把消费周期和core可用边沿混写。无效bubble采用add 0+0、mul 0×1、div 0/1；合法token中未选分支严格沿冻结源的safe operands和最终谓词，不让dummy状态修改合法status。非有限status1/result0、±0与tiny/saturation都对齐E384。

helper ap_ce在正常运行持续1，512credit已预约的内部流水不因输出反压暂停；输入无效仍前移bubble并屏蔽其所有返回。若实现CE停顿则必须全图数据/谓词/valid/标签/日程同时停顿，另作受影响验证，不只停父FSM。沿§8.4.7保留总512个在途＋已返回未消费credit，FIFO最多512，E384入队前已有完整预约，out反压不会覆盖旧头；E0只在credit可用时接受。reset统一取消valid/credit/FIFO和命令epoch，不清所有payload；不能用helper无reset寄存的旧值生成新valid。短/长分支可每拍混排，一条流、原节点/有限存储上限不增。

**综合与验证共用原成本记录。** 本修订在同一次bottom-up闭合的3600s中继续支付，原220.973399s不消失，余3379.026601s供mul/div子核、三类必要封装、新父综合/42实例DCP回填/最终连接及报告；新build不重置额度。普通脚本先`write_checkpoint`、resource/blackbox，最后才运行一次完整assembly timing/check_timing，child不反复跑timing；add0现有DCP SHA256=`94da0b741f7476e1935079b1f027581a82f09ac9ec0565afc65cdc23e3ebe719`可按上述身份复用。24GiB/唯一锁/CPU0–3/nice19/idleIO/MemAvailable>192GiB及120s真实语义保护不变。最终23A/17M/2D实例与父存储/控制必须一一对应且blackbox0；模块综合timing仍不等于P&R/Fmax。若这一次新父图也无法在余帽内闭合，保存实际停点，不追加另一生成架构或加帽；正确串行GEGLU及其它生产连接继续。

新父图实际RTL重跑原3270双profile、独立helper1159的受影响连接/完整精确gold、512credit满/恢复及在途/待返回reset；断言所有节点operand与谓词同token、Dexp/Dtanh接受/返回守恒、所有分支E384 commit、输出有序稳定。直接比对原独立gold，不把旧生成top相等当唯一证明。随后Wi5248→GEGLU2624及§7.3.3桥按新身份受影响回归；源图C模型可复用未改数值证据，但旧stream02实际RTL375cycle不覆盖新控制。新L384全工作量条件费用另记，旧71.809540ms保留旧L375身份；即使新的tanh服务改善也仍须加GEGLU7M/2A、供数/存储/发布、LN7824row与Attention480head实测服务，不称62ms为全模型。

#### 8.4.10 G51完整row实际RAM0后的同容量三bank修复

[GEGLU canonical row01](../attempts/geglu_canonical_row_01/receipt.json)已实际通过完整WI5248→GATE2624数值/协议及51个真实FP位置模块OOC，限定资源176828LUT/299253FF/48DSP，blackbox0、IO0；其中算术95754LUT/42834FF，row/metadata/control81074LUT/256419FF。31488B的U/G/gate payload实际全部展开成register，BRAM/URAM/LUTRAM均0。该结果允许继续正确生产桥，但不是可忽略的存储代价。下一项只修这三个row array的物理表达，不再生成新的GEGLU/tanh数值图。

vector owner独占`vector_and_ffn/rtl/geglu_canonical_row_adapter.sv`与新增`geglu_row_bank_v1.sv`及其TB/装配脚本；production的GATE writer/quant/fullA/Down源不改。U、G、gate各一个独立bank，**2624×32bit、1同步读/1同步写**，总251904bit=31488B不变；标准独立clocked memory process仅按wr_en写、按rd_en更新输出寄存器，无reset/config循环清数据。read输出在停读时保持，地址先验<2624；不要把大型array塞回带reset或多处赋值的父控制进程。payload无有效语义时可旧值/X，父层coverage/state/read-valid/row generation保证不可消费；RAM primitive类型与碎片由实际OOC确认，ram_style只作意图。

**保留实际可见edge，不改算术流水。** tanh接受E0→E384 FIFO commit、最早E385消费仍保持；GEGLU外部7M/2A加tanh组成的实际core commit延迟506亦保持，不能误称GEGLU也是384。全WI捕获、wi_row_done成功且真实读债务0后，PREP edge P同时使U/G bank读取index0，q在P NBA后稳定；RUN最早P+1将这对数据实际交core。每次`arithmetic_accept`时为下一合法index同步read，q于该edge后更新供下一拍core使用；不能发新core token时rd_en=0保持当前operand。父层显式保存operand_valid/index及row_generation，数据与issued索引一致，reset/错来源清valid而不清RAM。最多一对预读operand，不扩core512 credit；完整identity/三个Context/Ref继续驻留，行不可在算术/源读债务未清时复用。

每个真实core commit在gate bank的returned index写其成功数据，同时更新原coverage/错误归约。只有最后index2623成功commit、全部2624覆盖及core credits0、无任何更早错误的edge C，才准请求gate bank读index0；最后写地址2623与读0不同，禁止依赖同址write-through。gate q在C NBA后有效，最早C+1以原`v_valid/data/row/col/last`输出，保持原整行屏障。每次v握手且col<2623，在同edge读下一col并推进输出索引；下拍可继续一F32，v_ready=0时rd_en=0且q/索引/tag稳定。末col握手后不读越界地址，不提前生成row_write_done。若工具包装额外寄存器确实增加row I/O边沿，显式调整局部read-valid/pipe并重测该成本，但不得修改inner E384/E385或core506来掩盖错位。

G优先于U及原逐步GELU/gate first-error顺序保持；晚错误可使已接收core token排空，但不发该失败行的成功v流。core数据/tag为顺序返回也必须核范围/唯一coverage，read buffer与输出buffer按row_generation防旧返回被新行消费。实际row_write_done仍由production真实AW/W/B/pack债务0和正确task/dst epoch/row确认，诊断ack不代替物理成功；整task GATE发布及quant/A lease继续§7.3.3。下一行只在前行真实writer完成、所有本地read/output/core债务0后复用这三bank。

一次受影响回归复用原完整WI/gold、六个完整row/压力、G-before-U/晚错/完整identity/源完成和输出保持/reset范围；新增三bank全2624地址独立pattern/首末和非同址并发读写、P/C边沿及中途背压/row-generation恢复断言。亲核旧canonical算术hash未变即可复用51个FP数值/资源证据，仍重跑新RAM父封装实际RTL及已通过G→GATE→quant/fullA真实桥的受影响接口，不能仅用memory pattern代签。OOC只重新映射三个bank与新父控制并装配原51个精确子核，最终blackbox0/IO0且全部31488B实际容量存在；先DCP/resource后一次timing。沿该G51原3600s累计闭合记录余2676.424594s，不给三个bank各自新帽，不恢复整网综合/P&R。新资源取得后再比较原81074LUT/256419FF存储控制部分与bank成本；不把旧RAM0隐藏或预报新物理fit。

**受影响桥已于本阶段实际关闭四个不同真实row的正常范围。** [bridge RTL04](../attempts/t2_geglu_gate_quant_bridge_rtl_04/receipt.json)从原enc0的四个不同WI行，经本节三同步bank GEGLU产生10496 GATE字，真实656个AXI写beat/末B后再656读beat，四次完整row quant共328group，完整dualA的328次held-return身份读/release通过。未预载GATE/q/PS；owner拒绝、源读债务及AW/W/B反压实际覆盖。上游Wi Q8、下游Down同runtime连接、晚source/numerical/AXI错误、active-chain reset与two-A重叠仍不由此证明，不能拼接另一个预量化A的Down测试称整链通过。最新物理停点与余帽见§8.4.11。

#### 8.4.11 三bank父OOC再次成本中止后的单bank加四stub闭合

[row_bank_v1终态](../attempts/geglu_canonical_row_01/row_bank_v1/receipt_terminal_01.json)已通过三bank全深度及六完整row实际RTL，core506/tanh384/385与原算术hash不变；新父综合仍在Cross Boundary and Area Optimization连续120s无语义进展而停止。RTL elaboration的“3个2624×32 RAM”不是实际primitive映射，尚无新父DCP、RAM资源或完整装配。已从原成功G51 DCP导出完整不变算术子树（51FP位置、164port bits、blackbox0、95754LUT/42834FF/48DSP）；该精确子树可复用。原G累计1261.775981s，3600s内余2338.224019s。

**只保留一条保持RTL/延迟/容量的有界分层路线，留复制后工程实施，本阶段不启动。** 先对同body/参数/端口的`geglu_row_bank_v1`综合一次完整动态地址单bank，全部2624×32和同步1R1W/q保持必须存在；保存bank DCP/EDIF、实际RAM映射、资源及端口hash。再以三bank精确stub及已有core stub综合原父adapter，预期恰四个blackbox边界：u_bank/g_bank/gate_bank/arithmetic。父RTL、数值、coverage/identity/reset控制、read/write edge均不改，仅把存储映射从父优化问题分离；stub不增加寄存器或模拟read latency，不能把coverage等父控制另藏进未计资源黑盒。

父checkpoint及资源先落盘，随后将同一完整bank EDIF实例化三次，与已导出的exact arithmetic EDIF、当前父EDIF完成真实link；核对每个port位宽/方向/bit顺序、参数/时钟/reset/使能，51算术位置及三存储全覆盖，blackbox0/IO0，保存完整DCP和层级资源后才做一次final timing。同名模块处理只许工具唯一化或严格实例复用，不换较小body/不同版本核；不能以单bank×3加资源或旧父DCP替代新完整装配。所有bank/parent/link/timing共用余2338.224019s、24GiB、120s真实语义帽及唯一重工具锁。

该分解针对已见父优化成本，尚未证明能完成；若单bank失败、四stub父仍在同阶段触发保护或余帽不足，保存具体状态并以新RAM/父资源UNKNOWN收口，不原样重试、串试另一算法或重置累计额度。功能证据沿当前相同RTL复用，production负责受影响真实G→GATE→quant/fullA桥；只改变综合边界不再跑未变算术gold。没有整网OOC/P&R/板或LN/更宽Q8扩展授权。

### 8.5 同一账的闭合方法与停止出口

| 资源 | 当前未改条件账 @150MHz | C3/C4待证的公共或差异条件 |
| --- | ---: | --- |
| W payload | 48.094133ms，严格scale扫描另307.802453ms | 三独立读流19.237760ms；T3准入、冷LOAD/尾排空和实际效率另计 |
| Q8 | 当前TM1 1228.144693ms | 仅条件TM16/TN16 A+B为38.379573ms，映射/供数/R0/PS尚须成立 |
| QK+AV共享FP池 | 历史单context/F=11为49.152ms | 当前实测F=13：按读跨度C3 29.059200ms、C4 26.214400ms；按本TB全例局部窗口为29.392000/26.470400ms，均还依赖理想QK与F256条件 |
| softmax独立资源 | 旧三扫26.2144ms漏含非线性/树实现条件 | 本候选三扫32.768ms，实物树和8row流水的延迟/冲突另计 |
| quant独立资源 | 8lane两扫37.110187ms | 16lane两扫18.555093ms＋真实divider/返回服务 |
| vector共享池 | 原LN8与GEGLU4分项不代表联合吞吐；旧错误叶子77.366613ms只作历史 | 当前第2轮正确单slot叶子按已测row分布外推单叶约26.149700s tanh服务；§8.4.7单流II1若成立，整个共享vector条件主体93.040640ms＋真实附加服务，详§5.1。所有数值均非整图实测 |

旧75.3664ms来自QK/受限AV/softmax串行相加。新配置只有在两个SCORE槽、独立softmax、AV context和QK/AV共享池的实际调度允许重叠时才改善；**不得直接取上述行的max称完整延迟/吞吐**。先用完整单head128queries/8个tile的有限事件模型，资源分别记录占用、每槽状态/epoch、QK与AV互斥、softmax完整tile发布、PROB复制、AV反馈、writer及KV预取。模型输入必须列实际微基准测得的服务/延迟，未测值参数化而不写PASS；每个动作都要有前驱和容量，不用任意延迟回放拼出理想重叠。先核C3，再按明确失败原因比较C4；输出具体阻塞资源和每tile关键路径。

固定资源账在A+B假设下：Q8 6144、共享QK/AV1280；规划vector/quant/softmax的512DSP配额中，已拆出的基础算术为vector128+quant48+softmax减法/树24=200，余312仍须容纳相关非线性，不能记作已满足；control/bias/conversion规划256保留。4exp、4tanh、6divider（softmax4/quant1/LN1）、1sqrt及其FIFO/银行、QK scale/mask/FP tail与shell必须以实际结构计；若超配额，使用裸余832也须保留shell真实需求，不能同时花两次。所有bank/LUT/FF/BRAM/URAM未知继续列UNKNOWN，条件DSP相加不构成物理PASS。

单请求若仍用当前完全串行task调度，单Q838.379573＋共享QK/AV26.2144已64.593973ms，首请求50ms尚未闭合；跨模块/跨请求重叠需T6/T7合法producer/owner与更多存活缓冲，不在本微基准自动解锁。板端持续服务仍未测，20/s仅为远期参考。当前T4/T5出口是数值正确的端口/反馈/非线性服务、同基线相对改善和可解释资源预算；按真实资源/协议冲突整改C3/C4，不单凭超过旧参考淘汰。不能把局部正确与条件max拼成完整高性能已达。

### 8.6 首个可直接派发实验：单bank AV反馈投影

Root可把本节一次派给空闲计算owner，独占`attention_and_fp_engine/rtl/tb`的新增`av_feedback_*`文件并维护该模块两份source文档；Q8现有FP制品只读复用，不能改动T2文件。准备可轻量进行，编译/仿真等当前T1/T2重工具时段释放后运行。本例只需**一个真实FMUL、一个真实FADD、一个partial bank**；先取得反馈证据，不生成F256、完整QK或exp/div。

| 项目 | 固定实施范围 |
| --- | --- |
| 算术/IP | 复用实际`tm1tn8_fmul_ip`/`tm1tn8_fadd_ip`及其XCI/仿真模型身份；配置来源为`q8_linear_and_restore/tm1tn8_gs32_512/tb/create_fp_ip.tcl`，当前配置延迟6/11、NonBlocking、II1。6/11仅是IP配置事实；本轮整个反馈F已实测13，见下方结果，不以行为延迟模型替代真实IP结果 |
| bank与地址 | 投影§8.2的固定`bank=0`，即`row_local%4=0,d=0`。最多16个F32 partial，地址`4*context+row_local/4`；同步1R1W，读请求到数据固定1cycle，不做同拍写回旁路。用明确同步RAM实现及其实际仿真模型，若仅RTL推断意图则物理BRAM/LUTRAM映射继续UNKNOWN。每轮开始显式清零活跃地址，初始化时间单列 |
| 请求与返回 | 输入ready/valid携F32 prob、F32 V及§8.1的slot/slot_epoch/task_id/row/key/lane全字段（lane固定0）；context表保存完整NumericIdentity及query tile起点。接受前检查映射、身份和每地址下一个key，成功接受才推进key计数。product Q32和commit Q32各32个标量slot，沿§8.2先预约后发射；每地址busy从partial读接受保持到实际写回退休 |
| 观测/反压 | commit诊断ready/valid输出完整tag、product、old_partial、next_partial；仅当预约commit槽可接实际返回时发FADD，写回后诊断可在该槽停留到消费。诊断阻塞只能通过有限credit自然反压新接受，不能丢弃已接受返回；首done须全部key完成、busy清零、两队列及FP/诊断债务为0 |
| 两个配置 | C3依次处理tile批`[0,1,2]、[3,4,5]、[6,7]`，每批按key0..127、context升序、row组0..3轮转；C4为`[0,1,2,3]、[4,5,6,7]`。两者都覆盖全head128queries中row0,4,…,124的feature0，共4096个FMUL及4096个FADD；每批全部退休后才能改context绑定。只有context数量变化，其余RTL/IP/FIFO/RAM配置相同 |
| 输入与gold | 绑定§1同模型/请求的enc0、head0、B1/S128；V取实际v4 producer checkpoint，prob可由独立`tests/full_reference.py`的QK/softmax从同checkpoint生成，必须标为外部oracle输入。逐key独立F32乘法与升序加法生成所有product/partial gold，不能读新DUT输出。checkpoint不足时保留`NOT_RUN_INPUT`，先做下面短诊断；不拿旧S64或另一build冒充v4真实例 |

短诊断与两个配置复用一次编译：有限正常值的单地址连续key测本征F；不同地址连续至少256次接受核实际IP II和预约；输入bubble、诊断ready定种停顿并至少一次填满commit容量；错epoch/row/key拒绝且无写回；有乘法/加法在途时同步低有效reset清valid/身份/busy，旧返回不可写入重初始化的新epoch，随后合法恢复。负例都在局部新top中完成，不声称生产owner/reset链通过。已知33个FP边界失败保留，真实输入若触发任何基本运算差异立即FAIL；正常域通过不扩大为通用IEEE通过。

测量逐请求记录`mul_accept/return、partial_read_accept/return、add_accept/return、partial_write_commit、diagnostic_retire`，核对守恒及tag；单地址无外部停顿实测F，正常/受压分别列accepted间隔、busy/credit停顿、批尾、初始化和fill/drain。轮转模型单批n个投影地址的读接受跨度为`(128−1)*max(n,F)+n`，只计该跨度，不含初始乘法填充、最终返回/写回及批间重绑。故F=11时C3三批4477cycles/head、C4两批4096cycles/head；§8.2的4480cycles/head是按完整key frame收费的近似值，差3cycle/head不能再与末尾空slot/drain重复相加。使用实际事件替代近似后，再按480个head的原工作量复算；任何投影乘以256只是条件服务推算，单bank通过不能证明256bank端口、布线或资源成立。

本例正式结果已集中核验：C3/C4各4096贡献逐product/old partial/new partial及全部返回守恒通过，短例测F=13、不同地址连续接受II1、Q32双队列填满反压、3类拒绝及两种FP在途reset恢复。当前服务账使用上文F=13实测；C3满批无泡条件已否定，C4局部无泡仅保留为下一项有限服务建模输入，不自动解锁F256。已得原始事件计数足以复算上述范围，不为本轮单独新增逐请求日志重跑。

退出规则一次生效：gold/协议失败按FAIL留证并做合同内修复；成本沿§0 pilot≤120s、正式≤8GiB/3600s/40M cycles，超帽不加额度；F>12即否定C3满批无反馈泡假设，F>16亦否定C4，仍报告实际服务而不自动加context。本例最终交付是带身份的单通道功能范围、实测F/II/队列占用和C3/C4有限调度复算，集中并入阶段验收；不为每个短case新增审核文档。

## 9. T6/T7早期成本边界及两种替代覆盖

本节是已有3600s/40M cycles硬帽的早期应用，不新增审核门，也不阻断T1–T5优化模块。先核实际工作量与已有同结构实测速率，再决定是否值得准备完整长链；不等整层TB全部完成后才发现成本不足。以下墙时是服务器仿真成本，与条件150MHz硬件服务毫秒不同。

### 9.1 已测成本与同实现条件外推

实际依据：[QKV四行pilot guard](../attempts/t2_tm4_real_qkv_lut_pilot_01/guard/guard_result.json)在120.402s保护触发，包含编译/加载，仅完成2048/12288 stripes，不能用120s全部作为稳态算术窗口；随后[复用编译的正式guard](../attempts/t2_tm4_real_qkv_lut_full_01/guard/guard_result.json)为exit0、408.346s、峰值RSS911996KiB、无保护触发。[正式原始日志](../attempts/t2_tm4_real_qkv_lut_full_01/work/sim/simulate.log)记录完整12288 stripes、393216 group records、stalls0及`TM4TN8_REAL_MATRIX_PASS`，仿真`run`段403s（xsim整体405s）；由此得到约30.49 stripe/s。这里每stripe实际承载4row×8lane、完整GS32整数及独立FP/PS路径，全部中间gold检查仍开。该结果用于成本校准，不在本节提前发布T1/T2集中验收。

工作量来自同一[budget JSON](../../cpu_embedding_q8_validation_20261010/pipeline_budget.json)的`q8.families/geometry`。layer0的QKV/Wo/Wi/Down每四行分别12288/4096/20992/10496 stripes；S128需32个四行块，故分别393216/131072/671744/335872，合计1531904。用当前同32-FP通道及同检查密度的403s完整窗口作条件校准：

| 范围 | TM4/TN8等效stripe数 | 约30.49 stripe/s下的仿真段投影 | 单在3600s完成所需速率，尚未留其它阶段时间 |
| --- | ---: | ---: | ---: |
| layer0 QKV完整128行 | 393216 | 12896s，约3.58h | 109.23 stripe/s |
| layer0四个Q8矩阵 | 1531904 | 50240.7s，约13.96h | 425.53 stripe/s |
| 完整图全部Q8 | 46055432 | 1510444s，约17.48天 | 12793.18 stripe/s |

这是**当前仿真实现的工作量投影**，不是整层/整图实际运行，也不是新架构的严格墙时上下界。不同shape、输入切换密度、RAM实现、端点及检查开销仍会改变速率；表中未计Attention、quant、LN/vector、真实AXI/owner、初始化及尾排空。Root现场曾观察约2048 stripes/45s的较快短窗（约45.51 stripe/s，原进度行未逐条绑定墙钟，仅作乐观敏感性）；即按该速率，QKV128仍8640s、四Q8仍33660s，分别2.4h/9.35h。现有证据足以否定“照当前TM4事件密度直接扩到完整layer0就可落3600s”的准备假设，不必先实际超时一次。

TM16/TN16的几何增大可减少stripe/cycle数，但同时增加真实算术模型、信号更新、队列/银行和gold检查事件，不能把8倍硬件并行直接换成8倍仿真墙时加速。新候选若确实改变仿真结构，须用该实际候选的短pilot测有效group/基本运算事件速率及RSS，再替换本表系数；删掉中间检查、把FP替成理想行为延迟、跳过矩阵或改gold均不作为同范围提速。

### 9.2 周期硬边界与状态登记

当前单TM4/TN8的完整图Q8理想接受服务已经是46055432cycles，超过40M帽，尚未计其它算子/空泡。后续条件TM16/TN16单Q8引擎仍需5756936cycles/完整请求；若T7受控序列从空请求债务开始并完整计算最少8个请求，仅该共享引擎服务就至少`8×5756936=46055488cycles`，也超过40M。跨请求重叠不减少同一引擎总工作；不允许将部分请求预计算到受控进程/计量窗口之外、减少N后称原序列完成或拼接reset进程避帽。此结论只针对上述固定几何/单引擎及原序列范围，不能写成所有可能架构均不可验证。

T6/T7尚未实现、候选/依赖未定时继续标`NOT_RUN_DEPENDENCY`并附本节成本风险，不以条件表冒充实际成本中止。确定采用上述相同工作结构/几何后，可据明确工作量、绑定的测量或硬周期下界，对**该具体长例**记`NOT_RUN_COST（运行前成本排除）`，注明未启动完整长例；实际保护中止则另记真实attempt/完成进度。无需为已经超过硬周期下界的配置再跑超时pilot。若不同候选无足够下界，先≤120s真实pilot，按算术/事务进度计量；正式过程中仍沿§0两个相隔≥60s有效窗口超帽或120s无语义进展停止，不自行加帽。新模块短例继续依赖推进。

### 9.3 仅保留两种有界替代

1. **真实producer检查点分段RTL。** 保留原模型/请求/shape和独立gold，对已有v4真实producer导出的完整维度输入验证QKV/Wi/Down等已声明四行范围，及T4/T5的完整K/N、完整S128 query row/D64、LN D1024、GEGLU2624等有界模块；每段自动绑定输入producer、hash、row/head范围、数值中间值、owner/epoch、最终返回与恢复边界。未实现的Wo或其它边界按合同补必要短范围，不把一个代表矩阵自动覆盖全部122张。跨段交接明确是检查点重放，不能声称同runtime连续完整layer0或完整图通过，更不能拼出连续请求吞吐。
2. **当前身份CPU/CSim完整图＋真实FP RTL边界。** 对实际当前生产身份执行完整28 Encoder＋2 Decision＋scorer/ACT及持久请求/错误恢复CPU/CSim，独立参考和既定逐位/原容差不变；RTL继续以真实FP IP验证T1/T2/T4/T5算术、有限缓存/反压/复位和producer消费边界，另用这些实测服务参数维护有容量/依赖约束的有限事件模型。旧v4 CPU通过只能按原身份复用，不能覆盖未来修改后的全图；CSim的libm、接口模型及条件调度不能替代真实FP数值、物理时序或整图RTL持续吞吐。

两种替代均用于提供明确范围的离线证据，不更改原数值gold、不把未执行长链写PASS。完整layer/图的同runtime连续执行、至少8请求的有限吞吐、板端20/s与端到端50ms分别保持其真实未测/成本状态；本节不以替代覆盖关闭这些目标。
