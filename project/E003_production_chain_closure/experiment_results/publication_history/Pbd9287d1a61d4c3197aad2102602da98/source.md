# E003：Graph lifecycle F11–F13受影响主机修复

A002单owner，唯一实现根为E002/experiment。按D-M003-GRAPH-LIFECYCLE-SPLIT-01继续固定LAX1/LAC1及program/lifecycle职责，不改13BO/control、LTX1/LTC1、adapter/F10 shell、typed任务、数值规则或预算。

本轮修复三项主控静态缺口：lifecycle持久保存活动action、owner/BEGIN/source lease/cleanup状态，安全终态要求远端和本地清理都完成；LAC1限定Status、拒绝LOCAL_REJECT+OK并在语义失败时保持默认输出；program成功NORM核完整owner geometry和精确退休数，并在first_error后锁住当前request的普通action派发。

冻结主机回归保留B1/S64四窗口LayerNorm成功路径，新增PUBLISH失败/INVALIDATE未排空→匹配终态清理、BEGIN非终态、source release失败、LAC1坏语义、失败request锁存和全部16种未实现kind动态拒绝。旧graph_sequencer_hls_01的FAIL/semantic_stall及所有旧attempt保持。

---
Published: 2026-10-12T11:53:10.754301+00:00
Publication: P40223bc994e04a9596d2c593914b0daa
