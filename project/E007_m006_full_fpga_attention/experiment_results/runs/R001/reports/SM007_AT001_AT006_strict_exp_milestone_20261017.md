# SM007首个硬件结果：strict expf 调度与OOC风险

A002已按M006/SM007启动E002生产修改与E007/R001新证据，旧M004仍暂停。生产 `attention_exp_bits.cpp` 只增加HLS II1流水并去掉原单份f64 add/mul分配限制，不更改gl​ibc 2.39 expf位算法或独立gold；当前SHA `54ff1196824eebbb638dc0f45b97f4113ec4e6d7a7e55ec18e6662a3717939f1`。目标part为项目配置 `xcu55c-fsvh2892-2L-e`，300MHz；板卡身份尚无实测。

AT001原单lane HLS II2–210；AT002加流水但保留资源限制得II6；AT003同算法撤限后 HLS II1/167拍，估算96DSP/88455FF/74634LUT，时钟估计2.425ns＋0.90ns uncertainty。AT005冻结独立libm参考16396个expf及200000个F64基本运算CPU位比较通过；AT006同版生成RTL连续接受12个directed样本、12个逐位返回，首笔实测167拍。局部数值与II1在该定向窗口成立，不签完整S128、8lane或全head。

AT004同版单lane Vivado OOC固定120s pilot停于面积优化，guard timeout/-9、峰值owned RSS5361360KiB；无DCP、实际资源/Fmax。HLS数值不能乘8作最终资源判断；96DSP单lane提示8-lane严格EXP与另外8-lane TANH/divider及Q/G合计896DSP帽的风险，需联合实测。7笔guard/57条已观察policy零不匹配；参考1.2089934079995146s、static10.30310974799795s、RTL5.411835432001681s、模块HLS＋OOC177.792485506000955s，host完整UNKNOWN。详细原收据、失败及SHA见[机读账](../guard_ledger_AT001_AT006_20261017.json)与[E007摘要](../../../summary.md)。共享256lane FP/phase/bank以及8lane、完整单head/16head均尚未实施或验证，工程继续原预算内推进。
