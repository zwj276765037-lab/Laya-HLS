# M007下一集成边界：真实QKV→完整Attention→WO

2026-10-21；A001架构准备，服从M007/SM010/SM011。本文明确后继接口与所有权，不登记已实现、不启动新预算；当前F32-MATRIX-07、HEAD16-06、LN-05继续。实现及长例必须在这些阶段的实际出口后下达独立有界合同。

## 唯一资源与代码交接

当前matrix_superblock仍内含sharedFP/PS壳，layer仍内含attention_resources壳。直接把两壳串联会产生两套物理FP/PS，不能作为生产父图。后继由A010把matrix的控制/INT8/dot格式化与恢复调度抽为纯engine，现superblock留薄兼容壳；由A007把layer控制/RoPE/head与资源壳分离，现layer接口留薄壳。原8192INT8、256special F16 scale product以及4score scale保持已有职责，不能把它们混算为重复256F32阵列。

生产父级由A007负责接线，一份shared256mul/add、一份PS/G/context、一份LN-exp、一组SFU、一组DIV8、一份QKV、原系数cache，以及A010唯一A/W服务。纯quant/A前端调用同DIV8，纯matrix与Attention调用同FP/PS。两执行者不交叉改对方源码；正式抽取时各自冻结前/后接口与受影响测试。独立测试壳只用于其局部验证，不进入生产父层次。

父控制限定一请求上下文、单算术时钟，内部phase来自生产FSM。切换必须看到旧owner实际提交、读/响应、返回信用、错误/完成回执退休；不允许TB强制route或把债常量绑零。control新增位与现layer3754B保守声明合并核4KiB上限，不能把模块分别小于4KiB当作父联合小于4KiB；能按不重叠生命周期复用时须给实际实现依据。

## 一次有界服务的真实数据路径

1. 父接受完整request/generation/source_epoch和原model/numeric/graph/layout/build身份，绑定固定Encoder或Decision层描述符。完整tag先验证，再允许映射W内部紧凑model key；截断相等本身不是完整身份验证。系数表与bias绑定同模型和层。
2. 通过公开32F32输入进入已验证纯quant/A，再由唯一矩阵服务自主完成M128/K1024/N3072 QKV。先prepare下游QKV覆盖，矩阵的真实out_valid/ready直接参与银行写。列映射固定plane=col//1024、head=(col%1024)//64、half=(col%64)//32、token=row；共12288个32F32实际写握手，既不从gold预填，也不由TB逐超块发命令。
3. QKV全N成功回执、全部输出写入和矩阵实际资源释放成立后，父只启动一次layer。Encoder完整RoPE后head0..15，Decision跳过RoPE；不能将独立已算好的prob/context灌入代替算术。
4. Attention全部context写入/Check/债完成后，父从公开context读口按query→head→half读32F32，quant组号=2*head+half、row=query。读响应实际握手即消费者交接；只需有界保持，不新增512KiB context副本。4096响应的身份/序号与layer消费覆盖一致，读完实际quant→A写ack/发布及DIV释放后，再申请WO矩阵FP/PS。
5. layer的producer_done与context_release分别计时。正常不能以显式discard替代消费；错误可显式取消并排已接受的真实读/返回。只有layer输出所有权退休、quant/A完整成功及真实共享资源交接后，父执行一次M128/K1024/N1024 WO。WO真实32F32输出供后继残差；本段边界止于WO全结果及Check/债完成，不声称已完成整个Encoder。

上述QKV和WO使用同一个A/W/matrix实例与不同合法tensor身份。A双槽的有效/lease/取消规则保持，不能用共同reset实现正常换阶段。父处理错误只派发生产cancel/discard并等实际排空；上游失败不能触发下游矩阵。phase1/2/3/4/5/7的FP/DIV互斥按真实owner执行，不假定这些服务可同时占用同资源。

## 性能、参考与验证边界

完整F32 QKV57344、WO22528和Encoder/Decision完整Attention188544/186368各帽保持，含各自实际供数/冷W/输出退休，父新增间隙单列。context读用于WO量化供应，同runtime总时间只计一次并完整包含；producer_done早于读取不产生免费时间。32F32连续读/响应必须实测，不能从端口宽度推断II1。

正常主参考使用E010/R003已经绑定原B1的Encoder0/Encoder1/Decision0完整128行局部参考。QKV、RoPE、score/prob/context逐位保留；WO全128输入应为同一个独立context，按原full_reference及实际GGUF窗口计算局部gold。E012旧16真实+112诊断WO只能继承其局部算术证据，不能代签父真实全128轨迹。允许独立局部参考，不产生新30层gold、不从DUT输出生成gold。

