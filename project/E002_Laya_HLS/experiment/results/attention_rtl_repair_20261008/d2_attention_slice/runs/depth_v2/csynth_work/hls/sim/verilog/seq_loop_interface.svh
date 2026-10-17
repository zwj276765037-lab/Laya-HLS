`ifndef SEQ_LOOP_INTF__SV
    `define SEQ_LOOP_INTF__SV
    `timescale 1ns/1ps
    interface seq_loop_intf#(parameter FSM_WIDTH = 2)(input clock, input reset);
        logic [FSM_WIDTH-1:0] cur_state;
        logic [13:0] pre_states_valid;
        logic [FSM_WIDTH-1:0] pre_loop_state0;
        logic [FSM_WIDTH-1:0] pre_loop_state1;
        logic [FSM_WIDTH-1:0] pre_loop_state2;
        logic [FSM_WIDTH-1:0] pre_loop_state3;
        logic [FSM_WIDTH-1:0] pre_loop_state4;
        logic [FSM_WIDTH-1:0] pre_loop_state5;
        logic [FSM_WIDTH-1:0] pre_loop_state6;
        logic [FSM_WIDTH-1:0] pre_loop_state7;
        logic [FSM_WIDTH-1:0] pre_loop_state8;
        logic [FSM_WIDTH-1:0] pre_loop_state9;
        logic [FSM_WIDTH-1:0] pre_loop_state10;
        logic [FSM_WIDTH-1:0] pre_loop_state11;
        logic [FSM_WIDTH-1:0] pre_loop_state12;
        logic [FSM_WIDTH-1:0] pre_loop_state13;
        logic [7:0] post_states_valid;
        logic [FSM_WIDTH-1:0] post_loop_state0;
        logic [FSM_WIDTH-1:0] post_loop_state1;
        logic [FSM_WIDTH-1:0] post_loop_state2;
        logic [FSM_WIDTH-1:0] post_loop_state3;
        logic [FSM_WIDTH-1:0] post_loop_state4;
        logic [FSM_WIDTH-1:0] post_loop_state5;
        logic [FSM_WIDTH-1:0] post_loop_state6;
        logic [FSM_WIDTH-1:0] post_loop_state7;
        logic [16:0] quit_states_valid;
        logic [FSM_WIDTH-1:0] quit_loop_state0;
        logic [FSM_WIDTH-1:0] quit_loop_state1;
        logic [FSM_WIDTH-1:0] quit_loop_state2;
        logic [FSM_WIDTH-1:0] quit_loop_state3;
        logic [FSM_WIDTH-1:0] quit_loop_state4;
        logic [FSM_WIDTH-1:0] quit_loop_state5;
        logic [FSM_WIDTH-1:0] quit_loop_state6;
        logic [FSM_WIDTH-1:0] quit_loop_state7;
        logic [FSM_WIDTH-1:0] quit_loop_state8;
        logic [FSM_WIDTH-1:0] quit_loop_state9;
        logic [FSM_WIDTH-1:0] quit_loop_state10;
        logic [FSM_WIDTH-1:0] quit_loop_state11;
        logic [FSM_WIDTH-1:0] quit_loop_state12;
        logic [FSM_WIDTH-1:0] quit_loop_state13;
        logic [FSM_WIDTH-1:0] quit_loop_state14;
        logic [FSM_WIDTH-1:0] quit_loop_state15;
        logic [FSM_WIDTH-1:0] quit_loop_state16;
        logic [FSM_WIDTH-1:0] loop_quit_state;
        logic [FSM_WIDTH-1:0] iter_start_state;
        logic iter_end_states_valid;
        logic [FSM_WIDTH-1:0] iter_end_state0;
        logic  one_state_loop;
        logic  one_state_block;
        logic  finish;
    endinterface
`endif
