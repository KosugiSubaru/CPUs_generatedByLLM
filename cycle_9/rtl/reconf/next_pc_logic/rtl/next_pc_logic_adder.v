module next_pc_logic_adder (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_cin,
    output wire [15:0] o_sum,
    output wire        o_cout
);

    wire [16:0] w_c;
    genvar i;

    assign w_c[0] = i_cin;
    assign o_cout = w_c[16];

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_fa
            next_pc_logic_fa u_next_pc_logic_fa (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (w_c[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_c[i+1])
            );
        end
    endgenerate

endmodule