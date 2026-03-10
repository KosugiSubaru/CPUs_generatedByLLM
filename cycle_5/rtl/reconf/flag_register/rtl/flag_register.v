module flag_register (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_wen,      // フラグ更新有効信号（演算命令実行時に真）
    input  wire i_alu_z,    // ALUからの現在のZeroフラグ
    input  wire i_alu_n,    // ALUからの現在のNegativeフラグ
    input  wire i_alu_v,    // ALUからの現在のOverflowフラグ
    output wire o_flag_z,   // 保存されているZeroフラグ（次サイクル用）
    output wire o_flag_n,   // 保存されているNegativeフラグ（次サイクル用）
    output wire o_flag_v    // 保存されているOverflowフラグ（次サイクル用）
);

    // generate文で使用するためにフラグをベクトルにまとめる
    wire [2:0] w_alu_flags;
    wire [2:0] w_reg_flags;

    assign w_alu_flags = {i_alu_z, i_alu_n, i_alu_v};

    genvar i;

    // Z, N, Vの3ビット分、個別に保持回路をインスタンス化
    // これにより、演算結果の状態が「記憶」される様子を視覚化する
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_bits
            flag_register_bit u_flag_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_wen),
                .i_d     (w_alu_flags[i]),
                .o_q     (w_reg_flags[i])
            );
        end
    endgenerate

    // 出力への接続
    assign o_flag_z = w_reg_flags[2];
    assign o_flag_n = w_reg_flags[1];
    assign o_flag_v = w_reg_flags[0];

endmodule