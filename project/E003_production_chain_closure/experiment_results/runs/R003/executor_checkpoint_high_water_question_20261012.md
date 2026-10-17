# Executor真实checkpoint高水位入口问题

M003/SM003/E003/R003；沿D-M003-GRAPH-LIFECYCLE-SPLIT-01与D-M003-EXECUTOR-BOOTSTRAP-SOURCE-01。F16实际解码/adapter已有限通过，guarded LN_05已在正常四窗口hub/monitor prelude后取得真实1AR/64R、1024 gold、F9同consumer、完成派生END/一次task5退休。默认兼容仍串行收尾，随后交付当前身份。

准备独立executor top时发现：LBR1 v1 768B只返回source绑定，未返回正常前序形成的typed/task及LPV/producer高水位。现bootstrap host_02在软件runtime用正常四次预约/退休形成task1–4，然后续NORM task5–8；guarded LN_05的真实hub前序同样已使用task1–4、LPV event1–10。若硬件top仅真实LYRQ/LYMP admit→snapshot→mirror，然后start NORM，初始allocator会从task1/event1发出，与真实hub已有下界冲突。固定写入4/10或用SOURCE_READY_PROOF代替事实均不符合现合同。

请明确首个真实checkpoint诊断的唯一入口：

1. 可否在唯一hub完整绑定snapshot的新版本/有限扩展返回实际typed_last_task、last_event_seq及必要source/目标Ref已使用下界，由executor仅同步预约下界、保留本段tasks_retired=0，不从task最大值虚增退休？hub当前没有producer request高水位，受控前序走正常AXI writer而未经过LPE1，不能编造这项；真实producer/executor已有编号应由唯一shell/executor持有并延续。
2. 或采用有界已发生事务历史握手，让executor对实际完整绑定前序BEGIN/END/完成逐项形成正常退休及高水位，再开始snapshot/action；需要冻结内部格式、确认不形成第二退休/发布权威。

优先建议采用只读snapshot提供真实hub可知下界，并明确producer/action编号仍由同一持续executor保存；首个前序无LPE1事件诊断须诚实标明。若这种导入仅允许诊断而不适用于完整图，请给出准入限定。当前owner_max_epoch对目标Buffer也可能保留旧下界，不能仅镜像source epoch就宣称任意旧request/恢复均安全；未能真实取得的目标下界应拒绝或沿同runtime原executor保留。

这是生产bootstrap接口职责问题，不请求增加资源/审批。独立action端口/top脚手架与现有兼容验证继续；不启未明确准入的executor HLS。原guard/预算/G余2338.224019s保持，无新agent/OOC/P&R/上板，5172s组合不重启。
