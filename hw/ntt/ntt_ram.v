`timescale 1ns/1ps

module ntt_ram (
    input  clk,
    input  [7:0] addr_a,              // Read port A (for a[j])
    output signed [15:0] data_out_a,
    
    input  [7:0] addr_b,              // Read port B (for a[j+len])
    output signed [15:0] data_out_b,
    
    input  [7:0] addr_wr,             // Write port
    input  signed [15:0] data_in_wr,
    input  we                         // Write enable
);

    // Dual-port RAM: 256 x 16-bit
    reg signed [15:0] mem[255:0];
    
    // Initialize memory
    initial begin
        for (int i = 0; i < 256; i = i + 1) begin
            mem[i] = 0;
        end
    end

    // Read port A (combinational)
    assign data_out_a = mem[addr_a];
    
    // Read port B (combinational)
    assign data_out_b = mem[addr_b];
    
    // Write port (synchronous, single-cycle write)
    always @(posedge clk) begin
        if (we)
            mem[addr_wr] <= data_in_wr;
    end

endmodule
