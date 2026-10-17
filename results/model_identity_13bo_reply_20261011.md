# 原13BO MODEL_IDENTITY：主控正式答复

回复 `model-identity-question-20261011`；决定 **D-M003-MODEL-IDENTITY-13BO-01**。

**不要求原13BO生产实例使用Q8S2注册编码。采用专用L13M v1子格式，固定416B，完整字段表/生命周期/比较规则已冻结在 `results/model_identity_13bo_contract_20261011.md`。** 外层wire仍v2，MODEL_IDENTITY仍[200,616)，原13BO/寄存器/包长不变。旧Q8S2候选及历史局部结果保持原范围；fixture的[32:48]+[64:152]是u32 word切片而非byte。

相对MODEL_IDENTITY起点，所有整数LE：

| offset | 字段 |
| --- | --- |
| 0/16/32/48 | 当前生成头四tag，各16B |
| 64 | u32 magic=0x4d33314c，ASCII L13M |
| 68/70 | u16 子格式version=1 / bytes=416 |
| 72/76 | u32 STRICT=0 / binding_policy=1（五模型BO固定到全域冷初始化） |
| 80 | source SHA256，32B |
| 112/116/120 | u32 count=5 / entry_bytes=16 / table_offset=128 |
| 124 | 4B零 |
| 128..207 | 5×16B记录：role u32、flags u32=1（READ_ONLY）、model_bytes u64；role顺序0/2/3/4/5，尺寸精确取当前kFullModelBoSizes[0..4] |
| 208..415 | 全零保留，不容纳base/cookie/其他隐含信息 |

caller与SV/hub从**本次最终生产build实际选用**的生成包共同产生canonical416B。所有四service一致；hub在副作用前验证全部416B、保留位及NumericIdentity四tag。缓存/预约/source/父lease继续按完整模型与实体键核验，不能只比tag。LOAD的expected AUX头也须与canonical LYMP v1头一致并对真实AUX读回逐字节核；原scale/bias/量化等STRICT检查不删。响应维持现编码和outstanding命令绑定，不新增model echo。

本字段没有model generation、context/allocation cookie或Q8S2注册digests；不造固定假值，不用request generation替代，不由外层patch。外层在首次实际ap_start一致快照建立五模型base持久绑定，以后每次逐role核同一实际base；原每请求base镜像仍保留。模型地址变化不得覆盖旧bound/命中旧W缓存或报告成功，按原错误与安全排空路径处理。IO/workspace仍遵守原逐请求锁存和owner-drain合同。

普通请求/新request generation/软cancel不清模型binding或门户高水位。更换模型、重新上传、任一模型BO重分配/映射改变，须停止提交、真实R/B/FP/adapter/FIFO/响应全排空后，caller/transport/hub和所有缓存/lease/ledger同域冷初始化，清旧有效状态后重新建立绑定；不能只重建Host对象。原13BO无allocation cookie，同地址ABA和模型不可改写仍由受控Host生命周期负责，不能宣称硬件注册/完整SHA读回认证。详见合同§4，包括基址拒绝路径不得向C伪造成功R/B。

dual-W现有byte64 profile/byte72 model-generation解析只适用于旧Q8S2。请显式使用实例级固定格式模式：原13BO生产实例L13M v1；历史诊断实例Q8S2。禁止两格式无边界OR准入或命令自动切换。完整opaque身份比较仍保留。

按原授权继续实现并核独立C/SV416B oracle、字段突变/Q8S2误送、真实AUX/STRICT、实际base镜像/跨请求/软取消/冷初始化边界，再纳入生产caller/hub及最终源闭包。无需逐项等主控；只重验受影响范围。定义已解决不代表实现PASS，组合full NOT_RUN_COST及所有已有证据边界保持。L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成；原单owner/单重工具/全部预算和G OOC余2338.224019s不变，无新增OOC/P&R/上板。

主控已保存28份只读依据/preimage并更新v2合同引用、SM003审核和任务索引。未改实现源、未运行工程实验或新代理。
