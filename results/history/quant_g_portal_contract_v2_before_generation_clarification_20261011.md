# M003/L1 quant/G 门户补充合同：显式身份预约与父任务退休

日期：2026-10-11；决定 ID：D-M003-QUANT-G-V2；回复 `quant-g-question-20261011`。

主控技术决定：**按本补充实施**。适用于 A002、E003/R003 的 L1、相依 L2/L3 及 M004 的生产集成前置。本文冻结接口和生命周期，不是实现、仿真或阶段验收 PASS。工程是实现/RTL/TB 的唯一写入人；主控本轮只写合同与审核记录。问题来源见 [工程问题](../project/E003_production_chain_closure/experiment_results/runs/R003/interface_question_to_controller.md)。

本文在下列范围补充联合 design §3.8/§3.9/§7.3.3：私有门户 v2、未来任务预约、GEGLU 与 quant 分期、父 rows16 的租约。原数值/错误优先级、模型/shape、13BO/AXI-Lite、FIFO 深度、单持久服务、原始证据与工具预算不变。历史 v1 源和结果按原身份保留，不重标为 v2 PASS。

## 1. 集中决定

1. 采用**显式私有 wire v2**，保留 command 1024B / response 512B、原字段偏移；新增三个 12B Context 和一个 8B future-dst Ref。响应另回显 service 和 row view，防止同父任务不同 view 的响应错配。
2. **generated dispatcher 是 typed task/ref 的唯一预约分配者**。在 GEGLU 首个 producer 执行前，构造并保存该阶段全部 GEGLU、Down LOAD、Quant、Linear 的完整 typed task；不得推算 `task_id+1`、用函数调用次序补身份，或用 C READY 代替物理生产。预约不推进实际退休，也不占物理 A/W 数据槽。
3. **保持原逻辑顺序：全部 GEGLU → Down LOAD → 每窗口 QUANT、LINEAR。** 生产接入将 G 生产与量化分期；GEGLU 命令不自动执行未来 QUANT。复用同一 G/quant/fullA 物理资源，避免两 A 槽被提前填满后等待尚未到达的 Down。
4. **一个 rows16 LinearTask、一次完整 A 生产、多个 rows4 view、一次父 TaskDone。** A 的物理租约跨 view 保持；每个 view 有独立局部 PS/输出债务与响应，父任务归并完整覆盖、数值首错和末 B。
5. **GATE 是完整 tensor owner；三个 G bank 只是一个 row 工作集。** 一个 tensor 的所有 GEGLU 窗口共用原 GATE Ref/epoch；窗口身份、覆盖、防重放与消费者绑定须有独立有界账本。

## 2. 私有 wire v2

### 2.1 固定布局

所有偏移为 byte，little endian；不序列化 C++ 内存布局或指针。`VERSION=2`。原 magic 保持为协议族标识，版本只由 VERSION 判定；command/response 的原字段偏移和 beat 数不移动。

| command 字段 | offset | bytes | 定义 |
| --- | ---: | ---: | --- |
| PRODUCER_CONTEXT | 928 | 12 | 本链真实 producer 的完整 TaskContext，见操作表 |
| QUANT_CONTEXT | 940 | 12 | 当前或已预约的完整 QuantTask.ctx |
| LINEAR_CONTEXT | 952 | 12 | 已预约的完整父 LinearTask.ctx，绝非 rows4 改写版 |
| FUTURE_DST_REF | 964 | 8 | 父 LinearTask.dst，含独立 region byte |
| COMMAND_USED | 972 | — | `[972,1024)` 全零，仍余 52B |

Ref 编码沿原规则：epoch u32、id u8、bank u8、region u8、最后一 byte 零。新增 future-dst 的 region 必须与 LinearTask.dst_region 相同，不可只比 id/epoch。Context 的 task_id/op/stage/layer/batch/row_space/row0/rows 全部比较。

