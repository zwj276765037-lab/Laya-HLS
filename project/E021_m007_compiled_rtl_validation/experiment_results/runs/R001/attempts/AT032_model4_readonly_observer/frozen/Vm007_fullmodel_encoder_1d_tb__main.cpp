// Verilated -*- C++ -*-
// DESCRIPTION: main() calling loop, created with Verilator --main

#include "verilated.h"
#include "Vm007_fullmodel_encoder_1d_tb___024root.h"
#include <array>
#include <cstdio>
#include "Vm007_fullmodel_encoder_1d_tb.h"

//======================

int main(int argc, char** argv, char**) {
    // Setup context, defaults, and parse command line
    Verilated::debug(0);
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    contextp->threads(4);
    contextp->commandArgs(argc, argv);

    // Construct the Verilated model, from Vtop.h generated from Verilating
    const std::unique_ptr<Vm007_fullmodel_encoder_1d_tb> topp{new Vm007_fullmodel_encoder_1d_tb{contextp.get()}};

    std::array<uint64_t, 15> last_diag{};
    bool diag_started=false, debt_dumped=false;
    auto observe = [&](const char* when) {
        auto* const r=topp->rootp;
        if(r->m007_fullmodel_encoder_1d_tb__DOT__cycle < 64000 && !r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__protocol_bad && !r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__sm_error_valid && !r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__h_done_status) return;
        const unsigned h=unsigned(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__l_active_head)&15U;
        const std::array<uint64_t, 15> current_diag{(uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__state), (uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__state), (uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__owner), (uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__state), (uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__protocol_bad), (uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__incoming_error), (uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__sm_error_valid), (uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__sm_done_status), (uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__h_done_valid), (uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__h_done_status), (uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__q_done_status), (uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__q_error_valid), (uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__aborted), (uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__h_check_qk_done), (uint64_t)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__h_check_sm_done)};
        if(!diag_started || current_diag!=last_diag) {
            std::printf("M007_CPP_DIAG when=%s cycle=%llu active_head=%llu layer_state=%llu head_state=%llu owner=%llu sm_state=%llu protocol_bad=%llu incoming_error=%llu sm_error_valid=%llu sm_error_phase=%llu sm_error_rank=%llu sm_status=%llu aborted=%llu q_status=%llu q_error_valid=%llu q_error_phase=%llu q_error_rank=%llu h_valid=%llu h_ready=%llu h_status=%llu h_cycles=%llu qk_done=%llu sm_done=%llu nrope=%llu qkv_count=%llu layer_starts=%llu nheads=%llu head_request=%llu cmd_request=%llu head_generation=%llu cmd_generation=%llu head_identity=%llu max_checked=%llu shift_debt=%llu score=%llu prob=%llu context=%llu prob_ack=%llu maximum=%llu\n", when, (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__cycle), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__l_active_head), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__state), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__state), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__owner), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__state), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__protocol_bad), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__incoming_error), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__sm_error_valid), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__sm_error_phase), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__sm_error_rank), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__sm_done_status), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__aborted), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__q_done_status), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__q_error_valid), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__q_error_phase), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__q_error_rank), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__h_done_valid), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__h_done_ready), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__h_done_status), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__h_done_cycles), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__h_check_qk_done), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__h_check_sm_done), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__nrope), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__qkv_count), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__layer_starts), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__nheads), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__request_id), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__cmd_request), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__generation), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__cmd_generation), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__head), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__max_checked), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__shift_debt), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__head_score[h]), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__head_prob[h]), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__head_context[h]), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__head_prob_ack[h]), (unsigned long long)(r->m007_fullmodel_encoder_1d_tb__DOT__head_maximum[h]));
            std::fflush(stdout);
            diag_started=true; last_diag=current_diag;
        }
        if(!debt_dumped && (r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__protocol_bad || r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__sm_error_valid || r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__h_done_status)) {
            debt_dumped=true;
            std::printf("M007_CPP_DIAG_DEBT kind=fp_debt words="); for(unsigned i=0;i<14;++i) std::printf("%08x%s",unsigned(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__fp_debt[i]), i+1==14?"\n":",");
            std::printf("M007_CPP_DIAG_DEBT kind=sfu_debt words="); for(unsigned i=0;i<12;++i) std::printf("%08x%s",unsigned(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__sfu_debt[i]), i+1==12?"\n":",");
            std::printf("M007_CPP_DIAG_DEBT kind=div_debt words="); for(unsigned i=0;i<12;++i) std::printf("%08x%s",unsigned(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__div_debt[i]), i+1==12?"\n":",");
            std::printf("M007_CPP_DIAG_DEBT kind=score_debt words="); for(unsigned i=0;i<12;++i) std::printf("%08x%s",unsigned(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__score_debt[i]), i+1==12?"\n":",");
            std::printf("M007_CPP_DIAG_DEBT kind=exp_read_debt words="); for(unsigned i=0;i<12;++i) std::printf("%08x%s",unsigned(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__exp_read_debt[i]), i+1==12?"\n":",");
            std::printf("M007_CPP_DIAG_DEBT kind=exp_write_debt words="); for(unsigned i=0;i<12;++i) std::printf("%08x%s",unsigned(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__exp_write_debt[i]), i+1==12?"\n":",");
            std::printf("M007_CPP_DIAG_DEBT kind=prob_debt words="); for(unsigned i=0;i<12;++i) std::printf("%08x%s",unsigned(r->m007_fullmodel_encoder_1d_tb__DOT__dut__DOT__resident__DOT__joint__DOT__layer__DOT__head__DOT__softmax__DOT__prob_debt[i]), i+1==12?"\n":",");
            std::fflush(stdout);
        }
    };

    // Simulate until $finish
    while (!contextp->gotFinish()) {
        // Evaluate model
        observe("pre");
        topp->eval();
        observe("post");
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
