#!/usr/bin/env python3
"""Hash-check frozen ACT pages and emit byte-exact XSim readmemh inputs."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
FIX = HERE.parent / "fixtures"
BUILD = HERE.parent / "runs/static_build_v1"
PORTS = ["descriptor","w_q0","w_q1","w_scale","aux","activation",
         "out0","out1","observed"]
MAX_COMMANDS = 24

def get(fix, item):
    path = fix / item["relative_path"]
    payload = path.read_bytes()
    assert len(payload) == item["bytes"], path
    assert hashlib.sha256(payload).hexdigest() == item["sha256"], path
    return payload

def hexfile(path, data, width=1):
    assert len(data) % width == 0
    with path.open("w") as stream:
        for i in range(0,len(data),width):
            stream.write(data[i:i+width][::-1].hex()+"\n")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=["legal","fault_load","identity_reset"])
    ap.add_argument("output", type=Path)
    args = ap.parse_args()
    manifest = json.loads((FIX/"manifest.json").read_text())
    assert manifest["page_count"] == 41
    assert manifest["generated_file_count_excluding_manifest"] == 234
    for item in manifest["generated_files_excluding_manifest"]:
        get(FIX,item)
    args.output.mkdir(parents=True, exist_ok=False)
    pages = {}
    for p in manifest["pages"]:
        pages.setdefault(p["port"],{})[p["slot"]] = get(FIX,p)
    for port in PORTS:
        assert sorted(pages[port]) == list(range(len(pages[port])))
        hexfile(args.output/f"init_{port}.memh",b"".join(pages[port].values()))
    rows = manifest["commands"][args.mode]
    assert len(rows) == manifest["command_counts"][args.mode]
    assert len(rows) <= MAX_COMMANDS
    arrays = {key: bytearray() for key in ("descriptor","expected_header",
              "expected_observed","expected_out0","expected_out1",
              "activation","aux0","aux1","scale")}
    useful = bytearray()
    warm_reset = bytearray()
    cases = []
    for idx,row in enumerate(rows):
        arrays["descriptor"] += get(FIX,row["descriptor_page"])
        arrays["expected_header"] += get(FIX,row["expected_header"])
        arrays["expected_observed"] += get(FIX,row["expected_observed_32_pages"])
        arrays["expected_out0"] += get(FIX,row["expected_out0_page"])
        arrays["expected_out1"] += get(FIX,row["expected_out1_page"])
        av = row["activation_variant"]
        arrays["activation"] += get(FIX,manifest["variants"]["activation_"+av])
        ax = row["aux_variant"]
        arrays["aux0"] += (pages["aux"][0] if ax in ("normal","bias_fault")
                           else get(FIX,manifest["variants"]["aux_"+ax]))
        arrays["aux1"] += (get(FIX,manifest["variants"]["aux_bias_fault"])
                           if ax == "bias_fault" else pages["aux"][1])
        sv = row["scale_variant"]
        arrays["scale"] += (get(FIX,manifest["variants"]["scale_fault"])
                            if sv == "fault" else pages["w_scale"][0])
        for port in PORTS:
            useful += int(row["expected_port_useful_bytes"][port]).to_bytes(8,"little")
        reset = args.mode == "identity_reset" and idx == 21
        warm_reset += bytes([int(reset)])
        cases.append({"index":idx,"case":row["case"],"status":row["expected_status"],
                      "warm_reset_before":reset})
    for name,payload in arrays.items():
        hexfile(args.output/f"{name}.memh",payload)
    hexfile(args.output/"expected_useful.memh",useful,8)
    hexfile(args.output/"warm_reset.memh",warm_reset)
    snapshot = BUILD / "xsim.dir"
    assert snapshot.is_dir(), snapshot
    (args.output/"xsim.dir").symlink_to(snapshot.resolve(), target_is_directory=True)
    (args.output/"case_manifest.json").write_text(json.dumps({
        "mode":args.mode,"command_count":len(rows),"cases":cases,
        "fixture_manifest_sha256":hashlib.sha256((FIX/"manifest.json").read_bytes()).hexdigest(),
        "files":{p.name:{"bytes":p.stat().st_size,
                         "sha256":hashlib.sha256(p.read_bytes()).hexdigest()}
                 for p in args.output.iterdir() if p.is_file()}
    },indent=2,sort_keys=True)+"\n")
    print(f"Q8_PREPARED mode={args.mode} commands={len(rows)}")

if __name__ == "__main__":
    main()