| response 字段 | offset | bytes | 定义 |
| --- | ---: | ---: | --- |
| RESPONSE_PRODUCER_CONTEXT | 272 | 12 | 原样回显已接收 command 的 producer Context |
| RESPONSE_QUANT_CONTEXT | 284 | 12 | 原样回显 quant Context |
| RESPONSE_LINEAR_CONTEXT | 296 | 12 | 原样回显父 linear Context |
| RESPONSE_FUTURE_DST_REF | 308 | 8 | 原样回显 future-dst，含 region |
| RESPONSE_ROWS | 316 | 1 | 原样回显 command ROWS |
| RESPONSE_ROW_BLOCK | 317 | 1 | 原样回显 command ROW_BLOCK |
| RESPONSE_SERVICE | 318 | 2 | 原样回显 command service；OP_STATUS 仍是响应 Status |
| RESPONSE_USED | 320 | — | `[320,512)` 全零 |

`TASK/CONTEXT` 始终是**当前执行的 typed task**。MATRIX 每个 view 共用父 task_id/CONTEXT，响应的 `(ROWS,ROW_BLOCK,SERVICE)` 区分 view。不能以 response 到达先后代替该检查。

v2 encoder、decoder、SV layout、bindings、生成 caller 同步迁移；生产 runtime 不混用 v1/v2。同一 C/SV 字段定义须逐位核对。旧 v1 的 96B 保留区仍要求零，不能给 VERSION=1 的包偷偷填写扩展。未知/不匹配版本、保留位或 Ref padding、范围、身份错误，在任何新 RAM/FP/AXI 副作用前拒绝；完整包接收与拒绝 drain 沿原合同。v1 结果只作为受影响前基线。

响应正常和失败均回显全部绑定字段及原 NumericIdentity、portal generation、五 Ref、A/W epoch。caller 按本次 outstanding command 逐字段比较；失败保持 output_elements=0、unit=NONE、published=false，drained 仅在实际债务清零后为真。拒绝包不能触发有效 owner/预约；对损坏包的原样回显仅为诊断，caller 不把它提升为合法绑定。

### 2.2 每种操作的唯一映射

下表的 P/Q/L 是完整 Context；`0` 指全零 wire encoding（不能直接使用带默认 op/layer 的 C++ TaskContext 默认值）。None Ref 为全零。所有 Ref 比较含 region。

| service | CONTEXT | P / Q / L | SOURCE_REF | A_REF / W_REF / PS_REF | DST_REF | FUTURE_DST_REF |
| --- | --- | --- | --- | --- | --- | --- |
| LOAD_W=1 | 实际 LoadTask.ctx | 0 / 0 / 0 | None | None / LoadTask.dst / None | None | None |
| QUANT=2 | QuantTask.ctx | source 生产凭据 / QuantTask.ctx / 已预约 LinearTask.ctx | QuantTask.src | QuantTask.a_dst / LinearTask.w / LinearTask.ps | QuantTask.a_dst，region=0 | LinearTask.dst / dst_region |
| MATRIX=3 | 父 LinearTask.ctx | 与该 A 生产时同一 P / Q / L | 对应 QuantTask.src | LinearTask.a / w / ps | LinearTask.dst / dst_region | 与 DST_REF 完全相同 |
| GEGLU=4 | VectorTask.ctx，op=GEGLU | VectorTask.ctx / 已预约 Down QuantTask.ctx / 已预约 LIN_DOWN.ctx | VectorTask.src0，即 WI | 下游 QuantTask.a_dst / LIN_DOWN.w / LIN_DOWN.ps | VectorTask.dst，即 GATE | LIN_DOWN.dst / dst_region |

说明与校验：

