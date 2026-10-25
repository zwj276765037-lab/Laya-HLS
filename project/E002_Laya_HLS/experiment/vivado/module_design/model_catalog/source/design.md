# M007 模型目录 reader 与 Host 格式

权威来源：[架构 §12.2/12.3/12.6](../../../../../../../source/m007_residual_encoder30_20261023.md) 与 SM012 MODEL-CATALOG-28。实现/预算/异常规则在 E020 experiment_source/protocol.md。reader/Host/new TB 归 A008；生产父/W mux/transport_idle/两槽/bias 归 A010，type/VECTOR/共享组合归 A007。

`laya_m007_catalog_reader_v1` 只有2bit IDLE0/AR1/RSP2/DRAIN3，无 payload、地址、身份或 descriptor FF。公开口为 `req_valid/ready, req_word[6:0], catalog_base[63:0]`；`rsp_valid/ready, rsp_data[511:0], fault, rsp_rid[2:0], rsp_rresp[1:0], rsp_rlast, idle` 和标准 AR/R。仅 word0..123、4KiB base、65bit base+8192 无进位时 ready；平台实际 aperture 由 Host/父资格检查。ARID7/ARLEN0/ARSIZE6/INCR，ARADDR=base+64×word。

父从实际 request 接受到 idle 恢复必须保持 base/word。AR 一旦提出独立于 req_valid 持续到实际接受，RSP 直接反压真实 RVALID/data/status。坏 RID/RRESP/nonlast 的首返回 fault；非last 接受后 DRAIN 实际 R 至真 last 才 idle。取消/父错误只丢弃返回，不撤 AR、不伪造债清零。idle 为当前 FSM 空闲视图，父 ownership 切换还必须阻断同拍新准入并核全部旧 W transport 债。TB 双槽只在真实无fault响应接受边沿写入；不代签生产 mux。

复位同步置 IDLE，handshake 输出均由 rst_n 门控。in-flight/end reset 测试同时复位 TB 总线 peer，随后验证新请求与无幽灵返回；无身份 holding 的 reader 不声称识别任意晚到的 pre-reset RID7。

Host 工具固定8192B/有效7936B/header256+120×64/尾256零。五个完整 SHA 使用原包保存 preimage，不与本 RTL build SHA 混用；records SHA 与 CRC64 只覆盖7680B records。SIM 诊断地址明确标记，真实 PLATFORM 要求实际 aperture 来源；各base对齐4096、span≥needed、65bit端点、aperture、catalog/W及DMA封存区不重叠。span 不强加4096倍数。没有 W payload 打包或设备计算 SHA。

原包 manifest46bbd5ab…/inventory40983ab8… 固定身份；120 WeightKey 对原 expected_bindings 与 shape，tensor ID 是原inventory位置+1。系数只读原 `final_norm_w`、八 Decision bias、`type_emb.weight` 原字节，输出73728B bias/4096B gamma/12288B type。原 type 三行 Q8_0 按原 embedding_row 一次展开并与原函数逐字节比较；704chunk 为 setup 产品，设备实际 commit NOT_RUN。

AT002 Host8组、AT003 source census/编译与AT004公开RTL已PASS，当前reader SHA3490085a799760fda0cdb3f56dcbff7fe7ed43da947c13fccae8b6bc40eb5810，详细边界见 results.md。生产完整 setup/model_committed、实际口借还、DMA、层/30层、OOC/P&R/时序/上板均不在此出口。
