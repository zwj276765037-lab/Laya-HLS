# E003：R003实际结果与范围

codec_01严格C编译、负例和独立1536B逐字节oracle PASS。transport_05 PASS432cycles，accepted4/retired5/stale1；受控service endpoint，只证明transport。

matrix_binding_03 PASS859cycles，7实际resident commands/responses，6类活动取消与K256/N2恢复、AW/W/B2及4独立零F32；A/W为受控诊断端点，不是物理cache/模型链。base_mirror_02 PASS595cycles，13roles/26words/全部16WSTRB/61native writes/3snapshots，与真实历史pointer controller比较，current generated acceptance尚未绑定。axi_owner_02 PASS134cycles，AR4/R8/AW3/W6/B3及held lastR/B、W先AW、clear_error不清债与early-LAST恢复；overlong-R恢复未验证。

实际AMD dwidth512_03/128_01 PASS2344/2408cycles，guard0/null24.506518/24.925118s，peak1613640/1600148KiB。独立2048B读和8192B写/sentinel比较、稀疏WSTRB、64位高地址、4KiB拆分AR/AW2、真实R/W512与B2、RRESP/BRESP错误归并和末R/B反压。512_01/02保留末MI B同拍TB旧计数失败，修复真实edge统计后通过；无生产链/OOC/资源声明。

axi_13bo_owner_01 PASS372cycles，13BO×2owners=26transactions、AR/R/AW/W/B26each、26heldR/B，全部45具名字段。guard0/null23.452140s，peak1328940KiB。使用真实历史ABI，不代签新generated caller。

load_portal_02 PASS1143cycles，11commands/replies、5cancel cases、2overflow拒绝、1AUX RRESP错、2恢复和external-debt barrier；实际q AR9/R288、AUX AR14/R77。默认完整cache、独立诊断q/half1 scale/nonzero bias(+1.5/-2.5) stripe lease/read/release比较；guard0/null23.095349s、peak1468772KiB。覆盖cache load_done同拍cancel与pending-success/READY同拍cancel。此前load01 PASS仅其冻结范围。

load_native_02 PASS17275cycles，13commands/replies、6cancel、2overflow拒绝、1AUX RRESP错误、3正常恢复、外部debt barrier、pending-cancel/READY、实际8B AUX尾读，以及controller owner0的完整侧带恢复读。默认完整cache、四实际AMD converter与一个13BO owner wrapper，实际q AR23/R5633（含controller probe1）、AUX AR18/R366。held SI最后返回保留FIFO_MODE0真实cut-through MI LAST和owner，两个方向实际排空前不完成。guard0/null33.584732s、peak1831992KiB。26生成IP/source文件已哈希；保留vendor fifo_generator一条simulation warning，PASS轮无ERROR/FATAL。native01保留TB错误预期“held SI时MI已退休”的FAIL，原始IP语义核查后修正，未删no-early-ownership/completion检查。诊断数据/manual32-bit memory peers，不是当前generated/真实GGUF/整链通过。

resident_regression_02当前cache/reader取消依赖下static/pilot/full均PASS：56.586667/87.111961/424.467004s，peak2407008/1426128/1422652KiB，guard0/null。full48862cycles，4原distinct Down rows K2624/N1024，10496stripes/335872lane-groups、4096独立F32输出、512实际AW/W/Beach、heldB9217cycles与最后B发布/真实源release。A仍为原预量化fixture，无同runtime Wi/G/quant/13BO。resident01只按新增LOAD cancel前冻结身份有效。

终态后的当前/冻结身份核查：LOAD portal11、resident26、native LOAD21项file pairs全匹配，receipt manifest SHA匹配。全部attempt保留。L0 PARTIAL/L1 PARTIAL；L2–L5 NOT_RUN。完整首错/原始AXI源优先级、多view、CE/reset与真实同runtime链未通过；generic cache error映射不可代签L3。旧CPU/CSim适用旧build，新最终身份回归尚未执行。完整M004、资源/性能/P&R/板层未验收。


---
Published: 2026-10-11T09:58:35.524463+00:00
Publication: Pc21c3616d3944f36b5de343b41a00e51
