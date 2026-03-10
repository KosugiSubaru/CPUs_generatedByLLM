module alu_core_nbit_shifter (
    input  wire [15:0] i_data,
    input  wire [3:0]  i_amt,
    input  wire        i_left, // 0: SRA (算術右シフト), 1: SLA (算術左シフト)
    output wire [15:0] o_data
);

    wire [15:0] w_sra_out;
    wire [15:0] w_sla_out;

    // 算術右シフト (符号ビットを維持してシフト)
    // Verilogの >>> 演算子は、$signedでキャストすることで算術シフトとして動作する
    assign w_sra_out = $signed(i_data) >>> i_amt;

    // 算術左シフト (0を充填してシフト)
    // 一般的な16bitアーキテクチャでは、論理左シフトと算術左シフトは同等の動作（0埋め）となる
    assign w_sla_out = i_data << i_amt;

    // 演算種別フラグ(i_left)に基づいて、最終的な結果をビット並列で選択
    // 論理合成後の回路図において、右シフトパスと左シフトパスが並列に存在し、
    // 最後にセレクタで選ばれる構造を視覚化する
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_shift_mux
            assign o_data[i] = (i_left) ? w_sla_out[i] : w_sra_out[i];
        end
    endgenerate

endmodule