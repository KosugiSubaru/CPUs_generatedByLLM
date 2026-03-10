module imm_gen (
    input  wire [15:0] i_instr,
    input  wire [1:0]  i_imm_type, // 00:4bit(TypeA), 01:8bit, 10:4bit(TypeB), 11:12bit
    output wire [15:0] o_imm
);

    // 内部ワイヤ：各形式で拡張された即値候補
    wire [15:0] w_imm_ext4_a;
    wire [15:0] w_imm_ext8;
    wire [15:0] w_imm_ext4_b;
    wire [15:0] w_imm_ext12;

    // --- 1. 符号拡張部 (Sign Extension) ---
    // 各命令フォーマットに応じたビット位置から抽出し、16ビットへ拡張

    // Type 00用: [7:4]を抽出 (addi, load, jalr)
    imm_gen_ext_4to16 u_ext4_a (
        .i_imm (i_instr[7:4]),
        .o_imm (w_imm_ext4_a)
    );

    // Type 01用: [11:4]を抽出 (loadi, jal)
    imm_gen_ext_8to16 u_ext8 (
        .i_imm (i_instr[11:4]),
        .o_imm (w_imm_ext8)
    );

    // Type 10用: [15:12]を抽出 (store)
    imm_gen_ext_4to16 u_ext4_b (
        .i_imm (i_instr[15:12]),
        .o_imm (w_imm_ext4_b)
    );

    // Type 11用: [15:4]を抽出 (blt, bz)
    imm_gen_ext_12to16 u_ext12 (
        .i_imm (i_instr[15:4]),
        .o_imm (w_imm_ext12)
    );

    // --- 2. 最終出力選択部 (Selection) ---
    // 制御信号に基づき、正しい拡張済み即値を選択
    imm_gen_mux4_16bit u_mux_select (
        .i_sel (i_imm_type),
        .i_d0  (w_imm_ext4_a),
        .i_d1  (w_imm_ext8),
        .i_d2  (w_imm_ext4_b),
        .i_d3  (w_imm_ext12),
        .o_y   (o_imm)
    );

endmodule