- LOAD 延续 W_REF 承载权重缓存目标的含义；其余 Ref 与扩展置零，不能借 DST_REF 或 PS_REF 传隐式身份。LOAD 的 CONTEXT.op=LOAD_W，K/N/key/bias/model/weight ranges/AUX fields 取实际 descriptor；ROWS/ROW_BLOCK=0。无需绑定某一个未来 LinearTask，因为一个 LOAD 可被多个父任务消费。
- QUANT 的 CONTEXT=Q；MATRIX 的 CONTEXT=L；GEGLU 的 CONTEXT=P；这些重复字段必须显式填充并校验相等。GEGLU 的 Q.op=QUANT、L.op=LIN_DOWN，三 Context 的 stage/layer/batch/row_space/row0/rows 相同，但 task_id 不同；其先后来自真实计划表。通用 QUANT 的 Q/L 窗口必须相同，P 必须来自有效 source provenance。
- G→quant 路径：GEGLU 的 DST_REF 正是 QUANT 的 SOURCE_REF；GEGLU 的 SOURCE_REF 是 WI，二者不可混用。GEGLU 与 QUANT/MATRIX 携带的 Q/L、A/W/PS/future-dst 必须与同一计划记录逐项相等。PS_REF 在 GEGLU/QUANT 中只是**已预约的 future PS**，不得据此提前 claim PS。
- 通用 QUANT/MATRIX 的 P 是该 source 窗口的真实生产凭据，不能统一写成 GEGLU、QUANT 或当前 Context。GATE 窗口的 P 就是对应的已完成 GEGLU Context。其他来源由实际生产路径记录；复合 producer 的 source 必须保留其完整覆盖证明，并以真实完成该窗口覆盖的 typed producer 为锚，不能用一个锚 Context 冒充所有子生产均成功。该凭据必须在 source producer 实际完成时记录，不能在 quant 发送时猜造。
- QUANT 和 GEGLU：ROWS=当前 parent rows（1..16），ROW_BLOCK=0。MATRIX：ROWS 为 view 的 1 或 4，ROW_BLOCK 为父窗口内偏移；CONTEXT/L.rows 仍是父 rows。LOAD 不使用 row view。
- MATRIX 的 K/N/key/bias/model/output 布局保持既有含义。QUANT 的 K/N/key/bias/model 描述已预约 L，其中 K 是实际量化宽度。GEGLU 的 K=2624、N=1024 描述 Down；WI 每行 2*K 个 F32，GATE 每行 K 个 F32，不将 N 当 G 输出宽度。
- SOURCE_ROLE/SOURCE_OFFSET/SPAN/STRIDE 在 QUANT 表示实际 F32 source，在 GEGLU 表示实际 WI source；必须由原内存映射导出合法 BO/region/stride。GEGLU 的 OUTPUT_RANGES/ROW_STRIDE/BATCH_STRIDE 表示实际 GATE 输出；MATRIX 表示当前 matrix 输出，含原 QKV 两路规则。QUANT 的 A 在片内，OUTPUT_RANGES/输出 role 置零；其 ROW_STRIDE 明确定义为 source row stride，等于 SOURCE_STRIDE=K*4，BATCH_STRIDE 为该 source 的原固定布局 batch stride（TOKEN=1024*K*4、MARKER=16*K*4、BATCH=K*4），不能用运行时 S 缩小。GEGLU 的 WI source row stride=2*K*4、source batch stride=1024*SOURCE_STRIDE，GATE 输出 row/batch stride 则为 K*4 / 1024*K*4。LOAD 的 source/output 字段置零。MATRIX 不重读 F32 source，source 地址字段置零，但 SOURCE_REF 仍参与 A provenance 匹配。非 LOAD 的 weight/AUX 地址字段置零；W 模型身份/key/bias 仍是绑定信息。未使用字段必须零，不允许一字段多义暗载未来 BO 地址。
- GEGLU 包中的未来 A/W slot/epoch 只验证**预约关联**，不要求未来 W 已 READY，也不 acquire A/W。QUANT 只在真正执行时激活自己的 A，MATRIX 则必须检查实际 READY/lease 与完全相同的 L/W/dst 绑定。

### 2.3 容量与原命名空间

