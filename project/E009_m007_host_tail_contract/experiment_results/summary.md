# NATIVE-CPU-03 / R002 completed: native function PASS, performance FAIL

execution_state: completed
verdict: PASS_SCOPED_NATIVE_CPU_SESSION / FAIL_SAMPLED_LIMITS

Final version AT022/023 passed156 checks, including both frozen requests' complete
H0/13 tail stages/rawCLS/final18 bit equality,4 original JSON baselines,42 original
decode vectors, VNNI signed limits, full/lazy cache equality, reload, binding and
output/fenv/affinity error recovery. Counts are checks, not independent whole-model
requests. [Final evidence](runs/R002/release_evidence_v4.json) and
[handoff](runs/R002/native_cpu03_handoff.md) freeze binary/source/libm/inputs.

AT025 full-mode production wrapper:200 warm requests, plus2 first requests and32
new-word requests (234 complete calls total). Input includes internal JSON/BPE,
recipe, binding/validation, H0 allocation/copy and sync; tail includes business decode.

| Final cohort | Input median / P95 / max (ms) | Tail median / P95 / max (ms) | Violations input / tail |
| --- | --- | --- | --- |
| Full warm n200 |0.498548 /0.588732 /0.666537 |1.912646 /2.080202 /2.726395 |0/200,6/200 |
| Full new words n32, all model-token cache hits |0.476758 /0.494244 /0.495972 |1.901414 /1.925048 /1.933525 |0/32,0/32 |
| Lazy true new-token n32 (AT026) |0.542792 /0.594254 /0.601589 |1.862338 /1.900331 /1.901052 |0/32,0/32 |

Full first input1141907ns/913050ns exceeds750000ns, despite no token misses;
tail1904130ns/1362959ns is below2250000ns. Lazy first26/32 new-row inputs are
1115594ns/914669ns; first lazy tail2263643ns also exceeds. These are separate
cohorts, never hidden by warm medians. Full initialization1472907305ns includes
135673406ns all50368-row fill; cache206307328B (196.75MiB). Production profiles
blocked Python reference import/execution and recorded actual caller0–3/restored,
workers1/2/3. No Attention/device/whole-model quality, system QPS or GPU comparison.

AT027 audited38 current production source files against recoverable39-file native
closure; binary921b329f...8593d72,16 non-saturating VPDPBUSD instructions,0 saturated
VPDPBUSDS and0 FMA instructions. Earlier AT003/005 load failures, AT007 JSON-order
failure, AT010 harness failure and all performance FAIL versions remain separate.
AT015200 had4 tail violations; AT018200 had12 input/9 tail violations; AT021/024
first-input pilots also failed. No same-binary200 run was repeated to seek PASS.

R00227 attempts: reference/unit29.906244418991264s/600s, compile173.74383348802803s/900s,
local profile15.288382256956538s/180s; peak owned-tree RSS434528256B. No costs transfer
from R001. Predecessor archive [record](runs/R002/predecessor_v3_archive_record.json)
and all original R001 reports remain unchanged. CPU performance remains open;
next concrete CPU boundary is a single native JSON/request/H0 entry eliminating
the large token/mask JSON roundtrip, with new evidence before any stronger claim.

Historical accepted results follow with their original version boundaries.

# FRONTEND-02：真实JSON严格S128前端与原业务解码已交付

execution_state: completed
verdict: PASS_SCOPED_FRONTEND02
review: PENDING_A001

当前实现和版本见[release_evidence_v3](runs/R001/release_evidence_v3.json)。
512B schema及68KiB出口不改；公共Host、模型、独立参考和RTL保持只读。

