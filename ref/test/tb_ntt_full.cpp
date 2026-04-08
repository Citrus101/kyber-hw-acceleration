#include <stdio.h>
#include <stdint.h>
#include <verilated.h>
#include "Vntt_full.h"
#include "reduce.h"
#include "ntt.h"

vluint64_t sim_time = 0;

extern "C" void ntt_hw(int16_t *a);

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

void the_main_loop_got_too_long(void) {
    int16_t input[256];
    int16_t output[256] = {0};

    for(int i=0;i<256;i++){
        // int16_t val = (i == 0) || (i == 1) || (i >= 0);
        int16_t val = (i * 23048230) % KYBER_Q;

        input[i] = val;
        output[i] = val;
    }

    ntt_hw(output);
    pqcrystals_kyber512_ref_invntt(output);

    for(int i=0;i<16;i++){
        printf("input: %d cycled output: %d \n", input[i], montgomery_reduce(output[i]));
    }
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vntt_full* dut = new Vntt_full;
    uint8_t input[256] = {0};
    int16_t output[256] = {0};
    input[0] = 1;
    output[0] = 1;
    for(int i=0;i<256;i++){
        output[i] = 1;
    }
    pqcrystals_kyber512_ref_ntt(output);

    the_main_loop_got_too_long();
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
        dut->ext_data_in = -2;
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

    // -----------------
    // WAIT FOR DONE
    // -----------------
    int cycles = 0;
    while (!dut->done && cycles < 20000) {
        dut->clk = 0; dut->eval();
        dut->clk = 1; dut->eval();
        cycles++;
    }


    // -----------------------
    // Read output
    // -----------------------
    // printf("\nNTT Output \n");
    // for (int i = 0; i < 16; i++) {
    //     dut->ext_addr = i;
    //     dut->ext_we = 0;
    //     tick(dut);

    //     printf("HW %d: %d\n", i, (int16_t)dut->ext_data_in);
    // }
    // for (int i = 0; i < 16; i++) {
    //     dut->ext_addr = i;
    //     dut->ext_we = 0;
    //     tick(dut);

    //     printf("HW %d: %d\n", i, dut->ext_data_out);
    // }
    // for (int i = 0; i < 16; i++) {
    //     dut->ext_addr = i;
    //     dut->ext_we = 0;
    //     tick(dut);

    //     printf("SW %d: %d\n", i, montgomery_reduce(output[i]));
    // }

    delete dut;
    return 0;
}