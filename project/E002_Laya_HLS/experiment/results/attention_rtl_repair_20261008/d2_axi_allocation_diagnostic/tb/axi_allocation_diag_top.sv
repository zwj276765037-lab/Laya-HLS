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
    logic [31:0] last_rdata;
    logic [1:0] last_rresp;
    logic last_rlast;
    logic last_rid;
    logic [1:0] last_bresp;
    logic last_bid;
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
        .arvalid(bus.ARVALID), .arready(bus.ARREADY), \
        .arid(bus.ARID), .arlen(bus.ARLEN), .arsize(bus.ARSIZE), \
        .rvalid(bus.RVALID), .rready(bus.RREADY), \
        .rid(bus.RID), .rlast(bus.RLAST))
    `ATTACH_MON(mon_fixture,bus_fixture,"fixture");
    `ATTACH_MON(mon_io,bus_io,"io");
    `ATTACH_MON(mon_aux,bus_aux,"aux");
    `ATTACH_MON(mon_qkv0,bus_qkv0,"qkv0");
    `ATTACH_MON(mon_qkv1,bus_qkv1,"qkv1");
    `ATTACH_MON(mon_att_out,bus_att_out,"att_out");
    `ATTACH_MON(mon_observed,bus_observed,"observed");
`undef ATTACH_MON

    always @(posedge clk) begin
        if (rst_n === 1'b1 && bus_qkv0.BVALID === 1'b1 &&
            bus_qkv0.BREADY === 1'b1) begin
            last_bresp = bus_qkv0.BRESP;
            last_bid = bus_qkv0.BID;
        end
        if (rst_n === 1'b1 && bus_qkv0.RVALID === 1'b1 &&
            bus_qkv0.RREADY === 1'b1) begin
            last_rdata = bus_qkv0.RDATA;
            last_rresp = bus_qkv0.RRESP;
            last_rlast = bus_qkv0.RLAST;
            last_rid = bus_qkv0.RID;
        end
    end

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

    task automatic send_aw(input int i, input int address);
        @(negedge clk);
        bus_qkv0.AWID=0; bus_qkv0.AWADDR=address; bus_qkv0.AWLEN=0;
        bus_qkv0.AWSIZE=0; bus_qkv0.AWBURST=1; bus_qkv0.AWVALID=1;
        wait(mon_qkv0.aw_count >= longint'(i+1));
        @(negedge clk); bus_qkv0.AWVALID=0;
    endtask

    task automatic send_w(input int i, input int address, input byte unsigned value);
        int lane;
        lane=address%4;
        @(negedge clk);
        bus_qkv0.WID=0; bus_qkv0.WDATA=32'(value) << (8*lane);
        bus_qkv0.WSTRB=4'(1<<lane); bus_qkv0.WLAST=1; bus_qkv0.WVALID=1;
        wait(mon_qkv0.w_beats >= longint'(i+1));
        @(negedge clk); bus_qkv0.WVALID=0; bus_qkv0.WLAST=0; bus_qkv0.WSTRB=0;
    endtask

    task automatic send_ar(input int i, input int aligned_address);
        @(negedge clk);
        bus_qkv0.ARID=0; bus_qkv0.ARADDR=aligned_address; bus_qkv0.ARLEN=0;
        bus_qkv0.ARSIZE=2; bus_qkv0.ARBURST=1; bus_qkv0.ARVALID=1;
        wait(mon_qkv0.ar_count >= longint'(i+1));
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
            wait(mon_qkv0.b_count >= longint'(i+1));
            #0.001;
            if (last_bresp !== 2'b00 || last_bid !== 1'b0)
                $fatal(1,"DIAG_INVALID write response item=%0d resp=%b id=%b",
                       i,last_bresp,last_bid);
            send_ar(i, aligned);
            wait(mon_qkv0.r_beats >= longint'(i+1));
            #0.001;
            if (last_rresp !== 2'b00 || last_rlast !== 1'b1 || last_rid !== 1'b0)
                $fatal(1,"DIAG_INVALID read response item=%0d resp=%b last=%b id=%b",
                       i,last_rresp,last_rlast,last_rid);
            for (int lane=0; lane<4; lane++)
                if (last_rdata[lane*8 +: 8] !== active_test.expected[3][aligned+lane])
                    $fatal(1,"DIAG_INVALID readback item=%0d lane=%0d got=%02x expected=%02x",
                           i,lane,last_rdata[lane*8 +: 8],active_test.expected[3][aligned+lane]);
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
