# 普通Q/L producer Context：主控正式答复

回复`ordinary-linear-provenance-question-20261012`。决定 **D-M003-ORDINARY-SOURCE-PROVENANCE-01**，全文 `results/ordinary_linear_provenance_contract_20261012.md`；v2权威合同已补引用并明确原§2.2。

**采用第3项的逐窗口形式：P是使这个source窗口全部必需输出覆盖首次完整的真实成功typed task原Context。P本身不代表整tensor发布。** 每窗口保留P、完整贡献覆盖/真实退休证明，另由原full_publish/commit检查全部batch/window后发布整个owner。不能用全tensor循环最后task代表所有窗口，也不新增publication typed op/TaskDone、producer集合wire或第五service；任务计数不因本决定增加。

具体规则：

- Attention：每batch/rows16窗口有独立16-head覆盖。使此窗口16head全部实际成功退休的AV Context成为P；当前顺序通常是head15，但必须核前15head实际覆盖，不能仅看head号。B1/S64应记录4个不同窗口的真实AV Context。全tensor未发布前，即使某窗口完整也不能Q；后窗口/其他batch失败使整个tensor不可消费。
- LN/残差/向量/非QKV Linear：取实际完整输出本窗口的typed任务；Linear等四view和唯一父TaskDone/末B，rows4 response不是父窗口P。P保留真实stage/layer/op；LN_EMB stage1→首个LIN_QKV stage2合法，不能硬要求普通P与Q同stage/layer。
- QKV：两条实际Ref/epoch、pair/plane/head覆盖和两路末B分别核验；同一LIN_QKV父Context可成为两侧同窗口的P，但owner键不同，全pair必须原子发布。RoPE新epoch保留旧V来源并核全部Q/K更新，由每shard/window实际覆盖闭合的RoPE记录新P；不能把旧P直接改epoch。普通QUANT仍不接受QKV为连续F32源，原shape白名单不变。
- 原地/SCORER：保留旧epoch已发布凭据及原合法独占读lease，为新epoch另记P。SCORER Q取旧LN_MARKER来源，Q完成A后才允许该窗口覆写；新epoch P来自真实LIN_SCORER_FC1父任务，再后BIAS_GELU有自己的P。失败不能把已覆写旧epoch回滚READY。
- Q成功后A冻结其消费的source/P证明；MATRIX各view核此冻结绑定。F32源已按原规则释放或原地更新时，不误要求旧源现在仍READY。相同只读源可有合法不同Q消费者，重复同一Q票据仍拒绝；GATE专用预约消费不变。
- 失败/取消先排空、撤销本请求证明和未来绑定；同session新request以完整NumericIdentity区分，门户高水位与L13M基址绑定保持。

内部记录字段及保守固定容量见合同§2：32 owner×128窗口，最多两owner保留旧epoch额外256，共4352条窗口证明上界；允许经活跃性证明压缩为更小固定pool和复用coverage。不是4352个包或新tensor缓存，实际metadata/资源另计。

物理边界仍严格：typed逻辑完成与真实输出覆盖/RRESP/BRESP/末B需共同成立，不能把C READY或`done.drained=true`直接接成物理source成功。本答复解决P选取；实际generated非门户producer的身份绑定到物理ledger仍属于§3.9工程闭合。若现生成端口无法承载必要绑定，请直接给出实际端口/连线缺口，不以假P或布尔echo上线，也不私加wire。可先独立实现并验证C来源账本/普通builder。

已核`portal_controller_04` receipt四项文件SHA与日志；该证据明确是C++ Controller配受控service回复的metadata/retirement验证，25命令/13 typed任务，无真实数值payload、hub或RTL声明，不能作为物理整链PASS。完整manifest闭包未在本次架构答复中验收。

继续原授权内受影响实现/测试，必要边界用例见合同§6；无需逐项等主控。L0/L1 PARTIAL、L2–L5 NOT_RUN，组合full NOT_RUN_COST及M003/M004未完成状态保持；原ABI/wire v2/模型/数值/预算、G余2338.224019s不变，无新OOC/P&R/上板。

已采用新的README/索引/讨论导航规范，权威正文更新后由统一工具刷新；本讨论状态登记为待实施，不因本答复关闭验证事项。
