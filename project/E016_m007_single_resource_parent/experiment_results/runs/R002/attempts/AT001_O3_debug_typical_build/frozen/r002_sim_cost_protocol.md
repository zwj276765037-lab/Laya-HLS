# E016/R002：debug typical/off QKV3成本对照

合同：SM012 D-M007-SM012-SIM-COST-13。A010继续owned父runner/TB与E016证据，其余源read-only；R001原证据冻结。新预算reference0/static300/RTL300/OOC0秒，单次≤120秒、strict checked semantic stall120秒。共享m007_heavy.lock贯穿工具后代；CPU0–3/nice19/idle、MemAvailable>192GiB，static≤24GiB/RTL≤8GiB/40Mcycle。无旧余额转移。

当前parent SHAe35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8、其余source closure按R001所用依赖选择。两个build冻结完全相同的RTL/TB/原fixture/guard，唯一编译选项差为xelab -debug typical/off，保持--O3、-mt4、--relax、相同top/snapshot及全部数值/协议检查。R002同一TB只对原TB增加一个被动quant-return计数、4096终点断言与input/quant/A/W/QKV已有握手计数打印；原checker/频度/驱动与所有断言不删不改。instrumentation_boundary.json绑定其原/新SHA。

先typical build+原Encoder0 QKV3，再off build+同QKV3。预期4096真实input/quant/Awrite/Aack、768公开QKV32/24576 F32逐位值、三块每块1024连续issue/commit、真实W/A原映射、prebias与Attention独立原gold、8个高半身份/跨层tensor错误拒绝、parent保持未完成。严格进度guard及有限传输peer相同。保留实际compile/runtime命令、source/fixture/compiled manifest、warning/error、日志、wall和phase cycles。

两个snapshot分别尝试同一Tcl hierarchy query，query失败或缺内部scope时单独明确UNOBSERVED；不借typical层次替off签署。Build编译过程与hierarchy query分日志，不能将query不可用冒充数值失败或删除TB内部引用以通过off编译。

两次短例均完成后只比较实际wall/cycles与相同数值/事件计数。无改善或不兼容即出口，不盲试其它选项；有改善也不自动运行16head/WO。单次样本只支持该QKV3环境的初步成本对照，不能外推全部phase或FPGA吞吐。
