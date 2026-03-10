module next_pc_logic_branch_eval (
    input  wire [3:0] i_opcode, // 命令の下位4ビット(Opcode)
    input  wire       i_flag_z, // Flag RegisterからのZフラグ
    input  wire       i_flag_n, // Flag RegisterからのNフラグ
    input  wire       i_flag_v, // Flag RegisterからのVフラグ
    output wire       o_taken   // 分岐成立信号
);

    wire w_is_blt;
    wire w_is_bz;
    wire w_cond_blt;
    wire w_cond_bz;

    // 命令種別の判定 (ISA定義に基づくOpcodeの特定)
    assign w_is_blt = (i_opcode == 4'b1100); // branch less than
    assign w_is_bz  = (i_opcode == 4'b1101); // branch zero

    // 分岐条件の評価ロジック (ISA定義のbehaviorに基づく)
    // N ^ V: 符号付き比較における "Less Than" の条件
    assign w_cond_blt = i_flag_n ^ i_flag_v;
    // Z: ゼロ判定の条件
    assign w_cond_bz  = i_flag_z;

    // 命令が分岐命令であり、かつ条件を満たしている場合に分岐成立(Taken)とする
    // 論理合成後の回路図で、各条件判定(XOR等)と命令選択のANDゲートが視覚化される
    assign o_taken = (w_is_blt & w_cond_blt) | 
                     (w_is_bz  & w_cond_bz);

endmodule