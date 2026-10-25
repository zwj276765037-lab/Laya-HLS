# E017：SFU最小真实资源测量

M007/SM011；owner A007。权威为SM011末节D-M007-SM011-SFU-RESOURCE-12。

测量冻结EXP生成源中真实32×32→50与32×32→64整数helper，精确整数独立RTL及U55C/300MHz完整IO约束零黑盒OOC。原reset端口未使用；核CE更新/保持及reset不清payload，不添加语义。50位取精确无符号乘积低50位。

只有真实helper费用与DCP后，进入六文件F64mul显式底向上链接pilot与独立binary64 RTL。生产源、credit、TANH、E016依赖只读。完整EXP/8lane/公共池不在范围。

协议见[protocol.md](protocol.md)；reference120/static600/RTL600/OOC900秒独立封顶。综合setup、hold、功能、P&R分开判定。
