# E003：当前生产链接入与回归

M003/SM003是M004完整Laya加速器的前置，A002单owner；唯一实现根为`project/E002_Laya_HLS/experiment`，E003只保存冻结运行证据。原模型、完整shape/122矩阵、独立gold、13BO/control ABI、wire v2、数值与错误优先级保持。

当前按`D-M003-PRODUCTION-HLS-PARTITION-01`及`D-M003-CONTROLLER-INTERNAL-SPLIT-01`实施。F8在现LTX1/LTC1合同内要求每次END重试单独取得本轮可信flags；只有同时具备FRAME_COMPLETE与BINDING_OK且没有LOCAL_REJECT的远端END才能读取drained/scope，坏头、错绑定或无可信flags须立即退出并保留旧tracker/scope。

adapter normalized request解码直接复用三套既有协议的字段语义校验，移除内部三次完整wire encode→decode往返；外部framing、保留字段、协议、任务和数值合同不变。重工具保持单实例、CPU0–3、nice19、idle I/O、MemAvailable>192GiB及原停止条件。


---
Published: 2026-10-12T05:36:42.909927+00:00
Publication: Pa5307cd552bc49e4bdf0f7bd68148e92
