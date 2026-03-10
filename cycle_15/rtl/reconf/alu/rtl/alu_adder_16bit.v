module alu_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_cin,
    output wire [15:0] o_sum,
    output wire        o_cout
);

    wire [16:0] w_carry;

    assign w_carry[0] = i_cin;

    // generate文を用いて1ビット全加算器を16個直列にインスタンス化
    // これにより、論理合成後の回路図においてリプルキャリー加算器の構造が視覚化される
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_full_adders
            alu_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    assign o_cout = w_carry[16];

endmodule