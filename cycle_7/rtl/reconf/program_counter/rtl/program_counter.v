module program_counter (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,
    input  wire        i_pc_sel_target, // 1: Branch/Jump taken, 0: PC+2
    input  wire        i_pc_sel_rs1,    // 1: rs1+imm (jalr), 0: pc+imm (branch/jal)
    output wire [15:0] o_pc,
    output wire [15:0] o_pc_plus_2
);

    wire [15:0] w_next_pc;
    wire [15:0] w_target_pc;
    wire [15:0] w_base_addr;
    wire        w_unused_cout1;
    wire        w_unused_cout2;

    program_counter_reg_16bit u_pc_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_d     (w_next_pc),
        .o_q     (o_pc)
    );

    program_counter_adder_16bit u_adder_plus_2 (
        .i_a    (o_pc),
        .i_b    (16'd2),
        .i_cin  (1'b0),
        .o_sum  (o_pc_plus_2),
        .o_cout (w_unused_cout1)
    );

    program_counter_mux_2to1_16bit u_mux_base (
        .i_sel (i_pc_sel_rs1),
        .i_in0 (o_pc),
        .i_in1 (i_rs1_data),
        .o_out (w_base_addr)
    );

    program_counter_adder_16bit u_adder_target (
        .i_a    (w_base_addr),
        .i_b    (i_imm),
        .i_cin  (1'b0),
        .o_sum  (w_target_pc),
        .o_cout (w_unused_cout2)
    );

    program_counter_mux_2to1_16bit u_mux_next_pc (
        .i_sel (i_pc_sel_target),
        .i_in0 (o_pc_plus_2),
        .i_in1 (w_target_pc),
        .o_out (w_next_pc)
    );

endmodule