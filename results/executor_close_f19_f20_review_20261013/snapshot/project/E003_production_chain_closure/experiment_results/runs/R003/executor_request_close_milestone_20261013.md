# CLOSE/CLOSED有限端点与主机准备里程碑

M003/SM003/E003/R003；A002唯一owner。依据D-M003-EXECUTOR-CLOSE-REARM-01，原预算不变；本轮没有HLS/OOC/P&R/上板或新agent。

**工程有限验证通过，待主控审核。** `executor_request_close_shell_rtl_03`为PASS_SCOPED_RTL_REQUEST_CLOSE_ENDPOINT；`executor_request_close_host_05`为PASS_SCOPED_HOST_REQUEST_CLOSE_PREPARATION。actor_07和portal_13/14仅各原fixture兼容。真实生产wrapper、已接受但未发LGP的错误结果、ABORT已提交错误收束和无复位下一请求仍未闭合，不把本批称为生产请求恢复。

## 行为与证据

LHC1新增CLOSE8/CLOSED9，version1/1024B/16拍和全部旧字段不变；原七帧7168B逐字与actor_06相同。八组独立终态/commit literal，C++完整roundtrip及156个wire变体拒绝清输出；其他未知kind继续拒绝。code/detail/bad是原请求封存终态，非OK CLOSED仍可表示安全关闭；commit只能匹配已保存事实。

actor managed_close在实际软件LYRQ/LYMP准入时锁存；外部把该输入恢复false不能绕过关闭。WAIT_RESULT_CONSUMED需要完整、合法、逐字匹配的实际Host结果，单独result_consumed无授权；实际旧program/port和队列正常收束后产生CLOSE。匹配完整CLOSED要在CLOSE已实际消费之后，核整个K、终态及commit；关闭只一次，保留原runtime、导入基线和各下界，进入WAIT_NEW_ADMISSION。此状态未实现新候选ingress，不能重开旧前序或新executor。

六个独立软件runtime用例为：一条真实C++ program top/port/FSM/adapter及受控远端的正常四窗口路径（task5–8，4次真实本地退休），三条实际program/取消consumer路径，以及两条完整/部分command真实未分配action的ordinal0错误结果。五个取消/无action分支零业务事务/退休；正常段四退休不是关闭产生的退休。实际action/completion/program/Host消费者和原8/4/4拍尾等待保留；增加program READ_COMMAND且bound_command=false断言。每例实际Host结果完整读取后才发关闭；早到、错键、wrong commit/终态/旧GRANT不推进。待CLOSED反压12次调用时控制帧稳定，持久cancel及当前base/session/request变化仍按旧键完成一次关闭，输入恢复、新request_valid、旧结果/确认不rearm。关闭前后FullRuntime逐字节相等。

shell `_03`含原19项F18兼容及新增17关闭场景，总3230cycles。四组status/commit返回逐字匹配独立gold；work、Host、old_channels和physical_safe分别等待，未满足不发布CLOSED。仅response_ready、错/旧完整消费记录不会释放锁；已呈现响应在cancel/base/session/request变化和反压下稳定。实际完整8192bit CLOSED消费后保留最后关闭记录、S/H和关闭计数，清旧锁/route并进入WAIT_ADMISSION，不回legacy IDLE。helper已提交但shell尚未观察时，CLOSE不能补造commit；实际IMPORT在cancel下只传达commit，随后旧错误才关闭。终态封存同拍禁止新的authority/query/HELD；control_fire优先，原已接受query和cleanup路径保持。动态新增同拍断言覆盖本次ACTIVE/IMPORT_PENDING封存位置，未代签任意入口组合。

四份真实shell CLOSED各1024B，被冻结为host_05输入，经现C++完整codec roundtrip并与独立固定H1 literal逐字相同。该链是实际RTL捕获的离线解码，不是同硬件runtime的program/helper/关闭consumer接线；host受控CLOSED仍绑定H19，两个范围分开。

portal_13/14保留原实际hub/monitor/query双depth2正常和2拍后持续cancel范围。正常前序112AW/7168W/112B、458752B、7终态，离线actual-helper确认与GRANTED消费后CLAIM180/epoch9，typed仍7。取消query16拍实际ingress/返回及末2/末1各12周期反压，一次ABORT且不自动重开。production portal wrapper的MANAGED_REQUEST_CLOSE仍默认关闭、新close事实输入全部tie0；这些兼容不证明请求关闭。actor_07保留原两个受控软件请求共8次退休及45项F17。

