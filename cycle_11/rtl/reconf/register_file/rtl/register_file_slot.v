module register_file_slot (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_we,
    input  wire [15:0] i_data,
    output wire [15:0] o_data
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_bit_cells
            register_file_bit_cell u_bit_cell (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_we    (i_we),
                .i_d     (i_data[i]),
                .o_q     (o_data[i])
            );
        end
    endgenerate

endmodule