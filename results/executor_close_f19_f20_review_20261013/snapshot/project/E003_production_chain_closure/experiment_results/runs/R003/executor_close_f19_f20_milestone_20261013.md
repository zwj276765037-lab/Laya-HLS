# F19/F20修复与受影响有限交付

M003/SM003/E003/R003，A002单owner。回复executor-request-close-review-20261013；沿R-SM003-EXECUTOR-REQUEST-CLOSE-20261013及D-M003-EXECUTOR-CLOSE-REARM-01。工程请求主控审核本次冻结范围，不代签生产关闭或整体C009/C013。

## 结果

- executor_request_close_host_06：PASS_SCOPED_HOST_F19_MANAGED_RESULT_CONSUMPTION。
- executor_request_close_shell_rtl_04：PASS_SCOPED_RTL_F20_TERMINAL_CONTROL_ARBITRATION；原19+17及新增22例共4901cycles，仍小于原6000cycle帽。
- executor_actor_host_08：原两受控软件请求共8次退休、45项F17兼容PASS。
- executor_handoff_portal_rtl_15/16：分别原正常及持续cancel query的真实hub/monitor/depth2有限兼容PASS；request-close仍默认禁用、事实tie0。

全部新attempt退出0，guard child0/trigger null。未启动HLS/OOC/P&R/上板或新agent。旧所有attempt、FAIL、原交付聚合及原审核不回写。

## F19实际覆盖与边界

actor新增独立managed_result_consumed，仅完整Result codec成功且逐字等于本次result_packet建立；legacy result_consumed_pending与无键bool不进入managed路径。实际准入清该请求局部事实；WRITE_RESULT成功末拍及WAIT_RESULT_CONSUMED分别核完整记录，末拍过渡不会丢合法匹配通知。

新增六个独立软件runtime使用实际显式program command consumer产生ordinal0 LOCAL_REJECT错误结果：末拍bool pulse、持续bool、合法错identity、合法错PC、完整匹配record与末拍过渡同调用、尾读后才合法确认。前四及末例在正确record前持续零CLOSE；co-present例保持完整fact但输出未实际读空前零CLOSE。实际Host逐拍收4拍、尾2/尾1各延迟12次调用；错误完整记录后可再由正确完整record恰触发一次CLOSE，受控匹配CLOSED后重复通知不重复关闭。

六例FullRuntime从program错误至关闭逐字节不变，S/H、action接收下界不回退，零新task/Ref/LPV/producer预约或退休，事务流为空。原正常actual C++ program/port/FSM/adapter四窗口仍4次退休，原三cancel consumer及两command无action错误分支均保留零业务退休，156 wire拒绝保持。新六例为实际program错误consumer＋受控shell回应；co-present完整record是抽象consumer接口刺激，不声称真实硬件同拍消费。软件stream无深度限制，尾读延迟不等于depth2 write反压。

## F20实际覆盖与边界

terminal的完整ready/accepted及持久保存不依赖control_fire。合法旧K/终态与实际commit一经出现，同拍authority/query/自主HELD新启动门关闭。匹配CLOSE可引用同拍新封存对象，完整work/Host记录也可同拍保存。实际IMPORT/ABORT consumer共用精确控制header/key/kind/state/status/commit判定，observed_committed只来自旧保存事实或实际匹配IMPORT/commit1 ABORT；terminal自报不提交。

新增22例：ACTIVE、HELD_READY、IMPORT_PENDING各与foreign request、foreign sequence、未知kind、坏保留位、匹配CLOSE同拍（15例）；实际IMPORT+commit1 terminal、foreign IMPORT拒自报commit、早到IMPORT拒commit、实际commit1 ABORT、GRANTED已呈现反压中封存、HELD_READY新query冲突、已归属query第16次read＋terminal/work/Host同拍（7例）。每例合法终态仅接受一次、重复相同记录幂等；新启动/query许可为0、旧锁/route/S/H保持。旧已接query收齐16拍；后续CLOSE在真实记录和受控安全输入齐备后只关闭一次。

