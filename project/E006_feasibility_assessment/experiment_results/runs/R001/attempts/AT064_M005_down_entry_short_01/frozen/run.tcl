set_param general.maxThreads 4
create_project m005_down_entry_short_v1 [file join [file dirname [info script]] work vivado] -part xcu55c-fsvh2892-2L-e
add_files -norecurse {/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_compute_portal_layout_v1.sv}
add_files -norecurse {/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_model_identity_13bo_generated_v1.sv}
add_files -norecurse {/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT063_FFN4_wi_descriptor_01/frozen_new/laya_lnq0_bound_identity_generated_v1.sv}
add_files -norecurse {/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT035_QAR0_shared_admission_01/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_matrix_owner_ledger_v2.sv}
add_files -norecurse {/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT063_FFN4_wi_descriptor_01/frozen_ffn/laya_ffn0_down_residual_admission_v1.sv}
add_files -fileset sim_1 {/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E006_feasibility_assessment/experiment_results/runs/R001/attempts/AT064_M005_down_entry_short_01/frozen/m005_down_entry_short_tb_v1.sv}
set_property top m005_down_entry_short_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg LN_FIXTURE=/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/fixture -testplusarg BOUND_FIXTURE=/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT043_LNQ0_chain_02/bound_identity" -objects [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
launch_simulation -mode behavioral -step simulate
puts M005_DOWN_ENTRY_SHORT_SCRIPT_FINISHED
close_project
