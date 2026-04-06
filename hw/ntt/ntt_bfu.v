`timescale 1ns/1ps

module ntt_bfu (
    input  signed [15:0] a,
    input  signed [15:0] b,
    input  signed [15:0] zeta,
    output signed [15:0] a_out,
    output signed [15:0] b_out
);

    // Parameters
    localparam signed [15:0] Q    = 16'd3329;   // Modulus
    localparam signed [31:0] Q_32 = 32'sd3329;  // Extended modulus for 32-bit operations
    localparam signed [16:0] Q_17 = 17'sd3329;  // Extended modulus for 32-bit operations
    localparam signed [15:0] QINV = 16'd62209;  // -q^{-1} mod 2^16

    // -----------------------------
    // Multiply: t = zeta * b
    // -----------------------------
    wire signed [31:0] t;
    assign t = zeta * b;

    // -----------------------------
    // Montgomery Reduction
    // -----------------------------
    wire signed [31:0] m_full;
    wire signed [15:0] m;
    wire signed [31:0] u;

    assign m_full = t * QINV;       // Compute t * QINV
    assign m = m_full[15:0];       // Take lower 16 bits
    assign u = (t - m * Q) >>> 16; // Divide by R (2^16)

    wire signed [31:0] u_corr;
    assign u_corr = (u >= Q_32) ? u - Q_32 : 
                    (u < 0)     ? u + Q_32 : 
                                  u;

    wire signed [15:0] t_red;
    assign t_red = u_corr[15:0];   // Reduced t

    // -----------------------------
    // Butterfly Computation
    // -----------------------------
    wire signed [16:0] a_plus;
    wire signed [16:0] a_minus;

    assign a_plus  = a + t_red;
    assign a_minus = a - t_red;

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

    assign a_out = mod_q(a_plus);
    assign b_out = mod_q(a_minus);

endmodule