# E004：限定结果

既有AT091完整B1/S128软件基线对独立gold通过；AT101向量、AT110 LN首错、AT124算术在途复位与AT134 LN→Q局部数值/协议各保留原范围。修订8 AT138 U55C LNQ综合网表为37569 LUT/12543 FF/50 DSP/16 RAMB18，6.667ns内部WNS−1.408ns仍FAIL，未P&R。

修订9 AT148同版真实LN→Q→完整Wi冷/暖两命令各20992个PS/167936 lane-group及5248列final逐bit匹配独立同输入gold；LN 1024、Q 32group和真实W返回亦逐bit检查。冷/暖结果发布绝对cycle115019/190675，done118957/194613；W/AUX AR为656/656/82/1，暖零新增。AT150真实W返回标签错在issue16/预留11触发front abort，错误状态7、无发布、W/Q35债务零；无reset暖恢复前256个PS逐bit通过。AT151真实冷RRESP错使LOAD失败、三路reader债务排空且LN/矩阵未启动。AT152 front abort与issue/launch/最终完成同拍优先，AT155 abort=0原数值/拒绝/阻塞/局部在途reset回归通过。AT153原行参考与AT154硬件统计及1024个LN输出逐bit一致，mean=3c319f4e、variance=3e196272、inverse=40255b98。AT149旧guard未识别真实LNQ_WI进展而123.541269s语义停止，错误局部断言保留但整次COST_STOP。修订9守卫实耗static693.750471s、RTL含pilot1781.479534s/1800s、host已测0.824163s下界。详见同一阶段报告和原guard。

修订10 AT166同版真实LN→Q→完整Wi→canonical G→直接Q82组→Down连续cold/warm两命令各逐位匹配原独立同输入gold：每命令Wi 20992 PS、G 2624、Down 10496 PS、最终1024 F32；每命令真实W读/返、issue/PS均31488。两命令累计Wi AR656/656/82、Down AR328/328/41、AUX2，warm不增加W/AUX AR。消费者done绝对cycle178317/291678，命令握手相对延迟未单独记录。AT166 RTL1261.580029s/child0。AT168真实Wi行流水入口接受2/提交0/预留2及AT169真实G发射2/返回0/credit2分别在共同reset后观察510拍无ghost，限定隔离PASS；AT168原日志FP=2只是row_issue握手计数，未采真实浮点IP输入/返回，不能签FP已发未返；耗时203.568609s与521.349162s。AT167守卫误把复位计数归零判回退，202.464809s/child−9的COST_STOP保留。修订10截至AT169正确累计static1113.567624s/1800s、RTL含pilot3459.293175s/3600s，余RTL140.706825s；AT156–158四笔仿真44.618770s分类已纠正，host未全采样仍UNKNOWN。修复版bad/poison错误映射、错误后完整warm、复位后完整cold及主动内部反压/读释放竞争未实测；新顶层联合物理未知。详见[原阶段报告](runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)及AT166–169 guard/manifest。

修订11 AT173局部1024残差及finite/计数错误短例PASS；其完整运行最终FAIL_TB_AUX_STALL_COVERAGE_ZERO，但主控限定接纳真实FP发1返0、G发2返0各共同reset/510拍隔离后，cmd61完整cold到1024残差、cmd62实际W标签错排空、无reset cmd63完整warm到1024残差的Fatal前分项。AT174真实AUX首AR两拍停顿、1AR/8R至slot0 LOAD_DONE事件限定PASS；未断言停顿期间AR全部字段稳定。AT175 W首AR已接受、R0/64时共同reset，510拍所监测接口/活动计数无旧活动；下一slot0真实cold的W三口AR656/656/82、R41984/41984/5248与AUX1/8至LOAD_DONE事件限定PASS，未签完整FFN恢复。两探针均未在结束条件检查load_error==0、READY或成功lease身份，原日志无结束前状态采样；不签成功W槽或全系统债务排空。AT176外部scale+Inf被加载器拒绝，AT177的分段返回force版本在注入前发生TB bank不匹配，均FAIL且不能判断前端数值映射。AT178在450.400088s真实墙钟停止于Wi group21/约13779 PS，末组注入未到，COST_STOP。五次static/RTL费用连同AT170–173实账原guard精确累计1142.969831845/4724.407605240s，余RTL75.592394760s封存，不再重跑长前缀；host完整累计UNKNOWN。Wi/Down bad/poison状态6与协议7区分、内部主动反压、部分R后reset及本顶层联合物理仍未验证。见[原阶段报告](runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)和AT170–178原guard/manifest。

