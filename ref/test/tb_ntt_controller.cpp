#include "Vntt_controller.h"
#include "verilated.h"
#include <iostream>

vluint64_t main_time = 0;

double sc_time_stamp() {
    return main_time;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vntt_controller* dut = new Vntt_controller;

    // Initialize
    dut->clk = 0;
    dut->rst = 1;
    dut->start = 0;

    // Reset
    for (int i = 0; i < 5; i++) {
        dut->clk ^= 1; dut->eval(); main_time++;
    }
    dut->rst = 0;

    // Start pulse
    dut->start = 1;
    for (int i = 0; i < 2; i++) {
        dut->clk ^= 1; dut->eval(); main_time++;
    }
    dut->start = 0;

    std::cout << "time\tstate\tlen_exp\tlen\tstart\tj\tk\tbfu\twe\twe_b\n";

    // Run simulation
    for (int cycle = 0; !(dut->done) ; cycle++) {

        // Rising edge
        dut->clk = 1;
        dut->eval();
        main_time++;

        // Print key signals
        std::cout << main_time << "\t"
                  << (int)dut->state_out << "\t"
                  << (int)dut->len_exp_out << "\t"
                  << (int)dut->len_out << "\t"
                  << (int)dut->start_idx_out << "\t"
                  << (int)dut->j_idx_out << "\t"
                  << (int)dut->k_out << "\t"
                  << (int)dut->bfu_valid << "\t"
                  << (int)dut->write_en << "\t"
                  << (int)dut->write_b_en
                  << std::endl;

        // Falling edge
        dut->clk = 0;
        dut->eval();
        main_time++;

        if (dut->done) {
            std::cout << "DONE at cycle " << cycle << std::endl;
            break;
        }
    }

    delete dut;
    return 0;
}