from pathlib import Path
import json,hashlib,re,datetime,xml.etree.ElementTree as ET
ROOT=Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS');M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine';T=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn';E=ROOT/'project/E007_m006_full_fpga_attention/experiment_results/runs/R001/attempts';R=ROOT/'project/E015_m007_tanh_geglu8/experiment_results/runs/R001'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
release=json.loads((R/'release_evidence_v1.json').read_text());selected=[]
for rel,digest in release['selected_sources_sha256'].items():
 p=ROOT/rel;actual=sha(p);selected.append({'path':rel,'sha256':actual,'equals_AT055_release':actual==digest});assert actual==digest,(rel,actual,digest)
origin=json.loads((M/'rtl/strict_exp_ii1_167/ORIGIN.json').read_text())
for f in origin['generated_files']:assert sha(M/'rtl/strict_exp_ii1_167'/Path(f['path']).name)==f['sha256']
syn=E/'AT003_strict_exp_unshared_pipeline_300mhz_pilot/hls_project/solution1/syn/report';hls={}
for n in ['attention_exp_leaf','attention_exp_bits','attention_f64_add','attention_f64_mul']:
 p=syn/(n+'_csynth.xml');x=ET.parse(p).getroot();hls[n]={'path':str(p.relative_to(ROOT)),'sha256':sha(p),'resources':{v.tag:int(v.text)for v in x.findall('.//AreaEstimates/Resources/*')},'evidence_stage':'HLS hierarchy estimate, NOT Vivado joint synthesis','latency_cycles':int(x.find('.//SummaryOfOverallLatency/Best-caseLatency').text)}
reports={}
for n,folder in [('tanh_mul4','AT010_mul4_io_ooc'),('tanh_div12','AT021_div12_radix4_io_ooc'),('tanh_add3_e','AT044_add3_exponent_align_io_ooc')]:
 p=R/'attempts'/folder/'work/report.json';x=json.loads(p.read_text());reports[n]={'path':str(p.relative_to(ROOT)),'sha256':sha(p),'resources':x['resources'],'WNS_ns':x['WNS_ns'],'WHS_ns':x['WHS_ns'],'evidence_stage':'Vivado synthesis+opt single leaf; all hold open, no P&R'}
core=(T/'rtl/laya_m007_tanh_lane_v1.sv').read_text().split('module laya_m007_tanh_lane_v1',1)[0];regs=re.findall(r'\breg\s+(?:signed\s*)?(\[\s*(\d+)\s*:\s*(\d+)\s*\])?\s*(\w+)\s*;',core);widths={n:(abs(int(a)-int(b))+1 if a else 1)for _,a,b,n in regs};targets=set(re.findall(r'always\s*@\(posedge clk\)\s+(\w+)\s*<=',core));targets.add('valid_pipe');assert not targets-set(widths)
# Actual source declarations, not estimated physical register mapping.
def pool(width,tag,lat,lease):
 return {'payload_bits':width*256,'tag_bits':tag*256,'available_bits':256,'issued_valid_bits':lat,'pointer_counter_fault_bits':43,'lease_and_local_fault_bits':lease,'metadata_bits':tag*256+256+lat+43+lease}
