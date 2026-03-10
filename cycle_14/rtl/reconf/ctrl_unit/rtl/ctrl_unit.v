module ctrl_unit (
    input  wire [3:0] i_opcode,
    input  wire       i_flag_z,       // 1クロック前のフラグ
    input  wire       i_flag_n,       // 1クロック前のフラグ
    input  wire       i_flag_v,       // 1クロック前のフラグ
    output wire       o_reg_wen,      // レジスタファイル書き込み有効
    output wire       o_dmem_wen,     // データメモリ書き込み有効
    output wire       o_alu_src_sel,  // ALU入力B選択 (0: rs2, 1: imm)
    output wire [1:0] o_reg_wd_sel,   // レジスタ書き戻し選択 (0: ALU, 1: Mem, 2: PC+2)
    output wire [1:0] o_pc_sel,       // 次のPC選択 (0: PC+2, 1: PC+imm, 2: rs1+imm)
    output wire [3:0] o_alu_op        // ALU演算種別
);

    // デコーダから出力される16本の命令有効信号
    wire [15:0] w_instr_active;

    // 階層1: Opcodeを16本の個別信号に展開
    ctrl_unit_decoder_16 u_decoder (
        .i_opcode (i_opcode),
        .o_active (w_instr_active)
    );

    // 階層1: 命令有効信号を束ねてデータパス制御信号を生成
    ctrl_unit_mixer u_mixer (
        .i_active      (w_instr_active),
        .o_reg_wen     (o_reg_wen),
        .o_dmem_wen    (o_dmem_wen),
        .o_alu_src_sel (o_alu_src_sel),
        .o_reg_wd_sel  (o_reg_wd_sel),
        .o_alu_op      (o_alu_op)
    );

    // 階層1: 命令とフラグの状態からPCの遷移先を決定
    ctrl_unit_pc_logic u_pc_logic (
        .i_active (w_instr_active),
        .i_flag_z (i_flag_z),
        .i_flag_n (i_flag_n),
        .i_flag_v (i_flag_v),
        .o_pc_sel (o_pc_sel)
    );

endmodule