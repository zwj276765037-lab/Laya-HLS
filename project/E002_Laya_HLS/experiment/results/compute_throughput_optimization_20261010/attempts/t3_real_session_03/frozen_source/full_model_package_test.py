#!/usr/bin/env python3
"""Independent P2 B GGUF-to-BO verification, including all 153 tensors."""

from __future__ import annotations

import hashlib
import json
import mmap
import pathlib
import struct
import sys
import traceback

import numpy as np

from full_fixture_test import INVENTORY_SHA, MODEL_SHA, file_sha, sha


GRAPH_SHA = "f33f7848434b73048f957dcd232e1bd4ff99e95b8cf41c98191b69fddad815f9"
BO_NAMES = ("embedding", "w_q0", "w_q1", "w_scale", "aux")
TYPE_WIDTH = {0: 4, 1: 2}


def require(ok: bool, message: str) -> None:
    if not ok:
        raise AssertionError(message)


class Cursor:
    def __init__(self, data: mmap.mmap) -> None:
        self.data, self.at = data, 0

    def take(self, count: int) -> bytes:
        require(0 <= count <= len(self.data) - self.at, "GGUF metadata bounds")
        out = self.data[self.at : self.at + count]
        self.at += count
        return out

    def unpack(self, fmt: str) -> int:
        return struct.unpack("<" + fmt, self.take(struct.calcsize("<" + fmt)))[0]

    def string(self) -> bytes:
        return self.take(self.unpack("Q"))

    def value(self, kind: int) -> bytes | None:
        scalar_size = {0: 1, 1: 1, 2: 2, 3: 2, 4: 4, 5: 4,
                       6: 4, 7: 1, 10: 8, 11: 8, 12: 8}
        if kind == 8:
            return self.string()
        if kind == 9:
            member_kind, count = self.unpack("I"), self.unpack("Q")
            if member_kind in scalar_size:
                self.take(count * scalar_size[member_kind])
            else:
                for _ in range(count):
                    self.value(member_kind)
            return None
        require(kind in scalar_size, f"GGUF metadata type {kind}")
        self.take(scalar_size[kind])
        return None


def gguf_inventory_and_graph(model: mmap.mmap) -> tuple[list[dict], bytes, int]:
    cursor = Cursor(model)
    require(cursor.take(4) == b"GGUF" and cursor.unpack("I") == 3,
            "GGUF magic/version")
    count, metadata_count = cursor.unpack("Q"), cursor.unpack("Q")
    require(count == 153, "GGUF tensor count")
    graph = None
    alignment = 32
    for _ in range(metadata_count):
        key = cursor.string().decode("utf-8")
        kind = cursor.unpack("I")
        value = cursor.value(kind)
        if key == "ggmlc.graph_spec":
            require(kind == 8 and value is not None, "graph_spec string")
            graph = value
        if key == "general.alignment":
            # This model uses the documented default 32B alignment. Its
            # integer metadata value can be re-read from the raw field only
            # through cursor state, so independently require the inventory's
            # computed data offset below as the final guard.
            require(kind in (4, 10), "GGUF alignment type")
    tensors = []
    for _ in range(count):
        name = cursor.string().decode("utf-8")
        dimensions = [cursor.unpack("Q") for _ in range(cursor.unpack("I"))]
        kind, relative = cursor.unpack("I"), cursor.unpack("Q")
        tensors.append({"name": name, "ggml_ne": dimensions,
                        "ggml_type_id": kind, "relative_data_offset": relative})
    data_offset = (cursor.at + alignment - 1) // alignment * alignment
    for tensor in tensors:
        tensor["absolute_file_offset"] = data_offset + tensor["relative_data_offset"]
    require(graph is not None and sha(graph) == GRAPH_SHA, "frozen graph_spec SHA")
    return tensors, graph, data_offset


def source_size(entry: dict) -> int:
    shape = entry["ggml_ne"]
    count = int(np.prod(shape, dtype=np.int64))
    kind = entry["ggml_type_id"]
    if kind == 8:
        require(shape[0] % 32 == 0, "Q8 group width")
        return count // 32 * 34
    require(kind in TYPE_WIDTH, f"source tensor type {kind}")
    return count * TYPE_WIDTH[kind]


