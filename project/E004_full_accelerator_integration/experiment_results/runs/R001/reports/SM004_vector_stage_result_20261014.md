# SM004 精确F32向量残差阶段结果

M004/SM004/E004/R001；A002；2026-10-14。当前仅为固定图vector服务的局部实现和测量，不是完整模型硬件请求、整图性能或物理Fmax。源/输入/工具身份、各attempt原guard及DCP SHA见[机读证据](SM004_vector_stage_evidence_20261014.json)；旧AT088–091软件基线保持原范围。

## 叶子选择与流接口

AT092、AT098冻结原`tanh_libm_round1_02`的FSM FADD与现有Attention CE ADD。前者在`ap_start=1`且固定`0+0`时，实际`ap_ready`出现在cycle 1,4,7,…，即该刺激的连续接受间隔3拍；这不是全部F32域的II测量，不能用旧22拍slot延迟推断它每拍接收。CE ADD在52组原directed F32对上连续每拍喂一组，输出在第5个后续采样周期全部52/52逐bit等于原独立RNE样本；中途CE停3拍时输出保持，恢复后按有效时钟序列继续匹配24组，复位后16组检查通过。其无独立valid口，wrapper按实际流水延迟携带valid和顺序号；选择的叶子SHA为`19ff024047daea86c0a10b27a464d3c27506e3dcb5990d3877fa68343a8422b7`。

新单lane `laya_vector_add_stream_v1.sv` SHA `417c12d7b1c0717426419d7fe71056ef68f12f00039e0ee7c3234fa27698b494`，accept时预约32项总未消费容量；第6个后续上升沿写回有序结果，输出消费才归还credit。AT093真实4096对AT050四行skip/Down及独立末输出gold逐bitPASS。无反压4096次接受连续每拍、末消费共4103cycle（从case首周期到完成）；确定性输入空拍/输出反压为6444cycle、输出阻塞2340cycle、峰在途32。16项在途局部reset清空后无旧结果，32项新批次通过；accept/return/consume各为4096、4096、4096，backpressure case同样守恒。此复位只签本地流，未签AXI未退休事务复位。

## 双源读与末B服务

AT097旧服务将4096项编码为单个256拍/16KiB AXI4 INCR burst，跨越4KiB页界；其正常6928cycle、反压7185cycle、逐bit数值和W保持是旧非合规TB的局部观察，不作为当前总线服务性能或合规结论。AT100首次修正冻结版静态编译因TB两个局部标识拼写错误失败（原log/receipt保留）；只改此TB错误后冻结AT101。旧AT094–099原日志与源身份不回写。

AT101服务RTL SHA 13e98045e1ecb1d09e22a04ebe71848e42747d781d7015fba836e3c720092445。每个chunk取剩余beat及三路当前64B对齐地址距各自4KiB页尾的beat最小值；三路各自AR/R、AW/W/B，段内LAST，B握手后才推进三地址和下一段。输入及ADD结果的exp=255判非有限，按原逻辑序号取最早元素；完成口done_bad_element成功为0xffffffff，数值错误E_NUMERICAL6附首错索引，总线响应错E_INTERNAL8。错误后已发AW仍给足W/LAST/B，WSTRB从坏元素起屏蔽，B错后下段全屏蔽，目的块不得视为有效。此服务仍无portal、lease、整图恢复或AXI在途reset功能。

AT101独立TB检查每条Ax地址/长度/size/INCR、addr[11:0]+64*(len+1)≤4096、段内R/W LAST、B债、W反压跨拍DATA/STRB/LAST保持、目的64KiB总窗口（16KiB正常输出＋48KiB邻区）与原AT050 4096项独立gold。一次冷reset后10条命令顺序执行，中途无reset。4KiB对齐正常与反压分别6955/7206cycle，均为8AR/512R/4AW/256W/4B、49152B总线数据；反压样本W阻塞246cycle。分别移动源0、源1、目标页内偏移的三个4096项样本各6991cycle、16AR/8AW/8B；70beat混合偏移短尾样本2005cycle、8AR/4AW/4B。非有限输入索引7、有限相加溢出索引2且后续索引5输入非有限，分别返回首错7/2；首RRESP和首BRESP错误分别返回8，所有已发事务排空，未报告成功，屏蔽区与邻区保持哨兵。10条case原log均有VECTOR_AXI_CASE_PASS且最终VECTOR_AXI_PASS，guard child0/null。该证据是受控局部AXI模型，并未测真实HBM、整体固定图或物理服务资源。

## 局部OOC与成本

AT099只综合与AT093/AT097逐SHA相同的**单lane流封装＋CE ADD**，目标`xcu55c-fsvh2892-2L-e`，时钟请求6.667ns（约150MHz）。Vivado 2025.2 out-of-context综合实际1283 CLB LUT、614 CLB FF、0 DSP、0 RAMB36/18、0 URAM；其中89 LUT作memory（20 distributed RAM、69 SRL）。blackbox0，DCP已生成。综合内部setup WNS +3.057ns、最差寄存器路径约3.592ns、hold WHS +0.032ns；67输入/34输出缺外部delay且OOC未设置`HD.CLK_SRC`。这些不构成布局布线Fmax、总线服务资源、完整图fit或加速比。

已执行受守卫工具的实耗累计：静态44.381434s/1200s、RTL与pilot 34.727431s/900s、唯一OOC 78.220358s/900s；各单次均低于相应600s、300s、900s帽，guard触发均null。OOC峰owned RSS4215772KiB，全部实测MemAvailable最低仍高于192GiB。冻结/转换等轻量host准备没有独立owned RSS/policy采样，不能补称这部分已完整计量；未发生预算停止。没有P&R、完整硬件请求、旧FFN full、GPU或上板。

本阶段为**AT101局部向量接口与AXI4页界/finite受影响短测限定PASS**。下一步仍需A001在同M004确定LN、Attention、矩阵与tail的最简共享实现和全图连接；本模块独立样本不证明整图吞吐、跨层scratch复用、外部sequencer或完整软硬件等价。
