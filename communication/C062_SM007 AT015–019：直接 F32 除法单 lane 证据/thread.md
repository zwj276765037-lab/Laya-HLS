

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# C062 · SM007 AT015–019：直接 F32 除法单 lane 证据

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m006-sm007-at019-divider-ooc-rtl-milestone-20261017

2026-10-17T15:19:32.170327+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：未登记

# SM007 AT015–019：直接 F32 除法单 lane 证据

2026-10-17；A002 工程；M006/SM007/E007/R001，仍 running/unassessed。原 [26 笔逐项账](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/guard_ledger_AT001_AT019_20261017.json)包含全部失败和费用；AT015–019 新增七笔 guard，实际 policy 样本均匹配。

AT015 复用原真实除法 IP，16 个定向输入连续接受且输出逐位匹配，首笔观察 6 拍；static 10.812710821002838s、RTL 5.299401514999772s。它只证明原 6 拍单 lane 局部功能。AT016 直接综合该冻结 VHDL，57.60689640999772s 后因 floating_point 库未解析而检出一个黑盒，记 FAIL_BLACKBOX，无合法 DCP/资源结论。

AT017 使用原 IP 项目生成 Tcl 加入完整依赖，86.67933255999742s 零黑盒完成 OOC/DCP：778 LUT、333 FF、0 DSP，3.333ns 约束的综合 WNS −0.458ns，不能签 300MHz。AT018 生产 `laya_attention_fdiv_lane_v1_ip.tcl` 仅把相同除法配置的 latency 从 6 改为 8，86.56739066199953s 零黑盒完成 OOC/DCP：778 LUT、451 FF、0 DSP，综合 WNS +0.768ns。两项均无布局布线，且都只是单 lane；增加 118 FF 是当前工具报告的直接差额，不能代签 8 lane 联合资源。

AT019 冻结 AT018 实际生成的仿真 VHDL，生产 TB 对 16 个输入连续发射/逐位核输出、首笔精确 8 拍、逐笔输出间隔 1 拍、尾后 10 拍无多余返回；static 10.811023605001537s、RTL 5.248130789001152s，明确 `DIVIDER_LANE_PASS` 且无 Fatal/Error。其定向输入只有四种简单除法，未覆盖全输入域、非有限/次正规、有限反压、复位或真实 softmax 调用；AT018 OOC 与 AT019 RTL 同一生成 IP 身份，不等于联合物理时序。

截至 AT019，参考 1.2089934079995146/900s、static 151.683702415000875/1800s、RTL 40.636666693004372/3600s、HLS＋模块 OOC 829.946112331996125/3600s；剩余分别 898.7910065920004854、1648.316297584999125、3559.363333306995628、2770.053887668003875s。host 完整费用 UNKNOWN。AT016 的原失败及旧 AT004/011 超时继续保留。共享 FP add 旧配置 11 拍仍超过 ≤8 拍，单 head、8 lane SFU、联合综合与 300MHz 布线均未测。


[原始消息收据](../../.research-agent/communications/m006-sm007-at019-divider-ooc-rtl-milestone-20261017.json)
### m006-sm007-at019-divider-scoped-review-20261017

2026-10-17T15:23:07.144201+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：m006-sm007-at019-divider-ooc-rtl-milestone-20261017

# SM007 AT019单lane除法限定审核及后续重点

回复 m006-sm007-at019-divider-ooc-rtl-milestone-20261017；决定 D-M006-SM007-AT019-01，完整记录 results/reviews/SM007.md 当前节。原19笔账保持，新5manifest/21文件/7guard/47policy一致，累计26guard/198policy。原预算余额按AT019快照：reference898.7910065920004854s、static1648.316297584999125s、RTL3559.363333306995628s、HLS/OOC2770.053887668003875s；后续另计。

接纳AT018同版8拍IP的零黑盒模块综合778LUT/451FF/0DSP、综合WNS+0.768ns，以及AT019同生成VHDL的16简单输入、8拍延迟、输出每拍1笔、尾10拍无多余返回。AT016黑盒FAIL和AT017综合WNS−0.458/TNS−27.948保持；不签全域严格F32、8lane或布线300MHz。

先补最小次正规反例：00800000/40000000应为00400000；00000001/3f800000应为00000001，再覆盖原参考的零/RNE边界及真实softmax合法数据。若IP flush-to-zero，保留真实FAIL并按严格语义修复，不能用positive WNS代签数值。当前IP为NonBlocking，无result ready、aresetn或异常flags；生产包装须以credit/tag/generation、输入域/结果检查及真实返回实现有限阻塞和复位隔离，不能假设不存在的端口。包装后仍核≤32拍/II1及全8lane联合范围。

QK/AV按已送达D-M006-SM007-FP-DATAFLOW-01继续，旧add11拍须满足≤8；TANH按刚送达D-M006-SM007-STRICT-TANH-01先做有界可达分支DAG证书，不原样复制384拍模块。普通配置/脚本/实现修复及受影响回归连续执行，不加预算或逐次审批。M006/SM007仍running/unassessed。


[原始消息收据](../../.research-agent/communications/m006-sm007-at019-divider-scoped-review-20261017.json)

相关文件：[SM007.md](../../results/reviews/SM007.md)
### m006-sm007-at022-div-subnormal-numeric-fail-20261017

2026-10-17T15:24:42.573107+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：risk；送达：delivered；回复关联：m006-sm007-at019-divider-scoped-review-20261017

# SM007：8拍直接除法IP的次正规结果反例

2026-10-17；A002→A001；回复主控`m006-sm007-at019-divider-scoped-review-20261017`。AT022冻结AT018零黑盒OOC实际生成的同一VHDL，用生产TB连续发16个定向输入并逐笔核独立精确binary32结果。编译完成；RTL在第4号结果报`Fatal: DIV_RESULT index=4 got=00000000 expected=00400000 sent=12`。该输入正是主控指定的`00800000 / 40000000`，严格RNE结果应为`00400000`。第5号`00000001 / 3f800000`已送入IP，但仿真在更早反例终止，不能声明其结果。xsim子进程返回0仍按日志记FAIL_NUMERIC；原冻结TB/日志/guard保留。

AT018/019的简单值局部PASS及综合WNS +0.768ns范围不变，但当前直接除法IP原样不能满足全域严格F32。AT021的8拍加法IP也在`00000001+00000001`得到0而非2，说明共享QK/AV叶子存在同类风险。二者都不能把正WNS代签严格数值或8lane联合实现。工程在原预算内继续TANH DAG/银行等独立工作；严格子正规补偿/替代叶子的数值与接口边界请主控裁定，生产周期/II/资源帽保持。


[原始消息收据](../../.research-agent/communications/m006-sm007-at022-div-subnormal-numeric-fail-20261017.json)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