已呈现GRANTED/CLOSED字节在持续反压保持，封存后消费旧GRANT不授予新启动。原F18仲裁、旧query及受控旧work/Host消费仍前进。CLOSED为8192bit整体完整校验consumer；测试台提供terminal/work/Host/physical/predecessor事实，未签16拍CLOSED transport或真实生产物理排空。

## 真实捕获与兼容

四份新RTL CLOSED capture各1024B直接匹配独立H1 literal，现C++完整decode/encode roundtrip，状态/commit组合均保持。raw SHA分别：

- ok c0 931c1a77e04e96e11ade68c125e1cac2c832b6efeb797487cce0f7e95607ac1f
- ok c1 283224e9a6df1fd27065e4ea10b5b4111a936cc40b3c020412e97680a5d56537
- error c0 3e517990295301326277be5018a40b95cc4548f650fee6e3a8eef2f412c1106f
- error c1 d35e36549f2244b231fdfe9f41cc6bc0e365c67596f47a5a5cdbfcf2887bd47f

全部与上一交付同字节；Host受控关闭仍H19，不与H1 capture拼为同硬件runtime。原七帧7168B及八CLOSE/CLOSED literal不改。

portal_15原112AW/7168W/112B、7真实typed终态、实际depth2 16/16、离线actual-helper确认→GRANTED实际消费→CLAIM180/epoch9兼容保持。portal_16第2拍后持续cancel，旧query16次ingress及返回16次实际read、尾2/尾1反压、完整负oracle及绑定ABORT_CLOSED一次保持；终态仍7/LPV179，无自动重开。前序是地址pattern，不代签LN算术。旧transport在取消前已排空LPV，活动LPV缺口未由兼容关闭。

## 身份、历史与资源

295/295 frozen/声明pair；登记前295/295 current、880/880递归引用。登记后287/295 current、872/880引用，8项live差异均为两个catalog本轮登记，逐项SHA对上delta。所有原始行首marker及receipt核对；不以报错字符串中的PASS认通过。

历史共同原件对比：shell_03→04的23项只变shell/TB/runner；host_05→06、actor_07→08共同90项六变化为两catalog＋actor/header/TB/runner；portal_13→15和14→16共同34项四变化为两catalog＋shell/wrapper。外部新capture_run身份切换另单列。上一交付20项匹配筛选的原聚合/manifest/receipt/核验等SHA仍一致；历史FAIL不重写。

10guard串行，118条实际policy符合CPU0–3/nice19/idle I/O及原MemAvailable门。shell RTL23.969124s/1643180KiB；host oracle/build/run0.340840/20.360828/0.285840s，RSS24560/276036/20928KiB；actor兼容0.363526/20.279080/0.280803s，23900/275356/21384KiB；portal正常43.844749s/1634668KiB，持续cancel44.907332s/1640728KiB。RTL8GiB/120s/120s、host24GiB/1800s/120s及周期帽不变。

shell oracle0.173216s没有owned-child RSS/policy，peak null，整体资源观测完整性false；其他段仅按实际样本陈述。fixture生成/-MM的timeout/RLIMIT_AS不扩成观测guard。Host5条、actor45条leftover仍为原故意重放/错K/F17未读队列，未清FIFO或降低负例；不签所有流清空/坏帧恢复。

## 继续工作

F19/F20本冻结候选请求有限主控验收；旧F15–F18关闭不扩大。真实wrapper旧A/K/results/Host/CLOSED consumer、no-LGP已准入Host错误、committed ABORT、活动LPV旧半帧/END/末B/返回及带旧新归属准入/持续allocator仍待。已直接发executor-managed-lpv-owner-question-20261013核定持久A/K及CLAIM无BEGIN cleanup来源，回执delivered；独立工作继续。

C009/C013部分实施/awaiting_implementation，C008/C010待验。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。原单owner/单重工具/所有帽/G2338.224019s保持，5172s组合不重启，无新agent/HLS/OOC/P&R/上板/预算。

证据：本R003目录executor_close_f19_f20_verification_20261013.json、history、catalog_delta、原始五attempt manifest/receipt/driver.log；冻结审核仅用于所列范围。
