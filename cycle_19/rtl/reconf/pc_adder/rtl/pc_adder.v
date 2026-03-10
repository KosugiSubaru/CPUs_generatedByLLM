module pc_adder (
    input  wire [15:0] i_a,     // 入力A（例：現在のPC）
    input  wire [15:0] i_b,     // 入力B（例：定数2、または即値）
    output wire [15:0] o_sum    // 加算結果（例：次のPC）
);

    // キャリー信号を接続するためのワイヤ（16ビット分 + 入力用）
    wire [16:0] w_carry;
    
    // 初期のキャリー入力は0
    assign w_carry[0] = 1'b0;

    // 繰り返し構文のための変数宣言
    genvar i;

    // 全加算器を16個並列に配置し、キャリーを連鎖させる（Ripple Carry Adder構造）
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_adder_bits
            pc_adder_full u_pc_adder_full (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

endmodule