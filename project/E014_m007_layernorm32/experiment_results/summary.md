# E014：v3 正常与限定协议结果摘要

当前core2a97609c…2eac、layout v3的实际结果见[检查点](runs/R002/v3_normal_protocol_checkpoint_v1.json)。

| 已测范围 | 实际结果/证据 |
| --- | --- |
| 16row真实gamma | AT010：32736树节点/512最终向量及全中间逐位，first330、DONE退休2290 |
| 真实4ctx/held输出 | AT011：八行gamma全checker通过、1880held输出周期，ADD/MUL峰27/55 |
| gen/tag/index拒绝 | AT012–014：held reject5/8/6各17周期，matching cancel、实际债排空、held cancelled DONE17周期、无reset新gen完整4行恢复 |
| active clear/错误返回 | AT015/016：sticky protocol7/1、真债排空；额外坏ADD记录不减genuine pending、不替换真实返回；held terminal17周期和无reset恢复 |
| 禁用owner/gamma | AT017：disabled共同reset资格、任意公开union q共34检查、inactive零握手/next=q/retired0、gamma跨disable/合法retired clear保留后真实正常gamma通过 |
| blocked offer取消 | AT018 DIV阻塞18周期；AT021 sqrt18/DIV121周期，保持到真实接受、返回排空、held terminal17和无reset新gen4行通过 |
| public compact codec | 每例2816个item/ctx/index组合，其中1032非法范围；同生产函数局部wrapper，无内部位强制或故障注入 |

AT019实际FAIL与5.834709495014977秒费用保留：TB在sqrt忙但DIV尚未提出时提前取消。仅TB wait收紧为两个请求均实际blocked，AT020 build/AT021通过；两个build生产13文件相同，正常checker未变。

R002累计reference0/static40.573950229969342/RTL153.0837858609738765秒；余额60/559.426049770030658/1046.9162141390261235，OOC0。新窗口6536次verified owned PID/start_ticks策略采样、0校正，所有attempt owned cleanup为空，锁实核free。旧AT001–008后代策略仍UNKNOWN。

c612历史full128 plain/gamma各131072最终F32/261888树节点逐位、DONE退休16618/16626，仍只绑定[旧正常检查点](runs/R002/normal_checkpoint_v1.json)。v3 full128、真实arena/父fit/finite producer、完整CPU首错/source-summary、scale阻塞取消、内部损坏runtime、当前private FF census、整体OOC/P&R均未签。


---
Published: 2026-10-23T03:35:43.856166+00:00
Publication: P7b8cfeaf8a254b53bbcc11e958297316
