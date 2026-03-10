module next_pc_logic_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_cin,
    output wire [15:0] o_sum,
    output wire        o_cout
);

    // 内部ワイヤ：キャリーチェーン用
    wire [16:0] w_carry;

    // 初段のキャリー入力を接続
    assign w_carry[0] = i_cin;

    // 1ビットフルアダーを16個インスタンス化し、リップルキャリー加算器を構成
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_addr_adder
            next_pc_logic_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    // 最終段のキャリー出力を接続
    assign o_cout = w_carry[16];

endmodule