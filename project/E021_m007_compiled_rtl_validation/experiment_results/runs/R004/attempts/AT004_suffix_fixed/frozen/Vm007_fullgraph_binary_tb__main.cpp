// Verilated -*- C++ -*-
// DESCRIPTION: main() calling loop, created with Verilator --main

#include "verilated.h"
#include "Vm007_fullgraph_binary_tb___024root.h"
#include <cstdio>
#include <string>
#include <cstdint>
#include "Vm007_fullgraph_binary_tb.h"

//======================

int main(int argc, char** argv, char**) {
    // Setup context, defaults, and parse command line
    Verilated::debug(0);
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    contextp->threads(1);
    contextp->commandArgs(argc, argv);

    // Construct the Verilated model, from Vtop.h generated from Verilating
    const std::unique_ptr<Vm007_fullgraph_binary_tb> topp{new Vm007_fullgraph_binary_tb{contextp.get()}};

    unsigned long long last_observed[15] = {~0ULL,~0ULL,~0ULL,~0ULL,~0ULL,~0ULL,~0ULL,~0ULL,~0ULL,~0ULL,~0ULL,~0ULL,~0ULL,~0ULL,~0ULL};
    unsigned last_phase_state = ~0U, last_head_mask = ~0U, last_matrix_done = ~0U, last_global = ~0U;


    std::string export_path;
    for (int i=1;i<argc;i++) if (std::string(argv[i]).rfind("+EXPORT=",0)==0) export_path=std::string(argv[i]).substr(8);
    if(export_path.empty()) return 3;
    FILE *layer_file=nullptr,*layer_trace=nullptr;
    bool previous_clk=false,latched_fire=false; unsigned latched_addr=0,latched_global=30,active_capture=30;
    uint32_t latched_data[32]={}; unsigned captured[30]={}; bool seen[30][4096]={},capture_complete[30]={};
    unsigned long long eval_calls=0,low_samples=0,rising_samples=0;

    bool ln_observe_active=false,ln_held_pending=false; unsigned ln_expected_gamma=0,ln_expected_epoch=0,ln_held_gamma=0,ln_held_epoch=0,ln_wait_cycles=0; unsigned long long ln_start_cycle=0;

    unsigned last_fc2_global=30;
    // Simulate until $finish
    while (!contextp->gotFinish()) {
        // Evaluate model
        topp->eval();


        ++eval_calls;
        const bool current_clk=topp->rootp->m007_fullgraph_binary_tb__DOT__clk;
        if(current_clk&&!previous_clk) {
            ++rising_samples;
            if(latched_fire) {
                const unsigned gl=latched_global;
                if(gl>=30||captured[gl]>=4096||latched_addr>=4096||seen[gl][latched_addr]||topp->rootp->m007_fullgraph_binary_tb__DOT__layer_H_count[gl]!=captured[gl]+1) {std::printf("M007_LAYER_CAPTURE_ERROR actual_edge_count_or_coordinate\n");std::fflush(stdout);return 4;}
                if(active_capture!=gl) {
                    if(active_capture<30&&!capture_complete[active_capture]) {std::printf("M007_LAYER_CAPTURE_ERROR unfinished_previous_layer\n");return 4;}
                    active_capture=gl;
                    layer_file=std::fopen((export_path+".layer"+std::to_string(gl)+".f32.bin").c_str(),"wb");
                    layer_trace=std::fopen((export_path+".layer"+std::to_string(gl)+".accepted.jsonl").c_str(),"w");
                    if(!layer_file||!layer_trace)return 4;
                }
                if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__0__KET____DOT__words[latched_addr]!=latched_data[0]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__1__KET____DOT__words[latched_addr]!=latched_data[1]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__2__KET____DOT__words[latched_addr]!=latched_data[2]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__3__KET____DOT__words[latched_addr]!=latched_data[3]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__4__KET____DOT__words[latched_addr]!=latched_data[4]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__5__KET____DOT__words[latched_addr]!=latched_data[5]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__6__KET____DOT__words[latched_addr]!=latched_data[6]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__7__KET____DOT__words[latched_addr]!=latched_data[7]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__8__KET____DOT__words[latched_addr]!=latched_data[8]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__9__KET____DOT__words[latched_addr]!=latched_data[9]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__10__KET____DOT__words[latched_addr]!=latched_data[10]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__11__KET____DOT__words[latched_addr]!=latched_data[11]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__12__KET____DOT__words[latched_addr]!=latched_data[12]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__13__KET____DOT__words[latched_addr]!=latched_data[13]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__14__KET____DOT__words[latched_addr]!=latched_data[14]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__15__KET____DOT__words[latched_addr]!=latched_data[15]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__16__KET____DOT__words[latched_addr]!=latched_data[16]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__17__KET____DOT__words[latched_addr]!=latched_data[17]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__18__KET____DOT__words[latched_addr]!=latched_data[18]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__19__KET____DOT__words[latched_addr]!=latched_data[19]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__20__KET____DOT__words[latched_addr]!=latched_data[20]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__21__KET____DOT__words[latched_addr]!=latched_data[21]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__22__KET____DOT__words[latched_addr]!=latched_data[22]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__23__KET____DOT__words[latched_addr]!=latched_data[23]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__24__KET____DOT__words[latched_addr]!=latched_data[24]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__25__KET____DOT__words[latched_addr]!=latched_data[25]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__26__KET____DOT__words[latched_addr]!=latched_data[26]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__27__KET____DOT__words[latched_addr]!=latched_data[27]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__28__KET____DOT__words[latched_addr]!=latched_data[28]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__29__KET____DOT__words[latched_addr]!=latched_data[29]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__30__KET____DOT__words[latched_addr]!=latched_data[30]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__31__KET____DOT__words[latched_addr]!=latched_data[31]) {std::printf("M007_LAYER_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
                unsigned char bytes[128];for(unsigned lane=0;lane<32;lane++)for(unsigned octet=0;octet<4;octet++)bytes[4*lane+octet]=(latched_data[lane]>>(8*octet))&255;
                if(std::fseek(layer_file,128*latched_addr,SEEK_SET)||std::fwrite(bytes,1,128,layer_file)!=128)return 4;
                std::fprintf(layer_trace,"{\"global_layer\":%u,\"accept_seq\":%u,\"cycle\":%llu,\"address\":%u,\"data_hex_lane0_lsb\":\"",gl,captured[gl],static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle),latched_addr);
                for(int lane=31;lane>=0;lane--)std::fprintf(layer_trace,"%08x",latched_data[lane]);std::fprintf(layer_trace,"\"}\n");
                seen[gl][latched_addr]=true;++captured[gl];
            }
        }
        if(!current_clk) {
            ++low_samples;

            // Read-only snapshot before the next physical rising edge. No added eval.
            const unsigned ln_st=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__state,ln_gl=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__layer_index,ln_gamma=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__p_ln_cmd_gamma,ln_epoch=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__p_ln_cmd_epoch;
            const bool ln_start=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__v2_resident_ln_start_valid&&topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__v2_resident_ln_start_ready,ln_valid=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__p_ln_cmd_valid,ln_ready=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__ln_cmd_ready;
            if(ln_start) {
                if(ln_observe_active) {std::printf("M007_LN_HOLD_ERROR overlapping_start\n");return 4;}
                ln_observe_active=true;ln_expected_gamma=ln_st==89;ln_expected_epoch=ln_epoch;ln_start_cycle=topp->rootp->m007_fullgraph_binary_tb__DOT__cycle;ln_wait_cycles=0;ln_held_pending=false;
            }
            if(ln_observe_active) {
                std::printf("M007_LN_COMMAND_OBSERVE global=%u state=%u epoch=%u gamma=%u expected_gamma=%u rows=128 valid=%u ready=%u start_fire=%u cycle=%llu\n",ln_gl,ln_st,ln_epoch,ln_gamma,ln_expected_gamma,ln_valid,ln_ready,ln_start,static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle));std::fflush(stdout);
                if(ln_gamma!=ln_expected_gamma||ln_epoch!=ln_expected_epoch||(ln_held_pending&&(!ln_valid||ln_gamma!=ln_held_gamma||ln_epoch!=ln_held_epoch))) {std::printf("M007_LN_HOLD_ERROR gamma_epoch_or_unaccepted_command_changed\n");std::fflush(stdout);return 4;}
                ln_held_pending=ln_valid&&!ln_ready;
                if(ln_held_pending) {++ln_wait_cycles;ln_held_gamma=ln_gamma;ln_held_epoch=ln_epoch;}
                if(ln_valid&&ln_ready) {
                    std::printf("M007_LN_COMMAND_HOLD_OK global=%u gamma=%u epoch=%u rows=128 start_cycle=%llu command_observed_cycle=%llu natural_delay_cycles=%llu valid_wait_cycles=%u\n",ln_gl,ln_gamma,ln_epoch,ln_start_cycle,static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle),static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle)-ln_start_cycle,ln_wait_cycles);std::fflush(stdout);ln_observe_active=false;ln_held_pending=false;
                }
            }

            latched_fire=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__state==54&&topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__layer_index<30&&topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__vector_h_wr_valid&&topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__vector_h_wr_ready&&topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__vector_h_wr_commit&&topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__raw_h_wr_commit;
            if(latched_fire) {latched_global=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__layer_index;latched_addr=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__raw_h_wr_addr;for(unsigned lane=0;lane<32;lane++)latched_data[lane]=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__raw_h_wr_data[lane];}
        }
        previous_clk=current_clk;
        if(active_capture<30&&!capture_complete[active_capture]&&(topp->rootp->m007_fullgraph_binary_tb__DOT__layer_complete_seen&(1U<<active_capture))&&topp->rootp->m007_fullgraph_binary_tb__DOT__layer_H_count[active_capture]==4096) {
            const unsigned gl=active_capture;
            if(captured[gl]!=4096) {std::printf("M007_LAYER_CAPTURE_ERROR missing_actual_handshakes\n");std::fflush(stdout);return 4;}
            for(unsigned i=0;i<4096;i++)if(!seen[gl][i])return 4;
            std::fflush(layer_file);std::fflush(layer_trace);std::fclose(layer_file);std::fclose(layer_trace);layer_file=layer_trace=nullptr;capture_complete[gl]=true;
            FILE* meta=std::fopen((export_path+".layer"+std::to_string(gl)+".capture.json").c_str(),"w");if(!meta)return 4;
            std::fprintf(meta,"{\"complete\":true,\"global_layer\":%u,\"accepted_groups32\":4096,\"unique_groups32\":4096,\"bytes\":524288,\"eval_calls\":%llu,\"logical_cycle\":%llu,\"rising_samples\":%llu,\"low_samples\":%llu,\"provenance\":\"actual low-phase interface snapshot, following posedge original checker count and committed hidden bank verified; no gold reconstruction\"}\n",gl,eval_calls,static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle),rising_samples,low_samples);std::fclose(meta);
            std::printf("M007_LAYER_CAPTURE_COMPLETE global=%u groups=4096 bytes=524288 cycle=%llu eval_calls=%llu\n",gl,static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle),eval_calls);std::fflush(stdout);
        }

        { const unsigned gl = topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__layer_index; const unsigned st = topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__state; const unsigned hm = topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__l_head_completed; const unsigned md = gl < 30 ? topp->rootp->m007_fullgraph_binary_tb__DOT__layer_mdone[gl] : ~0U; if (st != last_phase_state || hm != last_head_mask || md != last_matrix_done || gl != last_global) { std::printf("M007_FULLGRAPH_PHASE global=%u state=%u heads=%u matrix_done=%u cycle=%llu\n", gl, st, hm, md, static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle)); std::fflush(stdout); last_phase_state=st; last_head_mask=hm; last_matrix_done=md; last_global=gl; } }
        { const unsigned gl=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__layer_index,st=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__state; if(gl>=28&&gl<30&&st==102&&last_fc2_global!=gl) {
            std::printf("M007_DECISION_FC2_ADMITTED global=%u writes=%u acks=%u closed=%u success=%u published=%u debt=%u cycle=%llu\n",gl,topp->rootp->m007_fullgraph_binary_tb__DOT__fc1_Awrites[gl-28],topp->rootp->m007_fullgraph_binary_tb__DOT__fc1_Aacks[gl-28],topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__front__DOT__producer_closed,topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__front__DOT__producer_success,topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__front__DOT__a_published,topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__front__DOT__a_write_debt,static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle));std::fflush(stdout);last_fc2_global=gl;
        } }


        // Read-only post-eval observation: no signal writes or extra eval calls.
        {
            const unsigned long long observed[] = {static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__commands),static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__h_count) / 1024,static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__catalog_runtime),static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__matrix_commands),static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__layers_completed),static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__ln_commands),static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__vector_commands),static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__g_commands),static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__exports) / 128,static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__full_active),static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__tail_commits),static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__tail_writes) / 128,static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__final_norm_count) / 1024,static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__type_count) / 1024,static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__layer_index)};
            bool changed = false;
            for (unsigned i = 0; i < 15; ++i) { if (observed[i] != last_observed[i]) changed = true; last_observed[i] = observed[i]; }
            if (changed) {
                std::printf("M007_FULLGRAPH_OBS cycle=%llu commands=%llu h_count=%llu catalog_runtime=%llu matrix_commands=%llu layers_completed=%llu ln_commands=%llu vector_commands=%llu g_commands=%llu exports=%llu full_active=%llu tail_commits=%llu tail_writes=%llu final_norm_count=%llu type_count=%llu global_layer=%llu\n", static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__commands), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__h_count), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__catalog_runtime), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__matrix_commands), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__layers_completed), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__ln_commands), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__vector_commands), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__g_commands), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__exports), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__full_active), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__tail_commits), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__tail_writes), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__final_norm_count), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__type_count), static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__layer_index));
                std::fflush(stdout);
            }
        }

        // Advance time
        if (!topp->eventsPending()) break;
        contextp->time(topp->nextTimeSlot());
    }

    if (!contextp->gotFinish()) {
        VL_DEBUG_IF(VL_PRINTF("+ Exiting without $finish; no events left\n"););
    }

    // Final model cleanup
    topp->final();
    return 0;
}
