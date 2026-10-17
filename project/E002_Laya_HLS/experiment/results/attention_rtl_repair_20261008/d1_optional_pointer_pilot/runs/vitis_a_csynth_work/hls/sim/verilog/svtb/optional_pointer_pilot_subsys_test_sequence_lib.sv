//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef OPTIONAL_POINTER_PILOT_SUBSYS_TEST_SEQUENCE_LIB__SV                                              
    `define OPTIONAL_POINTER_PILOT_SUBSYS_TEST_SEQUENCE_LIB__SV                                          
                                                                                                    
                                                                                                    
    `include "uvm_macros.svh"                                                                     
                                                                                                    
    class optional_pointer_pilot_subsys_test_sequence_lib extends uvm_sequence;                                
                                                                                                    
        function new (string name = "optional_pointer_pilot_subsys_test_sequence_lib");                      
            super.new(name);                                                                        
            `uvm_info(this.get_full_name(), "new is called", UVM_LOW)                             
        endfunction                                                                                 
                                                                                                    
        `uvm_object_utils(optional_pointer_pilot_subsys_test_sequence_lib)                                     
        `uvm_declare_p_sequencer(optional_pointer_pilot_virtual_sequencer)                                     
                                                                                                    
        virtual task body();                                                                        
            uvm_phase starting_phase;                                                               
            virtual interface misc_interface misc_if;                                               
            optional_pointer_pilot_reference_model refm;                                                       
                                                                                                    
            axi_pkg::axi_slave_sequence#(64,4,8,3,1) axi_slave_gmem_seq;
            axi_pkg::axi_busdatas_master_sequence#(7, 32) axi_master_wr_control_seq;
            axi_pkg::axi_busdatas_master_sequence#(7, 32) axi_master_poll_control_seq;
            axi_pkg::axi_busdatas_master_sequence#(5, 32) axi_master_wr_control_r_seq;

            if (!uvm_config_db#(optional_pointer_pilot_reference_model)::get(p_sequencer,"", "refm", refm))
                `uvm_fatal(this.get_full_name(), "No reference model")
            `uvm_info(this.get_full_name(), "get reference model by uvm_config_db", UVM_LOW)

            `uvm_info(this.get_full_name(), "body is called", UVM_LOW)
            starting_phase = this.get_starting_phase();
            if (starting_phase != null) begin
                `uvm_info(this.get_full_name(), "starting_phase not null", UVM_LOW)
                starting_phase.raise_objection(this);
            end
            else
                `uvm_info(this.get_full_name(), "starting_phase null" , UVM_LOW)

            misc_if = refm.misc_if;


            //phase_done.set_drain_time(this, 0ns);
            wait(refm.misc_if.reset === 1);
            ->refm.misc_if.initialed_evt;

            fork
                begin
                    fork
                        begin //axi slave sequence. loop delays
                            `uvm_create_on(axi_slave_gmem_seq, p_sequencer.gmem_sqr);
                            axi_slave_gmem_seq.misc_if = refm.misc_if;
                            axi_slave_gmem_seq.ap_done    = refm.ap_done_for_nexttrans   ;
                            axi_slave_gmem_seq.ap_ready   = refm.ap_ready_for_nexttrans  ;
                            axi_slave_gmem_seq.finish     = refm.finish ;
                            axi_slave_gmem_seq.isusr_delay = axi_pkg::NO_DELAY;
                            `uvm_send(axi_slave_gmem_seq);
                        end
                        begin
                            int control_page_idx_bak;
                            `uvm_create_on(axi_master_wr_control_seq, p_sequencer.control_sqr);
                            axi_master_wr_control_seq.misc_if = refm.misc_if;
                            axi_master_wr_control_seq.ap_done    = refm.ap_done_for_nexttrans   ;
                            axi_master_wr_control_seq.ap_ready   = refm.ap_ready_for_nexttrans  ;
                            axi_master_wr_control_seq.finish     = refm.finish ;
                            axi_master_wr_control_seq.isusr_delay = axi_pkg::NO_DELAY;
                            for(int i=0; i<15; i++) begin
                                logic[63:0] data64bit_mode[$];
                                logic[32-1:0] databusbit_mode[$];
                                logic[63:0] data64bit_layer[$];
                                logic[32-1:0] databusbit_layer[$];
                                logic[63:0] data64bit_src_bank[$];
                                logic[32-1:0] databusbit_src_bank[$];
                                logic[63:0] data64bit_epoch[$];
                                logic[32-1:0] databusbit_epoch[$];
                                logic[63:0] data64bit_second_id[$];
                                logic[32-1:0] databusbit_second_id[$];
                                logic[63:0] data64bit_second_bank[$];
                                logic[32-1:0] databusbit_second_bank[$];
                                logic[63:0] data64bit_second_epoch[$];
                                logic[32-1:0] databusbit_second_epoch[$];
                                logic[63:0] data64bit_second_region[$];
                                logic[32-1:0] databusbit_second_region[$];
                                logic[63:0] data64bit_load_ok[$];
                                logic[32-1:0] databusbit_load_ok[$];
                                data64bit_mode.delete(); databusbit_mode.delete();
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=0;
                                refm.mem_blk_pages_control_mode.tobusdata(data64bit_mode, refm.mem_blk_pages_control_mode.rd_page_idx, 32);
                                foreach(data64bit_mode[s]) databusbit_mode[s]=data64bit_mode[s][32-1:0];
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=1;
                                axi_master_wr_control_seq.datamerge_inavg(databusbit_mode, 0, 16, 1);
                                data64bit_layer.delete(); databusbit_layer.delete();
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=0;
                                refm.mem_blk_pages_control_layer.tobusdata(data64bit_layer, refm.mem_blk_pages_control_layer.rd_page_idx, 32);
                                foreach(data64bit_layer[s]) databusbit_layer[s]=data64bit_layer[s][32-1:0];
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=1;
                                axi_master_wr_control_seq.datamerge_inavg(databusbit_layer, 0, 24, 1);
                                data64bit_src_bank.delete(); databusbit_src_bank.delete();
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=0;
                                refm.mem_blk_pages_control_src_bank.tobusdata(data64bit_src_bank, refm.mem_blk_pages_control_src_bank.rd_page_idx, 32);
                                foreach(data64bit_src_bank[s]) databusbit_src_bank[s]=data64bit_src_bank[s][32-1:0];
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=1;
                                axi_master_wr_control_seq.datamerge_inavg(databusbit_src_bank, 0, 32, 1);
                                data64bit_epoch.delete(); databusbit_epoch.delete();
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=0;
                                refm.mem_blk_pages_control_epoch.tobusdata(data64bit_epoch, refm.mem_blk_pages_control_epoch.rd_page_idx, 32);
                                foreach(data64bit_epoch[s]) databusbit_epoch[s]=data64bit_epoch[s][32-1:0];
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=1;
                                axi_master_wr_control_seq.datamerge_inavg(databusbit_epoch, 0, 40, 1);
                                data64bit_second_id.delete(); databusbit_second_id.delete();
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=0;
                                refm.mem_blk_pages_control_second_id.tobusdata(data64bit_second_id, refm.mem_blk_pages_control_second_id.rd_page_idx, 32);
                                foreach(data64bit_second_id[s]) databusbit_second_id[s]=data64bit_second_id[s][32-1:0];
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=1;
                                axi_master_wr_control_seq.datamerge_inavg(databusbit_second_id, 0, 48, 1);
                                data64bit_second_bank.delete(); databusbit_second_bank.delete();
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=0;
                                refm.mem_blk_pages_control_second_bank.tobusdata(data64bit_second_bank, refm.mem_blk_pages_control_second_bank.rd_page_idx, 32);
                                foreach(data64bit_second_bank[s]) databusbit_second_bank[s]=data64bit_second_bank[s][32-1:0];
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=1;
                                axi_master_wr_control_seq.datamerge_inavg(databusbit_second_bank, 0, 56, 1);
                                data64bit_second_epoch.delete(); databusbit_second_epoch.delete();
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=0;
                                refm.mem_blk_pages_control_second_epoch.tobusdata(data64bit_second_epoch, refm.mem_blk_pages_control_second_epoch.rd_page_idx, 32);
                                foreach(data64bit_second_epoch[s]) databusbit_second_epoch[s]=data64bit_second_epoch[s][32-1:0];
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=1;
                                axi_master_wr_control_seq.datamerge_inavg(databusbit_second_epoch, 0, 64, 1);
                                data64bit_second_region.delete(); databusbit_second_region.delete();
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=0;
                                refm.mem_blk_pages_control_second_region.tobusdata(data64bit_second_region, refm.mem_blk_pages_control_second_region.rd_page_idx, 32);
                                foreach(data64bit_second_region[s]) databusbit_second_region[s]=data64bit_second_region[s][32-1:0];
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=1;
                                axi_master_wr_control_seq.datamerge_inavg(databusbit_second_region, 0, 72, 1);
                                data64bit_load_ok.delete(); databusbit_load_ok.delete();
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=0;
                                refm.mem_blk_pages_control_load_ok.tobusdata(data64bit_load_ok, refm.mem_blk_pages_control_load_ok.rd_page_idx, 32);
                                foreach(data64bit_load_ok[s]) databusbit_load_ok[s]=data64bit_load_ok[s][32-1:0];
                                axi_master_wr_control_seq.StableAxiliteNoUpdate=1;
                                axi_master_wr_control_seq.datamerge_inavg(databusbit_load_ok, 0, 80, 1);
                                `uvm_send(axi_master_wr_control_seq);
                                refm.write_data_finish_control = 1;
                                `uvm_info("control data writting thread", $sformatf("%0dth(total 15): waiting for all write data finish event",i), UVM_LOW)
                                wait(refm.allaxilite_write_data_finish.triggered);
                                refm.write_data_finish_control = 0;
                                fork
                                    begin // configure start to enable DUT
                                        axi_master_wr_control_seq.wr_addr_data.push_back( (1<<0)+(0<<32) );
                                        `uvm_info("control start dut by axilite", $sformatf("%0dth(total 15): begin to set start bit",i), UVM_LOW)
                                        `uvm_send(axi_master_wr_control_seq);
                                    end
                                    begin
                                        `uvm_info("control wait for ap_ready for next trans", $sformatf("%0dth(total 15): begin to wait",i), UVM_LOW)
                                        wait(refm.dut2tb_ap_ready.triggered);
                                        wait(refm.ap_done_for_nexttrans.triggered);
                                        #0.01; //make sure mem incr_rd_page_idx is called first
                                    end
                                join
                            end
                        end
                        begin
                            for(int j=0; j<15; j=j+refm.ap_done_cnt) begin
                                wait(misc_if.dut2tb_ap_done_kernel == 1);
                                `uvm_info("test finish control", $sformatf("ap_done of kernel is triggered"), UVM_LOW)
                                @(posedge misc_if.clock);
                                fork
                                    forever begin
                                        `uvm_create_on(axi_master_poll_control_seq, p_sequencer.control_sqr);
                                        axi_master_poll_control_seq.isusr_delay = axi_pkg::NO_DELAY;
                                        axi_master_poll_control_seq.misc_if = refm.misc_if;
                                        axi_master_poll_control_seq.rd_addr.push_back(0);
                                        `uvm_send(axi_master_poll_control_seq)
                                        repeat(2) @(posedge misc_if.clock);
                                    end
                                    begin
                                        `uvm_info("test finish control", $sformatf("%0dth(total 15) ap_done_for_nexttrans begin to wait",j), UVM_LOW)
                                        @refm.dut2tb_ap_done;
                                    end
                                join_any
                                disable fork;
                                wait(refm.ap_ready_for_nexttrans.triggered);
                            end
                        end
                        begin
                            int control_r_page_idx_bak;
                            `uvm_create_on(axi_master_wr_control_r_seq, p_sequencer.control_r_sqr);
                            axi_master_wr_control_r_seq.misc_if = refm.misc_if;
                            axi_master_wr_control_r_seq.ap_done    = refm.ap_done_for_nexttrans   ;
                            axi_master_wr_control_r_seq.ap_ready   = refm.ap_ready_for_nexttrans  ;
                            axi_master_wr_control_r_seq.finish     = refm.finish ;
                            axi_master_wr_control_r_seq.isusr_delay = axi_pkg::NO_DELAY;
                            for(int i=0; i<15; i++) begin
                                logic[63:0] data64bit_out_r[$];
                                logic[32-1:0] databusbit_out_r[$];
                                data64bit_out_r.delete(); databusbit_out_r.delete();
                                axi_master_wr_control_r_seq.StableAxiliteNoUpdate=0;
                                for(int j=0; j < (64+32-1)/32; j++) begin
                                    data64bit_out_r.push_back( ((refm.mem_blk_pages_gmem.maxi_bundlevar_offset["out_r"]+refm.mem_blk_pages_gmem.page_ofst[refm.mem_blk_pages_gmem.rd_page_idx])>>(j*32)) & (2**32-1) );
                                end
                                foreach(data64bit_out_r[s]) databusbit_out_r[s]=data64bit_out_r[s][32-1:0];
                                axi_master_wr_control_r_seq.StableAxiliteNoUpdate=1;
                                axi_master_wr_control_r_seq.datamerge_inavg(databusbit_out_r, 0, 16, 1);
                                `uvm_send(axi_master_wr_control_r_seq);
                                refm.write_data_finish_control_r = 1;
                                `uvm_info("control_r data writting thread", $sformatf("%0dth(total 15): waiting for all write data finish event",i), UVM_LOW)
                                wait(refm.allaxilite_write_data_finish.triggered);
                                refm.write_data_finish_control_r = 0;
                                `uvm_info("control_r wait for ap_ready for next trans", $sformatf("%0dth(total 15): begin to wait",i), UVM_LOW)
                                wait(refm.dut2tb_ap_ready.triggered);
                                wait(refm.ap_done_for_nexttrans.triggered);
                                #0.01; //make sure mem incr_rd_page_idx is called first
                            end
                        end
                    join
                end

                begin
                    for(int j=0; j<15; j=j+refm.ap_done_cnt) @refm.ap_done_for_nexttrans;
                    `uvm_info(this.get_full_name(), "autotb finished", UVM_LOW)
                    -> refm.finish;
                    refm.misc_if.finished = 1;
                    @(posedge refm.misc_if.clock);
                    refm.misc_if.finished = 0;
                    @(posedge refm.misc_if.clock);
                    -> refm.misc_if.finished_evt;
                end
            join_any
            repeat(5) @(posedge refm.misc_if.clock); //5 cycles delay for finish stuff. 5 is haphazard value

            p_sequencer.gmem_sqr.stop_sequences();
            p_sequencer.control_sqr.stop_sequences();
            p_sequencer.control_r_sqr.stop_sequences();
            disable fork;
                                                                                                    
            starting_phase.drop_objection(this);                                                    
                                                                                                    
        endtask                                                                                     
    endclass                                                                                        
                                                                                                    
`endif                                                                                              
