module imm_extender_mux_4to1_1b (
    input  wire [1:0] i_sel,
    input  wire       i_in0,
    input  wire       i_in1,
    input  wire       i_in2,
    input  wire       i_in3,
    output wire       o_out
);

    wire [3:0] w_in_bus;
    assign w_in_bus = {i_in3, i_in2, i_in1, i_in0};

    // 4つの入力から選択信号に基づき1ビットを選択して出力
    assign o_out = w_in_bus[i_sel];

endmodule