# E001：完整复制实验方案与实际执行

来源为用户当前阶段结束后完整复制的要求；源 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline`，目标 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment`。原工程不移动、不删除、不覆盖。R001保存真实import_project.py、execution_identity.json、copy.log、source_inventory.json、file_sha256.jsonl、symlink_mapping.json与copy_receipt.json。

方法：research.py init/add登记独立项目→rsync -aH全量复制→内部links重映射→逐普通文件双侧SHA256→entry集合/类型/权限/跨源inode/源变化核查。输入身份为R001/source_inventory.json及file_sha256.jsonl，原硬件输入身份完整留在副本内。复制与核对低优先级串行执行，未启动EDA或新代理。

通过标准为所有上述检查无error；实际receipt status为PASS_COPY_VERIFIED。此实验只支持副本一致性，不支持完整硬件功能、资源或性能判断。生成原生管理文档不修改复制工程内容。
