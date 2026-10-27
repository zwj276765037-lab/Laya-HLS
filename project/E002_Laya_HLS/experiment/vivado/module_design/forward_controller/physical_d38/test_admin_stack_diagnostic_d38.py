#!/usr/bin/python3
"""Two real small-process tests; never attaches the production Vivado."""
import importlib.util
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('stack_diagnostic', HERE/'admin_stack_diagnostic_d38.py')
d = importlib.util.module_from_spec(spec)
spec.loader.exec_module(d)
out = d.RUN/f'AT019_stack_diagnostic_tests_{time.time_ns()}'
out.mkdir(exist_ok=False)
toy = out/'toy.py'
toy.write_text("import ctypes,time\nctypes.CDLL(None).prctl(0x59616d61,ctypes.c_ulong(-1).value,0,0,0)\nwhile True:time.sleep(.02)\n")
results = []
begun = time.monotonic()
for name, hold, timeout in [('normal', False, 10), ('timeout', True, .5)]:
    case = out/name
    case.mkdir()
    child = subprocess.Popen([sys.executable, str(toy)], start_new_session=True)
    try:
        time.sleep(.1)
        identity = d.proc(child.pid)
        assert identity and child.pid != d.TARGET and identity['pgid'] == child.pid
        result = d.capture(child.pid, identity['start'], case, timeout=timeout, test_hold=hold)
        assert result['timed_out'] is hold, result
        assert result['debugger_exit'] is not None and result['detach_verified'], result
        text = (case/'gdb.txt').read_text(errors='replace')
        assert 'ptrace: Operation not permitted' not in text
        if not hold:
            assert result['debugger_exit'] == 0 and 'Thread 1' in text and '#0' in text, text
        results.append({'test': name, 'PASS': True, 'capture': str(case/'capture.json'),
                        'elapsed_seconds': result['elapsed_seconds'],
                        'cleanup_signals': result['cleanup_signals']})
    finally:
        if child.poll() is None:
            os.killpg(child.pid, signal.SIGKILL)
        child.wait(timeout=3)
d.dump(out/'test_result.json', {'PASS': True, 'scope': 'Infrastructure only; two local Python processes, no production attachment',
       'script_sha256': hashlib.sha256((HERE/'admin_stack_diagnostic_d38.py').read_bytes()).hexdigest(),
       'elapsed_seconds': time.monotonic()-begun, 'tests': results})
print(json.dumps({'PASS': True, 'output': str(out), 'tests': results}))
