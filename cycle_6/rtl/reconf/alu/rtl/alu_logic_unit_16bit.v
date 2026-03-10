module alu_logic_unit_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [2:0]  i_op, // and, or, xor, not を切り替えるための下位3ビット
    output wire [15:0] o_y
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_logic_bits
            // ビットごとに論理演算を行うモジュールを16個並列化
            alu_bit_logic u_bit_logic (
                .i_a  (i_a[i]),
                .i_b  (i_b[i]),
                .i_op (i_op),
                .o_y  (o_y[i])
            );
        end
    endgenerate

endmodule