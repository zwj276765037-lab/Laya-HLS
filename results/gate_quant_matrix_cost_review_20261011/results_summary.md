# E003：R003实际结果与范围

codec_01严格C编译、负例和独立1536B逐字节oracle PASS。transport_05 PASS432cycles，accepted4/retired5/stale1；受控service endpoint，只证明transport。

matrix_binding_03 PASS859cycles，7实际resident commands/responses，6类活动取消与K256/N2恢复、AW/W/B2及4独立零F32；A/W为受控诊断端点，不是物理cache/模型链。base_mirror_02 PASS595cycles，13roles/26words/全部16WSTRB/61native writes/3snapshots，与真实历史pointer controller比较，current generated acceptance尚未绑定。axi_owner_02 PASS134cycles，AR4/R8/AW3/W6/B3及held lastR/B、W先AW、clear_error不清债与early-LAST恢复；overlong-R恢复未验证。

实际AMD dwidth512_03/128_01 PASS2344/2408cycles，guard0/null24.506518/24.925118s，peak1613640/1600148KiB。独立2048B读和8192B写/sentinel比较、稀疏WSTRB、64位高地址、4KiB拆分AR/AW2、真实R/W512与B2、RRESP/BRESP错误归并和末R/B反压。512_01/02保留末MI B同拍TB旧计数失败，修复真实edge统计后通过；无生产链/OOC/资源声明。

axi_13bo_owner_01 PASS372cycles，13BO×2owners=26transactions、AR/R/AW/W/B26each、26heldR/B，全部45具名字段。guard0/null23.452140s，peak1328940KiB。使用真实历史ABI，不代签新generated caller。

load_portal_02 PASS1143cycles，11commands/replies、5cancel cases、2overflow拒绝、1AUX RRESP错、2恢复和external-debt barrier；实际q AR9/R288、AUX AR14/R77。默认完整cache、独立诊断q/half1 scale/nonzero bias(+1.5/-2.5) stripe lease/read/release比较；guard0/null23.095349s、peak1468772KiB。覆盖cache load_done同拍cancel与pending-success/READY同拍cancel。此前load01 PASS仅其冻结范围。

load_native_02 PASS17275cycles，13commands/replies、6cancel、2overflow拒绝、1AUX RRESP错误、3正常恢复、外部debt barrier、pending-cancel/READY、实际8B AUX尾读，以及controller owner0的完整侧带恢复读。默认完整cache、四实际AMD converter与一个13BO owner wrapper，实际q AR23/R5633（含controller probe1）、AUX AR18/R366。held SI最后返回保留FIFO_MODE0真实cut-through MI LAST和owner，两个方向实际排空前不完成。guard0/null33.584732s、peak1831992KiB。26生成IP/source文件已哈希；保留vendor fifo_generator一条simulation warning，PASS轮无ERROR/FATAL。native01保留TB错误预期“held SI时MI已退休”的FAIL，原始IP语义核查后修正，未删no-early-ownership/completion检查。诊断数据/manual32-bit memory peers，不是当前generated/真实GGUF/整链通过。

resident_regression_02当前cache/reader取消依赖下static/pilot/full均PASS：56.586667/87.111961/424.467004s，peak2407008/1426128/1422652KiB，guard0/null。full48862cycles，4原distinct Down rows K2624/N1024，10496stripes/335872lane-groups、4096独立F32输出、512实际AW/W/Beach、heldB9217cycles与最后B发布/真实源release。A仍为原预量化fixture，无同runtime Wi/G/quant/13BO。resident01只按新增LOAD cancel前冻结身份有效。

终态后的当前/冻结身份核查：LOAD portal11、resident26、native LOAD21项file pairs全匹配，receipt manifest SHA匹配。全部attempt保留。L0 PARTIAL/L1 PARTIAL；L2–L5 NOT_RUN。完整首错/原始AXI源优先级、多view、CE/reset与真实同runtime链未通过；generic cache error映射不可代签L3。旧CPU/CSim适用旧build，新最终身份回归尚未执行。完整M004、资源/性能/P&R/板层未验收。

load_native_03：当前native adapter补齐selected native offered AR/AW/W与visible R/B barrier。PASS18863cycles，14commands/replies，控制器AR背压15cycles后真实接受/返回，再准入LOAD；全部既有取消/恢复/8B AUX与owner测试保持。q AR26/R6146（含2controller probes）、AUX AR20/R400，guard0/null34.301440s、peak1839268KiB，21当前/冻结file pairs匹配。native02只签此前冻结adapter，resident02依赖未改变继续有效。仅新测controller offered AR，其它native写屏障不由该读测试代签。

