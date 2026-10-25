# FFN-REFERENCE-18：唯一最小 FFN island 连线

2026-10-23，A010。设计准备，无RTL修改/EDA。当前参考实测只完成原row0，完整128行因合同成本门COST_STOP；见AT003_cost_exit_audit/work/cost_exit.json。本表定义后继生产接线，不称已展开或验证。

## 命令和描述符边界

明确采用独立FFN island命令：公开`norm_ff[128,1024]`→Wi→G→Down→公开Down。在现父接口中使用未用的`cmd_kind=3`（本后继固定Encoder0/layer0），两套现`cmd_tensor/base/span`分别表示Wi、Down。复用已有request64/gen32/epoch32、完整128bit身份校验、两套tensor32及1024bit base/span寄存器，不新增两套Wi/Down描述符。保留原Attention kind0/1/2路径及冻结e354原身份；新FFN图/build身份由主控在实现时冻结，不能沿旧build标签签新RTL。

若把一次Attention命令直接延长为完整Encoder并增加Wi/Down描述符，将额外存1024bit，已超过当前480bit余量；这不是本最小后继。完整Encoder需另外定义实际描述符供给/重用和skip/residual/LN，不在本表中偷偷增加四矩阵命令存储。

Wi为manifest family3/layer0、mlp_wi.0.weight，K1024/N5248，无bias；Down为family4/layer0、mlp_wo.0.weight，K2624/N1024，无bias。实际原描述符、完整原权重SHA见supply_descriptor_source.json。32bit matrix tensor key必须由主控固定绑定上述manifest对象，不能截断名字或凭shape猜key。Wi每port W576 span1511424B，Down每port755712B；各base4096B对齐、完整65bit越界检查。原BO q/scale地址是来源，不能直接当W576四port地址。

## 逐束连接

