module imm_gen_mux (
    input  wire [3:0]  i_opcode,
    input  wire [15:0] i_imm4,    // 4ビット符号拡張済み
    input  wire [15:0] i_imm8,    // 8ビット符号拡張済み
    input  wire [15:0] i_imm12,   // 12ビット符号拡張済み
    output wire [15:0] o_imm
);

    wire w_sel_imm8;
    wire w_sel_imm12;

    // 選択条件の定義
    // 8ビット即値を選択する命令: loadi (1001), jal (1110)
    assign w_sel_imm8  = (i_opcode == 4'b1001) || (i_opcode == 4'b1110);

    // 12ビット即値を選択する命令: blt (1100), bz (1101)
    assign w_sel_imm12 = (i_opcode == 4'b1100) || (i_opcode == 4'b1101);

    genvar i;

    // 16ビットそれぞれのビットに対して、命令タイプに基づいた選択回路を構成する
    // 論理合成後の回路図において、ビットスライス構造のMUXとして視覚化される
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_imm_mux_bits
            assign o_imm[i] = w_sel_imm12 ? i_imm12[i] :
                             w_sel_imm8  ? i_imm8[i]  :
                                           i_imm4[i];
        end
    endgenerate

endmodule