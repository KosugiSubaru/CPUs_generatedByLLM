module alu_unit_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_sub_en, // 1なら減算(A-B)、0なら加算(A+B)
    output wire [15:0] o_sum,
    output wire        o_cout
);

    wire [16:0] w_carry;
    wire [15:0] w_b_inv;

    // 減算時はBを反転し、最下位キャリーインを1にすることで2の補数を作る
    assign w_carry[0] = i_sub_en;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder
            // XORを用いてi_sub_enが1の時だけビット反転
            assign w_b_inv[i] = i_b[i] ^ i_sub_en;

            alu_unit_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (w_b_inv[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    assign o_cout = w_carry[16];

endmodule