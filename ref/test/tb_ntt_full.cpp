#include <stdio.h>
#include <stdint.h>
#include <verilated.h>
#include "Vntt_full.h"
#include "reduce.h"
#include "ntt.h"

vluint64_t sim_time = 0;

double sc_time_stamp() {
    return sim_time;
}

// Clock tick
void tick(Vntt_full* dut) {
    dut->clk = 0;
    dut->eval();
    sim_time++;

    dut->clk = 1;
    dut->eval();
    sim_time++;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vntt_full* dut = new Vntt_full;
    uint8_t input[256] = {0};
    int16_t output[256] = {0};
    input[0] = 1;
    output[0] = 1;
    pqcrystals_kyber512_ref_ntt(output);
    // -----------------------
    // Reset
    // -----------------------
    dut->rst = 1;
    dut->start = 0;
    dut->ext_we = 0;

    for (int i = 0; i < 5; i++) tick(dut);

    dut->rst = 0;

    // -----------------------
    // Load input (impulse)
    // a[0] = 1, rest = 0
    // -----------------------
    for (int i = 0; i < 256; i++) {
        dut->ext_addr = i;
        dut->ext_data_in = (i == 0);
        dut->ext_we = 1;
        tick(dut);
    }
    dut->ext_we = 0;

    // -----------------------
    // Start NTT
    // -----------------------
    dut->start = 1;
    tick(dut);
    dut->start = 0;

    // -----------------------
    // Run until done
    // -----------------------
    while (!dut->done && sim_time < 5000) {
        tick(dut);
    }

    // -----------------------
    // Read output
    // -----------------------
    printf("\nNTT Output \n");
    for (int i = 0; i < 16; i++) {
        dut->ext_addr = i;
        dut->ext_we = 0;
        tick(dut);

        printf("HW %d: %d\n", i, dut->ext_data_out);
    }
    for (int i = 0; i < 16; i++) {
        dut->ext_addr = i;
        dut->ext_we = 0;
        tick(dut);

        printf("SW %d: %d\n", i, output[i]);
    }

    delete dut;
    return 0;
}