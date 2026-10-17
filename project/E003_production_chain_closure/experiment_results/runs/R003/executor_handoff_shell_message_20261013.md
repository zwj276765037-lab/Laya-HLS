# 有限executor shell阶段交付

聚合：project/E003_production_chain_closure/experiment_results/runs/R003/executor_handoff_shell_deliverables_20261013.json
聚合SHA：9ebfed5355d4796b4055564ffbed5c28813429ca143c3eb45cfe0c92e1c6f688

# Executor HOLD/IMPORT shell有限控制及真实portal连接交付

回复：executor-actor-f17-review-20261013；沿D-M003-EXECUTOR-CHECKPOINT-IMPORT-HANDSHAKE-01。范围M003/SM003/E003/R003。

F17已按主控审核在actor_04有限host范围关闭，旧证据不改。本轮工程自检：shell_rtl_02为PASS_SCOPED_RTL_CONTROL_SHELL_PROTOTYPE；helper_host_02为PASS_SCOPED_HOST_REAL_CAPTURE_CONFIRMATION；portal_rtl_02为PASS_SCOPED_RTL_DIAGNOSTIC_HANDOFF_PORTAL；checkpoint_rtl_07为默认managed关闭兼容PASS。C009/完整source保护及生产整链仍未关闭。

## 当前实现与测得行为

新增laya_executor_handoff_shell_v1.sv，独立8192bit LHC1控制ready/valid、单pending。HOLD真实接受时耗H并保存B/S/session/request，DRAIN保留旧控制器事务；匹配前序完成键及独立真实排空后才建立锁与持久HELD。query完整B/S/H匹配后收集实际consumer16拍，末拍仅IMPORT_PENDING；actual-helper的IMPORT_OK和匹配GRANTED实际消费后，才登记executor ownership及启动authority。响应反压时字节保持，撤销持久且cancel/base/session/request当拍关闭启动。physical_safe只用于取得保持/授权/安全关闭，不要求活动工作持续无债。

shell_rtl_02：16个有限诊断、1818cycles。HELD、LBR2末2/末1、延迟helper、GRANT各反压12周期；一次早到及七种错/旧/保留位确认可消费但不授权，重复IMPORT不再授权。actual C++helper预约空洞拒绝产生commit0 ABORT，物理安全延迟后返回持久ABORT_CLOSED；同一request不复位重试S/H1→2且旧确认无效。这不是两个accepted-request rearm。cancel/base在hold取得、LBR2末拍、IMPORT同拍、GRANT反压/消费及活动启动边界有检查；活动session/request变化同拍关启动而保留旧owner。commit0不能伪装撤销已提交导入，commit1 ABORT保留锁/归属进入隔离；完整错误结果/释放出口仍NOT_RUN。

portal新增默认关闭MANAGED_EXECUTOR_HANDOFF。managed时原transport最后LBR2 read产生的旧authority/pulse对外始终0；completed-query只选择内部route，外层完整键shell的GRANTED才授权。取消后，已交给executor的旧LPV route不随新启动authority一起关闭。managed后续source_query valid路径允许按交接route到hub；本轮没有运行合法QUANT lease/读债，因此只记接线实现，不签Q消费通过。默认模式行为保持，并以checkpoint_rtl_07实际回归。

## 实际捕获→helper→回放

portal_rtl_01只取得真实捕获，不执行IMPORT。正常唯一hub/monitor/LPV前序产生7次成功typed终态、112 AW/7168 W/112 B、458752B。来源是正常CLAIM/BEGIN/真实写/END/PUBLISH形成的受控地址pattern，非encoder数值。HOLD在第7个任务旧末B/END/返回尚在时已经接受，持续DRAIN且不锁旧入口；末B退休和旧END返回消费后继续必要PUBLISH及目标历史操作。诊断前序控制器显式在有限序列结束交出完整绑定键，不用瞬时无valid推导完成。

真实双depth2 LBS2/LBR2执行16/16拍，末2/末1各停读12周期，两LPV入口持续valid均无准入。HELD和第16次read后仍无shell ownership/authority、无新事件或退休；actual LBR2为task7、source1、INACTIVE target8、LPV179，整1024B匹配原独立literal gold（只用本次实际S/H1替换已定义的控制号）。

