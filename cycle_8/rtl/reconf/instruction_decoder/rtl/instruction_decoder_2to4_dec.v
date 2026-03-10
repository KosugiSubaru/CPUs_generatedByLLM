module instruction_decoder_2to4_dec (
    input  wire [1:0] i_in,
    output wire [3:0] o_out
);

    // 2ビット入力を4ビットのOne-Hot信号に変換
    // generate文を用いることで、論理合成後の回路図において
    // 各ビットのデコード論理（一致回路）が規則的に並んで視覚化される
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_dec_logic
            assign o_out[i] = (i_in == i);
        end
    endgenerate

endmodule