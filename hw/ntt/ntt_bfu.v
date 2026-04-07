`timescale 1ns/1ps

module ntt_bfu (
    input  signed [15:0] a,
    input  signed [15:0] b,
    input  signed [15:0] zeta,
    output signed [15:0] a_out,
    output signed [15:0] b_out
);

    // Parameters
    localparam signed [15:0] Q_16    = 16'd3329;   // Modulus
    localparam signed [16:0] Q_17 = 17'sd3329;  // Extended modulus for 32-bit operations
    localparam signed [31:0] Q_32 = 32'sd3329;  // Extended modulus for 32-bit operations
    localparam signed [15:0] QINV = 16'd62209;  // -q^{-1} mod 2^16

    // -----------------------------
    // Multiply: t = zeta * b
    // -----------------------------
    wire signed [31:0] t_32;
    wire signed [15:0] t_16;

    assign t_32 = zeta * b;
    assign t_16 = t_32[15:0]; // Take lower 16 bits for reduction


    // -----------------------------
    // Montgomery Reduction
    // -----------------------------
    wire signed [47:0] m_48;
    wire signed [31:0] m_32;
    wire signed [15:0] m_16;
    wire signed [31:0] u_32;
    wire signed [31:0] u_temp_32;
    wire signed [15:0] u_16;

    assign m_32 = m_48[31:0]; // Take lower 16 bits for reduction
    assign m_16 = m_32[15:0]; // Take lower 16 bits for reduction
    assign u_temp_32 = (u_32 >>> 16); 
    assign u_16 = u_temp_32[15:0]; // I do not have a good enough understanding about modulo arithmetic to get why we're doing this

    assign m_48 = t_32 * QINV;       // Compute t * QINV
    assign u_32 = (t_32 - m_16 * Q_16); // Divide by R (2^16)

    wire signed [15:0] u_reduced;

    wire signed [15:0] t_reduced;
    assign t_reduced = u_16;   

    // -----------------------------
    // Butterfly Computation
    // -----------------------------
    wire signed [16:0] plus;
    wire signed [16:0] minus;

    assign plus  = a + t_reduced;
    assign minus = a - t_reduced;

    // -----------------------------
    // Modular Correction
    // -----------------------------
    function signed [15:0] mod_q;
        input signed [16:0] x;
        begin
            if (x >= Q_17) x = x - Q_17;
            if (x >= Q_17) x = x - Q_17; // Ensure double reduction

            if (x < 0)  x = x + Q_17;
            if (x < 0)  x = x + Q_17; // Ensure double correction

            mod_q = x[15:0];
        end
    endfunction

    assign a_out = mod_q(plus);
    assign b_out = mod_q(minus);

endmodule