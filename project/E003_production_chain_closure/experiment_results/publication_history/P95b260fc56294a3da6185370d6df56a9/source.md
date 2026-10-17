# Executor action收发、真实请求准入与只读hub snapshot阶段交付

范围M003/SM003/E003/R003；沿D-M003-GRAPH-LIFECYCLE-SPLIT-01及D-M003-EXECUTOR-BOOTSTRAP-SOURCE-01，回复executor-bootstrap-source-answer-20261012。

## 结论与边界

四项冻结结果分别为PASS_SCOPED_HOST、PASS_SCOPED_HOST、PASS_SCOPED_RTL_SNAPSHOT_ONLY、PASS_SCOPED_RTL_COMPATIBILITY。没有executor HLS top、真实action消费shell、source保护或生产program/adapter/LN/hub整链结论。本轮没有新HLS/OOC/P&R/上板，当前无重工具。

- task_lifecycle_port_host_02：8/4拍action收发层围绕共享FSM，后继descriptor两拍已排队时，末2/1拍软件stream停读各12次调用保持旧action；本地LINEAR、旧ordinal、错source version拒绝，无新事件/退休，坏帧头/semantic kind隔离不产可信完成。实际C++ program→port/FSM→adapter和受控远端服务完成B1/S64四窗口四退休并清streams。该项请求/model/source仍由TB设定，不签RTL depth2或物理恢复。
- executor_bootstrap_host_02：先核旧本地action/tracker/reader及受控shell物理/结果fence，真实解析独立832B LYRQ、实际选定aux.bin前128B LYMP；十个请求/模型负例均无新有效准入。LBS1/LBR1均768B/12拍，独立Python逐字oracle1536B，23个头/语义/绑定拒绝复位输出，合法绑定错误保留。snapshot seq独立、溢出拒绝；旧proof/base切换/未持source guard/cancel均拒绝且不发LGP1。logical镜像直接缓存唯一hub已核事实，不调用CLAIM/cover/PUBLISH，不增owner统计。
- 同host runtime四个受控先前TaskDone经正常reservation/retirement函数记入task1–4；checkpoint不重新begin/admit，NORM真实FSM再恰退休task5–8，action退休量4，最终总统计8。snapshot与远端响应及physical/guard输入是host fixture，没有前序encoder算术或hub物理证明。bootstrap尝试发生在真实活动action/tracker期间，拒绝保持绑定和高水位，该action继续完成；同session request1102随后经真实LYRQ重新准入、snapshot seq2，protocol/action高水位保持。旧action错误cleanup续行仍沿既有FSM限定证据，本项不签bootstrap等待时新硬件cleanup恢复。
- bootstrap_snapshot_rtl_02：唯一hub新增默认禁用可选只读接口，读取原owner/model/descriptor/window数组，无第二发布表。受控encoder_00_out式HIDDEN bank0/region0 stage2/layer0，完整B1/S64/D1024/F32、old_ref NONE，通过正常CLAIM→四个BEGIN/实际AXI monitor写/END→PUBLISH建立；64 AW/4096 W/64 B、262144B，没有层级写owner或TB READY。数据是受控master地址pattern，不是encoder数值payload。
- snapshot RTL实际核absent/unpublished（含未完成四窗口）、错request/generation/epoch/role/rows/model、旧scope及末B/未消费END返回阻止准入、受控shell source-read debt/adapter/base错误、旧query seq及response反压稳定。已发布活动owner存在时允许成功，未要求domain_drained。query不改变10个生产事件、4次typed终态和owner发布；响应持有期间LPV变更不被接收。消费后正常INVALIDATE，再query正确拒绝。
- 本RTL只签查询事实；没有从snapshot接受到实际producer读取全过程的排他门/通用lease。snapshot消费后的source变更能发生，host接受要求guard=true只是接口合同及负例，不能当真实硬件保护。下一步在唯一shell接完整source变更/旁路写门控或显式原子lease，核启动前重绑定/cancel、实际AR/R与完成/fence/消费释放，再生成executor。
- generated_store_monitor_10：受影响默认禁用snapshot的原RTL兼容回归通过，保留原部分失败、末B、活动取消/反压与同session恢复范围，旧限定结论不扩大。



---
Published: 2026-10-12T13:39:18.611170+00:00
Publication: Paa8387958ba54321ac2abcbea9c0c309