cmd/rsp FIFO 各 depth2，各一个完整装配槽，一次最多一个活动命令；整个响应被 caller 消费后才能复用门户槽。基础显式 payload 仍为 1792B，扩展利用原包内保留空间，**不意味着新预约/覆盖/租约 metadata 免费**；新增表、序列化副本和寄存器须单独报告 bytes/bits 及实际资源。

M003 首次接入保留现行 v1 的 A/W Ref bank=物理 slot、Ref epoch=slot epoch 的绑定规则，不悄悄改变 typed Buffer 命名空间。当前生产 typed A8/WEIGHT 使用 bank0，故可顺序使用 slot0；双 A/双 W 的既有总容量不增加，未使用的 slot1 不算重叠性能通过。不得为了“使用两槽”将原 bank0 task 静默改成 bank1，或让 wrapper 把逻辑 Ref 替换成另一物理 Ref。将来若使用独立逻辑/物理映射，另立显式合同和受影响验证；这不阻塞本轮串行完整接入。

## 3. dispatcher 预约与实际执行分离

### 3.1 唯一计划与有限上界

新增一份有界的阶段计划，索引为实际 `(batch,row0,rows)`，每窗口保存**完整** typed producer/QuantTask/LinearTask 及相关 Ref/region、K/N/weight/bias、A/W slot/epoch ticket。共享字段允许存一次后引用，但不能只保存 Context 然后在下游重新 `fresh()` 其余字段。

在当前 B≤2、S≤1024、rows16 分窗下，GEGLU→Down 至多 `2*ceil(1024/16)=128` 个窗口。计划容量固定 128 项，加一份 Down LoadTask/descriptor 及阶段 header；至多 128 个 G、1 个 LOAD、128 个 Q、128 个 L，共 385 个 typed task 的有界表示。表中不存命令/响应包或 tensor 数据，不增加活动命令数。超界先拒绝，不动态扩队列。一般 linear 路径也必须先构造每对 Q/L，再 issue Q；不需要把整请求所有层展开常驻。

WI 完成后、第一条 GEGLU 之前，dispatcher 按原顺序预约：所有 G 窗口（batch 外层、row 内层）→Down LOAD→各窗口 Q/L。GATE/Down 输出 owner spec 与 downstream A/W/PS Ref 都在此处确定。未来 owner 仅预约 ticket，原 full_claim/full_publish 在原先执行位置激活，不提前占用可能仍活跃的 TMP/PS/W 数据资源。先前 WI 的真实 producer 凭据仍由其自己的完成记录提供。

当前任务分配器 `context()` 的 `last_task_id+1` 和 `fresh()` 的 `max_claimed_epoch+1` 都只是观察，不是预约操作。新增 **reserve cursor / per-resource reservation high-water**；每次返回 ticket 必须原子推进预约状态。`rt.last_task_id`、`max_claimed_epoch` 和物理 slot epoch 仍只由相应真实 issue/claim/retire 路径推进。所有分配入口统一遵循预约器，不能旧 `fresh()` 与新预约器各发同一个 Ref。

task ID 的分配可以在 allocator 内按原单调规则递增，但 bridge/codec/caller 只能查已保存的 task，不得根据 producer ID 推算 Q/L。预约器不能伪调用 finish，不能提前增加 tasks_retired/op_calls，不能把未执行 task 回填成成功。

### 3.2 来源凭据与激活

source provenance 按完整 NumericIdentity、Ref/region 和窗口查找，并来自真实成功 producer。GATE 每窗口的 P/Q/L/future Ref 绑定保存到后续 QUANT 执行，不能只记“最后一个 G Context”。可以与 128 项阶段计划共存/复用，但逻辑上必须区分 RESERVED、PRODUCED、QUANT_DONE、LINEAR_DONE、CANCELED；至少有 producer 成功覆盖、consumer 使用、防重放状态。完成、取消和地址越界均不能越过这份账本。

FullRuntime 仍是原 typed namespace/计划的权威；物理 hub 根据接收的显式身份及真实 producer/AXI 事件维护 slot、覆盖、lease。不得把 C 的 `owner_admitted/source_published` 布尔值直连为物理成功。物理 ledger 不需要常驻 385 个包，也不另设一份数据缓存；必要的 G 窗口绑定表有界为 128 项。

