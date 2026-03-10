module alu_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_sub,
    output wire [15:0] o_sum,
    output wire        o_cout
);

    wire [16:0] w_carry;
    wire [15:0] w_b_mod;

    // 減算時はBを反転し、最下位のキャリーインを1にすることで2の補数演算を実現
    assign w_carry[0] = i_sub;
    assign o_cout     = w_carry[16];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_fa
            assign w_b_mod[i] = i_b[i] ^ i_sub;
            alu_full_adder u_full_adder (
                .i_a    (i_a[i]),
                .i_b    (w_b_mod[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

endmodule