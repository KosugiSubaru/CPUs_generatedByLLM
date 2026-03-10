module alu_main_logical_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_q
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_logic_slices
            alu_main_logic_slice u_slice (
                .i_sel (i_sel),
                .i_a   (i_a[i]),
                .i_b   (i_b[i]),
                .o_q   (o_q[i])
            );
        end
    endgenerate

endmodule