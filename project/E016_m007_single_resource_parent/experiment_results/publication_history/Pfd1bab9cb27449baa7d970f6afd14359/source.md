# E016/R003 FULL-PARENT-15 当前实现

当前e354父及原共享依赖冻结在AT004（同一e354生产源，测试台用等价显式分支避免已观察xsim内核异常）。新增m007_full_parent_tb在同一完整snapshot支持QKV3、真实第二head退休和完整Attention父链，保留原8身份/原数值与协议checker，增加每head maximum终点、真实context4096、同quant/A发布、WO131072原gold及首次243bit独立期望/held回执。peer每个实际AR按地址锁定QKV/WO源与base，R不随之后phase切换。生产RTL未改，不复制服务。

新独立预算ref0/static600/RTL6000/OOC0，600s RTL保留。固定gate E=1.10*(P2+14*Hmax+Q)+10，Q为启动至末QKV实际提交wall的可证伪context+WO占位，非该段实测。gate与原3600s full单次上限不私改。全部源码/fixture复制冻结、编译/guard/命令/日志保留；原R001/R002不转余额。

---
Published: 2026-10-22T12:24:22.768499+00:00
Publication: Pedc98174ef6342f199a07c48f5e25027
