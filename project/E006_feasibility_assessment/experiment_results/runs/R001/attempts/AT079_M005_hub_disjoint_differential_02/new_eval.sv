module new_eval(input logic [8191:0] packet, output logic result);
  import laya_generated_provenance_layout_v1::*;
  function automatic logic geometry_within(input logic [1023:0] descriptor,
                                             input logic [511:0] geometry);
    logic valid;
    logic [63:0] owner_first,owner_after,first,after,repeat_base;
    logic [31:0] segment;
    logic [15:0] rows,repeats,row_cursor,repeat_cursor;
    logic [63:0] row_step,repeat_step;
    owner_first=descriptor[40*8+:64];
    owner_after=owner_first+descriptor[64*8+:64];
    repeat_base=geometry[0+:64];first=repeat_base;
    segment=geometry[8*8+:32];
    rows=geometry[12*8+:16];repeats=geometry[14*8+:16];
    row_step=geometry[16*8+:64];repeat_step=geometry[24*8+:64];
    row_cursor=0;repeat_cursor=0;
    valid=owner_after>=owner_first && owner_after<=descriptor[32*8+:64] &&
      64'(rows)*64'(repeats)<=32 && geometry[32*8+:64]<=16*5248*4;
    // A valid descriptor has at most 32 geometry entries. Keep the hardware
    // loop statically bounded; larger counts are already rejected above.
    for(int check_index=0;check_index<32;check_index++)begin
      if(repeat_cursor<repeats && row_cursor<rows)begin
        after=first+segment;
        valid=valid && first>=owner_first && after>=first && after<=owner_after;
        if(row_cursor+1<rows)begin
          row_cursor=row_cursor+1'b1;
          first=first+row_step;
        end else begin
          row_cursor=0;
          repeat_cursor=repeat_cursor+1'b1;
          repeat_base=repeat_base+repeat_step;
          first=repeat_base;
        end
      end
    end
    return valid;
  endfunction

  function automatic logic geometries_disjoint(input logic [8191:0] packet);
    logic valid;
    logic [7:0] count;
    logic [1023:0] descriptor[0:1];
    logic [511:0] geometry[0:1];
    logic [63:0] entry_first[0:63],entry_after[0:63];
    logic [7:0] entry_role[0:63];
    logic [63:0] entry_valid;
    logic [4095:0] overlap;
    logic [63:0] repeat_base,first,row_step,repeat_step;
    logic [31:0] segment;
    logic [15:0] rows,repeats,row_cursor,repeat_cursor;
    count=packet[DESCRIPTOR_COUNT*8+:8];
    descriptor[0]=packet[DESCRIPTOR0*8+:1024];
    descriptor[1]=packet[DESCRIPTOR1*8+:1024];
    geometry[0]=packet[GEOMETRY0*8+:512];
    geometry[1]=packet[GEOMETRY1*8+:512];
    // A legal frame has one or two descriptors, each with no more than 32
    // intervals.  Build their endpoints once, then compare unordered pairs.
    // Bitwise masks propagate unknown fields into the rejection decision.
    valid=(count==1 || count==2);
    entry_valid='0;
    overlap='0;
    for(int d=0;d<2;d++)begin
      if(d<count)valid=valid && geometry_within(descriptor[d],geometry[d]);
      repeat_base=geometry[d][0+:64];
      first=repeat_base;
      segment=geometry[d][8*8+:32];
      rows=geometry[d][12*8+:16];
      repeats=geometry[d][14*8+:16];
      row_step=geometry[d][16*8+:64];
      repeat_step=geometry[d][24*8+:64];
      row_cursor=0;
      repeat_cursor=0;
      for(int k=0;k<32;k++)begin
        entry_valid[d*32+k]=(d<count) && (repeat_cursor<repeats) &&
                            (row_cursor<rows);
        entry_role[d*32+k]=descriptor[d][28*8+:8];
        entry_first[d*32+k]=first;
        entry_after[d*32+k]=first+segment;
        if(repeat_cursor<repeats && row_cursor<rows)begin
          if(row_cursor+1<rows)begin
            row_cursor=row_cursor+1'b1;
            first=first+row_step;
          end else begin
            row_cursor=0;
            repeat_cursor=repeat_cursor+1'b1;
            repeat_base=repeat_base+repeat_step;
            first=repeat_base;
          end
        end
      end
    end
    for(int i=0;i<64;i++)begin
      for(int j=0;j<64;j++)begin
        if(i<j)
          overlap[i*64+j]=entry_valid[i] & entry_valid[j] &
            (entry_role[i]==entry_role[j]) &
            (entry_first[i]<entry_after[j]) &
            (entry_first[j]<entry_after[i]);
      end
    end
    return valid && !(|overlap);
  endfunction


  assign result=geometries_disjoint(packet);
endmodule
