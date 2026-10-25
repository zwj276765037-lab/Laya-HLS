# M007严格TANH/GEGLU后继依据

2026-10-21，A001静态核查；没有模型计算或EDA。

原TANH图含23 add、17 mul、2 direct div；有效结果edge356，旧固定commit384。当前8/8/32拍通用叶子原图重排仍342拍，故不能按现配置签160拍。起始新leaf要求3/4/12给原图152拍静态结果，剩8拍接口空间；真实300MHz/数值/II均待测，不能从整数调度推导物理可行。

[机读节点与路径](m007_tanh_schedule_20261021.json)保存原生成器SHA、完整依赖和候选成本。最初7/7/32边沿假设已明确更正为原E008/RTL实际8/8/32；没有修改旧原收据。

正式后继为[SM011 TANH-G8-08](../mission/M007_完整Attention高性能主干与部署闭合/tasks/SM011.md)。单lane新leaf和数值先行，然后8lane原G算法；A008在LN交付后实施，A007共享源只读。原G银行两个32KiB slot与Wi输出32宽兼容，后继Down按group-major量化写另一A槽，避免新增整G tensor RAM。

原gelu_array按全tensor阶段顺序核input/u/v/w/t/z/y，GEGLU gate结果最后；旧scalar g优先不能沿用为新全域Check。Decision激活明确为ReLU，不能套用Encoder GELU。资源、联合SFU和FFN整体性能须后继实际证明，当前仅完成后继接口与要求，不签实现。
