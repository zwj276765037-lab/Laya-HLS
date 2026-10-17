# 修订20 AT326–327局部里程碑（2026-10-16）

修订20仍在实施；本记录仅对应已执行的下层完整Check回显与上层内部覆盖位移交后的父top row0前缀。未完成上层单一owner、独立生产stage或完整16/128行。

- AT326：下层接受LN_ONLY时锁存id/row/epoch，导出result_exec=001及op8/status16/detail32/bad64，父core核接收身份并代理。原局部Q16全部16槽4352字最终复扫、512同步响应、部分窗口abort/discard/新epoch和共享bank客户端仍通过；非法LN视图tile的完整Check断言通过。static 32.20409899018705s，RTL 30.382008612155914s，均child0/trigger null。
- AT327：在上层生产服务内部维护norm_written、stage_store_fault与norm_stage_ready，wrapper撤去原成功位/故障/ready决定脉冲。冻结124份源码/脚本及5份实际fixture；同版父top重新展开static 143.9772515669465s，RTL 49.26396718993783s，均child0/trigger null。`PREFIX_ROW0`自检实际gamma256R、source64R、1024项norm逐位、64笔OKAY B及row0退休；终标在153800ns，无提前stage ready。该source64R为终标时全次计数，运行在row0完成后立即结束；不推断后继行或128终点。

四笔guard当前累计static 176.18135055713355/1800s、RTL 79.64597580209374/3600s；截至AT327余static 1623.81864944286645s、RTL 3520.35402419790626s，static仍须为最终父top构建保留400s。host完整累计UNKNOWN。原guard、manifest、源码身份均在各自attempt目录，失败/旧结果不改。

当前`laya_qkv_s128_request_v1`仍驱动staged 128行S_SEND/S_ROW/S_STAGE_READY与16行store错误屏障；`laya_qkv_scratch_row_v1`仍驱动IN_*及norm SEG/READ/FLUSH/RELEASE/Q_DONE。因此AT327是父请求前缀功能回归，不能判D-M004-SOURCE-NORM-OWNER-01控制迁移完成。下一步按既有固定切口迁移上层唯一控制后，再建立无逐行TB代驱动的独立stage与16行成本pilot；完整LN128和父top同版联合验证未运行。
