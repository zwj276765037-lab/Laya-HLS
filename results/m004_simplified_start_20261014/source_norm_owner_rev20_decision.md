# 修订20：上层source/norm单一归属与真实LN128阶段

2026-10-16；D-M004-SOURCE-NORM-OWNER-01；A001→A002；M004/SM004/E004/R001。承接[修订19限定审核](ln_shared_service_rev19_at325_stage_decision.md)及原[D-M004-LN-SHARED-SERVICE-01](ln_shared_service_rev19_decision.md)。采用既有[两模块静态切口](../../source/fixed_graph_architecture_20261014.md)，不再研究新架构。本段完成上层控制迁移、同版父请求入口与独立生产stage验证；工程在下列独立预算内连续实施、修复、回归，无逐项审批。

## 固定实现边界

起点为AT322–325同SHA：下层63da9112…、core8c799f91…、上层c6ca8ca7…、wrapper8294dc2f…、sequencera4c999e5…。A002继续唯一拥有E002 RTL/TB/design/results及E004原始证据；A001拥有本合同与集中审核。保留一份LN/Q、一份8×656×32bit final_bank、原skip/Q bank、两reader与单writer及原FIFO/holding容量；原leaf/FP/IP、数值顺序、共同clk/reset、无ready返回和同步读周期不变。无HLS重综/OOC/P&R、gold/完整oracle、第二bank或新agent。

上层`laya_source_norm_service_v1`须实际拥有以下控制，旧层不得保留可同时运行的副本：

- 从sequencer移动staged请求描述符验证/锁存、base_id/retired_rows、S_SEND/S_ROW/S_STAGE_READY和16行`drain_store_window/store_error_*`完整Check保持。原sequencer staged分支只传递一次请求握手、持有/错误与discard；legacy QKV/RoPE循环仍归原分支。不能让测试台逐行发命令来代替128循环。
- 从wrapper移动IN_* source/gamma预装、input_hold及读完成/错排空，norm SEG_PREP/READ_REQ/RSP/FLUSH/UNFLUSH/RELEASE/Q_DONE等对应分支，以及行退休、成功覆盖和错误完成条件。`stage_clear/row_retire/store_fault/ready_commit`须成为上层内部事件，不能由外部TB或旧wrapper决定成功位。上层现有reader/writer/路由原位复用；legacy source与QKV/RoPE固定客户调用同一生产服务。
- 128行staged上下文、norm_written、阶段失败及完成保持只有一份owner。外部tensor/epoch状态与该上下文的代理关系写清，父层不得另建影子位图后用它发布。正常stage ready保持到真实消费者/明确discard，绝不等于完整request_done、RAW或FINAL发布。

独立stage直接连接这一上层与同一真实下层，只有AXI存储peer及未活动的legacy客户端空闲接线。下层继续拥有LN_ONLY生命周期；其现端口还依赖父侧准入、prep_consume、bank_idle和完整Check映射，迁移时一并把**原staged固定准入/身份/Check逻辑**接成生产路径。result/done的id/row/epoch与result_exec=001来自接受时上下文；原op=0x10/status16/detail32/bad64映射与原行内/16行索引保持，不能由独立TB补齐或只检查4bit status。可将原纯映射移入下层固定输出，并让父core代理同一输出；保留legacy接口。活动状态/物理债必须由模块真实状态导出，外部空闲客户端常量不许覆盖LN或reader/writer债。仅为端口落地作必要下层调整，不扩展Q16父图、STEP16或矩阵。

## 必须保持的退休和错误行为

gamma先kind11完成1024项finite检查、真实256次AUX R及prep提交，随后每行kind01读取STATE0+s×4096；gamma身份在128行间保持。真实128个同步norm响应、64笔OKAY B、flush捕获/撤下、读写及bank pending/rsp债零、下层release/done消费后才置该行成功位并递增。末行不得回绕；非法base_id/range零发射。读取失败必须排完已接受事务再abort，缺数据不填零。

store故障锁存原首个错误、真实排债、禁止新增写；仅继续原当前16行LN算术窗口，成功norm通过故障上下文授权的discard退休而不置位、不增加成功B。窗口中数值Check优先，窗口全算术成功才报保存的store错误；不得把这一规则扩展成已证明旧整模首错等价。明确正常退休、算术成功但store故障后的discard计数、写成功数三个口径。

