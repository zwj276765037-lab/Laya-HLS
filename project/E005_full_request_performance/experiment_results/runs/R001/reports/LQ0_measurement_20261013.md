# LQ0：原冻结LN→真实store→Q/fullA有限测量

2026-10-13；M004/SM005/E005/R001；A002。主结果是 `AT014_LQ0_measurement_02`；`AT013_LQ0_measurement_01`完整数值已过，但首版观察器把复位期空闲 `ap_done` 计为额外结束、缺END/发布/fullA精确时点，原收据保留。AT014只补观察资格和事件，未改DUT/gold/响应。

**LQ0限定PASS。** 本轮直接复制`E003/R003/layernorm_quant_source_03`的完整冻结闭包。153份文件与历史逐SHA对应，仅观察TB不同，且原601行全保留、只插入121行计数/断言。原生成LN、连接、83份生成产物、fixture和gold身份保持。真实B1/S128 checkpoint前16×1024 F32，诊断身份B1/S64 stage2/layer1 gamma0。LN输出16,384 F32逐位、Q输出16,384 INT8与512 FP16 scale逐项对独立gold通过；source AR16/R1024，store AW16/W1024/B16与65536B，Q从实际store AR16/R1024、fullA128次4row/512 row-group、末B/真实completion→END/发布/实际Q响应消费/lease释放及最终零债务均有原断言。

| 时点（clock cycle） | LQ0实际观察 |
| --- | ---: |
| producer request首/末读 | 135 / 150 |
| 生成LN run子图start/done | 4,441 / 653,821 |
| LN source首/末AR，首/末R | 5,035 / 613,277；5,037 / 613,468 |
| LN destination首/末AW、W、B | 45,430 / 653,672；45,431 / 653,800；45,571 / 653,813 |
| completion首/末拍、END实际消费、PUBLISH消费 | 655,378 / 655,387；655,441；655,496 |
| Q命令接受、lease激活、首/末AR、首/末R | 655,498；655,499；655,502 / 658,402；655,504 / 658,593 |
| Q响应有效/实际消费、lease释放 | 658,760 / 658,765；658,766 |
| fullA acquire / 第512组核完 / release | 658,766 / 659,278 / 659,279 |
| 最终零债务与TB结束 | 659,334 |

互斥TB生命周期阶段为配置/reset25、CLAIM54、BEGIN72、LN运行及END收束655290、PUBLISH/Q/fullA3838、RELEASE/收尾55，总和**659334**。各阶段由TB`phase`划分，第三阶段包含生成run以外的控制与完整完成消费。生成`run`子图4,441→653,821的649,380拍同样包含真实读/算/写，**不是纯算术周期**。外部接口valid&&!ready计数source AR11、source R0、destination AW0/W12/B0、Q AR6/R0；它们可重叠且不代表所有供数延迟，不能相加为节省潜力。Q接受→实际响应消费3,267拍，fullA回读512拍；在本样本中LN长包围区间主导。真实传输三向合计196608B；没有稳态、HBM带宽或完整请求性能外推。

AT014 guard的static/pilot/full均child0、trigger null；耗时76.867212/56.399040/735.843213s，peak owned RSS 2,389,328/863,332/863,076KiB，原CPU0–3/nice19/idle I/O/MemAvailable门和分类帽保留。原`_03`全TB同为659334拍；耗时差异仅为工具成本，不是硬件收益。原F9未改且未重跑，按原冻结身份继承。

LQ1唯一假设：对原最终1024元素归一化循环作显式II1流水，保持相邻树归约和每元素浮点表达式/检查顺序；只更换LN生成核，其余冻结closure、TB响应和gold同口径。原HLS报告该循环10249cycles是生成估计，实际收益及资源待测。无收益或生成失败按阶段合同有据退出，不改gold/缩样本/减TB delay。

原始证据：[AT014 receipt](../attempts/AT014_LQ0_measurement_02/receipt.json)、[AT014 full log](../attempts/AT014_LQ0_measurement_02/full_sim.log)、[AT014 manifest](../attempts/AT014_LQ0_measurement_02/input_manifest.json)、[AT013 receipt](../attempts/AT013_LQ0_measurement_01/receipt.json)。只签有限16行算术链；当前live连接、完整S64/全模型、恢复、联合物理资源与板端仍未测，M003/M004未关闭。
