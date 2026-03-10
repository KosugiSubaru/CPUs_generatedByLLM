module control_unit (
    input  wire [3:0] i_opcode,
    output wire       o_reg_write,
    output wire       o_mem_write,
    output wire       o_mem_to_reg,
    output wire       o_alu_src,
    output wire       o_reg_data_sel,
    output wire [3:0] o_alu_op
);

    wire [15:0] w_inst_active;

    // Opcode(4bit)を16本のデコード信号へ展開
    // 内部で control_unit_instruction_gate を16個 generate インスタンス化
    control_unit_decoder u_decoder (
        .i_opcode      (i_opcode),
        .o_inst_active (w_inst_active)
    );

    // デコードされた16本の信号をマトリクス状に配線し、各制御信号を生成
    // 信号の集約（OR論理）により各ユニットへの指示を決定
    control_unit_op_matrix u_matrix (
        .i_inst_active   (w_inst_active),
        .o_reg_write     (o_reg_write),
        .o_mem_write     (o_mem_write),
        .o_mem_to_reg    (o_mem_to_reg),
        .o_alu_src       (o_alu_src),
        .o_reg_data_sel  (o_reg_data_sel),
        .o_alu_op        (o_alu_op)
    );

endmodule