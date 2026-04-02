#include "Vntt_full.h"
#include "verilated.h"
#include <iostream>
#include <cstdint>

// The reference NTT is compiled as C++ in this build, declare with C++ linkage
extern void pqcrystals_dilithium2_ref_ntt(int32_t a[256]);

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Vntt_full* top = new Vntt_full;

    // Test vector
    // int32_t hw_data[256] = {0};
    // int32_t sw_data[256] = {0};
    // hw_data[0] = 1;
    // hw_data[1] = 2;
    // sw_data[0] = 1;
    // sw_data[1] = 2;
    int32_t hw_data[256];
    int32_t sw_data[256];
    for (int i = 0; i < 256; i++) {
        hw_data[i] = i;  // 1,2,3,...,256
        sw_data[i] = i;
    }
    // === RESET ===
    top->rst = 1;
    top->start = 0;
    top->ext_we = 0;
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();
    top->rst = 0;
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();

    // === LOAD RAM ===
    std::cout << "Loading [1, 2, 0, ...]\n";
    top->ext_we = 1;
    for (int i = 0; i < 256; i++) {
        top->ext_addr = i;
        top->ext_data_in = hw_data[i];
        top->clk = 0; top->eval();
        top->clk = 1; top->eval();
    }
    top->ext_we = 0;


    // === VERIFY RAM WORKS ===
    std::cout << "Verifying RAM read/write...\n";
    top->ext_we = 1;
    top->ext_addr = 0;
    top->clk = 0; top->eval();
    std::cout << "RAM[0] = " << top->ext_data_out << " (expect 1)\n";

    top->ext_addr = 1;
    top->clk = 0; top->eval();
    std::cout << "RAM[1] = " << top->ext_data_out << " (expect 2)\n";

    top->ext_addr = 5;
    top->clk = 0; top->eval();
    std::cout << "RAM[5] = " << top->ext_data_out << " (expect 0)\n";
    top->ext_we = 0;


    // === RUN HARDWARE NTT WITH DETAILED TRACE ===
    std::cout << "\n=== STARTING NTT ===\n";
    top->rst = 1;
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();
    top->rst = 0;
    top->start = 1;
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();
    top->start = 0;

    std::cout << "\nFirst 30 cycles (detailed):\n";
    std::cout << "Cycle | State | j_idx | j_reg | j_comb | bfu_v | wr_en | wr_b | wr_addr | k\n";
    std::cout << "------|-------|-------|-------|--------|-------|-------|------|---------|---\n";
    
    for (int c = 0; c < 30; c++) {
        top->clk = 0; top->eval();
        top->clk = 1; top->eval();
        
        printf("%5d | %5d | %5d | %5d | %6d | %5d | %5d | %4d | %7d | %3d\n",
               c,
               (int)top->state_out,
               (int)top->j_idx_out,
               (int)top->j_reg_out,
               (int)top->j_comb_out,
               (int)top->bfu_valid_out,
               (int)top->write_en_out,
               (int)top->write_b_en_out,
               (int)top->write_addr_out,
               (int)top->k_out);
    }

    // Continue to completion
    int cycles = 30;
    while (!top->done && cycles < 5000) {
        top->clk = 0; top->eval();
        top->clk = 1; top->eval();
        cycles++;
    }
    
    if (!top->done) {
        std::cout << "❌ TIMEOUT\n";
        delete top;
        return 1;
    }
    std::cout << "\n✅ HW done in " << cycles << " cycles\n\n";

    // === READ OUTPUT ===
    top->ext_we = 1;
    for (int i = 0; i < 256; i++) {
        top->ext_addr = i;
        top->clk = 0; top->eval();
        hw_data[i] = top->ext_data_out;
    }
    top->ext_we = 0;


    // Print first 20 HW outputs
    std::cout << "First 20 HW outputs:\n";
    for (int i = 0; i < 20; i++) {
        std::cout << "HW[" << i << "] = " << hw_data[i] << "\n";
    }

    // === RUN SOFTWARE NTT ===
    std::cout << "Running SW NTT...\n";
    pqcrystals_dilithium2_ref_ntt(sw_data);


    // Print first 20 SW outputs
    std::cout << "First 20 SW outputs:\n";
    for (int i = 0; i < 20; i++) {
        std::cout << "SW[" << i << "] = " << sw_data[i] << "\n";
    }


    

    // === COMPARE ===
    int mismatches = 0;
    for (int i = 0; i < 256; i++) {
        if (hw_data[i] != sw_data[i]) {
            if (mismatches < 10) {
                std::cout << "MISMATCH [" << i << "]: HW=" << hw_data[i] 
                          << " SW=" << sw_data[i] << "\n";
            }
            mismatches++;
        }
    }

    if (mismatches == 0) {
        std::cout << "✅ PASS: All 256 values match!\n";
    } else {
        std::cout << "❌ FAIL: " << mismatches << " mismatches\n";
    }

    delete top;
    return (mismatches > 0) ? 1 : 0;
}