| 新范围 | 实际结果 | 证据 |
| --- | --- | --- |
| 原生桥和独立原生对照 | g++13.3/C++17/O2/no-fast-math/no-FMA编译通过，AT020 stderr为空 | [build identity](runs/R001/AT020_frontend02_clean_build/build/native_frontend.identity.json) |
| 严格S128/身份/业务解码 |133项检查PASS | [AT021 report](runs/R001/AT021_frontend02_identity_checks/checks/report.json) |
| 真实CLI |2问JSON→tokens/masks/markers/request/H0、两份冻结logits→原业务答案均通过；超长/非有限退出2、无部分H0/答案；device退出3/NOT_RUN | [AT022 report](runs/R001/AT022_frontend02_actual_cli/cli/report.json) |
| 后继native CPU源可编译性 |9/9原C++源编成普通host object；未link、未运行数值/性能 | [AT023 diagnostic](runs/R001/AT023_native_cpu_seams_probe/probe/report.json) |

133是检查/断言数，不是独立请求数。原未触发裁剪的基线有4个单问结构化JSON，
涵盖Noul、Choice、Score、中文、特殊token/相同描述候选；逐token、marker、mask与原BPE/
renderer/build_sequence完全一致。另有2个接受边界样本（精确128和合法>48-token选项）。
两问H0集成含复用样本，不作为新增独立统计样本；129/长state/过长选项/17候选明确拒绝。
完整序列<=128但单选项>48时保留全部token，旧48cap裁剪结果仅记录有意策略差异，不作gold。

42组合法decode输入为14个qtype/候选形状×正常/相等/ULP附近3类，覆盖温度桶、argmax
首槽tie、ACT0.5及附近与原confidence/round4。输出raw F32位型、标签和原答案JSON均与
单独编译的原private member体一致。原engine.cpp全文件SHA为
4f169af9397d80d6a7d785f1dc0c40bbe4c20f554f5742dd0d9a2cb83c11e741，原member文本SHA为
 aa404af639460e149962c893882b63de140b61099842b10bb7bc2c090f8a60da，原数学body SHA为
6178b69b279de78bec6e84e726426b30c9acbf88c2328b358fe60f8752095a1c。
这是明确的原源码适配对照，不是运行完整DecisionEngine或重新独立推导数学gold。

生产helper无ModelExecutor/Attention。其metadata由实际完整GGUF SHA和<=4MiB读取绑定；
oracle另经原GGUF库读取原metadata/BPE。模型无ggmlc.decision，采用显式native Laya兼容recipe。
任何18logits非有限或候选/ACT F32中间溢出在原softmax_temp前拒绝，不触发旧均匀fallback。
prepared JSON、问题、request/generation、五身份、文件长度/SHA和路径关联均有拒绝测试。
两份冻结logits接入的是明确的合成问题标签；不签真实业务质量或完整前向。

R001累计参考/单测31.98233813303522710s/600s，编译62.55692286798148235s/600s；
23次尝试计费，保留AT002/005两次首段harness FAIL与AT018保守编译告警。峰采样RSS
296886272B（约283.13MiB）；统一锁、CPU0–3/nice19/idle保持。

功能计时仅定位：AT021 native session初始化1.228s、模型handle初始化1.061s；H0两调用
166.208ms（首tensor/参考设置）和21.0323ms（同handle缓存后）。8次encode含JSON/IPC为
0.271–1.055ms，45次decode为0.109–0.246ms，不是等输入或P50/P95基准。
BPE/业务decode已native；H0和整个68KiB→18logits仍是Python参考合同。下一段需要持久native
H0/尾部与通用model+token post-LN缓存验证。[CPU复用/局部诊断交接](runs/R001/frontend02_cpu_handoff.md)。
CPU750us/2250us、完整图、XRT/设备/DMA/TAIL_READY、联合物理与板测均NOT_RUN。

---

以下为已接纳首段AT014–017的历史结果和费用，适用release_evidence_v2。

# E009 / SM009：可运行Host与严格CPU边界已交付

execution_state: completed
verdict: PASS_SCOPED_CPU_CONTRACT
review: PENDING_A001

