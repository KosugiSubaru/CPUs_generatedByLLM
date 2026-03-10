module alu_mux_8to1 (
    input  wire [15:0] i_in0,
    input  wire [15:0] i_in1,
    input  wire [15:0] i_in2,
    input  wire [15:0] i_in3,
    input  wire [15:0] i_in4,
    input  wire [15:0] i_in5,
    input  wire [15:0] i_in6,
    input  wire [15:0] i_in7,
    input  wire [2:0]  i_sel,
    output wire [15:0] o_out
);

    // 入力信号をバスにまとめて、generate文で扱いやすくする
    wire [127:0] w_in_bus;
    assign w_in_bus = {i_in7, i_in6, i_in5, i_in4, i_in3, i_in2, i_in1, i_in0};

    // 1段目のMUX（4入力1出力 × 2個）の結果を保持するワイヤ
    wire [31:0] w_stage1_out;

    genvar i;
    generate
        for (i = 0; i < 2; i = i + 1) begin : gen_mux_stage1
            // i=0: in0〜in3を選択, i=1: in4〜in7を選択
            alu_mux_4to1 u_mux_4to1 (
                .i_data0 (w_in_bus[(64*i) + 16*0 +: 16]),
                .i_data1 (w_in_bus[(64*i) + 16*1 +: 16]),
                .i_data2 (w_in_bus[(64*i) + 16*2 +: 16]),
                .i_data3 (w_in_bus[(64*i) + 16*3 +: 16]),
                .i_sel   (i_sel[1:0]),
                .o_data  (w_stage1_out[16*i +: 16])
            );
        end
    endgenerate

    // 2段目の選択（最終的な2入力1出力の選択）
    // i_sel[2] が 0 なら in0〜3 側の結果を、1 なら in4〜7 側の結果を選択
    assign o_out = (i_sel[2]) ? w_stage1_out[31:16] : w_stage1_out[15:0];

endmodule