# FFR0 AT053 审核问题只读补证

回复 `measurement-first-FFR0-status-progress-query-20261014`；M004/SM005/E005/R001。仅核现有冻结源码、manifest、原日志和 A002 实际状态，没有运行新参考/RTL/EDA。

1. [生产状态枚举](../../../../../E002_Laya_HLS/experiment/include/laya_types.h)第8行是 `E_NUMERICAL=6`、`E_PROTOCOL=7`、`E_INTERNAL=8`，没有9。AT053冻结残差DUT第103–104行将本地 `STATUS_NUMERICAL=8`、`STATUS_AXI=9`；冻结TB第323/330行期待8。该冻结runner的实际编译闭包只含生成FADD叶子、结果槽、残差DUT和TB，未见状态转换层。故NaN/有限溢出的原两探针只证明**本地数值拒绝和零新增写**，不能证明生产错误码语义；AXI错误码9也与现枚举不一致且未动态测试。正常 status0/gold/事务证据独立保留。旧AT053收据与原始日志不改。
2. 冻结TB第192–194行在 `cycle%20000==0` 且任何历史source R非零时无条件输出 `FFR0_PROGRESS`；冻结guard第88–90和151–153行只按前缀匹配并刷新语义进展时间。静态反例是首个R后读/加/B计数全停时，周期仍递增、每20000拍继续打印并续120s watchdog。AT053原full五条记录在20k/40k/60k/80k/100k拍均真实推进：skip_R 50/99/149/199/248，down_R同值，add_done 790/1584/2376/3170/3964，B 49/98/148/198/247；该次自然PASS不改判死锁，但guard的语义停滞保护不能凭现规则认证。
3. AT051是**准备未完**：无manifest/guard/工具；其7个部分冻结文件与AT052对应7项逐SHA相同，唯runner从错误的 `TB/hls_guard_helpers.py` 改为实际 `E002/tools/hls_guard_helpers.py`，SHA `3e0fa528…`→`68f10eb9…`（6593→6601B），AT052另加入正确helper冻结。AT052→AT053 14项manifest中仅联合TB改动，SHA `6ad5d382…`→`a8303cb6…`；差异含first_done探针隔离、提前成功/发布断言、AXI保持检查和两个数值拒绝探针，不能窄称为只改标签。DUT、结果槽、叶子、fixture、runner、guard均同SHA。两轮有因修正范围已经占用，不自行增加AT054。

合同指定的cfg受理、两端首末AR/R、本地源锁/目标有效精确边沿、逐项加法延迟和互斥阶段未由AT053完整打印；原报告只明确标出其中源锁边沿与加法延迟缺口，本补证补齐其余观察缺口。A002的[当前state](../../../../../../agent/A002/state.json)已于 `2026-10-13T22:02:32Z` 通过 `console.py report` 更新为AT053完成/无本项目重工具，`runtime_id=AT053_FFR0_four_row_02/guard_full`。当前只等主控受影响修正合同；M003/M004开放。
