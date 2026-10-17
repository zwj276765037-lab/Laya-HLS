# E004：完整软件基线与固定图局部服务实验

M004/SM004/E004/R001；A002 为 E002 实现与本批工具唯一写入负责人。当前权威 LN 单行合同为 `project/missions/SM004.md` 修订5；Vivado 2025.2、`xcu55c-fsvh2892-2L-e`、6.667ns 请求，只测试固定图候选的局部服务。原模型、F32 逐步舍入、独立 P1 保存夹具及 gamma 身份保持。AT091 是完整 B1/S128 的 host 软件正常请求；AT101 是受控 AXI4 向量服务；AT104/107/108 分别为 LN 叶子探针、1024 维单行 RTL 和同版单行 OOC。叶子/行参考仅复用独立 oracle，不重跑完整模型。预算为 LN host600s/8GiB、static1800s/24GiB、RTL1200s/8GiB、唯一 OOC1200s/24GiB；原始 attempts 不回写。

---
Published: 2026-10-14T16:21:32.853404+00:00
Publication: P7c48b55e54284f29bbd65dec515c35a1
