module register_file (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [3:0]  i_rs1_addr,
    input  wire [3:0]  i_rs2_addr,
    input  wire [3:0]  i_rd_addr,
    input  wire [15:0] i_rd_data,
    input  wire        i_rd_wen,
    output wire [15:0] o_rs1_data,
    output wire [15:0] o_rs2_data
);

    wire [15:0]  w_reg_ens;
    wire [255:0] w_reg_outputs;
    genvar i;

    // 書き込みデコーダー：どのアドレスのレジスタに書き込むかを決定
    register_file_decoder u_decoder (
        .i_addr    (i_rd_addr),
        .i_wen     (i_rd_wen),
        .o_reg_ens (w_reg_ens)
    );

    // 16個の16ビットレジスタを生成
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_registers
            register_file_word u_word (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (w_reg_ens[i]),
                .i_data  (i_rd_data),
                .o_data  (w_reg_outputs[i*16 +: 16])
            );
        end
    endgenerate

    // 読み出しポート1用の16入力マルチプレクサ
    register_file_mux16_16bit u_mux_rs1 (
        .i_sel   (i_rs1_addr),
        .i_data0 (w_reg_outputs[0*16  +: 16]), .i_data1 (w_reg_outputs[1*16  +: 16]),
        .i_data2 (w_reg_outputs[2*16  +: 16]), .i_data3 (w_reg_outputs[3*16  +: 16]),
        .i_data4 (w_reg_outputs[4*16  +: 16]), .i_data5 (w_reg_outputs[5*16  +: 16]),
        .i_data6 (w_reg_outputs[6*16  +: 16]), .i_data7 (w_reg_outputs[7*16  +: 16]),
        .i_data8 (w_reg_outputs[8*16  +: 16]), .i_data9 (w_reg_outputs[9*16  +: 16]),
        .i_data10(w_reg_outputs[10*16 +: 16]), .i_data11(w_reg_outputs[11*16 +: 16]),
        .i_data12(w_reg_outputs[12*16 +: 16]), .i_data13(w_reg_outputs[13*16 +: 16]),
        .i_data14(w_reg_outputs[14*16 +: 16]), .i_data15(w_reg_outputs[15*16 +: 16]),
        .o_data  (o_rs1_data)
    );

    // 読み出しポート2用の16入力マルチプレクサ
    register_file_mux16_16bit u_mux_rs2 (
        .i_sel   (i_rs2_addr),
        .i_data0 (w_reg_outputs[0*16  +: 16]), .i_data1 (w_reg_outputs[1*16  +: 16]),
        .i_data2 (w_reg_outputs[2*16  +: 16]), .i_data3 (w_reg_outputs[3*16  +: 16]),
        .i_data4 (w_reg_outputs[4*16  +: 16]), .i_data5 (w_reg_outputs[5*16  +: 16]),
        .i_data6 (w_reg_outputs[6*16  +: 16]), .i_data7 (w_reg_outputs[7*16  +: 16]),
        .i_data8 (w_reg_outputs[8*16  +: 16]), .i_data9 (w_reg_outputs[9*16  +: 16]),
        .i_data10(w_reg_outputs[10*16 +: 16]), .i_data11(w_reg_outputs[11*16 +: 16]),
        .i_data12(w_reg_outputs[12*16 +: 16]), .i_data13(w_reg_outputs[13*16 +: 16]),
        .i_data14(w_reg_outputs[14*16 +: 16]), .i_data15(w_reg_outputs[15*16 +: 16]),
        .o_data  (o_rs2_data)
    );

endmodule