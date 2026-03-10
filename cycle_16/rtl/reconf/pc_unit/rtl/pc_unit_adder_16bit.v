module pc_unit_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_sum
);

    wire [16:0] w_carry;

    assign w_carry[0] = 1'b0;

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : adder_bit
            pc_unit_full_adder u_pc_full_adder (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

endmodule