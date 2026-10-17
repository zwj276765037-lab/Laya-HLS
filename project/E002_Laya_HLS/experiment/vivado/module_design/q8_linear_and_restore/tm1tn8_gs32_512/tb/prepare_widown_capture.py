#!/usr/bin/env python3
"""Prepare an observation-only copy of current v4 CPU producer sources.

The original controller and persistent CSim testbench remain untouched. The
copied controller adds two layer-0 callbacks; the copied testbench dumps their
actual BO contents for request 3 while retaining its 47-checkpoint comparison.
Compilation and execution require the separately scheduled heavy-tool window.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def once(source: str, old: str, new: str, label: str) -> str:
    if source.count(old) != 1:
        raise RuntimeError(f"{label}: expected one exact source anchor")
    return source.replace(old, new, 1)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("root", type=Path)
    ap.add_argument("output", type=Path)
    args = ap.parse_args()
    root, output = args.root.resolve(), args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)

    controller_path = root / "hls/control/full_forward_controller.cpp"
    tb_path = (root / "results/cpu_embedding_q8_validation_20261010/tools/"
               "persistent_cpu_full_csim_tb.cpp")
    controller = controller_path.read_text()
    controller = once(controller,
        """      c = norm(Op::LN_FFN, hidden, 2, layer,
               fresh(Buffer::NORM), 0, 0, normalized);
      if (!c) return c;
      FullOwnerSpec wide;""",
        """      c = norm(Op::LN_FFN, hidden, 2, layer,
               fresh(Buffer::NORM), 0, 0, normalized);
      if (!c) return c;
      if (layer == 0) checkpoint("t2_enc0_ln_ffn_source", normalized);
      FullOwnerSpec wide;""", "LN_FFN layer-0 capture")
    controller = once(controller,
        """      c = vector(Op::GEGLU, wide, 2, layer,
                 fresh(Buffer::GATE), 0, 2624, gated);
      if (!c) return c;
      c = full_release_owner(rt, wide);""",
        """      c = vector(Op::GEGLU, wide, 2, layer,
                 fresh(Buffer::GATE), 0, 2624, gated);
      if (!c) return c;
      if (layer == 0) checkpoint("t2_enc0_geglu_source", gated);
      c = full_release_owner(rt, wide);""", "GEGLU layer-0 capture")
    controller = once(controller,
        """      if (c) c = full_commit_qkv_rope_pair(rt, final);
      if (!c) return c;
    }
    output = matrix(fresh(Buffer::ATT_OUT), 0, stage, layer,""",
        """      if (c) c = full_commit_qkv_rope_pair(rt, final);
      if (!c) return c;
    }
    if (stage == 2 && layer == 0)
      checkpoint("t2_enc0_v_head0_source", final[0]);
    output = matrix(fresh(Buffer::ATT_OUT), 0, stage, layer,""",
        "Encoder layer-0 head-0 V capture")

    tb = tb_path.read_text()
    tb = once(tb, '#include "laya_full_runtime.h"\n',
              '#include "laya_full_runtime.h"\n#include "laya_memory_map.h"\n',
              "QKV address declaration")
    anchor = """  const std::string label(name ? name : "");
  require(!label.empty() && obs.names.insert(label).second,
          "unique checkpoint " + label);"""
    replacement = """  const std::string label(name ? name : "");
  if (label == "t2_enc0_v_head0_source") {
    if (rt.inputs.identity.request_id == 3) {
      require(rt.inputs.identity.generation == 1 &&
              rt.inputs.identity.B == 1 && rt.inputs.identity.S == 128 &&
              space == RowSpace::TOKEN && width == 64 && region == 0 &&
              ref == rt.final_qkv_ref[0] && ref.id == Buffer::QKV &&
              ref.bank == 0,
              "T2 V producer source identity/shape");
      const fs::path directory(env_required("LAYA_T2_CAPTURE_ROOT"));
      fs::create_directories(directory);
      std::vector<uint8_t> actual(size_t(128) * 64 * 4);
      for (unsigned row = 0; row < 128; ++row)
        for (unsigned d = 0; d < 64; ++d) {
          Address address;
          Check c = laya::qkv_address(2, 0, 0, uint16_t(row), uint8_t(d),
                                     1, 128, address);
          require(bool(c), "T2 V producer address");
          c = laya::full::full_read(rt.memory, address.bo, address.offset,
                                   actual.data() + (size_t(row) * 64 + d) * 4,
                                   4);
          require(bool(c), "T2 V producer read");
        }
      const fs::path path = directory / "t2_enc0_v_head0_source.f32.bin";
      require(!fs::exists(path), "T2 unique V source capture");
      std::ofstream stream(path, std::ios::binary | std::ios::trunc);
      require(bool(stream), "T2 V source output open");
      stream.write(reinterpret_cast<const char*>(actual.data()),
                   std::streamsize(actual.size()));
      require(bool(stream), "T2 V source output complete");
      std::cout << "T2_PRODUCER_CAPTURE name=t2_enc0_v_head0_source"
                << " request=3 generation=1 rows=128 width=64 plane=V head=0"
                << " bytes=" << actual.size() << '\\n' << std::flush;
    }
    return;
  }
  if (label == "t2_enc0_ln_ffn_source" ||
      label == "t2_enc0_geglu_source") {
    if (rt.inputs.identity.request_id == 3) {
      require(rt.inputs.identity.generation == 1 &&
              rt.inputs.identity.B == 1 && rt.inputs.identity.S == 128 &&
              space == RowSpace::TOKEN &&
              width == (label == "t2_enc0_ln_ffn_source" ? 1024 : 2624),
              "T2 producer source identity/shape " + label);
      const fs::path directory(env_required("LAYA_T2_CAPTURE_ROOT"));
      fs::create_directories(directory);
      std::vector<uint8_t> actual(size_t(128) * width * 4);
      for (unsigned row = 0; row < 128; ++row) {
        Address address;
        Check c = laya::full::full_f32_address(
            rt, ref, region, 0, uint16_t(row), 0, address);
        require(bool(c), "T2 producer address " + label);
        c = laya::full::full_read(rt.memory, address.bo, address.offset,
                                 actual.data() + size_t(row) * width * 4,
                                 uint32_t(width * 4));
        require(bool(c), "T2 producer read " + label);
      }
      const fs::path path = directory / (label + ".f32.bin");
      require(!fs::exists(path), "T2 unique source capture " + label);
      std::ofstream stream(path, std::ios::binary | std::ios::trunc);
      require(bool(stream), "T2 source output open " + label);
      stream.write(reinterpret_cast<const char*>(actual.data()),
                   std::streamsize(actual.size()));
      require(bool(stream), "T2 source output complete " + label);
      std::cout << "T2_PRODUCER_CAPTURE name=" << label
                << " request=3 generation=1 rows=128 width=" << width
                << " bytes=" << actual.size() << '\\n' << std::flush;
    }
    return;
  }
  require(!label.empty() && obs.names.insert(label).second,
          "unique checkpoint " + label);"""
    tb = once(tb, anchor, replacement, "observation callback")
    controller_out = output / "full_forward_controller_t2_capture.cpp"
    tb_out = output / "persistent_cpu_full_csim_t2_capture_tb.cpp"
    controller_out.write_text(controller)
    tb_out.write_text(tb)
    manifest = {
        "schema": "t2_widown_av_observation_sources_v2",
        "purpose": "request3 B1 current producer V head0, LN_FFN and GEGLU inputs",
        "original_sources": {str(controller_path): sha(controller_path),
                             str(tb_path): sha(tb_path)},
        "generated_sources": {str(controller_out): sha(controller_out),
                              str(tb_out): sha(tb_out)},
        "generator": {"path": str(Path(__file__).resolve()),
                      "sha256": sha(Path(__file__))},
        "numeric_gold_role": "none; only actual source BO observation",
    }
    (output / "source_manifest.json").write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    print("T2_WIDOWN_CAPTURE_SOURCES_PREPARED")


if __name__ == "__main__":
    main()
