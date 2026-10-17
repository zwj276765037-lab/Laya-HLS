# 首A16到MATRIX16：静态接口接纳与后继实施边界

2026-10-16；D-M004-A16-MATRIX16-INTERFACE-01；A001。回复研究交付`m004-a16-matrix16-next-interface-answer-20261016`。本决定采用后继设计；修订21按原合同继续，不切换当前实施、不新增/挪用预算，不因本研究增加停点。矩阵实施及EDA仍NOT_RUN。

## 依据与审核范围

采用[原架构“AT368首A16之后”](../../source/fixed_graph_architecture_20261014.md#at368首a16之后现生产接口上的matrix16增量2026-10-16)和[研究机读依据](../../source/fixed_graph_support_20261014/a16_matrix16_interface_20261016.json)。[主控静态核验](a16_matrix16_interface_review_20261016.json)826项通过：9份冻结源码与3份manifest身份、28个六字段/末PS参考窗口、224条scatter、512组A/scale映射和整数工作量；读取时9份current仍匹配。完整参考父SHA复用原绑定，本次只重核选定字节，没有新oracle/gold、浮点求值、EDA或RTL运行。[计量](a16_matrix16_interface_review_time_20261016.txt)单次受20s/1GiB、CPU0–3/nice19/idle限制；交互host完整成本UNKNOWN。

还定向检查了冻结接口：下层service_quiescent确实排除A16/partial占有；上层stage_direct_active仍选择norm结果响应与SL_REARM；父engine cmd_ready无条件排除A16，非legacy数值bad还套row×4096。新矩阵入口必须分别修改，不能只从父层多发exec011。

## 采用的单一路径

1. **唯一共同矩阵服务。** 从现engine迁移唯一front/矩阵FSM/保持寄存器到`laya_matrix_service_v1`，legacy Wi/QKV/Down与STEP16调用同一实现。现W服务/cache同级唯一，原上层唯一拥有LNQ/bank/readers/writer。父图必须实例化同一被测服务；只移动控制和实例，不增第二矩阵/cache/bank、FP副本或时钟/CE变化。
2. **独立A claim和SL_MATRIX。** 一次锁存window_row0、source/a epoch、model/numeric、task及W身份和RAW目的。A cover=ffff且所有Q/prep/response/done真实退休后才claim；held A本身允许存在，不能使用排除A16的service_quiescent作准入。writer末B、pending/rsp、叶子done等真实债未清不换路。先消费W_PREP回执，再真正lease/read/ret；READY电平不代签。保留STATE1 norm，不用tensor_release交接。
3. **同步A与单写口PS。** Q读bank addr=34r+g；scale读34r+32+floor(g/16)，取bank=floor(g/2)%8及奇偶half。每stripe四行共8次同步请求，响应稳定到消费。PS仅addr544+r；四路末group commit单选接受，未选者保持。复用原bank和响应保持；A保持净增108B是payload差值，控制位由实现另列，不能当综合资源结果。
4. **完整父任务的STEP16。** 描述符始终rows16/K1024/N3072，严格TN8→四block→32group，sequence=((tile×4+block)×32+group)。step和ps_retire都以实际债零及握手推进；不能把rows4/N8反复配置当父任务完成。全父49152stripe/196608行组退休/6144笔B，全部成功及W/A实际释放后才允许task_done。
5. **Check与store优先。** exec011采用矩阵op30及task-local bad，不套Q的row×4096；当前TN8四block归并后才能进入下一tile。A[row1,g31]错误671775优先于尚未执行的tile1错误1024，不能取全局已观察bad最小值。合法响应peer验证此反例；正常主例接真实bank/cache，非finite W不能绕过真实LOAD前检。B错后锁存首store错、真排债停写，继续原16行全N算术、后续PS受控discard；后续数值Check优先，只有全N算术成功才返回store7。协议缺数据另报错，不能补零继续。

## 后继最小可验收出口

正常主例在同runtime真实LN128→冷W→真实STATE1首Q16之后进入第一TN8；核实际A claim、W lease、1024次A同步请求、128次W read/ret、128stripe、512行组退休、128个final、16笔OKAY B及实际ps_retire。第一TN8结束时A/W仍持有，无矩阵父done/RAW/FINAL/request_done。前4行6144个六字段u32和32个final逐位对原独立参考；后12行只核真实输入及bank→A→算术提交→PS→scratch传递、覆盖/保持，不称独立数值gold。

局部验证集中于：A/W身份与有限响应阻塞；四block/poison/数值次序；PS末组/末B阻塞和store延后。父图做实际exec011固定委派与受影响legacy矩阵兼容，不能以独立组合代签完整父图同runtime。第一TN8不签纯store最终完成、完整全N、后7个A16或RoPE/FINAL/Attention。

## 当前工程衔接与成本

A002继续[修订21](ln128_wprep_q16_rev21_decision.md)及[AT372审核](ln128_wprep_q16_rev21_at372_milestone_decision.md)的受影响交接/恢复测试；本设计不占其预算、不触发正常串联重跑，也不把所有历史异常排列设为矩阵推进前置。研究交付已足以进入后继合同准备，无需研究追加实验或确认收信。

后继实施预算在修订21阶段交付/成本出口时由A001集中下达，不要求用户逐项批准；当前不将研究建议当已生效新修订。沿此固定切口准备首次真实lease→stripe→四block终结→末B/ps_retire的分段cycle/墙钟pilot，构建费用另列。新组合没有同版成本，AT368的317.274436s仅为旧生产前缀实耗，不可直接作为新组合延迟或由单行比例外推。普通修复连续进行的规则保持。

M004/SM004保持running/unassessed。研究接口为静态接纳，工程实施/动态验证/全父图/完整模型/Host-HBM/联合物理均不由本决定升级。

通信落实：`m004-a16-matrix16-interface-adoption-engineering-20261016`已于`2026-10-15T21:22:51.387840+00:00`送达原活跃工程会话，turn`01a14112-00a9-7e33-9a64-f3cbfbbff010`；不要求研究或工程确认收信。送达仅表示消息已接受，不表示矩阵已实施。
