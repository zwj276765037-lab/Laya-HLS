# 修订22：唯一矩阵服务、STEP16与真实首TN8写回

2026-10-16；D-M004-A16-MATRIX16-01；A001→A002；M004/SM004/E004/R001。承接[修订21成本出口](ln128_wprep_q16_rev21_at383_closeout_decision.md)，正式实施[已接纳接口](a16_matrix16_interface_decision_20261016.md)及[原架构AT368后继章节](../../source/fixed_graph_architecture_20261014.md#at368首a16之后现生产接口上的matrix16增量2026-10-16)。这是新增矩阵生产功能及验证范围，不是AT383父LN超时路径原样追加额度。工程按本段独立预算连续实现、编译、修复和验证，不逐步等主控或用户批准。

## 起点、职责及保持项

起点为AT382父sequencer9abc446e…、wrapper3a11446a…、core920d804f…，及AT368/379共用上层e2be4e1e…、下层30816465…、W服务519a2ccb…、cache6d13fae4…。完整SHA与实际依赖以AT382/379冻结及本轮新manifest为准。修订21余605.50865154154599468s/323.3846215400844935s封存不转移；历史FAIL/COST_STOP保持。

A002仍是E002生产RTL/TB、模块design/results与E004证据/三摘要的唯一写入者；A001维护合同/审核，A003维护source。其他角色仍在工作，不撤销或覆盖他人改动。不新增agent。复用原四套row pipeline、FP/tag/credit、唯一front、W cache、LNQ、8×656×32bit bank、原reader和writer；不改算术、舍入/归约、clk/reset/CE、FP/IP、模型shape或独立gold。无HLS/OOC/P&R/新oracle。

## 必须落地的生产接口

1. **共同matrix服务及父调用。** 将父engine原矩阵LOAD/LEASE/FRONT_CFG/A_REQ/A_WAIT/W_REQ/W_WAIT/ISSUE/DRAIN/W_RELEASE及保持/Check迁为`laya_matrix_service_v1`；legacy Wi/QKV/Down和新STEP16由它执行，同一front和FP只有一份。原W服务/cache作为同级唯一供给，wp/legacy LOAD/lease/read/ret/release沿原固定仲裁；父engine保留LN/Q/G/ADD阶段选择。完整父图必须实例化独立测试所用同一服务，不能在独立TB另写矩阵调度、用第二cache或用生成参数删除实际生产必需模块来冒充完整父图。
2. **A16 claim与固定相位。** exec011单独准入，mode QKV、cold=0、rows16/K1024/N3072/bias0，window_row0固定16对齐，本段主例为0。锁存id、window_row0、source epoch、独立a_epoch、model3328/numeric672、task_context96、W slot0/epoch/key0001及RAW目的base/span/epoch。下层只读导出已持有的A描述符，cover=ffff、next_row16、prep/Q/response/done/feed及bank pending/rsp全部真退后claim；held A允许存在。不能沿用排除A16的service_quiescent，不消费假prep token。matrix_owned时禁止prep、Q16 fill、legacy LN/G/ADD抢占和结果reset。上层增加SL_MATRIX，固定切换同步结果读、PS写/读、writer rearm/segment路由，保留STATE1 norm上下文，不调用tensor_release。
3. **真实W事务。** W_PREP回执被消费后实际lease slot0/key0001/K1024/N3072，核slot/epoch/model/numeric/完整task身份及lease_done；每stripe读pair0/tile/group，逐返回核身份、mask和read_error。四block重复真实cache读，不新增预取RAM；READY或无AXI重载不等于读已执行。A claim后lease失败，真实排空/受控discard，不假发成功PS。成功全父或已决定错误并清债后才release W、确认release_done，再释放/丢弃A；cache保留READY，norm仍持有。
4. **同步A及PS单口。** A Q bank addr=34r+g；scale addr=34r+32+floor(g/16)，取bank=floor(g/2)%8及g奇偶half，half转换沿原位规则。四行每stripe共8次E0请求/E1响应，复用256bit held rsp，标签/数据保持至消费。A保持从256/32扩到1024/128bit，净payload+108B，控制位另列；不增bank/FIFO。PS仅addr544+r（原w4352..4479），末group四路commit按p单选真实写，未选保持；不得沿旧ready=1111同时丢写。已pending读先完成，末组写优先于新读；legacy原1R/1W规则保持。
5. **完整父描述符的STEP16。** front config_rows扩5bit，新增config_step16；legacy显式零扩展、step16=0。只config一次rows16/K1024/N3072完整父任务。服务产生严格tile0..383→block0..3→group0..31，front核sequence=((tile×4+block)×32+group)。step_done携tile/block、accepted32/row_retired128/terminal4及Check/rank，阻塞保持；front entry/PS/trace/credit、A/W响应及末组写真债零才换block。g0沿原PS0/poison0，四套算术不断reset。原完整expected_stripes=49152、行组退休196608；不能反复config rows4/N8得到伪父完成。
6. **隐藏PS写回与正确完成。** 一TN8四block完成后形成16行PS视图；有限有效mask、bad/poison和final_skip按原解释，不把全poison变成缺覆盖协议错。整tile保持时逐行同步读PS，沿原head-parity scatter计算QKV0/1地址、65bit溢出/跨度/逻辑域隔离检查；plane/head/d/row布局按研究固定公式。一个32B行段用原writer半beat strobe、64B对齐segment、tile_n0=n0%16，真实末B、flush撤下和债零才ps_retire。每TN8为16笔B/512有效字节/1024物理字节；STATE1 norm不写。全部384tile成功且W/A真实释放后才父matrix done；首tile或首A16不能发布全tensor RAW/FINAL/request_done。

## 首错与异常规则

exec011数值错误完整Check用op30/status16=6/detail0730000f及task-local bad=r_local×5248×128+(8tile+lane)×128+group，绕开core旧非legacy的row×4096重映射。成功status0/detail0/bad64全1；协议失败status7/detail07300005/bad64全1并保留实际路由诊断。本次命令的id/window/source/a/W epoch及全部声明Check字段锁存到done消费，阻塞时逐拍稳定，局部至少核三拍；本地拒绝不得复用历史服务done。排序key按原tile→local row→lane→group/phase，不用bad整数跨tile取min。当前TN8四block数值/poison归并后才能决定进入下一TN8；有数值错不发下一tile。

writer B错保存首store故障及路由/ordinal，真实排AW/W/B并停后续写；继续本16行全N剩余算术，后续正常PS受控discard且不增加成功B/写覆盖。后续首次失败TN8的数值Check优先，只有全384tile算术成功才报store7/detail07300005/bad64全1。不能把writer错接front abort或用已观察min提前结束。协议/tag/缺操作数错误真排空后失败，不补零继续；物理总线错误次序单列，不宣称CPU全请求首错等价。

固定局部反例在合法同步A/W响应peer上运行同matrix service/front、完整父描述符：A[row1,g31] scale7c00及W[tile1,g0,lane0] scale7c00，先完整tile0四block，返回6/bad671775且零tile1读取；去掉A故障后真实到tile1返回1024。移A故障到g0覆盖poison/final_skip；tile0实际B错＋tile1数值错检验store延后和数值优先。不能把非finite W放入真实LOAD后绕过现前检。首tile局部不能签纯store最终完成或完整全N；若未实际跑完须明确NOT_RUN。

## 验证出口与参考

主例为独立**实际生产组合**同runtime：真实STATE0/AUX→LN128/norm写B→冷W→真实STATE1首16行Q→A16 claim→W lease→第一TN8真实矩阵→PS和QKV scratch写B。TB只作合法请求caller和AXI存储peer；不预填norm/A/覆盖、模拟W完成、逐stripe调度或force内部债。真实首TN8终点观察即结束TB，不增加“只算一个tile即成功”的生产模式。

保留前缀原checker，新增核：1024次同步A请求、128次真实W read/ret、128stripe、512行组退休、128个final、16笔OKAY B及一次ps_retire，A/W仍持有、无父完成/RAW/FINAL。跨阻塞的实际握手/标签/计数逐项记录。前4行六字段6144个u32及32个final对原qkv_rows4独立参考；dot字段是int32位型。索引/父SHA沿已接纳研究记录。后12行仅独立norm及真实Q/矩阵搬运、finite/覆盖/保持，叶子观察值不作独立算术gold。尾部复扫STATE1 norm未变、A未被PS覆盖。

局部先验证真实bank/cache接入的claim/lease/read/ret及有限A rsp/W ret/末group commit/末B阻塞；受影响reset、epoch拒绝及错误恢复在合法公开接口施加，不能虚构ready。legacy同matrix服务的受影响正常/错误短兼容可用原保存Q/W或合法peer，明确边界；不原样重跑旧全FFN长基线。父core实际exec011代理在合法模块入口检验，不能用仅测试下层服务代签core委派。

完整父top必须用最终同版服务实际重新展开并核唯一实例/固定接线。未来父动态W/Q测试台须补真实W三路/AUX与STATE1 peer、phase相关禁止访问及A16/首TN8终标；AT382/383的W禁用/STATE1绑零/LN128就finish的TB仅保留作旧LN前缀，不延长它冒充完整链。父图若没有合法模块边界可局部到达exec011，记录静态和所达前缀，不force128覆盖；父完整同runtime仍须独立证据。这一欠账不阻塞本段独立真实矩阵主例。

## 独立预算与自动运行边界

本段新host准备累计300s/8GiB，static/IP累计1800s/24GiB、单次≤600s；RTL累计3600s/8GiB、单次≤1800s/40Mcycle。CPU0–3/nice19/idle、MemAvailable>192GiB、全项目一个重工具，120s真实语义停滞保护；单次帽还不得超过当时累计余额。失败/构建/诊断/局部/主例全部计费，旧修订不回填；完整host未知如实UNKNOWN。static计划保留400s给最终父图重建及受影响修正，不是额外额度。复用已冻结未变FP/IP闭包，所有改动源/TB重编；优先一次集中构建多种合法场景，避免每搬几根端口重建重图。

未知路径先固定≤120s pilot。最终独立组合层取得真实完整LN16前缀成本；另以同版实际W服务完整冷载、Q16合法保存norm局部样本、真实matrix/front完成首TN8的局部样本测新增成本。局部可经合法prep建立A16及真实W载入，错误顺序可用上述A/W peer，全部按边界报告；样本不能代签主例，且不为cost模式改生产shape/算法。

自动主例门为：局部功能通过，有完整样本且至少按2.5×(8×T_LN16+T_Wcold+T_Q16+T_first_TN8)作保守计划估计≤1440s，余RTL可容纳1800s，主例fixture/独立参考及实际closure已绑定。跨层次费用与尚未测适配开销分列UNKNOWN，此式不是数学上界/实测串联性能。满足即自行执行一次固定≤1800s主例；若任一局部120s未到完整出口，交实到前缀/COST_STOP，不动态加帽、不拿AT368的317s或父两行速率代填。普通功能修复在余量内继续；重复同一未变timeout不能重开预算原样跑。

当前不启动完整N3072父任务长跑、后7个A16、全RoPE/FINAL/Attention或完整重父LN128长例；这些保留后继实测范围，不删完整控制实现。集中阶段交付必须列同版生产身份/唯一实例、第一TN8实际范围、前4行数值与其余行传递、父图实际范围、Check与store未测分支、成本/周期/字节及失败记录。达到阶段出口或成本出口直接回传，不必耗尽预算，也不把所有历史控制排列设为下一计算阶段前置。M004/SM004仍running/unassessed。

实施派发`m004-rev21-closeout-rev22-matrix-dispatch-20261016`已于`2026-10-15T22:16:27.904307+00:00`送达原工程会话，turn`01a141a3-5df7-7db2-a8a6-7994715a150f`；保持既有工程角色/模型配置。送达不表示新RTL已完成，当前新阶段实测待交付。
