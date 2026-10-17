# 修订21 AT364真实独立生产串联里程碑

2026-10-16；M004/SM004/E004/R001。按 D-M004-LN128-WPREP-Q16-01 继续实施，未收束本段。

同版生产组合：上层 e2be4e1e…、下层 30816465…、唯一W服务 519a2ccb…、原cache 6d13fae4…。AT364 frozen manifest 绑定全部实际fixture；AT358只增量重编cache/W服务及串联TB，AT364复用其已编闭包并仅重编TB。独立TB直接实例化一份上层（内含唯一下层）和一份实际W服务；AXI peer提供真实raw/gamma、W载荷及STATE1内存返回，未预填norm或逐行发生产命令。

AT357独立上/下层LN16 pilot 37.31625036895275s通过；同串联层次AT363 LN16前缀40.05343775637448s通过。AT356当前W服务冷载成功6.02931497246027s，三路24576/24576/3072 R、8 AUX R、98304次scale检查，单独协议/scale/混合错误分类短例各通过；AT362当前下层用独立保存norm合法逐行局部Q16样本25.696477884426713s，16行512响应、4352word最终复扫，前四行Q/scale对原独立gold逐位。采用直接的串联LN16样本，成本式2.5×(8×LN16+W+Q16)=880.3832372697070575s，启动前RTL余额足够1800s。不同层次成本没有冒充串联延迟。

AT364真实单runtime主例 guard_rtl_full_chain：302.6612185873091s、child0、trigger null，且日志无Fatal，`CHAIN_LN128_PASS`及`CHAIN_A16_PASS`终标。128行LN、131072个norm真实W握手和最终STATE1复扫逐位、8192 source R与8192 OKAY B、gamma256 R；continue在真实保留上下文握手后，W三路24576/24576/3072 R、AUX8 R；随后STATE1 1024 R逐位对norm、Q入口接受计数16384、512同步Q响应、512个八bank Q写拍和256个scale-pair写拍、4352word bank保持/最终复扫，前四行Q与scale对同请求原独立保存gold逐位通过。r4..15只签行退休时bank快照在后续行保持；尚未逐位核STATE1到Q入口或叶子响应到bank的数据映射，不能签其传递正确或独立数值gold。最终A16_READY仍保留norm；本独立TB的request_done/RAW/FINAL为常量占位，不能作为父请求发布行为证据。

AT363相同生产SHA先达到A16，但TB在最后退休位同沿检查自己的观察计数而Fatal；AT364只让TB多采一沿并加诊断，原AT363 Fatal与306.6056573148817s费用保留，不把exit0改为PASS。AT359旧TB层次路径编译FAIL、AT360 core重图120s静态timeout、AT361脚本相对路径FAIL也保留。当前账截至AT364：static488.59907988831400432/1800s，RTL736.4435322098433930/3600s；余额1311.40092011168599568/2863.5564677901566070s，host完整UNKNOWN。原修订20余额未用。

父完整请求top的修订21源码仍待同版重编展开；真实父请求全128→A16、父exec100/Q16委派、交接反压、错误/恢复、共同reset等均未由上述独立主例代签。下一步为最终同版父top及受影响短例；不启动HLS/OOC/P&R或新gold。
