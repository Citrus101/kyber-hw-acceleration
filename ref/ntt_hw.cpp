#include "Vntt_full.h"
#include "verilated.h"
#include <cstdint>
#include <cstdio>

extern "C" void ntt_hw(int16_t *a) {
    Vntt_full *top = new Vntt_full;

    // -----------------
    // RESET
    // -----------------
    top->rst = 1;
    top->start = 0;
    top->ext_we = 0;

    top->clk = 0; top->eval();
    top->clk = 1; top->eval();

    top->rst = 0;
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();

    // -----------------
    // LOAD INPUT RAM
    // -----------------
    top->ext_we = 1;
    for (int i = 0; i < 256; i++) {
        top->ext_addr = i;
        top->ext_data_in = a[i];
        top->clk = 0; top->eval();
        top->clk = 1; top->eval();
    }
    top->ext_we = 0;


    //printf("[HW] Input loaded, starting NTT...\n");

    // -----------------
    // START NTT
    // -----------------
    top->start = 1;
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();
    top->start = 0;

    // -----------------
    // WAIT FOR DONE
    // -----------------
    int cycles = 0;
    while (!top->done && cycles < 20000) {
        top->clk = 0; top->eval();
        top->clk = 1; top->eval();
        cycles++;
    }

    if (!top->done) {
        printf("[HW] ERROR: NTT timeout\n");
        delete top;
        return;
    }

    // -----------------
    // READ OUTPUT RAM
    // -----------------
    // ext_we selects external address mux; avoid posedge to prevent writes.
    top->ext_we = 1;
    top->ext_data_in = 0;
    top->clk = 0;
    for (int i = 0; i < 256; i++) {
        top->ext_addr = i;
        top->eval();
        a[i] = top->ext_data_out;
    }

    delete top;
}