module flag_reg (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_flag_wen, // フラグ更新有効信号
    input  wire i_flag_z,   // ALUからの入力(Z)
    input  wire i_flag_n,   // ALUからの入力(N)
    input  wire i_flag_v,   // ALUからの入力(V)
    output wire o_flag_z,   // 保存されたフラグ(Z)
    output wire o_flag_n,   // 保存されたフラグ(N)
    output wire o_flag_v    // 保存されたフラグ(V)
);

    wire [2:0] w_flags_in;
    wire [2:0] w_flags_out;

    // 視覚化とインデックス管理のために入力をバス化
    assign w_flags_in = {i_flag_z, i_flag_n, i_flag_v};

    // パタン構造化：Z, N, Vの3ビット分をループでインスタンス化
    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_units
            flag_reg_unit u_unit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_flag_wen),
                .i_d     (w_flags_in[i]),
                .o_q     (w_flags_out[i])
            );
        end
    endgenerate

    // 出力ポートへの接続
    assign o_flag_z = w_flags_out[2];
    assign o_flag_n = w_flags_out[1];
    assign o_flag_v = w_flags_out[0];

endmodule