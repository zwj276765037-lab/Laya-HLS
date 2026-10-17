set_param general.maxThreads 4
read_verilog [glob "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/packing-pilot-vitis/csynth_vpp/hls/syn/verilog/*.v"]
synth_design -top full_cache_packing_pilot -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy none
report_utilization -file "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/results/synthesis_memory_fix_20261007/packing_pilot_vitis/vivado_ooc_utilization.rpt"
report_utilization -hierarchical -file "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/results/synthesis_memory_fix_20261007/packing_pilot_vitis/vivado_ooc_hierarchy.rpt"
puts "PILOT_URAM288_COUNT [llength [get_cells -hierarchical -filter {REF_NAME =~ URAM288*}]]"
write_checkpoint -force "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/results/synthesis_memory_fix_20261007/packing_pilot_vitis/vivado_ooc.dcp"
