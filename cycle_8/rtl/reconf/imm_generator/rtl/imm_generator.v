module imm_generator (
    input  wire [15:0] i_instr,
    input  wire [1:0]  i_imm_src_sel, // 0:addi/load/jalr, 1:store, 2:loadi/jal, 3:branch
    output wire [15:0] o_imm
);

    // 各命令形式に応じた即値フィールドの抽出（配線）
    wire [3:0]  w_imm_4bit_a; // addi(1000), load(1010), jalr(1111) -> [7:4]
    wire [3:0]  w_imm_4bit_b; // store(1011) -> [15:12]
    wire [7:0]  w_imm_8bit;   // loadi(1001), jal(1110) -> [11:4]
    wire [11:0] w_imm_12bit;  // blt(1100), bz(1101) -> [15:4]

    assign w_imm_4bit_a = i_instr[7:4];
    assign w_imm_4bit_b = i_instr[15:12];
    assign w_imm_8bit   = i_instr[11:4];
    assign w_imm_12bit  = i_instr[15:4];

    // 各形式ごとの符号拡張済み即値候補
    wire [15:0] w_ext_candidates [3:0];

    // --- 1. 符号拡張階層（形式別の構造化） ---
    // 4bit拡張器 (addi/load/jalr用)
    imm_generator_ext_4to16 u_ext4a (
        .i_imm (w_imm_4bit_a),
        .o_q   (w_ext_candidates[0])
    );

    // 4bit拡張器 (store用)
    imm_generator_ext_4to16 u_ext4b (
        .i_imm (w_imm_4bit_b),
        .o_q   (w_ext_candidates[1])
    );

    // 8bit拡張器 (loadi/jal用)
    imm_generator_ext_8to16 u_ext8 (
        .i_imm (w_imm_8bit),
        .o_q   (w_ext_candidates[2])
    );

    // 12bit拡張器 (branch用)
    imm_generator_ext_12to16 u_ext12 (
        .i_imm (w_imm_12bit),
        .o_q   (w_ext_candidates[3])
    );

    // --- 2. 選択階層（MUXの構造化） ---
    // デコーダからの選択信号に基づき、最終的な16bit即値を決定
    imm_generator_mux_4to1 u_imm_mux (
        .i_sel (i_imm_src_sel),
        .i_d0  (w_ext_candidates[0]),
        .i_d1  (w_ext_candidates[1]),
        .i_d2  (w_ext_candidates[2]),
        .i_d3  (w_ext_candidates[3]),
        .o_q   (o_imm)
    );

endmodule