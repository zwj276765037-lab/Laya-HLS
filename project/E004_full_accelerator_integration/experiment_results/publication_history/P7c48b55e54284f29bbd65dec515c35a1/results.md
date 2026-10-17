# E004：限定结果

AT091完整软件正常请求47项/4,523,596 F32对独立gold逐字节PASS，仍只是host。AT093单lane4096项正常4103cycle、反压6444cycle、峰32；AT099仅单lane局部OOC为1283LUT/614FF、DSP/BRAM/URAM0、内部WNS+3.057ns@6.667ns。AT097旧AXI服务2AR/1AW/1B与6928/7185cycle因跨4KiB，只保留旧局部数值观察。AT101修正版10条连续无reset局部命令PASS：对齐4096项正常/反压6955/7206cycle，8AR/512R/4AW/256W/4B，逐bitgold和64KiB目的窗口保护通过；三种单端口页内偏移各16AR/8AW/8B，70beat混合偏移短尾通过。数值错误首索引7及2、首RRESP/BRESP错误status8、WSTRB屏蔽/债务排空与W跨拍保持通过。AT100 TB拼写编译失败保留。guard静态/RTL/OOC累计44.381434/34.727431/78.220358s，触发null。服务未综合、无P&R/真实HBM/完整硬件图性能。见结果报告及AT101原日志。


---
Published: 2026-10-14T15:33:34.709772+00:00
Publication: P23b736dbba3040f7a1da3d5fd926200e
