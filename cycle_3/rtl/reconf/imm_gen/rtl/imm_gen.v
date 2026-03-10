module imm_gen (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    wire [1:0]  w_sel;
    wire [15:0] w_imm_i4;
    wire [15:0] w_imm_s4;
    wire [15:0] w_imm_i8;
    wire [15:0] w_imm_b12;

    // 命令のopcodeに基づき、どの即値形式を選択するかを決定するデコーダ
    imm_gen_decoder u_decoder (
        .i_opcode (i_instr[3:0]),
        .o_sel    (w_sel)
    );

    // 各命令フォーマットに応じた即値抽出・符号拡張ユニットのインスタンス化
    // 4bit即値 (addi, load, jalr)
    imm_gen_ext_i4 u_ext_i4 (
        .i_instr (i_instr),
        .o_imm   (w_imm_i4)
    );

    // 4bit即値 (store)
    imm_gen_ext_s4 u_ext_s4 (
        .i_instr (i_instr),
        .o_imm   (w_imm_s4)
    );

    // 8bit即値 (loadi, jal)
    imm_gen_ext_i8 u_ext_i8 (
        .i_instr (i_instr),
        .o_imm   (w_imm_i8)
    );

    // 12bit即値 (blt, bz)
    imm_gen_ext_b12 u_ext_b12 (
        .i_instr (i_instr),
        .o_imm   (w_imm_b12)
    );

    // デコード結果に従い、最終的な16ビット即値を選択
    // 内部で1ビットごとのMUXがgenerate文によりパタン展開される
    imm_gen_mux_4to1_16bit u_mux_16bit (
        .i_d0  (w_imm_i4),
        .i_d1  (w_imm_s4),
        .i_d2  (w_imm_i8),
        .i_d3  (w_imm_b12),
        .i_sel (w_sel),
        .o_q   (o_imm)
    );

endmodule