## 2026-10-11 新冻结局部验证

- codec_v2_02 PASS：四service、406mutation，独立6144B逐字节oracle。codec_v2_01编译失败保留于codec_v2_guard_01/driver.log，旧runner未冻结失败preimage，不能补称其具有完整冻结。
- transport_v2_02 PASS836cycles；最新版transport_generation_02 PASS1786cycles，accepted9/retired23/stale2。9类坏头超大g、10first-push cancel、partial/bad-tail可信g耗号、末响应读/cancel竞争、同session/新session恢复及跳号覆盖；20.442486s、peak1580948KiB、guard0/null。仅受控service端点，不代签真实hub/parent联动。
- load_native_v2_01 PASS18863cycles：14commands/replies、6cancel、2overflow、1AUX错误、3恢复；q AR26/R6146、AUX AR20/R400；35.675456s、peak1819492KiB。默认完整cache、四真实AMD converter与13BO owner，仍诊断数据/manual peers。
- matrix_binding_v2_01 static/pilot PASS56.545527/18.367958s，旧7命令6取消与K256/N2单view恢复范围保持；控制A/W端点，不证明多view父租约。
- reservation_03 PASS：128窗口/385typed/769门户票据、rows1..16的尾view、未发g不回收、同generation下一request重建与u64溢出；Controller仅syntax通过。host sizeof TaskReservation260B/GDownWindow264B/GDownPlan33936B，非RTL资源。
- parent_a_01 PASS10309cycles：真实完整dualA，3fills/3acquire/3release、9local views、7实体/覆盖拒绝、94464独立q字节比较，held末A return阻止release，窗口间cancel等external debt，same-session下一request恢复。23.679215s、peak1397844KiB、guard0/null。预量化诊断fixture不代签G/quant算术、真实source provenance、matrix联动或模型链。

所有上述结果仅适用于各自冻结输入；L0/L1 PARTIAL、L2–L5 NOT_RUN，M004未完成。新parent、matrix多view/首错、GATE同epoch跨窗口/分期、唯一持久hub及caller继续实施。无新OOC/P&R/上板。

## 2026-10-11 新增冻结局部证据

- `gate_tensor_04` PASS_SCOPED：1234 cycles，128窗口/2048行同epoch，最终写债后一次READY，8窗口读租约、跨窗口cancel、同session恢复；guard20.816296s、峰值1290512KiB。仅metadata ledger。
- `matrix_tensor_02` PASS_SCOPED：3529 cycles，128父/512 views/2048行，同dst epoch多父、早父不提前发布、sticky失败、跨父取消与恢复。
- `matrix_parent_current_01`在当前tensor ledger接口后重新取得static/pilot PASS。
- `matrix_parent_views_07` static/pilot PASS：58.001144/382.907547s，峰值2413404/1389172KiB，128440 cycles。18 commands/replies；新增9个真实rows4 view覆盖成功父、跨view空档取消、同session下一request失败父。各view独立g，每父一次A/W物理lease、成功/失败各一次父TaskDone，取消不伪造TaskDone；AW/W/B各2563，末view第512个B反压后释放；受控rank 2112000→5280验证跨view最小归并。诊断零输出和受控rank不代签模型数值。

`gate_tensor_01..03`与`matrix_parent_views_01..06`失败均保留。当前仍为L0/L1 PARTIAL、L2–L5 NOT_RUN；物理GATE writer、真实quant/G source、实际fullA/fullW cache、唯一hub/caller、完整CPU/CSim与M004未完成。

- 成本合规更正：matrix_parent_views_07的382.907547s完整运行没有先行≤120s成功pilot或冻结估算，且runner自matrix_parent_views_04起把pilot上限直接改为600s；功能PASS保留，但执行分类/预算为偏离，不能作为合规pilot/full成本证据。runner现恢复120s短pilot，完整回归使用显式full/3600s并在启动前记录实测速率和保守估算。
## 2026-10-11 物理GATE与split运行结果

