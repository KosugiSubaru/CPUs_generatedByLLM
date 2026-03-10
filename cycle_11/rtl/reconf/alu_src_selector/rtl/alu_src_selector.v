module alu_src_selector (
    input  wire        i_alu_src_b_sel,
    input  wire [15:0] i_rs2_data,
    input  wire [15:0] i_imm_data,
    output wire [15:0] o_alu_operand_b
);

    alu_src_selector_mux_2to1_16bit u_mux_operand_b (
        .i_sel (i_alu_src_b_sel),
        .i_d0  (i_rs2_data),
        .i_d1  (i_imm_data),
        .o_y   (o_alu_operand_b)
    );

endmodule