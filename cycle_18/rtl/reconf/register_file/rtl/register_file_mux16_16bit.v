module register_file_mux16_16bit (
    input wire [255:0] i_data_all,
    input wire [3:0]   i_sel,
    output wire [15:0] o_data
);

    genvar i, j;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_16bit
            wire [15:0] w_bits_from_regs;

            for (j = 0; j < 16; j = j + 1) begin : gen_collect_bits
                assign w_bits_from_regs[j] = i_data_all[j*16 + i];
            end

            register_file_mux16_1bit u_mux_bit (
                .i_data (w_bits_from_regs),
                .i_sel  (i_sel),
                .o_q    (o_data[i])
            );
        end
    endgenerate

endmodule