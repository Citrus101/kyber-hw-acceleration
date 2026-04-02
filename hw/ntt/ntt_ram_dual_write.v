`timescale 1ns/1ps

module ntt_ram_dual_write (
    input clk,
    
    // Read ports
    input  [7:0] addr_a,
    output signed [31:0] data_out_a,
    input  [7:0] addr_b,
    output signed [31:0] data_out_b,
    
    // Write port A
    input  [7:0] addr_wr_a,
    input  signed [31:0] data_in_wr_a,
    input  we_a,
    
    // Write port B
    input  [7:0] addr_wr_b,
    input  signed [31:0] data_in_wr_b,
    input  we_b
);

    reg signed [31:0] mem [0:255];
    
    // Initialize memory to zero
    initial begin
        for (int i = 0; i < 256; i = i + 1) begin
            mem[i] = 0;
        end
    end

    // Combinational reads (use assign with combinational logic)
    assign data_out_a = mem[addr_a];
    assign data_out_b = mem[addr_b];
    
    // Synchronous writes - both ports independently
    always @(posedge clk) begin
        if (we_a) begin
            mem[addr_wr_a] <= data_in_wr_a;
        end
        if (we_b) begin
            mem[addr_wr_b] <= data_in_wr_b;
        end
    end

endmodule


