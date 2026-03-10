module alu_core_logic_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [1:0]  i_sel,
    output wire [15:0] o_res
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_logic_slices
            alu_core_logic_slice u_slice (
                .i_a   (i_a[i]),
                .i_b   (i_b[i]),
                .i_sel (i_sel),
                .o_res (o_res[i])
            );
        end
    endgenerate

endmodule