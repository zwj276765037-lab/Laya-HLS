`timescale 1ns/1ps
module half_decode_tb;
logic [15:0] h;logic [31:0] old_result,new_result;
old_eval old_dut(.*,.result(old_result));
new_eval new_dut(.*,.result(new_result));
initial begin
 for(int i=0;i<65536;i++)begin
   h=16'(i);#1;
   if(old_result!==new_result)$fatal(1,"HALF_DIFF_FAIL h=%h old=%h new=%h",h,old_result,new_result);
 end
 $display("HALF_DECODE_DIFFERENTIAL_PASS patterns=65536");$finish;
end
endmodule
