# E004：完整软件基线与固定图局部服务实验

M004/SM004/E004/R001；A002唯一工程/工具owner。SM004修订9按固定单行Wi K1024/N5248合同，把AT040真实前LN row0接现行LNQ、真实冷/暖W cache与同步PS前端，独立保存的LN/Q/逐组PS/final只作检查器。顶层增加真实W读错/标签错触发的前端abort与结果行发布/释放；预算host≤300s、static≤1800s、RTL含pilot≤1800s，全项目单重工具/CPU0–3/nice19/idle/MemAvailable>192GiB。没有新联合OOC/P&R/整模前向。修订8 AT138/139较小LNQ网表事实保留，不能迁移成本或面积至本顶层。

修订10在同一真实AT040前LN row0上，把Wi的完整20992个PS及5248个F32送入原canonical G，再将其2624个结果经同一Q直接模式的82组接Down K2624/N1024；保存Wi/G/Q/逐组PS及1024个Down final独立二进制只作逐位检查器。cold真实双W槽LOAD、warm无重复LOAD；单套LN/Q/matrix/front/G与双槽W按固定FSM串接。新范围host≤300s、static≤1800s、RTL含pilot≤3600s，单次/内存/1Mcycle及全项目单重工具门见SM004末节。正常两命令数值已由AT166限定通过；复位/错误/反压只按各次实际覆盖解释。无新联合OOC/P&R、整模前向或末残差验收。

修订11在同一固定顶层保存真实前LN入站skip 1024×32bit，Down完成后由原精确ADD逐项与skip相加并原位覆写final bank；4bit done_phase新增8=RESIDUAL。AT050独立row0残差仅用于checker。验证含真实共同reset、错误后warm、AUX AR和AXI在途reset短探针；新预算host300s、static1800s、RTL4800s，均不转移旧账。无新联合OOC/P&R、全模型前向。

修订12同一固定顶层增1bit cmd_mode/7bit cmd_row及锁存result身份；mode1真实embedding LN gamma1→Q32组→slot0 QKV K1024/N3072矩阵，原bank tile0..383存pre-RoPE Q/K/V、tile384..511存真实消费的1024个embedding_norm。mode0原FFN仅row0，双W槽与G/ADD不复制；QKV冷W key=16'h0001、warm row1同槽lease，返回FFN需按每槽当前epoch+1重新冷载Wi/Down。外部raw/gamma仍由流端供给，独立AT091/AT050保存参考仅作checker。本段host300s、static1800s、RTL含pilot3600s，单次及资源帽按SM004修订12；无新联合OOC/P&R或完整前向。

SM004修订13：在同一原计算core外增加单个QKV/norm scratch包装层，并复用原AXI512 writer；QKV按48个head段和1个norm段从原结果bank同步读，写QKV0/QKV1/STATE1 HIDDEN三物理BO域；FFN保留原行消费者。writer新增真实债零rearm，包装层等待末B、flush、release/core done及零债后报outer done；tensor用128bit覆盖/sticky失败/epoch管理pre-RoPE RAW。原raw/gamma仍来自外部流；本地接口尚未绑定生产Host/HBM。预算host300s、static1800s、RTL4800s，未启动OOC/P&R或新gold。

修订13普通受影响修复：旧wrapper的FFN F_ROW只等待release，在core ROW非法tile直接DONE时可能卡住；新wrapper以真实读预约/rsp债排空接原core错误done，并在本地row消费前比较core回显mode/row。FFN错回显真实release/core done后给7/7，不污染tensor；QKV错回显排空后给7/12、sticky failed。新wrapper仅改控制/身份门控，原core、writer、地址算术与gold不变。

修订13同拍错误普通修复：AT212用生产wrapper/writer与合法同步row peer在首段真实flush_done同拍改变core mode回显，旧出口等待第二个flush_done而挂起；新wrapper仅在错误出口保持flush并按读/rsp及writer真实债零退休，原算术core/writer/gold不改。

修订14在同一core/writer之外分时接入一套scratch reader、AUX full cos/sin reader与原`rope_head.v`完整Check叶子：真实RAW写完并退休后，从scratch读Q/K，按head0 Q,K→head15 Q,K原址写回；V/norm保持原值。启用时RAW来源epoch=e，Q/K FINAL预留e+1，128位RAW/FINAL覆盖齐且末done消费后才发布FINAL；RAW-only与FFN原分支保留。本段用冻结两行参考核数值，局部同步peer核读写错误、reset、页界及元数据，不把局部peer当真实embedding producer。预算host300s、static/IP1800s、RTL4800s；当前未启动联合OOC/P&R、生产Host/HBM或整模型前向。

修订14 AT242沿生产RoPE adapter和原full-Check叶子，以四个明确F32位型短例核预检与末pair下/上半首错、完整Check定义字段及结果保持；后接AT236原保存正常head无复位恢复。此局部短例不计算新模型gold，不改叶子或当前wrapper。

主控D-M004-REV14-CLOSEOUT-01已按冻结身份限定接纳本修订所测两行正常链、当前wrapper控制局部与原叶子Check短例，并封存修订14未用额度。后继S128真实生产已按修订15合同实施至所测前缀，FINAL→Attention仍待后续连接。

修订15在原core bank预装STATE0 raw与AUX gamma各1024字，复用reader/writer和原RoPE叶子；单一固定128行sequencer锁存请求字段，逐行在outer done真实消费后前进。当前wrapper `d4856aee…`延迟预装abort至读债真零，并在source RAW-only续行比较gamma AUX描述符。无整行/整tensor新RAM、第二计算top、Attention或Host/HBM平台。当前实测仅旧wrapper两行正常前缀、当前wrapper一行真实全链和局部控制/调度，完整128行及全请求异常首错仍开放。

AT265仅在AT252相同生产sequencer的局部完成peer注入末行7/phase14错误，生产RTL及gold未改；该调度出口不替代实际row127读错。

D-M004-REV15-CLOSEOUT-01按AT250旧wrapper真实两行、当前wrapper AT264真实一行与AT265模拟peer末行错误出口分版收束修订15；生产RTL、数值/gold未再改变，剩余额度封存。Attention及后续连接须另有合同。


---
Published: 2026-10-15T09:35:24.229014+00:00
Publication: Pc997dcdb6d60419eb097200f56933f6b
