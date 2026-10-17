# E003：当前生产链接入与回归

M003/SM003是M004完整Laya加速器的前置，A002单owner；唯一实现根为`project/E002_Laya_HLS/experiment`，E003只保存冻结运行证据。原模型、完整shape/122矩阵、独立gold、13BO/control ABI、wire v2、数值与错误优先级保持。

当前按`D-M003-PRODUCTION-HLS-PARTITION-01`及`D-M003-CONTROLLER-INTERNAL-SPLIT-01`实施：完整图、PC、身份/预约/高水位、BEGIN/END、owner事件和唯一typed退休归graph sequencer；command/provenance adapter只执行一笔normalized COMPUTE/PROVENANCE/PRODUCER事务，持有compute/provenance/producer三对512-bit/depth2 FIFO共18根信号。sequencer只持有transaction request/completion两条FIFO共6根信号。

内部LTX1/LTC1固定小端schema为1536B/24拍请求、1024B/16拍完成、单inflight。失败normalized completion清空可信flags和binding字段；合法未排空匹配错误保持非终态。LayerNorm由sequencer展开为BEGIN→PRODUCER→END，取消期间匹配清理事务继续收束旧scope。重工具保持单实例、CPU0–3、nice19、idle I/O、MemAvailable>192GiB；HLS 24GiB/1800s/120s语义停滞，RTL pilot 8GiB/120s。

---
Published: 2026-10-12T04:34:29.449450+00:00
Publication: Pf7a29e53bf584d0596c2c56ef032df6c
