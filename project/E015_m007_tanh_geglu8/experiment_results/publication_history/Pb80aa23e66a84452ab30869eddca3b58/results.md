# E015：当前结果

AT002 build完成。AT003 add3原191904向量、AT004 mul4原217304向量、AT005 direct-div12原191792向量全部逐位通过，真实3/4/12拍与连续II1；每例CE hold36拍、真实2项inflight reset和45paired-valid恢复通过。原向量来自E008独立native SSE FE_TONEAREST且FTZ/DAZ关闭，未改gold。

AT006 add3完整IO综合+opt：470LUT/201FF/0DSP/0latch/0blackbox，WNS−0.956/TNS−31.674ns、54setup端点；WHS−0.027/THS−0.833ns、51hold端点。约束覆盖零缺失，300MHz时序FAIL，无P&R。关键sub1→normal2为16级，4.171ns=logic1.429+route2.742，正在三拍内等价重分段。AT001纯SV语法失败及1.830159s费用保留。

AT007独立原真实Encoder0全128行局部WO→残差→LN→Wi→G参考完成1.998655s，保存全部中间；335872实际z+384边界+6非finite共336262个TANH向量，GELU重组等原gelu_array。真实参考生成不代表硬件通过。

单lane/8lane/G、联合SFU/FFN、整体资源/物理300MHz尚未验证。原始证据见当前R001各AT。


---
Published: 2026-10-21T07:34:13.853593+00:00
Publication: Pf97084e29e9d4bfebe56b52a990fd4bb
