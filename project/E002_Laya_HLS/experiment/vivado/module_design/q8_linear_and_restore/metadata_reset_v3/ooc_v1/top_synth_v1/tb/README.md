This directory contains dormant source for a future isolated top OOC run.
`verify_clone.py` can read the accepted a2 source without opening Vivado;
`clone_project.py` would create a fresh byte-exact project clone with only its
XPR root Project Path rebound. `synth_ooc_top_v1.tcl` checks the clone and
actual compile order before the original synthesis/reporting sequence.
`verify_actual_compile.py` independently binds the 243 actual compile files.
No clone or EDA execution is released by these files.
