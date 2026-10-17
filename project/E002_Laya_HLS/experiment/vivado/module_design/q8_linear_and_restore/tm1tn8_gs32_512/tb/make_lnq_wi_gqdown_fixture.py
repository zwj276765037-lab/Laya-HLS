#!/usr/bin/env python3
"""Format saved, independently checked row-0 references for the RTL checker.

No arithmetic or expected values are produced here. Source identities are
verified against the research binding before byte-order-only conversion.
"""
import hashlib
import json
import shutil
import struct
import sys
from pathlib import Path


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main(root, out):
    binding = json.loads((root / "source/fixed_graph_support_20261014/wi_gqdown_binding_20261015.json").read_text())
    row = binding["row0"]
    out.mkdir(parents=True)
    old = root / "project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT143_SM004_lnq_wi_prefix_01/fixture"
    down = root / "project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t4_dual_w_fixture_01/work"
    for f in ("wi_config.hex", "model_identity.hex", "expected_aux_header.hex", "aux_header.hex",
              "wi_q0.hex", "wi_q1.hex", "wi_scale.hex", "ln_source_row0.hex", "ln_gold_row0.hex",
              "q_row0.hex", "scale_row0.hex", "ps_row0.hex", "final_row0.hex"):
        shutil.copyfile(old / f, out / f)
    for f in ("down_config.hex", "down_q0.hex", "down_q1.hex", "down_scale.hex"):
        shutil.copyfile(down / f, out / f)

    def checked(name):
        spec = row[name]
        source = (root / spec["path"]).read_bytes()
        data = source[spec["offset"]:spec["offset"] + spec["bytes"]]
        assert len(data) == spec["bytes"] and sha(data) == spec["sha256"], name
        return data

    def words(name, output):
        data = checked(name)
        assert len(data) % 4 == 0
        values = struct.unpack("<" + "I" * (len(data) // 4), data)
        (out / output).write_text("".join(f"{value:08x}\n" for value in values))

    words("g", "g_row0.hex")
    words("down_final", "down_final_row0.hex")
    q = checked("down_q")
    assert len(q) == 82 * 32
    (out / "down_q_row0.hex").write_text("".join(q[g:g + 32][::-1].hex() + "\n" for g in range(0, len(q), 32)))
    scale = checked("down_scale")
    assert len(scale) == 82 * 2
    (out / "down_scale_row0.hex").write_text("".join(f"{int.from_bytes(scale[i:i + 2], 'little'):04x}\n" for i in range(0, len(scale), 2)))
    steps = checked("down_steps")
    assert len(steps) == 82 * 1024 * 6 * 4
    values = struct.unpack("<" + "I" * (len(steps) // 4), steps)
    lines = []
    for g in range(82):
        for tile in range(128):
            ps = [values[((g * 1024 + tile * 8 + l) * 6) + 5] for l in range(8)]
            lines.append("".join(f"{v:08x}" for v in ps[::-1]) + "\n")
    (out / "down_ps_row0.hex").write_text("".join(lines))
    print("GQDOWN_FIXTURE_PASS row0_sha=" + row["down_final"]["sha256"])


if __name__ == "__main__":
    main(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve())
