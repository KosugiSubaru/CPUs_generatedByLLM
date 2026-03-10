module control_unit_alu_decoder (
    input  wire [15:0] i_inst_onehot,
    output wire [3:0]  o_alu_mode
);

    // 各命令の有効信号（視覚的対応のための内部結線）
    wire w_sub = i_inst_onehot[1];
    wire w_and = i_inst_onehot[2];
    wire w_or  = i_inst_onehot[3];
    wire w_xor = i_inst_onehot[4];
    wire w_not = i_inst_onehot[5];
    wire w_sra = i_inst_onehot[6];
    wire w_sla = i_inst_onehot[7];

    // ALUモード選択ロジック (ビットごとの論理合成)
    // ADD系命令(add, addi, load, store)は、全ビットが0(Mode 0000)となることで選択される
    assign o_alu_mode[0] = w_sub | w_or  | w_not | w_sla;
    assign o_alu_mode[1] = w_and | w_or  | w_sra | w_sla;
    assign o_alu_mode[2] = w_xor | w_not | w_sra | w_sla;
    assign o_alu_mode[3] = 1'b0;

endmodule