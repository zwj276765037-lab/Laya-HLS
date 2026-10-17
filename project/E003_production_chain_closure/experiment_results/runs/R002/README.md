

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# E003 / R002 运行结果

[负责人维护的本批运行记录](run.md)

# R002 — M003/SM003/E003 启动准备

execution_state: completed
verdict: unassessed
applicability: 仅启动前的轻量依赖与身份核查；M003/L0部分完成，L1–L5及完整加速器未验收。

准备子检查PASS，保护器和child退出0。1.675503s墙钟、峰值owned RSS 23452KiB、最低MemAvailable 426332756KiB；CPU0–3/nice19/idle I/O，4GiB/120s保护。实际起止见[receipt](preparation/receipt.json)和[guard结果](guard/guard_result.json)，原始输出见[driver.log](guard/driver.log)，精确命令和cwd见[guard计划](guard/guard_plan.json)。

33个编译单元使用真实编译器依赖提取，全部退出0；并未编译可执行文件。完整请求闭包57项（56源码依赖＋1生成包header），旧实际CSim闭包47项（46源码＋1header）；新增12、移除2、内容变化7。所有构建目标合计61项对旧51项。比较见[依赖差异](preparation/full_request_dependency_comparison.json)。当前/冻结61项共122次hash与大小核对均匹配，见[复核](preparation/dependency_snapshot_verification.json)。

[preimage](preparation/preimage.json)冻结当前compiler闭包与配置生成器；432项现有模块源码/配置/IP脚本/约束库存只是候选复用集合，尚不是最终生产top闭包。2份现有XDC的适用边界见[约束清单](preparation/constraint_inventory_scope.json)。模型BO、请求和独立gold沿已核验审计按原身份复用，本轮没有重复重hash全部payload或改变输入。

[路径计划](preparation/launch_path_plan.json)使用唯一E002/experiment实现根；最终build/请求/config须在L1–L3稳定后重新生成，当前没有可执行的最终回归命令，也没有给新源码挂旧build标签。Vitis/Vivado入口路径已记录，版本和许可未新调用；当前编译器为g++13.3.0。实际模型/强度仍为null；期望工程gpt-6.1-sol/xhigh，不修改模型设置。

未启动实现变更、HLS生成、完整CPU/CSim、RTL、OOC或新代理。本项目无其它重工具；发现其它项目Vivado进程，仅记为外部资源观察，未控

（摘录截断；完整记录见链接。）

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |
| [preparation](preparation) | completed | 未登记 | [执行收据](preparation/receipt.json) |

## 本批问题与交付文件


## 本批原始收据与输入身份


历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
