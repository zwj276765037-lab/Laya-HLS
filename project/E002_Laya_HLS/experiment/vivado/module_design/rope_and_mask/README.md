# RoPE、QKV重排与mask

当前状态（2026-10-07，P2 F0功能验证通过）：真实表RoPE、双shard转换与有限mask接入完整attention；当前完整CPU/CSim及既有代表性RoPE RTL用例通过。 分阶段证据见[source/results.md](source/results.md)。

执行half-split RoPE、QKV布局转换和有限mask生成。

- 上下游：接QKV Linear输出；向attention交付最终QKV及位置对应的mask。
- 共同设计要求：使用题内位置；完整QKV写入可见后交接；有限mask及合并顺序保持一致。

规格依据：

- [10_rope_and_mask.md](../../design_source/10_rope_and_mask.md)
- [11_attention_and_fp_engine.md](../../design_source/11_attention_and_fp_engine.md)

目录分工及HLS/RTL边界见[上级目录说明](../README.md)。

## 模块工作区

- [source/design.md](source/design.md)：详细设计、原规格路径/章节、结构/接口、数值、存储/流水和联测要求。
- [source/results.md](source/results.md)：平台/配置、资源、频率、可复算性能/带宽估算及未执行阶段。
- [rtl/](rtl/README.md)：后续维护的自定义/封装RTL。
- [tb/](tb/README.md)：本模块自检与关联链路测试。
