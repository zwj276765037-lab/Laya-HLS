#!/usr/bin/env python3
"""User-authorized two-hour follow-up in the existing D38 controller chat."""
import argparse
import fcntl
import json
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
THREAD = "01a129af-0395-7fd0-95ac-edd54873bd5f"
EXPECTED_CWD = "/home/user/EDA-202/zhuowenjun"
RUN = ROOT / "project/E022_m007_full_top_physical/experiment_results/runs/R001"
sys.path.insert(0, "/home/zwj/.codex/skills/research-agent/scripts")
from codex_rpc import CodexRpc


def write_json(path, value):
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n")
    temporary.replace(path)


def read_status():
    status = json.loads((RUN / "current_status.json").read_text())
    attempt = Path(status.get("attempt", "")).resolve()
    if not attempt.is_relative_to((RUN / "attempts").resolve()):
        raise RuntimeError("Current attempt is outside the authorized physical run")
    samples = sorted((p for p in attempt.glob("**/live_status.json") if p.parent.name != "observer"), key=lambda p: p.stat().st_mtime, reverse=True)
    sample = None
    if samples:
        latest = samples[0]
        sample = {"path": str(latest), "mtime_utc": datetime.fromtimestamp(latest.stat().st_mtime, timezone.utc).isoformat(), "data": json.loads(latest.read_text())}
        # Raw process lists can be large; the controller reads them when needed.
        if isinstance(sample["data"], dict):
            for key in list(sample["data"]):
                if isinstance(sample["data"][key], (list, dict)):
                    sample["data"].pop(key)
    return {"current_status": status, "latest_sample": sample}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="Verify destination without sending")
    parser.add_argument("--delivery-test", action="store_true")
    args = parser.parse_args()
    with (HERE / "tick.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        config = json.loads((HERE / "config.json").read_text())
        if not config.get("enabled"):
            print("Reporting disabled by controller")
            return
        if config.get("thread_id") != THREAD or config.get("project_root") != str(ROOT):
            raise RuntimeError("Reporting destination mismatch")
        snapshot = read_status()
        now = datetime.now(timezone.utc).isoformat()
        event_id = str(uuid.uuid4())
        receipt = {"utc": now, "event_id": event_id, "thread_id": THREAD, "kind": "check" if args.check else "delivery_test" if args.delivery_test else "two_hour_report", "snapshot": snapshot}
        receipts = HERE / "receipts"
        receipts.mkdir(exist_ok=True)
        destination = receipts / (datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S") + "_" + event_id + ".json")
        try:
            with CodexRpc(timeout=30) as rpc:
                resumed = rpc.request("thread/resume", {"threadId": THREAD, "excludeTurns": True})
                thread = resumed.get("thread", {})
                if thread.get("id") != THREAD or thread.get("cwd") != EXPECTED_CWD:
                    raise RuntimeError("Resumed controller identity/cwd mismatch")
                receipt["destination_verified"] = True
                if args.check:
                    receipt["status"] = "DESTINATION_VERIFIED_NO_MESSAGE_SENT"
                else:
                    label = "定时回报送达自检" if args.delivery_test else "两小时定时进度回报"
                    message = (
                        f"[Laya-HLS D38 {label}]\n"
                        "来源：本主控按用户2026-10-26‘延长上限到无限时间 每两小时汇报一次 请开始’配置的服务器定时器。"
                        "这是既有授权的定时触发，不是新的人类授权或其他角色消息。\n"
                        f"项目：{ROOT}\n触发UTC：{now}\n"
                        "请核最新真实进程/监督状态及原始日志，向用户简要汇报当前阶段、已用时间、内存、实质进展、DCP/资源/时序结果。"
                        "用户明确要求周期回报，即使没有阶段变化也应汇报；不要把旧采样当运行。"
                        "保持原Vivado和单重工具，已完成阶段需协调现有A010接续原授权步骤，不重复启动或重跑功能验证。"
                        "最新用户暂停/取消优先；不得由本触发恢复已暂停工程。"
                        "最终物理阶段收尾或用户要求停止后，将本目录config.json的enabled设false并停止laya-d38-progress.timer。\n"
                        + ("本次是送达自检，请在当前回复合并确认；正式回报每7200秒触发。\n" if args.delivery_test else "")
                        + "以下为触发时只读快照，需核新鲜度：\n"
                        + json.dumps(snapshot, ensure_ascii=False)
                    )
                    result = rpc.request("turn/start", {"threadId": THREAD, "clientUserMessageId": event_id, "input": [{"type": "text", "text": message}]})
                    turn_id = result.get("turn", {}).get("id")
                    if not turn_id:
                        raise RuntimeError("No accepted turn ID; delivery not confirmed")
                    receipt.update(status="ACCEPTED_BY_CONTROLLER_THREAD", accepted_turn_id=turn_id, response_completed=False)
        except Exception as error:
            receipt.update(status="DELIVERY_UNCONFIRMED", error=str(error), uncertain=bool(getattr(error, "uncertain", False)))
            write_json(destination, receipt)
            write_json(HERE / "last_receipt.json", receipt)
            raise
        write_json(destination, receipt)
        write_json(HERE / "last_receipt.json", receipt)
        print(json.dumps({key: receipt[key] for key in ("utc", "status", "thread_id", "kind")}, ensure_ascii=False))


if __name__ == "__main__":
    main()
