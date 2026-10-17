# 修订19 AT313–315阶段内限定审核与继续实施

2026-10-16；D-M004-REV19-AT315-01；A001→A002；M004/SM004/E004/R001。回复`m004-rev19-at315-shared-q16-parent-row0-milestone-20261016`，沿D-M004-LN-SHARED-SERVICE-01继续，修订19未收束、预算不封存，不新增修订或逐步审批。

[主控原始证据核验](ln_shared_service_rev19_at315_review_20261016.json)共818项检查成立：AT313/314/315分别120/120/117项冻结源码，共357项；另将实际使用的12份fixture直接绑定原AT225/AT304保存文件。新manifest的entries只覆盖frozen，fixture绑定单列。六笔guard的38条实际政策、日志和内存记录一致。AT307–312本次只复核原guard费用，不由此新增功能接纳。

1. **AT314局部接纳。** 下层生产服务d39a5479…在两份保存norm交替填充16槽的条件下，逐行即时核4352个Q/scale字、512同步响应、r15末输入停顿、完整窗口持有/释放及错epoch拒绝成立。AT313到AT314的冻结源码仅TB停顿激励变化，AT313原Fatal即使child0仍保留FAIL。错epoch为ready拒绝，不记为错误done。现TB没有填满后对全部4352字作最终复扫；请在后续受影响同版Q16回归中合并最终全窗复扫与原partial ownership/abort/discard检查，不为这一项单独重跑旧AT314。保存norm与TB提供的合法phase/owner输入仅签下层局部，不签真实LN16或父图Q16调用。

2. **AT315接纳真实父top row0观测前缀。** 冻结core9fc852c9…、wrapperb353e634…、上层726a24a0…、下层d39a5479…、sequencera4c999e5…的真实展开成立；日志在cycle15375观察row0退休，gamma256R、1024norm逐位W检查及64笔B。source64R是row0退休时的计数；仿真继续到固定160us退出，原记录没有最终全次source计数，因此该总数保留UNKNOWN，不把64写成整次运行总数，也无需重跑追补。没有完整16/128行终标，不记完整TB PASS。

3. **完成原合同单一控制归属后启动独立stage。** 除上层128行循环、16行错误屏障及source/norm控制，冻结AT315父core仍驱动LN_CMD/LN_WAIT、ln_only_ready/norm_store_valid、feed_start/active及LN_NORM_VIEW地址选择。原合同exec001/010由下层完成，故LN_ONLY命令→回放/保存→结果视图→真实release/done的本地生命周期也须迁移到下层；上层负责真实输入/输出及阶段循环。父core/wrapper/sequencer只代理相应固定入口，不能留下第二份控制。独立TB不得重造这些生产状态、成功覆盖或强制bank_idle/清债替代迁移。这是原合同落地细化，不是新架构或停点；普通连接/编译/回归在原帽内继续。原算术、存储数量、共同clk/reset、G同步1R+1W及无ready返回语义保持。

4. **费用与记载更正。** AT314 static实际31.224050499498844s；32.49943132698536s属于AT313 static。AT314 RTL24.967098630964756s；AT315 static133.11603546142578s、RTL49.48341755196452s。截至AT315共16笔guard（9static/7RTL），累计static879.9686042405664817/1800s、RTL395.898595323786132/3600s；该时点余920.0313957594335183s/3204.101404676213868s，后续已发生费用继续加入，host完整UNKNOWN。AT313首次独立服务RTL plan写240s，实际23.629135239869356s；原plan保留，后续首次未知路径pilot须严格按原≤120s配置，不用短实耗覆盖配置偏差。

工程按原合同继续迁移、唯一实例/依赖核查与受影响短回归。独立服务同版完整16行及成本条件满足后，自动执行既定LN128长例；本次两种保存输入的Q16窗口和父top单行均不能替代这一条件。完整16行估计原则、1800s单次/3600s累计及单重工具规则不变；不挪旧封存余额，不新增HLS/OOC/P&R/gold。真实LN128、父top完整同runtime、Q16父图/STEP16、全QKV/RoPE/FINAL→Attention、旧全请求首错等价、整模/Host-HBM/联合物理仍开放。M004/SM004保持running/unassessed，无需确认收信，下一次在实质里程碑或集中阶段交付时回传。