a=pool(256,11,167,138);b=pool(512,104,152,134);c=pool(512,104,167,138)
files=[M/'rtl/laya_sfu_exp8_v1.sv',M/'rtl/laya_return_vector_credit_v1.sv',M/'rtl/laya_attention_resources_v1.sv',M/'rtl/laya_attention_layer_engine_v1.sv',T/'rtl/laya_m007_tanh8_v1.sv',T/'rtl/laya_m007_tanh_lane_v1.sv']
files+=list((M/'rtl/strict_exp_ii1_167').glob('*.v'))+list((M/'rtl/strict_exp_ii1_167').glob('*.dat'))
obj={'observed_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'owner':'A007','stage':'bounded static source/interface/resource audit ONLY; no RTL edit, no EDA, no new experiment/budget','authority':'A001 resumed2026-10-22; SM011 TANH-G8-08 and SM012 SINGLE-PARENT-11; E010/R004 remains frozen','current_sources':[{'path':str(p.relative_to(ROOT)),'sha256':sha(p)}for p in files],'TANH_selected_sources_match_release':selected,'EXP_origin_exact':True,'current_EXP':{'raw_lanes':8,'F64_add_per_lane':6,'F64_mul_per_lane':6,'F64_mul_integer_subproducts_per_node':{'32x32_to50':1,'32x32_to64':3},'ROM_per_lane_bits':54*32,'legacy_tag_bits':11,'credit_LATENCY':167,'HEAD_BYPASS':1,'actual_accept_to_first_consumable_no_stall_cycles':167,'actual_return_evidence':'E010/R002 AT011 head-return service and frozen complete head observers; old buffered168 is separate version'},'current_TANH':{'raw_lanes':8,'F32_nodes_per_lane':{'add':23,'mul':17,'div':2},'core_edges':152,'credit_LATENCY':152,'HEAD_BYPASS':0,'actual_accept_to_consumable_no_stall_cycles':153,'main_inputs':release['tanh8']['main_inputs'],'functional_evidence':'E015/R001 AT055; full8lane functional/protocol PASS, NOT 8lane OOC/physical300MHz','core_visible_posedge_alignment_and_valid_bits_per_lane':sum(widths[n]for n in targets),'core_visible_posedge_alignment_and_valid_bits_eight_lanes':8*sum(widths[n]for n in targets),'TANH_generic_mul_projection_caveat':'mul0/1/2/3/4/6 have literal/selected-constant operands; instantiated specialization may change DSP mapping, not measured here'},'resource_evidence':{'EXP_HLS':hls,'TANH_single_leaf_OOC':reports,'EXP_same_source_F64_add_OOC':{'source_sha256':'56574c4d89a8cac3fd7c78ca19680cafa3e7fc368933fb2363dac40d4f607f2e','path':str((E/'AT012_strict_exp_f64_add_ooc_120s/work/utilization.rpt').relative_to(ROOT)),'LUT':3376,'FF':1923,'DSP':0,'boundary':'single generated helper, incomplete IO timing constraints, no P&R'},'EXP_F64_mul_OOC':'AT011 fixed120s COST_STOP, no final DCP/utilization; do not claim16DSP measured','EXP_complete_leaf_OOC':'AT004 fixed120s COST_STOP; no leaf/8lane joint implementation result'},'nominal_DSP_projection':{'classification':'EXISTING_TWO_ARITHMETIC_GRAPHS_PLACED_TOGETHER_STATIC_PROJECTION_ONLY_NOT_JOINT_SYNTHESIS_FAIL','EXP8_HLS_nominal':8*96,'TANH8_17_generic_mul2_nominal':8*17*2,'SFU_only_nominal':8*96+8*17*2,'extra_joint_cap':896,'SFU_nominal_over_cap':144,'quant32_same_generic_leaf_nominal':64,'G_outer_56_generic_mul_nominal_not_implemented':112,'nominal_with_quant_G':1216,'caveat':'Mixed evidence stages and constant specialization; cannot sign actual fit or refute method. No phase-exclusive FF/DSP savings credited.'},'single_pool_candidate_NOT_IMPLEMENTED':{'EXP_existing':a,'TANH_existing':b,'unified_candidate':c,'real_shared_payload_saving_bits':a['payload_bits']+b['payload_bits']-c['payload_bits'],'real_shared_metadata_saving_bits':a['metadata_bits']+b['metadata_bits']-c['metadata_bits'],'candidate_payload_bytes':c['payload_bits']//8,'candidate_metadata_bytes':c['metadata_bits']/8,'parent_4KiB':'Not free space; preserve service tag/credit/numerical pipeline in physical ledger once; parent added request controls separately counted','mode_invariant':'phase3/EXP andphase1/TANH fixed per lease; do not change until accepted requests, held return and actual external phase debt retire','delay_rule':'Runtime expected-return age167/152; runtime bypass EXP1/TANH0, preserve measured consumable167/153. Do not add15TANH cycles.','tail_rule':'A167bit common issued_valid must force unused high15bits zero in TANH and/or clear history only at true-empty lease transition; otherwise old TANH tokens could appear as false EXP due returns.','external_adapter':'Legacy EXP zero-extends11tag to96 and returns low11 underphase3; TANH keeps96tag+8mask. One full owner lease, one real reservation/available/payload/tag pool.','different_error_contracts':'EXP retains finite<=0/context64-row check and mode0/phase3; TANH mode1/phase1 accepts nonfinite as held per-lane status, nonzero mask, full request identity. Do not impose EXP domain on TANH.'},'unshared_without_explicit_implementation':['sixF64add/sixF64mul EXP graph versus23F32add/17F32mul/twoexactF32div TANH graph per lane; formats and per-operation rounding differ','TANH152edge alignment/valid state:464208 source bits over8cores, helper internal state additional; not removed by inactive phase','EXP8 independent32x54bit ROM read instances;8different lane indices require8read paths, no single-read ROM sharing claim','TANH internal16division nodes not the separate sharedDIV8 Q/LN/softmax service; cannot time-shareDIV8 and retainII1/153 by assertion'],'minimum_future_measurements_NOT_AUTHORIZED_OR_RUN':[{'order':1,'scope':'Existing32x32_to50 and32x32_to64 generated partial product leaf separately; actual DSP48 mapping/resource/checkpoint with complete IO/clock constraints','reason':'No existing fullF64mul OOC DSP result; cheapest new closure measures current product primitive before wide hierarchy','required':'new budget, actual same-source small pilot<=120; no identical old timeout rerun'},{'order':2,'scope':'F64mul exact six-file dependency closure, optionally bottom-up using newly measured exact partial products; verify binary64 strict vectors/latency16/II1/CE/reset and zero blackbox before larger EXP','dependencies':['attention_exp_leaf_attention_f64_mul.v','attention_exp_leaf_mul_32ns_32ns_50_2_1.v','attention_exp_leaf_mul_32ns_32ns_64_2_1.v','attention_exp_leaf_sparsemux_7_2_64_1_1.v','attention_exp_leaf_sparsemux_7_2_12_1_1.v','attention_exp_leaf_sparsemux_15_6_64_1_1.v'],'required':'actual cost gate and new budget, do not restart oldAT011 with only larger timeout'},{'order':3,'scope':'mode-aware one-pool interface prototype with unchanged raw cores, under future contract: actual maxcredit256/held last/release debt/phase switch167->152->167/reset/error/tag/context/mask and EXP/TANH complete independent values','reason':'Validates physical metadata reuse and latency without claiming DSP closure; raw arithmetic both still counted'},{'order':4,'scope':'One exact EXP raw leaf full12file closure and one full current TANH raw lane resource reports before8lane/combined synthesis; decide constant-specialization or dual-precision integer product redesign only from measured results','required':'No two complete wrapper stacks; no 896 cap orTANH160 relaxation; no current EDA authorization'}],'not_blocking':['E016 existingEXP-only parent integration','A008 G production engine per its own scope'],'production_files_changed':False}
path=M/'source/m007_sfu_unification_static_20261022.json';path.write_text(json.dumps(obj,indent=2)+'\n')
md='''# EXP/TANH 统一 SFU 的有界静态核对（2026-10-22）

本记录只有现源、既有报告与接口审查；未改生产 RTL，未启动仿真/综合，未建立新预算。E010/R004 仍冻结。A001 决定后继合同前，不把两个完整 wrapper 放入生产父级。逐源 SHA、原证据和机器账见同名 JSON。

## 现状和同口径延迟

| 项目 | 当前 EXP8 | 当前 TANH8 |
| --- | --- | --- |
| 独立数值图/每lane | 6个F64 add、6个F64 mul；每mul实际4个32×32整数子产品 | 原23个F32 add、17个F32 mul、2个精确F32 div |
| 请求 | mode0/phase3，11bit row/chunk；有限且≤0，实际64row context检查 | mode1/phase1，完整request/gen/epoch，96bit opaque tag、8bit非零mask |
| 错误 | 非法domain/context在接收前拒绝；意外leaf status是原协议故障 | 非finite输入形成可保持、可消费的逐lane数值status |
| credit/返回 | LATENCY167、HEAD_BYPASS1；无停顿从接受到首次可消费167拍 | core152、LATENCY152、HEAD_BYPASS0；无停顿首次可消费153拍 |
| 已有功能 | 原完整softmax/head中的实际EXP值和167拍服务 | E015 AT055全部336262主输入、42节点、153拍II1、满256信用/held/reset/错误消费PASS |
| 未有的物理结论 | 完整EXP单lane/8lane OOC均未通过；已有成本停止 | 8lane OOC/组合fit未测；小leaf setup正但hold仍失败 |

这里“可消费”指原`rsp_valid`能进行真实`valid&&ready`消费的边沿，无外部反压。不能把raw core152与EXP可消费167混算，更不能统一补齐到167raw后令TANH可消费168拍；TANH上限仍160。

## 最小可实施的接口切口（候选，未实现）

保留一份完整owner lease（request64/gen32/epoch32/head4/phase3）和一个实际256slot返回预约池。mode随lease固定：phase3为EXP，phase1为TANH；旧owner的接受事务、held返回、caller真实外部债未清之前不切mode，不用reset换phase。

规范请求使用8×F32、完整request身份、96bit tag和8bit mask；返回保持96bit tag、mask、8×F32及8×32bit原status。EXP薄适配显式`{85'b0,tag11}`并只在EXP响应取低11位，保留原context检查。TANH保持全部opaque tag，不能压入旧11bit。原purelayer/当前E016生产接口本轮不变；未来适配由合同明确后显式接线，不依赖端口隐式扩位。

现固定延迟credit不能直接复用为一个常量LATENCY实例。单池需按已锁phase检查实际返回年龄167/152，并分别采用EXP实际头返回旁路、TANH原缓冲返回，保持167/153口径。共用167bit issued-valid时，TANH只更新有效低152位并令高15位真实为零，或在真实空闲lease交接清历史；否则已消费TANH的尾历史可在切EXP后误报“到期返回”。不是把未退事务清零。所有slot只由真实接受/返回/消费推进，保留满信用、同沿消费复用与held稳定。

| 声明账，尚未实现共用 | 两个现wrapper合计 | 候选单池 |
| --- | ---: | ---: |
| 返回payload | 24576B（EXP8192+TANH16384） | 16384B，保留TANH全部status；真实复用才省8192B |
| tag+available+issued-valid+指针/债/fault+lease | 30629bit /3828.625B | 27228bit /3403.5B，候选省3401bit /425.125B |
| 其中统一tag/mask | 两份tag，2816+26624bit | 一份104×256=26624bit |

账按现源指针3×8、pending/inflight各9、fault1，EXP lease/local138bit、TANH134bit；候选沿EXP138bit、mode由phase派生。接口最终若新增寄存器必须另加。服务credit/tag和数值流水仍在物理总账一次计入，不是释放给父4KiB的免费空间；父新身份/计数另账。

## 当前不能据相位直接共享的实体

- EXP F64与TANH F32的精度、舍入位置和延迟不同，不能把TANH换成F64图后只在末端cast，也不能把17个F32乘法直接接六个16拍F64叶子来声称仍153拍。真正共DSP乘积需要新的明确整数产品/多精度接线与完整逐节点证明。
- TANH八个core仅可见posedge对齐/valid就有464208个源声明bit（每lane58026，含valid152）；不含其42算术叶内部状态。这是源声明位数，不是实综FF。inactive phase不会使这些状态自动消失。
- EXP每lane有32×54bit只读表及独立读路径。八lane可用不同index，不能将八个单读ROM直接当一份单读ROM。TANH没有同表的可等价替代关系。
- TANH内部16个F32除法节点与Q/LN/softmax唯一DIV8不是同一物理角色；无新调度/延迟证明不能借DIV8串行化。

## 896DSP风险与现成物理证据

EXP `attention_exp_leaf_csynth.xml`的层级总数为96DSP/88455FF/74634LUT，每lane有六个HLS估16DSP的F64mul。顶层RTL属性的DSP0只表示该层自用，不能忽略子实例。当前同源完整EXP没有实综资源。旧F64mul AT011/完整leaf AT004分别在固定120秒成本停止，不能写资源FAIL或零DSP。

当前TANH mul4单leaf综合+opt为2DSP，add3_e和div12均0DSP。现有两个算术图并置、按17个通用mul2DSP/每lane投影：EXP8的768 + TANH8的272 = **1040DSP**，比额外896帽多144；若再按quant32×2和G外侧56×2投影为1216。**这是混合HLS/小leaf证据的静态投影，不是同版联合实综FAIL，也不是方法已被反驳。** TANH mul0/1/2/3/4/6有常量或选定常量操作数；EXP也有常量端口，实际特殊化可能改变DSP映射，不能把通用leaf乘法视为联合实测。

| 可复用的现成资源报告 | 实际DSP | 边界 |
| --- | ---: | --- |
| 同SHA EXP F64-add AT012 | 0；3376LUT/1923FF | 单helper综合，非完整EXP；IO约束不完整，无P&R |
| TANH mul4 AT010 | 2；442LUT/120FF | 单leaf综合+opt，setup+0.332ns、hold失败 |
| TANH add3_e AT044 | 0；527LUT/208FF | setup+0.098ns、hold失败 |
| TANH radix4 div12 AT021 | 0；2266LUT/828FF | setup+0.182ns、hold失败 |
| 现quant使用的shared F32 mul，E008 AT017 | 2；459LUT/326FF | 单leaf旧约束边界；quant32实际例化，未将投影改标完整quant资源 |
| 现shared direct DIV，E008 AT013 | 0；1806LUT/1594FF | 单leaf；不覆盖TANH内部div角色或8lane联合资源 |

因此单一mode-aware lease/池可成为明确的小切口，但它本身不会消除两个数值图的DSP、LUT或pipeline状态。当前不能申报896闭合；不得以phase互斥从声明中减掉实例。

## 最小可执行测量建议（未授权、未运行）

1. 先测现生成32×32→50和32×32→64两个partial-product helper，确认实际DSP48映射和完整约束/zero-blackbox报告；未知pilot≤120，另立预算。
2. 再测F64mul最小六文件闭包：mul主文件、两个32×32 helper、sparsemux7/64、7/12、15/64。可在新实测child成本后以精确DCP底向上组合；不能只给旧AT011原样加帽。复用原独立F64向量作新的RTL输出检查，原CPU/CSim通过不冒签RTL。
3. 新合同内实现单池时，先跑真实256满信用、末held阻切换、167→152→167双向phase、错误/mask/context/tag、在途reset，保持全部原独立函数输出。这样签接口/metadata复用，仍不签算术共享或DSP fit。
4. 有小闭包成本与真实资源后，才选择完整一lane EXP（全部12个原生成文件含dat）和当前一lane TANH资源测量；据常量特殊化/乘积真实mapping决定是否需要等价整数产品重构，再讨论8lane联合。保留896和TANH≤160，不改变原算法。

E016当前EXP-only父接线与A008 G可在各自合同继续，不以新SFU物理方案作为前置。本记录交A001集中决定后继合同；A007只提供接口支持，不已实现上述候选。
'''
(M/'source/m007_sfu_unification_static_20261022.md').write_text(md)
print(json.dumps({'static_report':str(path.relative_to(ROOT)),'production_files_changed':False,'payload_candidate_saving_bytes':(a['payload_bits']+b['payload_bits']-c['payload_bits'])//8,'metadata_candidate_saving_bits':a['metadata_bits']+b['metadata_bits']-c['metadata_bits'],'DSP1040':'nominal juxtaposition projection, not measured joint failure','TANH_release_match':all(x['equals_AT055_release']for x in selected)},indent=2))
