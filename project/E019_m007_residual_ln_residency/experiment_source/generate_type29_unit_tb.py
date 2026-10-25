from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[3];SRC=Path(__file__).parent;A=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine'
base=(A/'tb/m007_resident21_tb.sv').read_text();s=base[:base.index(' initial begin')].replace('module m007_resident21_tb;', 'module m007_type29_unit_tb;')
s=s.replace('assign inputs_ready=loaded&&scratch_active;', 'assign inputs_ready=loaded&&scratch_active&&(op_arg!=1||(type_model_committed&&type_qtype<3));')
s=s.replace('assign start_epoch=owner_epoch;', "assign start_epoch=owner_epoch+32'(wrong_epoch);")
extra=r''' logic external_control_enable=1;logic[47:0]external_control_q=0,external_control_next;logic control_private_idle;
 logic type_rd_valid,type_rd_ready,type_rsp_valid,type_rsp_ready;logic[11:0]type_rd_addr,type_rsp_addr;logic[31:0][31:0]type_rsp_data;
 integer op_arg=1,q_hold_cycles=0,type_hold_cycles=0,type_checked=0,op0_compared=0,first_status=0,first_issued=0,first_retired=0,q_reads=0,type_reads=0,h_reads=0;
 bit wrong_epoch=0,recovery=0,epoch_fault_done=0,compare_op0=0;
 logic type_model_committed=0,type_setup_valid=0,type_setup_ready,type_setup_commit,type_idle,type_reject,bank_reset_n=1;
 logic[1:0]type_qtype=2,tb_type_qtype=0;logic[6:0]type_setup_index=0;logic[31:0][31:0]type_setup_data;
 logic tb_type_rd=0,tb_type_ready=0,raw_type_valid,raw_type_ready,raw_type_rd_ready,raw_q_rsp_valid;
 logic[11:0]tb_type_addr=0,raw_type_addr;logic[31:0][31:0]raw_type_data;logic[31:0]T[0:3071];string tf;
 wire q_response_gate=!(op_arg==1&&mode==3&&!recovery&&raw_q_rsp_valid&&q_rsp_addr==0&&q_hold_cycles<17);
 wire type_response_gate=!(op_arg==1&&mode==3&&!recovery&&raw_type_valid&&raw_type_addr==32&&type_hold_cycles<17);
 logic[31:0]raw_fp_rsp_epoch;
 wire epoch_fault=mode==6&&!recovery&&!epoch_fault_done&&add_rsp_valid[0];
 assign fp_rsp_epoch=raw_fp_rsp_epoch^32'(epoch_fault);
 always@(posedge clk)begin if(!rst_n)external_control_q<=0;else if(external_control_enable)external_control_q<=external_control_next;end
'''
s=s.replace('logic wrong_identity=0;', 'logic wrong_identity=0;bit wrong_epoch=0;integer op_arg=1;logic type_model_committed=0;logic[1:0]type_qtype=2;')
extra=extra.replace('integer op_arg=1,','integer ').replace('bit wrong_epoch=0,recovery=0,','bit recovery=0,').replace('logic type_model_committed=0,type_setup_valid=0,','logic type_setup_valid=0,').replace('logic[1:0]type_qtype=2,tb_type_qtype=0;','logic[1:0]tb_type_qtype=0;')
mode_decl=next(x for x in s.splitlines()if x.startswith(' integer mode,'))
s=s.replace(mode_decl+'\n','')
s=s.replace(' laya_m007_resident_vector32_v1 provider(.*);',mode_decl+'\n'+extra+' laya_m007_resident_vector32_v3 #(.EXTERNAL_CONTROL(1)) provider(.*);')
s=s.replace('.rsp_epoch(fp_rsp_epoch)', '.rsp_epoch(raw_fp_rsp_epoch)')
s=s.replace('assign bank_q_rsp_ready=run_provider?q_rsp_ready:tb_rsp_ready;', 'assign bank_q_rsp_ready=run_provider?(q_rsp_ready&&q_response_gate):tb_rsp_ready;')
s=s.replace('.rd_rsp_valid(q_rsp_valid)', '.rd_rsp_valid(raw_q_rsp_valid)')
anchor=' logic[31:0]H[0:131071]'
new=r''' assign q_rsp_valid=raw_q_rsp_valid&&(!run_provider||q_response_gate);
 assign type_rd_ready=raw_type_rd_ready;
 assign type_rsp_valid=raw_type_valid&&(!run_provider||type_response_gate);
 assign type_rsp_addr=raw_type_addr^((mode==5&&!recovery&&run_provider&&raw_type_addr==3)?12'h020:12'b0);
 assign type_rsp_data=raw_type_data;
 assign raw_type_ready=run_provider?(type_rsp_ready&&type_response_gate):tb_type_ready;
 laya_m007_type32_v1 type_bank(.clk,.rst_n(rst_n&&bank_reset_n),.model_committed(type_model_committed),.inference_active(run_provider),
  .wr_valid(type_setup_valid),.wr_ready(type_setup_ready),.wr_index(type_setup_index),.wr_data(type_setup_data),.wr_commit(type_setup_commit),
  .rd_valid(run_provider?type_rd_valid:tb_type_rd),.rd_ready(raw_type_rd_ready),.rd_qtype(run_provider?type_qtype:tb_type_qtype),.rd_vector_addr(run_provider?type_rd_addr:tb_type_addr),
  .rsp_valid(raw_type_valid),.rsp_ready(raw_type_ready),.rsp_vector_addr(raw_type_addr),.rsp_data(raw_type_data),.bank_idle(type_idle),.reject_valid(type_reject));
'''
assert anchor in s;s=s.replace(anchor,new+anchor)
# Exact op0 comparison against unchanged local-v2 on the same real service inputs.
ports=json.loads((SRC/'joint_v2_port_manifest.json').read_text())['consumers']['vector']['ports'];obs=' logic[47:0]v2_next;logic v2_private_idle;\n'
for di,dims,n in ports:
 if di=='output'and n not in ['external_control_next','control_private_idle']:obs+=f' logic {dims} v2_{n};\n'
