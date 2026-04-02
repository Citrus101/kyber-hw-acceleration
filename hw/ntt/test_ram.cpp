#include "Vntt_ram_dual_write.h"
#include "verilated.h"
#include <iostream>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vntt_ram_dual_write* ram = new Vntt_ram_dual_write;
    
    std::cout << "Testing dual-write RAM...\n";
    
    // Reset
    ram->clk = 0;
    ram->eval();
    
    // Write test: write 5 to address 0
    ram->addr_wr_a = 0;
    ram->data_in_wr_a = 5;
    ram->we_a = 1;
    ram->we_b = 0;
    ram->clk = 0; ram->eval();
    ram->clk = 1; ram->eval();  // Clock posedge
    
    // Read test: read from address 0
    ram->we_a = 0;
    ram->addr_a = 0;
    ram->clk = 0; ram->eval();
    std::cout << "After writing 5 to addr 0, read from addr 0: " << (int)ram->data_out_a << " (expected 5)\n";
    
    // Write to address 1
    ram->addr_wr_a = 1;
    ram->data_in_wr_a = 10;
    ram->we_a = 1;
    ram->clk = 0; ram->eval();
    ram->clk = 1; ram->eval();
    
    // Read from both addresses
    ram->we_a = 0;
    ram->addr_a = 0;
    ram->addr_b = 1;
    ram->clk = 0; ram->eval();
    std::cout << "After writing to both, addr 0: " << (int)ram->data_out_a << " (expected 5), addr 1: " << (int)ram->data_out_b << " (expected 10)\n";
    
    delete ram;
    return 0;
}
