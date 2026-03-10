module flag_reg (
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire       i_wen,
    input  wire [2:0] i_alu_flags, // [2]:V, [1]:N, [0]:Z
    output wire       o_flag_z,
    output wire       o_flag_n,
    output wire       o_flag_v
);

    wire [2:0] w_flags_out;

    // フラグビットを保持する記憶素子の配列
    // 論理合成後の回路図で、独立した記憶ブロックとして視覚化される
    generate
        flag_reg_bit_array u_bit_array (
            .i_clk   (i_clk),
            .i_rst_n (i_rst_n),
            .i_wen   (i_wen),
            .i_flags (i_alu_flags),
            .o_flags (w_flags_out)
        );
    endgenerate

    // 保持されているフラグの個別出力（分岐判定回路等で使用）
    assign o_flag_z = w_flags_out[0];
    assign o_flag_n = w_flags_out[1];
    assign o_flag_v = w_flags_out[2];

endmodule