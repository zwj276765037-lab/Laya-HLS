# 最小纯 layer 抽取接口映射（准备，未实现/未运行）

历史准备映射。R004现已实际抽取；当前接口和窄版本SHA以 `E010/experiment_results/runs/R004/pure_engine_interface_current.json` 为准。当前cache owner覆盖所有非IDLE（含PREP/held取消），不再采用下文历史L_PREP例外；原R003结果不追改。

依据主控 `source/m007_single_resource_qkv_attention_wo_20261021.md` 和当前 HEAD16-06。本文件只定位现有接线及后继约束，不修改生产 RTL、公开协议、预算或冻结证据。机器映射及源 SHA 见 [接口映射](m011_layer_pure_engine_interface_map.json)。

当前 `laya_attention_layer_v1` 内有纯 head、纯 RoPE、Check 控制，以及一份 `laya_attention_resources_v1` 和一份独立 coefficient cache。最小抽取保留描述符、覆盖、调度、context 公开读/消费控制、纯 head/RoPE/Check；把资源壳与 cache 实例迁入现接口的兼容壳或后继生产父级。兼容壳继续只例化一份各资源。未来父级直接连接纯 matrix 与纯 layer，不能同时保留两个含资源的旧壳。

| 现有资源束 | 非时钟信号数 | 纯 layer 边界 |
| --- | ---: | --- |
| QKV narrow/read | 18 | 保留矩阵输出经公开 QKV32 校验后到唯一银行 |
| PS/G/context storage | 74 | 保留全部 bind/op 身份、真实写回/读响应与 idle |
| shared FP256 | 45 | 原 phase2/3/4/7 lease、真实返回信用与 pending |
| LN-exp | 36 | 原 phase3 绑定与真实响应 |
| EXP SFU | 30 | 当前 Attention EXP 接口；TANH 统一化另按其后继合同 |
| DIV8 | 31 | 原 phase3 请求；父 quant 使用同一服务的 phase5 |
| 原 score scale4 | 10 | 保持原职责，不算另一套 FP256 |
| atomic Q64+K64 RoPE alias | 18 | owner/request/gen/epoch、整笔 ready/commit 和拒绝保持 |

以上262个现有资源端口在纯 engine 上逐一反转方向，不改宽度。cache 单列：原 bind/write 装载口留父级/兼容壳；纯 engine 需要25个现有状态、owner、读/响应信号。完整128-bit model/numeric/key及当前 owner 身份保持，131072B cache 和512B同步读数据寄存器仍只一份，其控制位仍计入联合4KiB。

当前 layer 公开 prepare 只锁描述符、清覆盖并进入 `L_PREP`。`h_prepare_valid` 只在一次 layer start/RoPE 后的 `L_HPREP` 才发给 head；因此 `L_PREP` 不发FP lease、不 bind PS/LN，也不租 DIV/SFU。QKV公开写 ready 只依真实 PREP/身份/银行 ready。准入 `prepare_ready` 仍要求 `real_idle && h_prepare_ready`，后者经 qkav 检查 storage bind ready 与 FP lease ready。现有接口应先真实 prepare layer，再让 matrix 占FP/PS phase1并流出12288笔公开QKV32写。主控已固定后继采用上述先prepare、后matrix的合法顺序，保留真实idle准入依赖，不新增放宽；不能把 shared ready 绑真或伪造 phase。

路由按资源束独立：matrix phase1 占FP/PS时，QKV写仍经纯 layer 的完整身份、finite Check、覆盖及唯一银行真实写握手。不能用一个全资源 owner mux 屏蔽该 PREP 写路，也不能从 matrix 直接绕过层覆盖写银行。QKV fullN 成功、所有输出写提交以及 matrix 实际 FP/PS/返回债释放后，父只启动一次 layer；现有 start_ready 的输入覆盖条件不代替父级资源交接判断。

context 供应顺序为 query→head→half；quant row=query，group=2*head+half。层覆盖位仍按 head*256+query*2+half，与读请求先后无关；opaque32 tag 可编码父级坐标，不能把返回 tag 当作独立完整身份验证。父完整 request/gen/epoch 租约始终锁存，读响应真实握手才交消费者。`result_rsp_ready` 对接实际 quant ready，阻塞时只保留有界32F32响应，不新增512KiB副本。storage context 仍在真实 phase4，quant调用唯一 DIV8 phase5；这两个不同资源束可并行，不能重bind在途context storage到phase5。全部4096响应、quant→A真实ack/发布和DIV释放后才切WO FP/PS phase1。

