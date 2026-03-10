module alu_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_is_sub,
    output wire [15:0] o_sum,
    output wire        o_cout
);

    wire [15:0] w_carry;
    wire [15:0] w_b_mod;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_alu_adder
            // 減算時は入力を反転 (XORによる1の補数生成)
            assign w_b_mod[i] = i_b[i] ^ i_is_sub;

            if (i == 0) begin
                // LSB: 減算時は i_is_sub(1) をキャリーインとすることで2の補数を完成させる
                alu_full_adder u_fa (
                    .i_a    (i_a[i]),
                    .i_b    (w_b_mod[i]),
                    .i_cin  (i_is_sub),
                    .o_sum  (o_sum[i]),
                    .o_cout (w_carry[i])
                );
            end else begin
                alu_full_adder u_fa (
                    .i_a    (i_a[i]),
                    .i_b    (w_b_mod[i]),
                    .i_cin  (w_carry[i-1]),
                    .o_sum  (o_sum[i]),
                    .o_cout (w_carry[i])
                );
            end
        end
    endgenerate

    assign o_cout = w_carry[15];

endmodule