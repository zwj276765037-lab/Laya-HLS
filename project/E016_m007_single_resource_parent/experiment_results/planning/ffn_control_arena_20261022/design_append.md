
## M007 CONTROL-ARENA-16 FFN interface preparation (2026-10-22, A010)

本段只读准备已完成，无生产RTL修改/EDA/新数值gold；R003完整Attention父链completed/frozen不变。独立设计与原始字节证据见 [FFN planning](../../../../../../E016_m007_single_resource_parent/experiment_results/planning/ffn_control_arena_20261022/planning.md)、[mapping_byte_checks.json](../../../../../../E016_m007_single_resource_parent/experiment_results/planning/ffn_control_arena_20261022/mapping_byte_checks.json) 与 [source_versions.json](../../../../../../E016_m007_single_resource_parent/experiment_results/planning/ffn_control_arena_20261022/source_versions.json)。

唯一后继为公开norm_ff F32输入的Encoder0 FFN island：同quant/A K1024→同matrix Wi K1024/N5248→native双槽G→4×8拼32→同quant/A另一槽K2624→全成功与真实债屏障→同matrix Down K2624/N1024→公开Down输出。它尚不签R003后的真实residual/LN或完整Encoder。Wi每物理块s已含原列32s..32s+31和2624+32s..2655+32s；原0..81调度已经配对，0/41重排不成立。W cache slot、PS context、G slot虽均s[0]，但分别按真实W release、matrix第256拍输出消费及G的512向量/真实债清释放，禁止合并退休。

独立字节核对PASS：原Wi→x/gate671744值、原AT058全12字段4030464字、G41984向量地址、E012 Wi20992拍/671744值、167936个原Q8权重record/5709824B。G输出s→row→chunk，4笔8lane拼一组32F32以(row,group=s)直接量化；front/A支持此group-major顺序，无整G重排RAM。只需一份128B数值holding；17bit seq/full及新增cancel/owner等控制须实计入当前余482bit，4035.75B仍是投影。

Wi使用shared256/PS，G原56mul/16add池与TANH8独立，quant使用原32mul及phase5 DIV8；不能把G固定3/4拍通道接到8拍shared256。storage PS/G独立bankset且同真实phase1身份允许分束同时服务，不能用全局owner屏蔽合法束。现资源壳只有EXP8专用tag接口，G原96bit TANH/pool接线尚未加入父；validation_shell自带storage不得进入父。EXP/TANH联合物理共享、896DSP/300MHz仍未签。

确定接口缺口是G上游取消：现discard要求!active/needs_discard，Wi中途失败将使G等待缺失输入。后继须由当前G单一owner增加身份匹配producer_cancel、仅排已接受实际工作、保持取消回执并经真实discard/release恢复；不虚构全覆盖。front已有producer_close失败与partial/published未leased A取消。父按Wi→G(rank,row,col)→Q8(G)→Down原图顺序选择源错误，保留G32bit 0/6/8与matrix/front状态的显式适配；Down仅在Wi/G成功、成功close后的quant/A完整发布与全部真实债/lease退休后准入。

原生产出处：Encoder0 skip=embedding_norm；attention_residual=skip+WO；norm_ff=无gamma LN(attention_residual)；Wi→G→Down后回加同一attention_residual。当前R003未接skip保存/真实残差/LN/Down残差生产者，不能将WO直接喂Wi。原E012 Wi source与AT007 norm_ff、E012 Down source与AT007 geglu逐行完全相同数均0/128，旧矩阵gold不能签当前全链；独立原Q8(G)/Down同输入期望尚缺，本准备未生成。A007 live external-control源只作静态依据，不继承E015 AT146旧SHA PASS。完整验收和独立预算由主控集中下达。
