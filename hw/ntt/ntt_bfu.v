`timescale 1ns/1ps

module ntt_bfu (
    input  signed [31:0] a,
    input  signed [31:0] b,
    input  signed [31:0] zeta,
    output signed [31:0] a_out,
    output signed [31:0] b_out
);

    // Dilithium prime (force 64-bit)
    localparam signed [63:0] Q = 64'd8380417;
    localparam signed [31:0] QINV = 32'd58728449;  // Q^-1 mod 2^32

    // Full precision multiply
    wire signed [63:0] mul;
    assign mul = $signed(zeta) * $signed(b);

    // Montgomery reduction: r = a * 2^-32 (mod Q)
    // t_low = (a & 0xFFFFFFFF) * QINV & 0xFFFFFFFF
    wire signed [63:0] mul_qinv;
    assign mul_qinv = mul * $signed(QINV);
    wire signed [31:0] t_low;
    assign t_low = mul_qinv[31:0];
    
    // t = (a - t_low * Q) >> 32
    wire signed [63:0] t_reduction;
    assign t_reduction = mul - ($signed(t_low) * Q);
    wire signed [31:0] t;
    assign t = t_reduction[63:32];  // arithmetic right shift by 32 bits

    assign a_out = a + t;
    assign b_out = a - t;

endmodule
