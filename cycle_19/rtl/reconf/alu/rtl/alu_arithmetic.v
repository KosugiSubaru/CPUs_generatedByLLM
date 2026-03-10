module alu_arithmetic (
    input  wire [15:0] i_a,      // 入力A
    input  wire [15:0] i_b,      // 入力B
    input  wire        i_sub,    // 減算選択フラグ (1: 減算, 0: 加算)
    output wire [15:0] o_res,    // 演算結果
    output wire        o_flag_n, // Negativeフラグ
    output wire        o_flag_v  // Overflowフラグ
);

    // キャリー連鎖およびB入力反転用のワイヤ
    wire [16:0] w_carry;
    wire [15:0] w_b_mod;

    // 減算時はi_sub(1)を初段のキャリーインとし、Bの全ビットを反転（2の補数）
    assign w_carry[0] = i_sub;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_adder_bits
            // 減算時はXORによりビット反転を行う
            assign w_b_mod[i] = i_b[i] ^ i_sub;

            alu_adder_1bit u_adder (
                .i_a    (i_a[i]),
                .i_b    (w_b_mod[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_res[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    // Nフラグ: 結果の最上位ビット（符号ビット）
    assign o_flag_n = o_res[15];

    // Vフラグ: 入力Aと加工後入力Bの符号が等しく、結果の符号がそれらと異なる場合に発生
    assign o_flag_v = (i_a[15] == w_b_mod[15]) && (o_res[15] != i_a[15]);

endmodule