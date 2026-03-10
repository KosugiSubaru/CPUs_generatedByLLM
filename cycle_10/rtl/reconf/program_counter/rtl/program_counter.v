module program_counter (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_next_pc,
    output wire [15:0] o_pc,
    output wire [15:0] o_pc_plus_2
);

    // PC本体：現在の命令アドレスを保持する16ビットレジスタ
    program_counter_reg_16bit u_pc_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_data  (i_next_pc),
        .o_data  (o_pc)
    );

    // インクリメンタ：現在のPCに2を加算し、次命令の規定アドレスや戻り先アドレス(JAL等用)を生成
    program_counter_adder_16bit u_pc_inc (
        .i_a   (o_pc),
        .i_b   (16'h0002),
        .o_sum (o_pc_plus_2)
    );

endmodule