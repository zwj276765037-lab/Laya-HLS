# Graph program消费通知主机补充审核

回复：`graph-program-consumption-host-milestone-20261012`  
审核：`R-SM003-GRAPH-PROGRAM-CONSUMPTION-HOST-20261012`  
范围：M003/SM003/E003/R003，D-M003-GRAPH-LIFECYCLE-SPLIT-01。

**接纳graph_program_top_host_02的PASS_SCOPED_HOST补充：末拍同次调用的抽象消费通知保持、延迟消费门控、所测早到通知忽略，以及request904完整结束和软件stream清空成立。无新增阻塞修复项，工程继续真实executor/shell准入及三层消费连接。** 不把本次主机锁存等同实际HLS时钟级通知链闭合。

主控核32组current/frozen/声明pair（31文件加合同）、75/75 manifest/receipt引用与五个交付SHA全匹配。相对_01只变更program top、TB和runner；512B oracle逐字相同，schema及既有codec保持。三命令exit0，oracle/build/run为0.066637/3.924084/0.011004s。launcher CPU0–3/nice19/idle I/O，MemAvailable430165964KiB>201326592KiB；子进程24GiB RLIMIT_AS/1800s timeout，不扩为owned-RSS/120s进度guard。详见[核查记录](graph_program_consumption_review_20261012/verification.json)，主控未运行编译、仿真或HLS。

代码在LGR1最后一次write_nb成功时保存result_consumed，下一WAIT消费pending并清除；早于这一位置的通知不被锁存。TB在901前三拍已取走后，给最后写拍所在host调用一个true，随后取走该末拍；下一次调用输入false仍能放行902。这证明抽象输入保持，通知由TB提前指定，不是由真实FIFO read握手测得。

902的完成接收期间注入一个早到脉冲，随后LGR1完整入队且903已排队，24次调用仍不读后继；实际软件取走结果并给通知后才处理903。903的零ordinal拒绝保持原消费门。904随后成功LAC1→成功LGR1→消费通知完成，末尾四条stream确实为空。因此可记录三个合法command完整处理（其中902为安全错误）和一次前置拒绝；它们不是三个数值成功或实际Host完整请求。

“早到旧通知忽略”限定上述一个脉冲时点；当前无tag布尔不能自行分辨恰在末拍或WAIT到达的旧通知/持续旧电平。真实shell仍须从当前LGR1 consumer四次实际握手产生持久通知、绑定唯一pending请求并明确清除/确认，跨生成HLS多周期调度不丢失、不串到下一请求。后续实际连接覆盖末1/2拍停读、末拍消费邻近状态切换、延迟/持续通知及后继排队；本次不要求重复无关主机成功运行。

按原计划继续executor/shell唯一request/model/base/source准入，LGR1、LAC1及F10 LTC1三层真实消费门控，旧active action内部清理续行；host组合后以当前身份生成有限program/executor分区，接实际LN master→monitor/唯一hub→source lease→Q/fullA。完整PC/family、取消/部分提交/旧返回恢复、当前完整CPU/实际CSim及最终13BO请求仍待。

旧_01及审核保留。C009部分实施/awaiting_implementation，C008/C010整体待验证；既有限定关闭不扩大。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成。G余2338.224019s、原帽/单重工具保持；5172s组合不重启，无新OOC/P&R/上板、agent、预算或逐项审批。
