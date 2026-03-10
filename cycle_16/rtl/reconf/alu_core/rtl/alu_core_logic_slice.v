module alu_core_logic_slice (
    input  wire       i_a,
    input  wire       i_b,
    input  wire [1:0] i_sel, // 10:and, 11:or, 00:xor, 01:not (Opcode[1:0])
    output wire       o_out
);

    // 1ビットに対する論理演算ゲート群
    // 選択信号に基づき、計算結果を1つ出力する
    assign o_out = (i_sel == 2'b10) ? (i_a & i_b) :
                   (i_sel == 2'b11) ? (i_a | i_b) :
                   (i_sel == 2'b00) ? (i_a ^ i_b) :
                   (i_sel == 2'b01) ? (~i_a)      : 1'b0;

endmodule