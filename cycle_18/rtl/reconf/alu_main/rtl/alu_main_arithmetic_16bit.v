module alu_main_arithmetic_16bit (
    input wire [15:0] i_a,
    input wire [15:0] i_b,
    input wire        i_sub_en,
    output wire [15:0] o_sum,
    output wire        o_cout
);

    wire [15:0] w_b_mod;
    wire [16:0] w_carry;

    assign w_carry[0] = i_sub_en;
    assign o_cout = w_carry[16];

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_arith_slice
            // 減算時はBのビットを反転（1の補数）、cin=1で2の補数加算を実現
            assign w_b_mod[i] = i_b[i] ^ i_sub_en;

            alu_main_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (w_b_mod[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

endmodule