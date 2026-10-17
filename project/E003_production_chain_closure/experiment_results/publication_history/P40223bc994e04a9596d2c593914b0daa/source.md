# E003：Graph program / task lifecycle 有限拆分进入主机验证

A002单owner，唯一实现根为E002/experiment。按主控 `D-M003-GRAPH-LIFECYCLE-SPLIT-01`，原graph职责拆为program sequencer和task lifecycle executor；现13BO/control ABI、LTX1/LTC1、adapter/F10 shell、typed任务、数值规则和资源帽不变。

新增固定little-endian LAX1/LAC1 action协议：512bit/depth2、单inflight，请求512B/8拍、完成256B/4拍。program独占模型PC、下一action、slot handle/version与action ordinal；executor独占身份、Task/Ref/epoch预约、高水位、owner/lease、BEGIN→producer→END/fence和唯一typed退休。17类action及持久状态已登记；当前executor只实现完整B×S NORM/LayerNorm，其他16类在副作用前拒绝。

program三源闭包排除executor、旧Controller和adapter；executor十四源闭包排除旧Controller、adapter实现及compute/provenance/producer三套外部协议codec。独立Python byte oracle与C++ host组合已运行；旧graph_sequencer_hls_01的FAIL/semantic_stall冻结保留且不原样重跑。

既有真实LayerNorm generated engine→monitor/hub→source lease→共享QUANT/fullA、流式adapter生成及F10八个独立协议RTL用例保持原限定结论。本轮没有把这些独立证据拼成same-runtime生产caller或完整graph。

---
Published: 2026-10-12T11:32:27.657617+00:00
Publication: P62d1df46ced0401da3a7b7a58a4679e7
