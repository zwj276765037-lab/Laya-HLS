# SM010 定向代码勘查与首段切口（2026-10-21）

范围：M007 主控委派的只读定位/整数核对；仅本文件及[邻接 JSON](m007_matrix_supply_map_20261021.json)由本执行者维护。请求模型 gpt-6.1-sol/xhigh，实际模型/推理配置 UNKNOWN。这是后继实施输入，不是架构批准或 RTL/性能 PASS。

## 已存在与具体差距

以下 E 指 `project/E002_Laya_HLS/experiment`，H 指 `E/vivado/module_design/hbm_loader_and_cache`，Q 指 `E/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512`。

| 链路 | 当前源码与接口 | 距 M007 的缺项 |
|---|---|---|
| 原权重 | `E/tools/export_gguf.py:258–270` 把 GGUF `[N,G,34]`（2B scale 后 32B q）拆为 TN8 奇偶 q0/q1 和独立 scale；`Q/tb/make_real_fixtures.py:77–101` 独立按原 tensor 字节检查 BO | 尚无 W576 packer/逆变换或四口持久布局 |
| reader | `H/rtl/t4_three_port_reader_v1.sv:3–5,40–55` 是 q0/q1/scale 三口；`t4_w_reader_port_v1.sv:39–69,131–145` 每口一个未完成 burst、64beat FIFO、最多64beat、4KiB拆分 | 需四个512bit口、每口8在途、每burst≤16beat、真实32768B返回信用和≤49152B总缓冲；不能把 AUX128bit 口算第四个 W 口 |
| W cache | `H/rtl/t4_dual_w_cache_v1.sv:58–94` 已有完整身份/lease/read/ret/release，pair读可返回512B q+32B scale；`:138–165` 冷载仍按整矩阵三BO；`H/source/design.md:203` 每槽5730816B、双槽11461632B | pair口宽可参考，但无新16-bank/depth512双超块slot、预取交叠和服务曲线证据；不复制旧11MiB缓存。旧bank `t4_w_cache_bank_v1.sv:24–37` 的同步读写/无payload reset可参考 |
| 量化/A | `activation_quantizer/rtl/quant16_stream_row.sv:3–7,16–33,73–94` 每组两个16F32输入/两个16q输出，32物理group slots、一个divider；cfg支持1..128组 | 尚非32F32/拍、1group/拍和≥128在途；无M007 A双557056B slot与16行×group供数。首段W测试不依赖改量化 |
| dot/恢复/PS | `Q/rtl/tm1tn8_integer_tree_packed.sv:3–21,109–114` 六级树、每拍8个精确21bit dot；`tm4tn8_sync_ps_front_v2.sv:298–331` 四行实例=32dot/拍=1024MAC/拍；`tm4tn8_fp_restore_v1.sv:3–5,81–114` 每实例8路转换、16mul、8add | 对8192MAC/拍、256group/拍少8倍宽度；无256个11×11精确scale乘积及完整≤64拍dot→PS/≤24拍反馈证据。A007共享 `attention_and_fp_engine/rtl/laya_shared_fp256_v2.sv:6–38` 已提供256lane独立mul/add接口，但不能等同于256lane矩阵恢复已接通 |

依据：[SM010](../mission/M007_完整Attention高性能主干与部署闭合/tasks/SM010.md:7)、[M007合同§4–5](../mission/M007_完整Attention高性能主干与部署闭合/contract.md:43)、[机读字段](../mission/M007_完整Attention高性能主干与部署闭合/performance_requirements.json:246)。

## W576 精确规范与可逆性

旧 M006 合同§5（`:115–130`）只固定逻辑 `superblock→group→四N16`、576=512q+32scale+32zero、64B record/4KiB matrix 对齐及跨页无空洞，**未明文规定 q 内 n/k 顺序、scale endian、四口分发和各口地址空间**。下列是**本轮主控消息集中固定的 M007-W576-v1**，不是旧合同已有实现：

- `G=K/32`；记录内 `q[32*c+j]` 对应列lane `c=0..15`、组内K `j=0..31`；`scale[512+2*c:514+2*c]` 保留原F16 little-endian两字节；`544..575=0`。
- 普通列 `n=64*s+16*p+c`；Wi `p<2: n=32*s+16*p+c`，`p>=2: n=2624+32*s+16*(p-2)+c`，`s=0..81`。逻辑记录序 `s,g,p`；四口p分别固定承载同超块N16位置p，`addr_p=base_p+576*(s*G+g)`，每口matrix base独立4KiB对齐，matrix内紧密。
- 不同matrix放置 `base_next=align_up(prev_end,4096)`，记录matrix间placement gap；gap不读入cache、不计414351360B。Down每口matrix长755712B，末端mod4096=2048，后继若接另一matrix则每口gap2048B/四口8192B。此间隙不是record/page padding。各口local record7起点4032，跨页为64B+512B；下条record起点4608，无补洞。
- slot为16bank×512×272bit=278528B，bank=c、address=`4*g+p`，存q256+scale16；32zero仅用于HBM记录。读一条记录544B，广播两M8 tile并复用八M16窗口。

