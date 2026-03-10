module instruction_decoder (
    input  wire [15:0] i_instr,
    input  wire        i_flag_z,         // 1クロック前のフラグ
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    output wire [3:0]  o_rs1_addr,
    output wire [3:0]  o_rs2_addr,
    output wire [3:0]  o_rd_addr,
    output wire [3:0]  o_alu_op,         // ALUへの演算指示
    output wire        o_reg_wen,        // レジスタファイル書き込み許可
    output wire        o_dmem_wen,       // データメモリ書き込み許可
    output wire [1:0]  o_pc_sel,         // 次PC選択 (00:normal, 01:imm_jump, 10:rs1_jump)
    output wire        o_alu_src_b_sel,  // ALU入力B選択 (0:rs2, 1:imm)
    output wire [1:0]  o_reg_wdata_sel   // レジスタ書き込みデータ選択 (0:ALU, 1:Mem, 2:PC+2, 3:Imm)
);

    wire [15:0] w_inst_valid;            // One-hot展開された16本の命令有効信号
    wire        w_branch_taken;          // 分岐条件成立信号

    // 命令フィールドの単純抽出 (視覚的な配線)
    assign o_rs1_addr = i_instr[11:8];
    assign o_rs2_addr = i_instr[7:4];
    assign o_rd_addr  = i_instr[15:12];

    // L1: Opcode(4bit)を16本の命令信号に展開する
    instruction_decoder_onehot_4to16 u_onehot (
        .i_opcode (i_instr[3:0]),
        .o_valid  (w_inst_valid)
    );

    // L1: 分岐命令の条件判定
    instruction_decoder_branch_eval u_branch_eval (
        .i_inst_valid (w_inst_valid),
        .i_flag_z     (i_flag_z),
        .i_flag_n     (i_flag_n),
        .i_flag_v     (i_flag_v),
        .o_taken      (w_branch_taken)
    );

    // L1: 16本の命令信号から各制御信号を生成する論理回路
    instruction_decoder_ctrl_logic u_ctrl_logic (
        .i_inst_valid     (w_inst_valid),
        .i_branch_taken   (w_branch_taken),
        .o_alu_op         (o_alu_op),
        .o_reg_wen        (o_reg_wen),
        .o_dmem_wen       (o_dmem_wen),
        .o_pc_sel         (o_pc_sel),
        .o_alu_src_b_sel  (o_alu_src_b_sel),
        .o_reg_wdata_sel  (o_reg_wdata_sel)
    );

endmodule