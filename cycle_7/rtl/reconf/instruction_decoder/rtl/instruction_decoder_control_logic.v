module instruction_decoder_control_logic (
    input  wire [15:0] i_inst_active,
    output wire        o_reg_write_en,
    output wire        o_dmem_wen,
    output wire [3:0]  o_alu_op,
    output wire        o_alu_src_sel,    // 0: rs2, 1: imm
    output wire [1:0]  o_reg_src_sel,    // 0: ALU, 1: Mem, 2: PC+2, 3: Imm(LOADI)
    output wire        o_is_blt,
    output wire        o_is_bz,
    output wire        o_is_jal,
    output wire        o_is_jalr
);

    // 命令ごとの有効信号をエイリアス（視認性向上）
    wire w_inst_add   = i_inst_active[0];
    wire w_inst_sub   = i_inst_active[1];
    wire w_inst_and   = i_inst_active[2];
    wire w_inst_or    = i_inst_active[3];
    wire w_inst_xor   = i_inst_active[4];
    wire w_inst_not   = i_inst_active[5];
    wire w_inst_sra   = i_inst_active[6];
    wire w_inst_sla   = i_inst_active[7];
    wire w_inst_addi  = i_inst_active[8];
    wire w_inst_loadi = i_inst_active[9];
    wire w_inst_load  = i_inst_active[10];
    wire w_inst_store = i_inst_active[11];
    wire w_inst_blt   = i_inst_active[12];
    wire w_inst_bz    = i_inst_active[13];
    wire w_inst_jal   = i_inst_active[14];
    wire w_inst_jalr  = i_inst_active[15];

    // レジスタファイルへの書き込み有効信号
    assign o_reg_write_en = w_inst_add | w_inst_sub | w_inst_and | w_inst_or | 
                            w_inst_xor | w_inst_not | w_inst_sra | w_inst_sla | 
                            w_inst_addi | w_inst_loadi | w_inst_load | 
                            w_inst_jal | w_inst_jalr;

    // データメモリへの書き込み有効信号
    assign o_dmem_wen = w_inst_store;

    // ALU演算ソース選択 (0: rs2_data, 1: immediate)
    assign o_alu_src_sel = w_inst_addi | w_inst_load | w_inst_store | w_inst_jalr;

    // レジスタ書き戻しデータ選択 (0:ALU, 1:DMEM, 2:PC+2, 3:LOADI_IMM)
    assign o_reg_src_sel[0] = w_inst_load | w_inst_loadi;
    assign o_reg_src_sel[1] = w_inst_jal | w_inst_jalr | w_inst_loadi;

    // ALUの操作コード生成 (基本は下位4bitのOpcodeに準拠)
    // ただし、Load/Store/JALRはアドレス計算のために加算(0000)を行う
    assign o_alu_op[0] = w_inst_sub | w_inst_or | w_inst_not | w_inst_sla;
    assign o_alu_op[1] = w_inst_and | w_inst_or | w_inst_sra | w_inst_sla;
    assign o_alu_op[2] = w_inst_xor | w_inst_not | w_inst_sra | w_inst_sla;
    assign o_alu_op[3] = w_inst_addi; // ADDI(1000)は加算として機能

    // 分岐・ジャンプ制御信号
    assign o_is_blt  = w_inst_blt;
    assign o_is_bz   = w_inst_bz;
    assign o_is_jal  = w_inst_jal;
    assign o_is_jalr = w_inst_jalr;

endmodule