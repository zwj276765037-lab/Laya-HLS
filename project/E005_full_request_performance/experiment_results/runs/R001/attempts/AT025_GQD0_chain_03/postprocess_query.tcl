load_features simulator
set wdb {/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT025_GQD0_chain_03/work/vivado/gqd0_chain_tb_v1.sim/sim_1/behav/xsim/gqd0_chain_tb_v1_behav.wdb}
puts "GQD_OPEN [open_wave_database -noautoloadwcfg $wdb]"
puts "GQD_TIME [current_time]"
foreach n {g_aw_count g_b_count g_source_r_count} {
  set o "/gqd0_chain_tb_v1/$n"
  puts "GQD_OBJECT $o [get_objects -quiet $o]"
  catch {get_value -radix unsigned $o} value
  puts "GQD_VALUE $o $value"
}
exit
