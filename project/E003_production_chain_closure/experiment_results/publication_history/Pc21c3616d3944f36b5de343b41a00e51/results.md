# E003：R003实际进展

codec_01严格C编译、负例和独立Python1536B逐字节oracle PASS。transport_05实际RTL PASS432cycles、accepted4/retired5/stale1；受控service endpoint，仅transport范围。

matrix_binding_03静态与RTL PASS859cycles，7真实resident commands/responses，6类活动取消和K256/N2恢复，实际AW/W/B2、4独立零F32。A/W为受控诊断lease端点，不是物理cache模型链；matrix01/02失败保留，修复接受后尚未出现ret_valid的W读债务。

base_mirror_02 PASS595cycles、13roles、26初始words、全部16WSTRB、61native writes、3snapshot；比较真实历史生成pointer控制器，尚未绑定新generated acceptance。

resident_regression_01当前正常路径static/pilot/full均PASS；full454.920886s、1424576KiB、guard0/null、48862cycles。4原distinct预量化A rows K2624/N1024，10496stripes、41984rowPS、335872lane-group、4096独立F32输出、512真实AW/W/B及最后B退休。实际fullA/dualW/nativeFP/local ledger闭合，未覆盖同runtimeWi/G/quant或生产13BO。

axi_owner_02局部PASS134cycles，AR4/R8/AW3/W6/B3；返回反压、W先AW、未接受AW、并行读写、安全fault clear与early-LAST恢复。01保留TB握手采样失败。真实AMD512/128至32宽度转换验证进行中；首512轮写退休断言失败，保持失败证据与通过标准，正在定位。

L0 PARTIAL；L1仍缺current generated caller/13BO外层、LOAD/quant/G物理hub。quant/G所需多个Context/future Ref的显式版本化映射尚未核定，不能猜身份或静默占保留位。L2–L5 NOT_RUN，之后继续M004全模型/完整请求性能/资源。历史FAIL全部保留，无新增OOC/P&R/板运行。


---
Published: 2026-10-11T09:18:37.078511+00:00
Publication: P103a0d0052ea4b5b93bdbe3c07a33edd
