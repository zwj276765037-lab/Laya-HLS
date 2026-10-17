"""One-shot controller-only record update with preserved preimages."""
from pathlib import Path
from datetime import datetime, timezone
import difflib
import hashlib
import json

ROOT = Path('/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS')
OUT = ROOT / 'results/measurement_first_FFN3_review_20261014'
assert json.loads((OUT / 'verification.json').read_text())['audit_pass']
assert not (OUT / 'records_before.json').exists(), 'Do not rerun a completed update'
paths = ['mission/current.md', 'goal/goal.md', 'results/overview.md',
         'results/hardware_metrics.md', 'results/hardware_progress.md',
         'results/review_queue.md', 'results/reviews/SM005.md',
         'project/missions/SM005.md', 'agent/A001/result.md',
         'agent/A001/state.json', 'NEW_CHAT_START.md']
before = {p: (ROOT / p).read_text() for p in paths}

def digest(p):
    data = p.read_bytes()
    return {'path': str(p.relative_to(ROOT)), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

for name, body in before.items():
    p = OUT / 'prior_records' / name
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(body)
(OUT / 'records_before.json').write_text(json.dumps({
    'at': datetime.now(timezone.utc).isoformat(),
    'files': [digest(ROOT / p) for p in paths]}, ensure_ascii=False, indent=2) + '\n')
updates = {}
updates['mission/current.md'] = '''# 当前工作：FFN4分离Wi与Down存储描述符并验证

[FFN3审核](../results/measurement_first_FFN3_review_20261014.md)核定AT062 FAIL_SEMANTIC_WI_READER_CONFIG：冷前缀1AR/64R通过，唯一full达到LN/Q/Wi，cycle271096因Wi reader误取Down STATE1 BO拒绝。Wi真实done消费271089、完成标记271090。原full1696.153932s/峰1036100KiB，child0/null不覆盖Fatal；后续G/Down/残差及最终保护未到达。1549路径、336来源引用、262编译包文件及两运行副本冻结身份一致；两动态guard/8policy匹配。旧记录不回写。

当前[D-M004-FFN-WI-DESCRIPTOR-REPLAY-01／FFN4](ffn_wi_descriptor_replay_stage_20261014.md)只稳定分离Wi DDR与Down STATE1描述符，保留功能DUT/reader范围校验/观察器/guard/gold。新static和四行reader正反短测，一次真实冷前缀后按实际到Wi与分阶段剩余成本决定至多一次full；旧3536.346s不自动沿用。static/短测首次加至多两轮有因修正，纯host累计120s内连续准备，完整边界见合同。新阶段NOT_RUN。

AT049到Down与AT054独立残差PASS不能拼成联合PASS。真正同runtime TMP/残差/655360B终检及整链周期仍未测。A002唯一实现/工具，E002/experiment代码、E005/R001证据；单重工具和原CPU/nice/I/O/MemAvailable/工具帽保持，无新agent/参考/HLS/OOC/P&R/上板。普通Q/L/整体生产控制/恢复停排；外部Attention residual、生产双lease、完整BO/13BO、全模型/资源/物理和M003/M004开放。
'''

goal_current = '''## 2026-10-14当前阶段

[FFN3审核](../results/measurement_first_FFN3_review_20261014.md)核定AT062唯一full在Wi reader配置处语义失败，已达LN/Q/Wi不代签后段。当前[FFN4](../mission/ffn_wi_descriptor_replay_stage_20261014.md)只分离Wi DDR与Down STATE1描述符，保留功能DUT/guard/gold；新static与受影响短测后，一次冷前缀及分阶段成本决定至多一次full。新结果NOT_RUN，普通Q/L旧goal不推翻测量优先重排；M003/M004与全模型/13BO/恢复/资源义务不变。

'''
body = before['goal/goal.md']
start = body.index('## 2026-10-14当前阶段')
end = body.index('## 当前优先级修订', start)
updates['goal/goal.md'] = body[:start] + goal_current + body[end:]

overview = before['results/overview.md']
start = overview.index('\n\n') + 2
end = overview.index('| 工作 |', start)
overview = overview[:start] + '''[FFN3语义失败已核](measurement_first_FFN3_review_20261014.md)：AT062冷前缀通过，full到LN/Q/Wi后于271096发生Wi reader cfg Fatal；Wi消费271089、标记271090，后段未到达。当前[FFN4](../mission/ffn_wi_descriptor_replay_stage_20261014.md)仅分离Wi DDR与Down STATE1描述符；新static/短测/冷前缀后按分阶段成本决定唯一full，NOT_RUN。普通Q/L/整体生产控制停排，M003/M004开放。

''' + overview[end:]
oldrow = '| FFN3类型感知启动 | NOT_RUN | 脚本/source链与ELF依赖核验；一次冷前缀后再有据full |'
assert overview.count(oldrow) == 1
overview = overview.replace(oldrow, '''| FFN3类型感知启动 | AT062前缀PASS；full Wi reader配置语义FAIL | 已达LN/Q/Wi，后段NOT_REACHED，旧额度收束 |
| FFN4存储描述符分离 | NOT_RUN | 稳定Wi DDR/Down STATE1；新static/短测/冷前缀/成本后唯一full |''')
updates['results/overview.md'] = overview

metrics = '''[FFN3审核](measurement_first_FFN3_review_20261014.md)：AT062 prefix28.989676s/1035900KiB，cycle5224、1AR/64R；full1696.153932s/1036100KiB、child0/null但Wi reader cfg Fatal271096。Wi末B271074/首done271082/消费271089/完成标记271090；非整链时延。两串行guard/8policy全匹配；host7.112138s、rusage自/子峰1522944/88796KiB，不是owned树峰，host实际I/O采样UNKNOWN。1549核查路径、336来源引用、262文件/130020393B编译包与冻结副本一致。3536.346080s仅旧工作量规划，不认证联合上界；FFN4须新分阶段成本。新物理资源/Fmax未知。以下为历史。

'''
progress = '''2026-10-14最新：[FFN3审核](measurement_first_FFN3_review_20261014.md)核定AT062语义FAIL，LN/Q/Wi已达，后续未到；唯一full收束。当前[FFN4](../mission/ffn_wi_descriptor_replay_stage_20261014.md)只分离Wi/Down BO描述符，保留功能DUT和guard/gold，新static/定向四行短测/一次冷前缀后有据准入至多一次full。新结果NOT_RUN，生产控制停排，M003/M004开放。以下为历史。

'''
for name, intro in [('results/hardware_metrics.md', metrics), ('results/hardware_progress.md', progress)]:
    head, tail = before[name].split('\n\n', 1)
    updates[name] = head + '\n\n' + intro + tail

entry = '''## R-SM005-FFN3-20261014：Wi reader配置语义失败，分离描述符

AT062 FAIL_SEMANTIC_WI_READER_CONFIG；冷前缀真实1AR/64R通过，唯一full1696.153932s/峰1036100KiB，271096拒绝Wi reader配置。LN/Q/Wi已达，Wi消费271089、完成标记271090，后段未到。1549路径、336来源、262包文件/130020393B及运行副本冻结身份相符；两guard/8policy匹配。host实际I/O/owned树峰缺项保留。

D-M004-FFN-WI-DESCRIPTOR-REPLAY-01选择FFN4：只修Wi DDR与Down STATE1描述符绑定，不改reader校验或算术DUT；新static、受影响正反短测、一次冷前缀和分阶段成本后至多一次full。旧3536.346s不能自动沿用。新结果NOT_RUN；普通Q/L/整体生产控制停排，M003/M004开放。

REVIEW_LINK；CONTRACT_LINK。

'''
for name, prefix in [('results/review_queue.md', ''), ('results/reviews/SM005.md', '../')]:
    contract_prefix = '../' if not prefix else '../../'
    block = entry.replace('REVIEW_LINK', f'[审核]({prefix}measurement_first_FFN3_review_20261014.md)').replace('CONTRACT_LINK', f'[合同]({contract_prefix}mission/ffn_wi_descriptor_replay_stage_20261014.md)')
    head, tail = before[name].split('\n\n', 1)
    updates[name] = head + '\n\n' + block + tail

sm = before['project/missions/SM005.md']
assert 'revision: 29 / 2026-10-14' in sm
sm = sm.replace('revision: 29 / 2026-10-14', 'revision: 30 / 2026-10-14')
start = sm.index('[FFN2审核]')
end = sm.index('最终任务仍分两层：', start)
sm = sm[:start] + '''[FFN3审核](../../results/measurement_first_FFN3_review_20261014.md)核定AT062真实前缀通过、唯一full在Wi reader配置处语义FAIL；LN/Q/Wi已达，G及后段未到。当前[FFN4](../../mission/ffn_wi_descriptor_replay_stage_20261014.md)只分离Wi DDR与Down STATE1描述符，功能DUT/guard/gold不变；新static与四行reader正反短测后，一次冷前缀和分阶段成本决定至多一次full，普通修正在合同上界内连续执行。新结果NOT_RUN，普通Q/L及整体生产控制停排。''' + sm[end:]
sm = sm.replace('当前FFN3类型感知准备与有据回放按本页最新合同执行', '当前FFN4描述符分离与受影响验证按本页最新合同执行')
updates['project/missions/SM005.md'] = sm

updates['agent/A001/result.md'] = '''# 项目主控与架构评判：最新交付

execution_state: completed
stage: measurement_first_FFN3_semantic_failure_review_FFN4_dispatch

[FFN3审核](../../results/measurement_first_FFN3_review_20261014.md)核定AT062 Wi reader配置语义FAIL，冻结身份及1549路径只读核对完成；LN/Q/Wi已达，不扩大到G/Down/残差。

[FFN4合同](../../mission/ffn_wi_descriptor_replay_stage_20261014.md)选择稳定分离Wi DDR与Down STATE1描述符，保留功能DUT/guard/gold，新static/短测/一次冷前缀与分阶段成本后至多一次full。新结果NOT_RUN，M003/M004开放。

实际送达以[核验回执](../../results/measurement_first_FFN3_review_20261014/delivery_verification.json)为准，不代签工程执行。
'''

chat = before['NEW_CHAT_START.md']
start = chat.index('## 最新工作入口：')
end = chat.index('根目录/home/', start)
chat_current = '''## 最新工作入口：2026-10-14 FFN3语义失败与FFN4描述符分离

先读[当前任务](mission/current.md)、[FFN3审核](results/measurement_first_FFN3_review_20261014.md)、[FFN4合同](mission/ffn_wi_descriptor_replay_stage_20261014.md)。AT062类型感知准备与真实LN冷前缀通过，唯一full到LN/Q/Wi后在271096触发Wi reader cfg Fatal。Wi消费271089、完成标记271090；后段未到，旧失败不回写。1549文件路径核验、336来源引用和262文件/130020393B编译包身份相符。

FFN4只分离Wi DDR与Down STATE1描述符，保留功能DUT/reader校验/观察器/guard/gold；新static、四行reader正反短测、一次冷前缀后以分阶段成本决定唯一full。静态/短测有界修正及host累计120s内连续准备，详细额度以合同为准。旧snapshot不可代表新TB，旧3536秒不自动准入。新结果NOT_RUN，旧局部PASS不拼接；普通Q/L及整体生产控制停排，M003/M004开放。

'''
updates['NEW_CHAT_START.md'] = chat[:start] + chat_current + chat[end:]

(OUT / 'diffs').mkdir(exist_ok=True)
for name, content in updates.items():
    assert (ROOT / name).read_text() == before[name], f'Concurrent edit: {name}'
    (OUT / 'diffs' / (name.replace('/', '__') + '.diff')).write_text(''.join(
        difflib.unified_diff(before[name].splitlines(keepends=True), content.splitlines(keepends=True), fromfile='before/' + name, tofile='after/' + name)))
    (ROOT / name).write_text(content)
record = {'at': datetime.now(timezone.utc).isoformat(), 'updates': [digest(ROOT / p) for p in updates],
          'DUT_changed': False, 'old_attempts_changed': False, 'audit': 'verification.json',
          'SM005_revision': 30}
(OUT / 'controller_record_update_verification.json').write_text(json.dumps(record, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'updated': len(updates), 'preimages': len(before), 'SM005_revision': 30}))
