# E003：当前生产链接入与回归

M003/SM003是M004完整Laya加速器的前置，A002单owner；唯一实现根为`project/E002_Laya_HLS/experiment`，E003只保存冻结运行证据。原模型、完整shape/122矩阵、独立gold、13BO/control ABI、wire v2、数值和错误优先级保持。L0/L1仍为PARTIAL，L2–L5 NOT_RUN。

当前权威结构为`D-M003-PRODUCTION-HLS-PARTITION-01`及`D-M003-CONTROLLER-INTERNAL-SPLIT-01`。完整任务图、PC、任务/Ref预约、高水位、错误恢复和唯一typed退休归graph sequencer；单帧command/provenance adapter直接拥有compute、provenance、producer三对512-bit/depth2 FIFO的18根内部连接信号。adapter action只允许COMPUTE_TRANSACTION、PROVENANCE_TRANSACTION、PRODUCER_TRANSACTION，复合LINEAR/GEGLU_DOWN/ATTENTION仍由sequencer展开。外部Host仍只见原13BO/control。

sequencer与adapter之间新增显式小端内部schema：request 1536B/24拍，completion 1024B/16拍，单inflight、一个请求槽和一个完成槽。completion分别表达完整帧、绑定成功、远端drained/scope/terminal/published及本地拒绝。adapter不拥有READY、owner发布、业务编号或typed退休；取消期间已接受事务继续收束，只有带CANCEL_CLEANUP的匹配END/RELEASE/INVALIDATE可作为旧scope清理事务继续。

现阶段先验证adapter真实HLS生成和burst store monitor，再验证sequencer/adapter/LayerNorm engine及depth2连接，随后接真实master→monitor/hub→source lease→Q/fullA。全部重工具保持CPU0–3、nice19、idle I/O、MemAvailable>192GiB；HLS 24GiB/1800s/120s语义停滞，RTL pilot 8GiB/120s。无OOC、P&R或上板授权。

---
Published: 2026-10-12T04:03:09.711311+00:00
Publication: P077d57d8799946569fe5131bb4b3897a
