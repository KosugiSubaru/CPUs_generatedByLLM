module alu_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_is_sub,
    output wire [15:0] o_sum,
    output wire        o_v
);

    wire [15:0] w_b_mod;
    wire [16:0] w_carry;

    // 減算時はBのビットを反転させる (2の補数計算のため、キャリーインに1を加える)
    assign w_b_mod = i_b ^ {16{i_is_sub}};
    assign w_carry[0] = i_is_sub;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_adder_bits
            alu_full_adder u_alu_full_adder (
                .i_a     (i_a[i]),
                .i_b     (w_b_mod[i]),
                .i_cin   (w_carry[i]),
                .o_sum   (o_sum[i]),
                .o_cout  (w_carry[i+1])
            );
        end
    endgenerate

    // 符号付きオーバーフローフラグ: 最上位ビットのキャリー入力とキャリー出力の異同を確認
    assign o_v = w_carry[16] ^ w_carry[15];

endmodule