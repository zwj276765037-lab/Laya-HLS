# E003：R003当前结果


## 2026-10-12 真实 LayerNorm generated master→monitor/hub→source lease

`E003/R003/layernorm_producer_portal_06` 的 static、rows1 pilot、完整 rows16 三段均为 **PASS_SCOPED_RTL**。static 55.061775s/峰值 2077580KiB；pilot 20.786439s/47267cycles/峰值 856556KiB；完整16行 245.157115s/655511cycles/峰值 856796KiB。三段 child0、trigger null，真实launcher/policy均核CPU0–3、nice19、idle I/O和MemAvailable>192GiB。

实际生成 LayerNorm engine 与五个原浮点 IP 连接持久 AXI monitor/hub。BEGIN八拍响应完整消费后才允许producer请求；真实source AR/R=16/1024，destination AW/W/B=16/1024/16，唯一有效WSTRB总量65536B，八拍completion携实际helper提交量65536B及源消费量65536B。测试台逐位比较全部16384项独立Python binary32 LayerNorm gold；受控提前END至末B及完整completion/fence后才返回。诚实rows16诊断owner完成PUBLISH后，全身份source query及原子lease取得/释放通过，最后owner/lease/债务归零。

本次同层级no-wave pilot速率参与启动前成本判定：47267/20.786439=2273.934517 cycles/s；按16行参考工作量756272cycles和1.5系数，投影499s，低于3600s。该参考估计不是已证明的组合周期上界或硬件性能。full实际245.157115s。输入manifest SHA256=`83aa4a3446f0886dd72be6ea3b675b2346d853a96d06139f5c8a9e3a417b48d9`，receipt=`7b7347fc6f8f5e81b06ce8330430c938889318f5671d0de57672b138dd807ded`；核查文件SHA256=`f4baaafdd5ec9d0efd75e64b7b0056d6addce6718a28390a9e31e642d9eadca7`。382/382引用、112/112 current、frozen、pair及model header→canonical包一致。

旧attempt全部保留：_01 ROM DAT未在xsim运行目录落位，pilot120.364733s timeout；_02已无DAT警告，但无AXI读写即先completion触发断言，另静态确认SV包build tag与实际engine头不符（未捕获该完成帧的status）；_03统一身份后完成7行末B，120.337284s timeout；_04单行算术/END/gold后source query检查FAIL；_05完整16行算术/END/gold后同检查FAIL，241.276650s。_05→_06共同冻结闭包仅TB改变：下降沿驱动valid并稳定采样grant，完整工作量/gold/DUT未变。_04没有单独复验rows1 query；此前白名单归因证据不足，现按测试台采样问题记录，不宣称格式拒绝。

该入口的caller帧由TB控制，提前END携冻结成功提交量，并在终态核它与真实completion一致；尚未证明生产caller从completion构造END。source-query lease在本次未接真实QUANT消费者读流；仅producer真实算术和写口物理链已运行，未签QUANT/fullA数值或真实sequencer/adapter的depth2并发。owner仅16行，不等于完整S64/S128 tensor发布。多窗口/owner/role/QKV、软取消/失败恢复、普通/GATE切换、LOAD/MATRIX、最终13BO top、完整CPU/实际CSim、完整硬件请求及联合资源/性能仍待。partition registry仍是integration_under_test，表示生产整体尚待这些出口。

L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成保持；无新OOC/P&R/上板，G OOC余2338.224019s不变。现LayerNorm入口已用当前pilot成本判定，旧gate_split runner的当前pilot成本修复仍需单独落实，5172s组合profile不重启。


---
Published: 2026-10-12T06:40:59.662522+00:00
Publication: Pc12e05ded50b47cbb482ec55b17aabad
