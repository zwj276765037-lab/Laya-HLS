`timescale 1ns/1ps
module m011_layer_rope_tb;
 logic clk,rst_n;
 logic start_valid;
 logic start_ready;
 logic[63:0]start_request_id;
 logic[31:0]start_generation,start_epoch;
 logic start_family;
 logic qkv_complete,coeff_complete;
 logic abort_valid;
 logic abort_ready;
 logic read_grant,fp_grant,write_grant;
 logic done_valid;
 logic done_ready;
 logic[7:0]done_status;
 logic[31:0]done_cycles,first_commit_cycle;
 logic[11:0]commits;
 logic error_valid;
 logic[63:0]error_rank;
 logic[4:0]error_stage;
 logic[31:0]error_element;
 logic resource_debt_clear;
 logic owner_valid;
 logic[63:0]request_id;
 logic[31:0]generation,epoch;
 logic fp_lease_valid;
 logic fp_lease_ready;
 logic fp_release_valid;
 logic fp_release_ready;
 logic fp_fault;
 logic[63:0]fp_rsp_request_id;
 logic[31:0]fp_rsp_generation,fp_rsp_epoch;
 logic[3:0]fp_rsp_head;
 logic[2:0]fp_rsp_phase;
 logic[6:0]fp_mul_pending;
 logic[6:0][6:0]fp_add_pending;
 logic[2:0]qkv_rd_valid;
 logic[2:0]qkv_rd_ready;
 logic[2:0][3:0]qkv_rd_head;
 logic[2:0][6:0]qkv_rd_token;
 logic[2:0][31:0]qkv_rd_tag;
 logic[2:0]qkv_rsp_valid;
 logic[2:0]qkv_rsp_ready;
 logic[2:0][3:0]qkv_rsp_head;
 logic[2:0][6:0]qkv_rsp_token;
 logic[2:0][31:0]qkv_rsp_tag;
 logic[2:0][63:0][31:0]qkv_rsp_data;
 logic coeff_rd_valid;
 logic coeff_rd_ready;
 logic coeff_rd_family;
 logic[6:0]coeff_rd_row;
 logic[95:0]coeff_rd_tag;
 logic coeff_rsp_valid;
 logic coeff_rsp_ready;
 logic coeff_rsp_family;
 logic[6:0]coeff_rsp_row;
 logic[95:0]coeff_rsp_tag;
 logic[127:0][31:0]coeff_rsp_data;
 logic mul_req_valid;
 logic mul_req_ready;
 logic[95:0]mul_req_tag;
 logic[255:0][31:0]mul_a,mul_b;
 logic mul_rsp_valid;
 logic mul_rsp_ready;
 logic[95:0]mul_rsp_tag;
 logic[255:0][31:0]mul_rsp_data;
 logic add_req_valid;
 logic add_req_ready;
 logic[95:0]add_req_tag;
 logic[255:0][31:0]add_a,add_b;
 logic add_rsp_valid;
 logic add_rsp_ready;
 logic[95:0]add_rsp_tag;
 logic[255:0][31:0]add_rsp_data;
 logic wr_valid;
 logic wr_ready;
 logic[3:0]wr_head;
 logic[6:0]wr_token;
 logic[95:0]wr_tag;
 logic[63:0][31:0]wr_q,wr_k;
 logic wr_commit_valid;
 logic[95:0]wr_commit_tag;
 initial clk=0;always #5 clk=~clk;
 logic load_valid,load_ready,load_half;logic[1:0]load_plane;logic[3:0]load_head;logic[6:0]load_token;logic[31:0][31:0]load_data;
 logic external_read;logic[2:0]ext_rd_valid,ext_rsp_ready,bank_rd_valid,bank_rd_ready,bank_rsp_valid,bank_rsp_ready;logic[2:0][3:0]ext_rd_head,bank_rd_head,bank_rsp_head;logic[2:0][6:0]ext_rd_token,bank_rd_token,bank_rsp_token;logic[2:0][31:0]ext_rd_tag,bank_rd_tag,bank_rsp_tag;logic[2:0][63:0][31:0]bank_rsp_data;
 logic coeff_bind_valid,coeff_bind_ready,coeff_bound;logic[63:0]coeff_model;logic[31:0]coeff_numeric;logic[127:0]coeff_key;logic[1:0]family_complete,table_sel;logic table_valid,table_ready,table_half,table_reject;logic[6:0]table_row;logic[31:0][31:0]table_data;logic[2:0]table_error,coeff_read_error;logic[4:0]table_bad_lane;logic coeff_read_reject;
 logic fp_active,fp_draining;logic[6:0]adds_valid,adds_root,adds_ready,adds_rsp_valid,adds_rsp_ready;logic[6:0][2:0]adds_phase;logic[6:0][31:0]adds_epoch;logic[6:0][95:0]adds_tag,adds_rsp_tag;
 logic bank_reject;logic[2:0]bank_reject_code;
 logic[31:0]pre[0:393215],postgold[0:393215],products[0:524287],cf[0:8191],sf[0:8191],cs[0:8191],ss[0:8191];
 string data,which,mode,file;int family_arg,write_count=0,product_vectors=0,commit_vectors=0,checked_product_words=0,checked_result_words=0,readback_words=0,hold_cycles=0,clock_count=0,last_commit=0;bit monitoring=0,was_held=0;logic[95:0]held_tag;logic[255:0][31:0]held_data;
 laya_attention_rope_engine_v1 dut(.*);
 assign qkv_complete=write_count==12288;assign coeff_complete=family_complete[family_arg];
 assign bank_rd_valid=external_read?ext_rd_valid:qkv_rd_valid;assign bank_rd_head=external_read?ext_rd_head:qkv_rd_head;assign bank_rd_token=external_read?ext_rd_token:qkv_rd_token;assign bank_rd_tag=external_read?ext_rd_tag:qkv_rd_tag;
 assign qkv_rd_ready=external_read?3'b0:bank_rd_ready;assign qkv_rsp_valid=external_read?3'b0:bank_rsp_valid;assign bank_rsp_ready=external_read?ext_rsp_ready:qkv_rsp_ready;
 assign qkv_rsp_head=bank_rsp_head;assign qkv_rsp_token=bank_rsp_token;assign qkv_rsp_tag=bank_rsp_tag;assign qkv_rsp_data=bank_rsp_data;
 laya_attention_qkv_bank_v2 qkv(.clk,.rst_n,.wr_valid(load_valid),.wr_ready(load_ready),.wr_plane(load_plane),.wr_head(load_head),.wr_token(load_token),.wr_half(load_half),.wr_data(load_data),.rd_valid(bank_rd_valid),.rd_ready(bank_rd_ready),.rd_head(bank_rd_head),.rd_token(bank_rd_token),.rd_tag(bank_rd_tag),.rd_rsp_valid(bank_rsp_valid),.rd_rsp_ready(bank_rsp_ready),.rd_rsp_head(bank_rsp_head),.rd_rsp_token(bank_rsp_token),.rd_rsp_tag(bank_rsp_tag),.rd_rsp_data(bank_rsp_data),
 .rope_owner_valid(owner_valid),.rope_owner_request_id(request_id),.rope_owner_generation(generation),.rope_owner_epoch(epoch),.rope_wr_valid(wr_valid),.rope_wr_ready(wr_ready),.rope_wr_request_id(request_id),.rope_wr_generation(generation),.rope_wr_epoch(epoch),.rope_wr_head(wr_head),.rope_wr_token(wr_token),.rope_wr_tag(wr_tag),.rope_wr_q(wr_q),.rope_wr_k(wr_k),.rope_wr_commit_valid(wr_commit_valid),.rope_wr_commit_tag(wr_commit_tag),.rope_reject_valid(bank_reject),.rope_reject_code(bank_reject_code));
 laya_rope_coeff_cache_v1 coeff(.clk,.rst_n,.bind_valid(coeff_bind_valid),.bind_ready(coeff_bind_ready),.bind_model_id(64'h12),.bind_numeric_id(32'h34),.bind_table_key(128'h5678),.bound_valid(coeff_bound),.bound_model_id(coeff_model),.bound_numeric_id(coeff_numeric),.bound_table_key(coeff_key),.family_complete,
 .wr_valid(table_valid),.wr_ready(table_ready),.wr_model_id(64'h12),.wr_numeric_id(32'h34),.wr_table_key(128'h5678),.wr_table(table_sel),.wr_row(table_row),.wr_half(table_half),.wr_data(table_data),.wr_reject_valid(table_reject),.wr_reject_code(table_error),.wr_nonfinite_lane(table_bad_lane),
 .owner_valid,.owner_request_id(request_id),.owner_generation(generation),.owner_epoch(epoch),.rd_valid(coeff_rd_valid),.rd_ready(coeff_rd_ready),.rd_family(coeff_rd_family),.rd_row(coeff_rd_row),.rd_tag(coeff_rd_tag),.rd_request_id(request_id),.rd_generation(generation),.rd_epoch(epoch),.rd_reject_valid(coeff_read_reject),.rd_reject_code(coeff_read_error),.rsp_valid(coeff_rsp_valid),.rsp_ready(coeff_rsp_ready),.rsp_family(coeff_rsp_family),.rsp_row(coeff_rsp_row),.rsp_tag(coeff_rsp_tag),.rsp_data(coeff_rsp_data));
 assign adds_valid={6'b0,add_req_valid};assign adds_root=0;assign add_req_ready=adds_ready[0];assign add_rsp_valid=adds_rsp_valid[0];assign add_rsp_tag=adds_rsp_tag[0];assign adds_rsp_ready={6'b0,add_rsp_ready};
 always_comb begin adds_phase=0;adds_epoch=0;adds_tag=0;for(int g=0;g<7;g++)begin adds_phase[g]=7;adds_epoch[g]=epoch;adds_tag[g]=add_req_tag;end end
 laya_shared_fp256_v2 fp(.clk,.rst_n,.lease_valid(fp_lease_valid),.lease_ready(fp_lease_ready),.lease_request_id(request_id),.lease_generation(generation),.lease_epoch(epoch),.lease_head(4'b0),.lease_phase(3'd7),.release_valid(fp_release_valid),.release_ready(fp_release_ready),.release_phase(3'd7),.release_epoch(epoch),.phase_debt_clear(resource_debt_clear),.lease_active(fp_active),.draining(fp_draining),.rsp_request_id(fp_rsp_request_id),.rsp_generation(fp_rsp_generation),.rsp_epoch(fp_rsp_epoch),.rsp_head(fp_rsp_head),.rsp_phase(fp_rsp_phase),
 .mul_req_valid,.mul_req_ready,.mul_req_phase(3'd7),.mul_req_epoch(epoch),.mul_req_tag,.mul_a,.mul_b,.mul_rsp_valid,.mul_rsp_ready,.mul_rsp_tag,.mul_rsp_data,
 .add_req_valid(adds_valid),.add_req_is_root(adds_root),.add_req_ready(adds_ready),.add_req_phase(adds_phase),.add_req_epoch(adds_epoch),.add_req_tag(adds_tag),.add_a,.add_b,.add_rsp_valid(adds_rsp_valid),.add_rsp_ready(adds_rsp_ready),.add_rsp_tag(adds_rsp_tag),.add_rsp_data,.mul_pending(fp_mul_pending),.add_pending(fp_add_pending),.protocol_fault(fp_fault));
 function automatic logic[31:0]coefficient(input int t,r,c);case(t)0:return cf[r*64+c];1:return sf[r*64+c];2:return cs[r*64+c];3:return ss[r*64+c];endcase endfunction
 function automatic int qindex(input int t,p,h,c);return ((t*3+p)*16+h)*64+c;endfunction
 task automatic step;@(posedge clk);#1;endtask
 task automatic coefficients;
  @(negedge clk);coeff_bind_valid=1;#1;if(!coeff_bind_ready)$fatal(1,"coeff bind");step();@(negedge clk);coeff_bind_valid=0;
  for(int t=0;t<4;t++)for(int r=0;r<128;r++)for(int h=0;h<2;h++)begin
   table_valid=1;table_sel=t;table_row=r;table_half=h;for(int c=0;c<32;c++)table_data[c]=coefficient(t,r,h*32+c);
   #1;if(!table_ready||table_reject)$fatal(1,"table write");step();@(negedge clk);
  end table_valid=0;if(family_complete!==3)$fatal(1,"coeff complete");
 endtask
 task automatic qkvload;
  write_count=0;
  for(int t=0;t<128;t++)for(int p=0;p<3;p++)for(int h=0;h<16;h++)for(int half=0;half<2;half++)begin
   @(negedge clk);load_valid=1;load_plane=p;load_head=h;load_token=t;load_half=half;for(int c=0;c<32;c++)load_data[c]=pre[qindex(t,p,h,half*32+c)];
   #1;if(!load_ready)$fatal(1,"QKV load not ready");if(write_count<12287&&start_ready)$fatal(1,"premature complete");step();write_count++;
  end
  @(negedge clk);load_valid=0;
 endtask
 task automatic beginrun(input int gen);
  @(negedge clk);start_generation=gen;start_valid=1;#1;if(!start_ready)$fatal(1,"start not ready");product_vectors=0;commit_vectors=0;checked_product_words=0;checked_result_words=0;hold_cycles=0;last_commit=0;was_held=0;monitoring=1;step();@(negedge clk);start_valid=0;
 endtask
 task automatic consume_done(input int status);
  while(!done_valid)step();if(done_status!=status)$fatal(1,"status%0d expected%0d stage%0d element%0d",done_status,status,error_stage,error_element);
  if(!resource_debt_clear||fp_active||owner_valid)$fatal(1,"DONE before actual debt release");repeat(3)begin step();if(!done_valid||start_ready)$fatal(1,"DONE hold");end
  @(negedge clk);done_ready=1;step();@(negedge clk);done_ready=0;monitoring=0;
 endtask
 task automatic readback;
  @(negedge clk);external_read=1;
  for(int h=0;h<16;h++)for(int t=0;t<128;t++)begin
   ext_rd_valid=7;ext_rsp_ready=0;for(int p=0;p<3;p++)begin ext_rd_head[p]=h;ext_rd_token[p]=t;ext_rd_tag[p]=32'(h*128+t);end
   #1;if(bank_rd_ready!==7)$fatal(1,"readback ready");step();
   if(bank_rsp_valid!==7)$fatal(1,"readback response");for(int p=0;p<3;p++)begin
    if(bank_rsp_head[p]!=h||bank_rsp_token[p]!=t||bank_rsp_tag[p]!=h*128+t)$fatal(1,"readback identity");
    for(int c=0;c<64;c++)begin if(bank_rsp_data[p][c]!==postgold[qindex(t,p,h,c)])$fatal(1,"readback mismatch h%0d t%0d p%0d c%0d",h,t,p,c);readback_words++;end
   end
   @(negedge clk);ext_rd_valid=0;
   if(h==15&&t==127)repeat(3)begin step();if(bank_rsp_valid!==7)$fatal(1,"last read held");end
   ext_rsp_ready=7;step();@(negedge clk);ext_rsp_ready=0;
  end external_read=0;
 endtask
 always@(negedge clk)begin
  if(mode=="stall"&&owner_valid)begin read_grant=clock_count%17!=5&&clock_count%17!=6;fp_grant=clock_count%13!=4;write_grant=clock_count%31<27;end
  else begin read_grant=1;fp_grant=1;write_grant=1;end
 end
 always@(posedge clk)begin
  clock_count++;
  if(rst_n&&monitoring)begin
   if(fp_fault||bank_reject)$fatal(1,"resource protocol fault");
   if(was_held)begin if(!add_rsp_valid||add_rsp_tag!==held_tag||add_rsp_data!==held_data)$fatal(1,"held final vector/tag changed");end
   was_held=add_rsp_valid&&!add_rsp_ready;if(was_held)begin hold_cycles++;held_tag=add_rsp_tag;held_data=add_rsp_data;end
   if(mul_rsp_valid&&mul_rsp_ready&&!dut.aborted)begin
    for(int p=0;p<2;p++)for(int j=0;j<32;j++)for(int m=0;m<4;m++)begin
     if(mul_rsp_data[(p*32+j)*4+m]!==products[(p*4+m)*65536+(int'(mul_rsp_tag[6:0])*16+int'(mul_rsp_tag[10:7]))*32+j])$fatal(1,"product h%0d t%0d p%0d pair%0d m%0d",mul_rsp_tag[10:7],mul_rsp_tag[6:0],p,j,m);checked_product_words++;
    end product_vectors++;
   end
   if(wr_commit_valid)begin
    if(wr_commit_tag!==wr_tag||!wr_valid||!wr_ready)$fatal(1,"commit identity");
    if(mode=="normal"&&last_commit!=0&&clock_count-last_commit!=1)$fatal(1,"normal RoPE II not1");last_commit=clock_count;
    for(int c=0;c<64;c++)begin
     if(wr_q[c]!==postgold[qindex(wr_token,0,wr_head,c)]||wr_k[c]!==postgold[qindex(wr_token,1,wr_head,c)])$fatal(1,"RoPE final h%0d t%0d c%0d",wr_head,wr_token,c);checked_result_words+=2;
    end commit_vectors++;
   end
  end
 end
 initial begin
  if(!$value$plusargs("DATA=%s",data))$fatal(1,"DATA");if(!$value$plusargs("CASE=%s",which))which="encoder0";if(!$value$plusargs("MODE=%s",mode))mode="normal";family_arg=which=="encoder1";
  $readmemh({data,"/",which,"_pre_qkv.mem"},pre);$readmemh({data,"/",which,"_post_qkv.mem"},postgold);
  $readmemh({data,"/cos_full.mem"},cf);$readmemh({data,"/sin_full.mem"},sf);$readmemh({data,"/cos_slide.mem"},cs);$readmemh({data,"/sin_slide.mem"},ss);
  for(int p=0;p<2;p++)for(int m=0;m<4;m++)begin file=$sformatf("%s/%s_rope_p%0d_m%0d.mem",data,which,p,m);$readmemh(file,products,(p*4+m)*65536,(p*4+m+1)*65536-1);end
  rst_n=0;start_valid=0;start_request_id=77;start_generation=8;start_epoch=9;start_family=family_arg;abort_valid=0;done_ready=0;read_grant=1;fp_grant=1;write_grant=1;load_valid=0;load_half=0;load_plane=0;load_head=0;load_token=0;load_data=0;external_read=0;ext_rd_valid=0;ext_rsp_ready=0;ext_rd_head=0;ext_rd_token=0;ext_rd_tag=0;coeff_bind_valid=0;table_valid=0;table_sel=0;table_row=0;table_half=0;table_data=0;
  repeat(3)step();@(negedge clk);rst_n=1;coefficients();qkvload();beginrun(8);
  if(mode=="abort")begin
   while(commits<8)step();if(fp_mul_pending==0||fp_add_pending==0)$fatal(1,"abort lacks actual FP debts");@(negedge clk);abort_valid=1;step();@(negedge clk);abort_valid=0;consume_done(2);
   qkvload();beginrun(9);
  end else if(mode=="reset")begin
   while(commits<8)step();if(fp_mul_pending==0||fp_add_pending==0)$fatal(1,"reset lacks actual FP debts");@(negedge clk);monitoring=0;rst_n=0;repeat(3)step();if(done_valid||fp_active||bank_rsp_valid!=0||coeff_rsp_valid)$fatal(1,"common reset state");@(negedge clk);rst_n=1;write_count=0;coefficients();qkvload();beginrun(9);
  end
  while(!done_valid)step();if(done_status!=0||error_valid)$fatal(1,"normal error status%0d stage%0d",done_status,error_stage);
  if(commits!=2048||commit_vectors!=2048||product_vectors!=2048||checked_product_words!=524288||checked_result_words!=262144)$fatal(1,"coverage commit%0d products%0d",commits,product_vectors);
  if(mode=="normal"&&(done_cycles>2176||first_commit_cycle>32))$fatal(1,"RoPE cycle bound first%0d total%0d",first_commit_cycle,done_cycles);
  $display("M011_ROPE_NORMAL case=%s mode=%s cycles=%0d first=%0d commits=%0d product_words=%0d QK_words=%0d held_cycles=%0d",which,mode,done_cycles,first_commit_cycle,commits,checked_product_words,checked_result_words,hold_cycles);
  consume_done(0);readback();if(readback_words!=393216)$fatal(1,"readback count");
  $display("HARDWARE_AGENT_SIM_PASS M011_LAYER_ROPE case=%s mode=%s public_QKV32=12288 atomic_QK64=2048 original_products=524288 final_QK=262144 V_unchanged=131072 bank_readback=393216",which,mode);$finish;
 end
 initial begin repeat(100000)@(posedge clk);$fatal(1,"cycle cap");end
endmodule
