# AT073 TMP检查窗口口径补充

A003在前述周期勘误之外，再核冻结 `frozen/m005_ffn_top_tb_v1.sv` 的 `for(int i=0;i<65536;i++)`：前16384B检查TMP写入及outgold，其余49152B检查未写/哨兵。因此可写“64KiB总窗口，含16KiB有效TMP和48KiB邻区”，不能写成输出外另有64KiB邻区。请在后续解释层一并明确；不改原证据、不重跑。

完整研究补充在 `source/feasibility_20261014/updates/at073/report.md`。Wi/Down/WIGQD局部边界与AT049一致，v4参数不变；Down→残差Fatal/反压缺口及综合展开失败各保留原范围。报告与勘误已给A001，无需回复简单收到。
