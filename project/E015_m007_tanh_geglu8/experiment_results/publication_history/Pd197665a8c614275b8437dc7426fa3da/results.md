# E015：当前结果

原E008独立向量：add191904、mul217304、direct-div191792；初版3/4/12拍/II1、CE hold、真实inflight reset及恢复逐位通过。AT014重分段add重新全向量PASS。AT019精确radix4 div12原191792/191965检查PASS；AT020提前exact-zero add3_z原191904/192077检查PASS。所有失败旧AT保留。

| 当前小leaf OOC | LUT/FF/DSP | setup WNS/TNS ns / endpoints | hold WHS/THS ns / endpoints |
| --- | --- | --- | --- |
| AT010 mul4 |442/120/2|+0.332/0 /0|−0.018/−0.380 /24|
| AT021 div12_radix4 |2266/828/0|+0.182/0 /0|−0.031/−3.824 /419|
| AT022 add3_z |479/207/0|−0.325/−18.649 /75|−0.043/−1.522 /81|

均0latch/0blackbox、完整约束覆盖零缺失，只有综合+opt。mul/div仅setup正；add仍setup FAIL，全部hold违例保留，无P&R/物理300MHz。旧add AT006−0.956、AT012−0.351与旧div AT011−1.464仍保留。旧report.rtl_sha256仅common ce7c文件，实际variant通过extra_sha256与read_verilog单独绑定，不冒称common SHA覆盖变体。

AT007真实Encoder0全部128行原局部WO→残差→LN→Wi→G参考，17产品、335872实际z/h、384边界和6非finite记录。AT018原42节点native SSE参考全336262输入最终等独立host libm，nodes.hex113320294B/SHAff69474c2d6d74ddb96a4fef13bd78f57132e816d0a2d6a92f8f524bac857a60。参考生成不代表RTL通过。

AT023重排原图至152edge并显式绑定新叶；AT024单lane含42节点断言编译完成8.441860s。首个512输入功能pilot AT027排队，尚未得到功能结论。add3_o把精确finite overflow提前注册，位权/符号/取消/非finite旁路说明已写source/design.md，原向量及定向半ULP邻位/正负溢出/对消验证待执行。

守卫身份窄边界：AT008–013缺启动前自身字节收据，exact loaded self-SHA UNKNOWN；候选版本仅dont_write_bytecode设置差异，生命周期逻辑相同，旧receipt不改，详见guard_identity_boundary.md。08:10:21 UTC起新AT用只读冻结guard_frozen_v1 SHA9bea7392dcd091608de2044e4fe11d25e8cbdb6eee50ad75057fd4c9d147aff7，冻结身份记录先于执行。数值/子driver/RTL/TB/输入/编译/工具与OOC证据单独保持。

8lane/G、联合SFU/FFN、总资源/布线/板测仍未验证。


---
Published: 2026-10-21T08:30:44.087482+00:00
Publication: P937367f5ff1847e6a82292b8e7077976
