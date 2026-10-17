# Managed LPV完整A及旧帧清理有限交付

M003/SM003/E003/R003；A002唯一实现owner。沿D-M003-EXECUTOR-MANAGED-LPV-OWNER-01，原范围/资源/预算保持。F19/F20已按R-SM003-EXECUTOR-CLOSE-F19-F20-20261013在原冻结host_06/shell_04范围关闭，本次不扩大关闭。

## 实现与来源

内部LAD1 version1，1024B/16拍；flags8=3，known role mask12，hardware session16、accepted-request24，完整84B NumericIdentity64、416B L13M160、13项epoch/address/capacity映射576（每项24B）；888之后及其他保留区零，不含S/H，不改LPV/Host ABI。C++完整codec/capture在真实软件LYRQ/LYMP准入后、HOLD前构造，失败不改变FullRuntime；当前仅STATE0已知，容量16920576B。host_02将真实actor保存对象encode输出到actual_admission_owner.bin，与独立literal逐字相等；不从literal直接生成该当前actual文件。host_01原assert同样比较实际对象但写出literal，保留原范围及文件，未回写。

MANAGED_LPV_OWNER默认0。新有限AXI portal启用后，以完整record安装锁住唯一A；首拍锁A/route，所有余16拍/8拍返回保留，pop须匹配完整旧A及route。持续撤销不清FIFO、拍状态或已呈现响应；末8次read只结束本帧，不释放A或清撤销。普通半帧收齐后负返回，完整已拥有pending仅在完整旧A/route/expected frame匹配后收齐负返回，零hub业务副作用。损坏完整model/保留位保持隔离。

唯一hub成功CLAIM owner槽与active_begin保存指向唯一稳定完整A的session/request引用；所有managed完整service请求比较该完整A/identity/model/known mapping，find_bound补owner A/model及完整descriptor，END保留原完整绑定/physical规则，INVALIDATE支持无BEGIN与错误END后的真实owner。managed取消禁自动批量清owner；新business/source query入口观察同拍与持久撤销，旧lease release路径保持。domain_drained独立于撤销flag，仍要求实际owner/scope/response/lease/guard等原条件。当前A不支持替换，防止未关闭时复用；这是有限持续单A准备，不是硬件rearm。

## 实际出口

- executor_admission_owner_host_02：完整1024B independent literal/codec/capture；22 wire拒绝清输出、7 capture拒绝FullRuntime不变、实际软件准入后HOLD前A。保留F19六末拍边界与原六真实结果分支：正常四窗口4退休，其他错误分支零业务退休。
- executor_managed_lpv_rtl_04：7复位分隔有限case，case内不reset/清FIFO/丢返回；1441/12000cycles。真实depth2 16/8拍，完整512B返回逐字匹配独立gold。CLAIM成功无BEGIN的返回反压下cancel/base变化、错route/完整旧A读不pop、恢复输入不清撤销、三个错descriptor/Ref/epoch和未知role不改正确owner，随后精确INVALIDATE。普通首2拍后撤销仍收齐、旧lane不换；受控完整preowned帧及从未发首拍的preowned旧帧各负返回。实际monitor一AW/一W/一B、旧END登记后末B与adapter fence各等12周期，错误END不丢scope/debt，正确END唯一hub typed终态一次，随后INVALIDATE与重复拒绝。model/保留位各完整隔离。A-bound source候选同拍cancel门关且恢复不重开，但无合法lease。
- executor_actor_host_09：原45 F17有限用例及两个软件请求共8退休兼容。
- generated_store_monitor_rtl_17：原默认实际fixture兼容（18AW/1027W/19B、4终态），该旧取消恢复仍仅默认语义。
- executor_handoff_portal_rtl_17/18：原正常及持续cancel查询fixture兼容；真实7终态、112AW/7168W/112B及16/16深度2查询，offline helper确认保持。managed LPV仍默认关闭，不能以这两项签活动LPV生产wrapper。
- executor_checkpoint_rtl_09：原五复位分隔诊断兼容，不签无复位accepted-request。

旧attempt与FAIL不改：managed_lpv_01为入口文件名错误，未执行DUT；_02在END交给hub前过早核pending而FAIL，_02→03只有TB改为等待实际hub接受再核末B等待；_03四有限case PASS。_03→04增加同拍source入口、坏保留位隔离与首次已拥有pending等受影响逻辑/用例。host_01→02的实际输出来源、runner及SV闭包变化单列；所有历史身份见verification的history。

## 核验与资源

355/355 frozen/声明pair；实际登记前355 current、1128/1128引用，登记后343 current、1116/1128引用，12差异全两catalog登记。当前actual A raw SHA256=40df536794b2377bb4955c106ce1a3eef8ded0a4b5c92d57c7f4eac218c56d0f，与RTL完整输入/独立literal相等。原四CLOSED捕获未改且当前host完整roundtrip。

12段所选guard实际起止串行，child0/trigger null；152实际policy均CPU0–3/nice19/idle I/O，MemAvailable门及原帽通过。managed RTL37.245376s/1650464KiB；oracle0.177104s无owned child RSS/policy，peak=null，资源观测完整性=false。host oracle/build/run为0.348978/22.064642/0.262617s，峰值25096/276780/30228KiB。actor oracle/build/run为0.276017/22.158026/0.244112s。默认monitor36.488315s，portal正常/取消38.977811/38.500288s，checkpoint76.727773s，均低于120s pilot帽。host5/actor45条故意leftover保持，不签坏帧恢复或全流清空；fixture/-MM不扩大为owned-tree资源实测。

## 未签范围与下一步

A字节来自真实软件准入但离线输入RTL，whole8192bit安装、preowned完整记录及候选lane仍受控；没有同一硬件runtime真实ingress/安装、实际adapter pending、真实全局HOLD路由切换、session/request真实生命周期。每case独立复位，禁止拼成无复位恢复。仅STATE0；source AR/F9/合法Q lease、双descriptor实际物理域/all13BO、生成adapter因果、唯一软件退休未验。实际END物理证据只一AW/W/B，不扩成LN数值计算。

生产wrapper仍将managed LPV新hook tie0、默认关闭；当前新增A capture失败仍隔离，已准入无LGP本地Host错误结果出口待实现。真实wrapper持续A/K/错误结果、committed ABORT、Host末拍/CLOSED真实consumer、带旧新归属准入及begin/recycle持续下界继续。其后接LAP1/action8/4、F10 24/16/source各入口/lease、独立executor生成及LN/hub→END/唯一软件退休→Q/full13BO。

C009/C013部分实施/awaiting_implementation，C008/C010待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。原单owner/单重工具/所有帽/G2338.224019s保持，5172s不重启，无新agent/HLS/OOC/P&R/上板/预算。当前无重工具。

原始与静态证据：各attempt的input_manifest/receipt/guard/fixture/frozen；本批executor_managed_lpv_verification_20261013.json、verify_executor_managed_lpv_20261013.py及catalog_delta。请求主控按实际有限冻结范围集中核查，工程继续独立已授权工作，无逐项审批。