修订12固定顶层SHA54fe628f…下，AT184同runtime Embedding QKV row0冷/row1暖的norm、Q/scale、全部PS最终值和3072列final每行逐位通过；AT193进一步核两行196608个lane-group的dot/sa/sw/product/term/PS六字段、6144 final、全部512tile读/done、有限W/AUX AR和R空拍、ready时x/gamma停顿，及QKV驻留后FFN错矩阵warm状态7/phase3、零issue/AR。AT193整次仍因TB给初次slot1 LOAD错误epoch3而FAIL，不能签冷FFN。AT195另起真实QKV row0冷READY后FFN以Wi epoch2、Down epoch1各LOAD成功，Wi20992 PS与G2624逐位通过，Down停于issue9542/10496、commit9530/10496；1100.280453s守卫`trigger=timeout`而COST_STOP，未到末残差/消费者done。AT188两行检查后有限覆盖终端FAIL、AT191非法tile TB误注入FAIL、AT187 pilot timeout均保留。修订12总账static800.903263994/1800s、RTL3568.453182073/3600s，余31.546817927s封存；host完整累计UNKNOWN。详见[同一阶段报告](runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)与AT193/195原日志/guard；无完整FFN跨模式PASS、完整图或联合物理。

修订13 AT204同runtime真实QKV row0 cold写回成功、row1 warm最后norm B有限hold后返回非OKAY并排空；两行各1024 norm、32组Q/scale、12288组八lane PS六字段和3072 final逐位核对。每行512个读响应、两行合计1024个，512笔AW/W/B的三口地址、数据、WSTRB逐项检查；row0 status0/49 flush，row1 status7/phase12/48成功flush，row0位保留、row1未置位、failed=1、RAW未发布。随后无reset FFN cold按Wi slot0 epoch2/Down slot1 epoch1真实LOAD，Wi20992 PS、G2624、Down10496 PS、ADD1024及128tile残差消费者/release/done与原参考逐位通过；FFN scratch写增量零。AT204整次SCRATCH_FULL_CHAIN_PASS、child0/trigger null、RTL1404.050676294s。AT197 writer九例加rearm、AT198展开PASS；AT205/208为模拟row peer的128位覆盖/32768笔B响应、释放/边界及早期数值6局部PASS；AT207为DUT+AXI peer共同reset四触发/510拍隔离及局部恢复PASS。AT199/200/201/202/206原TB/静态失败保持。AT196–208冻结229项SHA及168项guard政策全匹配，AT204与AT194同名QKV30/FFN23份fixture逐字相同。原guard实耗static319.7074945475906148/1800s、RTL1455.8813096918165374/4800s，host完整总量UNKNOWN。逐attempt与适用边界见修订13机读账和既有阶段报告。

AT209以旧wrapper及合法局部FFN接口peer复现Fatal: FFN_DIRECT_ERROR_HANG，guard child1；新wrapper SHA9c55ae10…的AT210局部终态/身份和完整peer两笔RTL均child0，覆盖FFN非法tile错误done保持/消费及下一合法行、FFN错mode与QKV错row回显拒绝，真实release/core done及tensor状态按所测范围成立。AT210三目的逐口AW先6240/6240/4160、W先6240/6240/4160；AW阻塞拍7169/10175/5835、W阻塞拍7205/11046/6321，AW/W全部字段受阻保持及route/base/span至真B的175128次检查PASS，正常末B前禁成功、错误末B后禁成功。AT211同新wrapper和原真实core/IP闭包静态展开PASS；新wrapper未重跑完整真实长链，AT204仍只属于旧wrapper。AT209–211新增97项manifest/49项政策均匹配，累计截至AT211 static474.5678006708621898/1800s、RTL1473.8209624327718898/4800s；host UNKNOWN。AT204原消息的两行合计读响应应为1024；AT202原Fatal为phase6局部peer timeout，释放采样竞态是后续诊断。局部AXI peer未建实际BO/外存哨兵。

AT212旧wrapper SHA9c55ae10…真实首段4笔AW/W/B与一次flush完成同拍身份错误后Fatal: FLUSH_ERROR_HANG、child1；AT213新wrapper SHAdaae5611…同探针status7/phase12、真实release/core done各一次、AW/W/B仍4且零债，显式discard后新epoch2通过256笔B的局部合法行。AT213终态/身份及128位元数据/逐口AXI局部回归PASS；AT214真实core/IP静态展开PASS，80项输入仅wrapper相对AT211改变。新wrapper未重跑AT204完整真实链；旧AT204 PASS只属旧e5dde5cc…身份。AT212–214新冻结文件98项、guard政策56项逐项匹配；修订13累计static615.5153379254043043/1800s、RTL1498.1496843509375738/4800s，host总量UNKNOWN。详见同一阶段报告及追加机读账。

