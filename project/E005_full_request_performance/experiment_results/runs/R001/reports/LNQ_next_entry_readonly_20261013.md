# LN→Q 下一计量入口只读核查

2026-10-13；A002；M004/SM005/E005/R001。此页仅为 CT0 之后的入口准备，未执行新工具、未改 DUT。

`layernorm_quant_source_03` 冻结 rows16/D1024 样本的原始 full 日志记录：base configured 25、BEGIN response 134、producer request 150、首 LN source AR 5035、末行 destination B 653813、8 拍 completion 完成 655387、首 Q source AR 655502、最终 PASS 659334 cycles。实际覆盖 16,384 F32 LN、16,384 INT8、512 FP16 scale，LN 读/写各 1024×512-bit 拍，Q 从实际写入的 store 重读 1024×512-bit 拍。这里只能计算事件间距，不能据此把 5035→653813 全称为纯算术或把 655502→659334 全称为 Q 内核时间。

已有 [LN/Q 复用盘点](ln_q_inventory_20261013.md)核对 `_03` 冻结生成 engine、gold、fixture；`_04` 只做 rows1 兼容 pilot。当前 live 连接相对 `_04` 有六份 provenance/shell 源变化，旧 rows16 结果不能代签当前连接。若主控选择此入口，新计量必须在相同冻结身份上增加握手/阶段观测，或先做受影响当前连接回归并单独标识身份；测量 TB 不改变独立 gold、真实 AXI store→Q reread、lease/最后 B/完成消费。

旧 full 实际 753.504 s、659334 cycles、peak 856844 KiB；成本只是参考。原单工具、CPU0–3/nice19/idle I/O、MemAvailable>192 GiB、RTL 8 GiB/3600 s/5M cycles/120 s 真实进展及 pilot≤120 s 均保持。尚未收到 CT0 后的新阶段合同，故未排队工具。
