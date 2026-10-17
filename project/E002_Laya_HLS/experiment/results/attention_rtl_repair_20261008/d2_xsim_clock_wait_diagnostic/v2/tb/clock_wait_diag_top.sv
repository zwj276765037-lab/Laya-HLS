`timescale 1ns/1ps

module clock_wait_diag_top;
    typedef virtual axi_if#(64,4,8,3,1) diag_vif_t;

    class clock_wait_worker;
        static int unsigned constructor_count = 0;
        int unsigned id;
        diag_vif_t vif;

        function new(input int unsigned worker_id, input diag_vif_t worker_vif);
            id = worker_id;
            vif = worker_vif;
            constructor_count++;
        endfunction

        task run_static(ref longint unsigned ticks[32]);
            forever begin
                @(posedge $root.clock_wait_diag_top.clk);
                ticks[id]++;
            end
        endtask

        task run_virtual(ref longint unsigned ticks[32]);
            forever begin
                @(posedge vif.clk);
                ticks[id]++;
            end
        endtask

        task run_virtual_delayed(ref longint unsigned ticks[32]);
            forever begin
                @(posedge vif.clk);
                #0.1;
                ticks[id]++;
            end
        endtask
    endclass
    import "DPI-C" function void phase_probe_stage(
        input string label, input longint sim_time_ps,
        input longint clock_count, input longint value0, input longint value1);

    localparam int WORKERS = 32;
    localparam int CLOCKS = 20000;
    logic clk = 0;
    logic rst_n = 0;
    longint unsigned ticks[WORKERS];
    bit completed[WORKERS];
    clock_wait_worker workers[WORKERS];
    string mode;

    always #3.33 clk = ~clk;

    axi_if#(64,4,8,3,1) bus_fixture(.clk(clk), .rst(rst_n));
    axi_if#(64,4,8,3,1) bus_io(.clk(clk), .rst(rst_n));
    axi_if#(64,4,8,3,1) bus_aux(.clk(clk), .rst(rst_n));
    axi_if#(64,4,8,3,1) bus_qkv0(.clk(clk), .rst(rst_n));
    axi_if#(64,4,8,3,1) bus_qkv1(.clk(clk), .rst(rst_n));
    axi_if#(64,4,8,3,1) bus_att_out(.clk(clk), .rst(rst_n));
    axi_if#(64,4,8,3,1) bus_observed(.clk(clk), .rst(rst_n));

`define INIT_IDLE(bus) \
    initial begin \
        bus.name=""; bus.has_checks=0; bus.has_coverage=0; \
        bus.AWID=0; bus.AWADDR=0; bus.AWREGION=0; bus.AWLEN=0; \
        bus.AWSIZE=0; bus.AWBURST=1; bus.AWLOCK=0; bus.AWCACHE=0; \
        bus.AWPROT=0; bus.AWQOS=0; bus.AWVALID=0; bus.AWREADY=0; \
        bus.AWUSER=0; bus.WID=0; bus.WDATA=0; bus.WSTRB=0; \
        bus.WLAST=0; bus.WVALID=0; bus.WREADY=0; bus.WUSER=0; \
        bus.BID=0; bus.BRESP=0; bus.BVALID=0; bus.BREADY=1; \
        bus.BUSER=0; bus.ARID=0; bus.ARADDR=0; bus.ARREGION=0; \
        bus.ARLEN=0; bus.ARSIZE=0; bus.ARBURST=1; bus.ARLOCK=0; \
        bus.ARCACHE=0; bus.ARPROT=0; bus.ARQOS=0; bus.ARVALID=0; \
        bus.ARREADY=0; bus.ARUSER=0; bus.RID=0; bus.RDATA=0; \
        bus.RRESP=0; bus.RLAST=0; bus.RVALID=0; bus.RREADY=1; \
        bus.RUSER=0; \
    end
    `INIT_IDLE(bus_fixture)
    `INIT_IDLE(bus_io)
    `INIT_IDLE(bus_aux)
    `INIT_IDLE(bus_qkv0)
    `INIT_IDLE(bus_qkv1)
    `INIT_IDLE(bus_att_out)
    `INIT_IDLE(bus_observed)
`undef INIT_IDLE

    task automatic run_module(input int unsigned id);
        forever begin
            @(posedge clk);
            ticks[id]++;
        end
    endtask

    function automatic bit sample_point(input int unsigned cycle);
        return cycle == 1 || cycle == 16 || cycle == 256 ||
               cycle == 1024 || cycle == 5000 || cycle == 10000 ||
               cycle == 15000 || cycle == CLOCKS;
    endfunction

    task automatic sample(input string label, input longint signed cycle);
        longint unsigned total = 0;
        for (int j = 0; j < WORKERS; j++) total += ticks[j];
        phase_probe_stage($sformatf("clock_wait_%s_%s", mode, label),
                          longint'($realtime * 1000.0), cycle,
                          longint'(clock_wait_worker::constructor_count),
                          longint'(total));
        $display("CLOCK_WAIT_SAMPLE mode=%s label=%s clocks=%0d workers=%0d constructors=%0d tick_sum=%0d",
                 mode, label, cycle, WORKERS,
                 clock_wait_worker::constructor_count, total);
    endtask

    initial begin : experiment
        diag_vif_t selected_vif;
        if (!$value$plusargs("WAIT_MODE=%s", mode) ||
            (mode != "M" && mode != "S" && mode != "V" && mode != "D"))
            $fatal(1, "CLOCK_WAIT_INVALID expected +WAIT_MODE=M|S|V|D");
        for (int i = 0; i < WORKERS; i++) begin
            ticks[i] = 0;
            completed[i] = 0;
            case (i % 7)
                0: selected_vif = bus_fixture;
                1: selected_vif = bus_io;
                2: selected_vif = bus_aux;
                3: selected_vif = bus_qkv0;
                4: selected_vif = bus_qkv1;
                5: selected_vif = bus_att_out;
                6: selected_vif = bus_observed;
            endcase
            workers[i] = new(i, selected_vif);
        end
        if (clock_wait_worker::constructor_count != WORKERS)
            $fatal(1, "CLOCK_WAIT_CONSTRUCTOR_COUNT count=%0d",
                   clock_wait_worker::constructor_count);
        #0;
        sample("memory_ready", 0);
        $display("CLOCK_WAIT_CONFIG mode=%s seed=1 clocks=%0d workers=%0d interfaces=7",
                 mode, CLOCKS, WORKERS);

        #100;
        repeat (3) @(posedge clk);
        #0.1 rst_n = 1;
        sample("reset_release", 0);

        for (int i = 0; i < WORKERS; i++) begin
            automatic int unsigned slot = i;
            fork
                begin
                    case (mode)
                        "M": run_module(slot);
                        "S": workers[slot].run_static(ticks);
                        "V": workers[slot].run_virtual(ticks);
                        "D": workers[slot].run_virtual_delayed(ticks);
                    endcase
                end
            join_none
        end
        #0;

        for (int cycle = 1; cycle <= CLOCKS; cycle++) begin
            @(posedge clk);
            #0.2;
            if (sample_point(cycle)) begin
                for (int j = 0; j < WORKERS; j++) begin
                    if (ticks[j] !== longint'(cycle))
                        $fatal(1, "CLOCK_WAIT_TICK_MISMATCH mode=%s cycle=%0d worker=%0d observed=%0d",
                               mode, cycle, j, ticks[j]);
                end
                sample($sformatf("clock_%0d", cycle), cycle);
            end
            if (cycle == CLOCKS) begin
                for (int j = 0; j < WORKERS; j++) begin
                    completed[j] = (ticks[j] == CLOCKS);
                    if (!completed[j])
                        $fatal(1, "CLOCK_WAIT_INCOMPLETE mode=%s worker=%0d", mode, j);
                end
                if (clock_wait_worker::constructor_count != WORKERS)
                    $fatal(1, "CLOCK_WAIT_CONSTRUCTOR_DRIFT count=%0d",
                           clock_wait_worker::constructor_count);
                $display("CLOCK_WAIT_MODE_PASS mode=%s clocks=%0d workers=%0d",
                         mode, CLOCKS, WORKERS);
                $fflush();
                $finish;
            end
        end
    end
endmodule