mp={'external_control_enable':"1'b1",'external_control_q':"48'b0",'external_control_next':'v2_next','control_private_idle':'v2_private_idle'}
obs+=' laya_m007_resident_vector32_v2 #(.EXTERNAL_CONTROL(0)) original_op0(\n'+',\n'.join(' .'+n+'('+mp.get(n,'v2_'+n if di=='output'else n)+')'for di,dims,n in ports)+'\n );\n always@(posedge clk)if(rst_n&&compare_op0)begin\n'
for di,dims,n in ports:
 if di=='output'and n not in ['external_control_next','control_private_idle']:obs+=f'  if({n}!==v2_{n})$fatal(1,"OP0_EQ_{n}");\n'
obs+='  if(external_control_next!==v2_next||control_private_idle!==v2_private_idle)$fatal(1,"OP0_Q_NEXT_EQ");op0_compared++;end\n'
s=s.replace(' task automatic step;',obs+' task automatic step;',1)
s+=r'''
 task automatic setup_type;
  type_model_committed=0;
  for(int a=0;a<96;a++)begin @(negedge clk);type_setup_valid=1;type_setup_index=7'(a);for(int l=0;l<32;l++)type_setup_data[l]=T[a*32+l];#0.001;if(!type_setup_ready||!type_setup_commit)$fatal(1,"TYPE_SETUP");step();end
  @(negedge clk);type_setup_valid=0;type_model_committed=1;
 endtask
 task automatic type_read_check(input int qt,addr,held);
  @(negedge clk);tb_type_qtype=2'(qt);tb_type_addr=12'(addr);tb_type_rd=1;tb_type_ready=0;#0.001;if(!raw_type_rd_ready)$fatal(1,"TYPE_RD_READY");step();@(negedge clk);tb_type_rd=0;
  if(!raw_type_valid||raw_type_addr!=addr)$fatal(1,"TYPE_SYNC_ADDR");
  repeat(held)begin step();if(!raw_type_valid||type_idle||raw_type_rd_ready||control_retired||control_private_idle||raw_type_addr!=addr)$fatal(1,"TYPE_HELD17_BARRIER");for(int l=0;l<32;l++)if(raw_type_data[l]!==T[qt*1024+(addr%32)*32+l])$fatal(1,"TYPE_HELD_PAYLOAD");end
  for(int l=0;l<32;l++)if(raw_type_data[l]!==T[qt*1024+(addr%32)*32+l])$fatal(1,"TYPE_ROUTE");type_checked+=32;checked+=32;
  $fdisplay(progress_fd,"{\"schema\":\"m007-resident-consumed-v1\",\"checked\":%0d,\"node_checks\":0,\"cycle\":%0d,\"phase\":1,\"returned\":%0d}",checked,cycles,type_checked);$fflush(progress_fd);
  @(negedge clk);tb_type_ready=1;step();@(negedge clk);tb_type_ready=0;
 endtask
 task automatic load_pair(input bit bad);
  for(int a=0;a<4096;a++)begin
   @(negedge clk);tb_wr_valid=1;tb_wr_addr=12'(a);for(int l=0;l<32;l++)begin tb_h_data[l]=H[a*32+l];tb_q_data[l]=(bad&&a==3&&l==5)?32'h7fc12345:Q[a*32+l];end
   #0.001;if(!raw_h_wr_ready||!raw_q_wr_ready||!raw_h_commit||!raw_q_commit)$fatal(1,"LOAD_COMMIT");step();
  end
  @(negedge clk);tb_wr_valid=0;loaded=1;
 endtask
 task automatic execute(input int expect_status);
  q_reads=0;type_reads=0;h_reads=0;@(negedge clk);run_provider=1;start_valid=1;#0.001;if(!start_ready)$fatal(1,"START_NOT_READY");step();@(negedge clk);start_valid=0;
  wait(done_valid);@(negedge clk);
  if(done_status!=expect_status||fp_lease_active||add_pending||mul_pending||h_rsp_valid||q_rsp_valid||type_rsp_valid||issued_vectors!=retired_vectors)$fatal(1,"DONE_REAL_DEBT status=%0d expected=%0d",done_status,expect_status);
  if(expect_status==0&&(commits!=4096||done_cycle-start_cycle-q_hold_cycles-type_hold_cycles-held_write_cycles>4160))$fatal(1,"FULL_BOUND");
  if(expect_status==6&&(done_error_row!=0||done_error_column!=101||issued_vectors>=4096))$fatal(1,"NAN_FIRST_ERROR");
  repeat(17)begin step();if(!done_valid||control_retired||start_ready)$fatal(1,"HELD_DONE");end
  if(expect_status==0&&done_cycle-start_cycle-q_hold_cycles-type_hold_cycles-held_write_cycles>4160)$fatal(1,"REAL_DONE_CYCLE_BOUND");
  @(negedge clk);done_ready=1;step();@(negedge clk);done_ready=0;run_provider=0;if(!control_retired)$fatal(1,"POST_DONE_RETIRE");
 endtask
 initial begin
  if(!$value$plusargs("MODE=%d",mode)||!$value$plusargs("OP=%d",op_arg)||!$value$plusargs("TYPE=%s",tf)||!$value$plusargs("H=%s",hf)||!$value$plusargs("Q=%s",qf)||!$value$plusargs("GOLD=%s",gf)||!$value$plusargs("PROGRESS_FILE=%s",pf))$fatal(1,"ARGS");
  start_op=2'(op_arg);$readmemh(tf,T);$readmemh(hf,H);$readmemh(qf,Q);$readmemh(gf,GOLD);progress_fd=$fopen(pf,"w");if(!progress_fd)$fatal(1,"PROGRESS_OPEN");
  repeat(5)@(negedge clk);rst_n=1;
  tb_type_rd=1;#0.001;if(raw_type_rd_ready||!type_reject)$fatal(1,"TYPE_UNCOMMITTED_READ");step();@(negedge clk);tb_type_rd=0;setup_type();
  type_setup_valid=1;#0.001;if(type_setup_ready||!type_reject)$fatal(1,"TYPE_COMMITTED_WRITE");step();@(negedge clk);type_setup_valid=0;
  for(int qt=0;qt<3;qt++)for(int c=0;c<32;c++)type_read_check(qt,((qt+3)*32)+c,qt==1&&c==17?17:0);
  @(negedge clk);tb_type_qtype=3;tb_type_rd=1;#0.001;if(raw_type_rd_ready||!type_reject)$fatal(1,"TYPE3_READ");step();@(negedge clk);tb_type_rd=0;tb_type_qtype=0;
  // Actual held response reset invalidation, followed by legal complete setup again.
  tb_type_addr=4095;tb_type_rd=1;step();@(negedge clk);tb_type_rd=0;bank_reset_n=0;type_model_committed=0;step();@(negedge clk);bank_reset_n=1;if(raw_type_valid)$fatal(1,"TYPE_RESET_RESPONSE");setup_type();type_read_check(2,4095,0);
  type_model_committed=0;type_setup_valid=1;type_setup_index=96;#0.001;if(type_setup_ready||!type_reject)$fatal(1,"TYPE_SETUP_INDEX");step();@(negedge clk);type_setup_valid=0;type_model_committed=1;
  compare_op0=op_arg==0;
  rope_owner_valid=1;scratch_lease_valid=1;#0.001;if(scratch_lease_ready)$fatal(1,"ROPE_ADMISSION");step();@(negedge clk);rope_owner_valid=0;#0.001;if(!scratch_lease_ready)$fatal(1,"SCRATCH_NOT_READY");step();@(negedge clk);scratch_lease_valid=0;
  wrong_identity=1;tb_wr_valid=1;tb_rd_valid=1;#0.001;if(raw_h_wr_ready||raw_h_rd_ready||raw_q_wr_ready||raw_q_rd_ready||!h_reject||!q_reject)$fatal(1,"OLD_IDENTITY_ACCEPT");step();@(negedge clk);tb_wr_valid=0;tb_rd_valid=0;wrong_identity=0;
  start_valid=1;#0.001;if(start_ready||!start_reject_valid)$fatal(1,"UNINITIALIZED_START");step();@(negedge clk);start_valid=0;
  load_pair(mode==4);
  wrong_epoch=1;start_valid=1;#0.001;if(start_ready||!start_reject_valid)$fatal(1,"OLD_START_EPOCH");step();@(negedge clk);start_valid=0;wrong_epoch=0;
  execute(mode>=5?8:mode==4?6:0);first_status=mode>=5?8:mode==4?6:0;first_issued=issued_vectors;first_retired=retired_vectors;
  if(mode>=4)begin
   @(negedge clk);scratch_release_valid=1;#0.001;if(!scratch_release_ready)$fatal(1,"ERROR_SCRATCH_RELEASE");step();@(negedge clk);scratch_release_valid=0;owner_generation++;owner_epoch++;scratch_lease_valid=1;step();@(negedge clk);scratch_lease_valid=0;
   recovery=1;loaded=0;commits=0;first_commit=-1;done_cycle=-1;load_pair(0);execute(0);
  end
  if(mode==3&&(q_hold_cycles!=17||type_hold_cycles!=17||held_write_cycles!=17))$fatal(1,"HELD_COVERAGE");
  for(int a=0;a<4096;a++)pair_read(a,1);
  @(negedge clk);scratch_release_valid=1;#0.001;if(!scratch_release_ready||!type_idle)$fatal(1,"FINAL_RELEASE");step();@(negedge clk);scratch_release_valid=0;
  if(op_arg==0&&op0_compared==0)$fatal(1,"OP0_EQ_NO_CYCLES");
  $display("HARDWARE_AGENT_SIM_PASS TYPE29_UNIT op=%0d mode=%0d commits=%0d checked=%0d scan_checked=%0d type_checked=%0d q_held=%0d type_held=%0d finalH_held=%0d first_status=%0d first_issued=%0d first_retired=%0d recovered=%0d lease_count=%0d release_count=%0d op0_compared=%0d q_reads=%0d type_reads=%0d h_reads=%0d external_bits=48 type_control_bits=13",op_arg,mode,commits,checked,scan_checked,type_checked,q_hold_cycles,type_hold_cycles,held_write_cycles,first_status,first_issued,first_retired,recovery,lease_count,release_count,op0_compared,q_reads,type_reads,h_reads);
  $fclose(progress_fd);compare_op0=0;@(negedge clk);external_control_enable=0;external_control_q='1;loaded=0;start_valid=1;repeat(3)begin step();if(type_rd_valid||type_rsp_ready||h_rd_valid||q_rd_valid||h_wr_valid||fp_lease_valid||fp_release_valid||done_valid||control_retired||idle||external_control_next!==external_control_q)$fatal(1,"INACTIVE_FOREIGN_Q");end
  $finish;
 end
'''
mon=base[base.index(' always @(negedge clk)'):]
mon=mon.replace('if((h_rd_valid&&h_rd_ready)!=(q_rd_valid&&q_rd_ready))', 'if(op_arg==0&&(h_rd_valid&&h_rd_ready)!=(q_rd_valid&&q_rd_ready))')
mon=mon.replace('   if(fp_protocol_fault)', '''   if(run_provider)begin if(q_rd_valid&&q_rd_ready)q_reads++;if(type_rd_valid&&type_rd_ready)type_reads++;if(h_rd_valid&&h_rd_ready)h_reads++;end
   if(epoch_fault&&add_rsp_valid[0]&&add_rsp_ready[0])epoch_fault_done<=1;
   if(!q_response_gate)begin q_hold_cycles<=q_hold_cycles+1;if(bank_q_rsp_ready||!raw_q_rsp_valid||q_rsp_addr!=0)$fatal(1,"Q_HELD_REAL");end
   if(!type_response_gate)begin type_hold_cycles<=type_hold_cycles+1;if(raw_type_ready||!raw_type_valid||raw_type_addr!=32)$fatal(1,"TYPE_HELD_REAL");end
   if(run_provider&&op_arg==1)begin
    if(h_rd_valid||bank_h_rd_valid||h_rsp_ready)$fatal(1,"TYPE_EXTRA_H_READ");
    if((q_rd_valid&&q_rd_ready)!=(type_rd_valid&&type_rd_ready))$fatal(1,"TYPE_ATOMIC_READ");
    if((q_rsp_valid&&q_rsp_ready)!=(type_rsp_valid&&type_rsp_ready))$fatal(1,"TYPE_ATOMIC_RESPONSE");
    if(type_rsp_valid&&q_rsp_valid&&type_rsp_addr!=q_rsp_addr&&add_req_valid[0])$fatal(1,"BAD_PAIR_FP_ACCEPT");
   end
   if(mode==3&&h_wr_valid&&h_wr_addr==4095&&!write_gate)begin if(h_wr_ready||raw_h_commit||done_valid||control_retired||fp_release_valid||!fp_lease_active||!add_rsp_valid[0]||add_rsp_ready[0])$fatal(1,"LAST_H_REAL_DEBT_BARRIER");end
   if(fp_protocol_fault)''')
old='if(!h_rsp_valid||!q_rsp_valid||h_rsp_addr!=q_rsp_addr||add_a[31:0]!==h_rsp_data||add_b[31:0]!==q_rsp_data||add_a[255:32]!==0||add_b[255:32]!==0)'
new='if(!q_rsp_valid||(op_arg==0?(!h_rsp_valid||h_rsp_addr!=q_rsp_addr||add_a[31:0]!==h_rsp_data||add_b[31:0]!==q_rsp_data):(!type_rsp_valid||type_rsp_addr!=q_rsp_addr||add_a[31:0]!==q_rsp_data||add_b[31:0]!==type_rsp_data))||add_a[255:32]!==0||add_b[255:32]!==0)';assert old in mon;mon=mon.replace(old,new)
mon=mon.replace('if(commits%128==0)begin','if(commits%128==0||mode>=4)begin')
s+=mon
(A/'tb/m007_type29_unit_tb.sv').write_text(s)
print('TYPE29 unit TB written')
