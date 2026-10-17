# RoPE、QKV重排与有限mask RTL

本目录保留需要维护的自定义/封装RTL；当前HLS实现维护在项目[hls/](../../../../hls/)，生成RTL保留对应build目录，不复制第二份源码。

已取得[RoPE isolated Verilog/XSim cosim日志](../../../../results/engineering_p2/20261007T030653Z-1859617/cosim_rope.log)，范围为同一算术leaf的3个补充用例。

实现依据：[详细设计](../source/design.md)、[平台/资源/性能记录](../source/results.md)。
