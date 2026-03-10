module next_pc_logic_mux_4to1_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_y
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_bits
            // 16ビットの各ビットに対して並列に4入力セレクタを構成
            // 論理合成後の回路図で、ビット並列な選択構造を視覚化する
            assign o_y[i] = (i_sel == 2'b00) ? i_d0[i] :
                            (i_sel == 2'b01) ? i_d1[i] :
                            (i_sel == 2'b10) ? i_d2[i] :
                                               i_d3[i];
        end
    endgenerate

endmodule