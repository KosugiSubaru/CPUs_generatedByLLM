module flag_reg (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_en,
    input  wire i_flag_z,
    input  wire i_flag_n,
    input  wire i_flag_v,
    output wire o_flag_z,
    output wire o_flag_n,
    output wire o_flag_v
);

    wire [2:0] w_flags_in;
    wire [2:0] w_flags_out;

    // ALUからのフラグ出力をバスにまとめる
    assign w_flags_in = {i_flag_z, i_flag_n, i_flag_v};

    // 保存されたフラグ値を個別に出力する
    assign o_flag_z = w_flags_out[2];
    assign o_flag_n = w_flags_out[1];
    assign o_flag_v = w_flags_out[0];

    // generate文を用いて3つのフラグビットを構造的に配置する
    // 回路図上でフラグごとに独立したレジスタセルが並んでいる様子を視覚化する
    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_bits
            flag_reg_bit u_flag_bit (
                .i_clk      (i_clk),
                .i_rst_n    (i_rst_n),
                .i_en       (i_en),
                .i_flag_in  (w_flags_in[i]),
                .o_flag_out (w_flags_out[i])
            );
        end
    endgenerate

endmodule