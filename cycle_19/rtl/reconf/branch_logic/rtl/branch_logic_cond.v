module branch_logic_cond (
    input  wire [3:0] i_opcode, // 命令オペコード
    input  wire       i_flag_z, // 前クロックのゼロフラグ
    input  wire       i_flag_n, // 前クロックのネガティブフラグ
    input  wire       i_flag_v, // 前クロックのオーバーフローフラグ
    output wire       o_cond_met // 分岐条件成立信号
);

    // ISA定義に基づく条件判定論理
    // 1100: blt -> N ^ V (符号付き比較 rs1 < rs2)
    // 1101: bz  -> Z     (rs1 == 0)
    assign o_cond_met = (i_opcode == 4'b1100) ? (i_flag_n ^ i_flag_v) :
                       (i_opcode == 4'b1101) ? (i_flag_z)             :
                       1'b0;

endmodule