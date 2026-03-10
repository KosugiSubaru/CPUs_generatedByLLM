module pc_adder (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_sum
);

    pc_adder_16bit u_pc_adder_16bit (
        .i_a   (i_a),
        .i_b   (i_b),
        .o_sum (o_sum)
    );

endmodule