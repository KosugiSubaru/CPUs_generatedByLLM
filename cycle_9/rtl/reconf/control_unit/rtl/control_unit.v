module control_unit (
    input  wire [3:0] i_opcode,
    input  wire       i_flag_z,
    input  wire       i_flag_n,
    input  wire       i_flag_v,
    output wire       o_reg_we,
    output wire       o_mem_we,
    output wire       o_alu_src_sel,
    output wire [1:0] o_wb_sel,
    output wire [3:0] o_alu_op,
    output wire [1:0] o_pc_sel
);

    wire [15:0] w_inst_onehot;

    control_unit_decoder u_control_unit_decoder (
        .i_opcode      (i_opcode     ),
        .o_inst_onehot (w_inst_onehot)
    );

    control_unit_logic u_control_unit_logic (
        .i_inst_onehot (w_inst_onehot),
        .o_reg_we      (o_reg_we     ),
        .o_mem_we      (o_mem_we     ),
        .o_alu_src_sel (o_alu_src_sel),
        .o_wb_sel      (o_wb_sel     ),
        .o_alu_op      (o_alu_op     )
    );

    control_unit_pc_logic u_control_unit_pc_logic (
        .i_inst_onehot (w_inst_onehot),
        .i_flag_z      (i_flag_z     ),
        .i_flag_n      (i_flag_n     ),
        .i_flag_v      (i_flag_v     ),
        .o_pc_sel      (o_pc_sel     )
    );

endmodule