module alu_unit_flags (
    input  wire [15:0] i_rd,
    input  wire [15:0] i_rs1,
    input  wire [15:0] i_rs2,
    input  wire        i_is_sub,
    output wire        o_f_z,
    output wire        o_f_n,
    output wire        o_f_v
);

    wire w_v_add;
    wire w_v_sub;

    // Z (Zero) flag: 演算結果が0の時にHigh
    assign o_f_z = (i_rd == 16'h0000);

    // N (Negative) flag: 演算結果の最上位ビット（符号ビット）を反映
    assign o_f_n = i_rd[15];

    // V (Overflow) flag: 符号付き加減算における溢れの判定
    // 加算時：同じ符号の入力を足して、異なる符号の結果が出た場合にオーバーフロー
    assign w_v_add = (i_rs1[15] == 1'b1 && i_rs2[15] == 1'b1 && i_rd[15] == 1'b0) ||
                     (i_rs1[15] == 1'b0 && i_rs2[15] == 1'b0 && i_rd[15] == 1'b1);

    // 減算時：異なる符号の入力を引いて、rs1と異なる符号の結果が出た場合にオーバーフロー
    assign w_v_sub = (i_rs1[15] == 1'b0 && i_rs2[15] == 1'b1 && i_rd[15] == 1'b1) ||
                     (i_rs1[15] == 1'b1 && i_rs2[15] == 1'b0 && i_rd[15] == 1'b0);

    // 演算種別（加算か減算か）に応じて適切なフラグを選択
    assign o_f_v = (i_is_sub == 1'b1) ? w_v_sub : w_v_add;

endmodule