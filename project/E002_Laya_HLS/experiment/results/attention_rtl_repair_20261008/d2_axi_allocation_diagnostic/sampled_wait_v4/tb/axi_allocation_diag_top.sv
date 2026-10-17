`timescale 1ns/1ps
module axi_allocation_diag_top;
    import uvm_pkg::*;
    import axi_pkg::*;
    import diag_pkg::*;
    logic clk = 0;
    logic rst_n = 0;
    longint unsigned postreset_count = 0;
    longint unsigned pairs_done = 0;
    string mode;
    typedef longint unsigned diag_u64_t;
    always #3.33 clk = ~clk;
    initial begin
        #100;
        repeat (3) @(posedge clk);
        #0.1 rst_n = 1;
    end
    always @(posedge clk) if (rst_n === 1'b1) postreset_count++;

    axi_if#(64,4,8,3,1) bus_fixture(.clk(clk), .rst(rst_n));
    axi_if#(64,4,8,3,1) bus_io(.clk(clk), .rst(rst_n));
    axi_if#(64,4,8,3,1) bus_aux(.clk(clk), .rst(rst_n));
    axi_if#(64,4,8,3,1) bus_qkv0(.clk(clk), .rst(rst_n));
    axi_if#(64,4,8,3,1) bus_qkv1(.clk(clk), .rst(rst_n));
    axi_if#(64,4,8,3,1) bus_att_out(.clk(clk), .rst(rst_n));
    axi_if#(64,4,8,3,1) bus_observed(.clk(clk), .rst(rst_n));

`define INIT_MASTER(bus) \
    initial begin \
        bus.AWID=0; bus.AWADDR=0; bus.AWREGION=0; bus.AWLEN=0; bus.AWSIZE=0; \
        bus.AWBURST=1; bus.AWLOCK=0; bus.AWCACHE=0; bus.AWPROT=0; \
        bus.AWQOS=0; bus.AWVALID=0; bus.AWUSER=0; \
        bus.WID=0; bus.WDATA=0; bus.WSTRB=0; bus.WLAST=0; \
        bus.WVALID=0; bus.WUSER=0; bus.BREADY=1; \
        bus.ARID=0; bus.ARADDR=0; bus.ARREGION=0; bus.ARLEN=0; bus.ARSIZE=0; \
        bus.ARBURST=1; bus.ARLOCK=0; bus.ARCACHE=0; bus.ARPROT=0; \
        bus.ARQOS=0; bus.ARVALID=0; bus.ARUSER=0; bus.RREADY=1; \
    end
    `INIT_MASTER(bus_fixture)
    `INIT_MASTER(bus_io)
    `INIT_MASTER(bus_aux)
    `INIT_MASTER(bus_qkv0)
    `INIT_MASTER(bus_qkv1)
    `INIT_MASTER(bus_att_out)
    `INIT_MASTER(bus_observed)
`undef INIT_MASTER

`define ATTACH_MON(instance,bus,label) \
    d2_phase_axi_monitor #(.PORT(label)) instance ( \
        .clk(clk), .rst_n(rst_n), \
        .awvalid(bus.AWVALID), .awready(bus.AWREADY), \
        .wvalid(bus.WVALID), .wready(bus.WREADY), .wstrb(bus.WSTRB), \
        .wlast(bus.WLAST), .bvalid(bus.BVALID), .bready(bus.BREADY), \
        .bid(bus.BID), .bresp(bus.BRESP), \
        .arvalid(bus.ARVALID), .arready(bus.ARREADY), \
        .arid(bus.ARID), .arlen(bus.ARLEN), .arsize(bus.ARSIZE), \
        .rvalid(bus.RVALID), .rready(bus.RREADY), \
        .rid(bus.RID), .rlast(bus.RLAST), \
        .rdata(bus.RDATA), .rresp(bus.RRESP))
    `ATTACH_MON(mon_fixture,bus_fixture,"fixture");
    `ATTACH_MON(mon_io,bus_io,"io");
    `ATTACH_MON(mon_aux,bus_aux,"aux");
    `ATTACH_MON(mon_qkv0,bus_qkv0,"qkv0");
    `ATTACH_MON(mon_qkv1,bus_qkv1,"qkv1");
    `ATTACH_MON(mon_att_out,bus_att_out,"att_out");
    `ATTACH_MON(mon_observed,bus_observed,"observed");