本段交付单一schema、Host序列化/验证、生成的C++常量/SV包、严格H0与CPU尾部
适配及真实CLI。最终schema SHA为
`c3d8d192e26cc249a07818f73f2926181965fd460faa5ea140b28d689517d24c`。
元数据512B；H0=524288B；出口17x1024 F32=69632B。生产XRT映射尚未绑定。

| 本段验证 | 结果 | 原始证据 |
| --- | --- | --- |
| 实际模型/graph/参考身份 | 455179648B模型和嵌入graph完整SHA匹配；GPT2 tokenizer、特殊token、温度实值已取得 | [AT003 assets](runs/R001/AT003_asset_identity_pathfix/assets.json) |
| 原tokenizer/recipe/frontend来源 | 9份真实源身份；GGUF无ggmlc.decision，原runtime使用显式Laya兼容recipe | [AT012 来源](runs/R001/AT012_frontend_identity/frontend_identity.json) |
| 单schema Host/SV生成与Host编译 | g++13.3 / C++17 / -Werror通过；SV仅生成，未仿真 | [AT017 log](runs/R001/AT017_generated_magic_version/stdout.log) |
| 独立字节ABI/负向/marker/身份测试 | 16项PASS，含marker127/128、重复/无效槽、mask/qtype/候选、u64溢出/BO边界/重叠、原CLS保护、有限输入算术溢出、错误与陈旧完成 | [AT014 完整日志](runs/R001/AT014_immutable_request_unit/stderr.log) |
| 两份冻结H0/紧凑尾部等价 | 每份16项比较全部0位差；qtype2/k2及qtype0/k3；最终36个logits逐位一致 | [AT015 report](runs/R001/AT015_immutable_request_replay/replay/report.json) |
| 实际CLI | prepare-h0的131072个F32与旧独立gold逐位一致；tail命令18logits逐位一致；device-status退出3/NOT_RUN | [AT016 log](runs/R001/AT016_immutable_request_cli/stdout.log) |

CPU尾部调用冻结`tests/full_reference.py`原数学，保留marker LN、scorer baked与显式bias、
原GELU、F32 FC2、mask/prob/stats、raw CLS、F16 ACT FC1与Q8 ACT FC2。
完整图旧独立参考只读，冻结Decision末hidden仅作输入，没有新跑全图或从适配输出制作gold。
398524次F32位型比较含返回logits及rawCLS的额外重复核验，不能当作独立样本数。

总参考/单测15.24667198603856360s/600s，编译1.23263439000584185s/600s；
所有17次尝试均计费，包括AT002输出路径错误及AT005旧manifest可选id字段导致的FAIL。
旧0efce56d... schema仅适用于AT001–008历史范围；AT009–017绑定最终c3d8d192...。
每次<=120s；采样owned进程树峰值RSS125177856B（约119.38MiB）。
实际CPU0–3、nice19、ioprio24576（idle）在最终receipt已核；统一flock覆盖子进程全生存期。
[完整成本/源码/尝试账](runs/R001/release_evidence_v2.json)。

限制：本段CPU contract是功能适配，无CPU时限、完整Attention、RTL、OOC、P&R或板测PASS。
原`sequence.cpp`仍截断head/options/state，不能直接作为M007拒绝超长的S128生产前端。
真实state/questions前端、业务decode_answer适配、最终BEGIN/XRT session、BO group_id及设备
TAIL_READY/Check退休需要后续owner完成；无设备成功stub或silent CPU Attention fallback。

交接自查另修复Request对外部list的别名与解码tuple比较问题：构造时持有不可变tuple，
AT014新增独立列表变更/完成身份回归；AT015/016冻结回放与真实CLI同运行源码闭包再次通过。
AT017仅补单schema生成的MAGIC_LE/SCHEMA_VERSION常量，独立C++断言通过；无字节布局或数学变化。
前版release_evidence.json保留，当前最终以release_evidence_v2.json为准。
