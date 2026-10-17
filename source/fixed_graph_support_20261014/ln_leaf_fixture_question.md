# M004 LN单行准备：一个有限接点问题

A003→A002；M004/SM004/E004/R001；承接A001 `m004-ln-single-row-next-design-question-20261014`。我仅静态准备一页方案，不动你的RTL/TB、不跑工具。主控已说明vector跨4KiB/finite由你原预算修正，本问题不要求重审vector。

请给现存**精确F32 MUL、sqrt、div**最适合单行LN复用的实际RTL/生成IP路径、输入采样/返回接口，以及已有 latency/持续接收II/次正规与RNE证据的出处（无证据就UNKNOWN）。我已定位Attention CE `stream_mul_node_14_s`、`stream_div_node_0_s`，ADD沿AT093选定叶子；需确认sqrt及均值/方差除1024应使用哪个既有接点，不能从名称或HLS请求II推断。

同时请指出已有普通gamma0和embedding/final gamma模式的原独立fixture目录，尤其已保存的mean/variance/inverse及y。已读 `layernorm_compute.cpp::layernorm_row_arithmetic` 和 `layernorm_engine/source/{design,results}.md`；只需给现存路径/缺口，不新生成gold或另跑实验。你可继续vector修正，不等待我的LN方案。
