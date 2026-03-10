module alu_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_sub,
    output wire [15:0] o_sum,
    output wire        o_cout
);

    wire [15:0] w_b_prep;
    wire [16:0] w_carry;

    // 減算時はBのビットを反転し、最下位へのキャリー(i_sub)で2の補数を作成
    assign w_b_prep = i_b ^ {16{i_sub}};
    assign w_carry[0] = i_sub;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder
            alu_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (w_b_prep[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    assign o_cout = w_carry[16];

endmodule