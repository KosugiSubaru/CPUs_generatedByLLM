module flag_reg (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_flag_wen, // 制御信号：フラグを更新するかどうか
    input  wire i_flag_z,   // ALUからの入力Z
    input  wire i_flag_n,   // ALUからの入力N
    input  wire i_flag_v,   // ALUからの入力V
    output wire o_flag_z,   // 分岐判定用出力Z
    output wire o_flag_n,   // 分岐判定用出力N
    output wire o_flag_v    // 分岐判定用出力V
);

    // 内部信号：フラグを3ビットのバスとして扱う
    wire [2:0] w_flags_in;
    wire [2:0] w_flags_out;

    // 入力信号の結合
    assign w_flags_in = {i_flag_z, i_flag_n, i_flag_v};

    // --- 状態保持バンク部 (Flag Bank) ---
    // 実際にフラグを保持するフリップフロップ群のインスタンス化
    flag_reg_bank u_flag_reg_bank (
        .i_clk    (i_clk),
        .i_rst_n  (i_rst_n),
        .i_en     (i_flag_wen),
        .i_flags  (w_flags_in),
        .o_flags  (w_flags_out)
    );

    // 出力信号の分配
    assign o_flag_z = w_flags_out[2];
    assign o_flag_n = w_flags_out[1];
    assign o_flag_v = w_flags_out[0];

endmodule