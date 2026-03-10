module alu_shifter_16bit (
    input  wire [15:0] i_a,
    input  wire [3:0]  i_b,
    input  wire        i_is_left,
    output wire [15:0] o_res
);

    wire signed [15:0] w_signed_a;
    wire [15:0]        w_sra_res;
    wire [15:0]        w_sla_res;

    // 算術シフトを行うため、符号付きとして扱う
    assign w_signed_a = i_a;

    // 算術右シフト (SRA): 最上位ビット（符号）を空いたビットに補充する
    assign w_sra_res = w_signed_a >>> i_b;

    // 算術左シフト (SLA): 下位ビットに0を補充する（論理左シフトと同様の動作）
    assign w_sla_res = i_a << i_b;

    // SLAかSRAかを選択
    assign o_res = (i_is_left) ? w_sla_res : w_sra_res;

endmodule