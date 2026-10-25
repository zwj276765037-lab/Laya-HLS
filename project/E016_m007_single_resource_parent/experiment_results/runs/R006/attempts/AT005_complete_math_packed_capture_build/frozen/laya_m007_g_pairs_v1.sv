`timescale 1ns/1ps
// Pure pair ownership/coverage and synchronous-bank client. No payload RAM.
// The parent keeps the sole laya_attention_storage_v1 bound to phase1.
module laya_m007_g_pairs_v1(
 input logic clk,rst_n,
 input logic bind_valid,output logic bind_ready,input logic [63:0] bind_request_id,
 input logic [31:0] bind_generation,bind_epoch,
 output logic bound,output logic [63:0] request_id,output logic [31:0] generation,epoch,
 input logic fill_valid,output logic fill_ready,input logic [63:0] fill_request_id,
 input logic [31:0] fill_generation,fill_epoch,input logic fill_slot,fill_half,
 input logic [6:0] fill_s,fill_row,input logic [31:0][31:0] fill_data,
 output logic fill_reject_valid,output logic [1:0] fill_reject_code,
 input logic rd_valid,output logic rd_ready,input logic [63:0] rd_request_id,
 input logic [31:0] rd_generation,rd_epoch,input logic rd_slot,input logic [6:0] rd_s,rd_row,input logic [1:0] rd_chunk,
 output logic rd_reject_valid,
 output logic rd_rsp_valid,input logic rd_rsp_ready,output logic rd_rsp_slot,
 output logic [6:0] rd_rsp_s,rd_rsp_row,output logic [1:0] rd_rsp_chunk,
 output logic [7:0][31:0] rd_rsp_x,rd_rsp_gate,output logic [95:0] rd_rsp_tag,
 input logic release_valid,output logic release_ready,input logic [63:0] release_request_id,
 input logic [31:0] release_generation,release_epoch,input logic release_slot,input logic [6:0] release_s,
 input logic [9:0] release_consumed_vectors,input logic release_client_debt_clear,output logic release_reject_valid,
 input logic discard_valid,output logic discard_ready,input logic [63:0] discard_request_id,
 input logic [31:0] discard_generation,discard_epoch,input logic discard_client_debt_clear,output logic discard_reject_valid,
 output logic [1:0] slot_active,slot_ready,output logic [1:0][6:0] slot_s,
 output logic [1:0][9:0] issued_vectors,returned_vectors,output logic write_pending,protocol_fault,
 output logic g_wr_valid,input logic g_wr_ready,output logic [255:0] g_wr_mask,
 output logic [255:0][5:0] g_wr_addr,output logic [255:0][31:0] g_wr_data,output logic [95:0] g_wr_tag,
 input logic g_wr_rsp_valid,output logic g_wr_rsp_ready,input logic [95:0] g_wr_rsp_tag,
 output logic g_rd_valid,input logic g_rd_ready,output logic [255:0] g_rd_mask,
 output logic [255:0][5:0] g_rd_addr,output logic [95:0] g_rd_tag,
 input logic g_rd_rsp_valid,output logic g_rd_rsp_ready,input logic [255:0][31:0] g_rd_rsp_data,
 input logic [255:0] g_rd_rsp_mask,input logic [95:0] g_rd_rsp_tag
);
 logic [1:0][255:0] coverage;
 logic [6:0] next_claim_s;
 logic [15:0] write_sequence;
 logic pending_slot;logic [7:0] pending_half_row;logic [6:0] pending_s;logic [95:0] pending_write_tag;
 logic fill_identity,fill_order,fill_busy,fill_duplicate,fill_legal,read_identity,read_coordinate,read_legal;
 logic release_identity,read_response_identity,discard_identity;
 logic [255:0] expected_read_mask;
 wire fill_fire=fill_valid&&fill_ready;
 wire write_ack=g_wr_rsp_valid&&g_wr_rsp_ready;
 wire read_fire=rd_valid&&rd_ready;
 wire read_return=rd_rsp_valid&&rd_rsp_ready;
 wire release_fire=release_valid&&release_ready;
 wire discard_fire=discard_valid&&discard_ready;
 assign slot_ready={slot_active[1]&&(&coverage[1]),slot_active[0]&&(&coverage[0])};
 assign bind_ready=rst_n&&!protocol_fault&&slot_active==0&&!write_pending&&issued_vectors==returned_vectors&&!g_wr_rsp_valid&&!g_rd_rsp_valid&&!fill_valid&&!rd_valid&&!discard_valid;
 always_comb begin
  fill_identity=bound&&fill_request_id==request_id&&fill_generation==generation&&fill_epoch==epoch;
  fill_busy=slot_active[fill_slot]&&slot_s[fill_slot]!=fill_s;
  fill_order=fill_s<=81&&fill_slot==fill_s[0]&&
   ((slot_active[fill_slot]&&slot_s[fill_slot]==fill_s)||fill_s==next_claim_s);
  fill_duplicate=slot_active[fill_slot]&&slot_s[fill_slot]==fill_s&&
   (coverage[fill_slot][{fill_half,fill_row}]||(write_pending&&pending_slot==fill_slot&&pending_half_row=={fill_half,fill_row}));
  fill_reject_code=0;
  if(!fill_identity)fill_reject_code=1;
  else if(!fill_order)fill_reject_code=2;
  else if(fill_duplicate)fill_reject_code=3;
  fill_reject_valid=rst_n&&fill_valid&&fill_reject_code!=0;
  discard_identity=bound&&discard_request_id==request_id&&discard_generation==generation&&discard_epoch==epoch;
  fill_legal=fill_reject_code==0&&!fill_busy&&!protocol_fault&&!(discard_valid&&discard_identity);
  g_wr_mask=0;g_wr_addr=0;g_wr_data=0;
  for(int column=0;column<32;column++)begin
   g_wr_mask[int'(fill_slot)*128+int'(fill_half)*64+int'(fill_row[0])*32+column]=1;
   g_wr_addr[int'(fill_slot)*128+int'(fill_half)*64+int'(fill_row[0])*32+column]=fill_row[6:1];
   g_wr_data[int'(fill_slot)*128+int'(fill_half)*64+int'(fill_row[0])*32+column]=fill_data[column];
  end
  g_wr_tag={generation,epoch,write_sequence,fill_s,fill_row,fill_half,fill_slot};
  // Matching ACK consumption can free the one actual write metadata slot.
  g_wr_valid=rst_n&&fill_valid&&fill_legal&&(!write_pending||(write_ack&&g_wr_rsp_tag==pending_write_tag));
  fill_ready=rst_n&&fill_legal&&g_wr_ready&&(!write_pending||(write_ack&&g_wr_rsp_tag==pending_write_tag));
  g_wr_rsp_ready=rst_n&&bound; // Invalid peer records do not retire real debt.

  read_identity=bound&&rd_request_id==request_id&&rd_generation==generation&&rd_epoch==epoch&&rd_s<=81&&rd_slot==rd_s[0];
  read_coordinate=slot_active[rd_slot]&&slot_s[rd_slot]==rd_s&&issued_vectors[rd_slot]<512&&{rd_row,rd_chunk}==issued_vectors[rd_slot][8:0];
  rd_reject_valid=rst_n&&rd_valid&&(!read_identity||(slot_active[rd_slot]&&slot_s[rd_slot]==rd_s&&!read_coordinate));
  read_legal=read_identity&&read_coordinate&&slot_ready[rd_slot]&&!protocol_fault&&!(discard_valid&&discard_identity);
  g_rd_mask=0;g_rd_addr=0;
  for(int lane=0;lane<8;lane++)for(int half=0;half<2;half++)begin
   g_rd_mask[int'(rd_slot)*128+half*64+int'(rd_row[0])*32+int'(rd_chunk)*8+lane]=1;
   g_rd_addr[int'(rd_slot)*128+half*64+int'(rd_row[0])*32+int'(rd_chunk)*8+lane]=rd_row[6:1];
  end
  g_rd_tag={generation,epoch,15'b0,rd_slot,rd_s,rd_row,rd_chunk};
  g_rd_valid=rst_n&&rd_valid&&read_legal;rd_ready=rst_n&&read_legal&&g_rd_ready;

  rd_rsp_slot=g_rd_rsp_tag[16];rd_rsp_s=g_rd_rsp_tag[15:9];rd_rsp_row=g_rd_rsp_tag[8:2];rd_rsp_chunk=g_rd_rsp_tag[1:0];rd_rsp_tag=g_rd_rsp_tag;
  expected_read_mask=0;rd_rsp_x=0;rd_rsp_gate=0;
  for(int lane=0;lane<8;lane++)begin
   expected_read_mask[int'(rd_rsp_slot)*128+int'(rd_rsp_row[0])*32+int'(rd_rsp_chunk)*8+lane]=1;
   expected_read_mask[int'(rd_rsp_slot)*128+64+int'(rd_rsp_row[0])*32+int'(rd_rsp_chunk)*8+lane]=1;
   rd_rsp_x[lane]=g_rd_rsp_data[int'(rd_rsp_slot)*128+int'(rd_rsp_row[0])*32+int'(rd_rsp_chunk)*8+lane];
   rd_rsp_gate[lane]=g_rd_rsp_data[int'(rd_rsp_slot)*128+64+int'(rd_rsp_row[0])*32+int'(rd_rsp_chunk)*8+lane];
  end
  read_response_identity=bound&&g_rd_rsp_tag[95:64]==generation&&g_rd_rsp_tag[63:32]==epoch&&g_rd_rsp_tag[31:17]==0&&
   slot_active[rd_rsp_slot]&&slot_s[rd_rsp_slot]==rd_rsp_s&&returned_vectors[rd_rsp_slot]<issued_vectors[rd_rsp_slot]&&
   returned_vectors[rd_rsp_slot][8:0]==g_rd_rsp_tag[8:0]&&g_rd_rsp_mask==expected_read_mask;
  rd_rsp_valid=rst_n&&g_rd_rsp_valid&&read_response_identity;
  g_rd_rsp_ready=rst_n&&bound&&(read_response_identity?rd_rsp_ready:1'b1);

  release_identity=bound&&release_request_id==request_id&&release_generation==generation&&release_epoch==epoch&&
   slot_active[release_slot]&&slot_s[release_slot]==release_s;
  release_reject_valid=rst_n&&release_valid&&!release_identity;
  release_ready=rst_n&&release_identity&&slot_ready[release_slot]&&issued_vectors[release_slot]==512&&returned_vectors[release_slot]==512&&
   release_consumed_vectors==512&&release_client_debt_clear&&!(write_pending&&pending_slot==release_slot);
  discard_reject_valid=rst_n&&discard_valid&&!discard_identity;
  discard_ready=rst_n&&discard_identity&&discard_client_debt_clear&&!write_pending&&issued_vectors==returned_vectors&&!g_wr_rsp_valid&&!g_rd_rsp_valid;
 end
 always_ff @(posedge clk)begin
  if(!rst_n)begin
   bound<=0;request_id<=0;generation<=0;epoch<=0;slot_active<=0;slot_s<=0;coverage<=0;next_claim_s<=0;write_sequence<=0;
   issued_vectors<=0;returned_vectors<=0;write_pending<=0;pending_slot<=0;pending_half_row<=0;pending_s<=0;pending_write_tag<=0;protocol_fault<=0;
  end else begin
   if(bind_valid&&bind_ready)begin
    bound<=1;request_id<=bind_request_id;generation<=bind_generation;epoch<=bind_epoch;slot_active<=0;coverage<=0;
    next_claim_s<=0;write_sequence<=0;issued_vectors<=0;returned_vectors<=0;
   end
   if(write_ack)begin
    if(write_pending&&g_wr_rsp_tag==pending_write_tag&&slot_active[pending_slot]&&slot_s[pending_slot]==pending_s)begin
     coverage[pending_slot][pending_half_row]<=1;write_pending<=0;
    end else protocol_fault<=1;
   end
   if(fill_fire)begin
    if(!slot_active[fill_slot])begin
     slot_active[fill_slot]<=1;slot_s[fill_slot]<=fill_s;coverage[fill_slot]<=0;next_claim_s<=next_claim_s+1'b1;
     issued_vectors[fill_slot]<=0;returned_vectors[fill_slot]<=0;
    end
    write_pending<=1;pending_slot<=fill_slot;pending_half_row<={fill_half,fill_row};pending_s<=fill_s;pending_write_tag<=g_wr_tag;write_sequence<=write_sequence+1'b1;
   end
   if(read_fire)issued_vectors[rd_slot]<=issued_vectors[rd_slot]+1'b1;
   if(g_rd_rsp_valid&&g_rd_rsp_ready&&!read_response_identity)protocol_fault<=1;
   if(read_return)returned_vectors[rd_rsp_slot]<=returned_vectors[rd_rsp_slot]+1'b1;
   if(release_fire)begin slot_active[release_slot]<=0;coverage[release_slot]<=0;end
   if(discard_fire)begin
    // Full coverage is deliberately unnecessary for cancellation. Only actual
    // accepted write/read/client debt must be zero; no missing work is faked.
    bound<=0;slot_active<=0;coverage<=0;issued_vectors<=0;returned_vectors<=0;protocol_fault<=0;
   end
  end
 end
endmodule
