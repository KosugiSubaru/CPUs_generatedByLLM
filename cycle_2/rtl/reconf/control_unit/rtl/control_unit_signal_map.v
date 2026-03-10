module control_unit_signal_map (
    input  wire [15:0] i_inst,        // 1-hot 命令有効信号
    output wire        o_reg_write,
    output wire        o_mem_write,
    output wire        o_alu_src,      // 0: rs2_data, 1: imm
    output wire [1:0]  o_reg_res_sel,  // 0: ALU, 1: Mem, 2: PC+2, 3: Imm
    output wire [3:0]  o_alu_op,
    output wire [2:0]  o_imm_type      // 即値抽出形式
);

    // 各命令グループの定義（1-hot信号の集約）
    wire w_is_rtype;
    wire w_is_branch;
    wire w_is_jump;

    assign w_is_rtype = |i_inst[7:0];   // add, sub, and, or, xor, not, sra, sla
    assign w_is_branch = |i_inst[13:12]; // blt, bz
    assign w_is_jump = |i_inst[15:14];   // jal, jalr

    // 1. レジスタファイルへの書き込み許可
    // R-type, addi, loadi, load, jal, jalr で書き込み
    assign o_reg_write = w_is_rtype | i_inst[8] | i_inst[9] | i_inst[10] | w_is_jump;

    // 2. データメモリへの書き込み許可
    // store命令のみ
    assign o_mem_write = i_inst[11];

    // 3. ALU入力ソース選択
    // 1: 即値(imm) を使う命令 (addi, load, store, jalr)
    assign o_alu_src = i_inst[8] | i_inst[10] | i_inst[11] | i_inst[15];

    // 4. レジスタ書き戻しデータ選択
    // 0(ALU): R-type, addi
    // 1(Mem): load
    // 2(PC+2): jal, jalr
    // 3(Imm): loadi
    assign o_reg_res_sel[0] = i_inst[10] | i_inst[9];
    assign o_reg_res_sel[1] = w_is_jump  | i_inst[9];

    // 5. ALU演算指定
    // R-typeはそのopcodeをそのまま使用。I-type(load/store/addi)は加算(0)を指定。
    assign o_alu_op[0] = i_inst[1] | i_inst[3] | i_inst[5] | i_inst[7];
    assign o_alu_op[1] = i_inst[2] | i_inst[3] | i_inst[6] | i_inst[7];
    assign o_alu_op[2] = i_inst[4] | i_inst[5] | i_inst[6] | i_inst[7];
    assign o_alu_op[3] = 1'b0; // 現在のISAでは未使用

    // 6. 即値抽出形式 (Imm Genへの指示)
    // 0: addi, load, jalr [7:4]
    // 1: loadi, jal       [11:4]
    // 2: store            [15:12]
    // 3: blt, bz          [15:4]
    assign o_imm_type[0] = (i_inst[9] | i_inst[14]) | (i_inst[12] | i_inst[13]);
    assign o_imm_type[1] = (i_inst[11])             | (i_inst[12] | i_inst[13]);
    assign o_imm_type[2] = 1'b0; // 拡張用

endmodule