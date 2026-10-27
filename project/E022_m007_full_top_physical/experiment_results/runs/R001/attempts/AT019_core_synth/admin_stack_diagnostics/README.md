# Fixed AT019 administrator diagnostic

Run once as administrator:

```sh
/usr/bin/python3 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/physical_d38/admin_stack_diagnostic_d38.py --execute
```

The script enforces its own CPU/nice/IO policy, validates the fixed native Vivado identity and active supervisors, and briefly attaches only that Vivado. It never attaches or resumes the retired guard or monitoring processes. No inferior calls, core dump or Tcl changes. A new DG_* directory contains gdb.txt, capture.json, preflight/postflight and the script hash. Its contents are returned to the current AT019 owner. Twenty-second capture cap plus up to seven seconds debugger cleanup. Stack frames may contain addresses without function names; info sharedlibrary records library ranges. Engineering observes this directory directly; no manual report forwarding is required.
