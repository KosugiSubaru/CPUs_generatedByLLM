module flag_reg (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_flag_wen,   // 演算命令時のみフラグを更新するための有効信号
    input  wire [2:0]  i_flags_in,   // ALUから出力される現在のフラグ [2]:V, [1]:N, [0]:Z
    output wire [2:0]  o_flags_out   // 1クロック保持されたフラグ（分岐判定用）
);

    // パタン構造化：各フラグビット（Z, N, V）に対して個別にDFFを配置
    // これにより、回路図上でフラグがビットごとに管理されている様子を視覚化する
    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_storage
            flag_reg_dff u_flag_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_flag_wen),
                .i_d     (i_flags_in[i]),
                .o_q     (o_flags_out[i])
            );
        end
    endgenerate

endmodule