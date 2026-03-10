module flag_reg (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_alu_z,
    input  wire i_alu_n,
    input  wire i_alu_v,
    output wire o_flag_z,
    output wire o_flag_n,
    output wire o_flag_v
);

    wire [2:0] w_alu_flags;
    wire [2:0] w_reg_flags;

    // ALUからの信号をベクトルにまとめる (0:Z, 1:N, 2:V)
    assign w_alu_flags = {i_alu_v, i_alu_n, i_alu_z};

    // 保存されたフラグを各出力へ分配
    assign o_flag_z = w_reg_flags[0];
    assign o_flag_n = w_reg_flags[1];
    assign o_flag_v = w_reg_flags[2];

    // generate文による3ビット分のフラグ保持回路の展開
    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : g_flag_bits
            flag_reg_bit u_flag_reg_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (w_alu_flags[i]),
                .o_q     (w_reg_flags[i])
            );
        end
    endgenerate

endmodule