module alu_logic_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [2:0]  i_op,
    output wire [15:0] o_res
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_logic_bits
            alu_logic_1bit u_alu_logic_1bit (
                .i_a   (i_a[i]),
                .i_b   (i_b[i]),
                .i_op  (i_op),
                .o_res (o_res[i])
            );
        end
    endgenerate

endmodule