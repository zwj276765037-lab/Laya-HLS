# once-BEGIN kind7成本草案（只读；不放行）

AT005 launch→layer0原H=336.314555s/cycle424292/848601eval，实际524288B同原Encoder0；含一次setup/H/捕获/计划停止，非整图PASS。最长Wi/G/quant连续段81.945932s；后续层/Decision/尾部未测。

固定工作：28Encoder=10full(0,3,…27)+18sliding；后续27层比layer0多preLN。2Decision各preLN+post-attnLN、4矩阵/16head/2残差，无RoPE/GEGLU；FC1/ReLU/quant重叠，16384A1写+ACK后才FC2。总120矩阵/运行catalog、480head、28GEGLU、60LN=29pre+30post+1final、61VECTOR=60残差+type。每LN=128×1024=4096groups32，总245760组Q写；每层H终点4096组。

Encoder27后final gamma(offset448)写4096Q、type(offset449)写4096H，再Decision0 preLN，不能漏/重计。H只public加载一次，层间驻留，无重复setup/完整public导出。尾=16marker槽(14inactive)+CLS=544×128B=69632B，须实际写/flush、commit及最终退清/DONE，原mask/marker不变。

固定的是shape、循环/计数/层序和CE算术延迟，非总cycles。full/sliding均走128×128 score/AV，sliding仅±64mask/不同RoPE，不能按窗口缩时。cache/peer/AXI回压、存储credit/owner交接影响cycles；数据检查分支、OS/IO影响工作或墙钟。TB固定8/17拍输出hold、tail_delay7、17拍DONEhold；握手等待另计。

预算式(秒)：B=1.35×[T0+9F+18S+27P+2D+N+Y+G+H]+10。

T0=336.314555；F/S=不含preLN的后续full/sliding完整层(含内部handoff)保守实测包络；P=额外preLN至QKV接续。D=max(T_Decision0,T_Decision1)完整局部样本，已含preLN，不能再加2P；其setup/publicIO可保守保留，不冒充kind7内部实测。N/Y/G=finalLN/type/gather写尾commit至DONE，H仅为未覆盖层间交接。Wi/G/quant不串行相加。未知项未齐则B=UNKNOWN；35%是规划裕量，非严格上界。

须B≤min(3600,当时D34余RTL−600reserve)；总授权7200，不转R001/R007余额。即使Decision/额外LN/尾部=0，3600/28仅容许Encoder均摊128.57s，当前首层336.31s有明显风险，未证后续能补平；不能宣称整图≤3600。缺测/超额报主控，不放行新预算。

停止条件：逐层连续计时preLN→QKV→16head→Attention→WO→残差A→LN→Wi/G/quant屏障→Down→残差B→原H/退清；未知段/交接仍≤120s。每真层终点重算elapsed+remaining；触及单次/余预算及时COST_STOP，保留在途请求，不伪PASS或切层注入。只有严格递增checked/真实retirement续semantic timer；gold/身份/计数错立即FAIL。尾部独立限时，30层+544写+1commit+正常DONE齐全才成功。

证据：E021/R002/attempts/AT005_first_original_layer/receipt_rtl.json及phase_source_predicates.json；原8b55 TB:165–188/237/281/285、parent_v3:1503/1706–1841、qk_av:519，完整源路径见本R007/fullgraph_retire_progress_delivery.json。只读，无运行/改源/新gold/转预算/主控索引改动。
