module instruction_decoder_field_logic (
    input  wire [15:0] i_instr,
    output wire [3:0]  o_rd_addr,
    output wire [3:0]  o_rs1_addr,
    output wire [3:0]  o_rs2_addr
);

    // 16bit命令からレジスタアドレス指定フィールドを抽出
    // 命令形式に関わらず固定位置を抽出し、有効性は制御信号(RegWrite等)で決定する
    assign o_rd_addr  = i_instr[15:12];
    assign o_rs1_addr = i_instr[11:8];
    assign o_rs2_addr = i_instr[7:4];

endmodule