module instruction_decoder_reg_selector (
    input  wire [3:0] i_nibble_1, // [7:4]
    input  wire [3:0] i_nibble_2, // [11:8]
    input  wire [3:0] i_nibble_3, // [15:12]
    output wire [3:0] o_rd_addr,
    output wire [3:0] o_rs1_addr,
    output wire [3:0] o_rs2_addr
);

    // ISA定義に基づき、各ニブルからレジスタアドレスを抽出
    // 本ISAでは、rs1, rs2, rdの位置が全命令で固定されているため
    // 構造的なビット配線として定義する

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_reg_addr
            assign o_rd_addr[i]  = i_nibble_3[i]; // 常に[15:12]をrdとして抽出
            assign o_rs1_addr[i] = i_nibble_2[i]; // 常に[11:8]をrs1として抽出
            assign o_rs2_addr[i] = i_nibble_1[i]; // 常に[7:4]をrs2として抽出
        end
    endgenerate

endmodule