`timescale 1ns/1ps
module ntt_full (
    input  clk,
    input  rst,
    input  start,
    output done,
    input  [7:0] ext_addr,
    output signed [15:0] ext_data_out,
    input  signed [15:0] ext_data_in,
    input  ext_we,
    
    // Instrumentation outputs from controller
    output [2:0] state_out,
    output [2:0] len_exp_out,
    output [7:0] start_idx_out,
    output [7:0] j_idx_out,
    output [6:0] k_out,
    
    // Debug outputs
    output [7:0] write_addr_out,
    output write_en_out,
    output write_b_en_out,
    output [7:0] j_reg_out,
    output [7:0] j_plus_len_reg_out,
    output bfu_valid_out,
    output [7:0] j_comb_out,
    output [7:0] j_plus_len_comb_out
);


    wire [6:0] k;
    wire [7:0] j, j_plus_len;
    wire bfu_valid, write_en, write_b_en;
    wire signed [15:0] ram_out_a, ram_out_b;
    wire signed [15:0] bfu_a_out, bfu_b_out;
    wire signed [15:0] zeta_data;
    
    // Register BFU outputs only (not addresses!)
    reg signed [15:0] bfu_a_out_reg, bfu_b_out_reg;
    
    // Capture BFU outputs during COMPUTE
    always @(posedge clk) begin
        if (rst) begin
            bfu_a_out_reg <= 16'd0;
            bfu_b_out_reg <= 16'd0;
        end else if (bfu_valid) begin
            bfu_a_out_reg <= bfu_a_out;
            bfu_b_out_reg <= bfu_b_out;
        end
    end
    
    // ===== KEY FIX: Use controller addresses DIRECTLY =====
    // No address registers needed! RAM reads are combinational.
    wire [7:0] ram_addr_a = ext_we ? ext_addr : j;
    wire [7:0] ram_addr_b = ext_we ? 8'd0 : j_plus_len;
    
    // Write addresses: use controller values directly too
    wire [7:0] write_addr = ext_we ? ext_addr : (write_b_en ? j_plus_len : j);
    wire we = ext_we | write_en | write_b_en;
    wire signed [15:0] write_data = ext_we ? ext_data_in : (write_b_en ? bfu_b_out_reg : bfu_a_out_reg);
    
    // Zeta ROM
    zetas_rom zeta_rom_inst (
        .addr(k),
        .data(zeta_data)
    );
    
    // RAM - combinational reads
    ntt_ram ram_inst (
        .clk(clk),
        .addr_a(ram_addr_a),
        .data_out_a(ram_out_a),
        .addr_b(ram_addr_b),
        .data_out_b(ram_out_b),
        .addr_wr(write_addr),
        .data_in_wr(write_data),
        .we(we)
    );
    
    // BFU
    ntt_bfu bfu_inst (
        .a(ram_out_a),
        .b(ram_out_b),
        .zeta(zeta_data),
        .a_out(bfu_a_out),
        .b_out(bfu_b_out)
    );
    
    // Controller
    ntt_controller ctrl_inst (
        .clk(clk),
        .rst(rst),
        .start(start & ~ext_we),
        .done(done),
        .k(k),
        .j(j),
        .j_plus_len(j_plus_len),
        .bfu_valid(bfu_valid),
        .write_en(write_en),
        .write_b_en(write_b_en),
        .state_out(state_out),
        .len_exp_out(len_exp_out),
        .start_idx_out(start_idx_out),
        .j_idx_out(j_idx_out),
        .k_out(k_out)
    );
    
    assign ext_data_out = ram_out_a;
    
    // Debug outputs - need to create j_reg for compatibility
    reg [7:0] j_reg_debug, j_plus_len_reg_debug;
    always @(posedge clk) begin
        if (rst) begin
            j_reg_debug <= 0;
            j_plus_len_reg_debug <= 0;
        end else begin
            j_reg_debug <= j;
            j_plus_len_reg_debug <= j_plus_len;
        end
    end
    
    assign write_addr_out = write_addr;
    assign write_en_out = write_en;
    assign write_b_en_out = write_b_en;
    assign j_reg_out = j_reg_debug;
    assign j_plus_len_reg_out = j_plus_len_reg_debug;
    assign bfu_valid_out = bfu_valid;
    assign j_comb_out = j;
    assign j_plus_len_comb_out = j_plus_len;

endmodule