helper_host_02在真实LYRQ/LYMP软件准入之后，用当前C++完整codec逐字roundtrip该实际捕获，并由真实helper导入基线7/179/8，统计贡献0。另一受控runtime带未知预约空洞时，真实helper拒绝并生成commit0 ABORT。IMPORT_OK也与独立LHC1 literal逐字匹配。此为离线actual-helper驱动，不是生成executor与前序同硬件runtime；HELD及fence在host侧仍受控。

portal_rtl_02复现同一真实前序和LBR2。捕获hex及helper输入raw byte与_01逐字相同，加载冻结actual-helper IMPORT_OK；GRANTED持12周期且两入口仍关闭，真实消费后仅一次切换。后继同LPV transport CLAIM180/epoch9实际接受，hub typed仍7，没有新增退休。cancel当拍关新authority，但旧executor route的full_n仍可达；本轮只测route保留，未执行后继旧END/INVALIDATE完整cleanup。LPV accepted_events20→21，source/target锁在此有限TB装配中覆盖两个LPV入口及单前序STATE0 writer的VALID/READY两侧，未覆盖source AR/F9/其余writer/13BO物理alias。

_01/_02 capture hex SHA：c2442fd8a8c35c39777229f95075c47958fde0c77c41dd8e52affa5b82a9ccc6；原始1024B SHA：05fd66a4d50e3bcca0d086a3cb2503202f595ed10a6d1e287cc817a34e1a64a6。

## 身份、原始工具与预算

五项闭包含全部外部合同/控制输入：211/211 frozen及声明pair，登记后200/211 current、707/718递归manifest/receipt SHA引用。11处live差异：四个attempt各两catalog（8处），另proof-only portal_01的portal/TB/runner三处后续实现变化。具体为managed legacy输出屏蔽、完整实际helper proof字节核对与对应fixture输入登记；冻结输入和运行物未变。无需将这些差异说成只有metadata。_01 capture在helper和_02回放逐字确认。

8段guard全部child0/trigger null且串行，110条实际policy为CPU0–3/nice19/idle I/O；MemAvailable门通过。helper24GiB/1800s/120s、RTL8GiB/120s/120s及周期帽符合。portal_01 15995cycles/37.842166s/peak1673040KiB；helper oracle/build/run0.214159/20.578234/0.176434s，RSS26952/260600/null；shell_02 1818cycles/20.085450s/1445736KiB（oracle0.172765s无child样本）；portal_02 16060cycles/37.181167s/1678120KiB；默认checkpoint_07 60.599430s/1637512KiB，原五个复位诊断保持。全部有限pilot，不作full或性能投影。

短helper run/shell oracle无owned-child RSS/policy样本，只签wrapper/guard配置。portal fixture生成只有120s subprocess timeout和继承launcher，不写成owned-tree采样。-MM仍只签timeout/RLIMIT_AS。

历史helper_01/shell_01均原PASS保留，_01→02的helper增加真实RTL捕获输入/解码，shell DUT未变而fixture/实际helper刺激身份更新。portal_01 proof-only PASS保留，portal_02为新managed mask/完整capture核对身份；没有修改历史attempt。原F17 _03编译FAIL及_04 PASS继续按冻结身份保留。

## 后续

下一步实现生产wrapper真实已准入请求先于前序、实际codec/helper与控制consumer同runtime、绑定ABORT安全关闭/已提交错误结果和带归属accepted-request rearm（保留S/H/LPV/task/Ref/producer/program）。再将所有实际source读/写修改入口及F9保护接入，并实测交接后合法QUANT lease/读债；沿原顺序串行生成executor top、8/4 action与F10 24/16真实consumer，连接LN/monitor/唯一hub→实际END/唯一软件退休→Q/fullA。当前结构是有限TB门装配，不能称生产top已接通。

C009部分实施/awaiting_implementation，C008/C010待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST、M003/M004未完成。G余2338.224019s、原单重工具/所有资源帽保持，5172s组合不重启；无新agent/HLS/OOC/P&R/上板/预算。当前无运行中重工具，工程继续原授权范围。
