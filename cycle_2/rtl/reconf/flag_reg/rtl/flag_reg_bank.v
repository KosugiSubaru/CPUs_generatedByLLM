module flag_reg_bank (
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire       i_en,
    input  wire [2:0] i_flags,
    output wire [2:0] o_flags
);

    genvar i;

    // generate文を用いて3つのフラグビット保持回路を並列にインスタンス化
    // 回路図上で独立した3つの保持素子として視覚化される
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_bits
            flag_reg_bit u_flag_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_en),
                .i_d     (i_flags[i]),
                .o_q     (o_flags[i])
            );
        end
    endgenerate

endmodule