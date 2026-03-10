module instruction_decoder_field_extractor (
    input  wire [15:0] i_instr,
    output wire [3:0]  o_opcode,
    output wire [3:0]  o_rd_addr,
    output wire [3:0]  o_rs1_addr,
    output wire [3:0]  o_rs2_addr,
    output wire [11:0] o_imm_raw
);

    // 命令ビット列から各フィールドを物理的に切り出す
    // どの命令形式（R/I/B/J-type）であっても、ビット位置そのものを抽出する
    
    // オペコード: [3:0]
    assign o_opcode   = i_instr[3:0];

    // レジスタ指定子候補（命令形式によって意味が変わるが、位置は固定されることが多い）
    assign o_rd_addr  = i_instr[15:12]; // RD（またはStoreのImm[15:12]）
    assign o_rs1_addr = i_instr[11:8];  // RS1
    assign o_rs2_addr = i_instr[7:4];   // RS2（またはaddi等のImm[7:4]）

    // 即値フィールド候補（後続のImmGenで符号拡張される前の生のビット列）
    // 最長の即値幅を持つBranch(12bit)を基準に出力
    assign o_imm_raw  = i_instr[15:4];

endmodule