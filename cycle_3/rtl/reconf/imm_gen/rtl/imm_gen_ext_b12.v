module imm_gen_ext_b12 (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // blt, bz 命令用 (ビット[15:4]を抽出して12bit即値を構成)
    assign o_imm[11:0] = i_instr[15:4];

    // ビット15 (抽出した12bit即値のMSB) を用いて符号拡張
    genvar i;
    generate
        for (i = 12; i < 16; i = i + 1) begin : gen_sign_ext_b12
            assign o_imm[i] = i_instr[15];
        end
    endgenerate

endmodule