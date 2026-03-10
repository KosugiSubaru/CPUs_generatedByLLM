module alu_core_logical_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [3:0]  i_opcode,
    output wire [15:0] o_res
);

    wire [15:0] w_res_and;
    wire [15:0] w_res_or;
    wire [15:0] w_res_xor;
    wire [15:0] w_res_not;

    // 1ビット論理演算スライスを16個並列配置して16ビット演算を実現
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_logic_slices
            alu_core_bit_logic u_bit_logic (
                .i_a   (i_a[i]),
                .i_b   (i_b[i]),
                .o_and (w_res_and[i]),
                .o_or  (w_res_or[i]),
                .o_xor (w_res_xor[i]),
                .o_not (w_res_not[i])
            );
        end
    endgenerate

    // Opcodeに基づき、実行中の論理演算結果を選択
    assign o_res = (i_opcode == 4'b0010) ? w_res_and :
                   (i_opcode == 4'b0011) ? w_res_or  :
                   (i_opcode == 4'b0100) ? w_res_xor :
                   (i_opcode == 4'b0101) ? w_res_not : 16'h0000;

endmodule