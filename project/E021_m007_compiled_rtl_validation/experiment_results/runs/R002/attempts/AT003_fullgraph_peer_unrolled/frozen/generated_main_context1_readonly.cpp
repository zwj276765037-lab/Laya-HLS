// Verilated -*- C++ -*-
// DESCRIPTION: main() calling loop, created with Verilator --main

#include "verilated.h"
#include "Vm007_fullgraph_binary_tb___024root.h"
#include <cstdio>
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
    // Simulate until $finish
    while (!contextp->gotFinish()) {
        // Evaluate model
        topp->eval();
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