主控D-M004-REV13-CLOSEOUT-01独立核AT212–214为七笔guard（3 static＋4 RTL），98项冻结身份和56条政策采样匹配；前次交付的“六笔”是文字笔误，原guard费用和累计账不变。修订13按旧AT204真实长链与新AT213局部控制/AT214展开的分版范围收束；未用余额封存、不转下一段。

修订14 AT225旧wrapper SHA `b131526237fa63c52603b8a4c3ce4fbc4b0e52f70ed0418d8e3f5214a4de9c38`同runtime真实row0冷/row1暖正常链获主控限定接纳：原LN/Q/六字段PS/pre-QKV与两行4096个Q/K FINAL逐位对独立冻结参考；两行合计1024 core响应、512 RAW B、256 RoPE B、256 scratch R、64 table R，V/norm逻辑内存保持。每行仅RAW/FINAL两位覆盖，不发布完整tensor。AT225 RTL791.7965642139316s、child0/null。其完整Check字段显式断言仅覆盖每行末head，逻辑内存不是设备物理BO及完整邻区哨兵。

当前wrapper SHA `0d3e340e687d9720cdd2b1bed161adc7c4172a6c1310c08546011bc6c392e79c`修复行内Q/K顺序与AUX旧sticky error新load接受记债。AT232真实core/IP展开PASS；AT230局部双坏输入证明K/head0先于Q/head1报数值6/phase13/bad1024，原Check保留；AUX部分R后RRESP错、scratch R错、末RoPE B错真实排空及discard后新epoch局部恢复通过。AT241原叶子局部页尾scratch/table分段、两QKV口AW先/W先各32、总线阻塞字段与末B发布屏障通过；AT240以模拟core/快速叶子peer验证128行元数据和FINAL发布，不证明128行真实算术。AT233仅证明MUL已接受而HLS未采样时共同reset隔离；严格IP未返回窗口NOT_RUN。AT231旧wrapper错误复现及AT220/221/222/227/238/239原失败保留。旧AT225真实长链不能迁移为当前wrapper同SHA全链PASS。

[修订14阶段报告](runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)及[逐guard账](runs/R001/reports/SM004_rev14_guard_ledger_AT215_AT241_20261015.json)：53笔guard（static/IP26、RTL27），精确实耗978.93351217359304232/1800s与1241.301459711045058/4800s，host完整累计UNKNOWN。当前版本完整两行真实长链、实际128行producer、物理BO隔离、全请求首错、Attention/Encoder/整模、Host/HBM与联合物理均未验。

AT242同一局部TB四例逐项核code6/detail0740000f及完整64bit bad：cos[7]=Inf和x[63]=NaN先报7；末pair双半溢出先报31；仅上半溢出报63；末位预检NaN优先于前位潜在乘法溢出报63。四次结果均保持至消费，随后无reset以AT236保存s127/head15 Q的成功Check与64个输出逐位通过。生产adapter与原叶子不变，当前wrapper完整两行长链仍未同SHA复测。AT242 17份冻结SHA、两笔19条政策采样匹配，static22.975409511476755s、RTL5.7779527977108955s均child0/null、无Fatal/Error。修订14[逐guard总账](runs/R001/reports/SM004_rev14_guard_ledger_AT215_AT242_20261015.json)为55笔，static1001.90892168506979732/1800s、RTL1247.0794125087559535/4800s，host完整累计UNKNOWN；旧AT225真实链和新AT230–241局部结论及历史失败均保留原适用身份。异常Check短例不证明wrapper错误写回、全请求首错或128行真实算术。

D-M004-REV14-CLOSEOUT-01将AT242限定接纳为`PASS_SCOPED_ROPE_CHECK_EDGE_ORDER_AND_LOCAL_REUSE`，修订14按旧AT225真实两行、当前wrapper AT230–241受影响局部/AT232展开及原leaf/adapter短例分版有界收束。最终55笔guard实耗static/IP1001.90892168506979732s、RTL1247.0794125087559535s；未用798.09107831493020268s与3552.9205874912440465s封存，不转移。host完整累计UNKNOWN。AT227无政策采样；AT234四次reset仅序列末尾完成一条局部成功行，AT240没有实际begin5。旧FAIL/COST_STOP、严格MUL IP未返回窗口NOT_RUN及当前wrapper同SHA完整长链缺口不变。[最终阶段报告](runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)。

