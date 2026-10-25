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
    FILE* layer_file=std::fopen((export_path+".layer0.f32.bin").c_str(),"wb");
    FILE* layer_trace=std::fopen((export_path+".layer0.accepted.jsonl").c_str(),"w");
    if(!layer_file||!layer_trace) return 3;
    bool previous_clk=false,latched_fire=false,capture_complete=false; unsigned latched_addr=0,captured=0; uint32_t latched_data[32]={}; bool seen[4096]={};
    unsigned long long eval_calls=0,low_samples=0,rising_samples=0;

    // Simulate until $finish
    while (!contextp->gotFinish()) {
        // Evaluate model
        topp->eval();

        ++eval_calls;
        const bool current_clk=topp->rootp->m007_fullgraph_binary_tb__DOT__clk;
        if(current_clk&&!previous_clk) {
            ++rising_samples;
            if(latched_fire) {
                if(captured>=4096||latched_addr>=4096||seen[latched_addr]||topp->rootp->m007_fullgraph_binary_tb__DOT__layer_H_count[0]!=captured+1) { std::printf("M007_LAYER0_CAPTURE_ERROR actual_edge_count_or_coordinate\n"); std::fflush(stdout); return 4; }
                if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__0__KET____DOT__words[latched_addr]!=latched_data[0]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__1__KET____DOT__words[latched_addr]!=latched_data[1]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__2__KET____DOT__words[latched_addr]!=latched_data[2]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__3__KET____DOT__words[latched_addr]!=latched_data[3]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__4__KET____DOT__words[latched_addr]!=latched_data[4]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__5__KET____DOT__words[latched_addr]!=latched_data[5]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__6__KET____DOT__words[latched_addr]!=latched_data[6]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__7__KET____DOT__words[latched_addr]!=latched_data[7]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__8__KET____DOT__words[latched_addr]!=latched_data[8]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__9__KET____DOT__words[latched_addr]!=latched_data[9]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__10__KET____DOT__words[latched_addr]!=latched_data[10]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__11__KET____DOT__words[latched_addr]!=latched_data[11]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__12__KET____DOT__words[latched_addr]!=latched_data[12]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__13__KET____DOT__words[latched_addr]!=latched_data[13]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__14__KET____DOT__words[latched_addr]!=latched_data[14]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__15__KET____DOT__words[latched_addr]!=latched_data[15]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__16__KET____DOT__words[latched_addr]!=latched_data[16]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__17__KET____DOT__words[latched_addr]!=latched_data[17]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__18__KET____DOT__words[latched_addr]!=latched_data[18]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__19__KET____DOT__words[latched_addr]!=latched_data[19]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__20__KET____DOT__words[latched_addr]!=latched_data[20]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__21__KET____DOT__words[latched_addr]!=latched_data[21]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__22__KET____DOT__words[latched_addr]!=latched_data[22]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__23__KET____DOT__words[latched_addr]!=latched_data[23]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__24__KET____DOT__words[latched_addr]!=latched_data[24]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__25__KET____DOT__words[latched_addr]!=latched_data[25]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__26__KET____DOT__words[latched_addr]!=latched_data[26]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__27__KET____DOT__words[latched_addr]!=latched_data[27]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__28__KET____DOT__words[latched_addr]!=latched_data[28]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__29__KET____DOT__words[latched_addr]!=latched_data[29]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__30__KET____DOT__words[latched_addr]!=latched_data[30]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
if(topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__hidden__DOT__channel_bank__BRA__31__KET____DOT__words[latched_addr]!=latched_data[31]) {std::printf("M007_LAYER0_CAPTURE_ERROR committed_bank_payload\n");std::fflush(stdout);return 4;}
                unsigned char bytes[128]; for(unsigned lane=0;lane<32;lane++)for(unsigned octet=0;octet<4;octet++)bytes[4*lane+octet]=(latched_data[lane]>>(8*octet))&255;
                if(std::fseek(layer_file,128*latched_addr,SEEK_SET)||std::fwrite(bytes,1,128,layer_file)!=128) return 4;
                std::fprintf(layer_trace,"{\"accept_seq\":%u,\"cycle\":%llu,\"address\":%u,\"data_hex_lane0_lsb\":\"",captured,static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle),latched_addr);
                for(int lane=31;lane>=0;lane--)std::fprintf(layer_trace,"%08x",latched_data[lane]); std::fprintf(layer_trace,"\"}\n");
                seen[latched_addr]=true;++captured;
            }
        }
        if(!current_clk) {
            ++low_samples;
            latched_fire=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__state==54&&topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__layer_index==0&&topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__vector_h_wr_valid&&topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__vector_h_wr_ready&&topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__vector_h_wr_commit&&topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__raw_h_wr_commit;
            if(latched_fire) { latched_addr=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__raw_h_wr_addr;for(unsigned lane=0;lane<32;lane++)latched_data[lane]=topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__resident__DOT__raw_h_wr_data[lane]; }
        }
        previous_clk=current_clk;
        if(!capture_complete&&topp->rootp->m007_fullgraph_binary_tb__DOT__layers_completed==1&&(topp->rootp->m007_fullgraph_binary_tb__DOT__layer_complete_seen&1)&&topp->rootp->m007_fullgraph_binary_tb__DOT__layer_H_count[0]==4096) {
            if(captured!=4096) {std::printf("M007_LAYER0_CAPTURE_ERROR missing_actual_handshakes\n");std::fflush(stdout);return 4;}
            for(unsigned i=0;i<4096;i++)if(!seen[i])return 4;
            std::fflush(layer_file);std::fflush(layer_trace);std::fclose(layer_file);std::fclose(layer_trace);capture_complete=true;
            FILE* meta=std::fopen((export_path+".layer0.capture.json").c_str(),"w");if(!meta)return 4;
            std::fprintf(meta,"{\"complete\":true,\"accepted_groups32\":4096,\"unique_groups32\":4096,\"bytes\":524288,\"eval_calls\":%llu,\"logical_cycle\":%llu,\"rising_samples\":%llu,\"low_samples\":%llu,\"provenance\":\"actual low-phase interface snapshot, following posedge original checker count and committed hidden bank verified; no gold reconstruction\"}\n",eval_calls,static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle),rising_samples,low_samples);std::fclose(meta);
            std::printf("M007_LAYER0_CAPTURE_COMPLETE groups=4096 bytes=524288 cycle=%llu eval_calls=%llu\n",static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle),eval_calls);std::fflush(stdout);
        }

        { const unsigned gl = topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__layer_index; const unsigned st = topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__state; const unsigned hm = topp->rootp->m007_fullgraph_binary_tb__DOT__dut__DOT__l_head_completed; const unsigned md = gl < 30 ? topp->rootp->m007_fullgraph_binary_tb__DOT__layer_mdone[gl] : ~0U; if (st != last_phase_state || hm != last_head_mask || md != last_matrix_done || gl != last_global) { std::printf("M007_FULLGRAPH_PHASE global=%u state=%u heads=%u matrix_done=%u cycle=%llu\n", gl, st, hm, md, static_cast<unsigned long long>(topp->rootp->m007_fullgraph_binary_tb__DOT__cycle)); std::fflush(stdout); last_phase_state=st; last_head_mask=hm; last_matrix_done=md; last_global=gl; } }

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
