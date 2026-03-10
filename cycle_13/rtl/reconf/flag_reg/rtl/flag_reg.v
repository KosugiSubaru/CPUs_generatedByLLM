module flag_reg (
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire       i_wen,
    input  wire [2:0] i_flags_in,  // [2]:Z, [1]:N, [0]:V (ALUからの入力)
    output wire [2:0] o_flags_out  // [2]:Z, [1]:N, [0]:V (保持されているフラグ)
);

    genvar i;

    // クロック同期でフラグを保持するビット素子を3つ並列に配置する
    // これにより、前回の演算結果に基づく条件分岐が物理的に可能になる
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_bits
            flag_reg_bit u_flag_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_wen   (i_wen),
                .i_d     (i_flags_in[i]),
                .o_q     (o_flags_out[i])
            );
        end
    endgenerate

endmodule