module alu_core (
    input  wire [3:0]  i_alu_op,
    input  wire [15:0] i_operand_a,
    input  wire [15:0] i_operand_b,
    output wire [15:0] o_result,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    wire [15:0] w_res_arith;
    wire [15:0] w_res_logic;
    wire [15:0] w_res_shift;
    wire        w_v_arith;

    alu_core_arithmetic_16bit u_arith (
        .i_a      (i_operand_a),
        .i_b      (i_operand_b),
        .i_is_sub (i_alu_op[0]),
        .o_sum    (w_res_arith),
        .o_v      (w_v_arith)
    );

    alu_core_logic_16bit u_logic (
        .i_a   (i_operand_a),
        .i_b   (i_operand_b),
        .i_sel (i_alu_op[1:0]),
        .o_res (w_res_logic)
    );

    alu_core_shifter_16bit u_shift (
        .i_a   (i_operand_a),
        .i_b   (i_operand_b),
        .i_sel (i_alu_op[0]),
        .o_res (w_res_shift)
    );

    alu_core_mux_8to1_16bit u_res_mux (
        .i_sel (i_alu_op[2:0]),
        .i_d0  (w_res_arith),
        .i_d1  (w_res_arith),
        .i_d2  (w_res_logic),
        .i_d3  (w_res_logic),
        .i_d4  (w_res_logic),
        .i_d5  (w_res_logic),
        .i_d6  (w_res_shift),
        .i_d7  (w_res_shift),
        .o_y   (o_result)
    );

    assign o_flag_z = (o_result == 16'h0000);
    assign o_flag_n = o_result[15];
    assign o_flag_v = (i_alu_op[3:1] == 3'b000) ? w_v_arith : 1'b0;

endmodule