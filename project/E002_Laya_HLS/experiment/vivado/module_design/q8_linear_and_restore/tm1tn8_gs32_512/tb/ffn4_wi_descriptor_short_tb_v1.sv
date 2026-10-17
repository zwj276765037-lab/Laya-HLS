`timescale 1ns/1ps
// FFN4 affected interface test. The Wi payload is the original independent
// fixture; the matrix descriptor is deliberately changed to Down before the
// successful reader command, while the reader retains its Wi DDR binding.
module ffn4_wi_descriptor_short_tb_v1;
  localparam logic [63:0] DDR_BASE=64'h100000000;
  localparam logic [63:0] STATE1_BASE=64'h310000000;
  localparam logic [63:0] WI_BO_BASE=DDR_BASE,WI_BO_SPAN=64'h2000000;
  localparam logic [63:0] WI_REGION_BASE=DDR_BASE+64'd4096,WI_REGION_SPAN=64'h1000000;
  localparam logic [63:0] WI_ROW_STRIDE=64'd20992,WI_BATCH_STRIDE=64'd21495808;
  logic clk=0,rst_n=0,cancel=0;always #5 clk=~clk;
  logic cfg_valid=0,cfg_ready,cfg_reject,old_mismatch=1;
  logic [671:0] cfg_numeric_identity=0;
  logic [95:0] cfg_producer_context=0;
  logic [63:0] cfg_source_ref=64'h0000000600000001;
  logic [63:0] matrix_bo_base=WI_BO_BASE,matrix_bo_span=WI_BO_SPAN;
  wire [63:0] cfg_bo_base=old_mismatch ? matrix_bo_base : WI_BO_BASE;
  wire [63:0] cfg_bo_span=old_mismatch ? matrix_bo_span : WI_BO_SPAN;
  logic [63:0] cfg_region_base=WI_REGION_BASE,cfg_region_span=WI_REGION_SPAN;
  logic [63:0] cfg_row_stride_bytes=WI_ROW_STRIDE;
  logic [63:0] cfg_batch_stride_bytes=WI_BATCH_STRIDE;
  logic wi_valid,wi_ready=0;logic [31:0] wi_data,wi_status;
  logic [671:0] wi_numeric_identity;logic [63:0] wi_source_ref;
  logic [15:0] wi_row;logic [12:0] wi_index;
  logic wi_row_done_valid,wi_row_done_ready=0;
  logic [31:0] wi_row_done_status;logic [63:0] wi_row_bad_element;
  logic read_debt_zero,active;
  logic [31:0] ar_count,r_count,complete_rows;
  logic [63:0] m_axi_araddr;logic [7:0] m_axi_arlen;
  logic [2:0] m_axi_arsize;logic [1:0] m_axi_arburst;
  logic m_axi_arvalid,m_axi_arready=1;
  logic [511:0] m_axi_rdata=0;logic [1:0] m_axi_rresp=0;
  logic m_axi_rlast=0,m_axi_rvalid=0,m_axi_rready;
  logic [31:0] fixture[0:20991];
  string gfixture;
  integer cycle=0,words=0,rows=0,physical_r=0,physical_ar=0;
  integer expected_beat=0,mem_left=0,mem_beat=0;
  logic [63:0] mem_addr=0;
  logic held_word=0,held_row=0;
  logic [31:0] hold_data,hold_status;
  logic [671:0] hold_identity;
  logic [63:0] hold_ref;
  logic [15:0] hold_row;
  logic [12:0] hold_index;
  logic [31:0] hold_row_status;
  logic [63:0] hold_bad;
  laya_wi_axi_reader_v1 dut(.*);
  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin
    cycle++;
    if(cycle>65000)$fatal(1,"FFN4 reader short cycle cap");
    wi_ready<=rst_n && active && cycle%7!=0;
    wi_row_done_ready<=rst_n && wi_row_done_valid && cycle%5!=0;
    if(rst_n)begin
      if(held_word && (!wi_valid || {wi_data,wi_status,wi_numeric_identity,
          wi_source_ref,wi_row,wi_index}!=={hold_data,hold_status,hold_identity,
          hold_ref,hold_row,hold_index}))
        $fatal(1,"FFN4 Wi scalar changed while backpressured");
      held_word=wi_valid && !wi_ready;
      if(held_word)begin
        hold_data=wi_data;hold_status=wi_status;hold_identity=wi_numeric_identity;
        hold_ref=wi_source_ref;hold_row=wi_row;hold_index=wi_index;
      end
      if(held_row && (!wi_row_done_valid ||
          {wi_row_done_status,wi_row_bad_element}!=={hold_row_status,hold_bad}))
        $fatal(1,"FFN4 Wi row status changed while backpressured");
      held_row=wi_row_done_valid && !wi_row_done_ready;
      if(held_row)begin hold_row_status=wi_row_done_status;hold_bad=wi_row_bad_element;end
      if(wi_valid && wi_ready)begin
        if(words>=20992 || wi_data!==fixture[words] || wi_status!==0 ||
           wi_numeric_identity!==cfg_numeric_identity || wi_source_ref!==cfg_source_ref ||
           wi_row!==16'(words/5248) || wi_index!==13'(words%5248))
          $fatal(1,"FFN4 Wi fixture/identity/row mismatch word=%0d",words);
        words++;
      end
      if(wi_row_done_valid && wi_row_done_ready)begin
        if(rows>=4 || words!=(rows+1)*5248 || wi_row_done_status!==0 ||
           wi_row_bad_element!==0 || !read_debt_zero)
          $fatal(1,"FFN4 Wi row/debt mismatch row=%0d",rows);
        rows++;
      end
      if(m_axi_arvalid && m_axi_arready)begin
        if(mem_left!=0 || m_axi_arsize!==3'd6 || m_axi_arburst!==2'd1 ||
           m_axi_araddr!==WI_REGION_BASE+64'(expected_beat)*64 ||
           m_axi_araddr[11:0]+(int'(m_axi_arlen)+1)*64>4096 ||
           m_axi_araddr+64'(m_axi_arlen+1)*64>WI_REGION_BASE+83968 ||
           (expected_beat%328)+int'(m_axi_arlen)+1>328)
          $fatal(1,"FFN4 Wi AR address/burst mismatch beat=%0d addr=%h",expected_beat,m_axi_araddr);
        physical_ar++;
      end
      if(m_axi_rvalid && m_axi_rready)begin
        if(m_axi_rresp!==0 || m_axi_rlast!==(mem_left==1))
          $fatal(1,"FFN4 Wi R response/last mismatch");
        physical_r++;expected_beat++;
      end
    end
  end
  always_ff @(posedge clk)begin
    if(!rst_n)begin m_axi_rvalid<=0;mem_left<=0;mem_addr<=0;mem_beat<=0;end
    else begin
      if(m_axi_arvalid && m_axi_arready)begin
        mem_left<=int'(m_axi_arlen)+1;mem_addr<=m_axi_araddr;mem_beat<=0;
      end
      if(!m_axi_rvalid && mem_left!=0)begin
        for(int lane=0;lane<16;lane++)
          m_axi_rdata[lane*32+:32]<=fixture[int'((mem_addr-WI_REGION_BASE)/4)+mem_beat*16+lane];
        m_axi_rresp<=0;m_axi_rlast<=mem_left==1;m_axi_rvalid<=1;
      end
      if(m_axi_rvalid && m_axi_rready)begin
        m_axi_rvalid<=0;mem_left<=mem_left-1;mem_beat<=mem_beat+1;
      end
    end
  end
  initial begin
    if(!$value$plusargs("GFIXTURE=%s",gfixture))$fatal(1,"FFN4 missing fixture");
    $readmemh({gfixture,"/wi.mem"},fixture);
    cfg_numeric_identity[63:0]=64'd3;
    cfg_numeric_identity[127:64]=64'd1;
    cfg_numeric_identity[143:128]=16'd1;
    cfg_numeric_identity[159:144]=16'd128;
    cfg_producer_context[31:0]=32'hac000004;
    cfg_producer_context[39:32]=8'h60;
    cfg_producer_context[47:40]=8'd2;
    cfg_producer_context[63:56]=8'd0;
    cfg_producer_context[87:72]=16'd0;
    cfg_producer_context[95:88]=8'd4;
    repeat(5)tick();@(negedge clk);rst_n=1;repeat(2)tick();
    // Reproduce AT062's wrong pairing via the actual reader cfg inputs.
    @(negedge clk);matrix_bo_base=STATE1_BASE;matrix_bo_span=64'd16919104;
    cfg_valid=1;tick();
    if(!cfg_reject || active || ar_count!=0 || r_count!=0 ||
       physical_ar!=0 || physical_r!=0 || words!=0 || rows!=0 || !read_debt_zero)
      $fatal(1,"FFN4 old Wi/Down BO mismatch was not a zero-AXI reject");
    $display("FFN4_OLD_MISMATCH_REJECT cycle=%0d ar=%0d r=%0d",cycle,physical_ar,physical_r);
    @(negedge clk);cfg_valid=0;old_mismatch=0;
    repeat(3)tick();
    if(matrix_bo_base!==STATE1_BASE || cfg_bo_base!==WI_BO_BASE ||
       cfg_region_base!==WI_REGION_BASE || cfg_row_stride_bytes!==WI_ROW_STRIDE)
      $fatal(1,"FFN4 switched matrix/Wi binding incorrect");
    @(negedge clk);cfg_valid=1;tick();
    if(cfg_reject || !active)$fatal(1,"FFN4 legal Wi reader cfg rejected");
    $display("FFN4_READER_BIND cycle=%0d matrix_bo=%h wi_bo=%h region=%h row=%0d batch=%0d",
      cycle,matrix_bo_base,cfg_bo_base,cfg_region_base,cfg_row_stride_bytes,cfg_batch_stride_bytes);
    @(negedge clk);cfg_valid=0;
    while(active)tick();
    if(words!=20992 || rows!=4 || physical_r!=1312 || expected_beat!=1312 ||
       r_count!=1312 || complete_rows!=4 || ar_count!=physical_ar ||
       !read_debt_zero || mem_left!=0 || m_axi_rvalid)
      $fatal(1,"FFN4 Wi four-row closure words=%0d rows=%0d ar=%0d r=%0d debt=%b",
        words,rows,physical_ar,physical_r,read_debt_zero);
    $display("FFN4_WI_READER_SHORT_PASS cycle=%0d AR=%0d R=%0d scalars=%0d rows=%0d",
      cycle,physical_ar,physical_r,words,rows);
    $finish;
  end
endmodule
