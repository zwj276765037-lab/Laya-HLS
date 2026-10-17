`timescale 1ns/1ps
// Controlled complete FSM/LAP/A/K and adapter/F10/sidecar peers. All source
// LTP/LTX bytes are independent frozen host01 literals. The actual generated
// executor exporter, managed adapter parser, hub and retirement are NOT RUN.
module laya_executor_transaction_collector_tb_v1;
  logic clk=0,rst_n=0,cancel=0,owner_revoked=0;
  always #5 clk=~clk;
  logic installed_owner_valid=1,old_has_hold=1,old_hold_key_valid=1;
  logic [8191:0] installed_owner,old_hold_key;
  logic old_route=1,physical_route=1,expected_action_valid=1;
  logic [4095:0] expected_action_packet;
  logic [511:0] transaction_pending_dout,source_transaction_request_dout;
  logic transaction_pending_empty_n,transaction_pending_read;
  logic source_transaction_request_empty_n,source_transaction_request_read;
  logic [511:0] transaction_request_dout;
  logic transaction_request_empty_n,transaction_request_read=0;
  logic transaction_completion_consumer_read=0,transaction_completion_consumer_empty_n;
  logic candidate_owned,candidate_verified,candidate_revoked,candidate_route;
  logic [8191:0] candidate_owner;
  logic protocol_error,isolated,metadata_first_pop,collector_first_pop,adapter_first_pop;
  logic txn_start,txn_done;
  logic [5:0] metadata_captured;
  logic [4:0] ltx_captured,adapter_request_consumed,ltc_consumed;
  logic [31:0] candidates_started,candidates_released;
  logic [2:0] phase;
  laya_executor_transaction_collector_v1 dut(.*);

  logic meta_in_valid=0,meta_in_ready,tx_in_valid=0,tx_in_ready;
  logic return_in_valid=0,return_in_ready;
  logic [511:0] meta_in_data,tx_in_data,return_in_data,return_data;
  logic [1:0] meta_occupancy,tx_occupancy,return_occupancy;
  laya_private_fifo2_v1 metadata_fifo(.clk,.rst_n,.in_valid(meta_in_valid),
    .in_ready(meta_in_ready),.in_data(meta_in_data),.out_valid(transaction_pending_empty_n),
    .out_ready(transaction_pending_read),.out_data(transaction_pending_dout),.occupancy(meta_occupancy));
  laya_private_fifo2_v1 source_fifo(.clk,.rst_n,.in_valid(tx_in_valid),
    .in_ready(tx_in_ready),.in_data(tx_in_data),.out_valid(source_transaction_request_empty_n),
    .out_ready(source_transaction_request_read),.out_data(source_transaction_request_dout),.occupancy(tx_occupancy));
  // Every return-consumption fact is a real pop from this depth2 FIFO.
  // Its opaque words test transport lifetime only, without a LTC codec claim.
  laya_private_fifo2_v1 return_fifo(.clk,.rst_n,.in_valid(return_in_valid),
    .in_ready(return_in_ready),.in_data(return_in_data),
    .out_valid(transaction_completion_consumer_empty_n),
    .out_ready(transaction_completion_consumer_read),.out_data(return_data),.occupancy(return_occupancy));

  string fixture,case_name;
  logic [511:0] meta_words[0:32],tx_words[0:23],return_words[0:15],owner_words[0:15],hold_words[0:15];
  logic [511:0] action_words[0:7];
  logic [511:0] captured_words[0:23];
  logic [8191:0] literal_owner,literal_hold;
  logic [4095:0] literal_action;
  logic [511:0] held_adapter;
  logic adapter_was_held=0,expect_error=0,live_changes=0,want_revoked=0;
  integer cycles=0,case_cycles=0,case_id=0,passed_cases=0,release_floor=0;
  integer om=0,ot=0,oa=0,oc=0,first_m=0,first_t=0,first_a=0,last_c=0;

  always @(posedge clk)begin
    cycles<=cycles+1;
    if(cycles>40000)$fatal(1,"collector global cycle cap case=%s phase=%0d",case_name,phase);
    if(!rst_n)begin
      case_cycles<=0;om<=0;ot<=0;oa<=0;oc<=0;
      first_m<=0;first_t<=0;first_a<=0;last_c<=0;adapter_was_held<=0;
    end else begin
      case_cycles<=case_cycles+1;
      if(case_cycles>1500)$fatal(1,"collector case cycle cap case=%s phase=%0d",case_name,phase);
      if(metadata_captured!==om || ltx_captured!==ot || adapter_request_consumed!==oa || ltc_consumed!==oc)
        $fatal(1,"independent actual pop counter mismatch case=%s",case_name);
      if(meta_occupancy>2 || tx_occupancy>2 || return_occupancy>2 || om>33 || ot>24 || oa>24 || oc>16)
        $fatal(1,"bounded collector quota exceeded");
      if(metadata_first_pop)first_m<=first_m+1;
      if(collector_first_pop)begin
        if(om!=33 || oa!=0 || candidate_verified)$fatal(1,"collector first pop conflated with adapter");
        first_t<=first_t+1;
      end
      if(adapter_first_pop)begin
        if(om!=33 || ot!=24 || !candidate_verified || !candidate_owned || first_t!=release_floor+1)
          $fatal(1,"adapter first pop before full original candidate");
        first_a<=first_a+1;
      end
      if(txn_start!==adapter_first_pop)$fatal(1,"txn_start was not real adapter first pop");
      if(txn_done)begin
        if(oc!=15 || oa!=24 || !transaction_completion_consumer_read ||
            !transaction_completion_consumer_empty_n)$fatal(1,"fake final caller pop");
        last_c<=last_c+1;
      end
      if(metadata_first_pop)begin om<=1;ot<=0;oa<=0;oc<=0;end
      else if(transaction_pending_empty_n && transaction_pending_read)om<=om+1;
      if(source_transaction_request_empty_n && source_transaction_request_read)ot<=ot+1;
      if(transaction_request_empty_n && transaction_request_read)begin
        if(transaction_request_dout!==tx_words[oa])$fatal(1,"original LTX byte mismatch case=%s beat=%0d",case_name,oa);
        captured_words[oa]<=transaction_request_dout;
        oa<=oa+1;
      end
      if(transaction_completion_consumer_empty_n && transaction_completion_consumer_read)begin
        if(return_data!==return_words[oc])$fatal(1,"controlled return word changed");
        oc<=oc+1;
      end
      if(adapter_was_held && (!transaction_request_empty_n || transaction_request_dout!==held_adapter))
        $fatal(1,"adapter FIFO word withdrawn/changed under backpressure");
      if(transaction_request_empty_n && (om!=33 || ot!=24 || !candidate_verified || protocol_error))
        $fatal(1,"partial or bad frame reached adapter interface");
      if(candidate_owned && candidate_owner!==literal_owner && !expect_error)
        $fatal(1,"old full A rebound from live fields");
      if(live_changes && candidate_owned && candidate_route!==1'b1)
        $fatal(1,"old route changed from live candidate");
      if(candidate_verified && (!candidate_owned || om!=33 || ot!=24))$fatal(1,"false transport verification");
      if(!expect_error && protocol_error)$fatal(1,"unexpected isolation case=%s",case_name);
      if(candidates_released>release_floor && (oc!=16 || last_c!=release_floor+1 || candidate_owned || candidate_verified))
        $fatal(1,"candidate released before 16 real caller reads");
      adapter_was_held<=transaction_request_empty_n && !transaction_request_read;
      held_adapter<=transaction_request_dout;
    end
  end

  task automatic tick;
    @(posedge clk);#1;@(negedge clk);
  endtask
  task automatic reset_case(input string name,input string packet,input bit has_hold,input bit route,input bit revoked);
    rst_n=0;cancel=revoked;owner_revoked=0;meta_in_valid=0;tx_in_valid=0;return_in_valid=0;
    transaction_request_read=0;transaction_completion_consumer_read=0;
    installed_owner_valid=1;installed_owner=literal_owner;old_has_hold=has_hold;
    old_hold_key_valid=has_hold;old_hold_key=literal_hold;
    expected_action_valid=1;expected_action_packet=literal_action;
    old_route=route;physical_route=route;live_changes=0;expect_error=0;want_revoked=revoked;
    case_name=name;case_id=case_id+1;release_floor=0;
    $readmemh({fixture,"/",packet,"_ltp.hex"},meta_words);
    $readmemh({fixture,"/",packet,"_ltx.hex"},tx_words);
    repeat(3)tick();rst_n=1;repeat(2)tick();
  endtask
  task automatic push_meta(input integer beat);
    meta_in_data=meta_words[beat];meta_in_valid=1;
    do begin @(posedge clk);end while(!meta_in_ready);
    #1;@(negedge clk);meta_in_valid=0;
  endtask
  task automatic push_tx(input integer beat);
    tx_in_data=tx_words[beat];tx_in_valid=1;
    do begin @(posedge clk);end while(!tx_in_ready);
    #1;@(negedge clk);tx_in_valid=0;
  endtask
  task automatic push_return(input integer beat);
    return_in_data=return_words[beat];return_in_valid=1;
    do begin @(posedge clk);end while(!return_in_ready);
    #1;@(negedge clk);return_in_valid=0;
  endtask
  task automatic pop_return;
    transaction_completion_consumer_read=1;
    do begin @(posedge clk);end while(!transaction_completion_consumer_empty_n);
    #1;@(negedge clk);transaction_completion_consumer_read=0;
  endtask
  task automatic change_live;
    cancel=1;owner_revoked=1;installed_owner[16*8+:64]=30;
    old_hold_key[16*8+:64]=99;old_route=0;
    expected_action_packet[24*8+:64]=9001;live_changes=1;want_revoked=1;
    // physical_route stays the actual locked source, not this new live route.
  endtask
  task automatic send_metadata(input bit change_fields,input bit tails);
    for(int i=0;i<33;i++)begin
      push_meta(i);
      if(change_fields && i==1)begin while(om<2)tick();change_live();end
      if(tails && (i==30 || i==31))begin
        while(om<i+1)tick();
        repeat(12)begin
          if(candidate_verified || ot!=0 || oa!=0 || transaction_request_empty_n)
            $fatal(1,"metadata tail prefix created candidate output");
          tick();
        end
      end
    end
    while(om<33)tick();tick();tick();
  endtask
  task automatic send_source(input bit tails);
    for(int i=0;i<24;i++)begin
      push_tx(i);
      if(tails && (i==21 || i==22))begin
        while(ot<i+1)tick();
        repeat(12)begin
          if(candidate_verified || oa!=0 || transaction_request_empty_n)
            $fatal(1,"LTX tail prefix reached adapter");
          tick();
        end
      end
    end
    while(ot<24)tick();tick();tick();
  endtask
  task automatic hold_adapter;
    repeat(12)begin
      if(!candidate_owned || !candidate_verified || !transaction_request_empty_n ||
          candidates_released!=release_floor)$fatal(1,"adapter tail released/withdrew old frame");
      tick();
    end
  endtask
  task automatic finish_good(input bit count_case=1);
    integer capture;
    while(!candidate_verified)tick();hold_adapter();
    for(int i=0;i<24;i++)begin
      transaction_request_read=1;
      do begin @(posedge clk);end while(!transaction_request_empty_n);
      #1;@(negedge clk);transaction_request_read=0;
      if(i==21 || i==22)hold_adapter();
    end
    if(oa!=24 || first_a!=release_floor+1 || txn_done || candidates_released!=release_floor)$fatal(1,"bad adapter end boundary");
    repeat(12)begin
      if(!candidate_owned || !candidate_verified || candidates_released!=release_floor || oc!=0)
        $fatal(1,"adapter idle replaced actual caller return consumption");
      tick();
    end
    for(int i=0;i<14;i++)begin push_return(i);pop_return();end
    push_return(14);push_return(15);
    if(return_occupancy!=2)$fatal(1,"real LTC tail2 not present");
    repeat(12)begin
      if(!candidate_owned || candidates_released!=release_floor || oc!=14)$fatal(1,"tail2 released old candidate");
      tick();
    end
    pop_return();if(return_occupancy!=1)$fatal(1,"real LTC tail1 not present");
    // Restoration cannot erase persistent candidate revocation.
    cancel=0;owner_revoked=0;installed_owner=literal_owner;old_hold_key=literal_hold;
    old_route=physical_route;expected_action_packet=literal_action;
    repeat(12)begin
      if(!candidate_owned || candidates_released!=release_floor || oc!=15 ||
          (want_revoked && !candidate_revoked))$fatal(1,"tail1/live restoration released old candidate");
      tick();
    end
    pop_return();repeat(2)tick();
    if(candidate_owned || candidate_verified || candidates_released!=release_floor+1 || om!=33 || ot!=24 ||
        oa!=24 || oc!=16 || first_m!=release_floor+1 || first_t!=release_floor+1 ||
        first_a!=release_floor+1 || last_c!=release_floor+1 || protocol_error ||
        (want_revoked && !candidate_revoked))
      $fatal(1,"complete original candidate lifecycle failed case=%s",case_name);
    release_floor=release_floor+1;
    if(count_case)passed_cases=passed_cases+1;
    capture=$fopen({fixture,"/actual_",case_name,"_ltx.hex"},"w");
    if(capture==0)$fatal(1,"cannot write actual adapter pop capture");
    for(int i=0;i<24;i++)$fdisplay(capture,"%0128x",captured_words[i]);
    $fclose(capture);
    if(count_case)$display("FULL_CURRENT_EXECUTOR_TRANSACTION_COLLECTOR_CASE_PASS id=%0d case=%s kind=complete meta=33 collector=24 adapter=24 caller=16 firsts=1/1/1 final=1 tails12=1 controlled_peers=1",case_id,case_name);
  endtask
  task automatic finish_bad(input integer want_meta,input integer want_tx);
    while(!isolated)tick();
    repeat(12)begin
      if(!protocol_error || transaction_request_empty_n || metadata_captured!=want_meta ||
          ltx_captured!=want_tx || oa!=0 || oc!=0 || candidates_released!=0 ||
          transaction_pending_read || source_transaction_request_read || txn_start || txn_done)
        $fatal(1,"bad/unknown frame made trustworthy output or resumed case=%s",case_name);
      cancel=0;owner_revoked=0;tick();
    end
    passed_cases=passed_cases+1;
    $display("FULL_CURRENT_EXECUTOR_TRANSACTION_COLLECTOR_CASE_PASS id=%0d case=%s kind=isolated meta=%0d collector=%0d adapter=0 caller=0 completion_generated=0",case_id,case_name,want_meta,want_tx);
  endtask

  initial begin
    if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE missing");
    $readmemh({fixture,"/owner.hex"},owner_words);
    $readmemh({fixture,"/hold_key.hex"},hold_words);
    $readmemh({fixture,"/expected_action.hex"},action_words);
    $readmemh({fixture,"/controlled_ltc.hex"},return_words);
    for(int i=0;i<16;i++)begin literal_owner[i*512+:512]=owner_words[i];literal_hold[i*512+:512]=hold_words[i];end
    for(int i=0;i<8;i++)literal_action[i*512+:512]=action_words[i];
    // All three ordinary kinds and legacy RELEASE still collect. The collector
    // has no remote cleanup permission; only the managed adapter/hub decides.
    reset_case("end_cleanup_cancel_before_first","end_cleanup",1,1,1);send_metadata(0,1);send_source(1);finish_good();
    // A matching retry is another real slot. No reset/FIFO clear or new A:
    // revocation survives the first actual LTC end and recovered live cancel.
    send_metadata(0,1);send_source(1);finish_good(0);
    if(candidates_started!=2 || candidates_released!=2 || !candidate_revoked)
      $fatal(1,"matching old retry erased persistent revocation");
    $display("FULL_CURRENT_EXECUTOR_TRANSACTION_COLLECTOR_RETRY_PASS started=2 released=2 persistent_revoked=1 no_reset=1");
    reset_case("end_ordinary_live_changes","end_ordinary",1,1,0);send_metadata(1,1);send_source(1);finish_good();
    reset_case("invalidate_cleanup","invalidate_cleanup",1,1,1);send_metadata(0,1);send_source(1);finish_good();
    reset_case("invalidate_ordinary","invalidate_ordinary",1,1,1);send_metadata(0,1);send_source(1);finish_good();
    reset_case("release_is_transport_only","release",1,1,1);send_metadata(0,1);send_source(1);finish_good();
    reset_case("claim_is_transport_only","claim",1,1,1);send_metadata(0,1);send_source(1);finish_good();
    reset_case("begin_is_transport_only","begin",1,1,1);send_metadata(0,1);send_source(1);finish_good();
    reset_case("publish_is_transport_only","publish",1,1,1);send_metadata(0,1);send_source(1);finish_good();
    reset_case("compute_is_transport_only","compute",1,1,1);send_metadata(0,1);send_source(1);finish_good();
    reset_case("producer_is_transport_only","producer",1,1,1);send_metadata(0,1);send_source(1);finish_good();
    reset_case("no_hold_controlled_route0","no_hold",0,0,1);send_metadata(0,1);send_source(1);finish_good();

    reset_case("bad_A_reserved","end_cleanup",1,1,0);expect_error=1;installed_owner[888*8]=1;push_meta(0);finish_bad(0,0);
    reset_case("wrong_A_session","end_cleanup",0,1,0);expect_error=1;installed_owner[16*8+:64]=30;send_metadata(0,0);finish_bad(33,0);
    reset_case("wrong_K_sequence","end_cleanup",1,1,0);expect_error=1;old_hold_key[16*8+:64]=2;send_metadata(0,0);finish_bad(33,0);
    reset_case("wrong_K_handoff","end_cleanup",1,1,0);expect_error=1;old_hold_key[680*8+:64]=20;send_metadata(0,0);finish_bad(33,0);
    reset_case("wrong_K_model","end_cleanup",1,1,0);expect_error=1;old_hold_key[(160+415)*8]^=1;push_meta(0);finish_bad(0,0);
    reset_case("wrong_physical_route","end_cleanup",1,1,0);expect_error=1;physical_route=0;push_meta(0);finish_bad(0,0);
    reset_case("foreign_expected_action","end_cleanup",1,1,0);expect_error=1;expected_action_packet[24*8+:64]=9001;send_metadata(0,0);finish_bad(33,0);
    for(int f=0;f<11;f++)begin
      reset_case($sformatf("metadata_fault_%0d",f),"end_cleanup",1,1,0);expect_error=1;
      case(f)
        0:meta_words[0][0]^=1;
        1:meta_words[0][4*8]^=1;
        2:meta_words[0][6*8]^=1;
        3:meta_words[0][8*8]^=1;
        4:meta_words[0][9*8+1]=1;
        5:meta_words[0][10*8]=1;
        6:meta_words[0][63*8]=1;
        7:meta_words[1][13*8]^=1;
        8:meta_words[(576+64+83)/64][((576+64+83)%64)*8]^=1;
        9:meta_words[(576+160+415)/64][((576+160+415)%64)*8]^=1;
        10:meta_words[8][63*8]^=1;
      endcase
      send_metadata(0,0);finish_bad(33,0);
    end
    for(int f=0;f<3;f++)begin
      reset_case($sformatf("source_full_word_fault_%0d",f),"end_cleanup",1,1,0);expect_error=1;
      if(f==0)tx_words[0][16*8]^=1;
      if(f==1)tx_words[9][24*8]^=1;
      if(f==2)tx_words[23][63*8]^=1;
      send_metadata(0,0);send_source(0);finish_bad(33,24);
    end
    reset_case("no_hold_invented_S","no_hold",0,0,0);expect_error=1;meta_words[0][32*8]=1;send_metadata(0,0);finish_bad(33,0);
    if(passed_cases!=33)$fatal(1,"bounded case set incomplete %0d",passed_cases);
    $display("FULL_CURRENT_EXECUTOR_TRANSACTION_COLLECTOR_RTL_PASS cases=33 metadata_beats=33 LTX_beats=24 adapter_beats=24 caller_beats=16 depth2=3 tails12=1 actual_FSM_exporter_NOT_RUN=1 actual_F10_sidecar_adapter_NOT_RUN=1 hub_retirement_NOT_RUN=1");
    $finish;
  end
endmodule
