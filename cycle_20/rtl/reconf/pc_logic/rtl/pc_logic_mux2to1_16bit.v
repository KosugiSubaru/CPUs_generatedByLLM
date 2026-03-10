module pc_logic_mux2to1_16bit (
    input  wire        i_sel,
    input  wire [15:0] i_data0,
    input  wire [15:0] i_data1,
    output wire [15:0] o_data
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_pc_logic_mux_bits
            // 1ビット2入力セレクタを16ビット分並列に展開
            pc_logic_mux2to1_1bit u_pc_logic_mux2to1_1bit (
                .i_sel (i_sel),
                .i_in0 (i_data0[i]),
                .i_in1 (i_data1[i]),
                .o_out (o_data[i])
            );
        end
    endgenerate

endmodule