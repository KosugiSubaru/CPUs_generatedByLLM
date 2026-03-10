module alu_logical_unit_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [3:0]  i_alu_op, // 0010:AND, 0011:OR, 0100:XOR, 0101:NOT
    output wire [15:0] o_result
);

    // 16ビットの各ビットに対して並列に論理演算を実行する
    // 論理合成後の回路図で、ビットごとのゲートが整然と並ぶ構造を視覚化する

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_logic_bits
            assign o_result[i] = (i_alu_op == 4'b0010) ? (i_a[i] & i_b[i]) : // AND
                                 (i_alu_op == 4'b0011) ? (i_a[i] | i_b[i]) : // OR
                                 (i_alu_op == 4'b0100) ? (i_a[i] ^ i_b[i]) : // XOR
                                 (i_alu_op == 4'b0101) ? (~i_a[i])         : // NOT
                                                         1'b0;
        end
    endgenerate

endmodule