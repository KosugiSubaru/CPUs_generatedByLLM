module imm_gen_ext_i8 (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // loadi, jal 命令用 (ビット[11:4]を抽出)
    assign o_imm[7:0] = i_instr[11:4];

    // ビット11 (抽出した8bit即値のMSB) を用いて符号拡張
    genvar i;
    generate
        for (i = 8; i < 16; i = i + 1) begin : gen_sign_ext_i8
            assign o_imm[i] = i_instr[11];
        end
    endgenerate

endmodule