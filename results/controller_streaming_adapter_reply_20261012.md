# 流式adapter生成与depth2阶段审核

回复：`controller-streaming-adapter-generation-milestone-20261012`，并合入 `controller-streaming-adapter-catalog-update-20261012`  
审核：`R-SM003-CONTROLLER-STREAMING-ADAPTER-20261012`  
范围：M003/SM003/E003/R003，沿D-M003-CONTROLLER-INTERNAL-SPLIT-01。

**接纳当前host、真实HLS生成/顶层端口和compute depth2 pilot的各自限定证据。adapter分区已实际生成；原HLS_03分类FAIL和RTL_01八case full COST_STOP均保留原终态。** 新增F10：completion尾拍入FIFO与被sequencer消费之间，下一事务准入缺少门控；单inflight的该边界尚未闭合。按现合同补实现和有界回归，不新增审批或预算。

## 身份与生成结论

主控核387/387 frozen及声明pair一致，审核时384/387 current、6736/6739 manifest/receipt引用匹配。三项live差异准确对应：HLS runner分类修复一次，随后分区JSON登记在host_12与HLS_03各引用一次；当前JSON SHA为`0c70942ced4987bc8deb3bc8757ad46cac8e0f99655fd5ce7776b795ff27da1d`。冻结DUT、fixture、RTL与运行产物无差异，RTL_01的304组/677项全部匹配。八个交付SHA一致。[核查记录](controller_streaming_adapter_review_20261012/verification.json)保存独立核查、原始日志和主控记录更新前副本；登记前聚合核查不改写。

host_12七条编译/执行命令exit0，四测试入口marker一致。56个映射probe是4×(1 compute＋6 action×2 descriptor count＋1 producer)，全部16拍逐字比较既有encoder，共896字/57344B；签字段映射覆盖，patterned请求不因此获得合法语义准入。既有错误/取消与codec/oracle回归按原host范围接纳。

HLS工具exit0、guard child0/trigger null，370.877336s、5987504KiB；248份Verilog和16份DAT确实存在。主控独立解析module header及端口声明，24/24 FIFO信号方向/宽度匹配，其中18根外部协议信号，ap_clk/ap_rst/cancel齐全，顶层无ap_ctrl_hs。原误判来自内部有限helper的`.ap_start/.ap_done/.ap_idle/.ap_ready`连接。可以引用现有生成产物及独立PASS_SCOPED_PORT_AUDIT，无需为分类修复重跑HLS；原receipt仍FAIL。

逐拍映射与有限PREPARE/NORMALIZE_RESPONSE调度确实移除了external_request整帧副本和三套encode调用，保留完整语义解析与响应归一化。Compile/Link31014、Unroll step1 67274、step4 58159与18.34s Loop/function优化反映当前编译成本；HW Transforms50701和峰值RSS并未全部下降。三表6144B控制数据、剩余帧扫描及csynth BRAM18K49/DSP29/FF53762/LUT190633/URAM0分别记录。后续联合预算须包含此分区，当前没有净资源节约、1字/cycle、实际Fmax或请求性能结论。

## depth2运行与成本

RTL_01确实使用相同SHA的实际HLS top和八个真实depth2 FIFO，16份DAT从冻结副本落位一致。static109.622604s、pilot16.579330s/51308cycles，三段HLS/static/pilot guard/policy均符合原帽。pilot只执行compute诊断帧及后继compute LOCAL_REJECT；核16拍外部帧、受控8拍response的中途gap/cancel、16拍normalized完成、输出背压与最终FIFO清空。没有运行真实MATRIX算术、LayerNorm、物理hub或prov/producer runtime路径。

full启动前当前速率3094.696799cycles/s参与判定：51308×8×3＝1231392参考cycles，乘1.5为1847088，超过本入口1Mcycle帽；墙钟参考597s不能覆盖周期拒启。manifest/receipt均COST_STOP/started:false，guard_full不存在。可按原预算推进预先冻结的有限协议子集，分别报告覆盖；需同runtime验证的取消/恢复关系保持在同一子集中，八case组合仍为未运行。

## F10 / P1：完成尾拍入队不等于sequencer消费

这是本轮静态发现，**未动态复现**，不撤销上面的冻结pilot通过。

合同§7.2（`production_hls_partition_contract_20261012.md:98`）要求“直至完成被sequencer消费或按原协议安全收束之前，不接收下一笔事务”。冻结`controller_transaction_adapter.cpp:498–503`在第16次`transaction_completion.write_nb()`成功后立即返回READ_INTERNAL。真实depth2 FIFO的write成功只表示入队；adapter top只有completion_full_n，没有最终consumer读握手。当前TB把request FIFO直接接adapter，未在shell补消费门控。

具体反例时序：sequencer消费当前completion前14拍后停读，adapter仍可将末两拍写入depth2 FIFO并切回READ_INTERNAL；已在request FIFO排队的下一descriptor两拍随后可被读入，尽管旧completion未被消费完。若继续供给后继帧，还可推进其解析/外发。TB `run_case`在完成FIFO刚满时检查12周期不读后继请求（111–118行），随后连续消费全部16拍（119–123行），没有在尾部保留1/2拍时重新检查；现marker不能签整个完成消费边界。

请补真实消费端门控。可在唯一RTL shell观察request/normalized-completion两侧实际FIFO握手，保持24拍请求与16拍完成的事务边界：旧完成最后一拍被sequencer读走之前，不允许下一帧首拍越过request FIFO出端；当前活动请求余拍/合法cleanup和response排空仍正常前进。该修复可复用现有生成adapter，保持原FIFO/schema/Host ABI与唯一sequencer退休权威，不要求因shell门控重跑HLS。若采用其他实现，也须以真实consumer握手为依据，不能只以FIFO有空位或最后一次write作为消费证明。

补有界真实depth2负例：分别在第14、第15个completion读取后保持停读，保证adapter已将其余尾拍入队，后继descriptor在输入FIFO等待；断言`tx_reads`不超过当前24拍、下一外部请求零拍、旧输出稳定。最后一拍实际消费后才允许后继继续，核原取消/本地拒绝、所有FIFO清空及一次事务完成。保留当前正常pilot和完整逐字比较，不以禁止TB提前排队来替代消费门控。本项纳入C009，安全收束与typed退休的旧限定关闭不扩大。

## 连续工作与状态

工程按原授权补F10，继续有界prov/producer错误路径与真实sequencer/adapter/LN连接，将TB模拟的producer及completion→END换为生产职责域，再补完整tensor/多窗口、部分提交、故障取消与错旧返回安全恢复。没有新增正式放行门。分区登记`generated_top_verified_rtl_compute_subset`可保留，但需同步注明F10及整体集成未验收。

C009保持awaiting_implementation，C008/C010整体awaiting_verification；F9、F6/F7/F8及C012旧限定关闭保持。三摘要publication `Pd19cc91636874868b650aa26dbcb0d8c`和A002状态已核。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST、M003/M004未完成；5172s组合不重启，G余2338.224019s不变。主控本轮仅只读审核，没有编译/仿真/综合，无新增OOC/P&R/上板、agent或预算。
