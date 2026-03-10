module imm_gen (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    // 内部接続用ワイヤ
    wire [3:0]  w_opcode;
    wire [3:0]  w_imm4_raw;
    wire [7:0]  w_imm8_raw;
    wire [11:0] w_imm12_raw;
    wire [15:0] w_imm4_ext;
    wire [15:0] w_imm8_ext;
    wire [15:0] w_imm12_ext;

    // 命令からOpcodeを抽出
    assign w_opcode = i_instr[3:0];

    // 即値ビットフィールドの抽出
    // ISAの定義に基づき、命令形式ごとに異なる位置から即値を切り出す
    // 4ビット: addi, load, jalr は [7:4] / store は [15:12]
    assign w_imm4_raw  = (w_opcode == 4'b1011) ? i_instr[15:12] : i_instr[7:4];
    // 8ビット: loadi, jal は [11:4]
    assign w_imm8_raw  = i_instr[11:4];
    // 12ビット: blt, bz は [15:4]
    assign w_imm12_raw = i_instr[15:4];

    // -------------------------------------------------------------------------
    // 1. 符号拡張ユニットのインスタンス化 (各ビット幅用)
    // -------------------------------------------------------------------------

    // 4bit -> 16bit 符号拡張
    imm_gen_ext_4to16 u_ext4 (
        .i_imm (w_imm4_raw),
        .o_imm (w_imm4_ext)
    );

    // 8bit -> 16bit 符号拡張
    imm_gen_ext_8to16 u_ext8 (
        .i_imm (w_imm8_raw),
        .o_imm (w_imm8_ext)
    );

    // 12bit -> 16bit 符号拡張
    imm_gen_ext_12to16 u_ext12 (
        .i_imm (w_imm12_raw),
        .o_imm (w_imm12_ext)
    );

    // -------------------------------------------------------------------------
    // 2. 即値選択マルチプレクサのインスタンス化
    // -------------------------------------------------------------------------
    // 拡張された候補の中から、Opcodeに対応する適切な幅の即値を選択する
    imm_gen_mux u_mux (
        .i_opcode (w_opcode),
        .i_imm4   (w_imm4_ext),
        .i_imm8   (w_imm8_ext),
        .i_imm12  (w_imm12_ext),
        .o_imm    (o_imm)
    );

endmodule