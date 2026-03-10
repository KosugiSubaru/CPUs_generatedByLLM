module control_unit_op_matrix (
    input  wire [15:0] i_inst_active,
    output wire        o_reg_write,
    output wire        o_mem_write,
    output wire        o_mem_to_reg,
    output wire        o_alu_src,
    output wire        o_reg_data_sel,
    output wire [3:0]  o_alu_op
);

    // 命令有効信号へのエイリアス（視覚的な対応のため）
    wire w_add   = i_inst_active[0];
    wire w_sub   = i_inst_active[1];
    wire w_and   = i_inst_active[2];
    wire w_or    = i_inst_active[3];
    wire w_xor   = i_inst_active[4];
    wire w_not   = i_inst_active[5];
    wire w_sra   = i_inst_active[6];
    wire w_sla   = i_inst_active[7];
    wire w_addi  = i_inst_active[8];
    wire w_loadi = i_inst_active[9];
    wire w_load  = i_inst_active[10];
    wire w_store = i_inst_active[11];
    wire w_blt   = i_inst_active[12];
    wire w_bz    = i_inst_active[13];
    wire w_jal   = i_inst_active[14];
    wire w_jalr  = i_inst_active[15];

    // レジスタファイルへの書き込み許可
    // store, blt, bz 以外の命令はすべてレジスタに結果を書き込む
    assign o_reg_write = w_add | w_sub | w_and | w_or | w_xor | w_not | 
                         w_sra | w_sla | w_addi | w_loadi | w_load | w_jal | w_jalr;

    // データメモリへの書き込み許可
    assign o_mem_write = w_store;

    // レジスタへの書き戻しソース選択 (1: メモリ出力, 0: ALU出力)
    assign o_mem_to_reg = w_load;

    // ALU入力Bの選択 (1: 即値, 0: レジスタrs2)
    // addi, loadi, load, store 命令で即値を使用
    assign o_alu_src = w_addi | w_loadi | w_load | w_store;

    // レジスタ書き込みデータ全体の選択 (1: PC+2, 0: ALU/Mem結果)
    // jal, jalr 命令で戻り先アドレスを保存
    assign o_reg_data_sel = w_jal | w_jalr;

    // ALU演算種別の生成 (命令のopcodeまたは特定の演算をマッピング)
    // bit 0
    assign o_alu_op[0] = w_sub | w_or | w_not | w_sla | w_loadi;
    // bit 1
    assign o_alu_op[1] = w_and | w_or | w_sra | w_sla;
    // bit 2
    assign o_alu_op[2] = w_xor | w_not | w_sra | w_sla;
    // bit 3
    assign o_alu_op[3] = w_addi | w_loadi; 
    // ※load, store は加算(0000)が必要なため、ALUOpはすべて0となるように設計

endmodule