module alu_mux_out_16bit (
    input  wire [3:0]  i_sel,
    input  wire [15:0] i_adder,
    input  wire [15:0] i_logic,
    input  wire [15:0] i_shifter,
    input  wire [15:0] i_pass_b,
    output wire [15:0] o_res
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_mux_bits
            // 1ビット単位のセレクタを16個展開し、ビットスライス構造を視覚化
            alu_mux_out_1bit u_alu_mux_out_1bit (
                .i_sel     (i_sel),
                .i_adder   (i_adder[i]),
                .i_logic   (i_logic[i]),
                .i_shifter (i_shifter[i]),
                .i_pass_b  (i_pass_b[i]),
                .o_res     (o_res[i])
            );
        end
    endgenerate

endmodule