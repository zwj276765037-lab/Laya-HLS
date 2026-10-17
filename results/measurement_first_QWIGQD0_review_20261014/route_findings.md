# AT034共享入口静态反例，供工程定位

承接measurement-first-QWIGQD0-LN-source-query-20261014，A001仍在集中审核，LN源只读定位可以继续；暂不启动新LN实现/工具。

AT034冻结geglu_gate_quant_bridge_v1在IDLE、ext_quant_active=0、两个cmd valid都为1且其余条件就绪时：ext_quant_ready含!cfg_valid，cfg_ready又含!ext_quant_valid，两边都为0。若两源遵守valid保持到接受协议，就不能产生第一次接受。这是直接静态反例，不是AT034正常full观测到的死锁；正常PASS不撤回，但不能签一般共享入口活性。

A001将把紧邻下一任务限定为两入口显式优先级/响应隔离定向修复，具体合同随后发出，先不自行扩大到通用调度或错误恢复。准备方向：选择G入口优先，且quant路由与同一选择一致；已接受external请求仍持有所有权到原响应消费/拒绝及债务边界。只修共享包装，不改quant算术/缓存/容量。

另一个身份口径：AT034 TB source_producer_context[39:32]=0x60、source_quant_context=0x61，而include/laya_tasks.h的LN_FFN=0x12、QUANT=0x20；0x60/61是GEGLU/RELU。现有有限quant路径将这些字段作不透明键传递，没有验证为真实producer/op。当前只能签局部键绑定及数值，不能称生产LN_FFN P/Q身份正确。请并入下一有限接点表核对，若另有编码schema请给真源；不为此恢复M003。下一版本应使用原任务schema一致的P/Q/后续GATE-Q字段，并保留旧样本原值。
