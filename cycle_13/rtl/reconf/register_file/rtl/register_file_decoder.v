module register_file_decoder (
    input  wire [3:0]  i_addr,
    input  wire        i_wen,
    output wire [15:0] o_reg_ens
);

    genvar i;

    // 4ビットのレジスタアドレスを16本の書き込み許可信号に展開する
    // ISA定義に従い、レジスタ0（zero_reg）は常に書き込み不可（0）とする
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_ens
            if (i == 0) begin : reg_zero
                assign o_reg_ens[i] = 1'b0;
            end else begin : reg_normal
                assign o_reg_ens[i] = (i_addr == i[3:0]) ? i_wen : 1'b0;
            end
        end
    endgenerate

endmodule