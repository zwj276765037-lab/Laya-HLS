"""Read actual compiled XSim scopes without executing the arithmetic task."""
from pathlib import Path
import argparse,subprocess,json,hashlib,re,shutil
V=Path('/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin')
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--build',type=Path,required=True);a=p.parse_args();a.output.mkdir();shutil.copytree(a.build/'xsim.dir',a.output/'xsim.dir');t=a.output/'hierarchy.tcl'
t.write_text('''set b /m007_control_arena_engine_tb/dut/joint
set wa [get_objects -quiet ${b}/workspace/state_q]
set la [get_scopes -quiet ${b}/layer/local_state]
set lg [get_scopes -quiet ${b}/g_engine/math/local_state]
set ea [get_objects -quiet ${b}/layer/qkv_coverage]
set eg [get_objects -quiet ${b}/g_engine/math/control_q]
set pa [get_objects -quiet ${b}/layer/local_state/state_q]
set pg [get_objects -quiet ${b}/g_engine/math/local_state/state_q]
puts "CONTROL_HIERARCHY workspace=$wa layer_local=$la g_local=$lg layer_q_view=$ea g_q_view=$eg layer_private_FF=$pa g_private_FF=$pg"
if {[llength $wa] != 1 || [llength $la] != 0 || [llength $lg] != 0 || [llength $ea] != 1 || [llength $eg] != 1 || [llength $pa] != 0 || [llength $pg] != 0} {error "workspace/private shadow elaboration mismatch"}
puts "HARDWARE_AGENT_SIM_PASS CONTROL_HIERARCHY actual_workspace_objects=1 private_control_branches=0 consumer_q_views=2"
quit
''')
r=subprocess.run([str(V/'xsim'),'control_arena_sim','-tclbatch',str(t)],cwd=a.output,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);print(r.stdout);(a.output/'hierarchy.log').write_text(r.stdout)
assert r.returncode==0 and 'HARDWARE_AGENT_SIM_PASS CONTROL_HIERARCHY actual_workspace_objects=1'in r.stdout and not re.search(r'(?im)^\s*(?:Fatal|ERROR):',r.stdout)
(a.output/'report.json').write_text(json.dumps({'status':'PASS','basis':'Actual compiled XSim scopes/objects, no arithmetic run','build_manifest_sha256':hashlib.sha256((a.build/'report.json').read_bytes()).hexdigest(),'workspace_objects':1,'private_control_local_branches':0,'consumer_q_views':2,'empty_generate_scope_note':'Pure alias external generate scopes are optimized away; query actual q aliases plus absence of private local FF objects','tcl_sha256':hashlib.sha256(t.read_bytes()).hexdigest()},indent=2)+'\n')
