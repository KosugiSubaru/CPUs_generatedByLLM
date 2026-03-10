module mem_ctrl_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_sum
);

    wire [16:0] w_carry;

    // 加算器のキャリー入力を0に固定
    assign w_carry[0] = 1'b0;

    // パタン構造化：16個のフルアダーを連結してリップルキャリー加算器を構成
    // 回路図上でメモリの実効アドレスを計算する構造を視覚化する
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : ripple_carry_logic
            mem_ctrl_full_adder u_full_adder (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

endmodule