module control_unit (
    input  wire [15:0] i_instr,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,

    output wire        o_reg_file_wen,
    output wire [3:0]  o_alu_op,
    output wire        o_alu_src_sel,
    output wire        o_dmem_wen,
    output wire        o_mem_to_reg,
    output wire        o_pc_src_sel,
    output wire        o_pc_base_sel,
    output wire        o_reg_data_sel
);

    wire [15:0] w_instr_decoded;

    control_unit_decoder_4to16 u_control_unit_decoder_4to16 (
        .i_opcode  (i_instr[3:0]),
        .o_decoded (w_instr_decoded)
    );

    control_unit_signal_logic u_control_unit_signal_logic (
        .i_instr_decoded (w_instr_decoded),
        .i_flag_z        (i_flag_z),
        .i_flag_n        (i_flag_n),
        .i_flag_v        (i_flag_v),
        .o_reg_file_wen  (o_reg_file_wen),
        .o_alu_op        (o_alu_op),
        .o_alu_src_sel   (o_alu_src_sel),
        .o_dmem_wen      (o_dmem_wen),
        .o_mem_to_reg    (o_mem_to_reg),
        .o_pc_src_sel    (o_pc_src_sel),
        .o_pc_base_sel   (o_pc_base_sel),
        .o_reg_data_sel  (o_reg_data_sel)
    );

endmodule