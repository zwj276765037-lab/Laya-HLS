# F19/F20受影响修复与验证计划

M003/SM003/E003/R003，A002单owner。依据R-SM003-EXECUTOR-REQUEST-CLOSE-20261013及D-M003-EXECUTOR-CLOSE-REARM-01；仅修既定消费归属和终态封存义务，不改变LHC1布局/Host ABI或数值规则。

F19：managed消费独立于legacy bool；真实program错误结果到WRITE_RESULT末拍，六个有限用例核bool pulse/持续、语法合法错identity/PC、完整record同过渡保留、后继完整record及尾2/尾1实际read延迟。原实际四窗口、五错误结果分支、156 wire拒绝保留；software queues无深度限制，co-present完整record为受控接口刺激，不代签硬件反压。

F20：完整终态ready/accepted独立于control仲裁，封存持久且新启动立即禁止；commit由实际完整IMPORT/ABORT consumer核定。三phase×五控制类别，另实际/错/早IMPORT、commit1 ABORT、GRANT已呈现稳定、query准入冲突及旧query末read/work/Host同拍。独立CLOSED literal不改。原19+17场景保留，原6000cycle帽不变。

新attempt不覆盖旧证据。先shell，再host真实capture codec，再actor/default兼容与managed portal正常/持续cancel兼容；只串行启动一个重工具。RTL8GiB/120s/120s、host24GiB/1800s/120s、CPU0–3/nice19/idle I/O、MemAvailable>192GiB原帽保持。G2338.224019s及5172s组合不重启，无新agent/HLS/OOC/P&R/上板/预算。

通过须原始行首marker、退出0、guard无触发、完整冻结SHA及literal/capture相等；失败保留新attempt并定位。F19/F20待主控有限验收，不写总完成。真实wrapper/no-LGP/committed错误、活动LPV、带归属新准入/所有高水位、source/Q/F10和生产整链仍待。
