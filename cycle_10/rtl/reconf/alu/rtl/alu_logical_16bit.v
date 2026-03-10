module alu_logical_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [2:0]  i_op,
    output wire [15:0] o_res
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_logical_bits
            // ビットごとに独立した論理演算ブロックを配置
            // i_op[2:0] は ALU Opcodes 010 (AND), 011 (OR), 100 (XOR), 101 (NOT) に対応
            alu_logical_bit u_bit (
                .i_a   (i_a[i]),
                .i_b   (i_b[i]),
                .i_op  (i_op),
                .o_res (o_res[i])
            );
        end
    endgenerate

endmodule