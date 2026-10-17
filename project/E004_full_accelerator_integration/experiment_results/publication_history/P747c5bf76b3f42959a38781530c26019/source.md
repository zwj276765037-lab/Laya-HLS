## 修订21 AT379–383阶段握手与父层继续接线方法（2026-10-16）

AT379沿AT368未变生产组合层，以合法caller保持阶段done三拍测试continue屏障。父请求工作源码的sequencer/wrapper/core当前SHA已冻结到AT382，完整父top实际展开及真实row0验证；AT383同一snapshot做120秒无提前终止前缀成本pilot。旧core/TB闭包错误各自保留FAIL，不改独立gold，不启动HLS/OOC/P&R。[阶段交付](../experiment_results/runs/R001/reports/SM004_rev21_AT383_parent_continue_cost_handoff_20261016.md)。

## 修订21 AT378独立stage W错误恢复方法（2026-10-16）

沿AT368四份生产SHA及原fixture，只重编串联TB；同runtime完成真实LN128、末q0 RRESP错误、全W排债和错误保持后，经生产stage_release_fire显式discard，重新从epoch2真实source/gamma读取并计算row0。TB直连stage接口为合法局部caller，不代替父wrapper/sequencer的tensor释放。原norm gold仅核W握手及最终内存；没有新gold、HLS/OOC/P&R。[阶段报告](../experiment_results/runs/R001/reports/SM004_rev21_AT378_w_error_recovery_engineering_stage_20261016.md)。

## 修订21 AT373–377受影响验证方法（2026-10-16）

AT373/374沿原下层生产SHA用合法局部事务核部分A错kind及共享cmd_epoch拒绝、显式discard及Q在途共同reset510拍；AT375–377仅增强独立真实串联TB，分别注入W末q0 RRESP错、LN末个B保持和STATE1最后RVALID延迟，不改生产RTL/原gold。AT377同版实际Q入口、叶子响应到bank及前4行gold的checker保留；原AT368正常串联不重跑。父图matrix服务后继接口仅按D-M004-A16-MATRIX16-INTERFACE-01作静态衔接，本修订未实施。身份、原guard和边界见[阶段报告](../experiment_results/runs/R001/reports/SM004_rev21_AT377_error_barrier_engineering_stage_20261016.md)。

# E004：完整软件基线与固定图局部服务实验


## 当前修订21方法：同版真实数据传递与W委派（AT365–372）

AT368沿AT364生产上层/下层/W服务/cache逐字相同，只把独立串联TB扩为实际Q入口16384字逐位与叶子响应→4352字bank独立映射监视器；r4..15仍只签传递，不生成新算术gold。AT367完整父请求top重展开到真实row0。AT369暴露兼容core壳缺新增W身份回显端口；当前壳只作固定透传，engine本体在父top所用AT367与AT372之间逐字相同。AT371复用唯一W服务/cache编译闭包测回执全字段；AT372以相同生产core和原fixture、`xelab -mt 4 --O3`完成本地拒绝消费→exec100冷载→错误epoch拒绝，同版错误分类短例。未运行HLS/OOC/P&R或新gold。证据和身份见[阶段报告](../experiment_results/runs/R001/reports/SM004_rev21_AT372_observer_wprep_engineering_stage_20261016.md)。

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

## 修订16当前方法与输入身份（2026-10-15）

按D-M004-ATT-CONSUMER-01以单一生产reader、原Attention tile service和writer实现FINAL模拟发布peer→真实QKV AXI读→QK/SM/AV→ATT_OUT写B的head0消费者。固定S128、16query tile、128key、D64；55word/128byte mask、NumericIdentity与三目的描述符在命令接受点锁存。Q最终成功load_done是QK前屏障；错误写仅按真实debt_zero及服务/读债排空后rearm。参考为已冻结t5软件捕获QKV和独立score/prob/out，未生成新gold。AT268与当前adapter按冻结SHA分版，详见阶段交付。


## 修订17当前方法（D-M004-STAGED-LNQ-01，2026-10-15）

