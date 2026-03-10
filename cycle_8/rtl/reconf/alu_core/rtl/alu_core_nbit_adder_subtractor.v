module alu_core_nbit_adder_subtractor (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_sub_en, // 0: 加算, 1: 減算
    output wire [15:0] o_sum,
    output wire        o_v       // オーバーフローフラグ
);

    wire [16:0] w_carry;
    wire [15:0] w_b_mod;

    // 減算時はBを反転し、キャリーイン(w_carry[0])を1にすることで2の補数とする
    assign w_carry[0] = i_sub_en;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder_array
            // 減算有効時は入力Bを反転させるゲート
            assign w_b_mod[i] = i_b[i] ^ i_sub_en;

            // 1bit全加算器のインスタンス化
            alu_core_1bit_full_adder u_full_adder (
                .i_a    (i_a[i]),
                .i_b    (w_b_mod[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    // オーバーフロー判定
    // 符号付き演算において、MSBへのキャリーとMSBからのキャリーが異なる場合に発生
    assign o_v = w_carry[15] ^ w_carry[16];

endmodule