静态可逆证明：GGUF原块起点 `tensor.source_offset+34*(n*G+g)`；scale取`[0:2]`、q取`[2+j]`，全部原字节原样搬运。普通逆映射 `s=n//64,p=n%64//16,c=n%16`；Wi令`h=n//2624,u=n%2624`，逆映射 `s=u//32,p=2*h+(u%32)//16,c=u%16`。这在六shape的N（均64倍数）、Wi的两半2624（32倍数）上是双射；`4*g+p`最大511。尚未实现/运行packer逆变换，不能把此证明称为原字节动态PASS。

| K / G | 完整超块记录数 | HBM字节 / 每口 | cache有效字节 / zero字节 | `256+ceil(B/96)` |
|---|---:|---:|---:|---:|
|1024 / 32|128|73728 / 18432|69632 / 4096|1024拍|
|2624 / 82|328|188928 / 47232|178432 / 10496|2224拍|
|4096 / 128|512|294912 / 73728|278528 / 16384|3328拍|

## 可直接派发的首段

**独立实现 W576 packer＋四口reader＋双超块slot；在 H 内新增 M007 命名文件，保留旧t4模块和旧父入口。** 输入取新工程现存 `E/build/model-q8-session-v2-actual-r2-20261010/manifest.json`，实际SHA为`46bbd5ab…98018c`；原共享GGUF文件存在（模型SHA此轮仅从冻结manifest继承，未重新hash455MB）。代表为 `qkv.0.weight` K1024/s0、`mlp_wi.0.weight` K1024/s81（跨两半/末列）、`mlp_wo.0.weight` K2624/s0、`head_fc2.0.weight` K4096/s0；准确原tensor offset/SHA、BO base/span见邻接JSON。不重建全模型包。

输出为每例四个紧密record文件＋layout元数据/源窗口身份、真实四AXI口RTL、两个真实slot及公开同步读/lease/release接口、自检TB/原始事件计数。验收逐完整superblock核所有G与四N16、零padding、原GGUF字节与旧BO字节独立一致、逆变换原字节一致；经slot公开读口逐位对照原输入，按(g,p,八M窗口)核544B供数/保持。用另一个真实超块填另一slot，核活动slot读与预取并行/切换/失败隔离；不得只核FIFO字节数或force READY。

每例从超块已排队受理到最后cache写入可读计C，按表中帽验收；记实际AR/R、≤16beat、4KiB拆分、每口0..8在途、RLAST/RRESP信用、有限停顿/错误/取消/复位和旧slot隔离。受控AXI模型须声明其供给假设；通过只代表该模型下reader/cache服务率，**真实HBM、平台映射、CDC、物理RAM资源与300MHz均NOT_RUN**。本段不依赖SM008恢复，也不代签完整矩阵或8192MAC/拍。

可复用入口：`H/tb/three_port_reader_model.py:54–74` 的旧BO独立地址公式，`H/tb/make_dual_w_fixture_v1.py:50–74` 的真实payload切片，`Q/tb/make_real_fixtures.py:77–101` 的GGUF/BO独立比对；不调用其oracle/full-matrix main生成数值gold。旧冻结`t4_dual_w_fixture_01/work`有Wi/Down，但该份缺qkv/decfc2 hex，不能假设生成器后来列出的七shape都已冻结；直接从上述现存原包/原GGUF按窗口读。

无写入冲突：A007依[SM011§存储](../mission/M007_完整Attention高性能主干与部署闭合/tasks/SM011.md:19)唯一实现PS两上下文64KiB、G/prob64KiB、context512KiB及共享FP。此次仅新W供数目录；未来恢复/PS必须经主控交接复用A007同一银行实例。A008的`host/m007_deploy`/schema不改；完整120tensor注册/Host装载及真实HBM映射留后继集中接口交接。

费用/状态：一次受控metadata+整数脚本（CPU0–3/nice19/idle、timeout20s、AS≤1GiB）实测wall0.04s、user0.03s、sys0.01s、峰RSS16440KiB、exit0；JSON为该次输出。其余只读命令未单独采样，费用UNKNOWN；重工具0、新gold0、RTL/OOC/板测NOT_RUN。未改mission、索引、A007/A008或旧源码。
