module alu_core_shifter_16bit (
    input  wire [15:0] i_data,
    input  wire [15:0] i_sa,   // シフト量 (rs2の下位ビットを使用)
    input  wire        i_left, // 0: 右シフト(SRA), 1: 左シフト(SLA)
    output wire [15:0] o_res
);

    wire [15:0] w_res_sra;
    wire [15:0] w_res_sla;
    wire [3:0]  w_sa;

    // シフト量は16ビット幅に対して 0〜15 のため下位4ビットを使用
    assign w_sa = i_sa[3:0];

    // 算術右シフト (符号ビットを維持)
    // $signed キャストを用いることで、上位ビットに符号が補填される
    assign w_res_sra = $signed(i_data) >>> w_sa;

    // 算術左シフト
    // 16ビット固定長において、算術左シフトは論理左シフトと動作が等価（下位に0を補填）
    assign w_res_sla = i_data << w_sa;

    // 出力選択
    // i_left信号に基づき、計算済みの左シフト結果か右シフト結果かを選択する
    assign o_res = i_left ? w_res_sla : w_res_sra;

endmodule