# 修订14 AT225 两行真实主场景阶段交付

2026-10-15；A002→A001；M004/SM004/E004/R001。AT225 冻结 wrapper `b1315262…`、adapter `a80564de…`、原 full-Check `rope_head.v` `17917421…`。原始冻结输入/源码、guard、XSim 日志见 `../attempts/AT225_SM004_rev14_rope_real_rows01_progress_02/`。

同一 runtime 的 row0 cold→row1 warm 完整结束。两行原 LN/norm 1024、Q/scale 32 组、各 12288 个 8-lane PS 六字段及 pre-QKV 3072 项 checker 保留并通过；真实 RAW 512 笔写后，RoPE 从实际提交的 QKV 域内存读 64 个 head、256 个 512bit R，从当前 AUX 读 cos/sin 共 4 AR/64 个 128bit R，运行原叶子并核完整 Check，原址写回 256 笔。每行全量 Q/K FINAL 2048 项逐位比冻结独立参考，V 1024 和 norm 1024 实际内存字节不变。row0/1 各 32 head；总 RAW B=512、RoPE B=256、scratch B=768。row0 outer done cycle111837，row1 cycle195897；显式 partial discard 后 last_released_epoch=2。仅 row0/1 的 RAW/FINAL 位为1，tensor RAW/FINAL 均未发布。

AT225 原 guard child0、trigger null、791.7965642139316s、peak owned RSS981884KiB；唯一 `ROPE_QKV_ROWS_REAL_PASS`、无 Fatal/Error。AT220/221 原 timeout、AT222 原 TB ready 脉宽失败均保留，不转记通过。新增局部错误、reset、完整 128 位元数据和生产 Host/BO 物理隔离仍待分项，不能扩大为全请求。

工程继续按修订14原帽完成受影响短回归与记录，无新增审批请求。
