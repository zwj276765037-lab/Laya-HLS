# E010：R001关键结果摘要

R001完整S128单head真实QK与独立AV功能/局部周期PASS，包含最后DONE/read响应债交接修复和同版回归。独立AV使用原保存prob，未签softmax或完整Attention。Decision/16head/父图/OOC/P&R/板测NOT_RUN。

| 当前修复版 | 全部逐位结果 | 服务周期 | 原始证据 |
| --- | --- | --- | --- |
| AT020 QK normal | 16384score公开PS读回、128max、全部产品/六级树/scale/bias | done4187≤4352；首score90≤160 | [log](runs/R001/attempts/AT020_fixed_core_normal_qk/guard_rtl/driver.log)、[guard/receipt](runs/R001/attempts/AT020_fixed_core_normal_qk/receipt_rtl.json) |
| AT021 independent AV normal | 8192context公开RAM读回、1048576产品及1048576逐key partial | done4508≤4608；首context4251≤4288；反馈max11≤24 | [log](runs/R001/attempts/AT021_fixed_core_normal_av/guard_rtl/driver.log)、[guard/receipt](runs/R001/attempts/AT021_fixed_core_normal_av/receipt_rtl.json) |
| AT018/019 QK/context handoff | DONE消费时仍held的公开response保持并真实消费；债推迟lease release，禁止新read；各自完整输出/中间值/正常周期仍PASS | QK4187；AV4508 | runs/R001/attempts/AT018_done_read_response_handoff_fix及AT019_context_read_response_handoff_fix的guard_rtl/driver.log、receipt_rtl.json、source_manifest.json/build_reuse.json |

AT017实际复现旧core HANDOFF_SCORE_RSP_LOST_OR_EARLY_RELEASE（FAIL14.788343109015841s）；修复仅使RELEASE继续转发已接受公开score/context响应并禁止新read，未清债或吞响应，FP/QKV/storage接口不变。AT003另有TB start采样竞态FAIL，AT004仅修TB同monitor事件采样；两次失败冻结保留并计费。

未变依赖原身份覆盖：AT006滑窗局部独立参考PASS4187/90；AT007 QK有限停顿4529/92；AT012 AV有限停顿4755/首4486/反馈12（停顿周期单列）；AT009 QK abort128根→128真实提交/219拍；AT013 AV abort128根→128提交/157拍；AT010叶子在途reset后request4/gen2完整重装并QK PASS4187/90；AT011先物理phase1但选逻辑phase0，rank10000004007f0002、element40898，所有4096根/树/score债退休后status1。原head局部诊断不签whole-layer首错。AT014及当前主例公开response hold3/done hold3/generation拒绝PASS。AT004/005原已核接纳局部身份保留。

真实访问：QK Q128/K4096同步读、PS4096×4F32写ack和2048×8F32公开读；AV V128/G4096×4F32读，PS4096反馈+32退休读（各256F32），4096×256F32写ack，context256×32F32写ack和读回。全部payload经公开生产口，无层次赋值/债强制。逻辑容量PS1024×16/G256×64/context64×2048不冒充全context逐址扫描；QK实际覆盖全score PS、AV覆盖全prob G及head0 context，AT001另检查首尾bank/地址、read优先/hold/rebind/旧generation/reset response debt。

[分段实测cycle](runs/R001/stage_cycles.json)：QK Q读2..3851、根8..4103、各树层/scale/bias逐级返回、末PS ack4185、done4187；每Q组4个accept边沿。准备到accept QK772拍/768个32F32写，AV2309拍/256个32F32 V写+2048个8F32 prob写（以原日志实际值为准）。初始化不计局部service周期，也不称单BEGIN端到端结果。

全部raw log/guard/manifest相对项目路径、成功/失败成本见 [账本](runs/R001/budget_ledger.json)；snapshot复用均有build_reuse.json，逐SV SHA匹配并绑定来源static receipt SHA。当前源版本/原证据适用边界见 [版本记录](runs/R001/current_version_evidence.json)。无新资源/实现频率结论。R001交付冻结后后继R002单独计费。
