# E002：当前实验工程验收范围

关联M002/SM002/A002。唯一实现根project/E002_Laya_HLS/experiment。本轮核验模型/输入、当前源码与旧baseline证据、真实生产链/13BO、恢复、可比性能及部署资源，不定义新goal/mission。

完整目标仍为B1/S128、28 Encoder＋2 Decision＋scorer/ACT及122 Q8矩阵；CPU token Embedding与会话控制，FPGA承担全部后续LN/量化/Q8/Attention/GEGLU/Decision。GGUF实物455179648B的SHA256 6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18匹配；五BO共448923648B及四请求source/target身份匹配，独立gold未改。

旧完整软件身份build23c62cd4778f54e3cc7508f5d05558de；当前46个实际编译依赖中7项变化（6实现/头文件＋1TB），配置生成器另有变化。production封存模块53项当前源匹配；Attention运行源匹配，两处历史文档SHA缺口保留。本轮仅定向文件/日志核验，未运行新的CPU/CSim/RTL/OOC/P&R/板卡或训练，未改变实现。

方法、验收矩阵和证据边界见[完整工程验收报告](../experiment_results/engineering_acceptance_20261011.md)。原始审计留experiment_results/engineering_acceptance_evidence_20261011/；真实生产接口沿用联合design §3.9。未变且通过的证据按身份复用。

---
Published: 2026-10-11T07:27:30.500120+00:00
Publication: P0aa6533d50e24ddbae22f0ce17a43cc8
