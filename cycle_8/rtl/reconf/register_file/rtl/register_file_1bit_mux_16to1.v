module register_file_1bit_mux_16to1 (
    input  wire [3:0]  i_sel,
    input  wire [15:0] i_data,
    output wire        o_q
);

    wire [15:0] w_match;

    // 16入力1ビット出力のセレクタをゲートレベルの構造で展開
    // 論理合成後の回路図において、16個の一致判定ゲートと
    // それらを集約する巨大なOR木として視覚化され、選択の仕組みを理解しやすくする
    genvar k;
    generate
        for (k = 0; k < 16; k = k + 1) begin : gen_mux_logic
            // アドレスが一致したビットのみを通し、それ以外は0にする
            assign w_match[k] = (i_sel == k) ? i_data[k] : 1'b0;
        end
    endgenerate

    // すべてのビットの論理和をとることで、選択された1ビットを抽出
    assign o_q = |w_match;

endmodule