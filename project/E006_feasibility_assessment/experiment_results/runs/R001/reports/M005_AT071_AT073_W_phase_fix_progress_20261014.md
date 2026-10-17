# M005 W 端短测与最后 normal full 准入

A002→A001；2026-10-14；M005/SM006/E006/R001；回复 m005-at070-bounded-closeout-controller-decision-20261014。

AT071 同代表 top W 冷装载短测在 3000cycle 受控 Fatal 停止：时钟持续推进，q0第二AR已被TB记账，但 W q0/q1/scale R 停在0/64/0，q0/q1 RVALID 有值而 RREADY=0，AUX仍8 beat。guard 15.236713s、child0/null，原日志包含 Fatal，结论 FAIL，不当PASS或DUT死锁。源码定位原TB在 posedge blocking cycle++，组合 W/AUX ARREADY/RVALID又以cycle取模产生；同一接收边沿的TB与DUT可采到不同ready。

E002唯一受影响普通修正：仅TB W/AUX模型在negedge锁存周期相位，四个 ARREADY/RVALID 表达式改用该相位；DUT算术/缓存/top/fixture/gold不改。AT072新冷短测：q0/q1首AR cycle23、scale首AR cycle24、AUX首AR cycle23；q0第二AR cycle106，第二段R从107恢复；q0/q1均128 R并在185/186末R，scale64 R，AUX末R33，cycle187 M005_W_PROBE_PASS。guard6.771937s、child0/null、无Fatal、无trigger。它仅证明真实同top W装载接点越过AT070停点，不代签整链或完整W载入。

AT073同冻结top正常TB静态编译/展开child0；原236项及候选22项每次spawn前逐bytes/SHA核；≤120s新冷prefix cycle5224有真实LN 1AR/64R及PASS，22.688626s、峰1014536KiB、无Fatal/trigger。按本次230.248cycle/s与旧真实到Down前172.487cycle/s取慢者，规划520000cycle乘1.10为3316.188s，小于单次3600s；这是准入估计，非完整链实测上界。AT065/070已用2/3 full、2796.627354s；若启动AT073，将使用最后一次full。完整功能/稳定性和物理结果仍NOT_RUN；旧attempt不改。
