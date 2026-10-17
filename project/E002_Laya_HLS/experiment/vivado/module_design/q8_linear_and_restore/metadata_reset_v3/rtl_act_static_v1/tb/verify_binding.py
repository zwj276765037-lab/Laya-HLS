#!/usr/bin/env python3
"""Rehash frozen Q8 sources, compiled snapshot, and prepared mode inputs."""
import argparse
import hashlib
import json
import shutil
from datetime import datetime, timezone
from pathlib import Path

RUNTIME_ARTIFACTS={f"q8_act_static/{name}" for name in (
    "xsim_script.tcl","xsimSettings.ini","xsimkernel.log","xsimcrash.log")}

def digest(path):
    h=hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda:stream.read(1<<20),b""):
            h.update(block)
    return h.hexdigest()

def records(packet):
    for key in ("source_gate","fixture_byte_review","materialization_evidence",
                "accepted_endpoint","xsim_ini","xsim_lookup_manual"):
        yield packet[key]
    for key in ("frozen_bound_baselines","verilog_modules","dat_files",
                "fp_sim_vhdl_wrappers","testbench_and_runner","fixtures",
                "original_model_files","guard_scripts","schedule_reports"):
        yield from packet[key]
    for group in packet["installed_library_files"].values():
        yield from group

def prepared_inventory(prepared, packet, expected_mode):
    manifest_path=prepared/"case_manifest.json"
    manifest=json.loads(manifest_path.read_text())
    if manifest["mode"] != expected_mode:
        raise RuntimeError("prepared mode mismatch")
    fixture=next(x for x in packet["fixtures"] if x["path"].endswith("/fixtures/manifest.json"))
    if manifest["fixture_manifest_sha256"] != fixture["sha256"]:
        raise RuntimeError("prepared fixture binding mismatch")
    files=[]
    for name,expected in sorted(manifest["files"].items()):
        if Path(name).name != name or not name.endswith(".memh"):
            raise RuntimeError(f"invalid prepared input name: {name}")
        path=prepared/name
        if not path.is_file() or path.is_symlink():
            raise RuntimeError(f"prepared input absent or linked: {path}")
        actual={"relative_path":name,"bytes":path.stat().st_size,"sha256":digest(path)}
        if (actual["bytes"],actual["sha256"]) != (expected["bytes"],expected["sha256"]):
            raise RuntimeError(f"prepared input changed: {path}")
        files.append(actual)
    actual_memh={p.name for p in prepared.glob("*.memh")}
    if actual_memh != set(manifest["files"]):
        raise RuntimeError("prepared input file set changed")
    files.append({"relative_path":"case_manifest.json",
                  "bytes":manifest_path.stat().st_size,"sha256":digest(manifest_path)})
    build=Path(packet["planned_runs_in_dependency_order"][0]["cwd"])
    snapshot=(build/"xsim.dir").resolve()
    link=prepared/"xsim.dir"
    if not link.is_symlink() or link.readlink() != snapshot or not snapshot.is_dir():
        raise RuntimeError("prepared xsim.dir binding mismatch")
    dat_source={Path(x["path"]).name:Path(x["path"]) for x in packet["dat_files"]}
    present={p.name:p for p in prepared.glob("*.dat")}
    if present and set(present) != set(dat_source):
        raise RuntimeError("prepared DAT link set incomplete")
    for name,path in present.items():
        if not path.is_symlink() or path.readlink() != dat_source[name]:
            raise RuntimeError(f"prepared DAT binding mismatch: {path}")
    return files,{"relative_path":"xsim.dir","target":str(snapshot)},len(present)

