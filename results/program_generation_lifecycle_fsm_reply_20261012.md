# Program生成、真实结果消费与lifecycle FSM审核

回复：`program-generation-lifecycle-fsm-milestone-20261012`  
审核：`R-SM003-PROGRAM-GENERATION-LIFECYCLE-FSM-20261012`  
范围：M003/SM003/E003/R003，D-M003-GRAPH-LIFECYCLE-SPLIT-01。

**分别接纳 graph_program_hls_01 的 PASS_SCOPED_GENERATION、graph_program_rtl_01 的 PASS_SCOPED_RTL_PROGRAM_CONSUMER，以及 task_lifecycle_fsm_host_02 的限定 PASS_SCOPED_HOST。无新增阻塞修复项。** program已取得真实生成及有限请求结果消费的RTL证据；executor仍只有共享FSM主机证据，bootstrap、executor top/action consumer及真实LN/hub链继续待验。

主控独立核211/211 frozen/声明pair、206/211 current，2264/2269 manifest/receipt SHA引用相符；五处live差异恰为已披露的generation两项、FSM三项catalog JSON登记。diff仅新增/更新登记及格式，冻结DUT/TB/gold/生成物未变；RTL123组无漂移。十个交付SHA一致。详见[核查记录](program_generation_lifecycle_fsm_review_20261012/verification.json)。主控未运行编译、仿真或HLS。

生成工具真实exit0，109.026356s、peak3379604KiB；73份Verilog/11份DAT。实际top header的12根FIFO信号及ap_clk/ap_rst/cancel/result_consumed齐全，无顶层ap_ctrl_hs。原syn top、交付副本和RTL冻结top同SHA。六源闭包不含executor/adapter/旧action树。HLS表BRAM18K3/DSP1/FF16819/LUT60478/URAM0仅作估算，不签联合资源或物理性能。

RTL shell从同一LGR1 FIFO真实consumer四次握手产生持久通知，下一accepted-command首拍真实读取才清除；请求四拍后门控，结果末拍消费后下一周期开放。TB实际四个depth2 FIFO、末两拍和末一拍各停读12周期、后继两拍已排队时，当前command_reads边界、后继action零增量、输出稳定均有断言。901成功、902安全错误、903前置拒绝、904成功恢复在同runtime完成，四FIFO最终为空。独立Python按固定布局/冻结tag生成逐字fixture；LAC1由TB提供，不是实际typed退休或算术成功。

static/pilot/full分别48.662357/5.766016/6.577758s，pilot6682/full22415cycles；四段含HLS的guard均child0/trigger null，实际子进程CPU0–3/nice19/idle I/O、MemAvailable、RSS/墙钟/进度保护符合原帽。11份DAT冻结与落位逐SHA相等。runner在full启动前以本次pilot计算40092cycles/34.596095s，原1M/3600s准入成立；该估计不代表完整图性能。

FSM使用持久action/window cursor及共享Phase，生产12源闭包排除旧同步execute树、adapter及外部codec；host另链接实际C++ adapter和受控远端。六例核四窗口四退休、PUBLISH首错后同action/同INVALIDATE键收束、本地producer拒绝零外发/issued0后同END键等待→终态、坏头/错END隔离无第三次END及不退休、非终态BEGIN保留软件reader/tracker。completion_consumed前再次start不改变高水位。错误隔离没有恢复出口的证据，不签硬件安全恢复；活动取消只签本次producer未外发分支，部分已提交失败仍待。

FSM build/run10.041669/0.117152s均exit0；host只有1800s timeout/24GiB RLIMIT_AS，不能写成owned-RSS/120s语义guard。_01编译FAIL保留，_01→_02共同源只改测试四处laya::detail限定名，DUT与断言语义相同。既有F6–F13关闭不自动扩大到未测的新FSM路径。

继续executor/shell唯一请求/模型/来源准入、独立executor top和LAX1/LAC1真实8/4拍consumer门控，并把F10接到executor真实LTC1 consumer。随后接program→executor→adapter→实际LN master/monitor/唯一hub，由实际completion构造END并唯一退休，再接既有Q/fullA独立gold。完整PC/family、全tensor/多窗口、活动cancel/部分提交/旧返回恢复、当前完整CPU/实际CSim及最终13BO请求仍待。

登记小修：production_hls_partitions.json中program的shell.validation仍写“shell depth2 RTL pending”，与新增evidence/state不一致。下次metadata更新改为本次有限program/受控LAC1范围通过，同时保留executor准入、完整链路待验；无需重跑工具或改历史attempt。

C009部分实施/awaiting_implementation，C008/C010整体待验证；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成。G余2338.224019s、原帽/单重工具保持；5172s组合不重启，无新OOC/P&R/上板、agent或预算。后续bootstrap source接口问题另以独立架构决定直接答复。

