module register_file_read_selector (
    input  wire [3:0]   i_sel,
    input  wire [255:0] i_data,
    output wire [15:0]  o_data
);

    genvar i, j;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_bit_selectors
            wire [15:0] w_mux_in;
            for (j = 0; j < 16; j = j + 1) begin : gen_collect_bits
                assign w_mux_in[j] = i_data[j*16 + i];
            end

            register_file_mux_16to1_1bit u_mux (
                .i_sel (i_sel),
                .i_d   (w_mux_in),
                .o_y   (o_data[i])
            );
        end
    endgenerate

endmodule