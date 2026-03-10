module control_unit_data_decoder (
    input  wire [15:0] i_inst_onehot,
    output wire        o_reg_wen,      // レジスタ書き込み有効
    output wire        o_dmem_wen,     // データメモリ書き込み有効
    output wire [1:0]  o_reg_src_sel,  // レジスタ戻り値 (0:ALU, 1:Mem, 2:Imm, 3:PC+2)
    output wire        o_alu_src_sel   // ALU入力B選択 (0:rs2, 1:imm)
);

    // 命令ごとの個別ワイヤ (視覚的デバッグ用)
    wire w_add   = i_inst_onehot[0];
    wire w_sub   = i_inst_onehot[1];
    wire w_and   = i_inst_onehot[2];
    wire w_or    = i_inst_onehot[3];
    wire w_xor   = i_inst_onehot[4];
    wire w_not   = i_inst_onehot[5];
    wire w_sra   = i_inst_onehot[6];
    wire w_sla   = i_inst_onehot[7];
    wire w_addi  = i_inst_onehot[8];
    wire w_loadi = i_inst_onehot[9];
    wire w_load  = i_inst_onehot[10];
    wire w_store = i_inst_onehot[11];
    wire w_blt   = i_inst_onehot[12];
    wire w_bz    = i_inst_onehot[13];
    wire w_jal   = i_inst_onehot[14];
    wire w_jalr  = i_inst_onehot[15];

    // レジスタ書き込み有効命令の論理和
    assign o_reg_wen = w_add | w_sub | w_and | w_or | w_xor | w_not | 
                       w_sra | w_sla | w_addi | w_loadi | w_load | w_jal | w_jalr;

    // データメモリ書き込み有効命令
    assign o_dmem_wen = w_store;

    // ALU入力Bに即値を選択する命令 (addi, load, store, jalr)
    assign o_alu_src_sel = w_addi | w_load | w_store | w_jalr;

    // レジスタ書き戻しデータのソース選択
    // 00: ALU結果
    // 01: データメモリ (load)
    // 10: 即値 (loadi)
    // 11: PC+2 (jal, jalr)
    assign o_reg_src_sel[0] = w_load  | w_jal | w_jalr;
    assign o_reg_src_sel[1] = w_loadi | w_jal | w_jalr;

endmodule