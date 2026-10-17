# QK/AV生成RTL修复合同与性能偏离处置

日期：2026-10-08；设计主持：GPT-6 Astra xhigh。工程：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline`。本合同承接用户对“性能未达到要求、计算未符合功能”的反馈，先查实并修复成功数值路径；不以新增解释文档替代工程修复。本轮实现由GPT-6 Sol max执行，独立Astra xhigh审核。

## 1. 已确认问题与责任边界

现行build `04934c15b3f83e842ec2e92ac2a81bf2`的QK/AV生成任务分别为`full_run_task_33/35`。两者context检查成功后仍固定返回E_SHAPE、elements=0，无Q/K/V/score/prob数值端口；完整生成RTL推理未成立。CPU完整图与标准libm CSim通过、HLS生成和OOC综合成功，分别只证明其各自阶段。此前把这些结果连起来解释为完整硬件功能已经接通，证据不足。

性能偏离属于另一条问题链：`hardware_agent/task.md §12.1、§12.5`明确F0是单任务阻塞基线，Q8叶为标量循环；实际综合配置关闭自动pipeline，源码没有并行dot阵列或跨任务DATAFLOW。旧16×8×32/64路FP候选预算没有落实到实际电路。这不是U55C速度不足的实测结论，也不是仅靠提高频率能消除的差距；`pipeline_loops=0`不能用来解释QK/AV为什么固定报shape错误。

50ms是用户A6000对照目标，保留该目标，不能降低目标后声称满足。尚无同口径U55C可达证据，本轮不承诺用简单unroll达到它。预算/后续验收明确分别报B1/S128与B2/S128；历史72/94等业务有效token长度按现有物理S128执行，不得与有效长度、GPU动态shape或不同batch计时混用。成功图Q8工作量和现有leaf调度得到的分钟数是条件外推，不是当前提前错误RTL的实际成功时延。

### 1.1 A6000实测的比较边界

[2026-10-05 GPU实测报告](/home/user/EDA-202/zhuowenjun/Workspace/Laya/results/laya_gpu_inference_benchmark_20261005.md)记录RTX A6000 `cuda:1`、SDK 0.3.20、PyTorch 2.9.1+cu128、常驻Agent、`fast=False`与BF16 autocast（加载参数FP32），每场景预热后150样本。

| 场景 | 执行B/S与候选 | 完整SDK P50 / P95 |
| --- | --- | --- |
| 两题一批 | B2/S94，实际长度72/94，K_pad=3 | 25.047 / 25.224 ms |
| 单独退款 | B1/S72，2候选 | 23.676 / 23.862 ms |
| 单独部门选择 | B1/S94，3候选 | 24.200 / 24.645 ms |

完整SDK计时包括准备/分词、H2D、前向、D2H与后处理，不含模型加载；B2驻留输入forward P50为23.962ms，属于另一计时区间。该GPU模型SHA为`891102d372688fc2a094dac56a384bc537b87c63f21f9f3dac0be2b7cbc8d86c`，当前FPGA冻结Typed-Decisions Q8_0模型SHA为`6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`，执行S128/16候选并遵守F32 R0恢复；不能称为同模型、同精度、同shape的速度比较。

50ms保留为用户的对照目标，24–25ms作为已有GPU场景的实测背景。后续加速结论必须对齐模型、原始请求、数值/质量合同、B/S/padding/候选以及计时边界；板上kernel start/done与常驻Host端完整请求各报一组，冷启动另列。旧GPU报告§7按当时方案计算的HLS算量不替代本合同当前冻结图的计数。本轮只引用已有记录，不新增GPU测试。

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

### 4.4 首个TM4/TN8联合原型：范围与缓存实物化

本节为**后续待实施规格**，不授权立即修改生产内核。复用`vivado/module_design/q8_linear_and_restore/{source,rtl,tb}`工作区，正式实现前将本节映射到该模块两份source文档并由Astra放行。原型必须连起真实模型BO装载、量化、完整K/N计算、PS与输出退役；只综合一个已塞满寄存器的dot不能满足出口。首个配置为TM4/TN8、GS32、单当前W缓存、单任务A8、单PS bank；先测全链串行基线，双缓存重叠是下一项独立变体。

外部测试边界保持冻结模型BO的字节布局和WeightKey；允许隔离top用明确`ap_uint<512>`读q0/q1/scale和激活/写回端口来表征真实宽总线，但这是新原型接口，不能写成生产13口已拓宽。实际RTL须逐口核512bit、burst、WSTRB与事务完成。生产集成仍需另行更新接口/存储配置与build身份。原型的计算Task保留rows≤16、完整K/N；内部按m0=0/4/8/12分4行微块，每微块完成全部group和N后排出，最后一个微块才允许整Task退休。

| 存储 | 首配置bank、word、地址 | 最大逻辑容量与端口要求 |
| --- | --- | --- |
| W q | 8 bank，每word256bit=一列一group；bank=n%8，addr=(n/8)×G+g | 每bank深度20,992（最大Wi），合计5,373,952 B；compute每bank每issue读1word，loader完整word写。首版load/compute分阶段 |
| W scale | 8 bank，每word16bit；与q同bank/address | 总335,872 B；每issue8个half，可在转换后广播到TM行 |
| A q | 4 bank，每word256bit；bank=r%4，addr=(r/4)×G+g | 保留完整16行，最大每bank512words，总65,536 B；当前4行每group各读1word，在全部N tile期间锁存广播 |
| A scale | 4 bank，每word16bit；同A q地址 | 总4,096 B；4个half/group。未写行与g≥G不读 |
| FP输入 | 8 bank，每word32bit；bank=k%8，addr=r×512+k/8 | 最大262,144 B；8lane装入/扫描/重放。每group32值跨4拍，K2624最后group完整 |
| PS | 32 bank，bank=r_local×8+n%8，每word32bit；addr=n/8 | 每bank656words，总83,968 B；每issue各1读+1写，真实simple/true dual-port与延迟从报告核查 |
| Bias | 8 bank，每word32bit，bank=n%8、addr=n/8 | 最大20,992 B；排出时读8列，N2只读2列 |

W深度按实际最大`ceil(N/8)×G=20,992`分配，不能用maxN×maxG的83,968浪费4倍容量。以上是逻辑容量，不是BRAM/URAM报告。例如若256bit W bank用72bit×4096 URAM拼接，则每bank需4宽×6深，8 bank合计192 URAM；16bit scale若用18bit×2048 BRAM36则11×8=88 tiles。这里只给一种可复算的物理拼接预算；实际推断方式、宽度/深度碎片、RAM读延迟、寄存器与mux都必须用OOC核实。双W缓存会复制这部分容量，不能仅按“剩余空闲LUT”决定启用。

### 4.5 冻结布局装载与8lane量化

原规格[04§7.1](../../vivado/design_source/04_model_package_and_memory_map.md)规定：t=n/8，shard=t%2，local_t=t/2，q字节相对地址`((local_t×G+g)×8+lane)×32+j`，scale地址`((t×G+g)×8+lane)×2`。loader按两口各自连续字节发burst，再将返回的256bit lane word写至bank=lane、addr=t×G+g；不重复量化或更改字节序。scale独立按原次序装入对应bank，只有q、scale及合法bias全部返回并完成校验后，当前W才可READY。物理pad至8的N2尾必须读写正确的模型span，只计算2列；其余lane不产生输出。每个已接受读请求都以信用保证返回存储，不跨4KiB发非法burst，响应乱序若被接口允许就用真实tag复位重排。

一次512bit q返回可拆2个256bit bank写，q0/q1若同拍返回合计4个word；不同shard可能竞争相同bank，必须仲裁/FIFO并给出每bank写吞吐，不能靠两个AXI端口自动获得两个同bank写口。首配置限制每bank每拍至多1写，因此应错开发请求或接受返回停顿；这一成本计入load周期。只在空W缓存装载；一次矩阵装载跨全部B/row tile复用，记录实际load次数和读放大。

Quant保持生产数值式`d_full=F32(amax/127)`、`inv=F32(1/d_full)`（零组inv=0），q由未舍入d_full求得的inv计算，half保存RNE，roundf半整数远离零。首版8lane分别完成第一遍abs/max与第二遍乘法/舍入，整tile q/scale覆盖后才发布A8；标记完整rows的READY前不得只写TM4行。输入非有限、scale溢出和q越界仍按原合同拒绝。倒数/除法和half转换须逐位验证，包括次正规；只有证明同值才能替换成吞吐更高的实现。

理想两遍工作量为`2×rows×K/8`拍，外加每group的scale/倒数服务与流水尾；scalar链若II>4会使8lane扫描阻塞。需记录输入读取、统计、inv生成、重放、q/scale写入的分项周期及stall。不能把“8lane”元数据当作已实现8lane吞吐，也不能将LN/GELU的较窄供给假定为8值/拍。

### 4.6 Dot、R0恢复、PS与退役的控制合同

发射顺序为每4行微块：group升序，内部n0=0/8/…；每次32个精确INT32 dot对应1024个S8乘法贡献。整数树每级符号扩展足够，32×128×128仍在INT32内；使用DSP打包必须证明有符号交叉项隔离，不能先假定“一DSP两乘”。每个有效输出有一次I32→F32、两次独立F32乘法与一次F32加法；TM4/TN8每拍issue的恢复吞吐需求是32转换+64乘+32加/拍。half转换可在A/W lane间广播，但`sa×sw`不能因近似/合并改变R0逐位结果。

issue携带task/epoch、m0、g、n0、有效行列、PS地址和最后group标记，标签与结果经历相同停顿。每个PS输出以+0开始，group0仍执行规定加法，不能直接用term替换以改变signed zero。令F为实际PS读请求到该地址写提交、下次读取安全所需的cycle窗口，T=ceil(N/8)，I为全dot/restore路径实际issue II；无旁路时group起点间距必须至少`max(T×I,F)`。N2的T=1必须显式等待或经审核的同值转发，不能依赖假DEPENDENCE取消或树化跨group求和。

实现计数至少包含accepted_issue、inflight、retired_group、committed_write；仅握手成功前进。反压时固定标签和payload；每条不能停的FP流水须在发射前为最坏在途结果预留容量，FIFO容量由真实latency×发射率及各级可停条件推导。最后一组发出不代表完成，必须等每个有效PS地址最后写提交。随后按生产列布局做bias、QKV scatter/普通输出写，并等待实际写响应；全部微块写完才能TaskDone/drained。对完整QKV仍须所有rows/plane/head的真实覆盖后发布，性能原型单tile不能伪装整层READY。

并行检测到多个错误时保留生产任务的first-error含义，按原遍历顺序的索引选择，而不使用“哪个pipeline先报错”作为新优先级。必须跟踪尚未发射及尚未退休的更早原索引工作；不能仅在当前在途错误中取最小值后就提交first-error。只有所有更早工作已完成且无更早错误，才能确定原优先级下的首错。失败要排空已接受事务、使未完成输出不可发布，并验证下一个合法任务恢复。首版单PS使排出与下个微块计算串行；第二变体才加入独立PS bank及对应epoch，实测排出/compute重叠和端口冲突。

### 4.7 可结束的真实数据试验与扩展出口

使用新官方包及完整CPU oracle的真实输入节点，选Encoder QKV/Wo/Wi/down、Decision QKV/FC1/FC2、Scorer FC1、ACT FC2，覆盖所有合法K/N；权重从冻结GGUF独立逆重排，输入不取待测原型输出为gold。数值比较分q/half scale、dot、scale乘积、term、每group PS、bias及最后F32；trace是观测口，不参与计算。native GGML输出仅作另一参考，不替代R0独立oracle。保持模型/源/请求/原始tensor与派生fixture SHA记录。

首个RTL联合例取真实ACT K256/N2/rows1，覆盖低利用率、PS反馈、真实bias与尾列；随后真实QKV K1024/N3072/rows1和rows4、K2624 down末group、最大N5248 Wi、最大K4096 FC2。所有单例先CPU/CSim再看实际综合cycle，沿D1资源守护且单例RTL先限50,000,000cycles；测试条数/仿真墙钟按实际报告分批，不抽掉完整K或N冒称矩阵已验。rows3/5/15用于微块尾与原Task行数；完整rows16、多任务重放、错epoch/不完整装载、随机AXI/FIFO反压、最后一组长停顿和恢复均需单列。

首版交付真实全链II、latency分解和OOC资源/时序，再决定启用两份W、A8/输入、PS中的哪几份双缓存；每个变体需独立验证状态与量化/装载/计算/排出重叠。不能把一个变体的II与另一个的RAM/时序拼接。默认不直接扩至TM16/TN16；扩大TM增加A/PS端口与恢复通道，扩大TN增加W/scale bank和广播扇出，变更到TN16还需适配原8列shard布局与N2尾。每种扩展给出实测每增一行/列的LUT/DSP/RAM、路由/Fmax及有效MAC增益。

与50ms目标相连：TM4/TN8理想1024 MAC/拍，在不计其他成本时Q8 B1也需307.04ms；TM16/TN16理想8192 MAC/拍，Q8 B1为38.38ms、B2为76.76ms。后者每issue需256转换、512个F32乘法和256个F32加法的吞吐，以及512B A、512B W、64B scales、PS各1024B读写；实际A锁存复用可降低平均读流量但不能取消广播/端口。资源、反馈、量化、输出和外部带宽损失必须实测，不能把整数峰值扩大8倍直接当整网8倍。B1剩余11.62ms要覆盖attention及所有其余未重叠工作，B2该几何的Q8理想下界已超50ms，因此当前规格不支持“实现该阵列即达到目标”的承诺。

## 5. 证据保存和文档职责

历史审核对应的合同原文已分别保存为[ D1精确前像](contract_snapshots/d1_reviewed_contract.md)（SHA256 `b16e5e40b5ba817a83059882f93d0b68238abc6187bb2f3e85d9c0b29b14c28c`）与[D2精确前像](contract_snapshots/d2_reviewed_contract.md)（`a14cde859c6f0f4a5fad55f8b3f3fc1662005323b801de8d21fbac5f90dbb893`）；后续§1.1及§4.4–4.7为新增比较口径/待实施性能设计，§7.6细化D2-I实际入口，不回写旧审核JSON。

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

### 7.6 D2-I具体入口：真实Controller可达编译与IR证明

D2-R首例未包含controller；本项另建`d2_controller_reachable/{source,rtl,tb}`，两个隔离top均**直接include当前正式`hls/control/full_forward_controller.cpp`**，在同一translation unit内实例化真实匿名namespace `Controller{rt,memory}`并调用公开的`linear`/`vector`重载。编译清单从官方`config/full_sources.cmake`取得25份生产源，移除被include的controller项、加入wrapper（避免重复定义），其余24份照实链接。允许HLS删除不可达`graph/full_execute_request`，但不得复制/reimplement核心方法、宏替换load/bind/issue、使用D1 stub或把claim/READY/coverage改成常量成功。当前controller SHA须为`23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623`，包为正式fe067。

**I-L：QKV linear完整局部生成路径。** 诊断top先生产解析合法B1/S64请求/模型头，接真实F32源tensor及完整q0/q1/scale/aux模型BO。首个输入取capture `ir_1414`（Decision0 `layer_norm_57`，原shape `[1024,128,2,1]`）第0题前64行；记录原/派生SHA与stride，标为算子输入边界。通过真实`full_claim_owner`、`full_f32_address/full_write`写完NORM `[1,64,1024]`各行、`full_cover_owner`和`full_publish_owner`建立source `{NORM bank0 epoch1, region0, stage4, layer0, batch255, TOKEN,row0=0,rows64,width1024,F32}`。没有合法完整生产者就不得进入综合，不能手填ledger绕过source检查。

wrapper按运行时`pair_present`选择真实`controller.linear(LIN_QKV,{5,0},source,4,0,fresh(QKV,0),0,output,pair)`或无pair重载。由生产方法完成真实LOAD_W、4×QUANT、4×Linear、双shard完整coverage/publish和pair复制；K1024/N3072、S64和数值路径不缩减。成功须CPU/CSim逐位比对独立R0 golden的全部64×3072个F32、两shard READY/spec/ref、返回pair、task/op计数和sentinel。native `ir_1415`只能报告native差异，不能代替独立R0gold。无pair例仍执行真实权重加载后返回原E_INTERNAL/detail0x07000004，拒绝数值与pair发布；额外坏scale/模型头验证原错误优先级。动态张量扰动须产生独立预期的QKV变化，不能只看固定success字段。

首例stage4闭合后，同一方法的stage2路径以真实Encoder QKV输入与family1/layer0扩展，合法source producer保持其真实stage/row space，输出应QKV_RAW、双shard发布而不冒称FINAL。可用独立cfg/top模板参数特化stage2/4，生产文件字节不变；两个实际编译范围分别留hash。先完成stage4真实可达证据，不为等待stage2而启动完整graph HLS。

**I-V：binary vector实际第二来源。** 独立top同样解析B1/S64请求，从两张完整真实F32输入经生产claim/write/cover/publish建立合法owner，然后调用实际`controller.vector`有src1重载。ADD_RESIDUAL首例stage4/layer0：src0为TMP、src1为HIDDEN bank0，dst为HIDDEN bank1，三个对象均TOKEN/64×1024，src0/source1的stage、layer和content与task匹配。可取native Decision0投影`ir_1428`与其残差输入`ir_1413`的第0题前64行；gold对这两份实际输入逐元素做独立F32加法，不以native后续节点取代同输入oracle。运行时切换src1数据/合法hidden bank并重新生成对应目标bank，结果必须随src1改变，合法第二bind、第二source acquire/read/release必须在IR保留。

I-V还覆盖ADD_TYPE：src0为stage3/layer255 HIDDEN，src1为stage3/layer255 TYPE_ROWS、BATCH、batch0、rows3、width1024，dst为另一HIDDEN bank；三行类型向量必须实际写入和cover/publish，`type_valid`由生产publish设置，不能手写。分别用合法qtype选择与独立逐元素加法gold。使用真实`vector`无src1重载调用二元op，按原typed-task shape检查拒绝，不能新增提前判错；用合法APPLY_CAND_MASK unary检查“缺src1”仍有真实成功路径。每种内容producer遵守原row space/region/spec；unary可另一次小top specialization，不强迫把GEGLU非线性也编入此范围。

每种top使用静态runtime和生产storage，连续用例必须用合法递增request/generation；各producer在解析成功后通过真实`controller.fresh(id,bank,region)`取得ref，首请求自然epoch1，后续遵守保留的max_claimed_epoch递增；失败时调用真实`controller.invalidate_incomplete`，再由下一次`full_parse_request`生产回收/软复位，禁止直接清ready/ref等内部字段来掩盖生命周期。也可每个测试单独进程/独立硬件reset启动，明确其未覆盖连续恢复；不能把这种情况写成persistent通过。

**工具路径和必须留存的生成证据。** CPU/标准libm CSim先通过上述完整合法/非法用例，再在独立配置以`vitis-run --mode hls --csim --config <cfg> --work_dir <独立目录>`与`v++ --compile --mode hls --config <cfg> --work_dir <另一目录>`执行局部csynth；具体参数以已成功D2-R入口为准，保留真实argv。保持现行part、150MHz请求、禁自动pipeline/partition和严格浮点设置；不通过全局关优化规避D1根因。一次一个重型任务，沿D1的4CPU、16GiB树RSS、192GiB MemAvailable和30min上限。I-L只为生成路径证明，**本轮不跑完整64行QKV RTL仿真**；单例组体本身已约1.126–1.252×10^9cycles，不能纳入5e7cycle切片预算。

在各work目录`hls/.autopilot/db`保存并解码`a.g.ld.*`、`a.g.ld.5.gdce.bc`、`a.g.lto.bc`、`a.o.1.tmp.bc`、`a.o.3.bc`及该wrapper的前端bc，缺阶段按实际记录不虚构。使用同安装的兼容`llvm-dis`（可核实候选`Vitis/lnx64/tools/clang-3.9-csynth/bin/llvm-dis`、`Vitis/tps/llvm/7.0/lnx64/bin/llvm-dis`或`Vitis/lnx64/tools/vcxx/libexec/llvm-dis`，先记录实际选中工具版本/hash）；命令形如`llvm-dis <bc> -o <独立ll>`。不混用D1或旧04934的IR当本项新结果。

审计表逐项列顶层调用点→真实Controller方法或其内联块→实际helper/task→RTL模块/端口及相应源hash：I-L的load成功后pair-present支路、双claim、quant/linear调用、双publish和两份返回copy；I-V的src1 descriptor构造、第二bind及实际第二来源读依赖。presence经合法调用特化成true而删除冗余guard是允许的，不能删成恒错误；无pair负例须保留原失败位置。若函数被inline，追踪控制流和内存依赖，不以函数名消失就判失败。必须展示生成数值RAM/外部读写端口和成功输出/完成依赖；仅看到bool端口或文件被编译不够。

D2-I出口是“真实生产方法在合法producer输入下，经CPU/CSim成功且优化IR/RTL保留成功数值/owner路径”，配合D1真实控制RTL和D2-R真实Attention RTL共同审核；仍不声称I-L完整QKV RTL执行或完整graph硬件功能通过。出现新的恒拒绝，应保存首次变化IR并缩小原因，不继续重跑完整top。

### 7.7 D2-R v3诊断内存边界与证明范围

此节按[独立v3设计审核](reviewer_d2_r_depth_v3_design_review.json)细化同一B1/S64 Decision0/head0/query0首例。v2的8GiB/16GiB两次XSim都触发主机任务树RSS守护，0/1事务完成、输出TV为空，无数值通过或失败结论；保留两次运行和v1/v2历史，不把资源停止改记为算子错误。

v3只缩减诊断top的序列化AXI depth：AUX=128个U8；QKV0/QKV1各10240064个U8；ATT_OUT=4100个U8。fixture786432个U8、io32768个U8、observed256个U32不变。生产FullMemory仍声明完整包/BO容量，host仍分配完整12MiB QKV/8MiB ATT_OUT数组；生产算子、owner、数值输入与原断言不变。新增每QKV `[10240000,10240064)` 的64B A5哨兵，覆盖本例最高exclusive写地址后的实际回传尾部。AUX仅检查0…127模型头，ATT_OUT含输出0…255及4096…4099下一行哨兵。

新源码/TB/config依赖须冻结并保存精确diff；重跑CSim、csynth和cosim setup后，独立审核实际生成接口、包装器、输入/输出TV depth及watchdog绑定才允许RTL。16GiB树RSS/192GiB主机可用内存下限、4CPU、30min、5e7cycles与单重任务不变，序列化payload减少40.9%不构成一定能完成仿真的保证。

生成C postcheck与独立raw-TV核查只能证明实际返回前缀。QKV/ATT_OUT完整host数组中未由RTL回传的高尾仍可能只是host初始化，不得据此声明硬件未破坏或覆盖完整BO。核查全部实际QKV写数据及新增64B哨兵、ATT_OUT实际结果/邻head/下一row哨兵、observed；证据明确标出未观测区。通过本首例也不填补上游Q8、实际controller、Encoder RoPE、B2/其他head/shape/负例或整网RTL缺口。

后续独立审核[联合Q8原型设计](reviewer_joint_q8_prototype_design_review.json)只接受§1.1/§4.4–4.7为待实施设计，不放行性能实现。该次审核的完整合同原文见[精确快照](contract_snapshots/joint_q8_reviewed_contract.md)，SHA256 `935464f9b644180d6369c3528de411d838da1a83319db36ded56704c8da14e5d`；本次first-error补充明确跟踪更早尚未完成工作，不改变原遍历优先级要求。

### 7.8 XSim生成内存模型的有限规模独立诊断

v3受控XSim也达到本轮16GiB树RSS预算，0/1事务、五份实际输出TV为空；见[独立终态审核](reviewer_d2_r_depth_v3_final_review.json)。该16GiB是本轮内部实验预算，并非用户永久指定上限。没有实际阶段证据和量化成本前，不自动重复整份DUT仿真或只提高预算。

准许Sol在独立`d2_xsim_memory_diagnostic/{source,rtl,tb}`模块下实现并执行小规模诊断，复用v3实际编译的`file_read_agent.sv`、`mem_model.sv`及所需UVM定义，保存原件、哈希、精确instrumentation diff和实际编译清单；不得改v3冻结源、生产DUT、工具安装或已有TV。源诊断只增加阶段/计数/帧长度断言和内存观测，不改变`$fread`、`TV.push_back`、`TV_Queue.push_back(TV)`、动态`mem`/`IsWr`分配和逐字节复制语义。生成合法单事务小TV：depth=1024、4096、16384、65536，每个payload由冻结fixture前缀取得；8B大端数量头和8B固定trailer由独立Python解析再核验，所有数据读回逐字节与输入匹配。

一个小snapshot以plusarg选择depth和模式，每次fresh进程。三个模式分别为：Q仅执行实际`read_TVIN_file`；M执行实际`mem_model.init(depth)`并写入同pattern；F执行实际`mem_model_pages_with_diffofst.tvinload_pagechk_atinit`完整初始化与offset文件绑定。按1K→4K→16K→64K逐级执行，各depth先Q/M后F；任何guard触发、帧读数量/事务数/队列长度/读回不符立即停止后续扩大并保存结果。不得把诊断Q/M/F成功写为Attention数值RTL通过。

每阶段必须记录：进程基线；打开/解析64位数量头后；读入队列的1K及后续2的幂和终点元素数；二维`TV_Queue.push_back`前/后；`mem`和`IsWr`各分配后；copy完成；offset绑定完成；最终完整读回核验。记录实际fread返回总量、声明depth、最终文件位置/EOF/trailer、事务数、每层queue size、分配depth、copy次数。内存记录区分当前RSS与进程峰值，保留时间戳及守护采样；可用诊断专用短阶段停顿帮助外部采样，或在进程内读取自身RSS，但须披露观测开销。不能单凭时间-RSS斜率猜测处理了多少字节。

本次小诊断预算：每次编译/运行任务树≤2GiB、≤120s、2 logical CPU、nice19/idleIO、主机MemAvailable≥192GiB、全局仅一个重任务；采样≤0.2s。记录每条实际命令、退出码和guard，不自动升depth或预算；初始最大64KiB。阶段报告计算相邻depth的增量RSS/byte、二维复制放大、分配和读回成本，区分正比例、非线性增长及未释放高水位。小规模线性拟合只可形成后续实验假设，不能直接声明21,304,580B全例的严格有限上界。若需更大校准或新内存表示，由Astra根据实测另行设计并明确预测/守护/停止准则。

后续整例方案必须保留生产AXI地址布局、全部数值与owner检查、实际BO写入/cover/publish、完整约定返回前缀及哨兵；不得手填READY或只返回status。若实际证据支持可解释的有限主机内存上界和足够余量，可内部审核新预算；若发现模型复制、解析或表示膨胀，则先处理已定位的诊断模型问题，再审核绑定。D2-I和联合Q8既定目标不因仿真模型资源问题取消。

### 7.9 真实完整XSim环境的被动阶段观测

[小模型独立审核](reviewer_d2_xsim_small_memory_review.json)接受1–64KiB的12个Q/M/F运行，不能把其成本外推成完整DUT上界。[进度归因修正](reviewer_d2_r_progress_phase_correction.json)说明117000只是reset后首打印；真实AXI静态链含交易动态对象和pending队列，虽有完成pop，实际队列大小/allocator保留均未测。本轮改为观测真实完整环境的运行阶段，验证“TV/页初始化成本”“DUT执行中的AXI积压”“已完成交易后的分配高水位”等可区分假设，不预设根因。

在独立`d2_xsim_phase_probe/{source,rtl,tb}`工作区复制v3实际生成仿真环境和完整相同C TV/offset。生产C++、全部DUT RTL/数值IP、AXI数据宽度/地址/存储depth、驱动响应/时延、参考比较与生成C postcheck逐byte不变，不重做csynth；输入hash与v3绑定，输出/log独立，原v1/v2/v3不改。只在生成testbench/reference_model/file_agent和只读诊断helper加入观测，沿用已审核DPI读取xsimk当前RSS/HWM；固定标量计数器，不保存每笔数据/交易对象，不打开wave或transaction recording，不加入人为总线stall/时延。

必需观测：
- 时间零/每个七口初始化前后/输出dump文件建立后/全部memory-ready，均给出sim time、wall timestamp、自己的RSS/HWM。每口保留真实header/trailer、总fread字节、元素数、事务/page数、copy数、实际offset/whole_page_size；U8六口与observed的256个U32按原框架解释。总计划payload为21304580B，原C TV完整帧和offset不裁剪、不合并、不替换成host零页。
- reset释放、真实ap_start与ap_done边沿、finish_cnt，及独立64位clock counter。前1024个clock在2的幂位置采样，之后每10000clock采样；每行明确统计截止到哪个posedge，不能把稀疏打印时间当停机时间。
- 七个实际m_axi口分别统计AW/AR握手事务数、W/R握手beat数、WLAST/RLAST数、B响应数、W有效strobe总字节、R按ARSIZE及burst信息对应的传输字节；同时给出AW减B、AR减RLAST的在途估计。握手只在VALID===1且READY===1计数。AXI-Lite控制start写入可观察但不改变。 R字节归因允许每实际port/ID固定16槽的{ARSIZE,remaining_beats}元数据ring，不存payload或交易handle、不动态扩容，并披露固定内存预算；处理同posedge AR/R并发，核RLAST与剩余beat。overflow、无对应AR或RLAST不一致使诊断失效并停止窗口，禁止静默丢计数；不改变生产num_read_outstanding。
- 同一采样点只读各实际`axi_state`实例per-ID `awq/wq/bq_rsp/bq_for_rsp_lat/arq/rq/rq_from_model`长度、键数和聚合长度，及现有`bqnum_for_slaseq/rq_from_model_num`。不能pop/clone/delete/改driver行为；不要遍历/拷贝队列payload。允许给class增加只读summary方法并由观察端调用，要求实际实例路径与source hash闭合。
- 如已有明确可定位的DUT task-retirement/owner控制寄存器，可被动读并给出真实生成映射；无法可靠定位则明确未观测，不改DUT为新增状态口。核心reset/start/cycle/AXI/队列/RSS观测必须齐全。

这是一次诊断窗口，不以完成Attention计算为必要终点。编译/静态展开限16GiB树RSS、300s、4CPU；仅一次运行限8GiB树RSS、180s、reset释放后1000000cycles，保留原50M-cycle watchdog，额外诊断终点以专用`D2_PHASE_PROBE_WINDOW_END`记录全部计数/RSS后结束。统一nice19/idleIO、主机MemAvailable≥192GiB、单重任务、采样≤0.2s。若原事务提前完成，保留真实输出并按原postcheck/raw-TV审核；若窗口或guard先停止，只判诊断记录是否有效，exit0或窗口marker绝非数值PASS。不得自动续跑、加预算或进行下一尝试。

当前只放行隔离观测代码实现与受控静态展开。运行前Astra必须审核实际diff、原188源/212制品的保持关系、新增观察源/DPI/hash、真实实例绑定、全部CTV/offset以及实际xelab和拟执行argv；明确放行该唯一窗口后才启动。期望报告先定位所有初始化结束时的基线，再将RSS增长对齐sim cycles、实际各口完成/未完成交易和实际队列长度。若队列稳定而RSS随已完成交易增大，报告为待进一步鉴别的allocator/对象保留线索；若无clock前进、无start或有巨大queue，按直接观测分类，不将相关性当根因。此项不改变D2-I/联合Q8范围，不授权完整top HLS。

### 7.10 首个有界AXI分配对照

§7.9唯一窗口的[独立诊断事实](reviewer_d2_phase_probe_v5_observation_review.json)及[制品身份补充](reviewer_d2_phase_probe_v5_observation_addendum.json)已接受：增长发生于初始化完成后的真实clock/AXI执行，具体分配或事件寿命仍未定位。按[d2_axi_allocation_diagnostic/source/design.md](d2_axi_allocation_diagnostic/source/design.md)隔离复制实际七口AXI VIP/内存模型，保持相同100000cycles与64KiB×7页，比较无交易idle与1024个真实单byte写加32bit读回的traffic。只加固定标量构造/握手/queue/RSS观察，保留原响应时延，不含Attention DUT，不宣称数值RTL。Sol可立即实现并做16GiB/300s受控静态展开；Astra核实际source/snapshot后才放行两次各4GiB/90s运行，无重试/升级。原§7.3–7.9变体及结果冻结；不放行第四次原Attention或完整top HLS。

### 7.11 外部真实装载QKV的新验证边界

按[d2_attention_preloaded/source/design.md](d2_attention_preloaded/source/design.md)另建 `attention_preloaded_slice` 与独立诊断身份：BEGIN真实parse/fresh/双shard claim后返回FILL；Host在两次调用间实际写全QKV图像并独立逐byte核验，生成绑定request/generation/bank/epoch/ticket及源/图像SHA的完成receipt；RUN只为实际完成行调用生产coverage，生产publish后执行原LOAD_KV→QK→lease→Softmax→AV。完整行span可一次coverage，缺plane/row必须真实publish失败；禁止直接赋READY/coverage。此项只验证外部输入导入及下游链，不声称上游Q8或旧RTL fixture full_write执行。

Vitis多事务实际page/offset推进、同一static runtime跨调用FILL保留且无夹入reset，以及RUN前对真实mem_model backing pages的全prefix独立校验，均为新的RTL门禁；receipt不是未验证的preload_ok。生产fe067字节与身份保持，旧§7.3的逐byte RTL生产器及全部历史结果冻结。当前只放行实现与8GiB/120s严格CPU准备；CPU/源码冻结审核后分别门控标准libm CSim、局部综合和2事务静态绑定。新数值RTL运行预算须依据新调度与分配诊断另行审核，本设计不放行新的RTL运行、D3或性能实施。

### 7.12 单重工具约束的调度范围澄清

本合同的“单重任务”“一次一个重型任务”及§7.8的“全局仅一个重任务”，统一指**本Laya工作流及其全部代理树**在同一时刻最多运行一项重型构建或仿真；不要求共享服务器上的无关用户/项目任务先结束。启动前确认本任务没有另一项重工具，检查实际允许CPU、负载及主机余量；在既定四CPU（或具体实验已定的二CPU）、nice19、idleIO、任务树RSS、wall-time、0.2s采样和MemAvailable≥192GiB守护内，允许与外部任务共存。只管理本任务拥有的进程树，不向无关任务发送信号、修改优先级或CPU affinity。

2026-10-08 controller明确此为现有调度约束的范围澄清。只读主机证据显示96个允许逻辑CPU、约421GiB可用内存，存在无关Vivado不构成独立阻塞条件；本轮可在低占用允许核继续已放行的AXI分配诊断静态构建。CPU占用是瞬时采样，具体四核由启动时实际affinity/命令留证；不为固定核号重启已合规启动的工具。本补充不变更设计、数值、测试数量或任何预算，不增加等待门；§7.10的source/snapshot独立审核及两次runtime放行条件保留。见[精确身份及主机证据补充](reviewer_single_heavy_scope_addendum.json)。

### 7.13 空闲增长后的稳定采样及最小时钟等待鉴别

独立终审接受§7.10的idle零交易/构造计数28恒定下显著RSS增长；traffic首笔B的分离观察不一致触发fatal，完整对照未完成且不代表实际总线响应为X。按[AXI模块现行设计](d2_axi_allocation_diagnostic/source/design.md)在隔离v2代码中采用统一clocking input #1step样本，联合记录handshake与响应字段，保留原VIP与所有assert；实现与受控静态准备放行，两次v2运行须新门控。另按[最小clock-wait设计](d2_xsim_clock_wait_diagnostic/source/design.md)比较32个固定worker的module/static-class/virtual-class/delayed-virtual四模式，只做重复时钟等待；实现与一次16GiB/300s静态准备放行，四次各4GiB/30s/20000cycles运行未放行。预置QKV CPU/CSim优先，重工具串行；不得把观测16.1876KiB/cycle当严格上界或回到未支持的交易对象积压归因。

### 7.14 离线执行与联合Q8表征的依赖澄清

2026-10-08用户已授权执行[mission](../../mission/task.md)，随后明确当前无板卡、先完成离线验证。阶段1–4及平台可离线准备持续推进，最终板测保留待板卡。Astra/controller接受以下依赖澄清；不改数值合同、生产fe067、既有运行证据或最终加速核的完整RTL门槛。此前本合同精确原文保留于[依赖澄清前快照](contract_snapshots/mission_dependency_preclarification_contract.md)，SHA256 `e07ce192b56fc6252a51b9d72dc126a14aa3ac9350dcf08ff393644858666705`。

不能把未加速F0的漫长完整RTL设为隔离性能表征的无限期前置门。按当前成功图工作量及179–199cycles/group，B1/S128仅Q8分量为263,805,471,536–293,280,943,216cycles；B2翻倍。现有D2-I I-L真实64行、K1024/N3072，且新I-L实际leaf报告仍为179–199cycles/group，单合法请求仅Q8即1,126,170,624–1,251,999,744cycles。即使假设每秒仿真一百万cycle，前者仍约73.28–81.47小时，后者18.77–20.87分钟，其他成本另加；这是假设敏感性分析，不是XSim实测速率或保证上界。

后续I-L/完整top数值RTL启动前，先从实际合法schedule计算工作周期，再用同环境的有界观测估计可执行墙钟与内存范围，说明初始化、数据搬运和停顿，符合预算才运行。当前idle增长率不能直接外推为整个DUT的严格内存界；50M-cycle watchdog也不是试验可结束的证据。不能截断K/N/层数、注入READY或用stub后宣称原I-L/完整F0通过。

联合Q8工作按三个不同技术门推进：

- **A：隔离原型实施。** 使用已接受的fe067完整CPU/B2标准libm CSim、D1控制修复RTL、D2-I源码/CPU/CSim/生成可达路径，以及冻结R0独立oracle，足以建立可独立验收的Q8原型输入与数值基准。完成现有q8模块的设计/接口/验证映射并经Astra放行后，可以与D2/D3交错实施；不等待旧F0完整数值RTL或完整核资源先完成。所有已知D2缺口仍单列，不把它们升级为通过。
- **B：独立切片表征。** 依§4.4–§4.7使用真实BO、完整K/N、量化/点积/R0/PS/写响应退役和背压，逐例CPU/CSim、实际数值RTL及无黑盒OOC；每次工具有明确输入、预算和证据。此门只接受该原型的II、数值、存储与资源系数。§4.3要求的完整修复核及shell余量，约束生产集成/系统适配结论，不禁止此前收集独立原型数据；未知整核余量和shell开销不得填为零。
- **C：生产集成与最终验收。** 原型结果与必要的D2真实控制/数据连接、错误/恢复证据齐备后，另立集成身份，保持完整CPU/CSim回归、真实完整生成结构和同源资源；最终加速核必须完成完整请求RTL数值、AXI、owner与恢复，板测待实际板卡。旧F0未执行的完整RTL仍标未验收，不要求一定先把该旧慢制品跑完，才能验证功能等价的最终加速核；不得把旧制品资源和新制品功能拼成系统通过。

当前Attention综合失败的定位/修正与已放行诊断优先。Q8采用同一Sol实现负责人、现有模块工作区及单重工具约束；实现、CPU、CSim、RTL、OOC分别按实际包审核，不允许并行重工具、擅自扩大预算或把本文视为直接放行所有后续运行。

### 7.15 Q8首版接口与验收口径落实

§4.4–§4.7现已映射至既有[q8模块当前design](../../vivado/module_design/q8_linear_and_restore/source/design.md)与[当前results](../../vivado/module_design/q8_linear_and_restore/source/results.md)。新隔离身份`q8_joint_tm4tn8_v1`的A门放行实现、ACT真实fixture和严格CPU准备；逐项工具门及预算以两份模块文档和相应审核JSON为准。原生产fe067与旧制品证据保留。此前合同精确字节在[q8映射前快照](contract_snapshots/q8_mapping_preclarification_contract.md)，SHA256 `d1c0bc515956dc26f3d09f4721fdb55cd36c8482c3538515f55153c1cc3ff1af`。

首版明确采用q0/q1/scale/activation四个显式512bit读口，而out0/out1采用U32并允许实际32bit写口，保证N2与散写真实有效字节。它是本次隔离表征的具体接口选择；§4.4的“逐口核512bit”适用于宣称512bit的端口，所有端口仍须逐口核真实位宽、burst、WSTRB和最终响应。aux/descriptor/observed按实际生成宽度报告。输出耗时全部计入联合链，不能按512bit虚算；后续512bit写变体须独立接口/尾拍/性能验收。生产13口没有因此拓宽。

§4.7的数值分层比较明确分覆盖范围：全部A8及全部最终F32必须逐位对账；固定观察口记录选中(r,n)的全G中间值。ACT通过两次真实RUN分别选两列覆盖全部组，并验证W复用。大矩阵必须注明代表trace或增加实际计算退休observer/scoreboard，不能把少量trace称为全部输出每组已比较。首错使用生产遍历rank而不是bad_element编码，LOAD/Quant/Linear不同检查顺序均保留。单PS在失败前可能已写出前微块，未完成输出不可READY；实际已写临时区域与未写哨兵分别核对，不新增无预算的全tile回滚承诺。
