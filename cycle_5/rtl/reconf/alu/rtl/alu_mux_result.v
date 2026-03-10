module alu_mux_result (
    input  wire [15:0] i_res_arith,    // 算術演算ユニットの結果
    input  wire [15:0] i_res_logic,    // 論理演算ユニットの結果
    input  wire [15:0] i_res_shift,    // シフト演算ユニットの結果
    input  wire [3:0]  i_mode,         // 演算モード (Opcode)
    output wire [15:0] o_res           // 最終的な演算結果
);

    // 各演算グループの選択フラグ
    wire w_sel_shift;
    wire w_sel_logic;

    // シフト演算を選択する条件: Opcode 0110 (sra), 0111 (sla)
    assign w_sel_shift = (i_mode[3:1] == 3'b011);

    // 論理演算を選択する条件: Opcode 0010 (and), 0011 (or), 0100 (xor), 0101 (not)
    assign w_sel_logic = (i_mode[3:2] == 2'b01 && i_mode[1] == 1'b0) || 
                         (i_mode[3:1] == 3'b001);

    // 演算モードに基づいた結果の最終選択
    // 回路図上で、3つの大きなデータバスから1つを選ぶMUXとして視覚化される
    assign o_res = (w_sel_shift) ? i_res_shift :
                   (w_sel_logic) ? i_res_logic :
                                   i_res_arith;

endmodule