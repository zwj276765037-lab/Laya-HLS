# KB2停止核定，按原合同进入CT0

R-SM005-KB2-STOP-20261013；回复measurement-first-KB2-no-go-CT0-start-20261013。M004/SM005/E005/R001，A002唯一整合/工具。此为主控在既有授权内的阶段判断，不是新增用户批准。

接纳KB2本轮有据no-go：停止当前two-64候选，保留已验KB1，不扫块大小、不加帽、不原样重跑。这里no-go表示该候选在本轮成本/进展边界内未取得完整样本；分块方法收益、功能正确性和停止根因均不能由此判定。

## 已独立核到的事实

主控核两份manifest各26冻结源、12fixture及收据/原log/IP，共94个唯一引用文件；相对KB1只变resident、front和TB，KB1 writer保持。measurement_02与_03之间26源仅TB增加有界停滞观测；不把_03称为另一实质DUT修复候选。8段guard含_01原static失败均串行，126条实际policy符合原CPU0–3/nice19/idle约束，实际MemAvailable及120s语义保护保持。主控未执行DUT工具。[核验](measurement_first_KB2_stop_review_20261013/verification.json)。

| 运行 | 实际结果 |
| --- | --- |
| 初始measurement | NOT_RUN保留 |
| measurement_01 | static FAIL/child1，21.565087s；原live接口漂移失败不回写 |
| measurement_02 | static/pilot PASS；pilot288 stripes、5 A reads、1024总PS比较，尚无最终输出；full COST_STOP355.083389s/peak1424912KiB |
| measurement_03 | static/pilot同有限PASS；full COST_STOP360.493669s/peak1429720KiB |
| delta_01 | 命令引用_03已编译snapshot，maxdeltaid10000；COST_STOP345.225717s/peak896020KiB |

三个停止均为semantic_stall、child-9，末条真实marker一致：`cycle=33397 stripes=5151 ps0=5120 outputs=0`，随后超过120s未见新进展。300cycle诊断未触发，有限delta运行也未提供能定位根因的新报错。

**口径修正：33397是末条观测周期，不是已证最终停拍；5120直接可见的是ps0，不把其余三行终值也写成已直接观测。** 不据此宣称确定RTL握手死锁、delta循环或仿真器缺陷。没有full完成、末B、done消费或新性能结论，不能用pilot补签。旧KB1的23.30%命令消费延迟/10.06%全冷减少仍有效。

新receipt中的“same frozen DUT old full/pilot ratio”继续只是继承成本参考；KB2的调度与TB确实改变。原receipt保留，工程在结果说明及后续runner明确其为旧入口比例参考，不用该标签声称同DUT，不为修正说明重跑实验。

## CT0按既定范围继续

KB2终态已满足[D-M004-KB1-NEXT-01](../mission/measurement_next_stage_20261013.md)的CT0入队条件，工程可直接连续实施/验证，无需新审批。已核CT0 design的5009bit×32字段偏移与原声明一致；原非零默认layer=255、state=INVALID(6)以及完整bitmap/identity都必须保持。该文档是schema准备，不签host/HLS/RTL通过。

只做原32项表REQUIRE/ACQUIRE/RELEASE_READ：真实RAM/完整校验、私有候选和唯一提交，响应反压不重复写；RELEASE_READ保持原较窄释放条件，不新增request_valid或全identity门。软件用真实原helper作reference，有限RTL核初始化、完整读回、边界/拒绝无写及同址顺序。原容量、全部默认值和TYPE_ROWS依赖不删。不开生产CLAIM/source/window/发布/退休、完整actor或恢复链。

继续按原一个薄HLS候选、明确原因可修一次的边界；若两次同点成本停止则退出该表达并集中评判同schema RTL，不能重新变成无限控制器前置。CT0有限出口之后再集中选择算术或实际集成下一步，本消息不追加KB3/其它控制范围。

工程需随本次终态同步E005三摘要/AT003终态及A002真实状态：主控读取时仍有“未启动KB2/等待KB1审核”和“KB2 full active”的旧投影。只更新工程负责的记录，不改历史失败或原始receipt；这项记录纠正不阻塞CT0独立工作。主控当前记录已切到KB2停止/CT0执行阶段，实际工具启动由工程真实报告。

原单工具/所有分类帽、G2338.224019s仅OOC余额、5172s不重启、无新agent/OOC/P&R/上板/预算保持。M003/M004未完成，完整控制链/冷INIT/恢复扩展继续停排。
