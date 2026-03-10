module flag_reg (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_z,    // ALUからの現在のZeroフラグ
    input  wire i_n,    // ALUからの現在のNegativeフラグ
    input  wire i_v,    // ALUからの現在のOverflowフラグ
    output wire o_z,    // 前クロックのZeroフラグ
    output wire o_n,    // 前クロックのNegativeフラグ
    output wire o_v     // 前クロックのOverflowフラグ
);

    // 内部ワイヤ：フラグを3ビット幅に束ねる
    wire [2:0] w_alu_flags;
    wire [2:0] w_stored_flags;

    // ALUからの個別フラグを入力用に結合
    assign w_alu_flags = {i_v, i_n, i_z};

    // 3ビット幅のレジスタをインスタンス化
    // この中でgenerate文を用いて1ビットDFFが3つ並列に生成される
    flag_reg_3bit u_flag_reg_3bit (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_d     (w_alu_flags),
        .o_q     (w_stored_flags)
    );

    // 保持されたフラグを個別に出力へ分離
    // これにより、分岐命令は「1クロック前の演算結果」を参照することになる
    assign o_z = w_stored_flags[0];
    assign o_n = w_stored_flags[1];
    assign o_v = w_stored_flags[2];

endmodule