# G量化输出与KB1预量化输入：定向字节身份

补充上一份只读定位：本项目复制树内原G桥04的 `work/fixture/q.mem` 与AT002 KB1的 `work/fixtures/a/q.mem` 均为21320B、SHA256均`7d99ba99cc3458df389add7b34483db5087f55a46cc5b29538ec363f1f4e8a76`；两份 `scale.mem` 均1640B、SHA256均`22a4b08447660550549fa4b2f509a61482e732be0dfdf0a1d43eff73989580c0`。故**冻结的独立期望输入**逐字节相同，四行×82组数据映射有直接依据。仍需由新有限DUT运行证明G真实producer经原完整身份和背压读口进入KB1 Down，而不能因fixture相同把两项旧PASS拼成实际链。
