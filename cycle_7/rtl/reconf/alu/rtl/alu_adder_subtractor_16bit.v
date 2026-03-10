module alu_adder_subtractor_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_sub_en, // 0: Add, 1: Sub
    output wire [15:0] o_sum,
    output wire        o_cout
);

    wire [16:0] w_carry;
    wire [15:0] w_b_inv;

    // 減算時はBのビットを反転し、最初のキャリーインを1にする(2の補数: ~B + 1)
    assign w_carry[0] = i_sub_en;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder
            // 減算選択信号とのXORによりビット反転を制御
            assign w_b_inv[i] = i_b[i] ^ i_sub_en;

            alu_full_adder u_full_adder (
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