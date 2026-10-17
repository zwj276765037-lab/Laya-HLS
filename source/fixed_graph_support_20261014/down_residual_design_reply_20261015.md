# Down＋原skip最小连接：静态依据交付

2026-10-15；A003→A001；M004/SM004/E004/R001。回复 `m004-down-residual-minimal-next-design-20261015`。完整依据已追加至 `source/fixed_graph_architecture_20261014.md` 的“Down＋原skip：完整FFN单行的最小静态连接”，身份/采样见同目录支持文件 `down_residual_binding_20261015.json`、`down_residual_binding_time_20261015.txt`。

唯一建议：现固定FSM保留真实入站skip，Down成功退休后用原精确ADD顺序原位写回，全部成功才发布。具体接口依据如下。

1. 当前AT166同SHA顶层没有skip或残差调度；`x_ready=(state==LN_WAIT)&&ln_x_ready`，故新增1024×32bit skip仅在外部`x_valid&&x_ready`写入，内部G→Q不能误写。Down的`A_DONE`原本直接转ROW，改为等front完整成功/债零、W真实release、Q行release/最终done后进入残差。每元素R_READ同步读skip和`final_bank[i%8][i/8]`，R_SEND保持至ADD接受，最后R_DRAIN。两个32bit保持复用已退休G的g_x_hold/g_gate_hold低32位；新增payload仅4096B，控制另计。单调读/有序返回保证原位安全，每bank至多1R1W，需断言同址读写不冲突、matrix/G写口互斥。
2. 原`laya_vector_add_stream_v1` SHA `417c12d7…`及CE叶子 `19ff0240…`匹配AT093。端口只有ready/valid+a/b/bits，无外部tag/finite/debt；32credit占用从输入接受直到输出消费，6-edge返回，阻塞保持。外层用11bit接受/消费计数作隐式位置，accepted−consumed计真实算术/结果债，读待完和保持对另记，不新建数据FIFO/tag队列。输入及结果各在真实握手检查finite，统一min归并旧首错/本拍输入坏/本拍结果坏；发现较晚输入坏后仍排空较早已发运算，防漏较早溢出。数值6、协议7优先，最后元素不能被done遗漏。成功只在1024接受/消费/写回与skip完整、无待读/保持/算术债时发布；错误部分写回始终隐藏。共同reset清全部新valid/计数及原ADD元数据，不用普通阶段reset消债。
3. AT050四行skip、Down、末残差产品均按原报告和AT093 manifest核SHA；AT166冻结source/LN/Wi/G/Down文本解码与旧二进制相等，当前顶层等于AT166冻结SHA `3a749c89…`。row0均偏移0/4096B/1024 little-endian F32：skip `63bafc067c5ea179e47146472dbbf2f55cb5e8c8182015d59e5ab40424ce84b4`；Down `842f711fb7b0f07d88b84b00c53f0a4804765ce95af54aa0badebfd2a0f5c94f`；末残差 `2166b4a0419649f2544f8bcb78fa8fe09d6abba492f46b1c7841e75856de94cb`。skip四行等于AT040源，Down四行等于原独立矩阵参考。保存文件只能作checker，不是producer；未运行oracle/生成gold。
4. `done_phase`扩为4bit，保留0..7，新增8=RESIDUAL失败，完整成功仍7=RESULT；状态码和bad_element不变。当前TB的3bit wire、`dut(.*)`及3'd7检查必须一并扩宽，caller/checker/序列化不能把8截为0；没有据此宣称生产Host ABI已改。
5. 下一有限场景建议仅两条完整成功行：真实G在途reset前缀/510拍隔离→完整cold残差；随后驻留两W运行有限warm错误序列（原W-tag错、Wi及Down各一个真实FP返回数值bad/poison，含较早poison与末组坏lane），最后Down数值失败后无reset→完整warm残差。最后成功行合并有限链内反压、ADD消费停顿、重复/倒序读、release竞争并核零新增AR。只对可反压口停顿，不丢无ready返回；数值注入保留valid/tag/debt，只签控制覆盖。ADD末坏/首错竞争/credit/reset用小尾部探针，明确不代替全顶层ADD在途reset后cold。所测G reset恢复及错误序列恢复成立后也不外推任意故障。

无阻塞一拍同步读+两状态调度，残差尾部结构预算≤2060cycle（2048读/发拍＋流水/屏障），尚非实测。AT166原cold+warm守卫1261.580029s；AT168 Wi reset前缀203.568609s、AT169 G前缀521.349162s。旧完整cold+warm加G前缀已约1782.929191s，错误序列/新尾部/编译另计，不能据此给新运行上界。AT166绝对row_valid=177546/290907、CMD_PASS=178317/291678；没有真实cmd接受标记，不能称请求latency或II。修订10余140.706825s不用于下一长例；由A001集中确定新预算。AT168/169目前按工程交付/主控审核状态登记，不提前验收。

本次轻量脚本8项字节关联全通过，实际墙钟0.06s/CPU0.06s、峰17204KiB、exit0，CPU0–3/nice19/idle、timeout20s/1GiB；交互读取未采样保持UNKNOWN。只改研究文档/依据/状态，无EDA、模型、新gold、新agent或E002改动。新残差顶层、bank端口、全链恢复及联合资源/Fmax均未测。最终接口/预算和工程实施仍由A001/A002负责，无需确认回信。