先验证纯engine抽取及唯一实例，再做带真实F32量化和QKV银行写的首边界样本、context→quant/A→WO局部完整样本。最后同版真实全链必须由成本pilot支持；一段独立通过不冒充同runtime整链。预算由实际HEAD16/F32交付的费用与可执行成本定，不因新组合昂贵而原样延长既有timeout。全层首错等价、30层、残差/FFN、物理资源与300MHz、板卡性能仍须后继证据。


## 现源抽取切口与按资源束路由（2026-10-21增量）

A010的[现源逐端口映射](../project/E012_m007_matrix_compute/experiment_results/runs/R003/reports/minimal_matrix_engine_extraction_map.md)和[量化/所有权边界](../project/E012_m007_matrix_compute/experiment_results/runs/R003/reports/single_resource_boundary.md)已由主控核读，作为后继固定切口：纯superblock保留INT8/dot格式化、64token与双ctx调度；纯full facade保留唯一A/W/bias bank并将实际FP/PS接口穿透到父级。旧superblock/full只保留局部验证兼容壳，生产父不实例化其私有资源。pure quant/A放父级，直接接同一DIV8及facade的真实A写/取消口；当前row-major F32壳只用于独立测试。

A007纯layer需将现唯一attention_resources及独立coeffcache移至兼容壳/未来父级，控制器、RoPE/head/Check和公开QKV32写覆盖保持同一生产实现。资源所有权按QKV、FP、PS/G/context、DIV、SFU及系数束分别路由，不能使用一个全局owner mux代替全部互斥：QKV矩阵在phase1持有FP/PS期间，其真实输出仍必须经layer公开32F32写口送到soleQKV，执行原完整身份、有限性和half覆盖检查。不能直接绕过公开写口填bank，也不能因matrix持有算术资源而屏蔽QKV写回。

现源逐线核实：layer.prepare_fire只锁描述符/清覆盖并进入L_PREP；h_prepare_valid直到后续L_HPREP（一次start及RoPE之后）才成立，L_PREP不领取FP/PS/LN/DIV/SFU。但prepare_ready在L_IDLE确实受real_idle与h_prepare_ready约束，后者要求真实storage_bind_ready和FP lease_ready。因此固定顺序是先合法layer.prepare，再由quant/QKV矩阵占资源并经L_PREP窄写，完整写入及matrix退休后才layer.start；保留现ready真实依赖，不添加矩阵active后强行prepare的捷径或假ready/phase/债零。matrix的bind_new_lease仍受真实A/W可用、sharedFP ready和storage bind_ready原子条件约束，phase_debt_clear保留原实际算术/退休/输出/PS债表达式；父只路由，不提前替它领取资源再回填虚假成功。全storage idle包含正在服务的G/context，不能用PS子债替代。

当前layer控制声明3754B，原4KiB下仅342B余量；pure quant/A还有256B accepted-coordinate账，facade/父命令与状态也必须逐项计入。阶段互斥不自动删除实际寄存器，复用须落在同一真实存储并给出写入/清除/保留边界，不能把多个模块各自小于4KiB称为联合合规。当前仅是静态接口准备，没有父级新运行或联合容量PASS。

全128真实Encoder0 context→WO→残差→LN→Wi→G原局部参考现已在[E015 AT007](../project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT007_encoder0_real_local_reference/work/report.json)保存并经主控字节/来源核验。后继Encoder0 WO使用其中wo_input_context.bin/wo.bin；不能继续用旧16真实+112诊断WO参考代签完整真实轨迹。原独立reference SHA和实际W窗口身份保持。另两层全128 WO参考在实际需要时按同一原算法局部生成，不把Encoder0结果外推。


控制存储的待实施优化候选：QKV完整half覆盖已经真实闭合、生产窄写入口关闭后，保留独立QKV完整标志，将同一物理coverage数组低4096位重新清零用于context实际响应消费。它只在两种用途不重叠且首次context读取前真实清理完成时允许；任意读取的去重、末响应held、错误/abort/reset和跨generation隔离都须回归。没有实现前仍按3754+256=4010B及新增facade/父字段全额记账，不能提前扣512B。此优化不改变4KiB要求或当前冻结layer证据。


## PREP取消与上游失败的后继接口决定

现layer.abort_ready只覆盖L_RSTART..L_WAIT，result_discard只覆盖正常DONE/RELEASE，L_PREP没有不reset的取消出口。这是后继真实QKV生产者连接必须补齐的接口；不能用补齐假数据、虚假done或共同reset绕过。

