# E015：G功能/周期阶段完成，控制容量不合规

AT055冻结八lane：336262主输入/14123004原42节点逐位PASS，153拍/II1；协议消费338828/14231096节点，满256信用、held298、6拒绝、17向量在途reset及64新gen、错误/掩码/release真实债屏障通过。原107.642217563秒，未重跑。小叶add3_e/mul4/div12 setup分别+0.098/+0.332/+0.182ns，hold全部仍失败，无P&R/物理300MHz。

AT057银行组件PASS；AT064纯算术12288原元素/122880外FP9+H比较PASS，首消费183拍。AT067/068真实三块+末G held17证据已由主控增量51限定接纳。组件pattern不代签算术；3块prefix保留命令等s3。

AT072完整335872原GEGLU输出、3358720外FP9/H检查逐位PASS；20992真实写+ACK、41984同步读、82release。首消费185≤256，自然eligible至实际done42171≤42240，最大块服务697≤768，跨s读/输出gap1，20735真实读写重叠、81次另一slot math+SFU在途时独立释放；正常done held17和真实lease释放通过。child129.274490395037秒/RSS864370688B，328真实事件。

四个完整错误案均335872主+12288无reset新gen原输出通过，2个数值错误记录，done6 held17、错gen discard拒绝17、合法discard与真实排债通过：

| 案 | 首错rank/row/column | 原域可评估主节点 |
| --- | --- | ---: |
| AT075 gate_then_late_input | 0/127/2623 | 3358710 |
| AT076 gate_then_late_v | 2/127/2623 | 3358713 |
| AT077 gate_then_late_z | 5/127/2623 | 3358715 |
| AT078 gate_inverse_row | 7/0/32 | 3358720 |

每案340语义事件；原域支配排除分别10/7/5/0，未伪造u/t溢出或评估记录。恢复均为真实3块prefix，未签新gen整命令完成。

AT080单列peer协议：真实匹配FP返回只改一次status8、valid/tag/data不变；69 math向量、70银行读、327写/ACK真实退债后partial done8，held17/显式partial discard/lease释放/无reset新gen12288通过，总12840元素/128390未受故障节点检查；无数值全域成功或wrong/missing-tag注入声明。

AT071精确新增G control46938bit=5867.25B，超过4KiB；bounded算术payload25600B、固定数值对齐736B另列。身份标签/真债/原域mask逐字段及候选可推导项已列，未实现压缩、未借payload归类扣除，原SFU/固定叶pipeline不重复混算。联合SFU/896DSP/FFN/父级/物理仍未闭合。

AT081核25恢复尝试、25源码归档/1009归档文件、181编译snapshot文件、90选中source/input身份；所有当前已验源一致，旧AT059/061差异单列。AT060/062观察器FAIL和AT065声明编译FAIL保留；直接原fixture修复后通过，不追改旧失败或宣称已定位XSim内部根因。AT051、AT008–013 guard身份UNKNOWN、AT034未启动和旧小OOC hold边界均保留。


---
Published: 2026-10-22T09:33:55.537786+00:00
Publication: Pfadc02208bd041c5b6b3832bbae173fd
