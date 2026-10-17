# E004：完整软件基线与固定图局部服务实验

M004/SM004/E004/R001；A002唯一工程/工具owner。SM004修订9按固定单行Wi K1024/N5248合同，把AT040真实前LN row0接现行LNQ、真实冷/暖W cache与同步PS前端，独立保存的LN/Q/逐组PS/final只作检查器。顶层增加真实W读错/标签错触发的前端abort与结果行发布/释放；预算host≤300s、static≤1800s、RTL含pilot≤1800s，全项目单重工具/CPU0–3/nice19/idle/MemAvailable>192GiB。没有新联合OOC/P&R/整模前向。修订8 AT138/139较小LNQ网表事实保留，不能迁移成本或面积至本顶层。

修订10在同一真实AT040前LN row0上，把Wi的完整20992个PS及5248个F32送入原canonical G，再将其2624个结果经同一Q直接模式的82组接Down K2624/N1024；保存Wi/G/Q/逐组PS及1024个Down final独立二进制只作逐位检查器。cold真实双W槽LOAD、warm无重复LOAD；单套LN/Q/matrix/front/G与双槽W按固定FSM串接。新范围host≤300s、static≤1800s、RTL含pilot≤3600s，单次/内存/1Mcycle及全项目单重工具门见SM004末节。正常两命令数值已由AT166限定通过；复位/错误/反压只按各次实际覆盖解释。无新联合OOC/P&R、整模前向或末残差验收。


---
Published: 2026-10-14T22:17:28.254852+00:00
Publication: P7f958afab3f94a998d5d5c0044a15cfa