def expected_bindings() -> dict[str, tuple[int, int, str, str | None]]:
    result = {}
    for layer in range(28):
        for family, stem in ((1, "qkv"), (2, "wo"),
                             (3, "mlp_wi"), (4, "mlp_wo")):
            result[f"{stem}.{layer}.weight"] = (family, layer, "Q8_0", None)
    for layer in range(2):
        for family, stem in ((5, "head_qkv"), (6, "head_wo"),
                             (7, "head_fc1"), (8, "head_fc2")):
            result[f"{stem}.{layer}.weight"] = (
                family, layer, "Q8_0", f"{stem}.{layer}.bias")
    result["scorer_fc1.weight"] = (9, 255, "Q8_0", "linear_120_baked_bias")
    result["scorer_fc2.weight"] = (10, 255, "F32", "scorer_fc2.bias")
    result["act_fc1.weight"] = (11, 255, "F16", None)
    result["act_fc2.weight"] = (12, 255, "Q8_0", "act_fc2.bias")
    require(len(result) == 124, "binding table definition")
    return result


def checked_span(spans: dict[str, list[tuple[int, int, str]]], bo: dict,
                 name: str, base: int, size: int, label: str) -> bytes:
    require(name in bo and base >= 0 and size >= 0 and base + size <= len(bo[name]),
            f"BO bounds {label}")
    require(base % 64 == 0, f"64B tensor base {label}")
    spans[name].append((base, base + size, label))
    # A byte copy keeps NumPy's temporary views independent of the mmap.
    # On a failed assertion Python retains the traceback frame until the
    # caller handles it, so exported mmap views would mask the real first
    # failure with BufferError during cleanup.
    return bo[name][base : base + size]


