module pc_unit_reg_16bit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_data,
    output wire [15:0] o_pc
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : reg_bit
            pc_unit_reg_1bit u_pc_reg_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_data[i]),
                .o_q     (o_pc[i])
            );
        end
    endgenerate

endmodule