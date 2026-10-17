# CLOSE端点与主机准备：冻结源码审核

审核：R-SM003-EXECUTOR-REQUEST-CLOSE-20261013。工程原始PASS/FAIL不修改。主控没有编译、仿真或运行HLS；以下F19/F20为冻结代码的静态路径推导，尚无新增动态FAIL。

## 判定

接纳本批实际执行用例、C/SV常量及literal、四份真实CLOSED捕获的离线codec、受影响兼容和资源/身份记录。完整Host结果作为关闭唯一依据、终态封存同拍禁止新启动这两项端点义务仍有静态缺口，标记F19/F20待修。不能用本批marker为受影响边界签最终关闭，也不把有限shell或host拼为同硬件runtime。

## F19：managed路径继承了旧无键结果消费布尔值

冻结文件：R003/executor_request_close_host_05/frozen/hls/control/executor_actor.cpp；相对project/E003_production_chain_closure/experiment_results/runs/定位。WRITE_RESULT第363–369行和WAIT_RESULT_CONSUMED第371–389行：

```cpp
// WRITE_RESULT，最后一次write_nb成功
s.result_consumed_pending = in.result_consumed;
s.phase = Phase::WAIT_RESULT_CONSUMED;
// managed分支
if (in.host_result_valid) {
  if (decode(...) && in.host_result == s.result_packet)
    s.result_consumed_pending = true;
  else ++s.control_rejections;
}
if (s.result_consumed_pending && /* local work ended and streams empty */)
  control(..., CLOSE, ...);
```

`managed_close`不限制第一处赋值。静态可达反例：沿现正常或错误结果路径进入WRITE_RESULT/beat3，最后写出时`in.result_consumed=1`而没有完整Host结果确认；这使pending=1。随后实际读取输出流至empty，但不提供完整有效Host记录，或提供错identity的合法结果。WAIT_RESULT_CONSUMED不会清除这个旧pending，其他既有正常收束条件成立后仍会发CLOSE。输出流empty只能证明流已被读取，不能补上完整结果校验和归属事实。

当前`executor_actor_test.cpp:159`的finish_managed_close在已经进入WAIT_RESULT_CONSUMED、实际dequeue之后才注入无键bool，故覆盖不到WRITE_RESULT末拍锁存窗口。`host_full_result_required=1`只由所测时序支持，不能覆盖该反例。

修复应令managed关闭的消费事实只能来自完整、合法、匹配本次结果的真实consumer记录；legacy bool不得在末拍或任意过渡时污染它。合法完整记录与末拍/状态切换同拍的情形也须有明确保留或握手机制，不能修成丢失真实确认。补末拍无键pulse、持续bool、错/旧完整记录、尾部反压及后继正确完整记录的动态例；在正确记录前零CLOSE，之后只关闭一次，FullRuntime和各下界不变。保留默认legacy兼容。

## F20：控制握手压住终态封存并留下启动窗口

冻结文件：R003/executor_request_close_shell_rtl_03/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_handoff_shell_v1.sv。第127–144行：

```sv
control_fire = control_valid && control_ready;
terminal_seal_fire = MANAGED_REQUEST_CLOSE && terminal_seal_valid &&
  !control_fire && !terminal_sealed && ... && terminal_ok(terminal_seal_record);
authority_valid = state==ACTIVE && executor_owns_dispatch && !revoked &&
  !cancel && immutable_live && protection_valid &&
  (!MANAGED_REQUEST_CLOSE || (!terminal_sealed && !terminal_seal_fire));
```

取实际可达ACTIVE、committed1、无response/query活动、immutable/protection成立、cancel=revoked=terminal_sealed=0。提交合法完整同K/commit的terminal_seal_record，同时control_valid=1携错键或坏kind帧。此时control_ready=1、control_fire=1、terminal_seal_fire=0、authority_valid=1。第162–167行没有锁存该终态，只记拒绝；控制帧也被拒绝，phase保持ACTIVE。若终态valid是当前TB `seal_terminal()`采用的一拍脉冲，则终态丢失；即使持续valid，仍已有同拍新启动窗口。接口没有terminal ready/accepted输出可把这次抑制解释成调用方已获通知的重试。

合法CLOSE与尚未锁存的终态同拍也不能靠拒绝CLOSE抹掉终态事实。HELD_READY处同类条件影响query_permit；IMPORT_PENDING的同拍IMPORT/commit变化须按真实已观察提交事实核验，不能从终态自报commit造授权。

当前TB第124–130行仅独立拉terminal_seal_valid；close循环先send(CLOSE)后seal，再send(CLOSE)，未覆盖seal与control_fire同拍。_02→03的封存门修复对该已测顺序有效，但没有消除上述仲裁窗口。

修复应分开“完整匹配终态事实令新启动立即停止”和“控制/响应的唯一仲裁”。错/旧控制不能压掉终态或放行新启动；明确持久保存/握手，保留已呈现响应字节、F18规则及旧query/cleanup进展。补ACTIVE合法终态与错/旧/坏控制、同拍CLOSE，及HELD_READY/IMPORT_PENDING受影响组合；真实新启动/新query准入为0，终态仅封存一次，原已接受工作可排空。不以reset、撤valid或清队列处理。

## 实际证据仍支持的范围

LHC1新增8/9保持version1/1024B/16拍及原七帧字节；8组literal独立重构，156 wire变体拒绝，四份RTL capture逐字匹配H1 literal并与host frozen external相同。host受控控制返回仍为H19；该离线关系不等于控制consumer同硬件runtime。

shell原19+新17例/3230cycles实际成功；各终态/commit组合、work/Host/channel/physical分开延迟、CLOSED稳定反压、当前live字段改变及完整8192bit消费后WAIT_ADMISSION均有原始marker/TB依据。消费口是整体bus，尚无16拍depth2 CLOSED transport。物理与结果记录仍由TB提供。

host六独立runtime：正常program/port/FSM/adapter四窗口贡献4次退休；三cancel consumer和两command已发送但无action分支零业务事务/退休。现测试沿完整Host消费→CLOSE→匹配CLOSED进入WAIT_NEW_ADMISSION，FullRuntime不变；当前没有新候选入口。未发LGP的已准入请求本地错误、committed ABORT完整结果仍未实现。actor_07旧45 F17和两软件请求8退休、portal_13/14正常及持续cancel query兼容保留。production wrapper的managed close仍默认关闭，新增事实tie0，不能代签请求关闭。

## 身份、历史和资源

29交付SHA、295/295 frozen/声明pair全部一致；287/295 current、872/880递归引用，8差异仅两个catalog。10guard起止串行、109实际policy符合原帽，shell oracle0.164578s无owned child RSS/policy、peak null、资源完整性=false。fixture/-MM仅配置证据。host_05五条leftover和actor_07四十五条与故意重放/错键或F17残帧覆盖一致，不签坏帧恢复。

host_01/02编译FAIL无DUT运行、shell_01内核异常保留；shell原始driver包含Tcl报错中引用PASS标记字符串，不能把字符串出现视为实际PASS行。主控核验匹配真正行首marker。所有历史diff重算吻合；_02→03 shell/TB变化和host捕获依赖切换均保留。

F19/F20修复与受影响回归沿原授权连续实施，无逐项审批或额外预算。C009/C013部分实施；活动LPV旧半帧/END/末B/返回、真实wrapper关闭/无复位准入与持续下界、LAP1/action/F10/source全部入口/Q及完整链仍待。旧F15–F18关闭不扩大。
