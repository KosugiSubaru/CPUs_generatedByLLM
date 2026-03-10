module immediate_generator (
    input  wire [11:0] i_imm_raw,
    input  wire [1:0]  i_imm_sel,    // 00:I, 01:S, 10:L, 11:B
    output wire [15:0] o_imm_ext
);

    wire [15:0] w_imm_i;
    wire [15:0] w_imm_s;
    wire [15:0] w_imm_l;
    wire [15:0] w_imm_b;

    // 1. I-type 拡張器 (addi, load, jalr 等)
    immediate_generator_i_extender u_i_ext (
        .i_imm_bits (i_imm_raw),
        .o_imm_ext  (w_imm_i)
    );

    // 2. S-type 拡張器 (store 等)
    immediate_generator_s_extender u_s_ext (
        .i_imm_bits (i_imm_raw),
        .o_imm_ext  (w_imm_s)
    );

    // 3. L-type 拡張器 (loadi, jal 等)
    immediate_generator_l_extender u_l_ext (
        .i_imm_bits (i_imm_raw),
        .o_imm_ext  (w_imm_l)
    );

    // 4. B-type 拡張器 (branch 等)
    immediate_generator_b_extender u_b_ext (
        .i_imm_bits (i_imm_raw),
        .o_imm_ext  (w_imm_b)
    );

    // 5. 命令形式に基づく最終的な即値の選択
    // 回路図上で、全形式の拡張器が並列動作し、MUXで1つが選ばれる様子を視覚化
    immediate_generator_mux_4to1_16bit u_mux (
        .i_sel  (i_imm_sel),
        .i_d0   (w_imm_i),
        .i_d1   (w_imm_s),
        .i_d2   (w_imm_l),
        .i_d3   (w_imm_b),
        .o_data (o_imm_ext)
    );

endmodule