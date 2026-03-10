module imm_generator_mux_4to1 (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_q
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_imm_mux_array
            // 各ビットごとに4つの入力候補から1つを選択
            // 論理合成後の回路図で、16個の独立したセレクタ要素として視覚化される
            assign o_q[i] = (i_sel == 2'b00) ? i_d0[i] :
                            (i_sel == 2'b01) ? i_d1[i] :
                            (i_sel == 2'b10) ? i_d2[i] : i_d3[i];
        end
    endgenerate

endmodule