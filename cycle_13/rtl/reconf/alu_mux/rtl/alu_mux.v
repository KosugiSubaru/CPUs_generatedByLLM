module alu_mux (
    input  wire        i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    output wire [15:0] o_data
);

    genvar i;

    // 1ビットマルチプレクサを16個並列に配置し、16ビットのバス選択回路を構成する
    // i_sel=0 の時にレジスタ値(i_d0)、i_sel=1 の時に即値(i_d1)を選択する
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_alu_mux_bits
            alu_mux_bit u_mux_bit (
                .i_sel  (i_sel),
                .i_d0   (i_d0[i]),
                .i_d1   (i_d1[i]),
                .o_data (o_data[i])
            );
        end
    endgenerate

endmodule