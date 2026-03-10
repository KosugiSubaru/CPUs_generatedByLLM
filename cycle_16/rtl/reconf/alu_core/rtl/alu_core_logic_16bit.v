module alu_core_logic_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [1:0]  i_sel, // Opcode[1:0] 10:and, 11:or, 00:xor, 01:not
    output wire [15:0] o_out
);

    genvar i;

    // ビットごとに独立した論理演算を行うため、1bitのスライスを16個並列化
    // これにより、データパスの「ビット並列性」を視覚化する
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_logic_slice
            alu_core_logic_slice u_logic_slice (
                .i_a   (i_a[i]),
                .i_b   (i_b[i]),
                .i_sel (i_sel),
                .o_out (o_out[i])
            );
        end
    endgenerate

endmodule