module alu_flag_logic (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [3:0]  i_opcode,
    input  wire [15:0] i_result,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    wire w_v_add;
    wire w_v_sub;
    wire w_is_sub;

    // Zeroフラグ: 全ビットが0であることを判定
    assign o_flag_z = (i_result == 16'h0000);

    // Negativeフラグ: 結果の最上位ビット(符号ビット)を抽出
    assign o_flag_n = i_result[15];

    // Overflowフラグ (加算用): ISA定義の論理式を実装
    // (rs1[15]==1) & (rs2[15]==1) & (rd[15]==0) | (rs1[15]==0) & (rs2[15]==0) & (rd[15]==1)
    assign w_v_add = (i_a[15] & i_b[15] & ~i_result[15]) | (~i_a[15] & ~i_b[15] & i_result[15]);

    // Overflowフラグ (減算用): ISA定義の論理式を実装
    // (rs1[15]==0) & (rs2[15]==1) & (rd[15]==1) | (rs1[15]==1) & (rs2[15]==0) & (rd[15]==0)
    assign w_v_sub = (~i_a[15] & i_b[15] & i_result[15]) | (i_a[15] & ~i_b[15] & ~i_result[15]);

    // Opcodeがsub(0001)のときのみ減算用Vフラグを選択、それ以外は加算系として扱う
    assign w_is_sub = (i_opcode == 4'b0001);
    assign o_flag_v = (w_is_sub) ? w_v_sub : w_v_add;

endmodule