未来 A slot epoch 可连续预约多次，但只有轮到对应 Q、slot 实际 EMPTY/INVALID 且上次使用已安全结束时才激活；actual next epoch 校验不能删除。未来 W 只能由那条真实 LOAD 生产。若任一早期任务失败，停止逻辑下游生产，撤销未执行 ticket，实际已接受的读写/算术仍排空。保留原“实际下一个 task_id 才能执行/退休”的约束，不因保留了后续 ID 允许乱序 issue。

预分配时只做结构/容量/溢出检查；实际下游 descriptor/数值/内存错误仍在原逻辑执行位置报告。不能因提早预约 Down 而提前读其权重、报出其数值错误，覆盖本应先发生的 G 错误。预约表容量按上述合法最大 shape 覆盖，不可把规划器成本当运行期新数值优先级。

### 3.3 失败、下一请求与 epoch

ticket 的有效键含完整 NumericIdentity（含 request_id）和 portal generation，不能只用 task_id 或 slot epoch。请求失败后，不跳过未发出的任务继续同一请求；完成旧命令/response 和全部不能取消的 R/B/FP drain 后，撤销该请求所有未激活预约和 producer bindings。

沿用原持久会话规则：下一合法 request 可以在同一 session generation 下、以更大 request_id 进入；其 task ID 按原请求初始化规则重置。**不新增“必须换 generation 才能恢复”要求**。未激活 ticket 只是已撤销的计划，可在旧请求完全失效后从实际 committed high-water 重建新请求预约；已真实 claim 的 Ref/slot epoch 高水位不能回退。旧请求的三 Context/Ref 即使数值与新 ticket 相似，也因完整身份不同而拒绝。溢出不回绕，沿原错误/重置规则处理。

## 4. G 的生产与消费

### 4.1 分期执行

生产版本从现 `geglu_gate_quant_bridge_v1` 的自动 PRODUCE→QUANT 链拆出显式命令边界：

1. GEGLU 命令实际读 WI、执行原算术、逐 row 写 GATE；每 row 的真实源读/算术/输出债务清零后才能复用 bank。
2. 当前 GEGLU 窗口覆盖完成且真实末 B 退休后，只返回这个 VectorTask 的 response。保存 P/Q/L 与未来 Ref 绑定；此时不填 A、不 acquire A/W、不报告 QUANT 或 LinearTask 完成。
3. 全部 G 窗口成功且总覆盖/写债务闭合后，完整 GATE owner 才 READY。接下来真实 Down LOAD 执行，然后每个 QUANT 通过同一 hub 读 GATE、生产完整 A，最后 MATRIX 消费 A。

复用现 G 行算术、三个行 bank、GATE writer、quant、dual-A/dual-W；不得保留一套 fused bridge 同时再实例化第二套 quant/fullA。可以保留历史 fused v1 的独立 fixture，但生产层必须显式版本化分期控制并冻结新源码身份，不能声称原 bridge04 已证明该新路径。

### 4.2 全 tensor owner 与局部工作集

GATE 完整 owner 仍是 `full_claim_owner` 所定义的一个 Ref/epoch/region，覆盖 B×S×2624 F32；每个 rows16 producer 的 batch/row0/rows 只是覆盖子集。一个窗口成功不创建新 GATE epoch，也不发布整个 tensor。物理侧的总覆盖按 NumericIdentity/Ref/region 管理，可用固定最大 2048 row bits；窗口成功位仅在该窗口真实最后 B 和各 row debt=0 后置位。

旧 writer/bridge 的“每次 cfg 都要求 gate_epoch > last_gate_epoch”不能原样用于多个窗口共用 GATE 的生产模式。新生产版本按如下规则替换，**不能仅删掉 epoch 检查**：

