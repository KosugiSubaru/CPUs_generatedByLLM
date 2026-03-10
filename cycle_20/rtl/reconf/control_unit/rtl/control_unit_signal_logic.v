module control_unit_signal_logic (
    input  wire [15:0] i_instr_decoded,
    input  wire        i_flag_z,
    input  wire        i_flag_n,
    input  wire        i_flag_v,

    output wire        o_reg_file_wen,
    output wire [3:0]  o_alu_op,
    output wire        o_alu_src_sel,
    output wire        o_dmem_wen,
    output wire        o_mem_to_reg,
    output wire        o_pc_src_sel,
    output wire        o_pc_base_sel,
    output wire        o_reg_data_sel
);

    // レジスタファイルへの書き込み許可
    // R-type, addi, loadi, load, jal, jalr で有効
    assign o_reg_file_wen = i_instr_decoded[0]  | i_instr_decoded[1]  | i_instr_decoded[2]  |
                            i_instr_decoded[3]  | i_instr_decoded[4]  | i_instr_decoded[5]  |
                            i_instr_decoded[6]  | i_instr_decoded[7]  | i_instr_decoded[8]  |
                            i_instr_decoded[9]  | i_instr_decoded[10] | i_instr_decoded[14] |
                            i_instr_decoded[15];

    // ALU演算選択信号 (i_instr_decoded[8]がaddiに対応)
    assign o_alu_op[0] = i_instr_decoded[1] | i_instr_decoded[3] | i_instr_decoded[5] | i_instr_decoded[7];
    assign o_alu_op[1] = i_instr_decoded[2] | i_instr_decoded[3] | i_instr_decoded[6] | i_instr_decoded[7];
    assign o_alu_op[2] = i_instr_decoded[4] | i_instr_decoded[5] | i_instr_decoded[6] | i_instr_decoded[7];
    assign o_alu_op[3] = i_instr_decoded[8];

    // ALU入力B選択 (0:rs2, 1:imm)
    // addi, loadi, load, store, jalr でimmを選択
    assign o_alu_src_sel = i_instr_decoded[8] | i_instr_decoded[9] | i_instr_decoded[10] | 
                           i_instr_decoded[11] | i_instr_decoded[15];

    // データメモリ書き込み許可
    // store命令のみ有効
    assign o_dmem_wen = i_instr_decoded[11];

    // レジスタへの書き戻しソース選択 (0:ALU, 1:Mem)
    // load命令のみMemを選択
    assign o_mem_to_reg = i_instr_decoded[10];

    // PC選択信号 (0:PC+2, 1:Target)
    // ジャンプ(jal, jalr)または分岐条件成立時にTargetを選択
    assign o_pc_src_sel = i_instr_decoded[14] | i_instr_decoded[15] | 
                          (i_instr_decoded[12] & (i_flag_n ^ i_flag_v)) | 
                          (i_instr_decoded[13] & i_flag_z);

    // PC計算ベース選択 (0:PC, 1:rs1)
    // jalr命令のみrs1ベース
    assign o_pc_base_sel = i_instr_decoded[15];

    // 書き込みデータ最終選択 (0:ALU/Mem, 1:PC+2)
    // jal, jalr (Link) 命令の時にPC+2をrdに書き込む
    assign o_reg_data_sel = i_instr_decoded[14] | i_instr_decoded[15];

endmodule