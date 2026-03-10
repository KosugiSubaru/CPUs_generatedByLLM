module ctrl_unit_mixer (
    input  wire [15:0] i_active,       // デコーダからの命令有効信号 (One-Hot)
    output wire       o_reg_wen,      // レジスタファイル書き込み有効
    output wire       o_dmem_wen,     // データメモリ書き込み有効
    output wire       o_alu_src_sel,  // ALU入力B選択 (0: rs2, 1: imm)
    output wire [1:0] o_reg_wd_sel,   // レジスタ書き戻し選択 (0: ALU, 1: Mem, 2: PC+2)
    output wire [3:0] o_alu_op        // ALU内部での演算種別
);

    // ---- レジスタファイルへの書き込み有効信号 ----
    // add, sub, and, or, xor, not, sra, sla, addi, loadi, load, jal, jalr で有効
    assign o_reg_wen = i_active[0] | i_active[1] | i_active[2] | i_active[3] |
                       i_active[4] | i_active[5] | i_active[6] | i_active[7] |
                       i_active[8] | i_active[9] | i_active[10] | i_active[14] | i_active[15];

    // ---- データメモリへの書き込み有効信号 ----
    // store命令のみ有効
    assign o_dmem_wen = i_active[11];

    // ---- ALUの第2入力(B)選択信号 ----
    // 0: rs2, 1: imm (addi, load, store, jalr, loadi)
    assign o_alu_src_sel = i_active[8] | i_active[9] | i_active[10] | i_active[11] | i_active[15];

    // ---- レジスタに書き戻すデータの選択信号 ----
    // 00: ALU結果, 01: メモリデータ(load), 10: 戻り先アドレス(jal, jalr)
    assign o_reg_wd_sel[0] = i_active[10];
    assign o_reg_wd_sel[1] = i_active[14] | i_active[15];

    // ---- ALU演算種別のマッピング ----
    // 算術命令以外(load, store, jalr)はアドレス計算のため加算(0000)を選択
    assign o_alu_op = (i_active[0] | i_active[8] | i_active[10] | i_active[11] | i_active[15]) ? 4'b0000 : // Add logic
                      (i_active[1]) ? 4'b0001 : // Sub
                      (i_active[2]) ? 4'b0010 : // And
                      (i_active[3]) ? 4'b0011 : // Or
                      (i_active[4]) ? 4'b0100 : // Xor
                      (i_active[5]) ? 4'b0101 : // Not
                      (i_active[6]) ? 4'b0110 : // SRA
                      (i_active[7]) ? 4'b0111 : // SLA
                      (i_active[9]) ? 4'b1001 : // LoadImm pass-through
                      4'b0000;

endmodule