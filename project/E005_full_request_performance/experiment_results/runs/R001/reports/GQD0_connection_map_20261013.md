# GQD0 有限接线与身份映射

执行合同：`D-M004-GQD-INTEGRATION-01`。本表描述新诊断测试台的实际接线；数值与动态完成以 AT 尝试原始结果为准。

| 真实生产者/消费者字段 | 接线与检查 |
| --- | --- |
| G桥 `cfg_numeric_identity[671:0]` | 取 Down `cfg_numeric_identity`，包含同一512bit模型身份；Wi输入、GATE/量化和Down的完整672bit身份一致。 |
| G桥 producer/quant/linear context | producer为同任务batch1,row0=7,rows4、op60；quant为同batch/row/rows、op61；linear与Down完整96bit context相同、op33。 |
| G桥 `cfg_gate_ref/cfg_a_ref/cfg_w_ref/cfg_down_dst_ref` | 依次对应Down `cfg_source_ref/cfg_a_ref/cfg_w_ref/cfg_dst_ref`；Wi ref另为原6类输入。 |
| G桥 A slot/epoch | 与Down `cfg_a_slot/cfg_a_epoch` 相同，slot0/epoch1；共享原两个物理slot容量。 |
| Down `a_acquire_*`, `a_read_*`, `a_ret_*`, `a_release_*` | 逐字段直连 G桥同名无`a_`前缀的租约、读、返回和释放口；完整slot、epoch、identity、linear context、A/W/dst ref及row_block/group不重建。Down独占消费与release，TB无诊断租约。 |
| Down row block/group | row_block_base0、rows4、group0..81；Down真实82次A返回逐行比较原独立q/scale。 |
| GATE AXI存储 | TB仅在真实AW/W/WSTRB后更新物理存储，G桥量化经真实AR/R读取；656写拍和656读拍及最后B单独核。 |
| Down W/PS/output | 原KB1冻结W严格加载、PS逐lane gold、四pack writer和256 AW/W/B响应策略保持；batch1输出地址按原4MiB batch stride核。 |

外部数据只有原四行Wi F32、权重/metadata、配置/命令及独立gold。q/scale文件仅供断言，未作为dualA数据驱动。原桥04与KB1冻结`quant_dual_a_v1.sv` SHA均为`0cf4e8b02e5559bde7644a1e4d7772b9206ad8b40a6f4eab7f5cc85c14613558`，新链仅实例化桥内一份；没有独立测试台预填A。

AT023为首版：static PASS（83.530697s），pilot在120.341961s保护触发`timeout`，未到首个进展/完成标记，无动态数值结论。AT024是第一轮受影响修复：pilot在真实首行GATE写入/最后B后退出以量到可执行前缀，并补batch1输出地址观察；源/fixture/gold/响应策略未改。AT024后续结果以其原receipt为准。

AT024 static/pilot PASS，真实首行5248 Wi词及164笔GATE AW/W/B闭合，pilot未到量化/Down。full在127.533100s被`semantic_stall`保护停止，原始log实际已出现cycle25 G配置接受、cycle5294第0行Wi完成及cycle19454第1行Wi完成。新`GQD_PROGRESS`标记未列入冻结guard识别式，不能把该停止称为DUT死锁或完整链结果。AT025第二轮只将这些真实进展标记改用guard现有`MATRIX_PROGRESS`前缀，不改DUT/数据；按原帽串行验证。
