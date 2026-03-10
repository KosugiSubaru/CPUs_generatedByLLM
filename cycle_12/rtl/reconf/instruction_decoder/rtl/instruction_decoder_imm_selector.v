module instruction_decoder_imm_selector (
    input  wire [3:0]  i_opcode,
    input  wire [3:0]  i_nibble_1, // [7:4]
    input  wire [3:0]  i_nibble_2, // [11:8]
    input  wire [3:0]  i_nibble_3, // [15:12]
    output wire [11:0] o_imm_raw
);

    // 各命令フォーマットごとの即値の「切り出しパターン」を定義
    // 後続の符号拡張モジュールのために、LSB側に寄せて出力する

    wire [11:0] w_imm_type_12bit; // Branch (blt, bz)
    wire [11:0] w_imm_type_8bit;  // loadi, jal
    wire [11:0] w_imm_type_4bit;  // addi, load, jalr
    wire [11:0] w_imm_type_store; // store

    assign w_imm_type_12bit = {i_nibble_3, i_nibble_2, i_nibble_1}; // [15:4]
    assign w_imm_type_8bit  = {4'b0000, i_nibble_2, i_nibble_1};    // [11:4]
    assign w_imm_type_4bit  = {8'b0000, i_nibble_1};                // [7:4]
    assign w_imm_type_store = {8'b0000, i_nibble_3};                // [15:12]

    // オペコードに応じてどの「切り出しパターン」を有効にするか選択
    // 回路図上で、命令の種類によってビットの抽出元が切り替わる様子を視覚化する
    assign o_imm_raw = (i_opcode == 4'b1100 || i_opcode == 4'b1101) ? w_imm_type_12bit :
                       (i_opcode == 4'b1001 || i_opcode == 4'b1110) ? w_imm_type_8bit  :
                       (i_opcode == 4'b1011)                        ? w_imm_type_store :
                                                                      w_imm_type_4bit;

endmodule