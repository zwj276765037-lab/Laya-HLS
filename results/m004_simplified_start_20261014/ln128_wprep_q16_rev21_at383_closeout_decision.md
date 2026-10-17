# 修订21成本出口：独立LN128→W→首A16接纳，父链仍开放

2026-10-16；D-M004-REV21-CLOSEOUT-01；A001。回复`m004-rev21-at383-parent-continue-cost-handoff-20261016`。本修订按成本出口结束；不是完整父请求或M004/SM004验收完成。未用static **605.50865154154599468s**、RTL **323.3846215400844935s**封存，不转后继，不在旧修订继续重工具。后继依[修订22独立合同](a16_matrix16_rev22_decision.md)连续推进，无需用户逐步批准。

## 增量审核

[905项增量检查](ln128_wprep_q16_rev21_at383_review_20261016.json)通过：AT379–383五份manifest共744项冻结/fixture、7笔guard/46条实际政策一致；原53笔账与原审核身份不改。累计60guard/398已观测政策，static **1194.49134845845400532/1800s**、RTL **3276.6153784599155065/3600s**。AT361未观测policy/RSS、host完整累计仍UNKNOWN。AT380/381编译FAIL、AT383 timeout和此前Fatal全部保留。

AT379沿AT368四份生产SHA，真实LN128后以合法stage_input_done_ready保持上层stage done三拍，同时提出continue；每拍核valid/status0、SL_FINAL、退休128、gamma有效、continue不接受、零STATE1/Q。消费done后到SL_HELD，一次continue清gamma，norm保持；278.195482281968s，child0/null。只接纳上层阶段done屏障，不扩展到下层pending/rsp、叶子done、legacy切路或父request发布。

AT382实际`--O3`构建完整父top成功，69.6241029445082s；同snapshot真实row0核1024norm/64B/source64R/gamma256R及未提前发布，50.32597625441849s。父sequencer9abc446e…、wrapper3a11446a…及匹配父TB与AT367字节相同，core完整文件920d804f…与AT372相同；不要把本次表述成新增生产接线实现。上/下层与W服务/cache仍同AT368。本次新增的是匹配当前完整依赖的重新展开/前缀证据。

AT383所有149项manifest条目与AT382相同，只去掉PREFIX_ROW0，以120s帽跑父LN前缀；120.35708910785615s、timeout/-9。日志确认row0在cycle15377、row1在29465退休，最后source192R/norm2048/B128含未退休row2预装。没有LN128或W/Q终点；为COST_STOP，不是数值FAIL。不能据两行比例或独立317s推完整父runtime。

## 父测试台的额外边界

冻结`laya_staged_ln128_pilot_tb.sv`是**LN-only前缀/阶段TB**：W的arready/rvalid固定0，STATE1 arready/rvalid固定0，出现W AR被原`STAGED_LN_FORBIDDEN_SERVICE`判错；正常终点打印STAGED_LN128_REAL_PASS随即finish。它不是可以仅延长墙钟便走到W/Q的完整父链测试台。请在工程阶段报告/三摘要补清这个限制，不改原冻结证据；该缺口与120s成本停止分别记录。未来父链必须接真实W/AUX/STATE1 peer并换成相位相关禁止访问检查，保留旧LN前缀断言含义、独立gold和禁止提前发布。

## 修订21接纳范围与后继

独立真实生产组合LN128→W冷载→STATE1首Q16/A16正常主例以AT368为准，前4行独立Q/scale与其余12行真实传递/布局/保持分列；AT371/372主W回执与core局部合法后继、AT373/374局部A/discard/Q输入reset、AT375–379独立错误/末拍/阶段done及恢复各按此前决定限定接纳。AT378只到W错后新LN首行，不签再次W/Q。父top动态continue/W/Q/A16、完整128同runtime与父tensor epoch释放仍OPEN。

下一阶段采用已审核的唯一matrix服务/STEP16接口，取得独立真实首TN8计算与写回，再集中验证受影响父接线。完整父链缺口不是当前矩阵工程的全部前置，也不能因分段通过删除。同步pending/rsp等没有合法外部可独立施加接口的排列按原范围OPEN，不force内部债、添测试专用生产口或为排列重复LN长前缀。

普通修复、真实参考、全项目单重工具及模型/资源约束不变。M004/SM004持续running/unassessed；整模、Host/HBM、联合物理/Fmax未完成。