`undef ATTACH_MON

    initial begin : uvm_start
        // Both runtime processes use xsim --sv_seed 1.
        if (!$value$plusargs("DIAG_MODE=%s", mode) ||
            (mode != "idle" && mode != "traffic"))
            $fatal(1, "DIAG_INVALID expected +DIAG_MODE=idle|traffic");
        uvm_config_db#(string)::set(null, "uvm_test_top", "diag_mode", mode);
        uvm_config_db#(diag_vif_t)::set(null, "uvm_test_top", "diag_vif", bus_qkv0);
        uvm_config_db#(diag_vif_t)::set(null, "uvm_test_top.axi_master_fixture.*", "vif", bus_fixture);
        uvm_config_db#(diag_vif_t)::set(null, "uvm_test_top.axi_master_io.*", "vif", bus_io);
        uvm_config_db#(diag_vif_t)::set(null, "uvm_test_top.axi_master_aux.*", "vif", bus_aux);
        uvm_config_db#(diag_vif_t)::set(null, "uvm_test_top.axi_master_qkv0.*", "vif", bus_qkv0);
        uvm_config_db#(diag_vif_t)::set(null, "uvm_test_top.axi_master_qkv1.*", "vif", bus_qkv1);
        uvm_config_db#(diag_vif_t)::set(null, "uvm_test_top.axi_master_att_out.*", "vif", bus_att_out);
        uvm_config_db#(diag_vif_t)::set(null, "uvm_test_top.axi_master_observed.*", "vif", bus_observed);
        $display("DIAG_CONFIG mode=%s seed=1 ports=7 depth=65536 clocks=100000", mode);
        run_test("axi_allocation_diag_test");
    end

    task automatic sample(input string label);
        if (active_test == null) $fatal(1, "DIAG_INVALID UVM test unavailable");
        phase_probe_stage({"diag_",label}, longint'($realtime*1000.0),
                          longint'(postreset_count),
                          longint'(axi_pkg::diag_transfer_constructs),
                          longint'(pairs_done));
        $display("DIAG_SAMPLE mode=%s label=%s cycle=%0d constructs=%0d pairs=%0d",
                 mode, label, postreset_count, axi_pkg::diag_transfer_constructs, pairs_done);
        mon_fixture.report(postreset_count);
        mon_io.report(postreset_count);
        mon_aux.report(postreset_count);
        mon_qkv0.report(postreset_count);
        mon_qkv1.report(postreset_count);
        mon_att_out.report(postreset_count);
        mon_observed.report(postreset_count);
        active_test.report_queues(postreset_count);
    endtask

    // These are fixed first-pair observations.  The cast is confined to the
    // printed threshold; the original wait expressions below are unchanged.
    task automatic trace_wait(input string channel, input string phase,
                              input int i, input longint unsigned count,
                              input logic predicate);
        $display("DIAG_WAIT_TRACE channel=%s phase=%s item=%0d threshold_u64=%0d count_u64=%0d predicate=%b postreset_clock=%0d sim_ps=%0d monitor_sample_cycle=%0d first_b=%b first_r=%b",
                 channel, phase, i, diag_u64_t'(longint'(i+1)),
                 diag_u64_t'(count), predicate, postreset_count,
                 longint'($realtime*1000.0), mon_qkv0.sample_cycle,
                 mon_qkv0.first_b_seen, mon_qkv0.first_r_seen);
        $fflush();
    endtask

    task automatic record_qkv_raw(input string edge_label);
        $display("DIAG_EDGE_WINDOW kind=raw_%s clock=%0d sim_ps=%0d sample_cycle=%0d aw=%b%b w=%b%b b=%b%b bid=%b bresp=%b ar=%b%b r=%b%b rid=%b rresp=%b rlast=%b rdata=%08x counts=%0d,%0d,%0d,%0d,%0d stored_b=%b,%b stored_r=%b,%b,%b,%08x first=%b,%b",
                 edge_label, postreset_count, longint'($realtime*1000.0),
                 mon_qkv0.sample_cycle,
                 bus_qkv0.AWVALID, bus_qkv0.AWREADY,
                 bus_qkv0.WVALID, bus_qkv0.WREADY,
                 bus_qkv0.BVALID, bus_qkv0.BREADY,
                 bus_qkv0.BID, bus_qkv0.BRESP,
                 bus_qkv0.ARVALID, bus_qkv0.ARREADY,
                 bus_qkv0.RVALID, bus_qkv0.RREADY,
                 bus_qkv0.RID, bus_qkv0.RRESP,
                 bus_qkv0.RLAST, bus_qkv0.RDATA,
                 mon_qkv0.aw_count, mon_qkv0.w_beats, mon_qkv0.b_count,
                 mon_qkv0.ar_count, mon_qkv0.r_beats,
                 mon_qkv0.last_b_id, mon_qkv0.last_b_resp,
                 mon_qkv0.last_r_id, mon_qkv0.last_r_resp,
                 mon_qkv0.last_r_last, mon_qkv0.last_r_data,
                 mon_qkv0.first_b_seen, mon_qkv0.first_r_seen);
        $fflush();
    endtask

    always @(posedge clk) begin
        #0.001;
        if (postreset_count >= 9998 && postreset_count <= 10024)
            record_qkv_raw("posedge_plus_0p001ns");
    end
    always @(negedge clk) begin
        #0.001;
        if (postreset_count >= 9998 && postreset_count <= 10024)
            record_qkv_raw("negedge_plus_0p001ns");
    end

    task automatic send_aw(input int i, input int address);
        @(negedge clk);
        if (i == 0)
            trace_wait("AW", "before_valid", i, mon_qkv0.aw_count,
                       mon_qkv0.aw_count >= longint'(i+1));
        bus_qkv0.AWID=0; bus_qkv0.AWADDR=address; bus_qkv0.AWLEN=0;
        bus_qkv0.AWSIZE=0; bus_qkv0.AWBURST=1; bus_qkv0.AWVALID=1;
        while ((mon_qkv0.aw_count >= longint'(i+1)) !== 1'b1) begin
            @(posedge clk);
            #0.001;
        end
        if (i == 0)
            trace_wait("AW", "after_wait", i, mon_qkv0.aw_count,
                       mon_qkv0.aw_count >= longint'(i+1));
        if ((mon_qkv0.aw_count >= longint'(i+1)) !== 1'b1)
            $fatal(1,"DIAG_WAIT_FALSE channel=AW item=%0d",i);
        @(negedge clk); bus_qkv0.AWVALID=0;
    endtask

    task automatic send_w(input int i, input int address, input byte unsigned value);
        int lane;
        lane=address%4;
        @(negedge clk);
        if (i == 0)
            trace_wait("W", "before_valid", i, mon_qkv0.w_beats,
                       mon_qkv0.w_beats >= longint'(i+1));
        bus_qkv0.WID=0; bus_qkv0.WDATA=32'(value) << (8*lane);
        bus_qkv0.WSTRB=4'(1<<lane); bus_qkv0.WLAST=1; bus_qkv0.WVALID=1;
        while ((mon_qkv0.w_beats >= longint'(i+1)) !== 1'b1) begin
            @(posedge clk);
            #0.001;
        end
        if (i == 0)
            trace_wait("W", "after_wait", i, mon_qkv0.w_beats,
                       mon_qkv0.w_beats >= longint'(i+1));
        if ((mon_qkv0.w_beats >= longint'(i+1)) !== 1'b1)
            $fatal(1,"DIAG_WAIT_FALSE channel=W item=%0d",i);
        @(negedge clk); bus_qkv0.WVALID=0; bus_qkv0.WLAST=0; bus_qkv0.WSTRB=0;
    endtask

    task automatic send_ar(input int i, input int aligned_address);
        @(negedge clk);
        if (i == 0)
            trace_wait("AR", "before_valid", i, mon_qkv0.ar_count,
                       mon_qkv0.ar_count >= longint'(i+1));
        bus_qkv0.ARID=0; bus_qkv0.ARADDR=aligned_address; bus_qkv0.ARLEN=0;
        bus_qkv0.ARSIZE=2; bus_qkv0.ARBURST=1; bus_qkv0.ARVALID=1;
        while ((mon_qkv0.ar_count >= longint'(i+1)) !== 1'b1) begin
            @(posedge clk);
            #0.001;
        end
        if (i == 0)
            trace_wait("AR", "after_wait", i, mon_qkv0.ar_count,
                       mon_qkv0.ar_count >= longint'(i+1));
        if ((mon_qkv0.ar_count >= longint'(i+1)) !== 1'b1)
            $fatal(1,"DIAG_WAIT_FALSE channel=AR item=%0d",i);
        @(negedge clk); bus_qkv0.ARVALID=0;
    endtask

    task automatic drive_traffic();
        int address, aligned;
        byte unsigned value;
        wait(postreset_count >= 10000);
        for (int i=0; i<1024; i++) begin
            address = 4*(i%256)+(i%4);
            aligned = address & ~3;
            value = byte'((8'h5a ^ i ^ (i>>8)) & 255);
            fork
                send_aw(i, address);
                send_w(i, address, value);
            join
            active_test.accepted_write(address, value);
            if (i == 0)
                trace_wait("B", "before_wait", i, mon_qkv0.b_count,
                           mon_qkv0.b_count >= longint'(i+1));
            while ((mon_qkv0.b_count >= longint'(i+1)) !== 1'b1) begin
                @(posedge clk);
                #0.001;
            end
            if (i == 0)
                trace_wait("B", "after_wait", i, mon_qkv0.b_count,
                           mon_qkv0.b_count >= longint'(i+1));
            if ((mon_qkv0.b_count >= longint'(i+1)) !== 1'b1)
                $fatal(1,"DIAG_WAIT_FALSE channel=B item=%0d",i);
            #0.001;
            if (mon_qkv0.last_b_resp !== 2'b00 ||
                mon_qkv0.last_b_id !== 1'b0)
                $fatal(1,"DIAG_INVALID write response item=%0d resp=%b id=%b",
                       i,mon_qkv0.last_b_resp,mon_qkv0.last_b_id);
            send_ar(i, aligned);
            if (i == 0)
                trace_wait("R", "before_wait", i, mon_qkv0.r_beats,
                           mon_qkv0.r_beats >= longint'(i+1));
            while ((mon_qkv0.r_beats >= longint'(i+1)) !== 1'b1) begin
                @(posedge clk);
                #0.001;
            end
            if (i == 0)
                trace_wait("R", "after_wait", i, mon_qkv0.r_beats,
                           mon_qkv0.r_beats >= longint'(i+1));
            if ((mon_qkv0.r_beats >= longint'(i+1)) !== 1'b1)
                $fatal(1,"DIAG_WAIT_FALSE channel=R item=%0d",i);
            #0.001;
            if (mon_qkv0.last_r_resp !== 2'b00 ||
                mon_qkv0.last_r_last !== 1'b1 ||
                mon_qkv0.last_r_id !== 1'b0)
                $fatal(1,"DIAG_INVALID read response item=%0d resp=%b last=%b id=%b",
                       i,mon_qkv0.last_r_resp,mon_qkv0.last_r_last,
                       mon_qkv0.last_r_id);
            for (int lane=0; lane<4; lane++)
                if (mon_qkv0.last_r_data[lane*8 +: 8] !==
                    active_test.expected[3][aligned+lane])
                    $fatal(1,"DIAG_INVALID readback item=%0d lane=%0d got=%02x expected=%02x",
                           i,lane,mon_qkv0.last_r_data[lane*8 +: 8],
                           active_test.expected[3][aligned+lane]);
            pairs_done++;
        end
        sample("traffic_complete");
    endtask

`define CHECK_IDLE_MON(mon,label) \
    if (mon.aw_count != 0 || mon.w_beats != 0 || mon.b_count != 0 || \
        mon.ar_count != 0 || mon.r_beats != 0 || mon.wlast_count != 0 || \
        mon.rlast_count != 0 || mon.used[0] != 0 || mon.used[1] != 0) \
        $fatal(1, "DIAG_INVALID nonidle port=%s", label)
    task automatic check_counts(input bit final_check);
        `CHECK_IDLE_MON(mon_fixture,"fixture");
        `CHECK_IDLE_MON(mon_io,"io");
        `CHECK_IDLE_MON(mon_aux,"aux");
        `CHECK_IDLE_MON(mon_qkv1,"qkv1");
        `CHECK_IDLE_MON(mon_att_out,"att_out");
        `CHECK_IDLE_MON(mon_observed,"observed");
        if (mode == "idle") begin
            `CHECK_IDLE_MON(mon_qkv0,"qkv0");
            if (pairs_done != 0 || active_test.sink[3].accepted_write_bytes != 0)
                $fatal(1,"DIAG_INVALID idle pairs=%0d callback_bytes=%0d",
                       pairs_done,active_test.sink[3].accepted_write_bytes);
        end else if (final_check) begin
            if (pairs_done != 1024 || mon_qkv0.aw_count != 1024 ||
                mon_qkv0.w_beats != 1024 || mon_qkv0.b_count != 1024 ||
                mon_qkv0.ar_count != 1024 || mon_qkv0.r_beats != 1024 ||
                mon_qkv0.wlast_count != 1024 || mon_qkv0.rlast_count != 1024 ||
                mon_qkv0.w_strobe_bytes != 1024 || mon_qkv0.r_transfer_bytes != 4096 ||
                mon_qkv0.used[0] != 0 || mon_qkv0.used[1] != 0 ||
                active_test.sink[3].accepted_write_bytes != 1024)
                $fatal(1,"DIAG_INVALID traffic counts pairs=%0d AW=%0d W=%0d B=%0d AR=%0d R=%0d callback=%0d",
                       pairs_done,mon_qkv0.aw_count,mon_qkv0.w_beats,mon_qkv0.b_count,
                       mon_qkv0.ar_count,mon_qkv0.r_beats,active_test.sink[3].accepted_write_bytes);
        end
        if (final_check && !active_test.queues_empty())
            $fatal(1,"DIAG_INVALID queues not drained at cycle=%0d",postreset_count);
    endtask
`undef CHECK_IDLE_MON

    initial begin : endpoint
        wait(rst_n === 1'b1);
        #0.001;
        sample("reset_release");
        if (mode == "traffic") fork drive_traffic(); join_none
        for (int c=1; c<=100000; c++) begin
            @(posedge clk);
            #0.001;
            if (postreset_count != longint'(c))
                $fatal(1,"DIAG_INVALID clock count expected=%0d got=%0d",c,postreset_count);
            if (c==1 || c==16 || c==256 || c==1024 || c%10000==0)
                sample($sformatf("clock_%0d",c));
            if (c==90000) begin
                if (mode == "traffic" && pairs_done != 1024)
                    $fatal(1,"DIAG_INVALID workload not complete by 90000 pairs=%0d",pairs_done);
                check_counts(1);
                sample("drain_90000");
            end
        end
        check_counts(1);
        active_test.check_memory();
        sample("final");
        if (mode == "idle") $display("DIAG_IDLE_PASS clocks=100000");
        else $display("DIAG_TRAFFIC_PASS clocks=100000 pairs=1024");
        $fflush();
        active_test.request_finish();
    end
endmodule
