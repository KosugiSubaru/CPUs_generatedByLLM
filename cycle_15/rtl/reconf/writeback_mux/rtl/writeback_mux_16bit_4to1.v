module writeback_mux_16bit_4to1 (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_data
);

    genvar i;

    // generate文を用いて、1ビット単位の4入力セレクタを16個並列に配置する
    // これにより、論理合成後の回路図においてビットスライス構造が視覚化される
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_wb_mux_slices
            writeback_mux_1bit_4to1 u_slice (
                .i_sel (i_sel),
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .i_d2  (i_d2[i]),
                .i_d3  (i_d3[i]),
                .o_data(o_data[i])
            );
        end
    endgenerate

endmodule