修订15 AT250旧wrapper取得一次固定S128请求内row0 cold→row1 warm真实STATE0/gamma→QKV RAW→full RoPE前缀，完整两行数值逐位PASS，仅两位覆盖且无请求/tensor最终发布。当前wrapper `d4856aee…`的AT264真实row0全链及紧凑逻辑内存输入只读/相邻行哨兵PASS；AT256 RAW-only gamma描述符拒绝、AT259早期读债故障排空、AT261 row127页尾读、AT262旧外部raw/gamma LN、AT263 prepared token、AT252 128行调度peer及AT260 legacy局部回归各按原端点限定PASS。AT251/255晚读错及复位恢复属旧wrapper；旧失败/timeout不回写。当前SHA没有同runtime真实两行或128行全请求成功。

[修订15阶段报告](runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)和[精确逐guard账](runs/R001/reports/SM004_rev15_guard_ledger_AT243_AT264_20261015.json)：42笔guard、static1769.133914342150093/1800s、RTL2768.097435323521494/4800s、402条政策样本零差异，host完整累计UNKNOWN。全128真实算术/FINAL发布、完整请求首错、Attention/Encoder/整模、物理BO与生产Host/HBM、联合资源/Fmax仍未验。

AT265固定S128 sequencer末行错误peer短例通过：128次行命令、127次成功行done及1次row127错误done实际握手；请求id208/row127/status7/phase14/bad全1保持三拍至消费，末位覆盖0、tensor FINAL不发布，未回绕发新行。仅调度/元数据范围，不签真实第127行输入读错或128行算术。[原RTL guard](runs/R001/attempts/AT265_SM004_rev15_s128_last_row_error_peer_01/guard_rtl/guard_result.json)与[AT243–265精确账](runs/R001/reports/SM004_rev15_guard_ledger_AT243_AT265_20261015.json)：44笔guard，static1773.706414608284832/1800s、RTL2773.568239858373999/4800s，413条政策零差异；host完整累计UNKNOWN。

主控D-M004-REV15-CLOSEOUT-01限定接纳AT265为`PASS_SCOPED_S128_LAST_ROW_ERROR_COMPLETION_PEER`，保留AT250旧wrapper两行真实前缀和当前wrapper AT264一行真实链的分版边界。最终44笔guard（21 static、23 RTL），static1773.706414608284832/1800s、RTL2773.568239858373999/4800s；累计1275项冻结身份、413条政策零差异，host完整UNKNOWN。余额static26.293585391715168s、RTL2026.431760141626001s封存，不转后继段；原失败/timeout保留。128行真实producer、当前SHA两行完整链、真实请求成功/FINAL及全请求首错等价仍未验。[主控机读审核](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json)。

## 修订16 FINAL→Attention消费者阶段证据（2026-10-15）

AT268旧adapter 5a44a3bc…在模拟发布peer下同runtime head0八tile/128query真实读算写通过：8200 AR、8704 R、512笔OKAY B，score/prob各16384项及ATT_OUT 8192 F32逐位。当前adapter 6d59c390…的AT270读/末B错误排空与无reset复用、AT271页界及AR/R/AW/W/B有限停顿、AT272 Q末R和K首R错误及后继正常tile均局部通过；当前SHA八tile未重跑。原失败/Fatal照旧保留。AT266–272共21笔原guard，static308.28305006958544s、RTL1094.2193052433431273s，231条政策零失配，host完整UNKNOWN。逐笔身份、结果及覆盖限制见阶段报告与机读账；不签真实128行上游交接、其他head、完整Encoder或物理资源/Fmax。


## 修订17 LN128/Q16 有界证据（2026-10-15）

当前core/wrapper/sequencer SHA为39b3bf4b…/5c88716f…/a4c999e5…。AT297同版真实固定请求120秒pilot只退休row0/1，gamma256 R、source128 R、2048项norm在W处逐位对保存gold、128笔OKAY B；row2已读未退休，guard timeout/COST_STOP，没有真实NORM_STAGE_READY。AT290保存row0/1 norm的Q16局部16行4352字、512个Q响应通过；AT292四种输入/总线错误及无reset恢复、AT294合法peer的窗口store与数值优先级、AT296真实row0末B错后row1 LN受控discard与新epoch恢复分端点通过。AT298/299模拟128行元数据与阶段ready共同reset 510拍只签peer控制；AT300当前leaf mode00/direct2624原gold短回归通过，不代签整core跨模式链。

