module alu_adder_subtractor_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_is_sub,
    output wire [15:0] o_sum,
    output wire        o_v
);

    // 内部ワイヤ定義
    wire [15:0] w_b_mod;
    wire [16:0] w_carry;

    // 減算時はBのビットを反転させる (A - B = A + (~B) + 1)
    // XORを用いて i_is_sub が 1 のときのみ反転を実現
    assign w_b_mod = i_b ^ {16{i_is_sub}};
    
    // 初期のキャリー入力は i_is_sub (減算時の +1 に対応)
    assign w_carry[0] = i_is_sub;

    // 1ビット全加算器を16個並列化（リップルキャリー方式）
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder_bits
            alu_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (w_b_mod[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    // 符号付きオーバーフロー(V)の生成
    // 加算: (A[15]==B[15]) かつ (結果[15]!=A[15]) の時に発生
    // 減算: (A[15]!=B[15]) かつ (結果[15]!=A[15]) の時に発生
    assign o_v = (!i_is_sub) ? 
                 ((i_a[15] == i_b[15])   && (o_sum[15] != i_a[15])) : // addition
                 ((i_a[15] != i_b[15])   && (o_sum[15] != i_a[15]));  // subtraction

endmodule