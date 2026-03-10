module program_counter (
    input wire         i_clk,
    input wire         i_rst_n,
    input wire [15:0]  i_imm,
    input wire [15:0]  i_rs1,
    input wire         i_jump_en,
    input wire         i_jalr_sel,
    input wire         i_branch_taken,
    output wire [15:0] o_pc,
    output wire [15:0] o_pc_plus_2
);

    wire [15:0] w_pc_current;
    wire [15:0] w_pc_next;
    wire [15:0] w_pc_plus_2;
    wire [15:0] w_pc_target;
    wire [15:0] w_target_base;
    wire        w_sel_pc_target;
    wire        w_unused_cout1;
    wire        w_unused_cout2;

    assign o_pc = w_pc_current;
    assign o_pc_plus_2 = w_pc_plus_2;
    assign w_sel_pc_target = i_jump_en | i_branch_taken;

    program_counter_reg_16bit u_pc_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_d     (w_pc_next),
        .o_q     (w_pc_current)
    );

    program_counter_adder_16bit u_adder_plus_2 (
        .i_a    (w_pc_current),
        .i_b    (16'h0002),
        .i_cin  (1'b0),
        .o_sum  (w_pc_plus_2),
        .o_cout (w_unused_cout1)
    );

    program_counter_mux2_16bit u_mux_base (
        .i_sel (i_jalr_sel),
        .i_d0  (w_pc_current),
        .i_d1  (i_rs1),
        .o_q   (w_target_base)
    );

    program_counter_adder_16bit u_adder_target (
        .i_a    (w_target_base),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (w_pc_target),
        .o_cout (w_unused_cout2)
    );

    program_counter_mux2_16bit u_mux_next (
        .i_sel (w_sel_pc_target),
        .i_d0  (w_pc_plus_2),
        .i_d1  (w_pc_target),
        .o_q   (w_pc_next)
    );

endmodule