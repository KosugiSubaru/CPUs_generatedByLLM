module instruction_decoder (
    input  wire [15:0] i_instr,       // 16ビット命令コード
    output wire [3:0]  o_rd,          // デスティネーションレジスタ番号
    output wire [3:0]  o_rs1,         // ソースレジスタ1番号
    output wire [3:0]  o_rs2,         // ソースレジスタ2番号
    output wire [15:0] o_imm,         // 符号拡張済み即値
    output wire        o_reg_wen,     // レジスタファイル書き込み有効信号
    output wire        o_dmem_wen,    // データメモリ書き込み有効信号
    output wire        o_mem_to_reg,  // メモリ読み出しデータをレジスタへ送る選択信号
    output wire        o_alu_src,     // ALU入力を即値にする選択信号
    output wire [3:0]  o_alu_op,      // ALU演算種別信号
    output wire        o_is_branch,   // 分岐命令フラグ
    output wire        o_is_jump,     // ジャンプ命令フラグ
    output wire        o_is_jalr      // jalr命令フラグ
);

    // 16種類のオペコードに対する一致信号
    wire [15:0] w_match;
    
    // generate文用の変数を宣言
    genvar i;

    // 全16命令の一致判定器をインスタンス化
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_match
            instruction_decoder_match u_match (
                .i_opcode        (i_instr[3:0]),
                .i_target_opcode (i[3:0]),
                .o_match         (w_match[i])
            );
        end
    endgenerate

    // レジスタ番号および即値の解析ユニット
    instruction_decoder_field u_field (
        .i_instr (i_instr),
        .o_rd    (o_rd),
        .o_rs1   (o_rs1),
        .o_rs2   (o_rs2),
        .o_imm   (o_imm)
    );

    // 各命令一致信号の論理和による制御信号の生成
    
    // レジスタ書き込み(RegWrite): add, sub, and, or, xor, not, sra, sla, addi, loadi, load, jal, jalr
    assign o_reg_wen    = w_match[0] | w_match[1] | w_match[2] | w_match[3] |
                         w_match[4] | w_match[5] | w_match[6] | w_match[7] |
                         w_match[8] | w_match[9] | w_match[10]| w_match[14]| w_match[15];

    // メモリ書き込み(MemWrite): store
    assign o_dmem_wen   = w_match[11];

    // ロード命令判定: load
    assign o_mem_to_reg = w_match[10];

    // ALU入力選択(ALUSrc): addi, loadi, load, store, jalr (rs2ではなくimmを使用するもの)
    assign o_alu_src    = w_match[8] | w_match[9] | w_match[10] | w_match[11] | w_match[15];

    // ALU演算信号: 命令のopcodeをそのまま転送
    assign o_alu_op     = i_instr[3:0];

    // 分岐・ジャンプ判定
    assign o_is_branch  = w_match[12] | w_match[13];
    assign o_is_jump    = w_match[14] | w_match[15];
    assign o_is_jalr    = w_match[15];

endmodule