| 束 | 确定连接和握手 | 所有权/生命周期 |
| --- | --- | --- |
| norm_ff公共F32 | parent.in_*→现q.in_*；row=0..127/group=0..31，4096拍32F32 | 同request/gen/epoch。旧`inputs_accepted[12:0]`足够，无新增输入计数 |
| 初始量化命令 | q.cmd_k=1024、cmd_slot=0；q.acfg/awr及响应→唯一m facade A/cache | 真实4096quant退休/A写ACK、发布和front DONE，DIV释放后才发Wi |
| Wi matrix命令 | m.cmd_k=1024、n=5248、a_slot=0、bias=0、tensor/base/span取原descriptor0 | 原facade一条命令自主load_next/issue_next 0..81；父不逐块发命令 |
| 冷W四端口 | 原m.ar/r束→公共HBM peer/外口；按实际AR地址固定来源 | 唯一W supply/cache，Wi1511424B/port；slot=s[0]、原lease/return/release不变 |
| shared256 FP | m.bind_new_lease、mul/add请求/返回/credit→原r.res_fp_* | Wi/Down实际FP phase1。G不占该池；无第二256FP壳 |
| storage bind/op | Wi首次m.bind_new_lease→原r.res_st_bind_*，同request/gen/epoch/phase1 | G不再重bind；G仅在真实storage owner匹配后准入。原global storage_idle仍是真实三个bankset合取 |
| PS银行 | m.ps_wr/rd及held响应↔原r.res_st_ps_* | Wi/Down PS1024bank，原context0/1独立退休。G活动不屏蔽PS束 |
| G银行 | 原G g_wr/rd所有mask/addr/tag/held响应↔同r.res_st_g_* | 同phase1身份，独立256bank。PS与G可同时合法工作；禁止复用validation_shell自带第二storage |
| Wi→G填充 | m.out_data/row/s→g.fill_data/row/s；fill_slot=s[0]；fill_half=(m.out_col>=2624) | 正常m.out_ready=g.fill_ready，fill_valid=m.out_valid且G已启动。每s已有两半32列，无0/41重排 |
| G全任务启动 | 实际arena G enable、storage owner和TANH lease匹配后g.cmd；与q的K2624命令联合真实接受 | 用`g.cmd_valid=F_GQSUB&&q.cmd_ready`、`q.cmd_valid=F_GQSUB&&g.cmd_ready`；两ready都不依赖各自cmd_valid，可同沿原子接续，无cmd_seen寄存器 |
| G外FP池 | G 9通道fp_req/rsp逐项直连一份原g_vector_pool | 原56mul/16add，3/4拍、96bit tag/独立seq和真实债保持。不可改接8拍shared256 |
| TANH | G sfu_req/rsp→一份原TANH8 mode1/phase1、完整96bit tag/mask/status | 原8lane DAG/每lane两条直接div；与原Attention EXP8的11bit专用tag接口分清。EXP未实现与TANH物理共享；资源全部计一次 |
| G8→32拼接 | g.out_*→唯一1024bit pack_data，按expected_seq[1:0]四笔写8lane | seq16校验`{gen,epoch,zero16,seq}`，无96bit tag/请求身份存储；full后保持至q.in_ready |
| G量化输入 | full pack_data→同q.in_data；坐标由`(pack_seq-1)`导出row和group=s；q.cmd_k=2624/slot=1 | 41984笔8lane→10496笔32F32→10496真实A写/ACK；同一front从初始量化退休后重开，无整G RAM |
| DIV | q.d_*↔原r.res_div_*，phase5 | quant专用原32mul不变；与G原直接div不是同一端口，不能改延迟或虚构并行 |
| 成功close | held Wi DONE status0、held G DONE status0且!done_cancelled、原全域coverage、pack seq41984/full0→q.producer_close_success=1 | 先成功close，再等q真实退休/发布/DONE及全部债/lease退休；不得把q最终DONE反用为close前提 |
| Down准入 | 成功close后q status0/A slot1有效、真实Wi/G资源退休→原WMSUB/WMRUN | m.cmd_k=2624/n=1024/a_slot=1/bias0、descriptor1；冷载原Down W576，16块；禁止投机Down |
| Down公开输出 | m.out_*→parent.out_* | s0..15→row0..127→half0/1，col=64s+32half，4096拍/131072值；held不提前父DONE |
| 父成功/首错 | 原父done/status/domain/tuple/request保持型寄存器复用 | Wi→G(rank,row,col)→Q8(G)→Down按原图顺序。相关下游DONE保留至Wi已知，不复制tuple；G32bit仅0/6/8合法值显式适配，未知值按协议错并保留原32bit在tuple中，禁止截断 |
| G上游取消 | producer_cancel_valid/ready/request64/gen32/epoch32、done_cancelled→CANCEL-17接口 | A007唯一写G。本任务只引用合同，不假定未交付实现已通过；匹配DONE消费后仍真实discard、release、新gen |
| front失败close | Wi失败/G错误/pack fault→q.producer_close_success=0；actual fill_cancel↔m | close同沿已接受input计入债。未接受holding只在失败close正式接受后放弃；所有已接受quant/DIV/A继续排完，不补输入 |
| G故障时Wi排出 | 公开G protocol_fault后m.out_ready接明确discard sink，继续Wi原检查/真实输出退休 | sink beat只计Wi消费，不计G fill。Wi实际源错误优先；避免G fill_ready=0永久卡住matrix |
| 共享控制arena | 单workspace A/G q/next、owner_req、REARM接A007已实现真实安全资格 | layer必须L_IDLE/real_idle/head/RoPE无债后A→G；G held output/DONE/cancel/discard及真实债未退时禁止切owner。Check/cache/matrix/front不共享 |

## 状态与新增寄存器预算

保持原state[4:0]及公开parent_state5bit：旧20个编码0..19不变，新增20..31共12个FFN状态：F_ARENA、F_NQSUB、F_NQRUN、F_WISUB、F_GQSUB、F_RUN、F_CLOSE、F_QDRAIN、F_ABORT、F_DISCARD、F_RELEASE、F_RETURN。Down命令/运行复用旧WMSUB/WMRUN，最后FINISH复用。具体组合动作/旧态FFN分支须在实现时逐沿验证；本表是可实现预算，非现RTL声明账。

只增加pack_seq16、pack_full1、pack_fault1、g_cancel_sent1、q_close_sent1，共20bit；不加cmd_seen、owner复制、pending元组或多套descriptor。两个sent位在新任务清，在对应真实握手置位，避免失败阶段重复cancel/close；资源lease_active/engine_idle/needs_discard直接来自真实服务，不新存镜像。1024bit数值holding128B单列payload，不把full/seq/fault归payload。详见ffn_control_budget.json。

## 仍未连接的真实上游/尾部

Encoder0 skip来自原embedding_norm；attention_residual=严格F32 add(skip,WO)；norm_ff=无gamma LN(attention_residual)；最终encoder_out=add(attention_residual,Down)。R003只输出WO，没有真实skip保存/读口、残差加法/LN生产者或Down残差回加。本island公开输入只签这个边界；保存norm_ff/G只用于独立参考，不能写成真实Encoder生产路径。LN本身控制没有包括在4036B基线，不能未经另账并入。
