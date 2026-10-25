# E015当前：紧凑G全正常通过，剩余三组完整错误继续

AT106源声明账：15709bit=1963.625B≤2048B。394条tag省31520bit，实际新增291bit，净省3903.625B；无mask/debt/coverage/tail删除或父级存储扣除。bounded数值payload25600B、固定数值对齐736B及既有SFU/叶内部账不变；联合4KiB仍OPEN。

AT095 pool输入域8案、9真实接受/返回、7拒绝、同拍混域/空闲17不重绑/fullseq alias通过。AT107 math输入域7案、56原标量/560节点、6拒绝、held17/空闲17/显式clear后seq0同域重用通过。AT108/111–114分别测试seq512/伪256同ring、旧gen、错epoch、保留位、额外FP记录；坏记录不退真实债，真实正确返回随后退休、partial done8/held17/discard/新gen12288均通过。AT115原匹配FP status8故障亦复验通过。

AT109/110原三块/held17通过，首185/最大块697；AT116/117最终同版32768中样17.76166324602673/17.755463239969686秒。AT118完整335872输出/3358720 FP9+H逐位通过；20992写ACK、41984读、82release，首185、完整自然eligible→真实done42171、最大块697、读/输出gap1、20735读写重叠、81次另一槽仍在途时释放。child128.6858779839822秒，328真实事件，性能与precompact完全一致。

AT120完整rank0晚x对早gate通过：335872主/3358710可评估主节点，total348160/3481590节点，2数值错误、done6 held17/错gen discard拒绝17/合法discard/实际lease释放和无reset新gen12288全部通过；child135.0427505680127秒。AT121–123 rank2/rank5/同rank逆物理row三案已按同版完整实测158.54702562481398秒界、180秒帽提交串行，未提前签当前版本四案全通过。

保留：AT092测试组合探针semantic stall120.09952738101128秒，寄存实际接受探针AT099及最终AT108/111–114通过；AT096/100实际重复seq0清除边界零高64tag失败，显式context参数修复后AT107通过；AT119 argv顺序不合exact plan，COST_GATE_STOP/child0，无仿真/源码归档，实际AT120按冻结argv重提通过。未删除checker/改gold/重置费用。precompact AT072/075–078、冻结AT055及所有旧FAIL按原SHA保留，不跨版升级；无parent/联合SFU/896DSP/物理300MHz或P&R声明。


---
Published: 2026-10-22T10:47:19.367529+00:00
Publication: Pd1bbb3b8bce54dc7b45e86d78489d1a2
