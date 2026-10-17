module old_eval(input logic [8191:0] packet, output logic result);
  import laya_generated_provenance_layout_v1::*;
  function automatic logic geometry_within(input logic [1023:0] descriptor,
                                             input logic [511:0] geometry);
    logic valid;
    logic [63:0] owner_first,owner_after,first,after;
    logic [31:0] segment;
    logic [15:0] rows,repeats;
    logic [63:0] row_step,repeat_step;
    owner_first=descriptor[40*8+:64];
    owner_after=owner_first+descriptor[64*8+:64];
    first=geometry[0+:64];segment=geometry[8*8+:32];
    rows=geometry[12*8+:16];repeats=geometry[14*8+:16];
    row_step=geometry[16*8+:64];repeat_step=geometry[24*8+:64];
    valid=owner_after>=owner_first && owner_after<=descriptor[32*8+:64] &&
      64'(rows)*64'(repeats)<=32 && geometry[32*8+:64]<=16*5248*4;
    for(int repeat_index=0;repeat_index<repeats;repeat_index++)
      for(int row=0;row<rows;row++)begin
        first=geometry[0+:64]+64'(repeat_index)*repeat_step+
              64'(row)*row_step;
        after=first+segment;
        valid=valid && first>=owner_first && after>=first && after<=owner_after;
      end
    return valid;
  endfunction

  function automatic logic geometries_disjoint(input logic [8191:0] packet);
    logic valid;
    logic [7:0] count;
    logic [1023:0] descriptor[0:1];
    logic [511:0] geometry[0:1];
    logic [63:0] af,ae,bf,be;
    count=packet[DESCRIPTOR_COUNT*8+:8];
    descriptor[0]=packet[DESCRIPTOR0*8+:1024];
    descriptor[1]=packet[DESCRIPTOR1*8+:1024];
    geometry[0]=packet[GEOMETRY0*8+:512];
    geometry[1]=packet[GEOMETRY1*8+:512];valid=1;
    for(int a=0;a<count;a++)begin
      valid=valid && geometry_within(descriptor[a],geometry[a]);
      for(int ar=0;ar<geometry[a][14*8+:16];ar++)
        for(int ai=0;ai<geometry[a][12*8+:16];ai++)begin
          af=geometry[a][0+:64]+64'(ar)*geometry[a][24*8+:64]+
             64'(ai)*geometry[a][16*8+:64];
          ae=af+geometry[a][8*8+:32];
          for(int b=a;b<count;b++)
            if(descriptor[a][28*8+:8]==descriptor[b][28*8+:8])
              for(int br=0;br<geometry[b][14*8+:16];br++)
                for(int bi=0;bi<geometry[b][12*8+:16];bi++)begin
                  if(a!=b || ar!=br || ai!=bi)begin
                    bf=geometry[b][0+:64]+64'(br)*geometry[b][24*8+:64]+
                       64'(bi)*geometry[b][16*8+:64];
                    be=bf+geometry[b][8*8+:32];
                    valid=valid && !(af<be && bf<ae);
                  end
                end
        end
    end
    return valid;
  endfunction


  assign result=geometries_disjoint(packet);
endmodule
