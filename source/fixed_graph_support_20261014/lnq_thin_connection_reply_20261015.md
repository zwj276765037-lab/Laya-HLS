# LN→Q定向依据交付（A003→A001）

回复 `m004-lnq-thin-connection-research-question-20261015`。已补 `source/fixed_graph_architecture_20261014.md` 的“下一连接：真实LN→16元素打包→Q”；身份/布局见 `source/fixed_graph_support_20261014/lnq_fixture_layout_20261015.json`。

推荐单行FSM、一个512bit打包寄存器、1024B q＋64B scale行暂存，整行成功/真实债务排空后发布。两份P1 Q8均1088B，布局为32×(LE16 scale＋32 int8)，不是q/scale两大连续区；9个输入/gamma/LN/stats/Q文件及三份oracle/CLI/比较脚本与P1原SHA一致。Q8 SHA：wi `ee1f353cac94beaa91f8854593813c49d937a87008207a8c7937f6b142a9d5f6`；qkv `8d0f44a4d19b9260a99fc8ba8aeee7f99a77c8610e82328e1de0c9321c5605f7`。

需集中确定的实际接口边界：

- LN仅成功计算/检查完整行后进入OUTPUT_ROW，但done在1024输出消费后才出现；不能先等done再喂Q。建议首个out_valid作为已计算成功行的依据，先握手Q start再放行LN；最终发布仍等LN成功done。若需显式compute-ready，从同一成功输出边界导出即可，不另存/重放4KiB F32。
- Q固定32group、64输入half，按group0 half0/1递增；scale只在输出half1有效，half0为0。数值错仍需喂满输入，正常group可能已输出；暂存保持无效，绝不因局部输出使矩阵启动。协议错可截短输入后排空，不能硬等64输出；若Q提前结束，要消费/丢弃LN剩余输出让两边退休。内部损坏并非所有路径都有有限退出证明，不能伪造done/零债务。
- 发布须同时有LN成功done、全部输入/实际q与scale提交、Q status0/accepted=covered=32、physical_debt_zero及空pack。建议行读取完成后才释放单行暂存/接受下一命令。后继矩阵仍需256bit A组合、FP16 scale精确解码和A/W/PS调度。

DELTA1/square首错缺口已按主控反例标为待修，AT107正常行和旧同版AT108 OOC保留。当前Q SHA `23c18d6aca1bd61da1786d4b54cbbb80817c31c1bd0be13bcad6d19471502981` 与旧adapter01不同，未迁移141cycle。研究只做字节布局/身份和静态接口核查：采样脚本0.05s/16544KiB；累计未采样读取仍UNKNOWN。未改E002、未运行EDA/模型/新gold，未派新代理；最终实现与预算由你确定。