producer_done、公开DONE消费、context_release是不同事件。现有 `real_idle` 可在DONE/RELEASE且仍有未读context时为真；不能单独作为层输出所有权已退出的判据。正常父级须观察完整消费后回到IDLE（当前持合法描述符时 prepare_ready）并核真实资源/响应均清。纯接口可后继明确导出同一组合 `state==L_IDLE && real_idle`，此处未新增端口。cache owner 当前在L_IDLE/L_PREP以外持续有效，移父后不能只按RoPE算术结束提前允许换表。

正常成功消费保持context_discarded=0。显式同gen discard只服务正常结果取消，当前 discard_ready 要求done_status=0；numeric/abort 已自动标坏context，父应消费错误DONE并等真实退出，不能等待不存在的正常discard握手。已接受的held读/响应始终必须真实排尽。

联合控制最新完整账为layer3754B + matrix facade/engine/pure front1475B =5229B；1475B已经含256B量化坐标，不能再加或仅记坐标下限。单做QKV/context物理覆盖复用减4096bit并加1bit QKV完整标志，仍为4717.125B，向上取整4718B，未计父新增且超过4KiB。当前 `h_resident_valid` 与 `r_qkv_complete` 依赖全覆盖归约，必须在合法完整start后改用真实锁存完整标志；同一coverage低4096位显式清零后供context真实响应去重。reset/abort/newgen/重复读/末held均须回归。所有节省在实际声明和受影响验证前不计入当前3754B。原softmax3865B、sharedFP tag6144B及既有payload分账不变。

后继抽取验证应先绑定前后源码与唯一实例，复用独立原数值gold，回归生产公开prepare/QKV32/RoPE/完整head和context响应语义。真正QKV→Attention→quant/A→WO同runtime、联合资源及时序、完整父级错误/取消和全30层仍需另行有界合同。本映射不启动这些新运行。

父级待定取消缺口：当前 `abort_ready` 仅L_RSTART..L_WAIT，不包含L_PREP；正常result_discard也不接受PREP。先layer.prepare后，若上游quant/QKV矩阵失败、覆盖未完整，层无法用现有公开协议无reset退还PREP描述符。后继需主控明确绑定generation的PREP取消入口和真实窄写/上游输出排债，不能补假数据、伪造DONE或用共同reset当正常取消。本阶段只登记缺口，不改现RTL。

主控已定义上述缺口的后继协议（当前未实现）：新增带request64/gen32/epoch32的prepare_cancel valid/ready和独立保持型cancel_rsp，复用已锁完整身份字段。仅匹配L_PREP接受，优先于同沿start与新QKV写；此前已接受窄写必须真实提交后才清覆盖。取消不伪造正常DONE/Check完成，回执保持至消费后回IDLE，不reset/rebind其它owner的FP/PS/DIV。父先实际停发并排尽上游quant/matrix及已接受输出，保留其原始首错后再取消。错身份、计算中、DONE/RELEASE不准入此口，分别继续用原abort/discard。后继局部测试覆盖零写、部分写、末写同沿、held回执、错身份及无reset新gen真实重装；此处不改AT024/029源码或新增运行预算。


主控2026-10-21批准的R004具体容量/故障切口（当前未实现）：

- Check2464个entry用NONE00/COMPLETED01/UNREACHABLE10/DOMINATED11的2bit类别，合法域三张解码输出逐位等同原图；同类重复幂等。不同旧/新类别或同沿多类为真实协议冲突，首次捕获kind/index/old_class/new_set_mask，保守32bit，sticky coverage_fault只由真实clear/reset清。净候选节省2464-32=2432bit=304B。fault后图没有验收覆盖语义，不保留旧非法union合同，必须禁止success；真实active引擎abort/排债，资源与读返回全清后允许protocol DONE消费，修复原L_WAIT被check_ready永久压低的等待。
- resident-only生产head→qkav结构配置禁旧外QKV/prob装载；默认compat配置保留原768+2048bit数组。真实matching resident握手锁1bit，prepare/reset清，start核该真实标志与当前request/gen/epoch/head，continueAV仍沿原真实softmax/债条件。层本身完整12288窄写/finite/身份覆盖和softmax真实写prob均保留，不把满覆盖绑常量。候选净移除2815bit=351.875B；当前未实施不扣。
- A010另负责关闭生产profiling512B；不得跨owner修改。上述四项全实际实现时，5229-512+0.125-512-304-351.875=3549.25B，保守向上取整3550B，父新增前余546B。它是待实现预算，非联合fit/物理通过。
