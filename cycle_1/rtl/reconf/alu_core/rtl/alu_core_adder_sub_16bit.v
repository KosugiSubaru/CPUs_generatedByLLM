module alu_core_adder_sub_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_sub_en, // 0: 加算, 1: 減算
    output wire [15:0] o_sum,
    output wire        o_v_flag  // オーバーフローフラグ
);

    wire [15:0] w_b_inv;
    wire [16:0] w_carry;

    // 減算時はBの各ビットを反転（1の補数）、後のキャリーインで+1して2の補数にする
    assign w_carry[0] = i_sub_en;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder_sub
            assign w_b_inv[i] = i_b[i] ^ i_sub_en;

            alu_core_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (w_b_inv[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    // ISA定義に基づいたオーバーフロー(V)の判定
    // 加算: (A[15]==B[15]) かつ 結果の符号が異なる場合
    // 減算: (A[15]!=B[15]) かつ 結果の符号がAと異なる場合
    assign o_v_flag = (!i_sub_en) ? 
                      ((i_a[15] == i_b[15]) && (o_sum[15] != i_a[15])) : 
                      ((i_a[15] != i_b[15]) && (o_sum[15] != i_a[15]));

endmodule