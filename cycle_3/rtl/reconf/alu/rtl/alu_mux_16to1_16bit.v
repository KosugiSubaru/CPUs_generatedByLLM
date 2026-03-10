module alu_mux_16to1_16bit (
    input  wire [255:0] i_data,
    input  wire [3:0]   i_sel,
    output wire [15:0]  o_q
);

    genvar bit_idx, op_idx;
    generate
        for (bit_idx = 0; bit_idx < 16; bit_idx = bit_idx + 1) begin : gen_alu_mux_slice
            wire [15:0] w_mux_in;

            // 16種類の演算ユニットから、同じ重みのビット（bit_idx）を抽出して束ねる
            for (op_idx = 0; op_idx < 16; op_idx = op_idx + 1) begin : gen_mux_input_wire
                assign w_mux_in[op_idx] = i_data[op_idx * 16 + bit_idx];
            end

            // 1ビット16入力セレクタを16個並列に配置し、演算結果を最終選択する
            alu_mux_16to1_1bit u_mux_bit (
                .i_d   (w_mux_in),
                .i_sel (i_sel),
                .o_q   (o_q[bit_idx])
            );
        end
    endgenerate

endmodule