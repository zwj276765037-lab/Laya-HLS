# QK/AV生成RTL修复合同与性能偏离处置

日期：2026-10-08；设计主持：GPT-6 Astra xhigh。工程：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline`。本合同承接用户对“性能未达到要求、计算未符合功能”的反馈，先查实并修复成功数值路径；不以新增解释文档替代工程修复。本轮实现由GPT-6 Sol max执行，独立Astra xhigh审核。

## 1. 已确认问题与责任边界

现行build `04934c15b3f83e842ec2e92ac2a81bf2`的QK/AV生成任务分别为`full_run_task_33/35`。两者context检查成功后仍固定返回E_SHAPE、elements=0，无Q/K/V/score/prob数值端口；完整生成RTL推理未成立。CPU完整图与标准libm CSim通过、HLS生成和OOC综合成功，分别只证明其各自阶段。此前把这些结果连起来解释为完整硬件功能已经接通，证据不足。

性能偏离属于另一条问题链：`hardware_agent/task.md §12.1、§12.5`明确F0是单任务阻塞基线，Q8叶为标量循环；实际综合配置关闭自动pipeline，源码没有并行dot阵列或跨任务DATAFLOW。旧16×8×32/64路FP候选预算没有落实到实际电路。这不是U55C速度不足的实测结论，也不是仅靠提高频率能消除的差距；`pipeline_loops=0`不能用来解释QK/AV为什么固定报shape错误。

50ms是用户A6000对照目标，保留该目标，不能降低目标后声称满足。尚无同口径U55C可达证据，本轮不承诺用简单unroll达到它。预算/后续验收明确分别报B1/S128与B2/S128；历史72/94等业务有效token长度按现有物理S128执行，不得与有效长度、GPU动态shape或不同batch计时混用。成功图Q8工作量和现有leaf调度得到的分钟数是条件外推，不是当前提前错误RTL的实际成功时延。

## 2. 不变的数值、任务与所有权合同

权威依据为[task.md §12.2–12.5](../../hardware_agent/task.md)、[Attention数值/接口](../../vivado/design_source/11_attention_and_fp_engine.md)、[Q8 R0](../../vivado/design_source/09_q8_linear_and_restore.md)、[共同typed-task/owner合同](../../vivado/design_source/15_integration_interfaces_and_pipeline.md)。本轮已重新读取这些源，不能以早期“推断”标签放宽后来冻结的P2合同。

- QK：64次独立F32乘法、固定相邻二叉归约，乘0.125后加finite mask/local bias；所有S个key参与。AV：每输出按key升序乘法后独立加法，acc从+0开始。禁止FMA、重结合、FTZ/DAZ及掩码跳算。
- shape、op/stage/layer、row space、B/S/head、ref/bank/epoch/identity、预期生产者、coverage检查全部保留；非法条件应在相应数据访问前拒绝。不能删除失败guard、把错误变success、放宽期望值或伪造elements。
- 只有真实数据生产、完整覆盖、owner状态合法的任务才可发布READY；SCORE→PROB独占lease、QKV双shard FINAL_READY、当前head KV绑定、AV逐head输出覆盖/退休规则不变。
- CPU/CSim继续按现有系统libm与严格浮点合同逐位比对。QK/AV基本算术顺序的精确要求不放宽；softmax等新增非线性HLS实现才适用既有`1e-4+1e-4*abs(ref)`算子误差线。不得用非线性容差掩盖地址、owner或shape错误。
- 不缩短主干层数、不减K/N/S、不跳候选、不用CPU/native代算补偿。诊断小top可缩小调用范围，但结果明确仅代表该局部边界。

## 3. 分阶段执行与放行条件

### D0：只读根因追溯，立即执行

保留当前源码、编译配置、生成RTL、已有IR和全部旧结果不动。实现负责人形成每个QK/AV shape predicate的表：源码表达式、合法controller构造值、runtime写入路径、CPU合法值、各IR阶段是否保留/恒化、最终RTL信号及判定。

追溯顺序不是只看报错点：

1. QK的op/stage/row_space、S、mask_mode、scale_bits默认初始化、kv/loaded_kv_ref/head、score.id/bank。
2. AV除公共项外追prob/ref、partial/dst、score_valid、score head/stage/layer/batch/row0/rows及final_qkv_ref绑定。
3. 对每个被判常量的runtime字段向唯一writer回溯，优先LOAD_KV成功分支及其上游QKV/RoPE发布。已知C++ LOAD_KV会写loaded_kv_ref/head，而最终RTL丢失这些状态端口，必须解释第一次消失发生在哪里。
4. 对比正常CPU与`__SYNTHESIS__`预处理路径：cache数组外置、persistent runtime、默认成员初值、重置/清零、const/alias、结构体拷贝与函数特化。差异要展示值/IR，不能凭猜测归因。
5. 使用已有前端/链接/HLS优化IR寻找“最后有成功分支”与“首次恒错误”的相邻阶段，绑定具体文件hash和函数/语句。若源码本身构造了非法值，先承认源码错误；若只有某pass改变语义，才建立工具问题假设。

可以运行小型CPU诊断或前处理/IR解码；结果目录为本目录各独立run。诊断harness可显式注入状态用于单个谓词真值实验，但这种状态注入**不能作为真实typed-task/owner成功验收**。

D0出口必须是可证伪的具体原因或已缩小的单一条件/变换，不接受“编译器优化太激进”“综合成功所以没问题”等泛化结论。

### D1：最小复现与最小等价修复

根据D0提出小top：只包含触发首次错误的类型、状态写读和条件，保留错误前后的实际构造方式；动态输入必须能覆盖合法与非法两条路径，不靠把合法值写死让工具删校验。与对照变体只差一个被怀疑的结构操作/pragma/存储边界，并记录双方源码和配置。

若D0可直接证明源码条件错误，允许Sol先提出一处保持数值/owner合同的修正，交Astra核定后修改唯一生产实现。若是工具变换，采用有最小复现支持的等价重写；不得通过对全部metadata加volatile或禁用所有优化掩盖原因。每个变体单独保存，失败也保留。

首次局部HLS试验必须由D0事实界定范围并由Astra技术审核放行；这不是再次向用户索取授权。默认4个逻辑CPU、nice19/idle I/O，本任务树RSS不超过16GiB、主机MemAvailable至少192GiB、单试验最多30分钟；记录工具版本、命令、树PID、资源、退出码和所有实际输入hash。达限立即保留诊断，不升级成全网综合。根据局部真实需要调整上限须先内部审核并记录，不影响其他项目。

D1通过标准：原最小复现稳定出现相同语义错误；单一等价修复后CPU和生成RTL均有合法success与非法拒绝，且状态字段/数据依赖在IR中真实保留。仅多出一个端口或不再恒E_SHAPE不足以通过。

### D2：真实typed-task联合链验证

修复必须回到唯一生产源码，而非只修测试wrapper。按真实owner/loader/任务建立`QKV FINAL→LOAD_KV→QK→SCORE/PROB lease→Softmax→AV→ATT_OUT`联合切片；Encoder路径还必须覆盖`RAW QKV→RoPE→FINAL`，Decision验证无RoPE路径。

最少覆盖：S128正常题、B1/B2、head0与15、首/末合法row tile、full/slide mask及全padding有限mask；另对S64与S1024边界进行针对性任务测试，不冒充所有shape的整网运行。QK每任务输出rows×S，AV每任务rows×64；所有数值和输出位置均与独立期望比较，尾部sentinel、未写行和邻head不可破坏。

负例逐项覆盖实际根因字段，以及错S/head/bank/ref/epoch/request/layer、缺coverage、未加载KV、过期score和重复head写入。检查first error、零/部分输出语义、失效/保留规则及下一次合法任务恢复。不能由测试先手填READY然后声称真实链通过。

分开报告：严格CPU、标准libm CSim、生成RTL结构核对、Verilog/XSim或HLS cosim。RTL要求至少一个真实合法数值任务完成、合法输入扰动导致对应输出变化、非法条件仍拒绝；若含外部AXI必须检查读写实际数据与完成退休，不能仅看ap_done。基础QK/AV运算保留精确合同，softmax非线性按既定误差线分项记录。

### D3：集成回归与完整top重建

只有根因闭合、局部修复数值/owner/RTL联合链通过且独立审核接受后，才放行完整top HLS。不得直接把已知失败的全网重新综合当诊断方法。

生产源码改变必须生成新的build身份/包绑定，保留旧04934 manifest及所有旧证据。先用新身份完成现有真实B2/S128与两次重基B1的完整CPU、持续会话/故障恢复和真实13口top CSim；核47×3检查点、任务计数与结果帧，不只比最终top1。

完整top重新生成后，必须机械核查QK、AV、RoPE及其他数值任务不再出现合法调用固定错误/零元素；追踪关键状态写读与数值RAM端口。生成RTL资源可能大于旧345,505LUT/437DSP，旧OOC资源不能当作修正设计的容量结论。完整top RTL仿真、平台链接、布线时序与上板仍逐阶段报告，未执行不得并入成功声明。

## 4. 性能架构后续合同：先联合切片，再决定整网目标

此节给下一阶段具体设计/测量要求，本轮不得让Sol自行unroll完整网络。性能修复与功能修复分别验收，先恢复正确路径。

### 4.1 必要算力和带宽条件

B1/S128 Q8工作量为47,160,754,688 MAC，B2为94,321,509,376 MAC。50ms@150MHz预算7,500,000cycle，因此B1仅Q8就需6,288.10理想MAC/cycle，B2需12,576.20，尚不含浮点恢复、attention、非线性与IO。

旧16×8×32候选最多4096 MAC/issue；即使每拍issue、满利用率且没有任何其他成本，B1 Q8也需76.76ms，B2需153.52ms。因此不能把旧候选实现以后就保证50ms。

旧64路共享FP候选也有独立必要下界：B1/S128的QK和AV各503,316,480个FP乘法贡献，即使64路每拍满载，串行共享引擎合计也要104.86ms；B2为209.72ms，尚不含softmax/scale/mask/IO。B1若单独将这两算子压入50ms，至少需134.22个FP乘法贡献/拍并配足规定顺序的加法/归约吞吐。Q8与Attention都占用请求预算，不能让它们各自使用全部50ms再称整网达标。

现有每请求q0/q1各约184.68MB，当前每口32bit@150MHz单向原始上限0.6GB/s，单口传输必要时间约307.8ms。若50ms内装这些权重，两口各至少3.694GB/s**有效**带宽，scale约0.462GB/s，另加激活/结果。因此AXI拓宽、burst/packing、并发bank和权重复用同样是必要设计内容。512bit@150MHz的9.6GB/s/口只是原始峰值，必须以平台连接和有效率验证；不把它写作既定可用值。

### 4.2 参数化联合切片的具体数据流

设计一个单一Q8引擎原型，几何记为`TM×TN×GS32`，按group外层、输出column-tile内层轮转。首个表征点取TM4/TN8/GS32；后续TM8/TN8、TM16/TN8、TM16/TN16只有依据测得II/资源/布线与完整预算再选择。首个点用于确定真实可扩展代价，不声称达到50ms。

- 每issue精确计算`TM×TN`个32项S8 dot：整数乘法/加树可并行改变结合，因为必须无溢出且INT32精确；每group每输出保留一个精确dot。
- R0恢复逐输出严格为`scale_product=F32(scale_a*scale_w)`、`term=F32(scale_product*F32(dot))`、`acc=F32(acc+term)`。F16次正规精确转换保留，不改为FMA。定义并测量dot、int-to-float、两个乘法、累加的latency/II，不能只报INT8 core II=1。
- 所需片内读带宽每issue：A为`TM×32`B、W为`TN×32`B、scale为`2×(TM+TN)`B；A向TN广播、W向TM广播。PS读和写分别`4×TM×TN`B。按row/column lane分bank，写明每bank字宽/深度/端口与RAM映射；禁止用逻辑数组partition承诺真实供给已足够。
- PS按输出tile轮转，真实同地址复访间隔为`ceil(N/TN)×II_issue`，要求不小于F32累加反馈延迟和RAM读改写hazard窗口。N2尾必须显式等待/旁路防冲突，不能用改变group归约顺序消除依赖。
- 连续矩阵N/K和tile尾用有效lane掩码控制；不读取越界A/W/scale、不输出多余列。bias在全部group完成后按冻结次序加入。
- Quantizer实际32元素两遍扫描/舍入与A8缓存供给按测得吞吐计；A8一tile供整个N。权重load、PS排出、下一tile量化仅在拥有独立存储端口和合法owner生命周期后才能重叠，双buffer不是加两份指针。
- 成功最后group退休→PS可读→bias/输出写回→响应退休→TaskDone，必须有明确计数与背压；局部stall不能重算同一group或丢一项累加。

### 4.3 性能切片验收与整网预算门槛

输入必须覆盖模型真实不同K/N（1024→3072/1024/5248/4096、2624→1024、4096→1024、1024→1024 scorer、256→2 ACT），以及真实F16次正规scale、负dot、零激活与不满TM行尾。逐位比较q/scale/dot/term/每group partial/bias/最终F32；随机背压和N2反馈必须通过。

每个候选输出：实现II与反馈/停顿原因、有效MAC/cycle、恢复/PS/量化/输出各自瓶颈、峰值与实测片内/外部bytes、真实LUT/FF/DSP/BRAM/URAM和时序。性能候选放行至少要求同源切片RTL数值/背压通过、OOC实际映射资源无黑盒、6.667ns请求下内部时序及受限I/O说明；资源必须在完整修复核与平台shell可用余量内核算，不能套旧缺陷制品的剩余资源。真正150MHz/更高频率达成须平台布局布线与时钟约束证明；上板性能以同B/S、同输入padding、同模型/数值合同的start/done和Host端计时分别验收。整网模型只能使用这些实测切片系数，串行段相加，已证明可重叠段才取max；同时补入完整QK/softmax/AV、LN/GEGLU及主机/平台成本。

资源/带宽无法覆盖50ms必要条件时，应给出证据支持的可达范围与结构选择，不把A6000对照指标悄悄降成已验收目标，也不以未知利用率修饰为保证值。需要改变精度/归约/attention算法来换速度时属于新的数值合同，必须另行设计和质量验证，不能混入本次shape修复。

## 5. 证据保存和文档职责

`results/performance_estimate_20261008`及旧综合/审核不回写。本目录保存新诊断predicate表、IR定位、最小复现、变体diff、运行配置/日志/hash、局部与集成结果、独立审核。模块source/design/results仅Astra维护，以新增当前进展方式保留历史，不把旧制品的通过记录移到新身份。

用户仅在发现新异常、关键决策或本轮完成时收到报告；内部执行依赖通过代理消息协调，避免例行进度打断。

## 6. D1放行补充：明确presence取代nullable metadata pointer

D0新增证据已经足以放行局部A/B：原始链接IR保留合法局部QKV数组的非空分支与pair写回；LTO/reflow后stage2、stage4的QKV linear在load_weight成功后固定返回E_INTERNAL/detail0x07000004，对应源码`if (!qkv_pair)`。此前QK/AV固定错误是上游QKV成功发布缺失的后果之一。另有ADD_RESIDUAL和ADD_TYPE的vector特化把真实传入`&hidden`/`&types`的src1变成NONE，且第二次bind消失。

可确认的原因表述为“nullable metadata pointer的存在性控制语义在gdce至lto/reflow之间丢失”；尚未留证具体内部pass或base=0瞬间，不能把猜测写成已证实机制。旧focused pilot未在cfg单列controller，但以文本include将其编入同一TU；其top只到fresh/invalidate_incomplete，linear/真实QKV图不可达，且手动设置QK前置状态，因此不覆盖这两个缺陷。

### 6.1 唯一生产修复边界

修改`hls/control/full_forward_controller.cpp`的内部表示，外部13口、task结构、数字/owner/错误合同不变。分三份可独立比较的补丁，组合后共同回归：

- **P1 QKV pair**：核心函数采用`linear_impl(..., FullOwnerSpec& output, bool pair_present, FullOwnerSpec (&pair_output)[2])`。原`if (!qkv_pair)`在同一位置替换为`if (!pair_present)`并保留原E_INTERNAL/detail；不得把guard移到load_weight之前。带pair的`linear`重载传true和真实2元素数组；不带pair的重载创建局部未用pair并传false。误以无pair重载调用LIN_QKV仍返回原错误；非QKV无pair行为不变。所有claim、quant、Linear、publish、copy顺序保持。
- **P2 Vector第二来源**：核心采用`vector_impl(..., bool src1_present, const FullOwnerSpec& src1, ...)`。`t.src1`、region选择及第二次bind只由明确bool决定。带第二来源的重载传真实reference和true；unary重载传独立默认spec和false。将residual/type_add改为reference调用，将GEGLU/APPLY_CAND_MASK移除nullptr参数。非法缺第二来源的二元op仍由原typed-task检查按原顺序拒绝，不新增提前claim/释放或删校验。
- **P3 Attention输入选择**：将`const FullOwnerSpec* att_source`及pointer phi改为`FullOwnerSpec att_source=hidden`；layer>0实际norm成功后赋值normalized。调用linear传该值的reference；原normalized/hidden owner释放对象与时点不变。只复制小型descriptor，不复制张量或大cache。

P1/P2修复同一已观测问题；P3去除同一路径的局部metadata pointer选择，尚未单独证明其有数值错误，必须在记录中保持这个区别。不得借此修改算术数组、并行结构或全局优化选项。

### 6.2 立即可执行的小top A/B

诊断工作区：`d1_optional_pointer_pilot/{source,rtl,tb}`。允许Sol在隔离目录编写和运行CPU、Vitis CSim、局部csynth与Verilog/XSim cosim；沿§3 D1守护执行，单个重型任务串行。原nullable A与显式presence B使用同一真实FullOwnerSpec/BufferRef等类型、相同动态payload/op和相同返回/写回观测，不通过精简整数类型改变触发条件。

最少测试：有pair的QKV成功并完整复制两个不同ref；无pair的QKV保留原E_INTERNAL/detail；普通Linear无pair不误拒；binary vector第二来源id/bank/epoch/region变动能出现在issued字段与第二绑定记录；unary仍NONE、无第二绑定；att_source layer0/非零选择准确。对A使用原源码表达式，B只改变presence表示，不改变期望输出。

小top可用stub承接load/bind/issue以观察控制语义，这是最小复现，不是真实数值/owner验收；stub必须公开为probe-only。若小A没有复现，保留其通过证据并逐步恢复真实controller上下文，不能改变测试去制造失败。即使A不复现，已有完整IR错误仍成立，但不能声称“小复现已闭合”。

只有D1原A错误在约定边界可复现、修复B的CPU/CSim与实际生成RTL合法/非法功能自检闭合，并经独立审核接受后，才允许将已核定P1/P2/P3等价补丁应用唯一controller生产源，再进入D2真实联合链。只恢复端口或看到数据路径不算此处通过；A未复现时继续恢复必要上下文。P3单独对照，不用于解释P1/P2根因。局部真实chain需要生产检查、真实数据和owner生命周期；小top的模拟load/bind/issue绝不能替代它。生产补丁不等于整网硬件修复已经验收。

### 6.3 新身份操作次序

D1诊断以独立源码/config hash绑定，不修改既有04934包或其证据。生产controller改动后，先保存旧源码hash与精确diff，再使用现有export/tag生成器在新的模型包目录产生新build tag（模型/数值/布局tag应保持，除非真实前像发生变化并说明）。旧`build/model-repair`和旧manifest只读；新回归入口显式指向新包。确认真实编译源清单包含新controller，记录实际配置、生成header、模型BO、请求与oracle身份。

真实请求中的build tag按既有ABI生成器绑定新包，其token/mask/marker/qtype内容、冻结模型权重和独立oracle数值不得改变。通过相应回归及独立审核后才讨论默认包指向/后续完整top；禁止把旧CPU/CSim结果直接改tag充当新run。

## 7. D2分层执行修订：可结束的真实Attention切片

本节显式细化§3 D2，不降低最终验收条件。完整S128 QKV投影的RTL仿真成本过高，不能把小probe替代它，也不能因局部通过就宣布完整controller/整网RTL通过。生产补丁仍以D1独立审核放行为前提。

### 7.1 为什么不先跑完整QKV投影RTL

单张QKV矩阵K1024/N3072。按已生成串行Q8 group 179–199cycle计算，以下仅为组体分量：

| 计算范围 | groups=rows×3072×1024/32 | 组体cycles |
| --- | ---: | ---: |
| 1行 | 98,304 | 17,596,416–19,562,496 |
| 16行任务 | 1,572,864 | 281,542,656–312,999,936 |
| B1/S128完整QKV | 12,582,912 | 2,252,341,248–2,503,999,488 |

这些是硬件cycle预算，不是XSim wall time。RTL模拟每秒能完成多少cycle要测，不能用150MHz把上述cycle变成软件仿真用时。本轮不启动完整QKV/整网长cosim。

### 7.2 三份互补证据及其证明边界

| 子项 | 实际入口/源 | 本轮要证明 | 不能证明 |
| --- | --- | --- | --- |
| D2-C：生产控制/owner回归 | 修复后的`Controller::linear/vector/graph`，真实`full_forward_ports`/13口top；现有完整CPU、`__SYNTHESIS__` storage shadow与标准libm CSim入口 | 新表示在完整B2/S128与两次B1图中执行实际生产数据、pair发布、第二来源绑定/数值和owner，检查点/任务数保持 | CPU、macro shadow与CSim不能替代生成RTL，不能据此宣布完整硬件图恢复 |
| D2-R：数值/owner RTL切片 | 下面定义的fixture输入边界＋生产`full_parse_request/full_write/full_claim_qkv_pair/full_cover_qkv/full_publish_qkv_pair`、LOAD_ROPE/RopeTask、LOAD_KV、QKTask、SoftmaxTask、AVTask及实际owner helper | 从真实QKV张量存储边界开始，真实数值、真实cache/owner、合法和非法任务、外部读写完成在生成RTL中工作 | 不证明该QKV由上游Q8投影RTL生成，不证明完整controller在RTL中能到达该边界，不是整网或整S64推理 |
| D2-I：生产生成路径复核 | 新源码的定向controller/受影响helper IR与局部RTL，D1正反对照 | pair存在性和binary src1的修复表示确实被生成并保留在当前生产实现；不能只修probe | 端口/IR保留不是数值验证，不填补完整top cosim缺口 |

D2局部通过时报告上述三栏各自结果，明确“上游Q8→完整controller→Attention的单一完整RTL运行仍未执行”。是否进入D3完整top重新生成，由Astra依据D1和这三份证据作新的技术放行，绝不把它写成整网RTL功能验收。

### 7.3 D2-R输入边界与真实数据生产

复用现有`tests/full_attention_dut_tb.cpp`、`full_attention_fixture.py`/独立reference的输入/布局思路，但新增可综合小top，不能照搬host vector/文件IO。诊断目录为`d2_attention_slice/{source,rtl,tb}`，只调用唯一生产函数，不复制QK/softmax/AV算法。

外部测试输入是冻结真实模型的中间QKV F32张量、mask和真实aux/RoPE参数，而非手填缓存或READY记录。fixture adapter须在RTL内：

1. 用合法请求和模型头调用生产解析/身份检查，建立B/S及mask；诊断请求有独立身份/生成记录。
2. `full_claim_qkv_pair`领取双shard，调用生产`qkv_address/full_write`把所有plane/head/batch/row的64个F32真正写到QKV BO。一个head/row的64值写完并检查成功后才调用`full_cover_qkv`；最后调用`full_publish_qkv_pair`。禁止直接赋owner.state/valid/coverage、final_qkv_ref、loaded_kv_ref/head、score_valid等内部成功状态。
3. fixture adapter仅是本切片的**输入生产器**，不是上游Q8 Linear替身或整网能力证明。每个fixture输入tensor的SHA、shape和所有有效元素都留证；预期值来自独立计算。省略某行/plane/head时不得登记该覆盖，生产publish必须拒绝。
4. Decision路径使用stage4/QKV_FINAL合法发布后进入LOAD_KV；Encoder路径使用stage2/QKV_RAW，实际LOAD_ROPE→pair lease→所有Q/K的RopeTask→commit FINAL，再进入LOAD_KV。原始V携带/两shard原子性按生产接口验证。
5. 实际LOAD_KV装所选head的全部B/S，随后QKTask→SCORE/PROB lease→SoftmaxTask→AVTask，数值由真实cache与HBM读取，输出落真实ATT_OUT。局部head/row完成只能留下部分ATT_OUT覆盖；不足16head/全S时必须拒绝完整publish，不伪造全矩阵READY。

若S64切片采用真实S128中间QKV前64行，明确标为“真实模型中间张量的S64算子切片”。其score、softmax归一化和AV须按本次S64、key集合与mask**全部独立重算**，不能裁剪S128的softmax或AV作为gold，也不能声称这是完整模型S64推理结果。B1取对应batch并按诊断ABI正确重基索引；原B2/S128完整回归仍保持原始输入数值。

### 7.4 执行顺序、覆盖与预算

先运行D2-C当前生产补丁的针对性CPU/综合宏路径及输入/owner反例，再准备D2-R的CPU/CSim保证adapter本身正确；原始失败RTL和新修正RTL分开放证据。小top真实综合完成后先看actual loop/latency和资源，再放行可结束的RTL用例。

首批D2-R：B1/S64、Decision stage4、head0、rows1、row0=0；再单独head15/末合法行。随后B1/S128/rows16与Encoder full/slide路径，最后B2与首末row tile；每个范围只有实际执行后才列PASS。S1024边界先用CPU与受影响task/leaf专项覆盖，不默认把全最大输入加入RTL长仿真。

数量预估：每query QK为64×S个乘法及63×S个树加，AV为64×S个顺序乘加；S64一query合计8192个乘法贡献，S128一query合计16384个，rows16再乘16。这些核心算术通常远小于完整QKV；实际cycle必须取本次HLS报告/RTL计数，不能引用旧恒错误3–5cycle。fixture输入搬运B1/S64为786,432B、B1/S128为1,572,864B；Encoder还需RoPE全覆盖读写与524,800B参数加载，不能在预算中遗漏。

静态cache容量最坏约为KV1MiB＋score/prob128KiB＋RoPE512.5KiB及runtime/临时buffer；是否因固定shape/可达性消除部分容量以本次报告为准，不承诺LUT/DSP/BRAM/URAM数。所有大权重Q8算术不在D2-R可达范围，禁止为了缩资源删其余实际Attention检查。

初始RTL用例上限50,000,000cycles、30分钟wall time，仍遵守16GiB任务RSS/192GiB主机底线与单重任务；若估计超过上限，先缩**切片覆盖范围**并明确缺口，不缩数值K维/改变S合同或改gold。工具因规模超过局部限制时保留实际触发与资源，再由Astra安排边界/预算；不得自动转全top或超长模拟。

首批负例至少覆盖missing QKV coverage导致publish拒绝、重复/错bank refs、wrong head/S、未LOAD_KV或过期kv epoch、score/prob状态错误、重复AV head/row覆盖。每个失败检查status/detail/TaskDone数量、真实输出sentinel与owner恢复；随后运行合法请求证明未污染后续状态。

CPU/CSim对固定操作合同逐位；QK/AV基本运算也按精确合同核，softmax等HLS非线性按既有独立误差线报告。头尾shape、bind与写回正确性不能靠该容差放宽。记录score、prob和AV各阶段首差、最大误差、元素数及RTL实际cycle。

### 7.5 独立审核补充：同输入算术与端到端误差分别判

D2-I必须使修正后的真实生产`linear/vector`方法在局部top实际可达；仅文本include却不可达，不能作为当前修复已进入生成RTL的证据。

若RTL softmax相对系统libm概率有允许的非线性误差，AV基本运算的严格顺序/逐位检查须使用**实际RTL输出的prob位模式**与同一V，独立按key升序F32乘后加重算oracle。另保留对完全独立QK→softmax→AV参考的最终误差，分开报告。不能用C softmax不同prob要求AV位相同，也不能以整体容差掩盖AV重排/FMA/地址错误；此解释不改变既定任何容差。
