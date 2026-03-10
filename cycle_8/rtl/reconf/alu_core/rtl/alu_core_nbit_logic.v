module alu_core_nbit_logic (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [2:0]  i_op, // オペコードの下位3ビット (AND:010, OR:011, XOR:100, NOT:101)
    output wire [15:0] o_data
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_logic_array
            // 1ビット論理演算器のインスタンス化
            // 論理合成後の回路図において、16個の独立した論理演算ブロックとして視覚化される
            alu_core_1bit_logic u_alu_core_1bit_logic (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_op   (i_op),
                .o_data (o_data[i])
            );
        end
    endgenerate

endmodule