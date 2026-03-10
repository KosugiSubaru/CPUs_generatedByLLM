module register_file_array (
    input  wire         i_clk,
    input  wire         i_rst_n,
    input  wire [15:0]  i_enables,
    input  wire [15:0]  i_data,
    output wire [255:0] o_data_bus
);

    // R0は常に0を出力するゼロレジスタとして物理的に固定（レジスタを配置しない）
    assign o_data_bus[15:0] = 16'h0000;

    // R1からR15までの汎用レジスタを生成
    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : gen_regs
            register_file_reg_16bit u_reg (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_enables[i]),
                .i_data  (i_data),
                .o_data  (o_data_bus[16*i +: 16])
            );
        end
    endgenerate

endmodule