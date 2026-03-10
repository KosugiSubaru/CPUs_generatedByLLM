module pc_reg (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_next_pc,
    output wire [15:0] o_now_pc
);

    genvar j;

    generate
        for (j = 0; j < 4; j = j + 1) begin : nibble_slice
            pc_reg_4bit u_pc_reg_4bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_next_pc[j*4 +: 4]),
                .o_q     (o_now_pc [j*4 +: 4])
            );
        end
    endgenerate

endmodule