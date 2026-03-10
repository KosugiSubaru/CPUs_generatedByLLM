module program_counter_adder_nbit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_sum
);

    wire [16:0] w_carry;
    genvar i;

    // キャリーの初期値（加算器の最下位ビットへの入力）
    assign w_carry[0] = 1'b0;

    // 1ビット全加算器を16個並列に配置し、Ripple Carry Adderを構成
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder
            program_counter_adder_1bit u_adder_bit (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

endmodule