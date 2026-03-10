module instruction_decoder (
    input  wire [15:0] i_instr,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    output wire [3:0]  o_rd_addr,
    output wire [3:0]  o_rs1_addr,
    output wire [3:0]  o_rs2_addr,
    output wire [11:0] o_imm_bits,
    output wire        o_reg_wen,
    output wire        o_dmem_wen,
    output wire [3:0]  o_alu_op,
    output wire        o_alu_src_b_sel,  // 0:rs2, 1:imm
    output wire [1:0]  o_reg_wdata_sel, // 0:ALU, 1:Mem, 2:PC+2
    output wire [1:0]  o_pc_sel         // 0:PC+2, 1:PC+Imm, 2:rs1+Imm
);

    // 内部配線
    wire [3:0]  w_opcode;
    wire [15:0] w_inst_en; // 16種類の命令実行フラグ(One-Hot)

    // --- 1. フィールド分割階層 ---
    // 16bit命令から意味のあるビットフィールドを物理的に分離
    instruction_decoder_field_splitter u_splitter (
        .i_instr    (i_instr),
        .o_opcode   (w_opcode),
        .o_rd_addr  (o_rd_addr),
        .o_rs1_addr (o_rs1_addr),
        .o_rs2_addr (o_rs2_addr),
        .o_imm_bits (o_imm_bits)
    );

    // --- 2. オペコード展開階層 ---
    // 4bitのオペコードを16本の命令有効ラインに変換
    // 内部でgenerate文を用いて2to4デコーダをパターン構造化
    instruction_decoder_opcode_4to16 u_opcode_dec (
        .i_opcode  (w_opcode),
        .o_inst_en (w_inst_en)
    );

    // --- 3. 信号集約階層 ---
    // 命令有効フラグとフラグ入力を論理合成して、最終的な制御信号を出力
    instruction_decoder_signal_merger u_merger (
        .i_inst_en        (w_inst_en),
        .i_flag_z         (i_flag_z),
        .i_flag_n         (i_flag_n),
        .i_flag_v         (i_flag_v),
        .o_reg_wen        (o_reg_wen),
        .o_dmem_wen       (o_dmem_wen),
        .o_alu_op         (o_alu_op),
        .o_alu_src_b_sel  (o_alu_src_b_sel),
        .o_reg_wdata_sel  (o_reg_wdata_sel),
        .o_pc_sel         (o_pc_sel)
    );

endmodule