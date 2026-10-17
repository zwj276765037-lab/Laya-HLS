`timescale 1ns/1ps

package diag_pkg;
    import uvm_pkg::*;
    import axi_pkg::*;
    import file_agent_pkg::*;
    `include "uvm_macros.svh"

    import "DPI-C" function void phase_probe_stage(input string label,
        input longint sim_ps, input longint clock_count,
        input longint value0, input longint value1);

    localparam int PORTS = 7;
    localparam int DEPTH = 65536;
    typedef virtual axi_if#(64,4,8,3,1) diag_vif_t;

    function automatic string port_name(int p);
        case (p)
            0: return "fixture";
            1: return "io";
            2: return "aux";
            3: return "qkv0";
            4: return "qkv1";
            5: return "att_out";
            6: return "observed";
            default: return "invalid";
        endcase
    endfunction

    function automatic byte unsigned initial_byte(int p, int address);
        return byte'(((address * 37) ^ (address >> 3) ^ (p * 53) ^ 8'ha5) & 255);
    endfunction

    class diag_read_callback extends axi_state_cbs;
        mem_model#(8) memory;
        function new(string name="diag_read_callback");
            super.new(name);
        endfunction
        virtual function void memmodel_read_fromar(ref logic[7:0] data[$],
                                                     input longint addr,
                                                     input longint len);
            if (memory == null || addr < 0 || len < 0 || addr + len > DEPTH)
                $fatal(1, "DIAG_INVALID read callback range addr=%0d len=%0d", addr, len);
            if (memory.read_elems(data, addr, len) != 0)
                $fatal(1, "DIAG_INVALID read callback failed addr=%0d len=%0d", addr, len);
        endfunction
    endclass

    class diag_memory_sink extends uvm_component;
        `uvm_component_utils(diag_memory_sink)
        uvm_analysis_imp#(axi_transfer, diag_memory_sink) imp;
        mem_model#(8) memory;
        longint unsigned accepted_write_bytes = 0;
        function new(string name, uvm_component parent);
            super.new(name, parent);
            imp = new("imp", this);
        endfunction
        virtual function void write(axi_transfer tr);
            if (memory == null || tr.data.size() != tr.byte_addr.size())
                $fatal(1, "DIAG_INVALID write callback shape data=%0d addr=%0d",
                       tr.data.size(), tr.byte_addr.size());
            for (int j=0; j<tr.data.size(); j++) begin
                if (tr.byte_addr[j] < 0 || tr.byte_addr[j] >= DEPTH ||
                    memory.write_one_elem(tr.data[j], tr.byte_addr[j]))
                    $fatal(1, "DIAG_INVALID write callback address=%0d", tr.byte_addr[j]);
                accepted_write_bytes++;
            end
        endfunction
    endclass

    typedef class axi_allocation_diag_test;
    axi_allocation_diag_test active_test;

    class axi_allocation_diag_test extends uvm_test;
        `uvm_component_utils(axi_allocation_diag_test)
        axi_env#(64,4,8,3,1) env[PORTS];
        axi_cfg cfg[PORTS];
        mem_model#(8) memory[PORTS];
        diag_memory_sink sink[PORTS];
        diag_read_callback callback[PORTS];
        axi_slave_sequence#(64,4,8,3,1) seq[PORTS];
        byte unsigned expected[PORTS][DEPTH];
        diag_vif_t qkv0_vif;
        event finish_event;
        string mode;
        longint unsigned expected_updates = 0;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            active_test = this;
            if (!uvm_config_db#(diag_vif_t)::get(this, "", "diag_vif", qkv0_vif) ||
                !uvm_config_db#(string)::get(this, "", "diag_mode", mode))
                $fatal(1, "DIAG_INVALID missing mode or qkv0 interface");
            for (int p=0; p<PORTS; p++) begin
                string env_name;
                memory[p] = mem_model#(8)::type_id::create($sformatf("memory_%0d", p));
                memory[p].init(DEPTH, 0);
                for (int a=0; a<DEPTH; a++) begin
                    expected[p][a] = initial_byte(p, a);
                    if (memory[p].write_one_elem(expected[p][a], a))
                        $fatal(1, "DIAG_INVALID initialization p=%0d addr=%0d", p, a);
                end
                callback[p] = new($sformatf("callback_%0d", p));
                callback[p].memory = memory[p];
                sink[p] = diag_memory_sink::type_id::create($sformatf("sink_%0d", p), this);
                sink[p].memory = memory[p];
                cfg[p] = new($sformatf("cfg_%0d", p), 1);
                cfg[p].set_default();
                cfg[p].drv_type = SLAVE;
                cfg[p].reset_level = RESET_LEVEL_LOW;
                cfg[p].write_latency_mode = TRANSACTION_FIRST;
                cfg[p].read_latency_mode = TRANSACTION_FIRST;
                env_name = {"axi_master_", port_name(p)};
                uvm_config_db#(axi_cfg)::set(this, {env_name, "*"}, "cfg", cfg[p]);
                env[p] = axi_env#(64,4,8,3,1)::type_id::create(env_name, this);
            end
            phase_probe_stage("memory_ready", longint'($realtime*1000.0), -1,
                              PORTS*DEPTH, PORTS);
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            for (int p=0; p<PORTS; p++) begin
                env[p].item_wtr_port.connect(sink[p].imp);
                uvm_callbacks#(axi_state, axi_state_cbs)::add(env[p].state, callback[p]);
            end
        endfunction

        virtual task run_phase(uvm_phase phase);
            phase.raise_objection(this);
            wait (qkv0_vif.rst === 1'b1);
            for (int p=0; p<PORTS; p++) begin
                seq[p] = axi_slave_sequence#(64,4,8,3,1)::type_id::create(
                    $sformatf("slave_sequence_%0d", p));
                seq[p].isusr_delay = NO_DELAY;
            end
            fork
                seq[0].start(env[0].vsqr);
                seq[1].start(env[1].vsqr);
                seq[2].start(env[2].vsqr);
                seq[3].start(env[3].vsqr);
                seq[4].start(env[4].vsqr);
                seq[5].start(env[5].vsqr);
                seq[6].start(env[6].vsqr);
            join_none
            @finish_event;
            phase.drop_objection(this);
        endtask

        function void accepted_write(int address, byte unsigned value);
            if (address < 0 || address >= DEPTH)
                $fatal(1, "DIAG_INVALID expected address=%0d", address);
            expected[3][address] = value;
            expected_updates++;
        endfunction

        function void report_queues(longint unsigned clock_count);
            for (int p=0; p<PORTS; p++)
                env[p].state.phase_probe_summary(port_name(p), clock_count);
        endfunction

        function bit queues_empty();
            for (int p=0; p<PORTS; p++) begin
                axi_state s = env[p].state;
                if (s.bqnum_for_slaseq != 0 || s.rq_from_model_num != 0)
                    return 0;
                for (int id=0; id<2; id++) begin
                    if (s.awq.exists(id) && s.awq[id].size() != 0) return 0;
                    if (s.wq.exists(id) && s.wq[id].size() != 0) return 0;
                    if (s.bq_rsp.exists(id) && s.bq_rsp[id].size() != 0) return 0;
                    if (s.bq_for_rsp_lat.exists(id) && s.bq_for_rsp_lat[id].size() != 0) return 0;
                    if (s.arq.exists(id) && s.arq[id].size() != 0) return 0;
                    if (s.rq.exists(id) && s.rq[id].size() != 0) return 0;
                    if (s.rq_from_model.exists(id) && s.rq_from_model[id].size() != 0) return 0;
                end
            end
            return 1;
        endfunction

        function void check_memory();
            for (int p=0; p<PORTS; p++) begin
                for (int a=0; a<DEPTH; a++) begin
                    if (memory[p].mem[a] !== expected[p][a])
                        $fatal(1, "DIAG_INVALID final memory p=%0d addr=%0d got=%02x expected=%02x",
                               p, a, memory[p].mem[a], expected[p][a]);
                end
            end
            if (mode == "idle" && expected_updates != 0)
                $fatal(1, "DIAG_INVALID idle expected_updates=%0d", expected_updates);
            if (mode == "traffic" && expected_updates != 1024)
                $fatal(1, "DIAG_INVALID traffic expected_updates=%0d", expected_updates);
        endfunction

        function void request_finish();
            ->finish_event;
        endfunction
    endclass

endpackage