def archive_runtime_artifacts(snapshot, out):
    out.mkdir(parents=True,exist_ok=False)
    records=[]
    for relative in sorted(RUNTIME_ARTIFACTS):
        source=snapshot/relative
        if source.is_file():
            target=out/source.name
            shutil.copy2(source,target)
            records.append({"relative_path":relative,"bytes":target.stat().st_size,
                            "sha256":digest(target)})
    missing=sorted(RUNTIME_ARTIFACTS-{x["relative_path"] for x in records})
    (out/"manifest.json").write_text(json.dumps({
        "schema":"q8_xsim_runtime_artifact_archive_v1",
        "source_snapshot":str(snapshot.resolve()),
        "files":records,"missing":missing},sort_keys=True,indent=2)+"\n")
    if missing:
        raise RuntimeError(f"XSim runtime artifacts missing; partial archive retained: {missing}")
    return records

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("packet",type=Path)
    ap.add_argument("out",type=Path)
    ap.add_argument("--snapshot",type=Path)
    ap.add_argument("--expected-snapshot-report",type=Path)
    ap.add_argument("--prepared",type=Path)
    ap.add_argument("--expected-mode",choices=["legal","fault_load","identity_reset"])
    ap.add_argument("--expected-prepared-report",type=Path)
    ap.add_argument("--archive-runtime-artifacts",type=Path)
    args=ap.parse_args()
    if args.expected_snapshot_report and not args.snapshot:
        ap.error("--expected-snapshot-report requires --snapshot")
    if bool(args.prepared) != bool(args.expected_mode):
        ap.error("--prepared and --expected-mode must be supplied together")
    if args.expected_prepared_report and not args.prepared:
        ap.error("--expected-prepared-report requires --prepared")
    if args.archive_runtime_artifacts and not args.snapshot:
        ap.error("--archive-runtime-artifacts requires --snapshot")
    archived=[]
    if args.archive_runtime_artifacts:
        archived=archive_runtime_artifacts(args.snapshot,args.archive_runtime_artifacts)
    packet=json.loads(args.packet.read_text())
    source=[]
    seen=set()
    for entry in records(packet):
        if entry["path"] in seen: continue
        seen.add(entry["path"])
        path=Path(entry["path"])
        actual={"path":str(path),"bytes":path.stat().st_size,
                "mode":oct(path.stat().st_mode & 0o777),"sha256":digest(path)}
        if actual!=entry:
            raise RuntimeError(f"source changed: {path}")
        source.append(actual)
    snap=[]
    if args.snapshot:
        if not args.snapshot.is_dir(): raise RuntimeError("snapshot directory absent")
        for path in sorted(args.snapshot.rglob("*")):
            if path.is_file():
                snap.append({"relative_path":str(path.relative_to(args.snapshot)),
                             "bytes":path.stat().st_size,"sha256":digest(path)})
    if args.expected_snapshot_report:
        baseline=json.loads(args.expected_snapshot_report.read_text())
        fixed=lambda rows:[x for x in rows if x["relative_path"] not in RUNTIME_ARTIFACTS]
        if fixed(snap)!=fixed(baseline["snapshot_files"]):
            raise RuntimeError("compiled snapshot changed outside four exact XSim runtime artifacts")
    prepared_files=[]
    prepared_link=None
    dat_link_count=0
    if args.prepared:
        prepared_files,prepared_link,dat_link_count=prepared_inventory(
            args.prepared,packet,args.expected_mode)
    if args.expected_prepared_report:
        baseline=json.loads(args.expected_prepared_report.read_text())
        if (prepared_files!=baseline["prepared_files"] or
            prepared_link!=baseline["prepared_snapshot_link"]):
            raise RuntimeError("prepared mode input changed")
    result={"schema":"q8_static_source_and_snapshot_check_v1",
            "at_utc":datetime.now(timezone.utc).isoformat(),
            "packet":{"path":str(args.packet.resolve()),
                      "sha256":digest(args.packet)},
            "source_count":len(source),"source_verified":True,
            "snapshot_root":str(args.snapshot.resolve()) if args.snapshot else None,
            "snapshot_files":snap,
            "runtime_artifact_files":[x for x in snap if x["relative_path"] in RUNTIME_ARTIFACTS],
            "archived_runtime_artifact_files":archived,
            "runtime_artifact_archive":str(args.archive_runtime_artifacts.resolve())
                if args.archive_runtime_artifacts else None,
            "prepared_root":str(args.prepared.resolve()) if args.prepared else None,
            "prepared_files":prepared_files,
            "prepared_snapshot_link":prepared_link,
            "prepared_dat_link_count":dat_link_count,
            "expected_snapshot_report":str(args.expected_snapshot_report.resolve())
               if args.expected_snapshot_report else None}
    args.out.parent.mkdir(parents=True,exist_ok=True)
    if args.out.exists(): raise FileExistsError(args.out)
    args.out.write_text(json.dumps(result,sort_keys=True,indent=2)+"\n")
    print(f"Q8_BINDING_VERIFIED source={len(source)} snapshot={len(snap)} prepared={len(prepared_files)} dat_links={dat_link_count}")

if __name__=="__main__": main()
