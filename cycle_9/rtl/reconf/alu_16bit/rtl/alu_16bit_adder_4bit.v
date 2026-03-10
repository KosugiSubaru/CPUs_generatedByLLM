module alu_16bit_adder_4bit (
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire       i_cin,
    output wire [3:0] o_sum,
    output wire       o_cout
);

    wire [4:0] w_c;
    genvar i;

    assign w_c[0] = i_cin;
    assign o_cout = w_c[4];

    generate
        for (i = 0; i < 4; i = i + 1) begin : fa_gen
            alu_16bit_fa u_alu_16bit_fa (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (w_c[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_c[i+1])
            );
        end
    endgenerate

endmodule