- `gate_store_04` PASS_SCOPED：202711 cycles；完整64行/四个rows16窗口共用同一GATE epoch，10496个实际AW/W/B，含取消场景总计10660个；末B后READY。21.641107s、峰值1323428KiB。受控GATE字输入只签writer/store。
- `gate_split_static_01` PASS_SCOPED_STATIC：唯一canonical GEGLU、物理store、延迟QUANT和full dual-A编译/展开通过；48.698790s、峰值2133148KiB，无运行声明。
- `gate_split_04` PASS_SCOPED_RUNTIME：static 52.656369s；一行pilot 11769 cycles/32.550573s；full 758736 cycles/1054.961660s、峰值1326676KiB。四个G命令共64行、335872 WI words、167936 GATE words、10496 AW/W/B；所有G结束前AR/quant为0。随后一个独立Q命令读取window0：56 AR/2624 R、16 quant rows/2624 halves；fullA四个rows4 view检查1312项，GATE与q/d/reciprocal/scale/fullA均比独立gold，最后释放lease并清理tensor。manifest SHA256=`bb7309b0e22f1de7940a144e8e93269367953851441705ade1cfba14ed4b9809`，receipt SHA256=`f8ad62afc4595dd7eb6d680b5cce1b4f5b6cb71d4381ea989ab6b47cb2ab9ad8`。
- `matrix_cost_stop_branch_01` PASS（记录逻辑）：合成3601s>3600s得到`COST_STOP/started:false`，manifest SHA256=`01a85a6aedf2cc10d99221bce2fe5fda778e042206e6e5c8dae4ead82ac5f96a`与receipt绑定一致，没有full工具产物。未运行Vivado，不是matrix功能证据。

`gate_store_01..03`和`gate_split_01..03`失败均保留；后者依次暴露TB组合ready采样及full进度可见性问题。`_04`没有缩减DUT、gold或full覆盖。当前只证明实际canonical GEGLU多窗口同epoch→独立QUANT window0→fullA局部链；其余Q/L、LOAD、fullW/matrix、hub/caller、L2/L3、完整CPU/CSim和M004未完成。

## 2026-10-11 真实父缓存matrix与停滞保护证据

- `matrix_parent_cache_03` PASS_SCOPED_RUNTIME：static/pilot/full 62.534447/92.153086/1725.782300s；full 114182 cycles，四个不同g的rows4 view共用一个rows16父。实际A提交2624 halves/1312 scales，W读取44608 beat；41984 stripes、167936个PS gold、16384个最终F32 gold、AW/W/B各2048。A/W各真实acquire/release一次，末B后父覆盖`ffff`且TaskDone一次。单父只覆盖tensor前16/256行，tensor publication保持0。manifest SHA256=`e87ba8097dad18e54078ef18e964c4c45ccabd62f60cd29a1db8a2498c55231d`，receipt SHA256=`2b51a19397dbade08bc8ab65c5ae69e35ec958ba6938e0434182fdf1bcbe1b3c`。
- `gate_split_progress_guard_02` PASS：1000条不变work进度不刷新，两次真实work增加可刷新；无Vivado/功能声明。manifest SHA256=`b3090800273e75c206f520f52f2e5172b5111be44406512985e5dc8b98d175fc`，receipt SHA256=`20857a4505379318c2ee0812c02d035324b7130c9df3ed227c8cd206bb68ebe4`。

`matrix_parent_cache_01/_02`和`gate_split_progress_guard_01`失败保留。当前A仍是预量化fixture；实际G/Q→该父matrix、多父tensor、其余Q/L、LOAD、hub/caller、L2/L3及完整CPU/CSim未完成。

## 2026-10-11 actual G/Q→父matrix组合成本证据

`gate_quant_matrix_parent_03`冻结实际canonical GEGLU/GATE、独立QUANT fullA、真实fullW与父matrix四view的直接连接；A没有TB填充路径。static 84.239673s PASS；同一no-wave batch profile的一行真实G pilot 11773 cycles/63.410458s PASS。以已通过组件758736+114182 cycles为完整工作量上界，当前pilot 185.663 cycles/s并加10%余量投影5172s>3600s，故full为`COST_STOP/started:false`。manifest `f0c140708f014f31a99e166728c4e47a16e0a9ae62dca84c462763fa7a770525`，receipt `042347a390b73357108c20090326c59e2728db1ac756fbab37ad64b7c4cdc0ac`。

`gate_quant_matrix_parent_01`旧成本逻辑仅按两个分立full墙钟估算3476s而启动；组合速率显出不适用后在591.128178s主动停止，保留FAIL/sigterm、无PASS marker。修正入口不增帽、不缩覆盖。`gate_split_progress_guard_03`另证明recognized split前缀缺work/缺字段/非法字段不刷新停滞计时，重复work也不刷新；receipt `51084ae8eb12f366b7580cf8183ba419ccf31fbd0a8766ed17cc3838556489b8`。


---
Published: 2026-10-11T15:28:18.196737+00:00
Publication: P173efffbe41b460dae8f9c5d67dd93cd
