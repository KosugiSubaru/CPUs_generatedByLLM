module instruction_decoder_field_splitter (
    input  wire [15:0] i_instr,
    output wire [3:0]  o_opcode,
    output wire [3:0]  o_rd_addr,
    output wire [3:0]  o_rs1_addr,
    output wire [3:0]  o_rs2_addr,
    output wire [11:0] o_imm_bits
);

    // オペコードおよびレジスタ指定フィールドの抽出（配線のみ）
    assign o_opcode   = i_instr[3:0];
    assign o_rd_addr  = i_instr[15:12];
    assign o_rs1_addr = i_instr[11:8];
    assign o_rs2_addr = i_instr[7:4];

    // 即値用ビット群の抽出（命令形式により使用範囲が異なるため、可能性のある全ビットを抽出）
    // 合成後の回路図で、12本の独立した配線として視覚化するためにgenerateを使用
    genvar i;
    generate
        for (i = 0; i < 12; i = i + 1) begin : gen_imm_wire
            assign o_imm_bits[i] = i_instr[i + 4];
        end
    endgenerate

endmodule