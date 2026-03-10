module pc_reg (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [1:0]  i_pc_sel,
    input  wire [15:0] i_pc_plus_2,
    input  wire [15:0] i_pc_branch,
    input  wire [15:0] i_pc_jalr,
    output wire [15:0] o_pc
);

    wire [15:0] w_next_pc;
    genvar i;

    // 次のPC値を選択する16ビット4入力マルチプレクサ
    // 00: PC+2, 01: PC+imm, 10: rs1+imm, 11: 0(Reserved)
    pc_reg_mux4_16bit u_pc_mux (
        .i_sel  (i_pc_sel),
        .i_d0   (i_pc_plus_2),
        .i_d1   (i_pc_branch),
        .i_d2   (i_pc_jalr),
        .i_d3   (16'b0),
        .o_data (w_next_pc)
    );

    // 1ビットレジスタ素子を16個並列化して16ビットレジスタを構成
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pc_register
            pc_reg_bit u_pc_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (w_next_pc[i]),
                .o_q     (o_pc[i])
            );
        end
    endgenerate

endmodule