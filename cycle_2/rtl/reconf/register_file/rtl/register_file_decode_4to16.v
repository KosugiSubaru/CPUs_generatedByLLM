module register_file_decode_4to16 (
    input  wire [3:0]  i_addr,
    input  wire        i_wen,
    output wire [15:0] o_decode_en
);

    genvar i;

    // 4ビットのアドレスを16本の書き込み許可信号に変換
    // 回路図上で各レジスタへの許可信号が独立して見えるようにgenerate文で記述
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_decode_logic
            if (i == 0) begin : r0_logic
                // ISA定義：レジスタ0は書き込み不可
                assign o_decode_en[i] = 1'b0;
            end else begin : general_reg_logic
                // 指定されたアドレスと一致し、かつ全体の書き込み有効信号がHighの時のみ許可
                assign o_decode_en[i] = (i_addr == i[3:0]) & i_wen;
            end
        end
    endgenerate

endmodule