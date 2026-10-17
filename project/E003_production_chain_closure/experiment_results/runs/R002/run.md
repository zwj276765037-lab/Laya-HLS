# R002 — M003/SM003/E003 启动准备

execution_state: completed
verdict: unassessed
applicability: 仅启动前的轻量依赖与身份核查；M003/L0部分完成，L1–L5及完整加速器未验收。

准备子检查PASS，保护器和child退出0。1.675503s墙钟、峰值owned RSS 23452KiB、最低MemAvailable 426332756KiB；CPU0–3/nice19/idle I/O，4GiB/120s保护。实际起止见[receipt](preparation/receipt.json)和[guard结果](guard/guard_result.json)，原始输出见[driver.log](guard/driver.log)，精确命令和cwd见[guard计划](guard/guard_plan.json)。

33个编译单元使用真实编译器依赖提取，全部退出0；并未编译可执行文件。完整请求闭包57项（56源码依赖＋1生成包header），旧实际CSim闭包47项（46源码＋1header）；新增12、移除2、内容变化7。所有构建目标合计61项对旧51项。比较见[依赖差异](preparation/full_request_dependency_comparison.json)。当前/冻结61项共122次hash与大小核对均匹配，见[复核](preparation/dependency_snapshot_verification.json)。

[preimage](preparation/preimage.json)冻结当前compiler闭包与配置生成器；432项现有模块源码/配置/IP脚本/约束库存只是候选复用集合，尚不是最终生产top闭包。2份现有XDC的适用边界见[约束清单](preparation/constraint_inventory_scope.json)。模型BO、请求和独立gold沿已核验审计按原身份复用，本轮没有重复重hash全部payload或改变输入。

[路径计划](preparation/launch_path_plan.json)使用唯一E002/experiment实现根；最终build/请求/config须在L1–L3稳定后重新生成，当前没有可执行的最终回归命令，也没有给新源码挂旧build标签。Vitis/Vivado入口路径已记录，版本和许可未新调用；当前编译器为g++13.3.0。实际模型/强度仍为null；期望工程gpt-6.1-sol/xhigh，不修改模型设置。

未启动实现变更、HLS生成、完整CPU/CSim、RTL、OOC或新代理。本项目无其它重工具；发现其它项目Vivado进程，仅记为外部资源观察，未控制其进程。R001因历史审计对象无references字段而失败；原始失败保留，修正读取后本R002完成，未覆盖原记录。

A002共享注册仍指向M002/SM002/E002；最新M003/M004合同明确授权A002工程owner，准备不受该陈旧标签阻断。请主控同步共享绑定；工程未改主控所有的registry/goal/mission/索引。旧A002状态与result保存在[R001快照](../R001/previous_A002_snapshot)，旧E002验收及handoff保持历史完成快照意义。
