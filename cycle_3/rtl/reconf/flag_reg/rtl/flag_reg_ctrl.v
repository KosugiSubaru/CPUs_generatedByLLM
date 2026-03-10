module flag_reg_ctrl (
    input  wire [3:0] i_opcode,
    output wire       o_wen
);

    // フラグ更新を許可する命令の判定
    // ISA定義およびCPUのデータパスに基づき、ALUで演算結果が生成される命令を選択
    
    wire w_is_alu_r;   // R-type ALU命令 (0000-0111: add, sub, and, or, xor, not, sra, sla)
    wire w_is_addi;    // addi命令 (1000)
    wire w_is_loadi;   // loadi命令 (1001)

    // Opcode [3] が 0 の命令はすべて R-type ALU 演算
    assign w_is_alu_r = (i_opcode[3] == 1'b0);

    // I-type 演算および即値ロード
    assign w_is_addi  = (i_opcode == 4'b1000);
    assign w_is_loadi = (i_opcode == 4'b1001);

    // 書き込み有効信号の集約
    // メモリ操作(load/store)、分岐(branch)、ジャンプ(jump)命令ではフラグを更新しない
    assign o_wen = w_is_alu_r | w_is_addi | w_is_loadi;

endmodule