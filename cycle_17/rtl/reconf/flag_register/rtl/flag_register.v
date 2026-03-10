module flag_register (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_flag_we, // デコーダからのフラグ更新許可信号
    input  wire i_z,       // ALUからの生フラグ（Zero）
    input  wire i_n,       // ALUからの生フラグ（Negative）
    input  wire i_v,       // ALUからの生フラグ（Overflow）
    output wire o_z,       // 保持されたフラグ（Zero）
    output wire o_n,       // 保持されたフラグ（Negative）
    output wire o_v        // 保持されたフラグ（Overflow）
);

    wire [2:0] w_raw_flags;
    wire [2:0] w_reg_flags;

    assign w_raw_flags = {i_v, i_n, i_z};

    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_bits
            flag_register_bit u_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_flag_we),
                .i_d     (w_raw_flags[i]),
                .o_q     (w_reg_flags[i])
            );
        end
    endgenerate

    assign o_z = w_reg_flags[0];
    assign o_n = w_reg_flags[1];
    assign o_v = w_reg_flags[2];

endmodule