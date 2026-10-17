# Executor HOLD/IMPORT actor主机准备审核

回复：`executor-handoff-actor-host-milestone-20261013`  
审核：**R-SM003-EXECUTOR-HANDOFF-ACTOR-HOST-20261013**；M003/SM003/E003/R003。

**按实际覆盖接纳executor_actor_host_02为PASS_SCOPED_HOST_HANDOFF_ACTOR_PREPARATION，executor_checkpoint_host_05保留原v2主机兼容PASS。新增静态问题F17：RUN_ACTION阶段遗漏持续撤销采样，须在受影响executor生成前修复并补有界回归。** 这不覆盖或重标原PASS；主控未运行DUT，F17是冻结源码的静态控制路径判断，尚无动态复现。真实shell、HLS entrypoint、物理保持与硬件rearm仍未验收。

## 身份与证据

独立递归核对两项manifest/receipt：158/158 frozen/声明pair、154/158 current，362/366 SHA引用；四项live差异逐项匹配两个catalog登记，无额外DUT/TB/oracle/模型漂移。七个交付SHA全部一致，聚合SHA与来信一致。actor_01→02共同83组只有executor_actor_test.cpp改变，DUT相同，旧PASS与原始文件保持。

六段guard child0/trigger null，实际起止串行，55条policy符合CPU0–3/nice19/idle I/O；MemAvailable及24GiB/1800s/120s帽符合。actor oracle/build/run为0.281302/20.441539/0.169802s；短run确无owned-RSS/child-policy样本，峰值为null，只保留launcher配置与功能marker。兼容三段为0.234116/15.885593/0.485404s；-MM限制不扩成进度/RSS观测。

独立重建七份literal控制帧，完整7168B与冻结fixture相等；冻结C++逐字decode/encode断言、20处wire拒绝清输出和五个合法键变体均有原始PASS marker。C/SV常量只做静态一致性核查，未执行SV。21源actor闭包与另加的真实program/adapter主机集成来源符合声明，无独立生成top结论。依据保存于[独立核查](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/executor_handoff_actor_host_review_20261013/verification.json)。

## 接纳的实际主机范围

reserve_hold在无HELD时构造B并一次消耗S；prepare_held只用当前pending，匹配而撤销的HELD保留已观察H和hold_reserved，输入恢复不能直接accept。LBR2未收齐不导入，完整帧之后实际helper提交只建立baseline/镜像/下界，不增加本地退休/owner统计；Command留存，实际IMPORT_OK被抽象消费并得到受控匹配GRANTED后才发LGP1。12个早到/错键/旧request GRANT零派发。

同一软件actor及真实C++ program/port/FSM/adapter处理两次实际LYRQ/LYMP准入：S1→2、H19→20、producer0→4→8、action0→1→2。每个请求四窗口，task5–8及8–11各退休4次，LAC1 first/last/count相符；每请求统计归零后实际累计两段8次，不能把两个task区间当成同一请求的连续历史。snapshot、shell fence、远端和session均受控；软件stream尾拍/24次调用等待不代表真实depth2时钟门控或硬件accepted-request生命周期。

实际预约空洞使helper拒绝并发commit0 ABORT，匹配受控ABORT_CLOSED后保留S/H，回到等待尝试；该测试没有修好空洞再完成第二次导入，不能外推成功重试。commit1后的cancel/base/request实例三例在WAIT_IMPORT_CONFIRMATION撤销，保持已呈现IMPORT_OK直到消费，再发ABORT；输入恢复和旧GRANT不发命令、不回退已导入下界。此出口只证明隔离保留，没有已提交错误的真实结果/安全释放或恢复。

## F17：发完command至实际action启动间的撤销空窗

冻结[executor_actor.cpp](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_actor_host_02/frozen/hls/control/executor_actor.cpp)的step前置撤销采样显式排除RUN_ACTION（约97–109行）；WRITE_COMMAND发完LGP1即进入该phase（217–224行），但此时LAX1首拍可以还未被消费。RUN_ACTION只把`in.cancel || s.revoked`交给port（226–231行），不检查当前base/session/accepted_request。

因此有明确静态路径：已收到合法GRANTED并发完LGP1，port仍在READ_ACTION/beat0；把base epoch/address/capacity或session/accepted_request改变，且action FIFO有待处理帧。该次step不会置revoked，port仍可读取新action首拍；若输入恢复，撤销也未被保存。即使未来shell挡住物理AR，这份actor仍未满足合同要求的启动前阻止action准入。RUN_ACTION且首拍未读时的短cancel也没有actor级持久锁存，不能依赖外部program恰好同时捕获脉冲来替代本归属状态。

请修复为在绑定存活期持续捕获不可变identity/session/base及cancel撤销，并将“禁止新启动”与“旧已接受action继续cleanup”分开。**不能把当前live()整段搬到RUN_ACTION并要求活动期间physical_quiescent恒真**：正常已接受任务会产生债务，source/target保护也需按真实权威移交；应分离不可变绑定撤销、启动前保护检查和旧工作清理资格。不要在检测变化后简单isolate/return而堵住已经接受的END/返回。

有限回归至少覆盖：合法GRANT→完整LGP1已发、LAX1首拍尚未读时，base/session/request实例分别变化并恢复，以及单次cancel脉冲；核撤销保持、无新action准入/普通事务/producer与退休，旧确认不能再开门。再覆盖LAX1部分接收或旧action已活动时的同类变化，按原绑定完成必要帧/cleanup，无正常后继启动、无丢债/清状态/假退休；保持原正常四窗口路径。生成shell后还须有真实同拍门控与物理债务证据，host不代签。

## 继续执行

工程可直接修F17并做受影响host验证，真实shell独立准备继续，不需逐项审批；受影响executor候选在修复闭包冻结后再按原帽生成。原portal的LBR2末拍直接授权及交接后Q query被长期屏蔽仍须按合同改接，不能用本主机PASS代签。未提交ABORT安全关闭、已提交错误收束、带归属rearm及实际8/4 action、F10 24/16消费仍是后续工作。

C009部分实施/awaiting_implementation，F17待修复验证；C008/C010整体待验，旧限定关闭不扩大。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。原单重工具/全部资源帽/G余2338.224019s保持，无新agent/HLS/OOC/P&R/上板/预算；5172s组合不重启。
