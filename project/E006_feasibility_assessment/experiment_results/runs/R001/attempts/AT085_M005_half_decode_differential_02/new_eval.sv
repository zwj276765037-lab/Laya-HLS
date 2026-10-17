`timescale 1ns/1ps
module new_eval(input logic [15:0] h, output logic [31:0] result);
  function automatic logic [31:0] half_to_f32(input logic [15:0] h);
    logic [4:0] e;logic [9:0] f;integer shift;
    e=h[14:10];f=h[9:0];shift=0;
    if(e==0) begin
      if(f==0)return {h[15],31'd0};
      for(int normalize=0;normalize<10;normalize++)
        if(!f[9])begin f=f<<1;shift=shift+1;end
      return {h[15],8'(112-shift),f[8:0],14'd0};
    end
    if(e==31)return {h[15],8'hff,h[9:0],13'd0};
    return {h[15],8'(int'(e)+112),h[9:0],13'd0};
  endfunction
assign result=half_to_f32(h);
endmodule
