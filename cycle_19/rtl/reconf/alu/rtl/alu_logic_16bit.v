module alu_logic_16bit (
    input  wire [15:0] i_a,      // 入力A
    input  wire [15:0] i_b,      // 入力B
    input  wire [3:0]  i_alu_op, // ALU演算種別信号
    output wire [15:0] o_res     // 16ビット演算結果
);

    genvar i;

    // 1ビット論理演算器を16個並列に展開
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_logic_bits
            alu_logic_1bit u_alu_logic_1bit (
                .i_a      (i_a[i]),
                .i_b      (i_b[i]),
                .i_alu_op (i_alu_op),
                .o_res    (o_res[i])
            );
        end
    endgenerate

endmodule