[工程交付](runs/R001/reports/SM004_rev17_staged_lnq_engineering_handoff_20261015.md)及[逐guard账](runs/R001/reports/SM004_rev17_guard_ledger_AT273_AT300_20261015.json)：54笔原guard，static1690.9283452630042897/1800s，RTL1660.9250732809305405/3600s；1817项冻结文件SHA与400条政策零差异，host完整UNKNOWN。AT297等旧失败/timeout原样保留。完整LN128、Q16父图接续、矩阵/RoPE/FINAL、真实Attention连接及联合物理仍未验。


D-M004-REV17-REVIEW-01追加勘误：28份manifest实际1821项冻结文件，原账1817漏计AT273四项字符串SHA，四项补核零差异；AT297全次source R=192，其中退休row0/1对应128、未退休row2为64。54笔guard/400政策与static1690.9283452630042897s、RTL1660.9250732809305405s原数不变。[机读勘误](runs/R001/reports/SM004_rev17_guard_ledger_erratum_20261015.json)保留原账SHA与四项逐字节证据。主控已将修订17余109.0716547369957103s/1939.0749267190694595s封存。AT290满Q16窗口PASS不覆盖部分窗口占有缺口，后继修订18处理。


## 修订18 Q16修复与LN128成本出口（2026-10-15）

AT302旧版真实复现部分Q16窗口的A row0首字覆盖、cover未清；AT303当前core局部阻断kind00/01/11和legacy/LN准入，原272字保持，后续合法行、abort持有和partial discard后新epoch逐位通过。AT304默认/AT305 `--O3`固定30000cycle前缀38条真实事件逐字一致，各核2048norm/128笔B，全次source192R含未退休row2的64R；RTL guard93.29140920005739s/89.64230179227889s。AT306同版完整请求TB的120秒pilot仅退休row0/1，child−9/timeout、COST_STOP；未完成16行窗口，不启动128行长例，`NORM_STAGE_READY`仍未通过。AT301静态timeout、AT305首次脚本路径child127照原账保留。[阶段报告](runs/R001/reports/SM004_rev18_q16_owner_ln128_cost_engineering_handoff_20261015.md)及[逐guard账](runs/R001/reports/SM004_rev18_guard_ledger_AT301_AT306_20261015.json)：static7笔742.38596129976213734/900s、RTL5笔363.27006784640254/2400s，756项manifest/101条政策零失配；host完整UNKNOWN。


D-M004-REV18-REVIEW-01审核计数更正：AT304/305共同manifest条目**112=107 frozen+5 fixture**且SHA全同；原报告称“110份共有frozen”误计了AT304目录中3个未入manifest的Python字节码缓存。38条事件以LF连接、不附末换行SHA为`337b04e8…`，附末换行SHA为`8b5138a2…`，两种序列化的事件内容相同。[机读A/B](runs/R001/reports/SM004_rev18_ln128_default_vs_O3_cost_20261015.json)及[勘误](runs/R001/reports/SM004_rev18_at306_count_erratum_20261015.json)已同步；原manifest/guard/日志不改。主控仅接纳AT303局部Q16保护和AT304/305单次同终点成本观测，AT306保持COST_STOP。

## 修订19共享服务AT325阶段（2026-10-16）

当前生产下层/父core/上层/wrapper/sequencer SHA见[工程阶段报告](runs/R001/reports/SM004_rev19_AT325_shared_service_engineering_stage_20261016.md)。AT323真实父top固定160µs前缀只退休row0，逐位1024norm、64笔B，gamma256R；AT324/325同版下层局部Q16全窗4352字最终复扫、512同步响应、部分占有及新epoch通过，保存raw/gamma的LN_ONLY视图和固定PS/G/QD/ADD bank客户短例另行通过。AT322同版晚RRESP与末B错误排空/无reset恢复通过。均不证明独立stage 16行或真实LN128。

[AT307–325原guard账](runs/R001/reports/SM004_rev19_guard_ledger_AT307_AT325_20261016.json)：19份manifest共2139项冻结条目、38笔guard、288条实际政策样本零不匹配；static1706.08185053430498095/1800s、RTL1473.825600214302521/3600s，host完整UNKNOWN。旧Fatal/编译失败/守卫误停/脚本路径失败均保留。现静态余额93.91814946569501905s低于已实测单次父top展开，上层归属迁移未完成，合法独立pilot和NORM_STAGE_READY仍NOT_RUN；修订19和M004/SM004继续running/unassessed。


---
Published: 2026-10-15T17:09:58.509492+00:00
Publication: P95b84fabae42488c8011aeebe805ef3d
