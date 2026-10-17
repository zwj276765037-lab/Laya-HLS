# E003：启动准备结果

[R002](runs/R002/run.md)轻量核查子检查PASS，guard/child退出0，墙钟1.675503s、峰值owned RSS 23452KiB。33个编译单元依赖提取全部退出0；完整请求闭包57项对旧47项（源码56对46），新增12/移除2/内容变化7；全部构建目标61对51项。当前与冻结61项共122次hash/大小核对匹配。432项现有模块源码/配置/IP/约束库存已记录，包括2份XDC，尚不代表最终生产top闭包。

[R001](runs/R001/run.md)在历史审计格式读取时以KeyError停止，原始日志和已用脚本保留；修正后新R002完成。模型payload与gold按已核验审计原身份复用，没有改变输入或重复运行验证。Attention v10两处历史文档漂移仍明确保留。

M003：L0 PARTIAL，L1–L5 NOT_RUN。实现变更、生成硬件、完整CPU/CSim、RTL及OOC均未启动；数值与链路验收无新结论。没有最终新build，也没有用旧tag给当前源码签名。完整加速器和完整请求性能仍未验收。详见[主控同步项](controller_start_notice.md)。


---
Published: 2026-10-11T08:13:46.070272+00:00
Publication: Pf0666919935040a7bd4e92f9f4dc8dbb