纯layer增加prepare_cancel_valid/ready，身份request64/generation32/epoch32，以及保持型prepare_cancel_rsp_valid/ready和相同身份/明确取消状态。已锁layer描述符直接作为回显来源，避免复制一套完整身份。仅L_PREP且完整取消身份匹配时接受；错身份不接受、不清覆盖，active算术阶段继续原abort协议，已完成输出继续原discard协议。取消优先于同沿start和新的QKV窄写，不能同沿既接受末写/启动又取消；此前已接受的实际窄写必须真实提交后才清覆盖和输入所有权。银行载荷无需整片清零，失效由真实覆盖/身份控制，下一generation仍须完整真实重装。

取消属于未启动Attention的终结，不发布正常layer done、success context或伪造各Check阶段已执行。取消响应在消费前保持全部字段、阻新prepare/start；消费后且自身已接受写/读/响应债清才回IDLE。不得reset、重bind或释放另一个owner正在使用的FP/PS/DIV；取消检查只依据本layer真实所属事务，父仍负责整体资源交接。

父在QKV上游错误/外部取消时先停止新的上游工作，沿生产quant/matrix的原错误取消路径实际排尽已接受计算、A/W/输出事务。L_PREP的合法输出接收保持到上游真实退休，不通过突然拉低QKV ready制造排债死锁；随后父请求PREP取消并消费回执。父返回原上游错误及身份，不能以内部取消状态覆盖原首错。量化阶段即失败且未启动矩阵时也走相同末段，不需虚构任何QKV写。

后继受影响短例固定覆盖零QKV写取消、部分真实QKV写取消、末写/启动与取消同沿优先、错request/gen/epoch不伤当前覆盖、held取消响应阻重配，以及无reset新gen真实完整重装。实际矩阵上游错误→真实排债→PREP取消→新请求必须在父级测试；只驱动独立layer取消口不能代签该父恢复。此决定尚未实施，不改变当前AT024/029冻结结果或运行预算。


## 分侧抽取已具备条件接续合同

2026-10-21：SM010 PURE-MATRIX-09与SM011 PURE-LAYER-10已明确下一可执行段、各自所有权和独立预算。它们在各owner当前R003合法运行/成本出口之后自动接续，不以用户再次催促为条件；登记计划不代表实际启动。矩阵侧先以原真实context文件验证完整WO局部输入，layer侧完成PREP取消与覆盖复用，之后才组合真正同runtime父链；父级实验预算尚未启动。pure front已有早关闭hook只作为待验证实现存在，本段补真实部分量化/A取消，不把静态代码当恢复通过。


## 联合控制容量与故障覆盖编码决定（2026-10-21）

新声明账修正了早期只计layer3754B+quant坐标256B的下限：matrix facade/engine/pure front保守共1475B，front已含坐标账；现总额5229B，尚未父新增。只实施输入/输出coverage共享减512B仍为4717B，不能判4KiB通过。以下是R004具体修改范围，实际节省须按最终源码/同配置验证后核算。

1. A010把仅用于max_issue_commit/max_ps_feedback的issue_time/ps_time两64×32bit数组放入可完全关闭的profiling generate，纯生产配置关闭，实际512B状态不例化；旧独立兼容配置可打开，但必须明确多出该状态。生产模式这些历史统计口标profile_valid=0（若兼容壳保留数值口则置0且声明无效），不得把0当实测延迟。生产配置TB从真实issue/PS读接受/写ack旁观测量，继续核≤64/≤24和完整周期；禁止删断言、假事件或让遥测状态影响ready/数据/错误/退休。纯配置和profile配置的数据/协议行为须受影响对比。其它保守调试计数先照计，未实现不扣。
2. A007在新纯路径将check_order的2464个entry从三张独立sticky位图改为2bit类别：00未覆盖、01实际完成、10因依赖不可达、11已被更早错误支配。旧同类重复set幂等；不同类旧/新或同拍多类set是协议冲突。合法域原三个输出位图组合解码、全部覆盖/原数值候选次序必须逐位相同。首次冲突保存kind、entry索引、旧类别及新set mask，保守按4B记账；sticky coverage_fault只由真实clear/reset清。该表示预期净省304B，未实现前不兑现。
3. coverage_fault=1后分类图不再具有可用于验收的覆盖语义，不要求保留旧三图非法union的位型。不得借压缩吞掉冲突或返回成功；层停止新head/start，沿真实active引擎abort/退休路径排空已接受事务，最终protocol错误可被消费，保持全身份/错误回执。此故障退出允许不等待已损坏的coverage all_accounted，但必须等待真实资源/读响应/返回债清；不能把check_ready被fault永久压低当作故障处理完成。当前旧L_WAIT存在该潜在无限等待，旧未测范围保留。本决定只定义新故障协议，对合法模型检查顺序/数值/覆盖不放宽。
4. A007核实并可在纯layer resident专用配置中真实消除head内历史独立QKV/prob外写coverage2816bit并新增1bit实际resident接受标志（净省2815bit），原单head独立装载兼容配置保留；生产完整layer已自行检查全QKV且softmax实际写prob，不能由常量伪造合法resident或G写完成。须明确哪些旧入口在生产结构上不可达、使用父真实coverage/身份/所有权的条件，以及原真实head/错误/恢复受影响回归；未实际证明和消除前不扣352B。