- 新 tensor：只能在旧 tensor 不活跃、无 read/write debt 后，接受与权威 owner 计划一致的下一合法 GATE epoch/identity，初始化该 tensor 的覆盖与窗口绑定。
- 同 tensor 后续窗口：NumericIdentity、GATE Ref/region、stage/layer/row_space 和下游计划一致；按原 batch/row 顺序接受下一个未覆盖窗口，记录其真实 P/Q/L 与未来 A/W/PS/dst。相同 epoch 因**同一 owner 的合法新窗口**获准，不是任意 epoch 放行。
- 重复/重叠窗口、乱序窗口、相同 P 被换 Q/L/dst、旧 request、错层/错行/错 epoch 均拒绝，无新 RAM/FP/AXI 副作用。
- GATE 窗口源消费 lease 绑定实际 Q 及其已记录 P/L/Ref；仅在全 tensor READY 后取得。量化真实 R/算术债务清零后释放该窗口 read lease，其他窗口的未消费数据与绑定仍有效。最后一个窗口完成也不伪称 LINEAR 已运行。
- tensor release 仍由实际 controller 在所有 Down 窗口使用完成后执行；回收需 reader/AXI 债务全零。失败取消全部依赖 binding，旧 R/B 不得覆盖新 owner。

三个 bank 仍各 2624×32bit、一个 row 工作集，总 payload 31488B；不缓存完整 B×S tensor。GATE 数据写入既有 FF BO，后续 quant 从该 BO 真实读取。bank 的 row generation/覆盖、父窗口进度、完整 tensor owner 三者独立；银行复用不增加 tensor epoch，也不能丢失前面窗口的 provenance。

## 5. rows16 父任务与 TM4 view

### 5.1 身份与 A 租约

QUANT 一次生产父窗口全部 rows（通常 16）的 A；绑定完整 L、source/A/W/future-dst、K 和 A epoch。成功只在该父窗口所有 row/group/half/scale 和真实读/算术债务闭合后发生。四个典型 MATRIX 命令为 `(ROW_BLOCK,ROWS)=(0,4),(4,4),(8,4),(12,4)`；尾部按合法 4-row 加 1-row view 覆盖，不填补不存在的 row。

所有 view 的 CONTEXT/L 完全相同（含原 row0/rows），P/Q、NumericIdentity、A/W/PS/dst Ref 也相同。实际 row=`L.row0+ROW_BLOCK+local_row`。内部算术/输出 adapter 若沿原协议使用派生 view Context，仅能从父 Context 和显式 view 得到；不分配新 typed task_id、不覆盖包内父 Context。每个 view 单独启动其完整 G×T loop，不能退回每 n0/group 一条命令。

持久 hub 增加**最多一个活动 linear 父描述符**及最多 16 个 row 的 coverage/first-error 状态：

- 第一个合法 view 才向 dual-A 取得完整 parent rows 的物理 lease，保存完整身份；后续 view 只取得该活动父 lease 下的局部使用权。
- `quant_dual_a_v1` 的 release 会清空整个 A slot，故不得把每个 matrix view 的结束直接接到该物理 release。新生产 parent lease 层在 view 间保持 IN_USE，确认上一个 view 实际读返回债务为零后才切换局部视图；只有父任务的最后必要 view/检查和真实读取结束后才 release 一次。
- 这份局部使用权必须由真实已持有 lease 支持并检查身份/覆盖，不是固定返回 acquire_done 或伪造 READY。需要生产 adapter/版本化控制改变时由工程在同一持久服务内实现，原局部 v1/v2 fixture 证据不代签它。
- W 可保守同样在父任务内 pin，最迟在最后真实 q/scale/bias 读返回后释放；不得在 view 间改绑、被 LOAD 覆盖。后一个父任务重新取得真实 W lease；已加载 W 数据可依原缓存策略保持 READY。
- 只允许同父的下一个合法 view；重复、跳过、重叠、换 L/Ref/epoch、另一个 Q/LOAD/G 在活动父任务中插入均拒绝或反压，不能丢掉已持有租约。一次活动 command 的规则仍成立。

