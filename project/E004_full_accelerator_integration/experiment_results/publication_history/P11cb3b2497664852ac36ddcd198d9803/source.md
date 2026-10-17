# E004：完整软件基线与固定图局部服务实验

M004/SM004/E004/R001；A002 唯一工程与工具写入负责人。现行合同为 `project/missions/SM004.md` 修订6。原模型、逐步 F32 舍入及独立 P1 保存夹具不变。AT091 完整 B1/S128 host 正常请求，AT101 受控向量服务；AT109/110 修复 LN 首错，AT121 为修复版 LN→现有Q→可复读单行的原功能回归；AT122/123仅修正Q在途共同reset TB覆盖，AT116 是同RTL一次U55C联合OOC，AT119/120只读审计该DCP。LN段与连接段预算分开，后者累计 host600s/static1800s/RTL1200s/OOC1800s，单重工具、CPU0–3/nice19/idle、系统MemAvailable>192GiB。


---
Published: 2026-10-14T17:33:45.493479+00:00
Publication: Pf3f75e497d314fcea70fc330109ef297
