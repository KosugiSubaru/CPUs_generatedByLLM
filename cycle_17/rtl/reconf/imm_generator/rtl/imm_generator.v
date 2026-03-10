module imm_generator (
    input  wire [15:0] i_instr,
    output wire [15:0] o_imm
);

    wire [15:0] w_imm_ext4_low;
    wire [15:0] w_imm_ext4_high;
    wire [15:0] w_imm_ext8;
    wire [15:0] w_imm_ext12;
    wire [1:0]  w_imm_sel;

    // 命令のオペコード(instr[3:0])に基づいて即値形式を選択する
    // 00: 4bit low (addi, load, jalr)
    // 01: 4bit high (store)
    // 10: 8bit (loadi, jal)
    // 11: 12bit (blt, bz)
    assign w_imm_sel = (i_instr[3:0] == 4'b1000 || i_instr[3:0] == 4'b1010 || i_instr[3:0] == 4'b1111) ? 2'b00 :
                       (i_instr[3:0] == 4'b1011) ? 2'b01 :
                       (i_instr[3:0] == 4'b1001 || i_instr[3:0] == 4'b1110) ? 2'b10 :
                       (i_instr[3:0] == 4'b1100 || i_instr[3:0] == 4'b1101) ? 2'b11 : 2'b00;

    // 各形式の抽出・符号拡張モジュールのインスタンス化
    imm_generator_ext4_low u_ext4l (
        .i_instr (i_instr),
        .o_imm   (w_imm_ext4_low)
    );

    imm_generator_ext4_high u_ext4h (
        .i_instr (i_instr),
        .o_imm   (w_imm_ext4_high)
    );

    imm_generator_ext8 u_ext8 (
        .i_instr (i_instr),
        .o_imm   (w_imm_ext8)
    );

    imm_generator_ext12 u_ext12 (
        .i_instr (i_instr),
        .o_imm   (w_imm_ext12)
    );

    // 最終的な即値を選択する16ビットMUX
    imm_generator_mux4_16bit u_mux_final (
        .i_sel (w_imm_sel),
        .i_d0  (w_imm_ext4_low),
        .i_d1  (w_imm_ext4_high),
        .i_d2  (w_imm_ext8),
        .i_d3  (w_imm_ext12),
        .o_y   (o_imm)
    );

endmodule