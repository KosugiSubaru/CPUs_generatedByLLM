module alu_core_arithmetic_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_is_sub,
    output wire [15:0] o_sum,
    output wire        o_v
);

    wire [15:0] w_b_mod;
    wire [16:0] w_carry;

    assign w_carry[0] = i_is_sub;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_ripple_carry_adder
            assign w_b_mod[i] = i_b[i] ^ i_is_sub;

            alu_core_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (w_b_mod[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    assign o_v = w_carry[16] ^ w_carry[15];

endmodule