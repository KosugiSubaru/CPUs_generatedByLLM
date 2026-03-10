module next_pc_logic_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_sum
);

    wire [16:0] w_carry;

    // 初段のキャリー入力は0に固定（PC+2やPC+immの計算用）
    assign w_carry[0] = 1'b0;

    // generate文を用いて1ビット全加算器を16個直列にインスタンス化
    // 論理合成後の回路図において、リプルキャリー加算器の構造を視覚化する
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_full_adders
            next_pc_logic_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

endmodule