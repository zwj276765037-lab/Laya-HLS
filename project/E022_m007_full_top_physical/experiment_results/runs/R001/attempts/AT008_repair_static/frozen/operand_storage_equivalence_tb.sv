`timescale 1ns/1ps
module operand_storage_equivalence_tb;
 logic clk=0,rst_n=1;
 logic [2:0] state=2;
 logic [63:0][3:0] pool_state;
 logic [12:0] issue_count=8191,mul_next=0,ps_next=0,add_next=0,write_next=0;
 logic format_valid=0,mul_rsp_valid=0,mul_rsp_ready=1,ps_rd_rsp_valid=0,ps_rd_rsp_ready=1,ps_rsp_math=0;
 logic [95:0] format_tag=0,mul_rsp_tag=0,ps_rd_rsp_tag=0,ps_wr_rsp_tag=0;
 logic [6:0] add_rsp_valid=0,add_rsp_ready=1;
 logic [6:0][95:0] add_rsp_tag=0;
 logic [255:0][31:0] converted,products,mul_rsp_data,add_rsp_data;
 logic [1023:0][31:0] ps_rd_rsp_data;
 logic ctx=0,ps_rsp_bias=0,ps_rsp_retire=0,out_hold_valid=0,out_ready=1;
 wire [255:0][31:0] old_mul_a,old_mul_b,old_add_a,old_add_b,old_trace_commit_data;
 wire [255:0][31:0] new_mul_a,new_mul_b,new_add_a,new_add_b,new_trace_commit_data;
 wire [1023:0][31:0] old_ps_wr_data,new_ps_wr_data;
 wire [1023:0] old_ps_wr_mask,new_ps_wr_mask;
 wire [1023:0][3:0] old_ps_wr_addr,new_ps_wr_addr;
 old_storage old_dut(.*, .mul_a(old_mul_a),.mul_b(old_mul_b),.add_a(old_add_a),.add_b(old_add_b),.trace_commit_data(old_trace_commit_data),.ps_wr_data(old_ps_wr_data),.ps_wr_mask(old_ps_wr_mask),.ps_wr_addr(old_ps_wr_addr));
 new_storage new_dut(.*, .mul_a(new_mul_a),.mul_b(new_mul_b),.add_a(new_add_a),.add_b(new_add_b),.trace_commit_data(new_trace_commit_data),.ps_wr_data(new_ps_wr_data),.ps_wr_mask(new_ps_wr_mask),.ps_wr_addr(new_ps_wr_addr));
 integer cycles=0,checks=0,pool0_cases=0,pool1_cases=0,x_cases=0,reset_cases=0,hold_cases=0;
 bit [63:0] format_seen=0,mul_seen=0,add_seen=0,ps_seen=0,read_seen=0;
 bit [31:0] zero_seen=0;
 bit [7:0] combo0[0:4],combo1[0:4];
 bit [1:0] ctx_seen=0;
 bit [31:0] data_ones=0,data_zeros=0;
 task automatic payload(input integer n);
  for(integer l=0;l<256;l++)begin
   converted[l]=(32'h9e3779b9*(l+1))^(32'h85ebca6b*(n+1));
   products[l]=~converted[l];mul_rsp_data[l]=converted[l]^32'ha5a5a5a5;
   add_rsp_data[l]=converted[l]^32'h3c6ef372;
   data_ones|=converted[l];data_zeros|=~converted[l];
  end
  for(integer l=0;l<1024;l++)ps_rd_rsp_data[l]=(32'hc2b2ae35*(l+1))^(32'h27d4eb2f*(n+1));
 endtask
 task automatic clear_events;
  format_valid=0;mul_rsp_valid=0;mul_rsp_ready=1;add_rsp_valid=0;add_rsp_ready=1;add_rsp_tag=0;
  ps_rd_rsp_valid=0;ps_rd_rsp_ready=1;ps_rsp_math=0;ps_rsp_bias=0;ps_rsp_retire=0;
  out_hold_valid=0;out_ready=1;rst_n=1;state=2;pool_state='0;issue_count=8191;ps_next=64;
 endtask
 task automatic compare_all;
  for(integer s=0;s<64;s++)begin
   if(old_dut.op0[s]!==new_dut.op0[s])$fatal(1,"op0 mismatch cycle=%0d slot=%0d",cycles,s);
   if(old_dut.op1[s]!==new_dut.op1[s])$fatal(1,"op1 mismatch cycle=%0d slot=%0d",cycles,s);
  end
  if({old_mul_a,old_mul_b,old_add_a,old_add_b,old_trace_commit_data,old_ps_wr_data,old_ps_wr_mask,old_ps_wr_addr}!=={new_mul_a,new_mul_b,new_add_a,new_add_b,new_trace_commit_data,new_ps_wr_data,new_ps_wr_mask,new_ps_wr_addr})$fatal(1,"async read mismatch cycle=%0d",cycles);
  checks++;
 endtask
 task automatic step;
  #1;compare_all();clk=1;#1;compare_all();clk=0;#1;cycles++;
  if(cycles>100000)$fatal(1,"cycle cap");
 endtask
 task automatic addresses(input integer f,input integer m,input integer a,input integer p,input integer z,input integer n);
  format_tag=f;mul_rsp_tag=m;add_rsp_tag[0]=a;
  ps_rd_rsp_tag=0;ps_rd_rsp_tag[18:13]=p;ps_rd_rsp_tag[28]=n%2;
  // Half selector bit16 belongs to the coherent slot field [18:13].
  if(ps_rd_rsp_tag[16]!==((p>>3)&1))$fatal(1,"incoherent PS tag");
  ps_next=z;mul_next=n%64;add_next=(n+17)%64;write_next=(n+31)%64;ps_wr_rsp_tag=(n+43)%64;
  pool_state='0;pool_state[add_next]=6;pool_state[write_next]=8;
  if(z<32)pool_state[z]=4;
  read_seen[mul_next]=1;read_seen[add_next]=1;read_seen[write_next]=1;read_seen[ps_wr_rsp_tag[5:0]]=1;
  ctx=n%2;
 endtask
 initial begin
  integer f,m,a,p,z,b;
  for(integer c=0;c<5;c++)begin combo0[c]=0;combo1[c]=0;end
  clear_events();payload(0);step(); // Actual uninitialized four-state pools and reads.
  for(integer s=0;s<64;s++)begin
   clear_events();payload(s);addresses(s,s,s,s,64,s);format_valid=1;format_seen[s]=1;step();
  end
  // Reset does not clear initialized data; every write is coincident with reset.
  for(integer s=0;s<64;s++)begin
   clear_events();payload(100+s);addresses(s,s,s,s,s%32,s);
   format_valid=1;mul_rsp_valid=1;add_rsp_valid=1;ps_rd_rsp_valid=1;ps_rsp_math=1;rst_n=0;reset_cases++;step();
  end
  // Three writers, all eight enable combinations, all five equality classes.
  for(integer pool=0;pool<2;pool++)for(integer s=0;s<64;s++)for(integer cl=0;cl<5;cl++)for(integer mask=0;mask<8;mask++)begin
   clear_events();payload(cycles);b=pool?s%32:s;
   f=b;m=(b+1)%64;a=(b+2)%64;
   case(cl)
    0:begin m=b;a=b;end
    1:begin end
    2:m=b;
    3:a=b;
    4:a=m;
   endcase
   if(pool==0)begin
    addresses(f,m,a,s,64,s+mask);format_valid=mask[0];mul_rsp_valid=mask[1];add_rsp_valid[0]=mask[2];
    if(mask[0])format_seen[f]=1;if(mask[1])mul_seen[m]=1;if(mask[2])add_seen[a]=1;
    combo0[cl][mask]=1;pool0_cases++;
   end else begin
    // f,z,p equality classes. z must stay in the actual first-group domain 0..31.
    z=m%32;p=a;
    if(cl==1||cl==3)z=(b+1)%32;
    if(cl==2)z=b;
    if(cl==4)p=z;
    if(cl==0)begin z=b;p=b;end
    addresses(f,0,0,p,z,s+mask);format_valid=mask[0];
    if(!mask[1])pool_state[z]=0;
    ps_rd_rsp_valid=mask[2];ps_rsp_math=1;
    if(mask[0])format_seen[f]=1;if(mask[1])zero_seen[z]=1;if(mask[2])ps_seen[p]=1;
    combo1[cl][mask]=1;ctx_seen[ps_rd_rsp_tag[28]]=1;pool1_cases++;
   end
   step();
  end
  // PS payload to every legal slot in both contexts, including bit16 overlap.
  for(integer c=0;c<2;c++)for(integer s=0;s<64;s++)begin
   clear_events();payload(cycles);addresses(s,s,s,s,64,s);
   ps_rd_rsp_tag[28]=c;ps_rd_rsp_valid=1;ps_rsp_math=1;ps_seen[s]=1;ctx_seen[c]=1;step();
  end
  // Return writes are allowed outside RUN; RUN writers must hold.
  for(integer st=0;st<5;st++)for(integer s=0;s<64;s++)begin
   clear_events();payload(cycles);addresses(s,(s+1)%64,(s+2)%64,(s+3)%64,s%32,s);
   state=st;format_valid=1;mul_rsp_valid=1;add_rsp_valid=1;ps_rd_rsp_valid=1;ps_rsp_math=1;step();
  end
  // Disabled ready/math/bias return guards, no-write holds, and read bias priority.
  for(integer s=0;s<64;s++)begin
   clear_events();payload(cycles);addresses(s,s,s,s,64,s);hold_cases++;step();
   mul_rsp_valid=1;mul_rsp_ready=0;add_rsp_valid=1;add_rsp_ready=0;ps_rd_rsp_valid=1;ps_rd_rsp_ready=0;step();
   mul_rsp_valid=0;ps_rd_rsp_ready=1;ps_rsp_math=0;ps_rsp_bias=1;out_hold_valid=1;out_ready=0;step();
   add_rsp_ready=1;add_rsp_tag[0][30]=1;step();
  end
  // Four-state data and guards; known slot domain is retained.
  for(integer s=0;s<64;s++)begin
   clear_events();payload(cycles);addresses(s,s,s,s,s%32,s);
   converted[s%256]='x;products[(s+1)%256]='z;format_valid=1;step();
   rst_n=1'bx;mul_rsp_valid=1;mul_rsp_data[s%256]='x;add_rsp_valid=1;add_rsp_data[s%256]='z;
   ps_rd_rsp_valid=1;ps_rsp_math=1;step();x_cases++;
   rst_n=1;format_valid=1'bx;mul_rsp_valid=1'bx;add_rsp_valid[0]=1'bx;ps_rd_rsp_valid=1'bx;step();x_cases++;
   state='x;format_valid=1;mul_rsp_valid=1;add_rsp_valid=0;ps_rd_rsp_valid=0;step();x_cases++;
  end
  if(format_seen!=='1||mul_seen!=='1||add_seen!=='1||ps_seen!=='1||read_seen!=='1||zero_seen!=='1||ctx_seen!==2'b11||data_ones!=='1||data_zeros!=='1)$fatal(1,"coverage missing");
  for(integer c=0;c<5;c++)if(combo0[c]!==8'hff||combo1[c]!==8'hff)$fatal(1,"combination missing");
  $display("OPERAND_STORAGE_EQUIVALENCE_PASS cycles=%0d full_pool_checks=%0d pool0_cases=%0d pool1_cases=%0d reset_cases=%0d hold_cases=%0d x_cases=%0d all64slots_all256lanes_all32bits=1",cycles,checks,pool0_cases,pool1_cases,reset_cases,hold_cases,x_cases);
  $finish;
 end
endmodule
