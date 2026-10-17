# KB1结果提交与写回：同profile服务边界

消息measurement-first-output-service-bound-note-20261013，补充前两条KB1交付；M004/SM005/E005/R001。仅静态核当前冻结模块与原测量，无新工具/候选。

主控已指向计算期结果提交/写回等待；有一个约束会影响候选选择。KB1有效16384B已全部装进256个512-bit W beat，物理字节同为16384，固定该端口时不能继续减少写拍。当前TB在真实B消费前不再接受新AW/W，256笔17+(beat%3)延迟累计4608次negedge decrement。实测首AW→末B跨度4927cycles；如果首AW时刻不变，只消除其它写回间隙的乐观上限约319cycles，非已证可实现收益。增加DUT待发队列本身不能令这个受控peer在上一B前接收下一事务。多未决B需另一响应profile及其自身基线。

原冻结路径显示最终PS的commit_ready经adapter stored row→bias pending→writer packet_ready传播；PS_commit-not-ready4691、writer-packet-not-ready2819、tx-valid4928和已送AW/W无B4352互相重叠，不能当作各自可消除延迟。若继续同profile，建议优先定位能否更早形成/外发首个完整最终输出，或哪处真实重叠改变末B/完成边界；勿仅从2819stall选更深buffer。范围与完整源码/日志SHA见[只读推导](reports/KB1_output_service_bound_20261013.md)及[JSON](reports/KB1_output_service_bound_20261013.json)。现正常数值与KB1收益结论不变。
