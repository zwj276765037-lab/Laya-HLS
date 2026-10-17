# KB1之后：提前形成最终输出，检验一个真实控制表

D-M004-KB1-NEXT-01；2026-10-13。沿[测量优先计划](hardware_measurement_replan_20261013.md)，M004/SM005/E005，A002唯一实现/整合/工具owner。KB0＋KB1同口径判断＋P3设计排序这一轮出口已完成；总任务未完成。下列是下一阶段授权范围，不是新预算或新用户批准。

## 首要工作：一个分块调度假设

保留KB1四row writer及原全部算术模块/数值语义。W加载与输出服务下界已说明：本profile单改读取器调度或堆待发缓存的理想空间很有限。当前cfg→first done16183cycles，first AW在cfg后11248cycles；先检验是否能提前形成完整结果，让串行写回覆盖在剩余计算内。

**候选KB2：四行Down/K2624/N1024、T=128，按两个连续64tile块调度。** 块内仍逐group递增，每个group遍历本块tile；第一块完成全部82group后推进第二块。每个输出的32项dot及82group浮点累加顺序、FP IP、舍入、数据/scale、PS物理容量与写回顺序保持。最终输出仍按tile/row升序交原adapter/bias/KB1 writer。原A/W真实lease、读取、返回、末B/局部发布/消费保持；重复A读取和块边界等待必须实测计入，不能TB预填替代。

先做一次有界依赖核查，再连续实现/验证，不追加逐项审批。工程后续接口映射与该选择一致：64tile时真实A读预计82→164，须由新运行核实。64tile来自现有F_PS_min37及128tile工作量，只是待证调度选择；不承诺间隔必然足够。必须明确以下身份关系后才能运行候选：

- 逻辑PS身份继续是完整(g,tile,row)及原owner/tag，原logical sequence=g*T+tile保留；实际发出序号是另一个计数，不再把二者错误相等。resident和front的预期游标共同按同一分块公式验证；不能删除顺序/重复/缺失校验来允许乱序。
- 每个tile严格接收g=0..81，原busy/initialized/真实PS返回依赖门保留；块内不足以满足依赖时真实停顿。所有128tile各82次、四row的覆盖和唯一性由独立oracle核对。gold按原逻辑(g,tile,row)索引，期望数值文件不改；不得按DUT错误发出顺序重新算gold。
- A每次group切换从真实fullA取得；W按实际g/tile从驻留dualW读取和校验，原容量/数据/READY/债务不变。调度改变不绕过读回、身份或物理在途计数。
- 仅此诊断构建启用分块路径，其它shape保持既有入口或在副作用前明确拒绝。局部正常样本不能代签新调度的通用首错/恢复语义；受影响非法tag/重复/依赖/反压检查保留，遇错样本终止并保留证据。

若核查发现该变换必须改浮点归约、PS容量、真实模型/接口语义或另造通用控制链，记录具体冲突并停止本候选，交本阶段no-go；不悄悄减shape/断言，也不为了凑KB2另选多个变化。普通调度游标、tag验证及TB按独立逻辑坐标索引的适配属于本合同已定义的实现。

比较复用AT002 KB1；如新增观测/检查影响可比性，先用原KB1与相同新观测确认边界。只增加回答假设所需的first/last final-PS、first AW/last B、分块边界、真实A/W读和原cycle/stall计数，不大改测试架构。仍同四distinct输入、全部335872 PS、4096F32及512最终packet gold，原TB供数、AW/W周期门、B逐笔延迟与7cycle done反压不变；实际写拍仍256。

出口是KB1→KB2的first-final/first-AW/last-B/actual-consume与全冷差值、实际重复A代价、完整gold、原资源账或UNKNOWN。更早first AW、较少某个stall、较快工具墙钟都不能单独判收益；末B/实际consume与全冷边界才作最终取舍。此轮只一个调度候选，允许最多两次有具体证据的受影响修复；无收益或同点成本停止就交反例，不展开尺寸搜索。静态→≤120s pilot→有依据full按原帽串行，无新增OOC/P&R。

## 次要工作：32项逻辑owner表的薄HLS实验

