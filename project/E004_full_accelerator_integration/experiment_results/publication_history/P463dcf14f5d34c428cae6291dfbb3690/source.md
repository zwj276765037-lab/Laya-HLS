# E004：完整软件基线与固定图局部服务实验

M004/SM004/E004/R001；A002唯一工程/工具owner。SM004修订9按固定单行Wi K1024/N5248合同，把AT040真实前LN row0接现行LNQ、真实冷/暖W cache与同步PS前端，独立保存的LN/Q/逐组PS/final只作检查器。顶层增加真实W读错/标签错触发的前端abort与结果行发布/释放；预算host≤300s、static≤1800s、RTL含pilot≤1800s，全项目单重工具/CPU0–3/nice19/idle/MemAvailable>192GiB。没有新联合OOC/P&R/整模前向。修订8 AT138/139较小LNQ网表事实保留，不能迁移成本或面积至本顶层。

修订10在同一真实AT040前LN row0上，把Wi的完整20992个PS及5248个F32送入原canonical G，再将其2624个结果经同一Q直接模式的82组接Down K2624/N1024；保存Wi/G/Q/逐组PS及1024个Down final独立二进制只作逐位检查器。cold真实双W槽LOAD、warm无重复LOAD；单套LN/Q/matrix/front/G与双槽W按固定FSM串接。新范围host≤300s、static≤1800s、RTL含pilot≤3600s，单次/内存/1Mcycle及全项目单重工具门见SM004末节。正常两命令数值已由AT166限定通过；复位/错误/反压只按各次实际覆盖解释。无新联合OOC/P&R、整模前向或末残差验收。

修订11在同一固定顶层保存真实前LN入站skip 1024×32bit，Down完成后由原精确ADD逐项与skip相加并原位覆写final bank；4bit done_phase新增8=RESIDUAL。AT050独立row0残差仅用于checker。验证含真实共同reset、错误后warm、AUX AR和AXI在途reset短探针；新预算host300s、static1800s、RTL4800s，均不转移旧账。无新联合OOC/P&R、全模型前向。

修订12同一固定顶层增1bit cmd_mode/7bit cmd_row及锁存result身份；mode1真实embedding LN gamma1→Q32组→slot0 QKV K1024/N3072矩阵，原bank tile0..383存pre-RoPE Q/K/V、tile384..511存真实消费的1024个embedding_norm。mode0原FFN仅row0，双W槽与G/ADD不复制；QKV冷W key=16'h0001、warm row1同槽lease，返回FFN需按每槽当前epoch+1重新冷载Wi/Down。外部raw/gamma仍由流端供给，独立AT091/AT050保存参考仅作checker。本段host300s、static1800s、RTL含pilot3600s，单次及资源帽按SM004修订12；无新联合OOC/P&R或完整前向。

SM004修订13：在同一原计算core外增加单个QKV/norm scratch包装层，并复用原AXI512 writer；QKV按48个head段和1个norm段从原结果bank同步读，写QKV0/QKV1/STATE1 HIDDEN三物理BO域；FFN保留原行消费者。writer新增真实债零rearm，包装层等待末B、flush、release/core done及零债后报outer done；tensor用128bit覆盖/sticky失败/epoch管理pre-RoPE RAW。原raw/gamma仍来自外部流；本地接口尚未绑定生产Host/HBM。预算host300s、static1800s、RTL4800s，未启动OOC/P&R或新gold。

修订13普通受影响修复：旧wrapper的FFN F_ROW只等待release，在core ROW非法tile直接DONE时可能卡住；新wrapper以真实读预约/rsp债排空接原core错误done，并在本地row消费前比较core回显mode/row。FFN错回显真实release/core done后给7/7，不污染tensor；QKV错回显排空后给7/12、sticky failed。新wrapper仅改控制/身份门控，原core、writer、地址算术与gold不变。

---
Published: 2026-10-15T04:19:47.945901+00:00
Publication: P45c25d394a5a48c4bae0509f40156c5d
