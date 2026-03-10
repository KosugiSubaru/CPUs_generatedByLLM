module register_file_bank (
    input  wire         i_clk,
    input  wire         i_rst_n,
    input  wire [15:0]  i_wens,
    input  wire [15:0]  i_data,
    output wire [255:0] o_regs
);

    // ISA定義: R0は常に0を返す、書き込み不可
    // 回路図上でR0がレジスタ実体を持たず、定数0に配線されていることを視覚化
    assign o_regs[15:0] = 16'h0000;

    // R1からR15までのレジスタ実体を生成
    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : gen_reg_instances
            register_file_16bit_reg u_reg (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_wens[i]),
                .i_data  (i_data),
                .o_data  (o_regs[16*i +: 16])
            );
        end
    endgenerate

endmodule