### 5.2 PS、发布与首错

typed PS/dst 是父任务计划身份；物理 PS/view ledger 是局部工作集。上一 view 的 front/PS/meta/FP/final/bias/writer/R/B 债务全部清零之后，才初始化下一 view 的局部状态和 group/tile sequence。完整 tag 按既有协议携带 row view 与 generation，不扩大 PS 数据容量。

每个 view response 的 `published` 只表示**该 command 范围的实际成功覆盖**，不能据此发布整个父 task 或完整 tensor。GEGLU response 同理只表示该 producer 窗口；QUANT 则表示其完整父 A 已产生；LOAD 表示实际 W slot 成功。caller 必须同时核 service、extent、状态、元素数和 unit。最终 typed TaskDone 只在所有 view 成功、父 coverage 完整、末 B/全部债务清零、父租约已释放后一次返回；tasks_retired/op_calls 对父 LinearTask 只增加一次。整个 tensor 的 full_publish 还要等待所有 rows16 父任务，沿原流程执行。

数值首错仍依联合 design §3.8 的原排序，不按 view 完成顺序选错。`G=K/32`，采用 u64：

```
parent_row = ROW_BLOCK + local_row
rank = (((tile * 16 + parent_row) * 8 + lane) * (G + 1) + group) * 5 + phase
```

`group=G` 保留原 bias/final 位置，phase/bad_element 编码不变。第一个 view 数值失败后，后面的 view 仍可能给出更小 tile 的优先错误，因此父层记 sticky failure 并继续必要数值检查、归并最小 rank；继续保留父 A/W 和失败父标记，不能因一个 view 的局部 owner 失败而丢 A 或把后续检查判为新任务。任何局部成功均不能清除父失败。所有必要检查和债务结束后使父目标 INVALID，返回唯一失败 TaskDone。

协议/AXI 错误按原错误优先级停止新工作并 drain；不为了数值归并继续发不安全事务。取消/active reset 必须排空已接受不能取消的 AXI、清理 parent pin/未发布覆盖和窗口绑定；payload 无需清零，旧 generation 的 R/B/FP/response 不得命中新 owner。请求错误后的恢复仍含同 generation 下一合法 request。

## 6. 工程可连续实施的顺序与验收出口

本决定解除**定义不明**的阻塞；quant/G 生产使能仍须由实际实现与受影响验证解锁。工程按既有授权连续实施，无新逐步用户审批：

1. 共用 v2 schema/codec/SV/响应绑定，更新 generated caller 的 task/ref allocator 和阶段计划；所有 loader/quant/matrix/G 走同一持久 hub。保留独立 BO/LOAD cancel/drain 工作成果。
2. 实现 G 分期、完整 GATE owner/窗口账本、parent A lease 和 view 汇总；不复制物理服务。冻结新增 metadata 的容量/字节数及所有行为变化。
3. 在原资源帽内完成受影响验证，再推进 M003 L2/L3、最终身份 L4/L5。若出现本文未覆盖的真实接口矛盾，带最小证据直接回复主控；独立已授权工作继续。

必要验收用例：

