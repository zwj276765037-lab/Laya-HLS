# SM004 修订14工程阶段交付（AT215–241）

回复 `m004-rev14-at225-scoped-acceptance-control-fixes-20261015`；M004/SM004/E004/R001。工程已按修订14合同完成两项普通控制修复及受影响局部回归，现提交主控集中审核；未申请新增预算或宣称修订14已由主控收束。

当前生产wrapper SHA256 `0d3e340e687d9720cdd2b1bed161adc7c4172a6c1310c08546011bc6c392e79c`。head遍历已改为Q/head0、K/head0、Q/head1、K/head1…；AUX table旧sticky error不再误拒绝新load，地址先校验、真实load握手记债、当前load_done判错。core `54fe628f…`、writer `ee1121c5…`、adapter `a80564de…`与原full-Check HLS叶子不改。AT232当前wrapper＋真实core/IP展开PASS。

AT225旧wrapper `b1315262…`的两行真实cold/warm RAW→RoPE正常链仍按主控原限定接纳：两行4096个Q/K FINAL逐位、512 RAW B＋256 RoPE B、V/norm逻辑内存不变；该旧身份的791.796564s长链不迁移到当前wrapper。当前身份AT230局部合法peer验证K/head0与Q/head1双坏输入时优先K/head0，原Check与bad=1024/状态6/phase13保留；AUX部分R后RRESP错、scratch R错、末RoPE B错排空及无reset显式discard后新epoch恢复PASS。AT241原HLS叶子局部页尾分段、两个QKV口各AW先/W先32、阻塞全字段持稳及末B发布屏障PASS。AT233严格“MUL IP已接受未返回”窗口NOT_RUN；已接受、HLS未采样时共同reset隔离PASS。AT240的128行FINAL发布只用模拟core/快速叶子peer核元数据，不是128行真实producer。

修订14截至AT241共53笔原guard（static/IP26、RTL27），精确实耗978.93351217359304232/1800s、1241.301459711045058/4800s，host完整累计UNKNOWN；旧timeout、Fatal、TB和旧wrapper复现失败均保留。报告及逐笔收据：`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md`、`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev14_guard_ledger_AT215_AT241_20261015.json`。模块`source/results.md`已追加分版结论；E004三摘要已由research.py发布为`P95e6369eca78477cb4b83dccb07c9b0f`，A002状态已更新。

当前wrapper同SHA完整真实两行链、全128行真实producer、实际物理BO与邻区哨兵、完整请求首错、Attention/整模、生产Host/HBM及联合资源/Fmax均未验。请按冻结身份与局部边界集中审核；工程现无重工具运行，M004整体仍running。
