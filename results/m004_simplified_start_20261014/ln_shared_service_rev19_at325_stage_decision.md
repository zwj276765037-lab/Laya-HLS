# 修订19 AT307–325分版审核与未完接口交接

2026-10-16；D-M004-REV19-AT325-01；A001→A002；M004/SM004/E004/R001。回复`m004-rev19-at325-engineering-stage-handoff-20261016`。修订19按局部实现及成本出口结束，**上层抽取目标未完成**；M004/SM004继续running/unassessed，剩余实现由[修订20合同](source_norm_owner_rev20_decision.md)连续承接，不等待用户逐步审批。

[主控机读核验](ln_shared_service_rev19_at325_review_20261016.json)5411项检查成立：19份manifest共2139项frozen、另外69项声明fixture、38笔guard及288条实际政策匹配；按实际TB读取另绑定30份运行输入至原AT225/AT304。当前五份生产RTL与AT322–325冻结身份一致，实际编译及继承work库逐项核对。原FAIL、语义守卫误停、timeout、child127均保留，不以exit0覆盖Fatal。审核脚本第一次路径选择错误和后续修正计量分别保留，没有运行EDA或新数值参考。

下层63da9112…的LN_ONLY命令/回放/norm视图/同步读/release/done迁移，以及父core8c799f91…的staged代理按所测范围接纳；唯一LNQ及8×656×32bit bank静态成立，不当综合资源报告。AT324/325两份保存norm交替16槽的Q16全窗即时检查、最终4352字复扫、512响应、partial/abort/discard/新epoch接纳。保存raw/gamma的1024norm内部值、tile127同步响应、非法tile128状态7/phase12局部接纳；AT325的PS/G/QD/ADD固定客户只签所测同步读写地址与采样时序，不签真实G/矩阵/ADD算术或全部地址冲突。

AT322晚raw RRESP真排空及无reset新epoch恢复、末B错误后另一个真实LN行不增加写B、discard后epoch3恢复64B，均按**行包装层端点**接纳。后继行由TB发命令，不签128行调度或完整16行错误归并。AT323在同版行包装层上观察真实row0在cycle15377退休、gamma256R/1024norm/64B；source64R仅属退休时点，全次末计数UNKNOWN；固定160us退出，没有完整TB终标。

需同步两点报告口径：AT322三快照的top分别为错误row-wrapper TB、下层Q16 TB、正常row-wrapper TB；AT323实例化的是`laya_qkv_scratch_row_v1`，由TB逐行发cmd，**没有展开/执行`laya_qkv_s128_request_v1`请求入口**。保留“含真实重core的父行包装层兼容”，不记为S128完整父请求top同版验证。AT323实际读取的`expected_aux_header.hex`未列其fixture_entries，主控已直接核与AT225一致；在追加证据说明中补这项绑定，不回写原manifest或重跑。

费用核到原guard：static1706.08185053430498095/1800s，RTL1473.825600214302521/3600s；本段剩余93.91814946569501905s/2126.174399785697479s封存、不转移。host完整累计UNKNOWN。未用RTL不能弥补static缺口；剩余static低于已测父层展开，且上层仍由外部stage脉冲驱动，因此未启动独立16行/LN128属于未完成实现和成本边界，不能称数值FAIL或完整抽取PASS。

后继只完成原已研究切口：上层内部拥有source/norm、固定128循环与16行store错归并，旧父层为固定代理；补齐独立连接所需原准入/身份/Check映射，真实父请求top与独立stage使用同版模块。真实LN128/NORM_STAGE_READY、完整父图同runtime、Q16父图/STEP16、全RoPE/FINAL→Attention、全请求首错等价、整模/Host-HBM及联合物理仍开放。
