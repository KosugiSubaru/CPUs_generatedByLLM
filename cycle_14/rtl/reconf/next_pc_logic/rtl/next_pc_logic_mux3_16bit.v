module next_pc_logic_mux3_16bit (
        input  wire [1:0]  i_sel,     // 00: d0, 01: d1, 10: d2
        input  wire [15:0] i_d0,
        input  wire [15:0] i_d1,
        input  wire [15:0] i_d2,
        output wire [15:0] o_q
    );

        genvar i;
        generate
            for (i = 0; i < 16; i = i + 1) begin : bit_slice_mux
                // ビットスライスごとに1bit幅の3入力セレクタを配置
                // パタン構造化により、回路図上で16ビット並列の選択構造を視覚化する
                next_pc_logic_mux3_1bit u_mux_bit (
                    .i_sel (i_sel),
                    .i_d0  (i_d0[i]),
                    .i_d1  (i_d1[i]),
                    .i_d2  (i_d2[i]),
                    .o_q   (o_q[i])
                );
            end
        endgenerate

    endmodule