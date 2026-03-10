module instruction_decoder (
    input  wire [15:0] i_instr,
    output wire [3:0]  o_rd_addr,
    output wire [3:0]  o_rs1_addr,
    output wire [3:0]  o_rs2_addr,
    output wire        o_reg_write_en,
    output wire        o_dmem_wen,
    output wire [3:0]  o_alu_op,
    output wire        o_alu_src_sel,
    output wire [1:0]  o_reg_src_sel,
    output wire        o_is_blt,
    output wire        o_is_bz,
    output wire        o_is_jal,
    output wire        o_is_jalr
);

    wire [15:0] w_inst_active;

    assign o_rd_addr  = i_instr[15:12];
    assign o_rs1_addr = i_instr[11:8];
    assign o_rs2_addr = i_instr[7:4];

    instruction_decoder_op_selector u_op_sel (
        .i_opcode      (i_instr[3:0]),
        .o_inst_active (w_inst_active)
    );

    instruction_decoder_control_logic u_ctrl_logic (
        .i_inst_active  (w_inst_active),
        .o_reg_write_en (o_reg_write_en),
        .o_dmem_wen     (o_dmem_wen),
        .o_alu_op       (o_alu_op),
        .o_alu_src_sel  (o_alu_src_sel),
        .o_reg_src_sel  (o_reg_src_sel),
        .o_is_blt       (o_is_blt),
        .o_is_bz        (o_is_bz),
        .o_is_jal       (o_is_jal),
        .o_is_jalr      (o_is_jalr)
    );

endmodule