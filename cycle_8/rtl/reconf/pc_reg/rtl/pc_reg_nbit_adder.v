module pc_reg_nbit_adder (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_cin,
    output wire [15:0] o_sum,
    output wire        o_cout
);

    wire [16:0] w_carry;

    assign w_carry[0] = i_cin;
    assign o_cout     = w_carry[16];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_full_adder_array
            pc_reg_1bit_full_adder u_pc_reg_1bit_full_adder (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

endmodule