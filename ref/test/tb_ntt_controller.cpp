#include "Vntt_controller.h"
#include "verilated.h"
#include <iostream>

vluint64_t main_time = 0;

// Clock toggle helper
void tick(Vntt_controller* top) {
    top->clk = 0;
    top->eval();
    main_time++;

    top->clk = 1;
    top->eval();
    main_time++;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vntt_controller* top = new Vntt_controller;

    std::cout << "Starting NTT Controller Test...\n";

    // 🔁 Reset
    top->rst = 1;
    top->start = 0;
    tick(top);
    tick(top);

    // Release reset
    top->rst = 0;

    // 🚀 Start signal (1-cycle pulse)
    top->start = 1;
    tick(top);
    top->start = 0;

    // 🧠 Run simulation
    int max_cycles = 5000;

    for (int i = 0; i < max_cycles; i++) {
        tick(top);

        // Print useful debug info
        std::cout << "Cycle " << i
                  << " | state=" << (int)top->state_out
                  << " len_exp=" << (int)top->len_exp_out
                  << " start=" << (int)top->start_idx_out
                  << " j=" << (int)top->j_idx_out
                  << " k=" << (int)top->k_out
                  << " done=" << (int)top->done
                  << "\n";

        if (top->done) {
            std::cout << "✅ DONE reached at cycle " << i << "\n";
            break;
        }
    }

    top->final();
    delete top;
    return 0;
}