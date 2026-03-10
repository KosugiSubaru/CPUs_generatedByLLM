module instruction_decoder_control_logic (
    input  wire [15:0] i_matches,
    output wire        o_reg_write,
    output wire        o_mem_write,
    output wire        o_mem_read,
    output wire        o_alu_src_b,
    output wire [3:0]  o_alu_op,
    output wire [1:0]  o_reg_src,
    output wire        o_pc_target_src,
    output wire        o_jump_uncond,
    output wire        o_branch_bz,
    output wire        o_branch_blt,
    output wire        o_flag_we
);

    // 1. レジスタ書き込み許可 (ALU系, addi, loadi, load, jal, jalr)
    assign o_reg_write = i_matches[0] | i_matches[1] | i_matches[2] | i_matches[3] |
                         i_matches[4] | i_matches[5] | i_matches[6] | i_matches[7] |
                         i_matches[8] | i_matches[9] | i_matches[10] |
                         i_matches[14] | i_matches[15];

    // 2. メモリ操作
    assign o_mem_write = i_matches[11]; // store
    assign o_mem_read  = i_matches[10]; // load

    // 3. ALU入力B選択 (0: rs2_data, 1: imm)
    assign o_alu_src_b = i_matches[8] | i_matches[10] | i_matches[11] | i_matches[15];

    // 4. ALU演算コード
    // ALU命令(0-8)はそのまま、メモリ/ジャンプ(10,11,15)は加算(0)
    assign o_alu_op = (i_matches[0] | i_matches[8] | i_matches[10] | i_matches[11] | i_matches[15]) ? 4'b0000 :
                      (i_matches[1]) ? 4'b0001 :
                      (i_matches[2]) ? 4'b0010 :
                      (i_matches[3]) ? 4'b0011 :
                      (i_matches[4]) ? 4'b0100 :
                      (i_matches[5]) ? 4'b0101 :
                      (i_matches[6]) ? 4'b0110 :
                      (i_matches[7]) ? 4'b0111 : 4'b0000;

    // 5. レジスタ書き込みデータ選択 (00: ALU結果, 01: メモリ, 10: PC+2, 11: 即値)
    assign o_reg_src[0] = i_matches[10] | i_matches[9];
    assign o_reg_src[1] = i_matches[14] | i_matches[15] | i_matches[9];

    // 6. PC制御
    assign o_pc_target_src = i_matches[15]; // jalrのみrs1ベース
    assign o_jump_uncond   = i_matches[14] | i_matches[15]; // jal, jalr
    assign o_branch_bz     = i_matches[13];
    assign o_branch_blt    = i_matches[12];

    // 7. フラグレジスタ更新許可 (ALU R-type命令のみ)
    assign o_flag_we = i_matches[0] | i_matches[1] | i_matches[2] | i_matches[3] |
                       i_matches[4] | i_matches[5] | i_matches[6] | i_matches[7];

endmodule