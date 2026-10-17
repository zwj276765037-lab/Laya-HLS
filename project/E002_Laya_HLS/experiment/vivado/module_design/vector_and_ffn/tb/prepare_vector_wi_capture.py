#!/usr/bin/env python3
"""Prepare read-only request-3 enc0 Wi observation in the existing CPU path."""

import argparse
import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[4]
CONTROLLER = ROOT / "hls/control/full_forward_controller.cpp"
TB = (ROOT / "results/cpu_embedding_q8_validation_20261010/tools/"
      "persistent_cpu_full_csim_tb.cpp")


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def once(text, old, new, label):
    if text.count(old) != 1:
        raise RuntimeError(f"{label}: expected one exact anchor")
    return text.replace(old, new, 1)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    output = args.out.resolve()
    output.mkdir(parents=True, exist_ok=False)
    controller = once(CONTROLLER.read_text(),
        """      c = linear(Op::LIN_WI, {3, layer}, normalized, 2, layer,
                 fresh(Buffer::WI), 0, wide);
      if (!c) return c;
      c = full_release_owner(rt, normalized);""",
        """      c = linear(Op::LIN_WI, {3, layer}, normalized, 2, layer,
                 fresh(Buffer::WI), 0, wide);
      if (!c) return c;
      if (layer == 0) checkpoint("vector_enc0_wi_output", wide);
      c = full_release_owner(rt, normalized);""", "Wi producer callback")
    tb = once(TB.read_text(),
        """  const std::string label(name ? name : "");
  require(!label.empty() && obs.names.insert(label).second,
          "unique checkpoint " + label);""",
        """  const std::string label(name ? name : "");
  if (label == "vector_enc0_wi_output") {
    if (rt.inputs.identity.request_id == 3) {
      require(rt.inputs.identity.generation == 1 &&
              rt.inputs.identity.B == 1 && rt.inputs.identity.S == 128 &&
              space == RowSpace::TOKEN && width == 5248 && region == 0 &&
              ref.id == Buffer::WI,
              "vector Wi producer identity/shape");
      Address address;
      Check c = laya::full::full_f32_address(rt, ref, 0, 0, 0, 0, address);
      require(bool(c), "vector Wi producer address");
      std::vector<uint8_t> actual(5248u * 4u);
      c = laya::full::full_read(rt.memory, address.bo, address.offset,
                               actual.data(), uint32_t(actual.size()));
      require(bool(c), "vector Wi producer read");
      const fs::path directory(env_required("LAYA_VECTOR_CAPTURE_ROOT"));
      fs::create_directories(directory);
      const fs::path path = directory / "vector_enc0_wi_row0.f32.bin";
      require(!fs::exists(path), "vector Wi unique read-only capture");
      std::ofstream stream(path, std::ios::binary | std::ios::trunc);
      require(bool(stream), "vector Wi capture open");
      stream.write(reinterpret_cast<const char*>(actual.data()),
                   std::streamsize(actual.size()));
      require(bool(stream), "vector Wi capture complete");
      std::cout << "VECTOR_WI_CAPTURE request=3 generation=1 B=1 S=128"
                << " stage=2 layer=0 row=0 width=5248 bytes="
                << actual.size() << '\\n' << std::flush;
    }
    return;
  }
  require(!label.empty() && obs.names.insert(label).second,
          "unique checkpoint " + label);""", "Wi observation callback")
    generated = {
        "full_forward_controller_vector_capture.cpp": controller,
        "persistent_cpu_full_csim_vector_capture_tb.cpp": tb,
    }
    for name, contents in generated.items():
        (output / name).write_text(contents)
    (output / "source_manifest.json").write_text(json.dumps({
        "schema": "laya-vector-wi-read-only-capture-sources-v1",
        "scope": "current v4 request3 enc0 Wi output row0, observation only; execution NOT_RUN",
        "original_sources": {str(CONTROLLER): sha(CONTROLLER), str(TB): sha(TB)},
        "generated_sources": {str(output / name): sha(output / name)
                              for name in generated},
        "generator": {str(Path(__file__).resolve()): sha(Path(__file__))},
    }, indent=2, sort_keys=True) + "\n")
    print("VECTOR_WI_CAPTURE_PREPARED actual_run=NOT_RUN")


if __name__ == "__main__":
    main()
