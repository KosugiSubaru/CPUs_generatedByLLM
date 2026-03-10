module control_unit (
    input  wire [3:0]  i_opcode,       // 命令の下位4ビット
    input  wire        i_flag_z,       // 前サイクルのZeroフラグ
    input  wire        i_flag_n,       // 前サイクルのNegativeフラグ
    input  wire        i_flag_v,       // 前サイクルのOverflowフラグ
    output wire [3:0]  o_alu_mode,     // ALUの演算モード
    output wire        o_reg_wen,      // レジスタファイル書き込み有効信号
    output wire        o_dmem_wen,     // データメモリ書き込み有効信号
    output wire [1:0]  o_reg_src_sel,  // レジスタ書き戻しデータ選択 (0:ALU, 1:Mem, 2:Imm, 3:PC+2)
    output wire        o_alu_src_sel,  // ALU第二入力選択 (0:rs2, 1:imm)
    output wire [1:0]  o_pc_sel        // 次PC選択 (0:PC+2, 1:PC+imm, 2:rs1+imm)
);

    // デコーダ間を接続する16本の命令有効信号 (One-hot)
    wire [15:0] w_inst_onehot;

    // -------------------------------------------------------------------------
    // 1. 命令識別デコーダ (Opcode -> One-hot signals)
    // -------------------------------------------------------------------------
    control_unit_instruction_decoder u_inst_decoder (
        .i_opcode      (i_opcode),
        .o_inst_onehot (w_inst_onehot)
    );

    // -------------------------------------------------------------------------
    // 2. ALU演算デコーダ (Which instruction needs which ALU mode?)
    // -------------------------------------------------------------------------
    control_unit_alu_decoder u_alu_decoder (
        .i_inst_onehot (w_inst_onehot),
        .o_alu_mode    (o_alu_mode)
    );

    // -------------------------------------------------------------------------
    // 3. データパス・書き込み制御デコーダ (Write enables and MUX selectors)
    // -------------------------------------------------------------------------
    control_unit_data_decoder u_data_decoder (
        .i_inst_onehot (w_inst_onehot),
        .o_reg_wen     (o_reg_wen),
        .o_dmem_wen    (o_dmem_wen),
        .o_reg_src_sel (o_reg_src_sel),
        .o_alu_src_sel (o_alu_src_sel)
    );

    // -------------------------------------------------------------------------
    // 4. 分岐・ジャンプ制御デコーダ (PC selection logic using Flags)
    // -------------------------------------------------------------------------
    control_unit_branch_decoder u_branch_decoder (
        .i_inst_onehot (w_inst_onehot),
        .i_flag_z      (i_flag_z),
        .i_flag_n      (i_flag_n),
        .i_flag_v      (i_flag_v),
        .o_pc_sel      (o_pc_sel)
    );

endmodule