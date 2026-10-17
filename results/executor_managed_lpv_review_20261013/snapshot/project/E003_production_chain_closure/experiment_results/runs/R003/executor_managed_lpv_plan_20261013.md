# Managed LPV归属实现与受影响证据计划

M003/SM003/E003/R003，A002单owner。D-M003-EXECUTOR-MANAGED-LPV-OWNER-01，实际用户授权/资源/预算保持。

先冻结内部LAD1完整A：1024B/16拍version1，session/request实例、84B NumericIdentity、416B L13M、13个role的known mask和每role epoch/address/capacity（未知role零）；不含S/H或Host可信声明。真实actor实际LYRQ/LYMP准入后、任何HOLD之前构造。当前fixture仅STATE0已知，其实际物理配置仍受控，未知role拒绝，不代签13BO。

C++ codec对独立literal、wire拒绝清输出及capture失败FullRuntime不变；SV完整record验证须实际执行并绑定真实C++capture。随后真实managed transport、唯一hub A/模型/descriptor精确检查及owner/cancel/END/INVALIDATE持续收束；正常默认旧诊断保持。首拍所有权、完整帧、返回8次read及末B/fence条件分开，不能按FIFO empty/reset/撤valid消失来过关。

受影响host/有限RTL串行，原CPU0–3/nice19/idle I/O、MemAvailable>192GiB、host24GiB/1800s/120s、RTL8GiB/120s/120s及入口周期帽。G2338.224019s不变；5172s组合不重启，无新agent/HLS/OOC/P&R/上板/预算。失败保留新attempt，独立工作继续。旧F19/F20候选及旧所有交付不回写。

## 当前有限RTL入口（2026-10-13）

`run_managed_lpv_rtl.py`冻结当前transport/hub/AXI portal及LAD1校验，依赖actual admission host_01完整1024B捕获与独立literal。四个复位分隔有限case，case内无reset/清FIFO/撤valid：CLAIM-only返回撤销及精确INVALIDATE；普通半帧/受控已拥有完整帧负返回；真实单STATE0 END/末B/adapter fence；损坏model隔离。逐字512B独立响应gold、11个SV A拒绝、实际首末拍和路由tag反压、零新业务/唯一旧typed终态核验。入口12000cycles、RTL8GiB/120s/120s及原launcher条件。

A安装及adapter preowned仍为受控完整内部接口刺激，硬件真实LYRQ/LYMP准入/安装、实际adapter pending、global HOLD切换、source AR/F9/lease、CLOSED/rearm均NOT_RUN；原wrapper managed参数默认0，不以本批代签生产使能。

## 当前交付身份

实际最终选择host_02及managed_lpv_rtl_04（七case/1441cycles、22SV wire拒绝），actor_09、monitor_17、portal_17/18、checkpoint_09受影响兼容。355/355冻结配对及12guard串行已核；两catalog登记带来12处live差异，资源完整性因短oracle未采样为false。前四case入口计划与_03 PASS是历史；_04补源入口同拍/坏保留位/首次已拥有pending，不回写旧attempt。当前无重工具，真实生产wrapper及关闭/rearm工作继续。
