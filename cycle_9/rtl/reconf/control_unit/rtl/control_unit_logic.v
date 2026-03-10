module control_unit_logic (
    input  wire [15:0] i_inst_onehot,
    output wire        o_reg_we,
    output wire        o_mem_we,
    output wire        o_alu_src_sel, // 0:rs2, 1:imm
    output wire [1:0]  o_wb_sel,      // 00:ALU, 01:Mem, 10:Imm, 11:PC+2
    output wire [3:0]  o_alu_op
);

    // レジスタ書き込み許可信号 (Store, Branch以外は基本的に書き込む)
    assign o_reg_we = i_inst_onehot[0]  | i_inst_onehot[1]  | i_inst_onehot[2]  | i_inst_onehot[3]  |
                      i_inst_onehot[4]  | i_inst_onehot[5]  | i_inst_onehot[6]  | i_inst_onehot[7]  |
                      i_inst_onehot[8]  | i_inst_onehot[9]  | i_inst_onehot[10] | i_inst_onehot[14] |
                      i_inst_onehot[15];

    // データメモリ書き込み許可信号 (Store命令のみ)
    assign o_mem_we = i_inst_onehot[11];

    // ALU入力選択信号 (rs2を使用するか、即値を使用するか)
    // addi, load, store は rs1 + imm の計算を行うため即値を選択
    assign o_alu_src_sel = i_inst_onehot[8] | i_inst_onehot[10] | i_inst_onehot[11];

    // レジスタ書き戻しデータ選択信号
    // 00: ALU結果 (R-type, addi)
    // 01: メモリ読み出しデータ (load)
    // 10: 即値データ (loadi)
    // 11: PC+2 (jal, jalr)
    assign o_wb_sel[0] = i_inst_onehot[10] | i_inst_onehot[14] | i_inst_onehot[15];
    assign o_wb_sel[1] = i_inst_onehot[9]  | i_inst_onehot[14] | i_inst_onehot[15];

    // ALU演算モード選択信号
    // R-type(0-7)はopcodeをそのまま使用。addi(8), load(10), store(11)は加算(0000)を指示
    assign o_alu_op[0] = i_inst_onehot[1] | i_inst_onehot[3] | i_inst_onehot[5] | i_inst_onehot[7];
    assign o_alu_op[1] = i_inst_onehot[2] | i_inst_onehot[3] | i_inst_onehot[6] | i_inst_onehot[7];
    assign o_alu_op[2] = i_inst_onehot[4] | i_inst_onehot[5] | i_inst_onehot[6] | i_inst_onehot[7];
    assign o_alu_op[3] = 1'b0; // 現在のISA定義ではMSBは常に0（0000〜0111）

endmodule