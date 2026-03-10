module register_file_decoder_4to16 (
    input  wire [3:0]  i_addr,
    output wire [15:0] o_decode
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_decode_lines
            assign o_decode[i] = (i_addr == i[3:0]);
        end
    endgenerate

endmodule