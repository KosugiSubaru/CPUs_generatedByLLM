module register_file_decoder_4to16 (
    input  wire        i_en,
    input  wire [3:0]  i_addr,
    output wire [15:0] o_enables
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_decode_logic
            // i_enが1かつi_addrがインデックスiと一致する場合にのみ、i番目のレジスタへの書き込みを許可
            assign o_enables[i] = i_en && (i_addr == i[3:0]);
        end
    endgenerate

endmodule