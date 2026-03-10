module alu_core_logic_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [1:0]  i_op, // opcode[1:0] (00:XOR, 01:NOT, 10:AND, 11:OR)
    output wire [15:0] o_res
);

    genvar i;

    // generate文を用いて、16ビット分独立した論理ゲートを配置
    // ビット間の依存関係（キャリー）がないことを視覚的に示す構造
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_logic_bits
            alu_core_bit_logic u_bit_logic (
                .i_a  (i_a[i]),
                .i_b  (i_b[i]),
                .i_op (i_op),
                .o_y  (o_res[i])
            );
        end
    endgenerate

endmodule