选定控制目标CT0：原`FullOwners.record[32]`及`full_require_owner`、`full_acquire_owner`、`full_release_read_owner`的真实表更新路径。依据`E002/experiment/include/laya_full_runtime.h`和`hls/common/laya_full_owner.cpp`。这是独立诊断替代表达，尚未接生产，不引入第二个可发布/退休的owner权威。

固定schema保持全部32项，每项完整NumericIdentity、ref、lease_old_ref、max_claimed_epoch、region/stage/layer/batch/row_space/row0/rows/width/content/state/readers/valid及两组64×32覆盖图。保留原语义默认值；按P3字段账每项5009bit，合160288bit，工程依据实际enum/默认值复核并在同一design.md列字段偏移，不把ABI padding或C++对象大小当RAM预算。另保留TYPE_ROWS校验所需3个type_valid，以及本次操作实际锁存的NumericIdentity、request_valid/model_header_valid和完整参数。

表达采用显式寄存器＋固定深度RAM＋有限微步骤，单一writer仲裁初始化/受控fixture装载/操作提交；串行一个inflight操作，响应反压时不重复提交。诊断装载只在首次初始化后、开始操作前，读回只在不干扰提交的边界，完整记录可观察，不靠keep声明假定RAM容量未被裁掉。操作开始后不通过装载、reset或清表制造测试通过。

- REQUIRE/ACQUIRE：保留原physical alias定位、完整spec/ref/epoch/identity、legal_spec/in_scope、READY/READ/valid、逐行coverage及TYPE_ROWS位校验。先完整读/检查，再形成私有候选；ACQUIRE仅在所有检查及readers未溢出后一次更新readers/state。REQUIRE无写入，拒绝无部分更新。
- RELEASE_READ：保留原函数的same_spec/READ/readers非零/valid检查及减一归READY规则。**原release没有新请求valid或全NumericIdentity门，不能借此次设计补上而阻断旧读者释放。** 它与ACQUIRE的校验不同须逐项标明；诊断调度context始终稳定。生产撤销/旧A下释放的接线在本实验之外，既有义务不删。
- 维护32项完整容量与语义值；明确按默认值串行INIT而非将所有字段武断写零。测试第0/31项与全表占用、物理alias、错epoch/spec/identity、覆盖图边界、readers255/0拒绝、连续同址ACQUIRE/RELEASE与不同址交错、查询在提交前后和响应反压。只有一个调度入口；仲裁检查针对初始化/装载/操作/读回互斥，不新增并行业务协议。

软件oracle用独立FullRuntime reference和上述原helper；硬件闭包只纳入表/必要校验，不带整Runtime对象图、allocator或source/window/publish/retire链。有限RTL核真实RAM读、完整校验到提交/拒绝、值保持及全部读回；HLS生成成功另核实际端口/容量和资源估计，控制cycles实测。未测字段的生产更新能力不代签通过，CT0不是完整owner生命周期。

排程：工程现有helper可并行准备CT0 schema/reference；**CT0重工具在上面算术候选取得结果或有证据no-go后才排队**，不反向阻塞性能工作。先一个薄HLS候选；如有明确原因可修一次。两次同点COST_STOP则停止该表达，交同schema手写RTL备选的集中取舍，不恢复FullRuntime/冷INIT盲跑。无需等待主控再逐项批准合同内普通实现/工具。

## 不变约束与记录

本阶段不新建agent；A002统筹现有helper及唯一共享写入。代码仍E002/experiment，原R001/AT001/AT002冻结不回写；后续AT按现有编号登记，局部控制标签CT0与算术KB分开。所有新结果起始NOT_RUN，主控文档不等于启动。

原单重工具、CPU0–3/nice19/idle I/O/MemAvailable>192GiB、static/HLS24GiB/1800s/120s真实停滞、RTL8GiB/3600s/40Mcycles及更严格入口帽、pilot≤120s全部保持。G2338.224019s仅OOC余额，无新预算/OOC/P&R/上板，5172s组合不重启。M003整体executor/冷INIT、CLOSE/rearm、cleanup扩展继续停排，完整模型与最终验收不变。
