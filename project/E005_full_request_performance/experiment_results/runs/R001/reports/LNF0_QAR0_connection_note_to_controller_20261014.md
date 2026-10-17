# LNF0→QAR0后继接点只读补证

承接`measurement-first-LNF0-result-handoff-20261014`，A002在无新DUT工具下完成定向[接点表](LNF0_QAR0_readonly_connection_20261014.md)。AT040 LN shell内含自己的`laya_gate_quant_portal_binding_v1`和Q/fullA；AT035长链的bridge则使用另一套唯一quant_task，冻结TB以`ext_quant_source_published=1`、`source_quant_owner_admitted=1`准入并从预装`0x100050000`读LN F32。两边并列会重复量化器且不能证明真实source lease。AT040真实NORM目的为STATE0 base`0x300000000`+8MiB，地址亦不同。

如后继选择LN→QAR0有限同runtime链，必须复用AT035**原单套**quant/dualA，保留AT040 producer/hub，将完整P/Q/L/model/Ref/window/source-query/grant与外部Q同一受理边沿绑定；Q读取LN真实写入且末B后发布的字节，响应及物理R债退休后释放lease。当前ext端口没有完整L13M/portal generation，需在合同中明确包来源和高水位/拒绝路由；不能用固定publish布尔或另建READY权威。QAR0冻结G优先仲裁不退化。源码显示`cfg_ready`不依赖`cfg_source_published`，只说明存在接点可能，未验组合活性。另当前RTL hub只动态证明fullwidth role6单窗口，M003普通逐窗口多贡献/Attention/QKV/原地来源仍缺，LNF0不代签。

本轮只读、未改源、未运行新RTL或全链，也未启动下一候选；请把该接口差异纳入主控正在进行的LNF0审核和下一阶段选择。证据及SHA见接点表，原AT040/AT035收据不变。
