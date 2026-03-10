module control_unit (
    input  wire [15:0] i_instr,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    // レジスタファイル制御
    output wire [3:0]  o_reg_rs1_addr,
    output wire [3:0]  o_reg_rs2_addr,
    output wire [3:0]  o_reg_rd_addr,
    output wire        o_reg_file_wen,
    // ALU制御
    output wire [3:0]  o_alu_op,
    output wire        o_alu_src_b_sel, // 0:rs2, 1:imm
    // データメモリ制御
    output wire        o_dmem_wen,
    // 書き戻し選択 (Write Back)
    output wire [1:0]  o_reg_wb_sel,   // 00:ALU, 01:Mem, 10:PC+2
    // 次のPC選択
    output wire [1:0]  o_pc_sel        // 00:PC+2, 01:PC+imm, 10:rs1+imm, 11:PC(Hold)
);

    wire [15:0] w_inst_onehot;

    // 命令デコーダ：4bitのOpcodeを16本の命令特定信号に変換
    control_unit_instruction_decoder u_inst_dec (
        .i_opcode      (i_instr[3:0]),
        .o_inst_onehot (w_inst_onehot)
    );

    // 信号生成ロジック：特定された命令とフラグから、各ユニットの制御信号を生成
    control_unit_signal_logic u_sig_logic (
        .i_inst_onehot   (w_inst_onehot),
        .i_flag_z        (i_flag_z),
        .i_flag_n        (i_flag_n),
        .i_flag_v        (i_flag_v),
        .o_reg_file_wen  (o_reg_file_wen),
        .o_alu_op        (o_alu_op),
        .o_alu_src_b_sel (o_alu_src_b_sel),
        .o_dmem_wen      (o_dmem_wen),
        .o_reg_wb_sel    (o_reg_wb_sel),
        .o_pc_sel        (o_pc_sel)
    );

    // 命令フィールドからのアドレス抽出（ISA定義に基づく固定配線）
    assign o_reg_rd_addr  = i_instr[15:12];
    assign o_reg_rs1_addr = i_instr[11:8];
    assign o_reg_rs2_addr = i_instr[7:4];

endmodule