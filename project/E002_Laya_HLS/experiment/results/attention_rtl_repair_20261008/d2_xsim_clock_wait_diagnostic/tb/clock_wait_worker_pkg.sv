`timescale 1ns/1ps

package clock_wait_worker_pkg;
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
endpackage