## 冻结身份与资源

完整口径 **295/295 frozen/声明pair；当前287/295，872/880 manifest/receipt递归SHA引用**。8项live差异全是两个catalog登记，逐项披露；不能写成当前295/295。独立字节/身份/guard检查见executor_request_close_verification_20261013.json；历史比较见executor_request_close_history_20261013.json。

10段所选guard起止串行，child0/trigger null，109条实际policy满足CPU0–3/nice19/idle I/O、MemAvailable>192GiB和原帽。RTL8GiB/120s/120s；host24GiB/1800s/120s。资源观测完整性=false：shell oracle0.164578s未采到owned-child RSS/policy，peak为null，只签配置。其他阶段只按实际样本记录，不从时间推定观测。fixture/-MM仍只配置/timeout/RLIMIT，不扩大成owned-tree保护。

| 阶段 | 墙钟s | peak owned KiB | 观测范围 |
| --- | ---: | ---: | --- |
| executor_request_close_shell_rtl_03 / guard_oracle | 0.164578 | null | 未采到child；仅配置 |
| executor_request_close_shell_rtl_03 / guard_rtl | 22.489856 | 1553612 | 实际采样 |
| executor_request_close_host_05 / guard_build | 21.175111 | 273788 | 实际采样 |
| executor_request_close_host_05 / guard_oracle | 0.285397 | 13644 | 实际采样 |
| executor_request_close_host_05 / guard_run | 0.223745 | 21460 | 实际采样 |
| executor_actor_host_07 / guard_build | 20.222678 | 269364 | 实际采样 |
| executor_actor_host_07 / guard_oracle | 0.279670 | 23828 | 实际采样 |
| executor_actor_host_07 / guard_run | 0.276871 | 21388 | 实际采样 |
| executor_handoff_portal_rtl_13 / guard | 44.701633 | 1679208 | 实际采样 |
| executor_handoff_portal_rtl_14 / guard | 45.177888 | 1672188 | 实际采样 |

## 历史与范围

host_01/02为TB编译FAIL，均没有DUT运行：_01的混合auto、detail命名冲突和Werror缩进；_02剩余混合auto声明；_03仅将声明拆开后PASS。_03→04/05增加真实CLOSED捕获输入、独立H1 gold及实际program终结断言，actor/header/codec DUT保持。shell_01在首份关闭捕获调用处XSim exceptional kernel终止，无最终PASS；_01→02只替换ternary字符串task参数为常量分支并增加定位marker，DUT和断言保持；_02 PASS保留。_02→03增加封存同拍新启动门和对应断言，DUT发生变化，以_03为本批最终身份。旧PASS、失败、manifest/receipt、日志不回写。

host_05的5条leftover警告对应一次关闭后的故意旧action重放和四个错K拒绝的未读action；actor_07的45条保持原F17负例。没有清FIFO/reset/丢帧来通过，坏归属/重放隔离没有恢复验收，不能声称所有负例流清空。关闭host_05软件队列实测最大depth16；actor_07实测最大depth24。两者均无硬件深度限制，不能写成depth2时钟行为。

## 下一步

真实wrapper仍须从唯一旧A/K和各实际consumer产生terminal/work/Host安全事实，完整CLOSED transport消费后协调actor/shell/transport清旧phase。未发LGP的已准入请求须真实executor本地Host错误结果及admission_closed(A)，已有任意LGP拍则继续真实program收束；已提交ABORT不得伪装commit0。活动LPV现transport_abort会清framing的缺口未改，本批query取消之前LPV已排空，不代签旧END/末B/返回。

接着实现带旧关闭依据/新完整候选的真实准入ready/valid，持久runtime不得用原full_begin_request/full_recycle_request清allocator/last_task/checkpoint下界来重装。保留S/H、LPV/task/Ref、producer/compute/program及可信接收下界；新的source有效性仍由新真实准入和owner生命周期核验。

之后实际LAP1和8/4 action、F10 24/16 consumer、全部source读写/修改入口与F9、合法Q lease/读债，以及独立executor串行生成、LN/monitor/唯一hub→实际END/唯一软件退休→Q/fullA/最终13BO按原顺序继续。

C009/C013 awaiting_implementation，C008/C010待验；F15–F18原有限关闭不扩大。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。G余2338.224019s、原单重工具/资源帽保持，5172s组合不重启。
