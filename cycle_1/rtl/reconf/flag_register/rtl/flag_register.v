module flag_register (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_flag_wen,
    input  wire i_alu_z,
    input  wire i_alu_n,
    input  wire i_alu_v,
    output wire o_flag_z,
    output wire o_flag_n,
    output wire o_flag_v
);

    wire [2:0] w_alu_flags;
    wire [2:0] w_stored_flags;

    // ALUからの個別フラグ信号を1つのバスに統合
    assign w_alu_flags = {i_alu_v, i_alu_n, i_alu_z};

    // Nビット構造化レジスタモジュールのインスタンス化
    // Z, N, V の3ビット分を保持するように構成
    flag_register_nbit u_nbit (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_wen   (i_flag_wen),
        .i_flags (w_alu_flags),
        .o_flags (w_stored_flags)
    );

    // 保持されたフラグを個別の信号として出力
    // これにより、分岐制御回路などが特定のフラグを個別に参照できる
    assign o_flag_z = w_stored_flags[0];
    assign o_flag_n = w_stored_flags[1];
    assign o_flag_v = w_stored_flags[2];

endmodule