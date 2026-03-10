module instruction_decoder_control_logic (
    input  wire [15:0] i_instr_signals,
    output wire        o_reg_wen,
    output wire        o_mem_wen,
    output wire        o_mem_to_reg,
    output wire        o_alu_src_b_imm,
    output wire [1:0]  o_reg_data_sel, // 00:ALU, 01:Mem, 10:PC+2, 11:Imm
    output wire        o_branch_blt,
    output wire        o_branch_bz,
    output wire        o_jump_jal,
    output wire        o_jump_jalr
);

    // 各命令の有効信号をデコード済み信号バスから取得（視覚化のため）
    wire is_add   = i_instr_signals[0];
    wire is_sub   = i_instr_signals[1];
    wire is_and   = i_instr_signals[2];
    wire is_or    = i_instr_signals[3];
    wire is_xor   = i_instr_signals[4];
    wire is_not   = i_instr_signals[5];
    wire is_sra   = i_instr_signals[6];
    wire is_sla   = i_instr_signals[7];
    wire is_addi  = i_instr_signals[8];
    wire is_loadi = i_instr_signals[9];
    wire is_load  = i_instr_signals[10];
    wire is_store = i_instr_signals[11];
    wire is_blt   = i_instr_signals[12];
    wire is_bz    = i_instr_signals[13];
    wire is_jal   = i_instr_signals[14];
    wire is_jalr  = i_instr_signals[15];

    // レジスタ書き込み有効: Store, Branch以外は基本的に書き込む
    assign o_reg_wen = is_add | is_sub | is_and | is_or | is_xor | is_not | 
                       is_sra | is_sla | is_addi | is_loadi | is_load | 
                       is_jal | is_jalr;

    // データメモリ書き込み有効
    assign o_mem_wen = is_store;

    // メモリからレジスタへのロード
    assign o_mem_to_reg = is_load;

    // ALUの第2入力に即値を使用する命令
    // loadiはALUを通さない場合もあるが、統一的な計算（0+Imm）としても扱える
    assign o_alu_src_b_imm = is_addi | is_load | is_store | is_loadi;

    // レジスタに書き込むデータの選択ロジック
    // 00: ALU result
    // 01: Memory output (load)
    // 10: PC + 2 (jal/jalr)
    // 11: Immediate (loadi)
    assign o_reg_data_sel[0] = is_load | is_loadi;
    assign o_reg_data_sel[1] = is_jal | is_jalr | is_loadi;

    // 分岐・ジャンプ制御信号
    assign o_branch_blt = is_blt;
    assign o_branch_bz  = is_bz;
    assign o_jump_jal   = is_jal;
    assign o_jump_jalr  = is_jalr;

endmodule