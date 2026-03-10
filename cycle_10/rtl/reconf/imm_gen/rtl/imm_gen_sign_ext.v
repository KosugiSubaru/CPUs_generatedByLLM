module imm_gen_sign_ext #(
    parameter IN_WIDTH = 4
)(
    input  wire [IN_WIDTH-1:0] i_in,
    output wire [15:0]         o_out
);

    genvar i;

    // 符号拡張ロジックをビットごとに構造化して視覚化
    generate
        // 下位ビット：入力をそのままコピー
        for (i = 0; i < IN_WIDTH; i = i + 1) begin : gen_lower_bits
            assign o_out[i] = i_in[i];
        end

        // 上位ビット：最上位ビット（符号ビット）をすべての空きビットにコピー
        for (i = IN_WIDTH; i < 16; i = i + 1) begin : gen_sign_bits
            assign o_out[i] = i_in[IN_WIDTH-1];
        end
    endgenerate

endmodule