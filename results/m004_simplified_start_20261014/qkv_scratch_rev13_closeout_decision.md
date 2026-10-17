# 修订13集中收束：真实长链与新控制修复分版接纳

2026-10-15；D-M004-REV13-CLOSEOUT-01；A001→A002；M004/SM004/E004/R001。回复 m004-rev13-at212-at214-flush-echo-debt-fix-handoff-20261015 及数量勘误。

主控已独立核AT212–214的98条冻结身份（8/10/80）、31份原manifest/guard/plan/policy/log及56条实际政策；AT211/214共同80项仅wrapper改变。旧/新复现的TB、同步peer与writer逐字相同，AT212真实首段8rsp/4AW-W-B后身份错误与flush_done同拍，原Fatal FLUSH_ERROR_HANG/child1保留。AT213 wrapper `daae56115474afa20d04598964eca85869e86226ca9abcf3e5e8945660e06db0` 仅改ERR_FLUSH读响应门控和真实债零出口，满足原错误合同；7/12、一次release/core done、sticky failed、显式discard后epoch2/rearm及完整局部行通过。原终态/回显/逐口AXI/128位元数据局部回归及AT214真实core/IP展开接纳。

账目勘误：实际是**7笔guard（3 static＋4 RTL）**，不是通信所写六笔。新增static140.9475372545421145s、RTL24.328721918165684s；累计static615.5153379254043043s/1800s、RTL1498.1496843509375738s/4800s，与原未舍入guard相同。费用无需改变，只请同步原阶段报告/摘要中guard笔数；历史消息和原证据不回写。host完整累计UNKNOWN。主控机读字段 `revision13_at212_at214_drain_closeout_review` 保存逐笔来源与判定。

修订13据此收束，不再为相同基线启动重工具。AT204 e5dde5cc…旧wrapper的真实两行scratch、第二行末B错误排空后完整FFN至残差done仍按原冻结身份接纳；AT210/213新wrapper仅有受影响局部控制验证，AT211/214只有真实core/IP展开，不把旧1404秒实测迁移给新身份。所有旧FAIL/COST_STOP保留。未用static/RTL余额封存，不转入下一段。

M004/SM004整体继续running，完整128行真实producer、物理BO隔离、RoPE/Attention、全Encoder/模型、生产Host/HBM及联合资源/Fmax仍开放。下一RoPE的静态接法已核82条来源中81条当前相同，wrapper后续普通修复的身份差异已单列；主控已让A003用原冻结独立RoPE函数仅补当前两行参考，原gold不改。修订14正式接口/预算将另给，当前不提前实现；无需用户或中间步骤确认。
