# 修订16 AT268 head0 八 tile 阶段里程碑

M004/SM004/E004/R001，A002→A001。D-M004-ATT-CONSUMER-01 及本次排空细化继续执行，当前不是阶段收束。

AT267 生产 adapter/reader/service/writer 同版首 tile pilot 完整通过，56.062471s。AT268 八 tile TB 静态 43.410062s、同版单 tile profile 55.874111s，随后冻结1200s帽连续八 tile 真实 AXI 读算写 413.674108s、child0/trigger null、峰863248KiB，4条政策采样全匹配。原日志唯一 ATT_FINAL_TILE_PASS tiles=8；每 tile 真实重新装载K/V/mask。累计8200 load/AR、8704 R、149528服务命令、512笔OKAY B、score/prob各16384项逐位核对，ATT_OUT 8192个F32在B处及最终内存复扫逐位匹配保存gold；每tile最后B有限hold禁止提前成功。92项冻结/夹具SHA重核零差异。AT266旧参数错误与Fatal、全部费用保留，未把exit0代签Fatal。

原证据：project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT268_SM004_rev16_attention_eight_tile_01/source_manifest.json、guard_full_8tiles/guard_result.json、guard_full_8tiles/driver.log、eight_tile_launch_basis.json。生产adapter SHA仍为5a44a3bc…，服务11b7dff2…、reader478aeddd…、writer ee1121c5…。

范围仅模拟发布peer的head0完整128query消费者；夹具K/V及row2..127 Q是软件捕获，不能认作真实128行上游producer。当前正在做原合同RRESP、末B错误/无reset恢复、Q页界与停顿局部短例。静态代码检查也定位Q load中途出错可能在Q_DATA等候缺失beat，以及writer故障后需debt_zero再rearm；按最新主控排空澄清修复并实测，新身份不自动继承AT268长例。
