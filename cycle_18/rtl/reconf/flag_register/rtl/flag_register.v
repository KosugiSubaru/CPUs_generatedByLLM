module flag_register (
    input wire       i_clk,
    input wire       i_rst_n,
    input wire       i_flag_we,
    input wire       i_alu_flag_z,
    input wire       i_alu_flag_n,
    input wire       i_alu_flag_v,
    output wire      o_flag_z,
    output wire      o_flag_n,
    output wire      o_flag_v
);

    wire [2:0] w_flag_in;
    wire [2:0] w_flag_out;

    // ALUからのフラグをバスにまとめる (0:Z, 1:N, 2:V)
    assign w_flag_in[0] = i_alu_flag_z;
    assign w_flag_in[1] = i_alu_flag_n;
    assign w_flag_in[2] = i_alu_flag_v;

    // 構造化された3ビットレジスタのインスタンス化
    flag_register_3bit u_flag_reg_storage (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_we    (i_flag_we),
        .i_d     (w_flag_in),
        .o_q     (w_flag_out)
    );

    // 保持されているフラグを個別の信号として出力
    assign o_flag_z = w_flag_out[0];
    assign o_flag_n = w_flag_out[1];
    assign o_flag_v = w_flag_out[2];

endmodule