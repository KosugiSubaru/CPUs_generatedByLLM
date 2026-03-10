module instruction_decoder_signal_merger (
    input  wire [15:0] i_inst_en,      // 16種類の命令有効フラグ (One-Hot)
    input  wire        i_flag_z,       // 前命令のZeroフラグ
    input  wire        i_flag_n,       // 前命令のNegativeフラグ
    input  wire        i_flag_v,       // 前命令のOverflowフラグ
    output wire        o_reg_wen,      // レジスタファイル書き込み有効
    output wire        o_dmem_wen,     // データメモリ書き込み有効
    output wire [3:0]  o_alu_op,       // ALU演算選択
    output wire        o_alu_src_b_sel, // ALU入力B選択 (0:rs2, 1:imm)
    output wire [1:0]  o_reg_wdata_sel, // レジスタ書き込みデータ選択 (0:ALU, 1:Mem, 2:PC+2)
    output wire [1:0]  o_pc_sel         // 次PC選択 (0:PC+2, 1:PC+Imm, 2:rs1+Imm)
);

    // 分岐条件判定
    wire w_blt_taken;
    wire w_bz_taken;
    wire w_branch_taken;

    assign w_blt_taken    = i_inst_en[12] & (i_flag_n ^ i_flag_v); // BLT: N^V
    assign w_bz_taken     = i_inst_en[13] & i_flag_z;              // BZ: Z
    assign w_branch_taken = w_blt_taken | w_bz_taken;

    // レジスタ書き込み有効命令の集約 (store, blt, bz 以外)
    assign o_reg_wen = i_inst_en[0] | i_inst_en[1] | i_inst_en[2] | i_inst_en[3] | 
                       i_inst_en[4] | i_inst_en[5] | i_inst_en[6] | i_inst_en[7] | 
                       i_inst_en[8] | i_inst_en[9] | i_inst_en[10] | i_inst_en[14] | 
                       i_inst_en[15];

    // データメモリ書き込み有効命令の集約 (store)
    assign o_dmem_wen = i_inst_en[11];

    // ALU演算選択 (命令の下位4bit = opcodeインデックスをそのまま使用)
    assign o_alu_op = (i_inst_en[0]) ? 4'h0 : (i_inst_en[1]) ? 4'h1 :
                      (i_inst_en[2]) ? 4'h2 : (i_inst_en[3]) ? 4'h3 :
                      (i_inst_en[4]) ? 4'h4 : (i_inst_en[5]) ? 4'h5 :
                      (i_inst_en[6]) ? 4'h6 : (i_inst_en[7]) ? 4'h7 :
                      (i_inst_en[8]) ? 4'h8 : (i_inst_en[9]) ? 4'h9 :
                      (i_inst_en[10])? 4'h8 : (i_inst_en[11])? 4'h8 : 4'h0;

    // ALU入力B選択 (addi, load, store, loadi の場合に即値を選択)
    assign o_alu_src_b_sel = i_inst_en[8] | i_inst_en[9] | i_inst_en[10] | i_inst_en[11];

    // レジスタ書き戻しデータ選択
    // 0:ALU (演算系), 1:Mem (load), 2:PC+2 (jal, jalr)
    assign o_reg_wdata_sel[0] = i_inst_en[10];
    assign o_reg_wdata_sel[1] = i_inst_en[14] | i_inst_en[15];

    // 次PC選択
    // 0:PC+2, 1:PC+Imm (Branch Taken / JAL), 2:rs1+Imm (JALR)
    assign o_pc_sel[0] = w_branch_taken | i_inst_en[14];
    assign o_pc_sel[1] = i_inst_en[15];

endmodule