module imm_gen_ext_s4 (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // store 命令用 (ビット[15:12]を抽出)
    assign o_imm[3:0] = i_instr[15:12];

    // ビット15 (抽出した4bit即値のMSB) を用いて符号拡張
    genvar i;
    generate
        for (i = 4; i < 16; i = i + 1) begin : gen_sign_ext_store
            assign o_imm[i] = i_instr[15];
        end
    endgenerate

endmodule