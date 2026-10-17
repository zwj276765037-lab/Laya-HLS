# FFN2审核：运行包准备停止，尚无新仿真

2026-10-14；R-SM005-FFN2-20261014；M004/SM005/E005/R001；A001。回复 `measurement-first-FFN2-AT061-bounded-preparation-handoff-20261014`。

**核定COST_NOT_ADMITTED_INVALID_RUNTIME_DEPENDENCY_PREPARATION。** AT060清单缺解析库闭包，AT061唯一纯准备修正又对Bash loader调用ldd并失败；原合同停止，无pilot/full、LN AR/R、新速率或完整链结果。旧AT058/059静态和短测、AT057有限前缀均保持原范围。

[主控只读核查](measurement_first_FFN2_review_20261014/verification.json)核1173个证据/管理/工具文件当前身份：AT060清单的262文件/130020393B与AT059源、AT060和AT061两份bundle逐bytes/SHA相同，两副本无符号链接；AT059的336输入引用也一致。AT060十项冻结支持文件及五项vendor身份相符。两次冻结仅launcher不同，源DUT/TB/guard/fixture未改。

AT060完整/缺ROM/坏ROM/缺reloc四个原preflight分别ACCEPT/REJECT/REJECT/REJECT；三个拒绝原因对应集合缺项或字节身份变化。冻结negatives路径只调用verify，不到launch/spawn分支，支持这组是host-only检查；它只检查原清单所列范围，不能证明遗漏的库已经核验。两尝试无guard/真实资源采样，host墙钟、RSS、CPU/nice/I/O实测保持UNKNOWN。

AT061 `package_manifest.json` 不存在，pilot/full启动记录和运行目录不存在。`ldd_loader.exit=1`、stderr为 `not a dynamic executable`；主控直接读magic，确认xsim wrapper、loader、setupEnv.sh、rdiArgs.sh是脚本，而unwrapped xsim、snapshot xsimk和Bash解释器是ELF。冻结launcher在清单写入前对loader执行 `subprocess.run(ldd, check=True)`，与准备停止记录一致。原Python完整stdout/stderr traceback未归档，不补称已核原异常堆栈；以后准备执行也保存原输出/返回码。

这里还有两项需要一次讲清的依赖边界：loader第131行确实source `rdiArgs.sh`，前两版TOOL_FILES未列它；loader会构建RDI_LIBDIR、Java/Python等库路径，AT061人为设定的两个LD_LIBRARY_PATH目录不能自动等同实际xsim解析环境。ldd的DT_NEEDED闭包也不证明所有运行期dlopen或脚本资源已枚举。

选择[D-M004-FFN-TYPED-RUNTIME-PREPARATION-01／FFN3](../mission/ffn_typed_runtime_preparation_stage_20261014.md)。保持一个直接xsim方案、同AT059编译产物/DUT/TB/guard/数据，补类型感知的脚本/ELF身份与实际解析环境。纯host普通修正改由明确的累计120s执行预算约束，额度内连续修复并保存失败版本，无需每个脚本异常再开合同；这不放宽xsim次数、DUT修改或资源帽。至多一次真实冷前缀，只有新前缀与保守成本准入后才可至多一次冷full。

FFN2历史停止不回写，AT060局部ACCEPT不追认完整运行包。FFN3新结果NOT_RUN；普通Q/L/整体executor/恢复停排，M003/M004及全模型/13BO/生产双lease/联合物理义务仍开放。
