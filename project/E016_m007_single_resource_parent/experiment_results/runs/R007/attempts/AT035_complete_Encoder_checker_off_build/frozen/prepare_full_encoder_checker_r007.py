#!/usr/bin/env python3
"""Prepare v3 Encoder0 checker from immutable R006 + current v3 setup.

Source/byte preparation only. Does not compile, run EDA or evaluate F32.
The running AT026 snapshot and its source files are never written here.
"""
from pathlib import Path
import hashlib,json,re,time

ROOT=Path(__file__).resolve().parents[3]
M=ROOT/'project/E002_Laya_HLS/experiment/vivado/module_design'
R=ROOT/'project/E016_m007_single_resource_parent/experiment_results/runs/R007'
OLD=R.parent/'R006/attempts/AT014_CE_fixed_capture_minimum_prefix_build/frozen/m007_encoder0_complete_tb.sv'
CURRENT=R/'attempts/AT026_parent_normal_cost_checker_build/frozen/m007_fullmodel_parent_tb.sv'
OUT=M/'forward_controller/tb/m007_fullmodel_encoder_tb.sv'

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def replace_once(s,a,b):
 assert s.count(a)==1,(a,s.count(a))
 return s.replace(a,b,1)

def main():
 start=time.monotonic();old=OLD.read_text();cur=CURRENT.read_text()
 # Frozen old numerical/lease/event assertions remain the checker baseline.
 body=old[old.index(' laya_m007_single_parent_v2 dut'):old.index('\n initial begin')]
 intro=cur[cur.index(' localparam logic[255:0] PLATFORM_SHA'):cur.index(' always #1 clk')]
 body=replace_once(body,' laya_m007_single_parent_v2 dut(.*);',intro.rstrip())
 body=body.replace('kind_run==4','kind_run==5').replace('kind_run!=4','kind_run!=5').replace('kind_run=4','kind_run=5')
 # The v3 device catalog is the actual descriptor producer. The public v2
 # descriptor task/monitor must not survive as a second producer.
 a=body.index(' task automatic descriptor(');b=body.index(' always_comb arready=15;',a)
 body=body[:a]+body[b:]
 body=replace_once(body,' always_comb arready=15;\n','')
 body=replace_once(body,'  else for(int p=0;p<4;p++)if(!rvalid[p]||last_r_fire[p])begin','  else if(!dut.catalog_owns)begin\n   arready=15;\n   for(int p=0;p<4;p++)if(!rvalid[p]||last_r_fire[p])begin')
 body=replace_once(body,'  if(rst_n)begin\n   out_ready=1;','  end\n  if(rst_n&&full_active)begin\n   out_ready=1;')
 body=replace_once(body,'  cycle++;last_r_fire<=rvalid&rready;','  last_r_fire<=rvalid&rready;')
 body=replace_once(body,'  else begin\n   if(parent_state!=old_state)','  else if(full_active)begin\n   if(parent_state!=old_state)')
 a=body.index('   if(desc_valid&&desc_ready)begin');b=body.index('   if(dut.q_cmd_valid',a)
 body=body[:a]+body[b:]
 body=body.replace('descriptors!=2','catalog_runtime!=4')
 body=replace_once(body,'   for(int p=0;p<4;p++)begin\n    if(arvalid[p]&&arready[p])begin','   if(!dut.catalog_owns)for(int p=0;p<4;p++)begin\n    if(arvalid[p]&&arready[p])begin')
 body=replace_once(body,'   if(out_valid&&out_ready)begin\n    if(kind_run==5)','   if(out_valid&&out_ready)begin\n    if(out_slot!=0)$fatal(1,"single Encoder output slot");\n    if(kind_run==5)')
 body=replace_once(body,'   if(done_valid)begin\n    if({done_status','   if(done_valid)begin\n    if(done_op!=2)$fatal(1,"v3 BEGIN receipt op");\n    if({done_status')
 body=body.replace('.receipt_fire(done_valid&&done_ready)', '.receipt_fire(full_active&&done_op==2&&done_valid&&done_ready)').replace('.command_fire(cmd_valid&&cmd_ready)', '.command_fire(full_active&&cmd_valid&&cmd_ready)')
 # Only original model coefficient/setup/catalog and real external tail peer
 # are copied from the v3 snapshot. The tail peer is retained for kind7 work;
 # this prepared mathematical top accepts only kind5/layer0.
 extra='''
 logic full_active=0;integer mode=9,ar_count=0,r_count=0,model_count=0,h_count=0,catalog_runtime=0;
 integer bus_word=0,held_word=0;logic pending=0,drain_pending=0,fault_injected=0,response_consumed=0;
 logic[63:0]held_addr;logic held_ar=0;
 logic[511:0]catalog_mem[0:127];logic[31:0]bias_mem[0:18431],gamma_mem[0:1023],type_mem[0:3071];
 logic[31:0]rope_mem[0:3][0:8191];string data_dir,rope_dir;
'''
 tail=cur[cur.index(' // SIM D2H peer'):cur.index(' task automatic step;')]
 tasks=cur[cur.index(' task automatic step;'):cur.index(' // One actual catalog request')]
 tasks=re.sub(r' task automatic progress\(.*?\n endtask', ' task automatic progress(input int n,input string phase);begin checked(n,phase);end endtask',tasks,count=1,flags=re.S)
 body=replace_once(body,' task automatic step;begin @(posedge clk);#0.1;end endtask\n','')
 catalog=cur[cur.index(' // One actual catalog request'):cur.index(' always@(negedge clk)if(rst_n&&!dut.catalog_owns)')]
 common=cur[cur.index(' always@(posedge clk)if(rst_n)begin\n  cycle++;'):cur.index('  if(mode==5||mode==8)begin\n   if(cmd_valid')]
 common=common.replace('if(dut.runtime_catalog&&dut.cat_rsp_valid&&dut.cat_rsp_ready&&!dut.cat_fault)catalog_runtime++;', '''if(dut.runtime_catalog&&dut.cat_rsp_valid&&dut.cat_rsp_ready&&!dut.cat_fault)begin
   if(catalog_runtime>=4||dut.cat_word!=4+catalog_runtime||!dut.m_transport_idle||!dut.q_cmd_ready||dut.q_done_valid)$fatal(1,"runtime refill before real old debt retirement/order");
   if(catalog_runtime>=2&&(m_done_count[1]!=1||ctx_responses!=4096||!dut.l_layer_idle||dut.v2_scratch_owner_active))$fatal(1,"FFN catalog before true WO/context/scratch retirement");
   catalog_runtime++;$display("M007_FULLMODEL_ENCODER0_CATALOG_REFILL count=%0d epoch=%0d cycle=%0d",catalog_runtime,dut.operation_epoch,cycle);$fflush();
  end''')
 common+='  if(cycle>40000000)$fatal(1,"40Mcycle watchdog");\n end\n'
 # All old references/packing/coverage arrays are loaded identically. These
 # bytes are expected values, never a producer of intermediate activations.
 defaults=cur[cur.index(' initial begin')+len(' initial begin'):cur.index('  if(!$value$plusargs("DATA=')]
 init=old[old.index('  if(!$value$plusargs("ORIGINAL='):old.index('  for(int ph=0;ph<4;ph++)for(int p=0;p<4;p++)begin fixture_base')]
 init=init.replace('kind_run==4','kind_run==5').replace('kind_run=4','kind_run=5')
 init=init.replace('(kind_run==3||kind_run==5)','(kind_run==5)')
 addresses=json.loads((ROOT/'project/E020_m007_model_catalog/experiment_results/runs/R001/attempts/AT002_host_fix/work/host/sim_addresses.json').read_text())
 for ph,record in enumerate(addresses['records'][:4]):
  for port in range(4):init+=f"  fixture_base[{ph}][{port}]=64'd{record['base'][port]};fixture_span[{ph}][{port}]=64'd{record['span'][port]};\n"
 config=cur[cur.index('  cmd_model_id=dut.MODEL_ID;'):cur.index('  repeat(4)step();@(negedge clk);rst_n=1;')]
 config=config.replace("cmd_mask=mode==8?128'h00000000000000ffffffffffffffffff:'1;","cmd_mask=128'h00000000000000ffffffffffffffffff;")
 setup='''
  if(!$value$plusargs("DATA=%s",data_dir))$fatal(1,"v3 original model coefficients required");
  rope_dir=attention_fixture;
  $readmemh({data_dir,"/catalog.hex"},catalog_mem);$readmemh({data_dir,"/bias.words.hex"},bias_mem);$readmemh({data_dir,"/gamma.words.hex"},gamma_mem);$readmemh({data_dir,"/type.words.hex"},type_mem);
  $readmemh({rope_dir,"/cos_full.mem"},rope_mem[0]);$readmemh({rope_dir,"/sin_full.mem"},rope_mem[1]);$readmemh({rope_dir,"/cos_slide.mem"},rope_mem[2]);$readmemh({rope_dir,"/sin_slide.mem"},rope_mem[3]);
'''+config+'''
  if(cmd_mask!==128'h00000000000000ffffffffffffffffff)$fatal(1,"original B1 mask required");
  for(int row=0;row<128;row++)if(cmd_mask[row]!==maskmem[row][0])$fatal(1,"B1 mask differs from independent original fixture");
  repeat(4)step();@(negedge clk);rst_n=1;wait(cmd_ready);
  load_rope();send_setup();wait(parent_state==65);for(int j=0;j<576;j++)offer_word(0,j);
  wait(parent_state==68);for(int j=0;j<32;j++)offer_word(1,j);
  wait(parent_state==70);for(int j=0;j<96;j++)offer_word(2,j);
  consume_done(0,0,0,0);if(!model_committed||model_count!=704||ar_count!=124||r_count!=124)$fatal(1,"complete real v3 setup");
  full_active=1;out_ready=1;send_begin();wait(parent_state==32);
  for(int index=0;index<4096;index++)begin
   @(negedge clk);in_valid=1;in_data=initial_h[index];in_request=cmd_request;in_generation=cmd_generation;in_epoch=cmd_epoch;in_row=index/32;in_group=index%32;
   do @(posedge clk);while(!in_ready);
  end
  @(negedge clk);in_valid=0;
'''
 finish=old[old.index('  wait(done_valid);@(negedge clk);repeat(5)'):old.rindex('\nendmodule')]
 finish=finish.replace('kind_run==4','kind_run==5').replace('descriptors!=2','catalog_runtime!=4')
 # Event family rewrite is applied uniformly below.
 prefix=cur[:cur.index(' localparam logic[255:0] PLATFORM_SHA')].replace('module m007_fullmodel_parent_tb;','module m007_fullmodel_encoder_tb;')
 body=body.replace('logic [1046:0] held_out','logic [1051:0] held_out').replace('{out_data,out_row,out_col}','{out_data,out_row,out_col,out_slot}')
 body=body.replace('M007_ENCODER0_', 'M007_FULLMODEL_ENCODER0_').replace('M007_PARENT_HEAD_', 'M007_FULLMODEL_HEAD_')
 finish=finish.replace('M007_ENCODER0_', 'M007_FULLMODEL_ENCODER0_')
 out=prefix+extra+body+'\n'+tail+tasks+catalog+common+'\n initial begin'+defaults+init+setup+finish+'\nendmodule\n'
 assert not re.search(r'\b(?:desc_valid|desc_request|desc_base|desc_span|cmd_tensor|cmd_base|cmd_span|bias_model_id|bias_numeric_id)\b',out)
 assert out.count('module m007_fullmodel_encoder_tb;')==1 and out.count('laya_m007_single_parent_v3 #(')==1
 OUT.write_text(out)
 report={'schema':'m007-r007-full-Encoder-checker-source-v1','status':'SOURCE_PREPARED_NOT_COMPILED_NOT_RUN','source':str(OUT.relative_to(ROOT)),'source_sha256':sha(OUT),'generator_sha256':sha(Path(__file__)),'old_checker':str(OLD.relative_to(ROOT)),'old_checker_sha256':sha(OLD),'v3_setup_checker':str(CURRENT.relative_to(ROOT)),'v3_setup_checker_sha256':sha(CURRENT),'kind':5,'layer':0,'original_B1_mask128':'00000000000000ffffffffffffffffff','numeric_oracle_recomputed':False,'running_AT031_snapshot_untouched':True,'kept':['four full matrix/A/W/prebias/issue/PS assertions','full original Attention and 16head coverage','R005 original G FP9/TANH/output and timing','actual WO/residual/LN/Q-to-quant-to-Wi chain','Down/residual/finalH original checkpoint','actual output holding and held/retired independent DONE','real public F32 capture','current real SIM tail writer source'],'changes':['v3 ABI/setup and model catalog peer','runtime catalog replaces old Host descriptor driver','four real AR origins use E020 SIM bases and per-ID locked source','single Encoder kind5 only; kind7 original production graph unchanged'],'NOT_RUN':['SV compilation','new full-top mathematical execution','current full-Encoder cost gate','kind7 full graph'],'source_preparation_wall_s':time.monotonic()-start}
 (R/'full_encoder_checker_source_preparation.json').write_text(json.dumps(report,indent=2)+'\n')
 print(json.dumps(report))

if __name__=='__main__':main()
