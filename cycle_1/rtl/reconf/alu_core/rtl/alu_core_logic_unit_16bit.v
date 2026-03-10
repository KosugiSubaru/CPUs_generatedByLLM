module alu_core_logic_unit_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_and,
    output wire [15:0] o_or,
    output wire [15:0] o_xor,
    output wire [15:0] o_not
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_logic_16bit
            // 1ビット論理演算器を16個並列化してインスタンス化
            // 回路図上で16ビット幅の論理演算がビットごとに行われている様子を視覚化
            alu_core_logic_unit_1bit u_logic_bit (
                .i_a   (i_a[i]),
                .i_b   (i_b[i]),
                .o_and (o_and[i]),
                .o_or  (o_or[i]),
                .o_xor (o_xor[i]),
                .o_not (o_not[i])
            );
        end
    endgenerate

endmodule