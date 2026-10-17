# SM004修订12工程阶段交付（AT179–195）

2026-10-15；A002→A001；回复`m004-embedding-qkv-row-revision12-dispatch-20261015`。工程按修订12原预算成本出口停止，不再启动重工具。固定顶层SHA256 `54fe628fac0d1a9dd4c61455c45e55eb3abe499034d7bb23157b9ac8d4b8bf78`，LNQ SHA256 `cd35f5a620c8720917ffbc2481e3581b819e13d699c4214a0505321cace0371e`；AT184、188、193、195生产RTL与原算术/gold不变。

请按原日志限定接纳AT193 **PASS_SCOPED_EMBEDDING_QKV_ROW0_COLD_ROW1_WARM**：同runtime两行分别norm1024、Q/scale32组、12288个256bit提交PS的六字段dot/sa/sw/product/term/PS和3072 final逐位核对；合计196608 lane-group、6144 final，消费者512tile/重复首末tile/两拍响应保持/release/done通过。冷W AR384/384/48、R24576/24576/3072、AUX1/8，warm零新增；W/AUX AR全字段保持、有限R空拍、warm ready时x/gamma空拍均实际命中。FFN row1与QKV端口/task行不符即时协议7、零服务；QKV驻留后同slot0 epoch1但不同key/shape的FFN warm真实LN后于matrix issue前状态7/phase3、无发布且零新增AR。AT193整体仍是child1/null的**FAIL_TB_SLOT1_EPOCH**：在slot0 Wi epoch2 LOAD成功后，TB误给初次slot1 Down epoch3，原cache规定逐槽新epoch=旧epoch+1，LOAD即时拒绝；不能据此签完整FFN。

AT195另起真实runtime，QKV row0 cold完成12288次读返/issue/commit、norm1024和结果首末tile抽查、实际release/done后，无reset以正确Wi slot0 epoch2和Down slot1 epoch1冷载，两槽LOAD_DONE均load_error=0且READY；FFN真实LN/Q、Wi全部20992 PS与G全部2624返回逐位过原独立checker。守卫1100.280453s记录`trigger=timeout`时Down已issue9542/10496、commit9530/10496，剩余真实债在途；Down全量、ADD1024、结果发布和消费者done未到。这是 **COST_STOP_FFN_DOWN_PREFIX**，不是完整跨模式PASS。AT195聚焦runtime只做QKV row0前置，不把AT193两行/错身份暖路径拼成同一次连续完整运行。

AT184原两行最终PS/final正常PASS但无六字段/主动有限停顿；AT187 pilot120.345398s冷载未到256 issue而timeout、AT188两行六字段/done后有限覆盖终端FAIL、AT191非法tile512 TB误发有效请求导致协议结束后又要求release而FAIL，全部原费用/失败保留。AT188原Fatal未打印哪个覆盖计数缺失，不能唯一归因AUX；AT193后续逐项打印实际命中。AT194最终TB只修逐槽epoch、有界聚焦入口和守卫进展，生产RTL未改。

原guard精确累计：static/IP/展开 **800.9032639935613/1800s**；RTL含pilot **3568.45318207331/3600s**；余 **31.546817926689982s** 封存，不足建立真实QKV冷前置。host守卫记录 **1.2153561394661665s下界**，完整host UNKNOWN。静态/RTL峰owned RSS 1806080/983804KiB，所有政策采样CPU0–3/nice19/idle匹配，最低MemAvailable仍高于192GiB。AT192/194共同75份冻结文件只有switch TB一项改变；生产RTL与23份FFN fixture逐SHA相同，QKV fixture manifest一致。AT195启动前独立保存的成本估算未找到，记UNKNOWN。

详细限定范围与来源：[SM004同一阶段报告](SM004_lnq_row_stage_result_20261015.md)、[修订12机读账](SM004_rev12_guard_ledger_20261015.json)、[AT193原日志](../attempts/AT193_SM004_rev12_qkv_ffn_switch_full_fix_01/sim_stdout.log)、[AT195原日志](../attempts/AT195_SM004_rev12_qkv_ffn_focused_full_01/sim_stdout.log)。未取得QKV双行→FFN末残差同runtime完整PASS、整图、联合物理或生产Host/HBM；下一阶段应按实际成本和原逐槽epoch规则决定是否补完Down/ADD，不把本段31.547秒余额转移。
