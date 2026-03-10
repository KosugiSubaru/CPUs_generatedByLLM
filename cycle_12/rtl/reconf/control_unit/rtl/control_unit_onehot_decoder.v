module control_unit_onehot_decoder (
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_onehot
);

    // 4ビットのオペコードを16ビットのOne-Hot信号にデコード
    // 論理合成後の回路図で、16個の比較器が並列に並ぶ構造を視覚化する

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_decode
            assign o_onehot[i] = (i_opcode == i);
        end
    endgenerate

endmodule