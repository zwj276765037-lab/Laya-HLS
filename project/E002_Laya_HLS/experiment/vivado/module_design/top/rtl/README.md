# 总体集成 RTL

本目录保留需要维护的自定义/封装RTL；当前HLS实现维护在项目[hls/](../../../../hls/)。当前 build tag 的[679份自动生成Verilog与201份DAT](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/rtl_verilog/)归档在结果目录，并由[独立Vivado工程](../../../project/README.md)复用；本目录不复制第二份源码。

本模块尚无独立RTL协同仿真验收证据；CPU/CSim状态单列在results中。

实现依据：[详细设计](../source/design.md)、[平台/资源/性能记录](../source/results.md)。