def verify_q8_matrix(entry: dict, descriptor: dict, source: bytes,
                     bo: dict, spans: dict) -> str:
    K, N = entry["ggml_ne"][:2]
    require(descriptor["K"] == K and descriptor["N"] == N, "Q8 K/N binding")
    G = K // 32
    tiles = (N + 7) // 8
    qbase = descriptor["q_base"]
    qspan = descriptor["q_span"]
    require(len(qbase) == len(qspan) == 2, "Q8 two shard fields")
    expected_qspan = [((tiles + 1 - shard) // 2) * G * 8 * 32
                      for shard in range(2)]
    require([int(v) for v in qspan] == expected_qspan,
            "Q8 shard capacities")
    qviews = []
    for shard, bo_name in enumerate(("w_q0", "w_q1")):
        if qspan[shard] == 0:
            require(int(qbase[shard]) == 0, "empty Q8 shard base")
            qviews.append(None)
        else:
            raw = checked_span(spans, bo, bo_name, int(qbase[shard]),
                               int(qspan[shard]), entry["name"] + f":q{shard}")
            qviews.append(np.frombuffer(raw, dtype=np.uint8).reshape(
                expected_qspan[shard] // (G * 8 * 32), G, 8, 32))
    scale_base = int(descriptor["scale_base"])
    scale_span = int(descriptor["scale_span"])
    require(scale_span == tiles * G * 8 * 2, "Q8 scale capacity")
    scale_raw = checked_span(spans, bo, "w_scale", scale_base,
                             scale_span, entry["name"] + ":scale")
    scale_view = np.frombuffer(scale_raw, dtype=np.uint8).reshape(tiles, G, 8, 2)
    original = np.frombuffer(source, dtype=np.uint8).reshape(N, G, 34)
    restored = np.empty_like(original)
    for tile in range(tiles):
        shard, local_tile = tile % 2, tile // 2
        columns = min(8, N - tile * 8)
        expected_q = np.zeros((G, 8, 32), dtype=np.uint8)
        expected_s = np.zeros((G, 8, 2), dtype=np.uint8)
        expected_q[:, :columns, :] = original[tile*8 : tile*8+columns, :, 2:].transpose(1, 0, 2)
        expected_s[:, :columns, :] = original[tile*8 : tile*8+columns, :, :2].transpose(1, 0, 2)
        require(np.array_equal(qviews[shard][local_tile], expected_q),
                f"Q8 q scatter/padded lanes {entry['name']} tile{tile}")
        require(np.array_equal(scale_view[tile], expected_s),
                f"Q8 scale scatter/padded lanes {entry['name']} tile{tile}")
        restored[tile*8 : tile*8+columns, :, :2] = scale_view[tile, :, :columns, :].transpose(1, 0, 2)
        restored[tile*8 : tile*8+columns, :, 2:] = qviews[shard][local_tile, :, :columns, :].transpose(1, 0, 2)
    inverse_sha = sha(restored.tobytes())
    require(inverse_sha == sha(source), f"Q8 inverse source SHA {entry['name']}")
    return inverse_sha


def verify_slide_bias(raw: bytes) -> None:
    require(len(raw) == 1025 * 1025 * 4, "slide_bias span")
    actual = np.frombuffer(raw, dtype="<u4").reshape(1025, 1025)
    index = np.arange(1025)
    expected = np.where(np.abs(index[:, None] - index[None, :]) <= 64,
                        np.float32(0), np.float32(-10000)).astype("<f4")
    require(np.array_equal(actual, expected.view("<u4")),
            "every omitted slide_bias element")


def verify_padding(bo: dict, spans: dict) -> dict:
    result = {}
    for name, data in bo.items():
        intervals = sorted(spans[name])
        cursor = 0
        padding = 0
        for start, end, label in intervals:
            require(start >= cursor, f"BO overlap {name}:{label}")
            gap = data[cursor:start]
            require(not any(gap), f"BO nonzero padding {name} before {label}")
            padding += len(gap)
            cursor = end
        gap = data[cursor:]
        require(not any(gap), f"BO nonzero trailing padding {name}")
        result[name] = {"objects": len(intervals), "zero_padding_bytes": padding + len(gap)}
    return result


def verify(root: pathlib.Path, package: pathlib.Path,
           strict_current_sources: bool = False) -> dict:
    manifest_file = package / "manifest.json"
    manifest = json.loads(manifest_file.read_text())
    require(manifest["schema"] == "laya-model-p2-v1", "export manifest schema")
    inventory_file = root / "reference/runs/typed_q8_ref_20261005/gguf_inventory.json"
    require(file_sha(inventory_file) == INVENTORY_SHA, "frozen inventory SHA")
    inventory = json.loads(inventory_file.read_text())
    source_model = manifest["source_model"]
    model_file = pathlib.Path(source_model["path"])
    require(model_file.stat().st_size == 455179648 and
            file_sha(model_file) == MODEL_SHA and
            source_model["size"] == 455179648 and
            source_model["sha256"] == MODEL_SHA and
            source_model["graph_spec_sha256"] == GRAPH_SHA,
            "source model pinned identity")
    model_handle = model_file.open("rb")
    model = mmap.mmap(model_handle.fileno(), 0, access=mmap.ACCESS_READ)
    bo_handles, bo = {}, {}
    try:
        parsed, graph, data_offset = gguf_inventory_and_graph(model)
        require(parsed == inventory["tensors"] and
                data_offset == inventory["data_offset"],
                "independent GGUF header/inventory parse")
        graph_json = json.loads(graph)
        require(len(graph_json["nodes"]) == 1364 and
                len(graph_json["parameters"]) == 153 and
                len(graph_json["inputs"]) == 5 and
                len(graph_json["outputs"]) == 2,
                "real graph topology identity")
        for name in BO_NAMES:
            info = manifest["bo"][name]
            path = package / info["file"]
            require(file_sha(path) == info["sha256"] and
                    path.stat().st_size == info["size"],
                    f"BO {name} actual size/SHA")
            bo_handles[name] = path.open("rb")
            bo[name] = mmap.mmap(bo_handles[name].fileno(), 0, access=mmap.ACCESS_READ)
        spans: dict[str, list[tuple[int, int, str]]] = {name: [] for name in BO_NAMES}
        aux_header = bo["aux"][:128]
        require(len(aux_header) == 128 and aux_header[:4] == b"LYMP" and
                struct.unpack_from("<HHIII", aux_header, 4) == (1, 0, 128, 13, 1) and
                aux_header[20:32] == bytes(12), "aux header fixed fields")
        spans["aux"].append((0, 128, "model_header"))
        tags = manifest["tags"]
        preimages = manifest["tag_preimages"]
        parsed_preimages: dict[str, dict] = {}
        for key in ("numeric", "layout", "build"):
            item = preimages[key]
            path = package / item["file"]
            raw = path.read_bytes()
            digest = sha(raw)
            require(digest == item["sha256"] and
                    bytes.fromhex(tags[key]) == bytes.fromhex(digest)[:16],
                    f"{key} saved preimage/digest")
            if key in ("layout", "build"):
                parsed_preimage = json.loads(raw)
                canonical = (json.dumps(parsed_preimage, sort_keys=True,
                                        separators=(",", ":"),
                                        ensure_ascii=False) + "\n").encode("utf-8")
                require(raw == canonical, f"{key} canonical JSON preimage")
                parsed_preimages[key] = parsed_preimage
        task = (root / "hardware_agent/task.md").read_text(encoding="utf-8")
        start = task.index("### 12.2 ")
        end = task.index("### 12.3 ", start)
        require((package / preimages["numeric"]["file"]).read_bytes() ==
                task[start:end].encode("utf-8"),
                "numeric tag exact frozen section 12.2 UTF-8")
        require(tags["model"] == MODEL_SHA[:32], "model tag derivation")
        layout = parsed_preimages["layout"]
        require(layout["schema"] == "laya-layout-v1" and
                layout["source_model_sha256"] == MODEL_SHA and
                layout["tensors"] == manifest["tensors"] and
                layout["weights"] == manifest["weights"] and
                layout["bo_sizes"] == {name: manifest["bo"][name]["size"]
                                       for name in BO_NAMES},
                "layout preimage semantic binding")
        build = parsed_preimages["build"]
        require(build["schema"] == "laya-build-v1" and
                build["model_sha256"] == MODEL_SHA and
                build["numeric_sha256"] == preimages["numeric"]["sha256"] and
                build["layout_sha256"] == preimages["layout"]["sha256"],
                "build preimage model/numeric/layout binding")
        source_hashes = build["sources"]
        require(source_hashes and len({item["path"] for item in source_hashes}) ==
                len(source_hashes), "build source inventory unique/nonempty")
        stale_sources = []
        for item in source_hashes:
            relative = pathlib.PurePosixPath(item["path"])
            require(not relative.is_absolute() and ".." not in relative.parts and
                    len(item["sha256"]) == 64, "build source path/SHA format")
            path = root / relative
            actual = file_sha(path) if path.is_file() else None
            if actual != item["sha256"]:
                stale_sources.append({"path": item["path"],
                                      "recorded_sha256": item["sha256"],
                                      "current_sha256": actual})
        if strict_current_sources:
            require(not stale_sources, "build preimage contains stale source hashes")
        for start, key in ((32, "model"), (48, "numeric"),
                           (64, "layout"), (80, "build")):
            digest = bytes.fromhex(tags[key])
            require(len(digest) == 16 and digest != bytes(16) and
                    aux_header[start:start+16] == digest,
                    f"aux header {key} tag")
        require(aux_header[96:128] == bytes.fromhex(MODEL_SHA),
                "aux header complete model SHA")

        original = {item["name"]: item for item in inventory["tensors"]}
        exported = {item["name"]: item for item in manifest["tensors"]}
        require(len(exported) == len(original) == len(manifest["tensors"]) == 153 and
                set(exported) == set(original), "exact 153 exported tensor entries")
        bindings = {item["name"]: item for item in manifest["weights"]}
        expected = expected_bindings()
        require(len(bindings) == len(manifest["weights"]) == 124 and
                set(bindings) == set(expected), "all 124 frozen WeightKeys")
        require(len({(int(v["family"]), int(v["layer"])) for v in bindings.values()}) == 124,
                "no duplicate WeightKey")
        payload_total = 0
        restored_count = 0
        for name, src in original.items():
            length = source_size(src)
            offset = src["absolute_file_offset"]
            require(offset + length <= len(model), f"GGUF source bounds {name}")
            data = model[offset : offset + length]
            payload_total += length
            desc = exported[name]
            require(desc["ggml_type_id"] == src["ggml_type_id"] and
                    desc["ggml_ne"] == src["ggml_ne"] and
                    desc["source_offset"] == offset and
                    desc["source_bytes"] == length and
                    desc["source_sha256"] == sha(data),
                    f"source tensor metadata/SHA {name}")
            if name == "slide_bias":
                require(desc["omitted"] is True and desc.get("omission_rule"),
                        "only permitted omission")
                verify_slide_bias(data)
                continue
            require(desc["omitted"] is False and
                    desc["restored_sha256"] == sha(data),
                    f"restored source hash {name}")
            if name in bindings and src["ggml_type_id"] == 8:
                inverse_sha = verify_q8_matrix(src, bindings[name], data, bo, spans)
                require(inverse_sha == desc["restored_sha256"],
                        f"inverse Q8 tensor hash {name}")
            else:
                bo_name = desc["bo"]
                require(bo_name in ("embedding", "aux"),
                        f"nonmatrix tensor BO {name}")
                base, span = int(desc["base"]), int(desc["span"])
                require(span == length, f"nonmatrix payload span {name}")
                actual = checked_span(spans, bo, bo_name, base, span, name)
                require(actual == data, f"nonmatrix byte identity {name}")
                del actual
            restored_count += 1
        require(payload_total == 453123852 and restored_count == 152,
                "total source/retained payload bytes and count")

        for name, descriptor in bindings.items():
            family, layer, dtype, bias_name = expected[name]
            src = original[name]
            require((descriptor["family"], descriptor["layer"]) == (family, layer) and
                    descriptor["K"] == src["ggml_ne"][0] and
                    descriptor["N"] == src["ggml_ne"][1] and
                    (descriptor["bias_name"] or None) == bias_name and
                    descriptor["source_sha256"] == exported[name]["source_sha256"],
                    f"frozen WeightKey binding {name}")
            # The manifest records the GGUF numeric type ID, which must agree
            # with the independently parsed source metadata and WeightKey.
            require(src["ggml_type_id"] == {"Q8_0": 8, "F32": 0, "F16": 1}[dtype],
                    f"WeightKey datatype {name}")
            require(int(descriptor["dtype"]) == src["ggml_type_id"],
                    f"descriptor datatype {name}")
            tensor = exported[name]
            if src["ggml_type_id"] in (0, 1):
                require(tensor["bo"] == "aux" and
                        int(descriptor["aux_base"]) == int(tensor["base"]) and
                        int(descriptor["aux_span"]) == int(tensor["span"]) and
                        descriptor["q_base"] == [0, 0] and
                        descriptor["q_span"] == [0, 0] and
                        int(descriptor["scale_base"]) == 0 and
                        int(descriptor["scale_span"]) == 0,
                        f"F32/F16 descriptor aux binding {name}")
                require(bo["aux"][int(descriptor["aux_base"]):
                                  int(descriptor["aux_base"]) +
                                  int(descriptor["aux_span"])] ==
                        model[src["absolute_file_offset"]:
                              src["absolute_file_offset"] + source_size(src)],
                        f"F32/F16 descriptor BO bytes {name}")
            else:
                require(int(descriptor["aux_base"]) == 0 and
                        int(descriptor["aux_span"]) == 0,
                        f"Q8 descriptor has no aux weight {name}")
            if bias_name is None:
                require(int(descriptor["bias_span"]) == 0,
                        f"no spurious bias {name}")
            else:
                bias_data = model[original[bias_name]["absolute_file_offset"] :
                                  original[bias_name]["absolute_file_offset"] +
                                  source_size(original[bias_name])]
                require(descriptor["bias_sha256"] == sha(bias_data) and
                        int(descriptor["bias_span"]) == len(bias_data),
                        f"bias source identity {name}")
                require(bo["aux"][int(descriptor["bias_base"]):
                                   int(descriptor["bias_base"]) + len(bias_data)] == bias_data,
                        f"bias aux binding {name}")
        padding = verify_padding(bo, spans)
        return {"status": "MODEL_PACKAGE_PASS", "tensors_verified": 153,
                "restored_tensors": restored_count,
                "q8_linear_matrices": 122, "weight_keys": 124,
                "graph_sha256": GRAPH_SHA, "source_payload_bytes": payload_total,
                "retained_payload_bytes": payload_total - 4202500,
                "bo_padding": padding,
                "build_sources_recorded": len(source_hashes),
                "build_sources_stale": stale_sources,
                "strict_current_sources": strict_current_sources,
                "manifest_sha256": file_sha(manifest_file),
                "model_sha256": MODEL_SHA, "inventory_sha256": INVENTORY_SHA}
    finally:
        for mapped in bo.values():
            mapped.close()
        for handle in bo_handles.values():
            handle.close()
        model.close()
        model_handle.close()


def main() -> int:
    if len(sys.argv) not in (4, 5) or (len(sys.argv) == 5 and
                                    sys.argv[4] != "--strict-current-sources"):
        print("usage: full_model_package_test.py ROOT PACKAGE_DIR OUTPUT_DIR "
              "[--strict-current-sources]",
              file=sys.stderr)
        return 2
    root, package, output = (pathlib.Path(x).resolve() for x in sys.argv[1:4])
    output.mkdir(parents=True, exist_ok=True)
    try:
        result = verify(root, package, len(sys.argv) == 5)
        return_code = 0
    except Exception as exc:
        result = {"status": "FAIL", "error": f"{type(exc).__name__}: {exc}",
                  "traceback": traceback.format_exc()}
        print(result["error"], file=sys.stderr)
        return_code = 1
    (output / "full_model_package_report.json").write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n")
    return return_code


if __name__ == "__main__":
    raise SystemExit(main())
