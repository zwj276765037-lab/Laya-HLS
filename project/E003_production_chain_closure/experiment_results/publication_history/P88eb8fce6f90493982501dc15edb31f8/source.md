# E003 当前实现与独立参考

唯一实现根仍为E002/experiment。当前按检查点高水位合同实现可选v2 hub/LPV transport下界及16拍派发权交接。原hub typed/owner数组为权威，连续前序witness只签观察到的成功task前缀；LPV号直接来自原transport.last_event_seq。真实base历史及当前monitored_bo_base共同门控authority。参考为literal Python完整1024B布局、真实LPV/AXI监测前序和现C++ codec/helper；原LYRQ/LYMP、旧v1及F15/F16合同保持。

正常诊断真实target tasks1–3、source tasks4–7，地址pattern而非encoder数值。独立expected不读取DUT输出。v2 helper仍不发TaskDone/retire/CLAIM/PUBLISH；实际捕获导入的fence是受控host事实。完整17类graph、持续accepted-request、全部13BO及生成executor未完成。

本阶段已获主控限定接纳；当前准备独立持久executor top及实际准入/导入确认，不扩为生产整链通过。


---
Published: 2026-10-12T17:12:23.134143+00:00
Publication: Pf7ec5c766a024c9b8dcbf7fb196ae41c
