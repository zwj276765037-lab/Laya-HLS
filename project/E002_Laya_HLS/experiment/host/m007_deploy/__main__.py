"""Runnable explicit CPU contract tail adapter, and honest device availability."""
import argparse
import json
from pathlib import Path

from .backend import XRTBackend
from .contract import Identity, decode_request


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("device-status")
    cpu = sub.add_parser("cpu-contract-tail")
    cpu.add_argument("--request", type=Path, required=True)
    cpu.add_argument("--identity", type=Path, required=True)
    cpu.add_argument("--tail", type=Path, required=True)
    cpu.add_argument("--gguf", type=Path, required=True)
    cpu.add_argument("--output", type=Path, required=True)
    h0 = sub.add_parser("prepare-h0")
    h0.add_argument("--token-ids", type=Path, required=True)
    h0.add_argument("--gguf", type=Path, required=True)
    h0.add_argument("--output", type=Path, required=True)
    frontend = sub.add_parser("frontend-prepare")
    frontend.add_argument("--input", type=Path, required=True)
    frontend.add_argument("--native", type=Path, required=True)
    frontend.add_argument("--gguf", type=Path, required=True)
    frontend.add_argument("--assets", type=Path, required=True)
    frontend.add_argument("--output-dir", type=Path, required=True)
    frontend.add_argument("--request-id", type=int, default=1)
    frontend.add_argument("--generation", type=int, default=1)
    decoder = sub.add_parser("decode-answer")
    decoder.add_argument("--prepared", type=Path, required=True)
    decoder.add_argument("--question-index", type=int, default=0)
    decoder.add_argument("--logits18", type=Path, required=True)
    decoder.add_argument("--native", type=Path, required=True)
    decoder.add_argument("--gguf", type=Path, required=True)
    decoder.add_argument("--assets", type=Path, required=True)
    decoder.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.command == "device-status":
        print(json.dumps({"backend": "device", "status": XRTBackend.status,
                          "reason": XRTBackend.reason}))
        return 3
    if args.command in ("frontend-prepare", "decode-answer"):
        from .frontend import NativeFrontend, prepare_json_requests, decode_prepared
        target = args.output_dir if args.command == "frontend-prepare" else args.output
        work = target.parent / (target.name + ".native")
        with NativeFrontend(args.native, args.gguf, args.assets, work) as native:
            if args.command == "frontend-prepare":
                result = prepare_json_requests(args.input, native, args.output_dir,
                                               args.request_id, args.generation)
                print(json.dumps({"status": result["status"], "questions": len(result["questions"]),
                                  "device": "NOT_RUN", "output": str(args.output_dir)}))
            else:
                result = decode_prepared(args.prepared, args.question_index,
                                          args.logits18.read_bytes(), native)
                args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2,
                                                   allow_nan=False) + "\n")
                print(json.dumps({"status": "BUSINESS_DECODE_COMPLETE", "device": "NOT_RUN",
                                  "output": str(args.output)}))
        return 0
    from .cpu_contract import GGUFWeights, finish_tail_cpu_contract, prepare_h0
    if args.command == "prepare-h0":
        import numpy as np
        raw = args.token_ids.read_bytes()
        if len(raw) != 512:
            raise ValueError("token IDs require exactly 128 little-endian I32 values")
        with GGUFWeights(args.gguf) as weights:
            result = prepare_h0(np.frombuffer(raw, dtype="<i4"), weights)
        args.output.write_bytes(result.tobytes())
        print(json.dumps({"backend": "cpu_contract", "status": "H0_PREPARED",
                          "bytes": result.nbytes, "board": "NOT_RUN"}))
        return 0
    identity = Identity(**json.loads(args.identity.read_text()))
    request = decode_request(args.request.read_bytes(), identity)
    with GGUFWeights(args.gguf) as weights:
        result = finish_tail_cpu_contract(args.tail.read_bytes(), request, weights)
    args.output.write_bytes(result.logits18.tobytes())
    print(json.dumps({"backend": "cpu_contract", "status": "CPU_CONTRACT_COMPLETE",
                      "logits": 18, "board": "NOT_RUN", "output": str(args.output)}))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ValueError, ArithmeticError) as error:
        print(json.dumps({"status": "ERROR", "code": getattr(error, "code", "INPUT_ERROR"),
                          "message": str(error), "device": "NOT_RUN"}), file=__import__("sys").stderr)
        raise SystemExit(2)
