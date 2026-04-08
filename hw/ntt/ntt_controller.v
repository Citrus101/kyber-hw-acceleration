`timescale 1ns/1ps

module ntt_controller (
    input  clk,
    input  rst,
    input  start,
    output reg done,
    
    output reg [6:0] k,
    output reg [7:0] j,
    output reg [7:0] j_plus_len,
    output reg bfu_valid,
    output reg write_en,
    output reg write_b_en,  // Signal to write b_out to a[j+len]

    // Instrumentation outputs
    output reg [2:0] state_out,
    output reg [2:0] len_exp_out,
    // output reg [7:0] len_out,
    output reg [7:0] start_idx_out,
    output reg [7:0] j_idx_out,
    output reg [6:0] k_out
);

    localparam IDLE = 3'd0;
    localparam COMPUTE = 3'd1;
    localparam WRITE_A = 3'd2;
    localparam WRITE_B = 3'd3;
    localparam DONE_STATE = 3'd4;

    reg [2:0] state;
    reg [2:0] len_exp;
    reg [7:0] start_idx;
    reg [7:0] j_idx;
    reg [6:0] k_idx;
    
    wire [7:0] len_val = 8'd128 >> (7 - len_exp);

    // assign len_out = len_val;  // For instrumentation

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            len_exp <= 3'd7;
            start_idx <= 8'd0;
            j_idx <= 8'd0;
            k_idx <= 7'd1;
            k <= 7'd1;
            j <= 8'd0;
            j_plus_len <= 8'd128;
            bfu_valid <= 1'b0;
            write_en <= 1'b0;
            write_b_en <= 1'b0;
            done <= 1'b0;
        end else begin
            // Default: update outputs
            k <= k_idx;
            j <= j_idx;
            j_plus_len <= j_idx + len_val;
            // instrumentation
            state_out <= state;
            len_exp_out <= len_exp;
            start_idx_out <= start_idx;
            j_idx_out <= j_idx;
            k_out <= k_idx;

            case (state)
                IDLE: begin
                    bfu_valid <= 1'b0;
                    write_en <= 1'b0;
                    write_b_en <= 1'b0;
                    done <= 1'b0;
                    if (start) begin
                        state <= COMPUTE;
                        len_exp <= 3'd7;
                        start_idx <= 8'd0;
                        j_idx <= 8'd0;
                        k_idx <= 7'd1;
                    end
                end

                COMPUTE: begin
                    bfu_valid <= 1'b1;
                    write_en <= 1'b0;
                    write_b_en <= 1'b0;
                    state <= WRITE_A;
                end

                WRITE_A: begin
                    write_en <= 1'b1;  // Write a_out to a[j]
                    bfu_valid <= 1'b0;
                    write_b_en <= 1'b0;
                    state <= WRITE_B;
                end
                
                WRITE_B: begin
                    write_en <= 1'b0;
                    write_b_en <= 1'b1;  // Write b_out to a[j+len]
                    bfu_valid <= 1'b0;
                    
                    // Check if we've processed all j for this (start, len) pair BEFORE incrementing
                    if ((j_idx + 1) == (start_idx + len_val)) begin
                        // Done with this (start, len) pair
                        // k_idx increments once per (start, len) pair, at the END of all j iterations
                        k_idx <= k_idx + 1;
                        
                        // Done with this start, check if there's another start
                        if ((start_idx + 2*len_val) < 256) begin
                            // Next start value
                            start_idx <= start_idx + 2*len_val;
                            j_idx <= start_idx + 2*len_val;
                            state <= COMPUTE;
                        end else if (len_exp > 3'd1) begin
                            // Done with all starts for this len, move to next stage
                            len_exp <= len_exp - 1;
                            start_idx <= 8'd0;
                            j_idx <= 8'd0;
                            state <= COMPUTE;
                        end else begin
                            // All stages complete
                            state <= DONE_STATE;
                        end
                    end else begin
                        // More j values for this (start, len) pair
                        // Continue with next j, use the SAME zeta (k_idx does NOT increment)
                        j_idx <= j_idx + 1;  // Increment j_idx for next butterfly
                        state <= COMPUTE;
                    end
                end

                DONE_STATE: begin
                    done <= 1'b1;
                    bfu_valid <= 1'b0;
                    write_en <= 1'b0;
                    write_b_en <= 1'b0;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
