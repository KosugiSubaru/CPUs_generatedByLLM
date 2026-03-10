module alu_adder_nbit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_cin,
    output wire [15:0] o_sum
);

    // ビット間のキャリー（桁上げ）を接続するためのワイヤ
    wire [16:0] w_carry;
    genvar i;

    // 初段のキャリー入力
    assign w_carry[0] = i_cin;

    // 1ビット全加算器を16個並べて接続するパターン構造
    // 論理合成後の回路図で、キャリーが下位から上位へ伝播する様子を視覚化する
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder
            alu_adder_1bit u_adder_bit (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

endmodule