# SM004修订16 FINAL→Attention消费者阶段交付

M004/SM004/E004/R001，A002工程交付；回复D-M004-REV16-AT268-01。按D-M004-ATT-CONSUMER-01及Q最终load_done、写错debt_zero细化，以模拟已发布FINAL peer验证生产reader、原Attention service、writer和新adapter的真实AXI读算写。本阶段没有接真实128行producer。

## 分版结果

- AT268冻结adapter SHA 5a44a3bc80697e25592a7b1f7701d5b3b298ddfb62d53cab9f303c90684106fe 已由主控限定接纳：同runtime head0八tile覆盖128query，8200 load/AR、8704 R、149528次服务调用、512笔OKAY B；score/prob各16384项和8192项ATT_OUT在B处与最终内存逐位匹配。RTL guard 413.674108074978s、child0/null。输入为软件捕获QKV内存，发布由模拟peer提供。
- 当前adapter SHA 6d59c3903c2f65f473f1816c0ae4548a9afc36210be1939b86320985e5840dec 相对AT268仅修Q读错出口及写错排空/rearm；reader/service/writer及算术不变。AT270页尾首burst Q RRESP错在QK前排空，随后无reset正常tile；末B BRESP错待真实debt_zero再rearm，随后无reset正常tile。RTL各61.61185588873923s和103.09305280260742s，child0/null。
- AT271当前adapter正常单tile页界/停顿：Q跨4KiB分2 AR，总1026 AR/1088 R/64 B；AR/R/AW/W/B受阻命中，VALID及字段持稳断言通过；RTL54.992271875962615s、child0/null。
- AT272只变TB至SHA a83f5f4ab7338db69212b557f12a9118f20cc73fc8ecd70b4684d5c60f763021。Q窗口最后一个R即第1088笔注入RRESP错误，真实最终load_done后QK未启动、零B，错误done消费后无reset完成下一正常tile的64 B和全输出检查。static43.71585061773658s、RTL62.811791421845555s，child0/null。另以同冻结版首笔K RRESP错回归：1 R/1 AR后错误完成，后继正常tile通过；RTL55.007858550176024s、child0/null。两次最终正常标记只属恢复tile。
- AT269末B错首次隐藏成功但后继ATT_FINAL_BAD；AT270页界尝试AW未受阻触发ATT_STALL_COVERAGE_BAD；AT266参数错误及child0含Fatal的旧失败均原样记FAIL。

AT272冻结身份见[manifest](../attempts/AT272_SM004_rev16_attention_q_last_rerr_01/source_manifest.json)，原始[末Q读错](../attempts/AT272_SM004_rev16_attention_q_last_rerr_01/guard_q_last_rerr/guard_result.json)与[首K读错](../attempts/AT272_SM004_rev16_attention_q_last_rerr_01/guard_k_first_rerr/guard_result.json)的guard、driver.log及政策可复核。AT268八tile正常PASS不迁移当前SHA；当前SHA同版八tile为NOT_RUN。

## 费用与边界

[原guard逐笔账](SM004_rev16_guard_ledger_AT266_AT272_20261015.json)计AT266–272共21笔：static/IP 7笔308.28305006958544/1800s，RTL含pilot和失败14笔1094.2193052433431273/3600s；余额1491.71694993041456s/2505.7806947566568727s，未封存。231条CPU0–3/nice19/idle政策样本零失配；host准备完整累计UNKNOWN。AT268 launch basis低记0.0003512605720733s，原文件保留，最终账以原guard纠正。修订15余额仍独立封存。

本阶段仅签模拟发布peer加head0软件捕获QKV的消费者。当前mask来自request3/gen1保存包，55word绑定及128byte mask沿合同；未证明真实128行FINAL发布或同runtime producer→consumer交接。紧凑逻辑sentinel只覆盖输出后八个64B槽，不签邻head或物理BO。其余15head、完整ATT_OUT发布、完整Encoder/模型、Host/HBM、联合资源/Fmax与全请求首错等价未验。当前adapter共同reset及独立AXI reset无新增实测。下一最小接口边界是producer真实全128发布且双方读写债全零后，复用reader/writer交接FINAL描述符并保留norm；本报告不启动后继合同。
