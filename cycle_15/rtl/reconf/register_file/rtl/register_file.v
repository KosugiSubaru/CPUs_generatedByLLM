module register_file (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [3:0]  i_rs1_addr,    // 読み出しポート1 アドレス
    input  wire [3:0]  i_rs2_addr,    // 読み出しポート2 アドレス
    input  wire [3:0]  i_rd_addr,     // 書き込みポート アドレス
    input  wire [15:0] i_rd_data,     // 書き込みデータ
    input  wire        i_wen,         // 書き込み有効信号
    output wire [15:0] o_rs1_data,    // 読み出しデータ1
    output wire [15:0] o_rs2_data     // 読み出しデータ2
);

    wire [15:0]  w_wen_bus;           // 各レジスタへのデコード済み書き込み有効信号
    wire [255:0] w_regs_flat;         // 全16レジスタの値をまとめたバス (16bit * 16)

    // 書き込みデコーダ：書き込みアドレス(rd)を16本の有効信号に展開する
    register_file_write_decoder u_write_dec (
        .i_addr (i_rd_addr),
        .i_wen  (i_wen),
        .o_wen  (w_wen_bus)
    );

    // 記憶アレイ：16ビット×16本のレジスタ実体
    register_file_storage_array u_storage (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_wen_bus   (w_wen_bus),
        .i_data      (i_rd_data),
        .o_regs_flat (w_regs_flat)
    );

    // 読み出しポート：generate文内部でif文を使用し、出力ポートに直接信号を接続
    genvar p;
    generate
        for (p = 0; p < 2; p = p + 1) begin : gen_read_ports
            if (p == 0) begin : gen_port1
                register_file_read_mux_16to1 u_read_mux (
                    .i_sel  (i_rs1_addr),
                    .i_regs (w_regs_flat),
                    .o_data (o_rs1_data)
                );
            end else begin : gen_port2
                register_file_read_mux_16to1 u_read_mux (
                    .i_sel  (i_rs2_addr),
                    .i_regs (w_regs_flat),
                    .o_data (o_rs2_data)
                );
            end
        end
    endgenerate

endmodule