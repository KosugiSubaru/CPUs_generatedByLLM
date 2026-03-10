module flag_reg (
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire [3:0] i_opcode,
    input  wire       i_alu_z,
    input  wire       i_alu_n,
    input  wire       i_alu_v,
    output wire       o_flag_z,
    output wire       o_flag_n,
    output wire       o_flag_v
);

    wire       w_wen;
    wire [2:0] w_alu_flags;
    wire [2:0] w_held_flags;

    // ALUからの生のフラグ信号を束ねる
    assign w_alu_flags = {i_alu_v, i_alu_n, i_alu_z};

    // 命令（opcode）をデコードし、フラグを更新すべきかどうかを判定
    flag_reg_ctrl u_ctrl (
        .i_opcode (i_opcode),
        .o_wen    (w_wen)
    );

    // Z, N, V の3つのフラグ保持用レジスタを並列に配置
    // generate文を用いることで、ビットごとに独立した記憶素子であることを視覚化
    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_bits
            flag_reg_bit u_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_wen   (w_wen),
                .i_d     (w_alu_flags[i]),
                .o_q     (w_held_flags[i])
            );
        end
    endgenerate

    // 1クロック保持（遅延）されたフラグを出力
    assign o_flag_z = w_held_flags[0];
    assign o_flag_n = w_held_flags[1];
    assign o_flag_v = w_held_flags[2];

endmodule