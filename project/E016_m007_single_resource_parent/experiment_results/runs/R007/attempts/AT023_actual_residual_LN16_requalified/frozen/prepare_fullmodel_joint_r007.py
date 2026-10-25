from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[3];M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design';R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007';p=M/'attention_and_fp_engine/tb/m007_joint27_tb.sv';s=p.read_text().replace('module m007_joint27_tb #','module m007_fullmodel_joint_tb #')
a='laya_m007_resident_joint_v2 #(.TANH_FORCE_CORE_CE(FORCE_CORE_CE)) dut(.*);';b="laya_m007_resident_joint_v3 #(.TANH_FORCE_CORE_CE(FORCE_CORE_CE)) dut(.type_model_committed(1'b0),.type_qtype(2'b0),.type_wr_valid(1'b0),.type_wr_ready(),.type_wr_index(7'b0),.type_wr_data('0),.type_wr_commit(),.type_bank_idle(),.type_reject_valid(),.h_load_success_valid(1'b0),.*);";assert a in s;s=s.replace(a,b)
a='''   @(negedge clk);resident_ln_start_valid=0;resident_owner_valid=1;scratch_acquire();
   stage=5;run_ln(0,rows_arg);''';b='''   @(negedge clk);resident_ln_start_valid=0;resident_owner_valid=1;
   if(resident_ln_source_qualified)$fatal(1,"OWNER_LOSS_FAILED_TO_INVALIDATE_WITNESS");
   // D29 owner-loss invalidates source qualification: recreate it using real
   // public H/Q commits and finite VECTOR output, then acquire a new LN lease.
   switch_to(3);scratch_acquire();load_hq(0,0);run_vector(0,0);scratch_release();update_epoch();switch_to(2);scratch_acquire();
   stage=5;run_ln(0,rows_arg);''';assert a in s;s=s.replace(a,b)
s=s.replace('last_progress=checked;', 'last_progress=checked;$display("M007_PARENT_CHECKED checked=%0d phase=JOINT cycle=%0d",checked,cycle);$fflush();')
s=s.replace('module m007_fullmodel_joint_tb #(parameter bit FORCE_CORE_CE=0);','module m007_fullmodel_joint_tb #(parameter bit FORCE_CORE_CE=0);\n integer residual_total=0;')
s=s.replace(" logic  rst_n='0';"," logic  rst_n='0';\n always@(posedge clk)if(rst_n&&dut.vector_h_wr_valid&&dut.vector_h_wr_commit)residual_total++;")
s=s.replace('residual_vectors=4096 ln_vectors=%0d','residual_vectors=%0d ln_vectors=%0d').replace('g_bank_ops,mode_arg==0?rows_arg*32','g_bank_ops,residual_total,mode_arg==0?rows_arg*32')
o=M/'forward_controller/tb/m007_fullmodel_joint_tb.sv';o.write_text(s);d=json.loads((R/'joint_adapter_source.json').read_text());d.update(original_checker_sha256=hashlib.sha256(p.read_bytes()).hexdigest(),adapter_sha256=hashlib.sha256(o.read_bytes()).hexdigest(),changes='version/name + unused type pins + owner-loss actual H/Q/VECTOR qualification repair + monotonic checked event stdout; original numerical/lease/assertions retained',source_generator_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest());(R/'joint_adapter_source.json').write_text(json.dumps(d,indent=2)+'\n')
