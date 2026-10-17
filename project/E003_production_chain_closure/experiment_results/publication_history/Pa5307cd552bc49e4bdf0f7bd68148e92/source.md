# E003：当前生产链接入与回归

M003/SM003是M004完整Laya加速器的前置，A002单owner；唯一实现根为`project/E002_Laya_HLS/experiment`，E003只保存冻结运行证据。原模型、完整shape/122矩阵、独立gold、13BO/control ABI、wire v2、数值与错误优先级保持。

当前按`D-M003-PRODUCTION-HLS-PARTITION-01`及`D-M003-CONTROLLER-INTERNAL-SPLIT-01`实施：graph sequencer保留完整图、身份/预约/高水位、BEGIN/END和唯一typed退休；单帧adapter持有compute/provenance/producer三对FIFO。内部LTX1/LTC1 schema、单inflight和取消收束合同不变。

本阶段只修复主控审核F6/F7。completion decoder在任何头检查前清空输出，坏magic/version/beats/kind/status/unit/flags/reserved不能残留可信binding；合法完整绑定的未排空错误仍保持非终态。producer `LOCAL_REJECT`仅在完整绑定、未发外部请求、零提交时成立，并统一释放source read lease、保持destination未发布；旧BEGIN scope仍须由匹配END安全关闭。

重工具保持单实例、CPU0–3、nice19、idle I/O、MemAvailable>192GiB。本轮只运行受影响主机回归，没有重启已`semantic_stall`的adapter HLS profile。


---
Published: 2026-10-12T05:10:23.258838+00:00
Publication: P78369405568248c681babf5ee355a95c
