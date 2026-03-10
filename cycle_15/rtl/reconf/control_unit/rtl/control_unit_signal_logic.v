module control_unit_signal_logic (
    input  wire [15:0] i_inst_onehot,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,
    // 制御信号出力
    output wire        o_reg_file_wen,
    output wire [3:0]  o_alu_op,
    output wire        o_alu_src_b_sel, // 0:rs2, 1:imm
    output wire        o_dmem_wen,
    output wire [1:0]  o_reg_wb_sel,    // 00:ALU, 01:Mem, 10:PC+2
    output wire [1:0]  o_pc_sel         // 00:PC+2, 01:PC+imm, 10:rs1+imm, 11:PC
);

    // 命令One-hot信号のエイリアス（可読性と回路図での視覚化のため）
    wire w_inst_add   = i_inst_onehot[0];
    wire w_inst_sub   = i_inst_onehot[1];
    wire w_inst_and   = i_inst_onehot[2];
    wire w_inst_or    = i_inst_onehot[3];
    wire w_inst_xor   = i_inst_onehot[4];
    wire w_inst_not   = i_inst_onehot[5];
    wire w_inst_sra   = i_inst_onehot[6];
    wire w_inst_sla   = i_inst_onehot[7];
    wire w_inst_addi  = i_inst_onehot[8];
    wire w_inst_loadi = i_inst_onehot[9];
    wire w_inst_load  = i_inst_onehot[10];
    wire w_inst_store = i_inst_onehot[11];
    wire w_inst_blt   = i_inst_onehot[12];
    wire w_inst_bz    = i_inst_onehot[13];
    wire w_inst_jal   = i_inst_onehot[14];
    wire w_inst_jalr  = i_inst_onehot[15];

    // --- レジスタファイル書き込み有効化 ---
    // store, blt, bz 以外の命令はレジスタに結果を書き込む
    assign o_reg_file_wen = w_inst_add | w_inst_sub | w_inst_and | w_inst_or |
                            w_inst_xor | w_inst_not | w_inst_sra | w_inst_sla |
                            w_inst_addi | w_inst_loadi | w_inst_load |
                            w_inst_jal | w_inst_jalr;

    // --- ALU演算選択 (ALU Op) ---
    // ISAのOpcode 0-7をそのままALU制御に使用し、
    // 即値演算やメモリアドレス計算(load/store/jalr)では加算(0000)を選択する
    assign o_alu_op[0] = w_inst_sub | w_inst_or | w_inst_not | w_inst_sla;
    assign o_alu_op[1] = w_inst_and | w_inst_or | w_inst_sra | w_inst_sla;
    assign o_alu_op[2] = w_inst_xor | w_inst_not | w_inst_sra | w_inst_sla;
    assign o_alu_op[3] = 1'b0; // 現在の命令セットではbit3は常に0 (addi含む)

    // --- ALU入力B選択 ---
    // rs2を使用するか、命令内の即値(imm)を使用するかを選択
    assign o_alu_src_b_sel = w_inst_addi | w_inst_loadi | w_inst_load | w_inst_store | w_inst_jalr;

    // --- データメモリ書き込み有効化 ---
    assign o_dmem_wen = w_inst_store;

    // --- レジスタ書き戻し選択 (Write Back) ---
    // 00: ALU結果, 01: メモリ読出値, 10: PC+2 (リンク用)
    assign o_reg_wb_sel[0] = w_inst_load;
    assign o_reg_wb_sel[1] = w_inst_jal | w_inst_jalr;

    // --- 次のPCアドレス選択 ---
    // 00: PC+2, 01: PC+imm, 10: rs1+imm
    wire w_branch_taken;
    assign w_branch_taken = (w_inst_bz  & i_flag_z) | 
                            (w_inst_blt & (i_flag_n ^ i_flag_v));

    assign o_pc_sel[0] = w_inst_jal | w_branch_taken;
    assign o_pc_sel[1] = w_inst_jalr;

endmodule