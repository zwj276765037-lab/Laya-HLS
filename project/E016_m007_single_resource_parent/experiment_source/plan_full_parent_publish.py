#!/usr/bin/env python3
"""Write only successor preparation and owner documentation; no EDA/RTL/TB changes."""
import resource,time,json,hashlib,datetime as dt,os
from pathlib import Path
resource.setrlimit(resource.RLIMIT_AS,(1024**3,1024**3));os.sched_setaffinity(0,{0,1,2,3});start=time.monotonic()
ROOT=Path(__file__).resolve().parents[3];E=ROOT/'project/E016_m007_single_resource_parent';P=E/'experiment_results/planning/full_parent_successor_20261022';M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def dump(p,d):p.write_text(json.dumps(d,indent=2,ensure_ascii=False)+'\n')
control=read(P/'control_read_receipt.json');identity=next(x['sha256'] for x in control['files'] if x['path'].endswith('/laya_m007_single_parent_v1.sv'));assert identity=='e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8';assert read(P/'frozen_gold_layout_consistency.json')['verdict']=='PASS'
sealed=[E/'experiment_results/runs'/r/n for r in ['R001','R002'] for n in ['budget_ledger.json','final_delivery.md','final_delivery_manifest.json']];before={str(p.relative_to(ROOT)):sha(p) for p in sealed};rtl_before={str(p.relative_to(ROOT)):sha(p) for p in (M/'rtl').glob('laya_m007*.sv')};tb_before={str(p.relative_to(ROOT)):sha(p) for p in (M/'tb').glob('m007*') if p.is_file()}
text=f'''## M007 E016 完整父链后继准备（2026-10-22，只读规划）

本节是主控要求的有界准备，不是完整验证合同或运行放行。生产RTL/TB/runner未改，EDA未运行；R001/R002原attempt、最终交付和封账预算不变。当前parent SHA `{identity}`。证据与单独只读账：[planning]({P}/planning_ledger.json)、[冻结gold布局核对]({P}/frozen_gold_layout_consistency.json)。

### 当前实际入口与不能直接运行完整链的原因

生产parent在[控制段]({M}/rtl/laya_m007_single_parent_v1.sv:1142)已写出 `LRUN→CSUB→CRUN→CDRAIN→WMSUB→WMRUN→FINISH`：真实layer成功DONE后启动同一quant/A和context adapter，等待c_complete/c_idle及layer_idle，再发K1024/N1024的WO命令；WO真实matrix DONE被消费后才进入父FINISH。这是源码行为，未被当前完整链动态签署，未发现仅据源码即可认定必须先修改RTL的缺陷。

现[m007_single_parent_tb.sv]({M}/tb/m007_single_parent_tb.sv:211)没有full模式。PREFIX>0只结束QKV前缀；PREFIX=0在首个实际h_done握手就打印FIRST_HEAD并$finish。head计数是首head总数，max_checked只置一次，未按16head退休重置；仅去掉$finish会在head1统计断言失效。虽然score/prob/context/max数组已加载全16head参考，当前终点仍只核head0，且未要求max_checked成为终点条件。

当前W peer只装QKV p0..p3，AR地址仅允许cmd_base[0]/cmd_span[0]，Rdata也固定按QKV基址读。当前A/write和W/prebias/core trace checker同样固定QKV数据与48块计数；后续context A和WO从s0重起会误用旧gold/旧计数。out_ready恒1，尚无父WO数据/正常成功DONE检查。

现[runner]({M}/tb/m007_parent_run.py:34)也无full模式：prefix0要求QKV3 pilot，成本门只投影完整QKV+首head71168周期，成功marker固定FIRST_HEAD；没有完整父成功marker、全链fixture身份、完整阶段wall事件或独立后继账。因此不能直接调用旧runner加timeout获得完整链。R002 runner同样固定PREFIX=3，仅供已关闭的debug选项对照；普通runner保留O3/debug typical，不继续扫旗标。

### 新TB应新增的检查与合法驱动

| 边界 | 应新增或按相位扩展的实际检查 | 驱动限制 |
| --- | --- | --- |
| 一次父命令/QKV | 原8身份拒绝与所有原QKV检查保留；正常命令只接受一次；4096原输入→4096quant/Awrite/Aack，48块、12288QKV32/393216值；matrix QKV命令与layer.start各恰一次 | 通过原cmd/F32/coeff口，正常链不reset、不逐块发命令 |
| 16head | 每个head独立score16384/prob16384/context8192/prob ack2048、maximum128比较且终点必须已核maximum；每head真实h_done/status/identity/head index、唯一start/retire及周期帽；总head16、score/prob各262144、context131072、prob ack32768、maximum2048、RoPE2048commit；layer head_completed/context_valid在交接前应FFFF | 只被动观察实际内部握手；全局strict checked counter单调不重置，局部per-head计数可分组；保持全部原checker频度 |
| layer成功回执 | 核实际l_done_valid&&l_done_ready，status0、request/gen与原命令完全一致，16head已完成；按冻结layer Check合同核completed/unreachable/dominated/coverage/error，不用“全置1”替代合同 | 不TB伪造layer DONE/context_valid；layer成功DONE不代表context已释放 |
| 公共context4096组 | 对每个真实rd/rsp握手记录一笔实际credit，tag/代际/顺序及32F32逐位比较；读序i=32*query+2*head+half，参考lane=context[(head*128+query)*64+32*half+c]；4096实际响应→4096quant/Awrite/Aack、一次A发布，compare两套QKV/context A gold分相位 | 必须消费实际layer输出；原context文件仅作期望。公共响应保持依实际信用；禁止强制c_*或layer状态 |
| context所有权退休 | 核layer公开消费覆盖4096、public_read_owned=0、无未退storage响应、c_idle/c_complete/c_consumed=4096、quant/DIV/A debt已清并实际发布，最后才接受WO matrix命令 | layer[退休逻辑]({ROOT}/project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine/rtl/laya_attention_layer_engine_v1.sv:1169)在响应真正握手时记覆盖，L_RELEASE等全部覆盖与real_idle才回IDLE；应观察实际条件，不能用TB换相位 |
| W重绑定/复用唯一cache | 用实际AR地址在已登记的QKV/WO基址范围选择原packed数据；每个已接受ID保存其所属源，R响应按接受时源返回；核QKV旧W/A/FP/PS lease和peer AR/R debt全退，WO实际K1024/N1024、tensor32、base[1]/span[1]、同request/gen/epoch，16块冷W装载及原W/prebias/A映射 | peer扩展为两套只读fixture，不复制生产W服务。不能用全局phase给旧在途ID改数据，不能预填W完成或force cache |
| WO131072原值 | 按actual out_valid&&out_ready计4096个32F32响应；输出s=i/256、row=(i%256)/2、col=64*s+32*(i%2)，每lane对原WO[row*1024+col+c]；16块每块1024连续issue/commit，记录反馈、W/A协议和最后输出/资源释放 | 原out_ready口有限反压可合法保持中间/末WO响应；held时valid/data/row/col稳定，不提前接受WO DONE/父成功 |
| 首次父成功/held DONE | 正常例逐拍禁止在“16head、4096实际context、A发布、4096WO响应及真实WO matrix DONE/债释放”前出现任何父DONE；首次成功须status/source_status/error_domain/error_tuple全0，done_request/gen/epoch精确等于接受命令；并核来源m_done身份。done_ready=0保持至少5拍，完整243bit字段既等于独立期望又稳定、cmd_ready=0、无新工作；真正ready后只退休一次，回IDLE可合法接下一命令 | 仅驱动原done_ready/out_ready；稳定性与期望值分别断言，不能只拍下DUT值再自比 |
| 事件与成本 | 在实际command、QKV accept/end、layer start、每head begin/end、layer done、context首/末响应/发布/释放、WO accept/首末输出/matrix done、父done/retire记cycle与主机monotonic wall；generic日志不续strict numerical progress | 原40Mcycle、资源策略、单独账不改；新full终标只有所有检查完成且实际父成功退休才发 |

上述断言属于TB/runner扩展，不应先改生产接口。完整同构建TB可设置observer-only的STOP_AFTER_HEAD=1：在真实head0完成后结束pilot；full设置0继续观察至父DONE。两者不改变DUT命令、参考、相位、驱动或检查频度，full phase checker也必须编入同一snapshot；不是以pilot签全链。两个mode同样在初始化时绑定WO原fixture，避免pilot漏计加载/observer开销。

末context响应在独立consumer中曾合法保持12拍，但当前生产parent没有run_enable/独立result_rsp_ready的外部控制口，out_ready仅影响WO。完整parent若自然发生context反压可被动核稳定；无法通过合法顶层口指定“第4095响应保持12拍”时应标该定向保持NOT_RUN，不能force内部ready或借独立peer结果冒充。正常WO out和父DONE保持均有现成合法顶层口，可随一次完整正常例完成。

### 独立参考已具备，仍未知的生产行为

只读布局核对本次已比较全部131072 context位型：E010 encoder0_context.mem按上述query/head/half重排后与E012/R004 AT005 input.hex完全一致。WO output.hex的4096组按上述s/row/half顺序与E015 AT007原wo.bin/expected_f32.bin的131072位型完全一致。原WO gold SHA `1527544ebbc58548cacd152ba0a98fe679332fc83d651f3c2ffed15b4eca19dc`，原WO weight SHA `6be3b4e35057b15055db95ef5ab1d572ce202ac89200abc51479a1bfdd31c288`，均来自已有fixture.json；未重算gold。新完整模式仍须把所有WO p0..p3、input/Awrite/output/prebias/源manifest身份纳入snapshot，期望文件不能被当成真实context输入。

目前“已证TB缺口”不等于“生产RTL有缺陷”。以下组合行为仍未知：全部16head及layer Check退休；真实layer result读与同storage phase4/DIV phase5并行路由；QKV A释放后同request/gen/epoch重新真实填槽是否正确失效旧内容并发布新context A；layer4096覆盖到real_idle与quant/A完成的联合排债；唯一W/A/cache/FP/PS由QKV→layer→WO的重绑定与迟到响应隔离；WO输出保持、最终成功状态/tuple/identity与held父DONE。当前源码有相应调用路径但未完整实测；必须由新正常链暴露问题，再在授权内定位修复，不预先宣称PASS或FAIL。

现e354的c_fault相位修复通过当前短QKV/reset scope，仍未动态覆盖“真实父context fault→无reset新generation”链；这是独立错误恢复后继，不应拿正常完整例当作该故障覆盖。Encoder0无bias完整链也不能签Decision/bias、全图原首错/Check、30层、HBM注册/CDC/物理时序/板卡。

正常成功tuple零有具体源码依据：facade[每次实际cmd清状态/坐标]({ROOT}/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/rtl/laya_m007_matrix_facade_v1.sv:240)，parent在WMRUN消费实际m_done后映射成功状态/域并返回该坐标；新TB仍必须把预期0与原命令身份逐项核对，不能用来源稳定性代替独立期望。

### 建议集中制定的新预算与一次完整运行上限

建议新独立批次（名称由主控决定）reference0/static300/RTL7200/OOC0秒，不转R001/R002余额。static每次≤120秒；同一当前RTL/全检查TB构建后先真实完整QKV→首head pilot≤1200秒，再由主控基于该pilot决定一次full≤5400秒（90分钟）；其余600秒仅供有新诊断依据的短恢复/受影响回归，不自动再跑整条长前缀。全部真实语义停滞120秒、CPU0–3/nice19/idle、MemAvailable>192GiB、static≤24GiB/RTL≤8GiB、40Mcycle及项目锁不变。budget是建议而非本次已获执行额度。

旧3494.951523668秒只说明旧parent/旧首head observer下的attention-only费用，不能为e354或新全检查TB放行。旧E012/R004完整WO203.558494425秒来自独立context-file runtime；R001本地consumer6.426384921秒也不是当前完整父的phase样本。它们仅帮助给新5400秒一次性cap留工程容量，不能拼接成当前完整链实测。

新pilot必须给P=当前同snapshot命令至首head退出wall、H=该实际head0 begin→end wall，并保留阶段/数值证据。建议供主控决策的工程估计 `E=1.35*(P+15*H+C_allow+W_allow)+10`；第一次完整链尚无同runtime C/W样本，可在新集中合同中明确选择C_allow=60秒、W_allow=600秒作为收费/停止占位（不是测量、不是性能保证），而不要求先做完16head才能给第一个完整例放行。若E≤5400且当前pilot数值/所有权/strict进度通过，可由新合同明确授权一次完整例，在这次运行里直接测得所有head/context/WO真实成本与完整成功；若超cap或pilot失败，交主控集中调整scope/预算，不在runner自动加帽或反复重放。当前没有执行/放行任何pilot或full。

完整验证同时记录原QKV≤57344、Encoder layer≤188544、WO≤22528、每满足前提dispatch≤16且父调度合计≤128，以及Encoder整块≤268416拍；新合同应精确定义原QKV_ACCEPT/WO_RETIRE事件，并同时记录父cmd accept与QKV matrix cmd accept，避免把不同边界混写。外部held停顿单列，不能自行从原总帽扣除或把独立周期相加写成实测。FPGA吞吐/300MHz/物理fit仍不属于仿真wall预算结论。
'''
(P/'planning.md').write_text('# 完整父链后继准备\n\n'+text)
for name in ['design.md','results.md']:
 p=M/'source'/name;s=p.read_text();assert '## M007 E016 完整父链后继准备（2026-10-22，只读规划）' not in s;p.write_text(s.rstrip()+'\n\n'+text);assert p.read_text().startswith(s.rstrip())