| 范围 | 必须证明 |
| --- | --- |
| wire | C/SV 逐位一致，所有操作 round-trip；v1/v2 混用、保留区、三个 Context、future-dst region、service/row view 错配均拒绝，副作用为零；cmd16/rsp8、FIFO depth2、13BO/控制寄存器不变 |
| 预约 | 合法最大 128 窗口 metadata 有界；G/Q/L/LOAD task ID 与 Ref 无重复；未来 ticket 不产生 READY、不占 A、不退休；输出/物理 epoch 按真实执行次序激活 |
| G 跨窗口 | 同一 GATE Ref/epoch 至少两个 rows16 窗口成功；第二个窗口不因旧“每 cfg 新 epoch”规则被误拒；重复/重叠/错未来 consumer 被拒，早窗口不发布整 tensor；真实末 B 反压下保持 |
| G 分期 | 多于两个 G 窗口在 Down 之前完成，不占满 A、不等待未来 Q；GEGLU 一条命令只返回其自身完成，真正 Q 到达后才量化，不能重复量化或提前记 op_calls |
| 父 view | 一个 rows16 Q 对应四个 rows4 matrix view；中间不释放 A、不重算 Q，完整 A/Ref 绑定不变；父末 B 被压住时不得提前 TaskDone；父任务仅退休一次 |
| 首错 | 较早 view 的较大 tile 错误与较晚 view 的较小 tile 错误并存时，按原 rank 选后者；bias/final/源/协议优先级和无成功发布保持 |
| 恢复 | 预约后 G/LOAD/Q/中间 view 错误或 active reset，旧 R/B/FP/response 不污染新 owner；同 generation 更大 request_id 恢复，以及新 generation 恢复；未激活 ticket 撤销，已 claim epoch 不回退 |
| 生产链 | 仍完成原四 distinct 真实 row 的同 runtime Wi Q8→G→quant→Down，真实 BO/末 B、4096 F32 独立 gold；新增多窗口/父视图用例不能由原四 row 局部 PASS 代签 |

合法最大 metadata/调度边界可用有界结构与控制用例证明，无须为此擅自跑超帽整图 RTL。M003 仍需当前完整 CPU/实际 CSim 和各原里程碑；局部通过不能关闭 M004。M004 持续目标是完整 Laya 加速器和尽量高性能，不设固定 20%/5%/50ms 门槛；本决定不宣称串行 slot0 已实现最终性能优化。

单重工具、CPU0–3/nice19/idle I/O、MemAvailable>192GiB、原 RTL/static/OOC 帽保持。M003 不因接口修订获得新增 OOC/P&R/上板授权；G 累计 OOC 余 2338.224019s 不重置。本轮主控未启动任何工程实验。

## 7. 决策依据与身份

以下路径以唯一实现根 `project/E002_Laya_HLS/experiment` 为基准；源码核查快照的 SHA256/行数见 [证据清单](quant_g_portal_contract_v2_evidence_20261011.json)。清单证明本次阅读身份，不是实现冻结或测试收据。工程随后变更由自己的新运行 manifest 标识。

- `include/laya_compute_portal.h:11` 与 `hls/platform/compute_portal_codec.cpp:49`：固定 v1 包、96B 保留区、逐字段响应绑定。
- `hls/control/full_forward_controller.cpp:27`、`:210`、`:644`：非预约 fresh/context、先 quant 再创建 linear、全部 G 后再 Down。
- `hls/operators/full_tasks.cpp:13`：实际下一个 task 的检查与退休；`hls/common/laya_full_io.cpp:70`、`:208`：请求级 task ID 和同 generation 的后继请求；`hls/common/laya_full_owner.cpp:131`：真实 claim epoch 规则。
- `include/laya_full_runtime.h:64`：owner/完整 tensor 覆盖；`include/laya_tasks.h:8`：完整 typed task 定义。
- `vivado/module_design/activation_quantizer/rtl/quant_task_to_dual_a_v1.sv:139`、`quant_dual_a_v1.sv:147`：完整 parent Context、fullA 和 acquire/read/release。
- `vivado/module_design/activation_quantizer/rtl/geglu_gate_quant_bridge_v1.sv:105`、`:146`：自动 G→Q 控制与三个 Context；`geglu_gate_writer_ledger_v1.sv:103`：单 cfg 递增 GATE epoch 和 consumer 绑定。
- `vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_matrix_portal_binding_v1.sv:221`、`tm4tn8_matrix_resident_v2.sv:193`、`:260`：父/视图以及现有每 view 释放 A；`laya_load_portal_binding_v1.sv:125`：LOAD 的 W 身份。
- `results/compute_throughput_optimization_20261010/source/design.md:295`、`:313`、`:945`：原父首错/物理退休、§3.9 固定门户、三个单 row bank。本文仅补充前述身份/生命周期缺口，其余规范保持。