若以上四项都真实落地，保守账从5229B出发，QKV/context复用净省4095bit（含1bit完整标志）、关闭profiling省4096bit、2bit分类含32bit首冲突记录净省2432bit、resident专用净省2815bit；合计3549.25B按分块向上取整为3550B，剩546B留父级新增控制；这是静态设计预算，不是最终fit，LN/G/父新控制及共用身份仍须逐项核。外部model/numeric完整128bit验证不能通过截断来省空间。其它服务既有独立预算（softmax3865B、sharedFP返回tag6144B）继续原范围一次计数；不把新增控制临时改名挪出4KiB。

固定算术管线中的逐lane tag/valid属于随该管线data流动的原数值管线存储，单独保留真实bit/FF总账；它们不是父请求可复用4KiB，也不是payload数字本身。A010现已列出dot2304B tag、half-product12384B原声明、converter3104B等，绝不从总物理预算删除或假定工具自动合并。若后续实际将同一向量恒等metadata共享为一个移位管线，必须同clock/CE/reset/valid/延迟对齐且从原接受事件更新，全部lane真实返回/错误/间断/复位回归后再按实际声明记节省；本次不以这类未实施优化宣称联合资源达标。

受影响错误测试包括每类合法重复set、旧/新类别冲突、同沿多类、first-conflict保持、fault后禁止成功、真在途排空/protocol done消费及新gen清理。合成/布局布线和父全图另计，容量修复不修改原性能或数值帽。


## prepared head故障退出的落实要求（2026-10-21）

主控现源静态核见：新增coverage_fault抑制resident/start valid后，原L_HRES/HSTART仍仅据ready转态；head H_PREP和qkav PREP又不能abort，且layer h_done_ready仅在L_HEAD。该组合可能无实际接受而推进或挂住prepared所有权。本条是PURE-LAYER-10既定真实故障排债的具体修复要求，没有动态FAIL_NUMERIC结论。

所有状态推进必须由实际valid&&ready；resident-only内部prepared未start阶段允许已有abort链受理取消，禁止为了退出而伪造start或领取算术lease。停止新的resident/start，排清本owner此前真实接受事务，再形成可保持/消费的错误或取消DONE；layer在明确故障排空状态接收该回执，最后真实债清才对外protocol完成。未实际启动的取消不设置head完成、context有效或已执行Check覆盖。没有自有FP lease时不释放其他owner；默认独立兼容配置保持原行为，新增状态位计入实际账。合法head PREP→abort短例可以验证这段协议，不代签无实际触发的layer classification冲突；禁止force位图、债或状态。


## 父组合共享版本收敛（2026-10-21）

矩阵抽取先以R003 AT018旧sharedFP80f91e…验证，Attention已在f4508add…上完成空流水CE受影响检查，两者不能直接当成同版父链。主控已指定矩阵R004末段在原余额内显式回归f4508add…，DIV统一8bbd1463…；最终父只能使用一份同SHA sharedFP/资源。旧完整QKV/WO/Down及新真实context WO仍守各自冻结身份；只有新消费者实际通过范围才可继承到组合，矩阵老SHA不会通过实例化第二份来保留。


## SINGLE-PARENT-11 正式接续（2026-10-21）

纯matrix/layer及当前sharedFP消费者已具备实现条件。A010在R004出口后拥有forward_controller新增M007父控制/资源router，A007保持layer/resources单owner支持；本条取代早期父接线由A007负责的人员安排。正式接口、独立预算和阶段验收见[SM012 SINGLE-PARENT-11](../mission/M007_完整Attention高性能主干与部署闭合/tasks/SM012.md#d-m007-sm012-single-parent-11唯一资源的-qkvattentionwo)。E016/R001已登记，实际启动由工程收据/状态报告确认。PREP期间系数owner保护必须采用A007窄修复后的生产源；旧head正常数值与新保护回归分别保留身份。
