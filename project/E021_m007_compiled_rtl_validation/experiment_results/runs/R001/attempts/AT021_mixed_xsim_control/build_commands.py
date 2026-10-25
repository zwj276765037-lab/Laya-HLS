import subprocess
subprocess.run(['/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xvlog', '--sv', '/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E021_m007_compiled_rtl_validation/experiment_results/runs/R001/attempts/AT018_mixed_zero_clock_fixture/frozen/mixed_zero_clock_tb.sv'], check=True)
subprocess.run(['/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/xelab', 'work.mixed_zero_clock_tb', '--relax', '-debug', 'off', '-mt', '4', '--O3', '-s', 'mixed_zero_clock_sim'], check=True)
