# 当前单线程 fullgraph 模拟器的有限加速候选（只读）

A010，2026-10-23。范围：E021/R002/AT003_fullgraph_peer_unrolled 的实际生成代码/object/编译记录，以及 AT004_fullgraph_fixedbatch_pilot 的实际 main、runtime overlay、119s pilot。没有实现候选、启动 profile/EDA/编译、复制生成树、写 E021/tools 或新建实验尝试；R007 预算不变。期望模型/强度 gpt-6.1-sol/xhigh，实际配置未核实。

当前不能承诺明显全图提速。优先完成原同 exe 首完整层成本样本；下面的候选均应成为独立后继，不能边跑边改当前源或用局部时间替代30层成本。model4 的实际数值 FAIL 继续保留，不推荐重试多线程。

## 已核事实

- AT003 fresh build 为742个生成 C++ 单元、268117455B；实际成功 compile 记录分布为536个 `-O2`、206个 `-O1`、3个运行库 `-Os`。Verilator 命令的 `-O3` 是翻译器优化，不等于 C++ 的 `-O3`。没有记录到 `-ffast-math`、`-Ofast` 或关闭树向量化的选项；不能假设当前 O2 完全没有 SIMD。
- AT004 仍为 model1/context1、local fixed-batch-v1、converge512。主循环严格为 eval→只读 observer→eventsPending/nextTimeSlot→time；没有额外 eval。timing runtime 实际仍编译为 `-Os`，main 为 `-O2`。
- pilot 用户+系统 CPU118.948071s、wall119.005002s、实际1线程；系统 CPU0.072985s。它说明 CPU 密集，不能区分调用/整数计算/缓存/调度各自占比，也不能由 read_bytes0 判定没有文件操作。

## 三个候选（尚未实施/测收益）

| 优先级 | 有限变更及依据 | 必须保持的边界；预期判断 |
|---|---|---|
| 1 | **只清除已证实无副作用的跨 TU 空 dispatch 调用。** `…h1b9c86bc__528.cpp:932` 的 eval_nba 顺序调用590个 wrapper，其中579个为空；`…__104.cpp:377` 的 eval_act 调用74个 wrapper，其中63个为空，52个同 TU、11个跨 TU。对实际 object 用 `objdump -r` 按完整符号精确匹配，确认528.o保留579个、104.o保留11个跨 TU 空调用。只需对这两个 caller TU 制作后继并重新编译/归档/链接。实际原编译分别2.837885s、1.535374s，只是历史成本，不能作新构建上限。 | 当前实际 flags 无 `VL_DEBUG`，空体只含 unused 消除、普通 Symsp 局部指针和 `VL_DEBUG_IF`。未来必须逐个核正文/预处理状态，不能按名称或“模块闲置”删除。仅删这590处精确已证实空调用；11个非空 active/11个非空 NBA wrapper 的顺序、trigger 计算、time-slot、全部 signal/NBA/断言和512收敛循环原封不动。旧 source/object 冻结，逆变换恢复。数量多不等于占时高；仍需相同端点实测。 |
| 2 | **按实际 PC 热点选择少数单元改标准优化等级。** 第一小步可仅将当前 `-Os` 的 fixed-batch timing runtime 改 `-O2`；它每 time-slot 处理 coroutine/队列，重编译范围仅一个对象。更大的机会应是实际热的1–3个生成 TU 做 `-O2→-O3`/正常整数向量化 A/B，而非重编全部742个或提高206个 cold 单元。候选位置包括 trigger 单元 `hd5778669__0.cpp:905` 和 active/NBA调用附近，但未取得热点占比。 | 不使用 Ofast/fast-math/unsafe-math/浮点重结合，不改整数位宽、RTL表达式、浮点算法或响应拍数；保持ABI、头文件/PCH一致性、原fixed-batch算法/guard/1线程。当前O2可能已有向量化，O3也可能扩大代码、恶化I-cache；没有PC证据时不以268MB源码大小推断收益。若runtime样本占比很小，跳过此分支。 |
| 3 | **main observer 的小范围分支/存储整理。** AT004 main:27读4个phase字段；31–33每次eval后构造15字段粗化数组、比较并更新last数组，即使没有变化也写last。可保持同样字段与逐eval采样，只在changed时复制last；编译器可能已部分消除，收益未知。 | 完整保留原OBS/PHASE的触发、字段、时刻、flush，以及独立RTL_RETIRE/checked guard。不能降采样、把cycle当心跳、跳eval或删gold/断言。保守视为低收益候选，不能用它解释kind5/kind7约3–4%差异或预计显著全图改善。 |

## 闲置模块/时钟与 eval：已有门控及不能跳过的部分