proposal={'scope':'controller-requested read-only successor preparation, not executable permission','parent_sha256':identity,'production_changes':False,'EDA_runs':False,'current_full_mode_available':False,'reason':['normalTB exits first h_done','runner prefix0 is FIRST_HEAD only','W peer/checkers fixed QKV','16head/context/WO/success-DONE terminal assertions absent'],'suggested_independent_caps_s':{'reference':0,'static':300,'rtl':7200,'ooc':0},'suggested_per_attempt_s':{'static':120,'current_build_first_head_pilot':1200,'one_complete_parent':5400,'reserved_short_recovery_total':600},'provisional_unmeasured_allowances_s':{'context':60,'WO':600},'controller_estimate_formula':'1.35*(actual current P+15*actual current H+C_allow+W_allow)+10','not_automatically_admitted':True,'controller_contract_needed_before_EDA':True,'gold_cross_layout_evidence':'frozen_gold_layout_consistency.json','normal_complete_coverage':['16 real heads','4096 real layer public context responses','same quant/A publish and layer release','one real WO rebind','131072 original WO values','first actual success and held243bit expected identity/tuple'], 'uncontrolled_targeted_case':'No legal parent top-level knob for forced last-context-response hold; passive natural hold only, otherwise NOT_RUN','uncertain_production_behavior':['same-generation A refill','phase4 storage plus phase5 DIV handoff','all16 layer retirement','W/FP/PS/A lease and queued-response handoff','WO backpressure and final actual parent success','actual context fault to next-generation recovery not signed by normal case']};dump(P/'successor_proposal.json',proposal)
for rel,h in before.items():assert sha(ROOT/rel)==h
for rel,h in {**rtl_before,**tb_before}.items():assert sha(ROOT/rel)==h
receipt={'stage':'planning_document_write_and_boundary_verification','elapsed_s':time.monotonic()-start,'maxrss_kb':resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,'address_space_limit_bytes':1024**3,'cpu_ids':sorted(os.sched_getaffinity(0)),'nice':os.getpriority(os.PRIO_PROCESS,0),'timeout_s':20,'scope':'authorized planning docs and evidence only; RTL/TB and R001/R002 sealed records unchanged'};assert receipt['elapsed_s']<20;dump(P/'document_read_receipt.json',receipt)
ledger=read(P/'planning_ledger.json');ledger['measured_read_receipts']=[read(p) for p in sorted(P.glob('*_read_receipt.json'))];ledger['used_s']=6+sum(x['elapsed_s'] for x in ledger['measured_read_receipts']);ledger['remaining_s']=60-ledger['used_s'];assert ledger['used_s']<60;dump(P/'planning_ledger.json',ledger)
state=read(P/'engineering_state_current.json');state.update(execution_state='completed',stage='Read-only successor plan delivered; no EDA or production changes; current full-mode gaps explicit',next_step='Controller centralized complete-validation contract and independent budget; no long case automatically admitted',reported_at=dt.datetime.now(dt.timezone.utc).isoformat(),planning_read_used_s=ledger['used_s']);dump(P/'engineering_state_current.json',state);keys=('execution_state','current_task','stage','blocker','next_step','runtime_id','thread_id');dump(P/'console_report_current.json',{k:state[k] for k in keys})
dump(P/'planning_delivery_manifest.json',{'at':dt.datetime.now(dt.timezone.utc).isoformat(),'sealed_R001_R002_hashes_unchanged':before,'production_RTL_hashes_unchanged':rtl_before,'TB_runner_hashes_unchanged':tb_before,'planning_read_ledger':'planning_ledger.json','files':[{'path':str(p.relative_to(ROOT)),'sha256':sha(p),'bytes':p.stat().st_size} for p in sorted(P.iterdir()) if p.is_file() and p.name!='planning_delivery_manifest.json'],'source_document_append_only':[str((M/'source'/n).relative_to(ROOT)) for n in ['design.md','results.md']],'no_EDA':True,'no_old_budget_changes':True})
print('FULL_PARENT_READONLY_PLANNING_DELIVERED '+json.dumps({'planning_used_s':ledger['used_s'],'planning_remaining_s':ledger['remaining_s'],'parent_sha256':identity,'gold_layout':'131072+131072 PASS','production_and_sealed_records_unchanged':True},ensure_ascii=False))