AUX/core LOAD/source/RoPE切路须等真实load_done/out_valid/input_hold清空；writer须末B、flush撤下及debt_zero后rearm/换段。上层对下层的release须同时核同步read pending/rsp和叶子债，不能仅看IDLE。共同reset清有效状态及peer活动，仍不签独立AXI reset。旧e/e+1/e+2、失败sticky和显式discard规则保持，不自动释放后续WO残差需要的norm。

## 集中验证与构建顺序

先完成上述单一owner迁移和设计状态表，再以独立stage作快速编译/短测，稳定后构建同SHA真实S128请求父top。避免每搬一组寄存器便重建全部重父图。复用已核且未改的库闭包，重新编译全部受影响源；冻结实际源码/FP/IP/工具/TB和**实际运行所读fixture**。未变AT324/325局部证据按SHA复用，仅端口/占有或读时序受影响时重跑对应短例，不重跑旧长算术基线。

1. **真实独立阶段。** 用原完整B1/S128 STATE0 raw、gamma及131072字norm gold，由一次固定请求触发生产循环。首次pilot≤120s，逐行记录source/LN/末B/退休cycle及单调墙钟；只观察到前缀时如实记录。完整首16行须16384norm逐位、1024 sourceR、1024成功B、gamma256R及真实覆盖。pilot可以在16行退休后有明确前缀终标退出，不能缩小生产128形状。取得同版完整窗口后，保守全128估计至少为该16行总墙钟×8×2.5；估计≤1440s且RTL余量能容纳1800s时，自动一次≤1800s/40Mcycle真实LN128，不等新批准。全例核131072norm、8192 sourceR/8192成功B、128唯一退休、末B屏障、最终内存复扫和真实NORM_STAGE_READY，request_done/RAW/FINAL仍不得发布。没有完整16行或不落帽则交COST_STOP与实际瓶颈，不同配置不得拼接、同配置不自动加时。
2. **真实父请求入口。** 同版`laya_qkv_s128_request_v1`连完整父层实际例化两共享模块；至少一次请求接受后由生产控制自动完成真实row0，核1024norm/64B及退休事件，有限前缀禁止提前请求成功/阶段发布。与独立服务同输入行比逐位结果及握手/退休约束，允许明确固定代理带来的控制周期差，不宣称父重图仿真提速。TB须有自身前缀终标和终点计数，不只固定时间quit。AT323逐行命令TB可以作局部回归，不能代替本项。
3. **迁移受影响的错误与反压。** 真实source晚RRESP或gamma load_done错误真排空→显式discard→新epoch恢复；真实norm末B错误→原16行窗口延后检查/discard规则；有限AR/R/AW/W/B停顿与一例4KiB页界；prep或LN/回放真在途共同reset后510拍隔离及新行恢复。合并至同一新stage TB，用运行参数选择，保留全字段保持及真实B checker。16行store/numeric先后控制可用明确合法完成peer作局部区分，但至少保留真实store错后下一LN行及恢复端点，不能把peer结果写成16行真算术。
4. **持有与交接。** 同步pending/rsp受阻及末B受阻时，禁止release/覆盖/阶段ready/legacy换路；释放后真实债零才能推进。正常末行可合并在LN128中；若LN128未跑，只用标明模拟完成peer的128元数据短例覆盖末行屏障，不作为真实LN128。改动到下层接口时只补受影响Q16部分占有/同步读短回归。

## 独立预算和出口

修订20host准备累计300s/8GiB；static/IP累计1800s/24GiB、单次600s；RTL累计3600s/8GiB、单次1800s/40Mcycle。首次未知路径pilot≤120s，真实语义停滞120s；CPU0–3/nice19/idle、MemAvailable>192GiB、全项目单重工具。至少为最终同版父请求top编译与受影响修正保留400s static计划空间；它包含在1800s内，不是追加额度。仅改变TB可增量构建，生产层次改变必须实际重新展开。旧修订19余额封存，不挪用、不回填；所有失败/构建/局部/长例入同一账，host未知项如实保留。

本段交付重点是上层单一owner是否完成、独立stage及真正父请求top是否同版、完整16/128是否到终点及成本。实现/连接/TB/守卫普通错误在帽内连续修复，不为每次动作另建审核文档；阶段变化、实质阻塞或集中出口回传。预算不足时先交已完成映射和确切缺口，不把未测试端口声明为可用。完整Q16父图、matrix/全RoPE/FINAL→Attention、旧全请求首错、完整模型、Host/HBM/物理BO与联合资源/Fmax继续开放。