生产 `laya_shared_fp256_v2.sv:56–60,98–100` 已用 fire、inflight、pending、raw-valid 判断 transaction-empty CE，reset始终开启；mul/add叶实例接真实CE（87/121）。`laya_fadd_rne_v1.sv:73–78`、`laya_fmul_rne_v1.sv:54–57` 已在CE下推进valid与数据。控制/credit/ready/故障检查仍逐拍运行。全局“idle/owner未选中”不能替代这些条件；直接停clk、跳模型eval、冻结整个module、忽略held response会改变状态/取消/lease/drain语义，当前不作为低风险候选。

生成调度也不是“每次eval无条件跑完整模块”：`…__530.cpp:438–471` 根据trigger进入active/NBA，482–520保留嵌套收敛；非空wrapper里还有细分trigger。可清理的是上面已证实的no-op调用，不能将它外推为任意非空闲置函数可跳过。`__104.cpp:55` 的12288bit coverage默认拷贝等宽复制确实存在，但未测其实际热度；不据此改生产/覆盖语义。

## 无 perf 权限时，用户态 PC 采样是否值得

**值得作为 A012 的有界诊断评估，尚未实现或启动。** 主控提供 perf_event_paranoid=4、无可见clang++/valgrind；无需改系统设置或依赖perf附加。实际 AT004 exe 是x86-64 ELF64 PIE，未剥离，保留592个eval_nba相关定义符号，能做函数级归类；没有 `-g` 不能承诺源行精度。

可由 A012 在隔离的局部main后继，仅对实际单线程model设置约97Hz `ITIMER_PROF`/`SIGPROF`、`SA_SIGINFO|SA_RESTART`。handler只从ucontext读取PC到固定容量、可丢样的预分配记录/非阻塞write；禁止handler里printf、malloc、unwind/backtrace或任何modelroot写入。PIE映射基址/模块表在handler外采集，离线结合当前exe符号。不得把LD_PRELOAD施加到guard/父Python/其他进程。timer必须停止并恢复旧handler；统计实际样本数/丢样/总开销。

建议只规划10–15s steady-head和10–15s Wi/G各一个窗口（或在已授权首层运行中受控采样），先确认runtime、dispatch/trigger、FP整数核、宽拷贝各自占比。信号中断文件操作、采样扰动/丢样和地址解析都需验证；采样运行仅用于热点诊断，成本比较仍用不带采样的相同exe端点。缺省先不实施，避免干扰当前首层样本。此诊断不驱动RTL，不改变gold/硬件周期；也不自动证明诊断后继与原运行等价。

## 证据及版本边界

路径下方用 `B=project/E021_m007_compiled_rtl_validation/experiment_results/runs/R002/attempts`；`A=B/AT003_fullgraph_peer_unrolled`；`C=B/AT004_fullgraph_fixedbatch_pilot`；`O=A/work/obj`。这些都是原路径引用，无数据搬移。

| 原记录/源 | SHA256或精确定位 |
|---|---|
| A/config.json；C/config.json | b25f82ef48af29ea0280091b86f262fe1937cec4dd2a2a48195fcddb897ca8f5；f94bccf7003cac41f050e1d5a770584e3f97aac7bd866e24443e338e0b9621f2 |
| C/overlay_commands.json；C/kind7_frontier_analysis.json | 3cd14c8ab7544ab99e1f500836d80156d60bbc28fef86e7274e04e0355462916；3556fa235dcd2f9a20d3ddc672c354a9d62793fecf1d978f15dbf9e2e5ed45f5 |
| C/work/obj/Vm007_fullgraph_binary_tb；同目录__main.cpp | c47d9d4fc4328582a8e4bd51914a1ad36e5fab42f06b77d510e999c66d54649e；34956efe3ab7a9d94a1e286494a20c4930267b03963a5b9ebf48bfb07355fbe1 |
| O/Vm007_fullgraph_binary_tb___024root__DepSet_h1b9c86bc__104.cpp；.o | e545b070431a4accc43a7a91a6567415b9db8e53dc9cbe53c56dea7411d85520；1ab1d8826045f63478aa3e9dca44272d667d7681bffd59fed3b85b2ac9d2890d |
| O/Vm007_fullgraph_binary_tb___024root__DepSet_h1b9c86bc__528.cpp；.o | 52e7a3433c85473f30c1ee94ba0553ca80fdc2ab6e9b599441cade59c78ddbcd；2226d41cbc0f7504fb4a362eeebe70872aeaddea47d74c37a2a0b6096b4757e1 |
| A/cxx_units：528/104/runtime实际编译记录 | 1792761178896456968_920290.json；1792761258530039995_923096.json；1792761412954533830_929823.json |
| 当前runtime_fixed_batch_v1/verilated_timing.cpp | project/E002_Laya_HLS/experiment/tools/m007_verilator/；545efeb8946e4fdc3b344d1cfaa840abda7f98f7a610cc93efda8b22f8485ebc |

本文件是只读源/编译产物分析，不是优化验收或运行证据。下游实现/采样/重编必须由A012在其实际资源与后继版本记录内执行；此处没有扩大R007预算。
