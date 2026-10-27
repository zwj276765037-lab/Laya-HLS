set ooc_stub_directory {/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E022_m007_full_top_physical/experiment_results/runs/R001/input/stubs_v6}
set ooc_top(core_synth) {laya_m007_matrix_engine_v1}
set ooc_generics(core_synth) [list {PROFILE_ENABLE=1'b0}]
set ooc_stubs(core_synth) [list ]
set ooc_expected_bb(core_synth) [list ]
set ooc_top(facade_synth) {laya_m007_matrix_facade_v2}
set ooc_generics(facade_synth) [list {PROFILE_ENABLE=1'b0} {CANONICAL_MODEL=1'b1} {CANONICAL_MODEL_ID=64'h9db40381604108af}]
set ooc_stubs(facade_synth) [list laya_m007_matrix_engine_v1]
set ooc_expected_bb(facade_synth) [list core]
set ooc_top(resident_synth) {laya_m007_resident_joint_v3}
set ooc_generics(resident_synth) [list {TANH_FORCE_CORE_CE=1'b0}]
set ooc_stubs(resident_synth) [list ]
set ooc_expected_bb(resident_synth) [list ]
set ooc_top(parent_synth) {laya_m007_single_parent_v3}
set ooc_generics(parent_synth) [list {MODEL_SHA256=256'h6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18} {GRAPH_SHA256=256'hf33f7848434b73048f957dcd232e1bd4ff99e95b8cf41c98191b69fddad815f9} {NUMERIC_SHA256=256'haeb13e7937d29fe6a2c68c407249f294212aa24f4e45fd3862b092795ab066f7} {LAYOUT_SHA256=256'h2d848b5fb78236c795cb1d442f088393a3fd6cbd7f8ecf3cf9f984c59b5e0991} {PACKAGE_BUILD_SHA256=256'h7209eb09c3f265363cfb274f7790a73336e1570f5081bc9bbb2538c1ba5a50d5} {TABLE_KEY=128'hb1fdc9ca482c0210982c7245cc50c965} {ADDRESS_PROFILE=2'h1} {HBM_PORT_BASE=256'h0} {HBM_PORT_SPAN=256'h0000000100000000000000010000000000000001000000000000000100000000} {VERIFY_POST_ENCODER27_H=1'b0} {PLATFORM_MANIFEST_SHA256=256'hf0df35cc7013643161e135ae0949473a9b5c0f13d5a4e3aea3675c2cf607db18}]
set ooc_stubs(parent_synth) [list laya_m007_matrix_facade_v2 laya_m007_resident_joint_v3]
set ooc_expected_bb(parent_synth) [list matrix resident]
set ooc_synth_options(core_synth) [list -no_timing_driven]
set ooc_synth_options(facade_synth) [list]
set ooc_synth_options(resident_synth) [list]
set ooc_synth_options(parent_synth) [list]
