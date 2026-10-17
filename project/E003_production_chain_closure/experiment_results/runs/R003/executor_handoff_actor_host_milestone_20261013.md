# Executor HOLD/IMPORT持久actor主机准备阶段交付

消息 executor-handoff-actor-host-milestone-20261013；回复 executor-checkpoint-import-handshake-answer-20261013。范围M003/SM003/E003/R003，沿D-M003-EXECUTOR-CHECKPOINT-IMPORT-HANDSHAKE-01。

工程结论：executor_actor_host_02为PASS_SCOPED_HOST_HANDOFF_ACTOR_PREPARATION；executor_checkpoint_host_05按旧v2主机fixture兼容通过。只签实际C++ schema/helper/core组合，HELD/GRANTED/ABORT_CLOSED/session/fence/远端受控。尚无独立C HLS entrypoint、executor生成物、真实RTL控制握手/物理保持或硬件rearm，不把同一software runtime两个请求写成两个硬件accepted-request生命周期。无新增阻塞问题，真实shell接线继续，不等待逐项审核。

## 实现与实际测试

新增独立LHC1控制协议1024B/16拍、version1，完整B随帧回显；K包含hardware session、accepted-request实例、NumericIdentity、S/H及完整source/target/model/base绑定。header/保留位在全部帧核验，不用短hash或无tag脉冲替代。C/SV常量逐项静态匹配；本轮SV未执行。独立Python literal七种帧共7168B与实际C++ encode/decode逐字一致，20个保留位/头拒绝清旧输出，五个语法合法全键变化不匹配。

reserve_hold先从真实已准入请求/model构建B并一次消耗S，完全不依赖held；prepare_held只使用该pending S，匹配shell H并核Fence。不再依赖“先query才能held”。匹配但cancel的HELD仍保存已观察H，signal恢复后hold_reserved继续阻止误用accept；失败不退S/H。旧prepare包装与原LBS2/LBR2字节保持兼容。

actor拥有一份持续FullRuntime/Port/shared Machine/checkpoint。两个software请求1101、1102都经实际LYRQ/LYMP解析准入；同request查询不再begin/admit。S1→2/H19→20，producer0→4→8/action0→1→2保持。每个导入本地tasks_retired为0、owner claim/lease贡献0；随后真实C++ program top→port/FSM→transaction adapter与受控远端各执行四窗口、实际每段退休4次，共两段8次。两段task5–8及8–11、LAC1 first/last/count一致；统计不是task最大号推导。

LBR2尾2/尾1各停12次host调用，未完成全帧无导入。第16次read后仍暂存command，24次调用无LGP1/action/事务；实际helper成功形成commit1 IMPORT_OK，受控匹配GRANTED才允许发LGP1。12个早到/错S/H/session/identity/旧request GRANT均零派发。结果输出后延迟消费24次调用保持request准入门。这里是software stream/抽象消费通知，不是depth2时钟级门控。

未知预约空洞由实际helper拒绝，生成commit0 ABORT；受控匹配ABORT_CLOSED后保留已耗S/H并回到等待新尝试。已提交后cancel/base/request实例改变三例生成commit1 ABORT，输入恢复和旧GRANT不发command、不回滚baseline/LPV/Ref，不增加退休。已提交撤销没有生产错误结果/真实安全释放出口，本轮只签fail-closed保留，恢复待实现。原控制帧保持到抽象consumer握手，不改写已呈现的IMPORT_OK以隐藏撤销。

## 运行、身份与兼容

actor_02 oracle/build/run为0.281302/20.441539/0.169802s；owned-RSS峰值24496/250440/未观测KiB。短run在第一次有效child采样前结束，只有launcher/wrapper配置及功能marker，不把未观测填0。compat checkpoint_host_05为0.234116/15.885593/0.485404s，峰值24640/246424/345168KiB；保留旧2048B字节oracle、46 wire/36全runtime拒绝/4 prepare负例以及旧三受控runtime四窗口/动态下界/统计检查。

六guard child0/trigger null，55条实际CPU0–3/nice19/idle I/O policy，开始/结束串行且MemAvailable/24GiB/1800s/120s保护保持。-MM依赖提取只有timeout/RLIMIT_AS，不冒充owned-RSS/进度观测。

两项共158/158 frozen/声明pair；登记前158/158 current和366/366引用，登记后154/158 current和362/366引用。四处只为两个catalog本轮登记，无DUT/TB/oracle/模型漂移。核验SHA `f625a58f585e582de2058d89cfad0236e3e41a7ebd07f5a60c609bbd8c40a769`；catalog delta另存。actor_01原PASS保留，_01→02仅测试增加早到/错GRANT、LAC1编号统计和撤销HELD不能复用，DUT完全相同。新四合同均纳入冻结闭包，旧183组补计记录已按主控答复验收，不回写旧交付。

## 后续与总体状态

下一步把这些C++消息接到真实独立控制通道：前序真实action结束/待发清空握手及monitor/LPV/F10/读债→HELD；完整LBR2实际consumer后仍authority0；实际helper确认→GRANTED；未提交ABORT安全关闭和已提交错误收束；带归属rearm与持续S/H。当前portal/transport旧末拍直接authority和QUANT query长期屏蔽行为仍须按新合同接线，未签生产启动。

再接独立executor HLS、实际8/4 action与F10 24/16消费、真实LN/monitor/唯一hub→completion派生END/唯一软件退休→Q/fullA。完整source全部入口、13BO/base、family/PC、恢复、完整CPU/CSim及最终请求仍待。C009部分实施，C008/C010整体待验，旧限定关闭不扩大；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。原单重工具/所有帽/G余2338.224019s保持，无新agent/HLS/OOC/P&R/上板/预算；5172s组合不重启。
