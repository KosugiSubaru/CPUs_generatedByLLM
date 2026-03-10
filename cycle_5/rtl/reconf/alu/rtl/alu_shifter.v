module alu_shifter (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_mode, // 0: SRA (算術右シフト), 1: SLA (算術左シフト)
    output wire [15:0] o_res
);

    wire [15:0] w_sra_res;
    wire [15:0] w_sla_res;
    wire [3:0]  w_shamt;
    genvar i;

    // 16ビット幅のデータに対し、シフト量は下位4ビットのみを使用
    assign w_shamt = i_b[3:0];

    // 算術右シフト (SRA): 符号ビットを維持してシフト
    // $signedを使用することで算術シフトとして動作させる
    assign w_sra_res = $signed(i_a) >>> w_shamt;

    // 算術左シフト (SLA): 左シフトを行う
    assign w_sla_res = i_a << w_shamt;

    // 演算結果の選択 (MUX構造のパタン構造化)
    // 16ビットそれぞれのビットに対して、モードに応じた選択回路を構成する
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_res_mux
            assign o_res[i] = (i_mode == 1'b0) ? w_sra_res[i] : w_sla_res[i];
        end
    endgenerate

endmodule