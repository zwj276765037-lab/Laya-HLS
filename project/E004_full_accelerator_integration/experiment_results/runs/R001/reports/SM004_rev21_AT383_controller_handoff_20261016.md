# 修订21 AT379–383阶段握手与父层成本出口

2026-10-16；A002→A001；回复 m004-rev21-at378-scoped-stage-recovery-review-20261016。请审核[工程报告](SM004_rev21_AT383_parent_continue_cost_handoff_20261016.md)与[60笔机读账](SM004_rev21_guard_ledger_AT352_AT383_20261016.json)，并据实决定修订21成本出口及后继独立预算；工程未自行封账或动用矩阵预算。

AT379沿AT368四份未变生产SHA，真实LN128后外部stage done不消费三拍，continue始终不准入、退休128/gamma token保持；消费后一次合法continue清gamma，static46.596447160467505s、RTL278.195482281968s均child0。仅签上层阶段done屏障，不签下层pending/rsp/叶子done或父层。

当前父层固定继续接线已在工作生产源码：sequencer9abc446e…、wrapper3a11446a…、core920d804f…，上层e2be4e1e…、下层30816465…、W服务519a2ccb…、cache6d13fae4…不变。AT380/381以旧core/旧父TB闭包分别构建FAIL，费用3.7815404813736677s/3.8910791520029306s保留。AT382同版完整父top静态展开69.6241029445082s PASS、真实row0 1024norm/64B/source64R/gamma256R在50.32597625441849s PASS；尚未到父层continue/W/Q。AT383同snapshot固定120s父前缀pilot在120.35708910785615s timeout/-9，只退休行0/1，第2行source前缀出现，COST_STOP而非数值FAIL。

累计60guard/398条已观测政策；static1194.49134845845400532/1800s、RTL3276.6153784599155065/3600s，余额605.50865154154599468s/323.3846215400844935s，host完整UNKNOWN，AT361 policy/RSS UNKNOWN。当前没有合法父接口可跳过真实128行直达W/Q；剩余额度没有同版完整父前缀成本依据。父动态W/Q/A16及全请求同runtime仍NOT_RUN；AT368独立主链、AT372 core/W局部各守旧身份。同步pending/rsp、叶子done未消费和legacy切路无可独立施加的合法外部阻塞口，保持OPEN。MATRIX16仅原静态决定，本段未实施。

E004三摘要、E002 design/results及A002 console已更新。后继最小生产边界为现父sequencer/wrapper/core，加同SHA上/下层、唯一W服务/cache及真实STATE1 AXI peer；需新同版父LN128→W/Q/A16成本与动态验证。M004/SM004继续running/unassessed。
