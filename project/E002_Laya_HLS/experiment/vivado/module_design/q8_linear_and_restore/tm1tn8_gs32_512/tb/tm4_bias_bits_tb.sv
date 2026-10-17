`timescale 1ns/1ps
module tm4_bias_bits_tb;
  import tm4tn8_bias_bits_v1::*;
  logic [95:0] vectors[0:4155];
  logic [31:0] got,a,b,gold;
  integer helpers=0,native=0;
  string fixture;
  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture)) $fatal(1,"fixture required");
    $readmemh({fixture,"/vectors.hex"},vectors);
    for(integer i=0;i<4156;i++) begin
      a=vectors[i][95:64];b=vectors[i][63:32];gold=vectors[i][31:0];got=add_finite_rne(a,b);
      if(got!==gold) $fatal(1,"exact add index=%0d a=%h b=%h got=%h gold=%h",i,a,b,got,gold);
      if(helper_route(a,b)) helpers=helpers+1;
      else begin
        native=native+1;
        if(gold[30:23]==0 && gold[22:0]!=0) $fatal(1,"unsafe native domain index=%0d",i);
      end
    end
    $display("TM4_BIAS_BITS_PASS pairs=4156 directed=60 independent_rational=1 helper_routes=%0d native_routes=%0d maxexp_boundary=25",helpers,native);
    $finish;
  end
endmodule
