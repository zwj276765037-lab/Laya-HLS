# 原13BO生产门户的 MODEL_IDENTITY 编码问题

关联：M003/SM003/E003/R003，D-M003-QUANT-G-V2 与 §3.9 生产 caller/hub 接入。工程会继续不依赖本决定的 beat transport、response 绑定核验和显式身份参数化 builder；本问题只阻塞最终生产命令中 416B `MODEL_IDENTITY` 的取值与供给路径。

## 已核事实

1. v2 私有门户固定 `MODEL_IDENTITY=[200,616)`，共 416B/3328bit；LOAD/QUANT/MATRIX/GEGLU 共用同一 `Command::model_identity`。
2. 现 dual-W 服务对该字段采用 Q8S2 模型会话身份：descriptor words 64..151 加四个 128-bit tag。fixture 实际由 register bytes `[32,48)` 与 `[64,152)` 拼出该身份。
3. Q8S2 words 64..151 含 profile、model generation、context cookie、validation/manifest/build/source digests，以及五个模型 BO 的 role/base/size/allocation cookie。
4. 原13BO生产 top 没有 Q8S2 `REGISTER_MODEL` 生命周期；generated C caller 也不能按 §3.9 把 C 指针强制转换为物理地址。外层 RTL 才会锁存实际13BO基址并按 role+offset/span 发物理访问。
5. 当前 generated model header只提供四个 tag、source SHA 和 BO size，不能自行构造完整 Q8S2 session identity。

## 请主控核定

原13BO生产门户的 3328-bit `MODEL_IDENTITY` 是否仍必须逐字节采用 Q8S2 `register[32:48] + register[64:152]` 编码？

- 若是：model generation、context cookie、validation/manifest/build/source digests及各 BO allocation cookie 由谁生成和持久保存？其中 BO base 是命令中写零、由外层按已锁存基址 patch，还是由 Host 通过现有寄存器镜像提供？
- 若不是：请给出原13BO生产门户专用的固定416B编码表、生命周期以及 caller/hub 两侧的比较规则。

这里不能由工程自行选择固定编译期身份、request session generation、外层 patch 或新模型session记录之一，否则会实质改变模型绑定和防重放合同。请只定义该字段；原13BO ABI、wire v2包长、数值/shape/预算均不变，也不请求新增实验成本。
