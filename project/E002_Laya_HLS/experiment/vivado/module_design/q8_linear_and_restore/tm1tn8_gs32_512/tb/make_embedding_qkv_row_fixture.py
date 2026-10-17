#!/usr/bin/env python3
"""Byte-order-only RTL checker inputs from the frozen independent QKV data."""
import hashlib
import json
import shutil
import struct
import sys
from pathlib import Path


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main(root, out):
    binding = json.loads((root / "source/fixed_graph_support_20261014/embedding_qkv_binding_20261015.json").read_text())
    out.mkdir(parents=True, exist_ok=False)
    inputs = {}
    outputs = {}

    def checked(label, spec):
        path = root / spec["path"]
        with path.open("rb") as stream:
            stream.seek(spec.get("offset", 0))
            data = stream.read(spec["bytes"])
        assert len(data) == spec["bytes"] and digest(data) == spec["sha256"], label
        inputs[label] = {"path": spec["path"], "offset": spec.get("offset", 0),
                         "bytes": len(data), "sha256": digest(data)}
        return data

    def emit(label, data, beat):
        assert len(data) % beat == 0, label
        path = out / (label + ".hex")
        path.write_text("".join(f"{int.from_bytes(data[i:i+beat], 'little'):0{beat*2}x}\n"
                                for i in range(0, len(data), beat)))
        outputs[label] = {"bytes": path.stat().st_size, "sha256": digest(path.read_bytes())}

    raw = checked("raw", binding["oracle"]["embedding_raw.f32.bin"])
    norm = checked("norm", binding["oracle"]["embedding_norm.f32.bin"])
    gamma = checked("gamma", binding["gamma_current"])
    source = checked("source_rows4", binding["fixture_products"]["qkv_rows4"]["source_f32"])
    assert norm[:16384] == source and gamma and len(gamma) == 4096
    emit("gamma", gamma, 4)

    products = binding["fixture_products"]["qkv_rows4"]
    aq = checked("a8_q", products["a8_q"])
    scale = checked("a8_scale", products["a8_scale"])
    steps = checked("steps", products["steps_u32x6"])
    final = checked("final", products["output_f32"])
    assert len(aq) == 4*1024 and len(scale) == 4*32*2
    assert len(steps) == 4*32*3072*6*4 and len(final) == 4*3072*4
    words = memoryview(steps).cast("I")
    for row in (0, 1):
        emit(f"raw_row{row}", raw[row*4096:(row+1)*4096], 4)
        emit(f"norm_row{row}", norm[row*4096:(row+1)*4096], 4)
        emit(f"q_row{row}", aq[row*1024:(row+1)*1024], 32)
        emit(f"scale_row{row}", scale[row*64:(row+1)*64], 2)
        emit(f"final_row{row}", final[row*12288:(row+1)*12288], 4)
        stages = [bytearray() for _ in range(6)]
        for g in range(32):
            for tile in range(384):
                for lane in range(8):
                    index = ((row*32+g)*3072+tile*8+lane)*6
                    for step in range(6):
                        stages[step].extend(struct.pack("<I", words[index+step]))
        assert stages[5][-12288:] == final[row*12288:(row+1)*12288]
        for step in range(5):
            emit(f"step{step}_row{row}", stages[step], 32)
        emit(f"ps_row{row}", stages[5], 32)

    for role, out_name in (("q0", "w_q0"), ("q1", "w_q1"),
                           ("w_scale", "w_scale")):
        data = checked(role, binding["model_windows"][role]["current"])
        assert data == checked(role+"_independent", products[role])
        emit(out_name, data, 64)
    previous = root / "project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT173_SM004_residual_combined_recovery_01/fixture"
    for name in ("model_identity.hex", "expected_aux_header.hex", "aux_header.hex"):
        shutil.copyfile(previous / name, out / name)
        outputs[name] = {"bytes": (out / name).stat().st_size,
                         "sha256": digest((out / name).read_bytes())}
    (out / "manifest.json").write_text(json.dumps({"schema": "rev12_qkv_saved_checker_v1",
        "scope": "row0_row1_saved_independent_reference_byte_order_only",
        "binding": digest((root / "source/fixed_graph_support_20261014/embedding_qkv_binding_20261015.json").read_bytes()),
        "inputs": inputs, "outputs": outputs}, indent=2) + "\n")
    print("QKV_ROW_FIXTURE_PASS rows=2 groups=32 tiles=384 saved_reference_only=1")


if __name__ == "__main__":
    main(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve())
