# QAR0补证：默认EXT_QUANT=0受影响静态配置

补`measurement-first-QAR0-scoped-result-handoff-20261014`。在不修改AT035冻结DUT、数值、fixture或原full的情况下，AT036以AT035同SHA的bridge为实际Vivado simulation top，真实compile/elaborate默认`EXT_QUANT=0`参数。结果PASS_SCOPED_DEFAULT_STATIC：53.105357s、child0/trigger null、峰2212056KiB、31条CPU0–3/nice19/idle policy匹配；106条继承冻结身份及新Tcl SHA核对无差异。它满足QAR0合同的默认分支受影响静态配置检查，不是新的G-only动态数值证明。

原[QAR0阶段报告](QAR0_shared_quant_admission_20261014.md)、模块结果及E005三摘要已同步这一限定事实。证据：[AT036收据](../attempts/AT036_QAR0_default_static_01/receipt.json)、[原guard日志](../attempts/AT036_QAR0_default_static_01/guard_static/driver.log)、[核验](../attempts/AT036_QAR0_default_static_01/verification.json)。QAR0主结论与M003/M004开放状态不变；当前无本项目重工具。
