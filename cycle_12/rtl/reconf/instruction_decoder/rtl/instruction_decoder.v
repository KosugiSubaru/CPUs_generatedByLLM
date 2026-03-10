module instruction_decoder (
    input  wire [15:0] i_instr,
    output wire [3:0]  o_opcode,
    output wire [3:0]  o_rd_addr,
    output wire [3:0]  o_rs1_addr,
    output wire [3:0]  o_rs2_addr,
    output wire [11:0] o_imm_raw
);

    wire [3:0] w_nibble_0;
    wire [3:0] w_nibble_1;
    wire [3:0] w_nibble_2;
    wire [3:0] w_nibble_3;

    // 1. 命令語を4ビットずつのニブルに物理分割
    instruction_decoder_field_slicer u_slicer (
        .i_instr    (i_instr),
        .o_nibble_0 (w_nibble_0), // Opcode
        .o_nibble_1 (w_nibble_1), // Rs2 / Imm
        .o_nibble_2 (w_nibble_2), // Rs1 / Imm
        .o_nibble_3 (w_nibble_3)  // Rd / Imm
    );

    // オペコードの確定
    assign o_opcode = w_nibble_0;

    // 2. フィールドから各レジスタアドレスを抽出
    instruction_decoder_reg_selector u_reg_selector (
        .i_nibble_1 (w_nibble_1),
        .i_nibble_2 (w_nibble_2),
        .i_nibble_3 (w_nibble_3),
        .o_rd_addr  (o_rd_addr),
        .o_rs1_addr (o_rs1_addr),
        .o_rs2_addr (o_rs2_addr)
    );

    // 3. オペコードに応じて命令内の即値ビットを収集
    instruction_decoder_imm_selector u_imm_selector (
        .i_opcode   (w_nibble_0),
        .i_nibble_1 (w_nibble_1),
        .i_nibble_2 (w_nibble_2),
        .i_nibble_3 (w_nibble_3),
        .o_imm_raw  (o_imm_raw)
    );

endmodule