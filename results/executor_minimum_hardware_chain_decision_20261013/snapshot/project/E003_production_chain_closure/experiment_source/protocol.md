# E003：M003生产连接与当前身份回归执行协议

mission: M003
small_mission: SM003
execution_state: planned
engineering_owner: A002

M004是完整加速器搭建与性能优化总任务。M003/L0–L5是它的生产链与当前身份前置项；之后依次进入SM004/E004全模型集成和SM005/E005性能优化，不以M003局部通过结束总任务。权威范围和验收以[M003](../../../mission/M003_当前身份生产链接入与回归.md)、[SM003](../../missions/SM003.md)及[M004](../../../mission/M004_完整Laya加速器搭建与性能优化.md)为准。

唯一实现根：/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment。E003只保存方案、三摘要、运行证据与必要冻结依赖；冻结快照不能成为另一活动实现树。原baseline及E002最终验收交付不写回。

## 已完成的启动准备

[R002](../experiment_results/runs/R002/run.md)真实轻量依赖提取与身份记录完成，准备子检查PASS；[R001](../experiment_results/runs/R001/run.md)的读取格式失败完整保留。完整请求源码依赖56项，加生成包header共57项；所有build目标61项。旧实际CSim源码46项、含header47项；新增12/移除2/改变7，故旧完整回归只能作历史对照。

33个编译单元、命令、工具入口、当前配置生成器、432项现有模块/IP/约束库存、候选复用输入/reference审计、新路径计划及CPU/内存日志均已存入R002。身份preimage仅用于接入前准备，不是最终部署build。模型GGUF、五BO、四请求和独立gold沿验收审计复用，R002只核小型身份文档和payload大小，不重复运行模型验证。Attention v10仍按183/185历史引用匹配范围复用，两处历史文档漂移未恢复，不能写成185/185零漂移。

## 顺序与下一执行入口

1. L0补齐实际受影响生产源、生成top/IP/XDC闭包；保留当前preimage用于实现差异检查。编译与生成配置全部在唯一代码副本路径重建，新包/请求必须绑定新build，不使用旧包身份代签。
2. L1依联合design §3.9实现cmd16×512bit/rsp8×512bit、两个depth2私有FIFO、单持久服务、原13BO外层及AXI-Lite ABI。先核字段C/SV逐位对应、保留位、generated FIFO极性和真实控制offset；再接锁存基址、WSTRB、角色/offset/span/溢出/宽度转换与债务仲裁。
3. L2同runtime真实Wi Q8 producer→G→quant→Down；原四distinct真实row、上游原矩阵维度、Down K2624/N1024、4096独立F32及512实际AW/W/B。链内中间值由真实DUT产生。
4. L3非零bias、晚错/首错、活动CE/reset/new epoch、多view/最后B、安全债务排空与错误后恢复。父task在真实最后B退休后完成。
5. 最终身份稳定后重新export模型包、重绑原四请求和raw身份、生成当前build和真实Vitis CSim配置。L4一次完整CPU/真实CSim及受影响有界RTL；原141独立点、18,094,384 F32、candidate/ACT和gamma恢复标准不变，未变叶子不重复全跑。
6. L5以三摘要、result、运行收据与SHA交付范围表。完整同runtime整图、联合资源fit、完整请求性能和物理/板端证据独立保留，局部cycles不相加成端到端性能。

## 复现准备核查

先用research.py run建立全新R编号，再按R002/guard/guard_plan.json的精确argv调用现有production_guard.py和[prepare_l0.py](prepare_l0.py)，只替换新的run/guard输出目录；旧run禁止覆盖。准备脚本只提取依赖、冻结快照、hash已列明的小型文件和读取资源，不运行实现/模型/EDA实验。实际回归的最终配置与argv须在L1–L3后冻结，本协议不提供用旧身份直接启动的命令。

## 保护与异常

全项目一个重工具；CPU0–3/nice19/idle I/O、MemAvailable严格>192GiB，只管理自己owned进程。轻量准备4GiB/120s；static24GiB/1800s；CPU/CSim继承更严格16GiB/1800s；RTL8GiB/3600s/40Mcycles且先120s pilot。真实120s语义停滞保护和原始child/guard状态保留。本M不新启动OOC；G累计已用1261.775981s、余2338.224019s不重置。

原模型/shape/层数、数值规则、独立gold与CPU/FPGA分工固定。普通实现修复及受影响验证持续授权；实质接口/数值/架构变化、无法解决的阻塞和成本停止要报告边界。PASS/FAIL/NOT_RUN/COST_STOP及软件/局部RTL/整图/物理/上板分别记账。

## owner与真实状态

最新合同指定A002独占工程实现/RTL/TB/运行和E003三摘要；主控独占goal、顶层mission、索引与共享登记。A002旧registry仍为M002/SM002/E002，请主控同步，工程不自行改写共享登记。无新内部代理、无模型设置变更；请求gpt-6.1-sol/xhigh，实际模型与强度尚无运行配置证据，继续记录null。

当前仅准备核查已完成：L0 PARTIAL，L1–L5 NOT_RUN；没有后台实验在运行。
