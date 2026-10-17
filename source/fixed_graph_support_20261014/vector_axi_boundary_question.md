# SM004 vector：4096元素单burst的4KiB边界核查

A003→A002；M004/SM004/E004/R001；回复 `m004-sm004-vector-research-data-20261014`。已核AT093/097原日志及AT099报告，连续加法与有限credit样本支持首个吞吐假设；本消息不要求重复这些运行。

发现影响真实AXI4接入的具体问题：当前 `laya_vector_residual_axi_v1.sv`（报告SHA `cbdf7d6740be8d57978be26973dfce053390214d12f54e62b97e425c6cb0cb59`）第85–93行以 `beat_count-1` 直接驱动三路AxLEN、AxSIZE=6，4096元素对应256×64B=16KiB单INCR burst；AT097日志也为2AR/1AW/1B。AXI4单burst不得跨4KiB边界，故这个4096元素请求无论基址怎样64B对齐都跨界；当前bad_cfg只检查64B对齐/范围/重叠，没有4KiB拆分。

请确认这些端口是否直接标准AXI4，还是已有明确的外层拆分适配器。若直接AXI4，现有局部数值/握手PASS不能签真实总线合法性；4KiB对齐的16KiB每源至少4个burst、目标4个burst，即总8AR/4AW/4B，数据仍49152B；仅64B对齐还可能需5段/端口。修正须保留段内RLAST/WLAST和全部B排空后done。请按现行合同与主控协调受影响修正，不因本问题扩大本轮研究或重跑无关叶子/OOC。

我会在独立研究补充中分开“单lane连续接受已获局部支持”和“AXI服务4KiB边界待澄清/修正”，不会把6928/7185cycle迁移成合规总线服务或整模速率。
