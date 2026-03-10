module register_file_array (
    input  wire         i_clk,
    input  wire         i_rst_n,
    input  wire [15:0]  i_we_bus,
    input  wire [15:0]  i_data_in,
    output wire [255:0] o_reg_bus
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_reg
            if (i == 0) begin : r0
                register_file_zero u_register_file_zero (
                    .i_clk   (i_clk),
                    .i_rst_n (i_rst_n),
                    .i_we    (i_we_bus[i]),
                    .i_data  (i_data_in),
                    .o_data  (o_reg_bus[i*16 +: 16])
                );
            end else begin : rx
                register_file_cell u_register_file_cell (
                    .i_clk   (i_clk),
                    .i_rst_n (i_rst_n),
                    .i_we    (i_we_bus[i]),
                    .i_data  (i_data_in),
                    .o_data  (o_reg_bus[i*16 +: 16])
                );
            end
        end
    endgenerate

endmodule