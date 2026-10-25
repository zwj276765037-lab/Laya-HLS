# E014：LN-COMPACT-22 实验依据摘要

任务M007/SM011/LN-COMPACT-22，独立批次R002；A008只拥有layernorm_engine与E014。A007共享资源/真实arena、A010父图分别单owner。

当前生产core为2a97609c9245f53c699b77e5c8110fc9ea7f2029547e32d593366da0e2e22eac。默认模式保留任意96bit tag；canonical模式按身份/row/chunk重建，ADD仍64信用/146bit metadata，scalar3/2bit标签和全部控制在q中，external无私有影子q。v3布局12128/12288bit，备用160，新增8bit保持scale/sqrt/DIV已提出未接受请求；work与physical retirement均包含offer。Gamma132bit持久控制及原18055bit数值状态保留。

正常及协议短验证在真实唯一sharedFP256/DIV8/LN-exp32KiB壳上执行，q由TB拥有。复用R001 AT001原encoder00/27、原final_norm_w和原全中间/最终checker，无新gold。AT009与AT020的13个生产依赖相同，只有MODE17的TB触发条件收紧；完整SHA与范围见[当前检查点](../experiment_results/runs/R002/v3_normal_protocol_checkpoint_v1.json)和[生产manifest](../experiment_results/runs/R002/source_manifest_v3_verified.json)。

当前只签PURE_EXTERNAL_CONTROL_UNIT正常16row/真实4ctx和限定协议/取消/恢复。c612原full128正常证据独立保留，未迁移到v3。source_finite_qualified仍是TB常量，不是实际producer有限性证明。完整CPU错误排序和source-summary仲裁尚未实现，当前数值错误仍物理先到/global stop；gamma拒载仍是配置资格。真实arena/父4KiB、v3 full128、scale阻塞取消、内部bit损坏runtime及当前完整FF census继续OPEN。

原独立帽reference60/static600/RTL1200/OOC0秒，单次未知≤120秒；CPU0–3/nice19/idle、MemAvailable>192GiB、项目一重锁、120秒真实checked-consume停滞保护保持。AT009以后guard_v2记录owned PID/start_ticks策略采样，AT001–008旧后代策略UNKNOWN不补签。desired gpt-6.1-sol/xhigh，actual未独立核实。
