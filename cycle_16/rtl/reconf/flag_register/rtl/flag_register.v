module flag_register (
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire       i_alu_z,   // 現在のALU出力：ゼロフラグ
    input  wire       i_alu_n,   // 現在のALU出力：負フラグ
    input  wire       i_alu_v,   // 現在のALU出力：オーバーフローフラグ
    output wire       o_flag_z,  // 保持されたフラグ（次命令の条件判定用）
    output wire       o_flag_n,
    output wire       o_flag_v
);

    wire [2:0] w_alu_flags;
    wire [2:0] w_stored_flags;

    // ALUからのフラグをバスにまとめる
    assign w_alu_flags = {i_alu_z, i_alu_n, i_alu_v};

    // 保持されたフラグを各出力へ分配
    assign o_flag_z = w_stored_flags[2];
    assign o_flag_n = w_stored_flags[1];
    assign o_flag_v = w_stored_flags[0];

    // パタン構造化：各フラグビットに対してレジスタをインスタンス化
    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_bits
            flag_register_bit u_flag_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (w_alu_flags[i]),
                .o_q     (w_stored_flags[i])
            );
        end
    endgenerate

endmodule