在同一core/bank、STATE0/AUX reader、STATE1 writer和固定sequencer内实施gamma一次预检、逐行LN_ONLY1024/真实norm写B与内部NORM_STAGE_READY；同一core另有DIRECT_NORM1024及16行Q/scale紧密bank入口。真实LN128是Q16/W加载前的阶段屏障。store错只排空写债并继续当前16行LN算术，后继正常norm受控discard；该窗口数值错优先。MATRIX16/STEP16、W_PREP_ONLY和全RoPE/FINAL仍属后继。当前三模块和leaf SHA、实际分版验证及未测范围见修订17工程交付。


## 修订18 Q16占有与成本方法（D-M004-LNQ-COST-OWNER-01）

当前单一core `a73632b8…`在Q16部分窗口期间只准后续DIRECT_NORM行的prep_kind10/cmd_exec010，保持原bank覆盖与release/discard桥；wrapper/sequencer、量化叶子与gold未变。LN128成本只用同一修复SHA、同一冻结诊断TB/夹具和原FP/IP闭包对比默认xelab与本机实际接受的`--O3`，保留完整逐位checker和AXI存储peer。该候选不修改生产时钟、CE、算术或实例；结构抽取仅为后继设计，未实施。


D-M004-REV18-REVIEW-01限定接纳部分Q16窗口占有修复；修订18成本出口已收束，唯一共享LNQ服务抽取只保留为后继接口设计，当前生产父top未作抽取。

## 修订19共享LN服务实际边界（2026-10-16）

按D-M004-LN-SHARED-SERVICE-01，当前生产父top已实例化唯一LNQ/final_bank下层和唯一reader/reader/writer上层。下层接管staged LN_ONLY命令、回放、norm视图/release/done和Q16覆盖，原legacy经同一下层访问；上层仍由旧sequencer/wrapper驱动128行循环及16行错误屏障，所以独立真实LN128阶段入口尚不可合法验证。数值输入沿原B1/S128保存raw/norm/gamma与原FP/IP，未生成gold。当前冻结身份、局部客户接口及下一切口见[工程阶段报告](../experiment_results/runs/R001/reports/SM004_rev19_AT325_shared_service_engineering_stage_20261016.md)。

## 修订20 AT331时点上层归属迁移的已执行前缀（2026-10-16）

按D-M004-SOURCE-NORM-OWNER-01，AT328把唯一下层LNQ/final_bank物理实例移到上层source/norm服务，重core以固定link接原bank端口；AT330加入本次LN_ONLY命令实际委托来源标记，父本地拒绝输出完整协议Check。所用leaf/FP/IP和B1/S128输入/gold未生成或改动。AT331仍由旧sequencer/wrapper执行staged循环与source/norm行FSM；独立stage与16/128行未实施。[阶段原证据](../experiment_results/runs/R001/reports/SM004_rev20_AT331_bank_extract_local_check_milestone_20261016.md)。

## 修订20 AT343–351 当前生产身份与验证方法（2026-10-16）

AT343生产上层58086436…独占一次staged请求、128行/16行故障窗口及真实source/norm读写，下层f63e25e2…独占LNQ/final_bank；父core452deb9c…、wrapperb1b73970…、sequencer8b9261e0…仅固定代理。AT344–350只增量编译冻结TB，原生产RTL/FP/IP/reader/writer与B1/S128 raw/gamma/norm_gold逐SHA保持AT343身份。norm_gold仅在真实W及最终内存作为独立checker，不代替计算；错误、跨页界/停顿、拒绝与共同reset采用同一生产服务和AXI peer。AT351父core增强TB展开超本段剩余静态帽，未产生可运行snapshot。方法与身份见[工程报告](../experiment_results/runs/R001/reports/SM004_rev20_AT351_engineering_stage_handoff_20261016.md)。


---
Published: 2026-10-15T22:09:05.294966+00:00
Publication: Pff5461c95a0e4cae80882b88c283108f
