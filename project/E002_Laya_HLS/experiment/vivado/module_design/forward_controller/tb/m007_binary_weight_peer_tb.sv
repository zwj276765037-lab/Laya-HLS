`timescale 1ns/1ps
// Simulation input peer only. No production arithmetic, shadow activations or
// full-model preload. All accepted response sources are immutable per ID.
module m007_binary_weight_peer(
 input logic clk,rst_n,enable,
 input logic[3:0]arvalid,output logic[3:0]arready,
 input logic[3:0][63:0]araddr,input logic[3:0][2:0]arid,
 input logic[3:0][7:0]arlen,input logic[3:0][2:0]arsize,
 input logic[3:0][1:0]arburst,
 output logic[3:0]rvalid,input logic[3:0]rready,
 output logic[3:0][2:0]rid,output logic[3:0][511:0]rdata,
 output logic[3:0][1:0]rresp,output logic[3:0]rlast,
 output logic idle,
 output integer accepted_ar,returned_beats,peak_live,cache_hits,cache_misses
);
 logic[735:0]metadata[0:119];
 logic active[0:3][0:7];integer descriptor[0:3][0:7];
 logic[63:0]origin[0:3][0:7];integer beats[0:3][0:7],position[0:3][0:7],eligible[0:3][0:7];
 logic[3:0]last_fire;integer rotate[0:3],cycle=0;
 // Eight64B direct-mapped source words per port; fixed2048B total.
 logic cache_valid[0:3][0:7];integer cache_descriptor[0:3][0:7];
 logic[63:0]cache_word[0:3][0:7];logic[511:0]cache_data[0:3][0:7];
 integer q0[0:3],q1[0:3],scale[0:3];
 integer q0_bytes[0:3],q1_bytes[0:3],scale_bytes[0:3];
 string meta_path,package_path;logic initialized=0;
 initial begin
  if(!$value$plusargs("PEER_META=%s",meta_path)||!$value$plusargs("MODEL_PACKAGE=%s",package_path))$fatal(1,"binary peer source paths required");
  $readmemh(meta_path,metadata);
  for(int p=0;p<4;p++)begin
   q0[p]=$fopen({package_path,"/w_q0.bin"},"rb");q1[p]=$fopen({package_path,"/w_q1.bin"},"rb");scale[p]=$fopen({package_path,"/w_scale.bin"},"rb");
   if(!q0[p]||!q1[p]||!scale[p])$fatal(1,"original TN8 BO open");
   if($fseek(q0[p],0,2)||$fseek(q1[p],0,2)||$fseek(scale[p],0,2))$fatal(1,"original BO length seek");
   q0_bytes[p]=$ftell(q0[p]);q1_bytes[p]=$ftell(q1[p]);scale_bytes[p]=$ftell(scale[p]);
   if(q0_bytes[p]!=184682496||q1_bytes[p]!=184680448||scale_bytes[p]!=23085184)$fatal(1,"bound original BO sizes");
  end
  initialized=1;
 end
 function automatic integer source_index(input integer p,input logic[63:0]address,input integer length);
  integer found;logic[64:0]finish,base,end_address;
  begin
   found=-1;finish={1'b0,address}+65'(64*length);
   for(int d=0;d<120;d++)begin
    base={1'b0,metadata[d][224+128*p+:64]};end_address=base+{1'b0,metadata[d][288+128*p+:64]};
    if({1'b0,address}>=base&&finish<=end_address)begin if(found>=0)$fatal(1,"ambiguous immutable catalog source");found=d;end
   end
   return found;
  end
 endfunction
 function automatic logic[511:0]source_word(input integer p,d,input logic[63:0]offset);
  integer group_count,n,record_index,word,s,g,c,column,tile,lane,shard,fd,got,slot;
  longint unsigned qaddress,saddress;
  reg[7:0]bytes[0:31];logic[511:0]value;
  begin
   slot=(d+int'(offset>>6))%8;
   if(cache_valid[p][slot]&&cache_descriptor[p][slot]==d&&cache_word[p][slot]==(offset>>6))begin cache_hits++;return cache_data[p][slot];end
   cache_misses++;value=0;group_count=int'(metadata[d][15:0])/32;n=int'(metadata[d][31:16]);
   if(!(group_count==32||group_count==82||group_count==128))$fatal(1,"original K/G binding");
   record_index=int'(offset/576);word=int'((offset%576)/64);s=record_index/group_count;g=record_index%group_count;
   if(word<8)begin
    for(int half=0;half<2;half++)begin
     c=2*word+half;column=n==5248?32*s+16*(p%2)+c+(p>=2?2624:0):64*s+16*p+c;
     tile=column/8;lane=column%8;shard=tile%2;
     qaddress=(shard?metadata[d][159:96]:metadata[d][95:32])+64'(((tile/2)*group_count+g)*256+lane*32);
     fd=shard?q1[p]:q0[p];
     if(qaddress+32>64'(shard?q1_bytes[p]:q0_bytes[p])||qaddress>64'h7fffffff)$fatal(1,"TN8 Q source bounds");
     if($fseek(fd,int'(qaddress),0))$fatal(1,"Q source seek");got=$fread(bytes,fd,0,32);if(got!=32)$fatal(1,"Q source short read");
     for(int j=0;j<32;j++)value[8*(32*half+j)+:8]=bytes[j];
    end
   end else if(word==8)begin
    for(int c=0;c<16;c++)begin
     column=n==5248?32*s+16*(p%2)+c+(p>=2?2624:0):64*s+16*p+c;tile=column/8;lane=column%8;
     saddress=metadata[d][223:160]+64'((tile*group_count+g)*16+lane*2);
     if(saddress+2>64'(scale_bytes[p])||saddress>64'h7fffffff)$fatal(1,"TN8 scale source bounds");
     if($fseek(scale[p],int'(saddress),0))$fatal(1,"scale source seek");got=$fread(bytes,scale[p],0,2);if(got!=2)$fatal(1,"scale source short read");
     value[16*c+:8]=bytes[0];value[16*c+8+:8]=bytes[1];
    end
   end else $fatal(1,"W576 word index");
   cache_valid[p][slot]=1;cache_descriptor[p][slot]=d;cache_word[p][slot]=offset>>6;cache_data[p][slot]=value;
   return value;
  end
 endfunction
 always_comb begin
  arready=0;idle=1;
  for(int p=0;p<4;p++)begin
   if(rst_n&&initialized&&enable)arready[p]=!active[p][arid[p]];
   if(rvalid[p])idle=0;
   for(int id=0;id<8;id++)if(active[p][id])idle=0;
  end
 end
 always@(posedge clk)begin
  cycle++;last_fire<=rvalid&rready;
  if(!rst_n)begin
   accepted_ar=0;returned_beats=0;peak_live=0;cache_hits=0;cache_misses=0;last_fire<=0;
   for(int p=0;p<4;p++)begin rotate[p]=0;for(int id=0;id<8;id++)begin active[p][id]<=0;cache_valid[p][id]=0;end end
  end else begin
   integer live;
   begin : m007_peer_posedge_port_0
    if(arvalid[0]&&arready[0])begin
     integer d,id,length;logic[64:0]finish;
     id=int'(arid[0]);length=int'(arlen[0])+1;finish={1'b0,araddr[0]}+65'(64*length);
     if(!enable||active[0][id]||araddr[0][5:0]!=0||arsize[0]!=6||arburst[0]!=1||length>16||finish[64]||int'(araddr[0][11:0])+64*length>4096)$fatal(1,"binary peer AR protocol");
     d=source_index(0,araddr[0],length);if(d<0)$fatal(1,"unregistered original tensor address");
     descriptor[0][id]<=d;origin[0][id]<=araddr[0]-metadata[d][224+128*0+:64];beats[0][id]<=length;position[0][id]<=0;eligible[0][id]<=cycle+3;active[0][id]<=1;accepted_ar++;
    end
    if(rvalid[0]&&rready[0])begin
     integer id;id=int'(rid[0]);if(!active[0][id]||rlast[0]!=(position[0][id]+1==beats[0][id]))$fatal(1,"binary peer actual R debt");
     returned_beats++;if(rlast[0])active[0][id]<=0;else position[0][id]<=position[0][id]+1;rotate[0]=(id+1)%8;
    end
   end
   begin : m007_peer_posedge_port_1
    if(arvalid[1]&&arready[1])begin
     integer d,id,length;logic[64:0]finish;
     id=int'(arid[1]);length=int'(arlen[1])+1;finish={1'b0,araddr[1]}+65'(64*length);
     if(!enable||active[1][id]||araddr[1][5:0]!=0||arsize[1]!=6||arburst[1]!=1||length>16||finish[64]||int'(araddr[1][11:0])+64*length>4096)$fatal(1,"binary peer AR protocol");
     d=source_index(1,araddr[1],length);if(d<0)$fatal(1,"unregistered original tensor address");
     descriptor[1][id]<=d;origin[1][id]<=araddr[1]-metadata[d][224+128*1+:64];beats[1][id]<=length;position[1][id]<=0;eligible[1][id]<=cycle+3;active[1][id]<=1;accepted_ar++;
    end
    if(rvalid[1]&&rready[1])begin
     integer id;id=int'(rid[1]);if(!active[1][id]||rlast[1]!=(position[1][id]+1==beats[1][id]))$fatal(1,"binary peer actual R debt");
     returned_beats++;if(rlast[1])active[1][id]<=0;else position[1][id]<=position[1][id]+1;rotate[1]=(id+1)%8;
    end
   end
   begin : m007_peer_posedge_port_2
    if(arvalid[2]&&arready[2])begin
     integer d,id,length;logic[64:0]finish;
     id=int'(arid[2]);length=int'(arlen[2])+1;finish={1'b0,araddr[2]}+65'(64*length);
     if(!enable||active[2][id]||araddr[2][5:0]!=0||arsize[2]!=6||arburst[2]!=1||length>16||finish[64]||int'(araddr[2][11:0])+64*length>4096)$fatal(1,"binary peer AR protocol");
     d=source_index(2,araddr[2],length);if(d<0)$fatal(1,"unregistered original tensor address");
     descriptor[2][id]<=d;origin[2][id]<=araddr[2]-metadata[d][224+128*2+:64];beats[2][id]<=length;position[2][id]<=0;eligible[2][id]<=cycle+3;active[2][id]<=1;accepted_ar++;
    end
    if(rvalid[2]&&rready[2])begin
     integer id;id=int'(rid[2]);if(!active[2][id]||rlast[2]!=(position[2][id]+1==beats[2][id]))$fatal(1,"binary peer actual R debt");
     returned_beats++;if(rlast[2])active[2][id]<=0;else position[2][id]<=position[2][id]+1;rotate[2]=(id+1)%8;
    end
   end
   begin : m007_peer_posedge_port_3
    if(arvalid[3]&&arready[3])begin
     integer d,id,length;logic[64:0]finish;
     id=int'(arid[3]);length=int'(arlen[3])+1;finish={1'b0,araddr[3]}+65'(64*length);
     if(!enable||active[3][id]||araddr[3][5:0]!=0||arsize[3]!=6||arburst[3]!=1||length>16||finish[64]||int'(araddr[3][11:0])+64*length>4096)$fatal(1,"binary peer AR protocol");
     d=source_index(3,araddr[3],length);if(d<0)$fatal(1,"unregistered original tensor address");
     descriptor[3][id]<=d;origin[3][id]<=araddr[3]-metadata[d][224+128*3+:64];beats[3][id]<=length;position[3][id]<=0;eligible[3][id]<=cycle+3;active[3][id]<=1;accepted_ar++;
    end
    if(rvalid[3]&&rready[3])begin
     integer id;id=int'(rid[3]);if(!active[3][id]||rlast[3]!=(position[3][id]+1==beats[3][id]))$fatal(1,"binary peer actual R debt");
     returned_beats++;if(rlast[3])active[3][id]<=0;else position[3][id]<=position[3][id]+1;rotate[3]=(id+1)%8;
    end
   end
   live=0;for(int p=0;p<4;p++)for(int id=0;id<8;id++)if(active[p][id])live++;if(live>peak_live)peak_live=live;
   if(!enable&&(live!=0||rvalid!=0))$fatal(1,"source owner withdrawn before real R drain");
  end
 end
 always@(negedge clk)begin
  if(!rst_n)begin rvalid=0;rid=0;rdata=0;rresp=0;rlast=0;end
  else if(enable)for(int p=0;p<4;p++)if(!rvalid[p]||last_fire[p])begin
   integer pick;pick=-1;
   for(int j=7;j>=0;j--)if(active[p][(rotate[p]+j)%8]&&cycle>=eligible[p][(rotate[p]+j)%8])pick=(rotate[p]+j)%8;
   rvalid[p]=0;
   if(pick>=0)begin rvalid[p]=1;rid[p]=3'(pick);rresp[p]=0;rlast[p]=position[p][pick]+1==beats[p][pick];rdata[p]=source_word(p,descriptor[p][pick],origin[p][pick]+64'(64*position[p][pick]));end
  end
 end
endmodule

module m007_binary_weight_peer_unit_tb;
 logic clk=0,rst_n=0,enable=1;always #1 clk=~clk;
 logic[3:0]arvalid=0,arready,rvalid,rready=0,rlast;
 logic[3:0][63:0]araddr=0;logic[3:0][2:0]arid=0,arsize='{default:3'd6},rid;
 logic[3:0][7:0]arlen=0;logic[3:0][1:0]arburst='{default:2'd1},rresp;
 logic[3:0][511:0]rdata;logic idle;integer accepted_ar,returned_beats,peak_live,cache_hits,cache_misses;
 m007_binary_weight_peer peer(.*);
 logic[127:0]requests[0:4095];logic[511:0]expected[0:65535];
 integer request_count,word_count,issue=0,accepted=0,completed=0,checked=0,cycle=0;
 integer owner[0:3][0:7],seen_words[0:3][0:7];logic owned[0:3][0:7];
 logic[479:0]first_seen=0,last_seen=0;integer overlap=0,held_ar=0,held_r=0,held_last=0;
 logic[3:0]ar_fire=0,was_ar_held=0,was_r_held=0;
 logic[3:0][77:0]held_ar_packet;logic[3:0][517:0]held_r_packet;
 string data_path;
 always@(negedge clk)if(rst_n)begin
  for(int p=0;p<4;p++)if(ar_fire[p])arvalid[p]=0;
  if(issue<request_count)begin
   integer p;p=int'(requests[issue][1:0]);
   if(!arvalid[p])begin arvalid[p]=1;arid[p]=3'(issue%8);araddr[p]=requests[issue][65:2];arlen[p]=requests[issue][73:66];end
  end
  for(int p=0;p<4;p++)rready[p]=(cycle>48)&&(cycle%13!=p)&&(cycle%17!=p);
 end
 always@(posedge clk)if(rst_n)begin
  cycle++;ar_fire<=arvalid&arready;
  for(int p=0;p<4;p++)begin
   if(was_ar_held[p]&&(!arvalid[p]||{araddr[p],arid[p],arlen[p],arsize[p]}!==held_ar_packet[p]))$fatal(1,"unit AR unstable while held");
   if(was_r_held[p]&&(!rvalid[p]||{rid[p],rdata[p],rresp[p],rlast[p]}!==held_r_packet[p]))$fatal(1,"unit real R unstable while held");
   was_ar_held[p]=arvalid[p]&&!arready[p];held_ar_packet[p]={araddr[p],arid[p],arlen[p],arsize[p]};
   was_r_held[p]=rvalid[p]&&!rready[p];held_r_packet[p]={rid[p],rdata[p],rresp[p],rlast[p]};
   if(was_ar_held[p])held_ar++;
   if(was_r_held[p])begin held_r++;if(rlast[p])begin held_last++;if(idle)$fatal(1,"idle before last real R consumed");end end
   if(arvalid[p]&&arready[p])begin
    integer id;id=int'(arid[p]);if(owned[p][id]||p!=int'(requests[issue][1:0])||araddr[p]!==requests[issue][65:2])$fatal(1,"unit AR acceptance/source order");
    for(int other=0;other<8;other++)if(owned[p][other]&&requests[owner[p][other]][112:106]!=requests[issue][112:106])overlap++;
    owned[p][id]=1;owner[p][id]=issue;seen_words[p][id]=0;issue++;accepted++;
   end
   if(rvalid[p]&&rready[p])begin
    integer id,index,word,tensor,flag;id=int'(rid[p]);index=owner[p][id];word=seen_words[p][id];
    if(!owned[p][id]||rresp[p]!=0||rdata[p]!==expected[int'(requests[index][105:74])+word]||rlast[p]!=(word==int'(requests[index][73:66])))$fatal(1,"GGUF independent byte mismatch/source/length p=%0d id=%0d case=%0d word=%0d",p,id,index,word);
    checked++;seen_words[p][id]++;if(checked%64==0)begin $display("M007_PARENT_CHECKED checked=%0d phase=BINARY_W_PEER cycle=%0d",checked*64,cycle);$fflush();end
    if(rlast[p])begin
     tensor=int'(requests[index][112:106]);flag=int'(requests[index][127:113]);if(flag&1)first_seen[4*tensor+p]=1;if(flag&2)last_seen[4*tensor+p]=1;owned[p][id]=0;completed++;
    end
   end
  end
  if(cycle>200000)$fatal(1,"bounded peer unit watchdog");
 end
 initial begin
  if(!$value$plusargs("PEER_DATA=%s",data_path)||!$value$plusargs("REQUESTS=%d",request_count)||!$value$plusargs("WORDS=%d",word_count))$fatal(1,"bound unit fixture paths/counts");
  if(request_count>4096||word_count>65536)$fatal(1,"bounded fixture capacity");
  $readmemh({data_path,"/requests.hex"},requests,0,request_count-1);$readmemh({data_path,"/expected.hex"},expected,0,word_count-1);
  for(int p=0;p<4;p++)for(int id=0;id<8;id++)begin owned[p][id]=0;owner[p][id]=0;seen_words[p][id]=0;end
  repeat(5)@(negedge clk);rst_n=1;
  wait(completed==request_count);wait(idle);repeat(4)@(negedge clk);
  if(issue!=request_count||accepted!=request_count||checked!=word_count||accepted_ar!=request_count||returned_beats!=word_count||first_seen!={480{1'b1}}||last_seen!={480{1'b1}}||peak_live<8||overlap==0||held_ar<17||held_r<17||held_last<17)$fatal(1,"complete binary peer coverage issue=%0d accepted=%0d completed=%0d words=%0d peak=%0d overlap=%0d heldAR=%0d heldR=%0d heldLAST=%0d",issue,accepted,completed,checked,peak_live,overlap,held_ar,held_r,held_last);
  enable=0;repeat(4)@(negedge clk);if(!idle||rvalid!=0)$fatal(1,"peer owner return before actual drain");
  $display("HARDWARE_AGENT_SIM_PASS M007_BINARY_WEIGHT_PEER tensors=120 ports=4 requests=%0d words64B=%0d bytes=%0d peak_live=%0d overlap=%0d held_AR=%0d held_R=%0d held_last=%0d cache_hits=%0d cache_misses=%0d cache_payload_bytes=2048 held_response_bytes=256 cycles=%0d",accepted,checked,checked*64,peak_live,overlap,held_ar,held_r,held_last,cache_hits,cache_misses,cycle);$fflush();$finish;
 end
endmodule
