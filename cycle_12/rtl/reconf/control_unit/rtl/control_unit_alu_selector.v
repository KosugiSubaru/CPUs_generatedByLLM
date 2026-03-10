module control_unit_alu_selector (
    input  wire [15:0] i_onehot,
    output wire [3:0]  o_alu_op,
    output wire        o_alu_src_b_sel // 0: Register(rs2), 1: Immediate
);

    // ALU演算モードのデコード信号
    // ISAのオペコード[3:0]を基本としつつ、I形式やメモリアクセス命令では強制的にADDに変換する
    wire w_op_add_type;
    wire w_op_pass_imm;

    // ADDが必要な命令群: add(0), addi(8), load(10), store(11)
    assign w_op_add_type = i_onehot[0] | i_onehot[8] | i_onehot[10] | i_onehot[11];
    
    // 即値をそのまま通す必要がある命令群: loadi(9)
    assign w_op_pass_imm = i_onehot[9];

    // ALU演算選択信号の生成
    // R形式はオペコードをそのまま使用。それ以外は上記条件で上書きする。
    assign o_alu_op = (w_op_add_type) ? 4'b0000 :
                      (w_op_pass_imm) ? 4'b1001 :
                      (i_onehot[1])   ? 4'b0001 : // sub
                      (i_onehot[2])   ? 4'b0010 : // and
                      (i_onehot[3])   ? 4'b0011 : // or
                      (i_onehot[4])   ? 4'b0100 : // xor
                      (i_onehot[5])   ? 4'b0101 : // not
                      (i_onehot[6])   ? 4'b0110 : // sra
                      (i_onehot[7])   ? 4'b0111 : // sla
                                        4'b0000;

    // ALUの第2入力(B)に即値(Immediate)を供給するかどうかの選択信号
    // addi(8), loadi(9), load(10), store(11) で即値を使用する
    assign o_alu_src_b_sel = i_onehot[8] | i_onehot[9] | i_onehot[10] | i_onehot[11];

endmodule