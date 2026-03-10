module program_counter_register_16bit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_d,
    output wire [15:0] o_q
);

    genvar i;

    // 16ビットのD-FFを並列にインスタンス化
    generate
        for (i = 0; i < 16; i = i + 1) begin : reg_bit
            program_counter_dff u_pc_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_d[i]),
                .o_q     (o_q[i])
            );
        end
    endgenerate

endmodule