module program_counter_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_sum
);

    wire [15:0] w_carry;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder_16bit
            if (i == 0) begin
                program_counter_full_adder u_fa (
                    .i_a    (i_a[i]),
                    .i_b    (i_b[i]),
                    .i_cin  (1'b0),
                    .o_sum  (o_sum[i]),
                    .o_cout (w_carry[i])
                );
            end else begin
                program_counter_full_adder u_fa (
                    .i_a    (i_a[i]),
                    .i_b    (i_b[i]),
                    .i_cin  (w_carry[i-1]),
                    .o_sum  (o_sum[i]),
                    .o_cout (w_carry[i])
                );
            end
        end
    endgenerate

endmodule