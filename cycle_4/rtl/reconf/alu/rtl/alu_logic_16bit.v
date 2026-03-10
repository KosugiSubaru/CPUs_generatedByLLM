module alu_logic_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [3:0]  i_op,
    output wire [15:0] o_out
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_logic
            alu_logic_cell u_logic_cell (
                .i_op  (i_op),
                .i_a   (i_a[i]),
                .i_b   (i_b[i]),
                .o_out (o_out[i])
            );
        end
    endgenerate

endmodule